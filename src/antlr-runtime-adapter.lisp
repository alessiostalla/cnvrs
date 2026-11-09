;;; Frontend boundary: Lisp grammar graphs and arbitrary token values are
;;; lowered to the typed ATN/token stream consumed by the Java runtime port.
(in-package #:cnvrs)

;; Runtime policy is file-local: the standalone ASDF system is compiled before
;; the native frontend. Retain safety checks while optimizing the hot loops.
(declaim (optimize (speed 3) (safety 1) (debug 0) (space 0) (compilation-speed 1)))
(defvar *antlr-callback-input* nil)
(defun ensure-antlr-runtime (grammar)
  (or (parser-atn-runtime grammar)
      (bordeaux-threads:with-lock-held ((parser-atn-runtime-lock grammar))
        (%ensure-antlr-runtime grammar))))
(defun %ensure-antlr-runtime (grammar)
  (declare (optimize (speed 1) (compilation-speed 3) (safety 2)))
  (or (parser-atn-runtime grammar)
      (let* ((original (parser-states grammar))
             (states (make-array (length original)))
             (tokens (make-hash-table :test 'equal))
             (stops (make-array (hash-table-count (parser-stops grammar))))
             (rules (make-hash-table :test 'eq))
             (predicates (make-hash-table :test 'equal))
             (predicate-indices (make-hash-table :test 'eql))
             (decisions nil) (decision-map (make-hash-table)))
        (loop for token across (parser-token-keys grammar) for id from 1 do
          (setf (gethash token tokens) (if (eq token +end-of-input+) -1 id)))
        (maphash (lambda (name id)
                   (let ((rule (state-rule-index (aref original id))))
                     (setf (gethash name rules) rule
                           (svref stops rule) (gethash name (parser-stops grammar)))))
                 (parser-starts grammar))
        (loop for source across original for id from 0 do
          (setf (svref states id)
                (cnvrs/antlr-runtime:make-atn-state
                 :number id :rule (state-rule-index source) :kind (state-kind source)
                 :end-state (state-end-state source) :loop-back (state-loop-back source)
                 :precedence-rule-p (state-precedence-rule-p source)
                 :precedence-decision-p (state-precedence-decision-p source))))
        (loop for source across original for id from 0 do
          (when (state-decision source)
            (setf (gethash id decision-map) (state-decision source))
            (push (cons (state-decision source) id) decisions))
          (setf (cnvrs/antlr-runtime:atn-state-transitions (svref states id))
                (loop for edge in (state-edges source)
                      for kind = (transition-kind edge)
                      collect (cnvrs/antlr-runtime:make-atn-transition
                               :kind (case kind (:call :rule) (:token :atom) (:not-token :not-set) (:token-set :set) (t kind))
                               :target (if (eq kind :call)
                                           (gethash (transition-value edge) (parser-starts grammar))
                                           (transition-target edge))
                               :follow (and (eq kind :call) (transition-target edge))
                               :precedence (if (eq kind :call) (state-call-precedence source) 0)
                               :label (case kind
                                        (:predicate
                                         (let* ((rule (cnvrs/antlr-runtime:atn-state-rule (svref states id)))
                                                (index (gethash :global predicate-indices 0)))
                                           (incf (gethash :global predicate-indices 0))
                                           (setf (gethash (cons rule index) predicates) (transition-value edge))
                                           (list :predicate rule index nil)))
                                        (:precedence
                                         (incf (gethash :global predicate-indices 0))
                                         (transition-value edge))
                                        (:token (gethash (transition-value edge) tokens))
                                        ((:not-token :token-set) (mapcar (lambda (x) (gethash x tokens)) (transition-value edge))))))))
        ;; Java ATNDeserializer synthesizes rule-stop follow transitions.
        (loop for source across original do
          (dolist (edge (state-edges source))
            (when (eq (transition-kind edge) :call)
              (let* ((stop (svref states (gethash (transition-value edge) (parser-stops grammar))))
                     (follow (transition-target edge)))
                (unless (find follow (cnvrs/antlr-runtime:atn-state-transitions stop)
                              :key #'cnvrs/antlr-runtime:atn-transition-target)
                  (setf (cnvrs/antlr-runtime:atn-state-transitions stop)
                        (append (cnvrs/antlr-runtime:atn-state-transitions stop)
                                (list (cnvrs/antlr-runtime:make-atn-transition :kind :epsilon :target follow
                                     :outermost-precedence-return
                                     (if (and (state-precedence-rule-p
                                               (aref original (gethash (transition-value edge) (parser-starts grammar))))
                                              (zerop (state-call-precedence source)))
                                         (gethash (transition-value edge) rules) -1))))))))))
        (let ((atn (cnvrs/antlr-runtime:make-atn :states states :rule-stops stops
                                               :decisions (map 'vector #'cdr (sort decisions #'< :key #'car))
                                               :max-token-type (1+ (hash-table-count tokens)))))
          (setf (parser-atn-runtime grammar)
                (list (cnvrs/antlr-runtime:make-parser-atn-simulator
                       atn :predicate-evaluator
                       (lambda (predicate types at outer)
                         (declare (ignore types outer))
                         (semantic-call (gethash (cons (second predicate) (third predicate)) predicates)
                                        *antlr-callback-input* at)))
                      tokens decision-map))))))
(defun antlr-token-input (input table)
  (or (and *antlr-input-cache* (gethash input *antlr-input-cache*))
      (let ((types nil) (positions (make-hash-table)) (logical 0))
        (declare (type fixnum logical))
        (loop for p of-type fixnum = (input-start-position input) then (input-next-position input p)
              while (< p (input-size input)) do
                (setf (gethash p positions) logical)
                (push (gethash (token-key (input-token input p)) table (1+ (hash-table-count table))) types)
                (incf logical))
        (setf (gethash (input-size input) positions) logical)
        (let ((entry (list (coerce (nreverse types) 'vector) positions)))
          (when *antlr-input-cache* (setf (gethash input *antlr-input-cache*) entry))
          entry))))
(defun antlr-adaptive-predict (grammar state stack input position)
  (destructuring-bind (sim table decision-map) (ensure-antlr-runtime grammar)
    (cache-get-or-compute (parser-sll-decisions grammar) state
                          (lambda () (aref (cnvrs/antlr-runtime:simulator-decision-dfas sim)
                                           (gethash state decision-map))))
    (destructuring-bind (types positions) (antlr-token-input input table)
      (let ((*antlr-callback-input* input))
        (handler-case
            (1- (cnvrs/antlr-runtime:adaptive-predict
                 sim types (gethash state decision-map) :position (gethash position positions)
                 :outer-context stack :precedence *antlr-precedence*))
          (cnvrs/antlr-runtime:no-viable-alt () nil))))))

(defun parser-prediction-simulator (parser)
  "Return the parser's ANTLR Java reference simulator (creating it on first use)."
  (let ((grammar (ensure-compiled parser)))
    (unless (parser-p grammar) (grammar-fail "Prediction requires a parser"))
    (first (ensure-antlr-runtime grammar))))

(defun initialize-direct-lookahead (grammar)
  "Apply Java AnalysisPipeline/ParserFactory LL(1) selection without changing ATNs."
  (declare (optimize (speed 1) (compilation-speed 3) (safety 2)))
  (destructuring-bind (sim types decisions) (ensure-antlr-runtime grammar)
    (declare (ignore decisions))
    (let* ((atn (cnvrs/antlr-runtime:simulator-atn sim))
           (states (parser-states grammar)) (keys (parser-token-keys grammar)))
      (loop for id across (cnvrs/antlr-runtime:atn-decisions atn)
            for state = (aref states id)
            for look = (unless (state-non-greedy-p state)
                         (cnvrs/antlr-runtime:decision-lookahead atn id)) do
        ;; Java normalizes a multi-alt EBNF body into a nested choice; its
        ;; entry/loopback and inner block are independently LL(1)-eligible.
        (when (cnvrs/antlr-runtime:lookahead-disjoint-p look)
          (let* ((default (state-exit-alternative state))
                 (table (make-array (1+ (length keys)) :initial-element default)))
            (labels ((alternative (type)
                       (or (position-if (lambda (set) (member type set)) look) default)))
              (loop for key across keys for index from 0 do
                (setf (aref table index) (alternative (gethash key types))))
              ;; Wildcard/not-set choices include arbitrary Lisp tokens outside
              ;; the explicit vocabulary, using the adapter's existing extra type.
              (setf (aref table (length keys)) (alternative (cnvrs/antlr-runtime::atn-max-token-type atn))))
            (setf (state-direct-lookahead state) table))))))
  grammar)
