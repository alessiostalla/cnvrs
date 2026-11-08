;;; Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
;;; ParserATNFactory, TailEpsilonRemover and parser state compaction,
;;; following ANTLR Java 4.13.2. See antlr-runtime/LICENSE-ANTLR.txt.
(in-package #:cnvrs)

(defun java-left-recursion (definitions)
  "Produce Java's primary-block / precedence-loop rewrite without helper rules."
  (let ((left-rules nil))
    (values
     (loop for (rule source) in definitions collect
       (let* ((antlr (and (consp source) (eq (first source) 'antlr-precedence)))
              (body (if antlr (second source) source))
              (alts (if (eq (expression-kind body) :choice) (rest body) (list body)))
              (recursive (remove-if-not (lambda (a) (direct-left-alternative rule a)) alts)))
         (if (null recursive) (list rule body)
             (let ((bases nil) (binary nil) (suffixes nil)
                   ;; Native forms historically list operators low to high;
                   ;; the equivalent Java rule lists them high to low.
                   (ordered (if antlr alts
                                (let ((ops (reverse recursive)))
                                  (mapcar (lambda (a)
                                            (if (member a recursive :test #'eq)
                                                (pop ops) a)) alts)))))
               (push rule left-rules)
               (labels ((retarget-last (form precedence)
                          (cond ((eq form rule) (list 'atn-call rule precedence))
                                ((atom form) form)
                                ((member (first form) '(token predicate action not-token)) form)
                                (t (let ((copy (copy-list form)))
                                     (setf (car (last copy))
                                           (retarget-last (car (last copy)) precedence))
                                     copy)))))
                 (loop for alt in ordered for index from 1
                       for precedence = (1+ (- (length alts) index)) do
                   (multiple-value-bind (suffix right label left-label)
                       (direct-left-alternative rule alt)
                     (if suffix
                         (let* ((has-right (labels ((contains (x)
                                                      (or (eq x rule)
                                                          (and (consp x)
                                                               (not (member (first x) '(token predicate action)))
                                                               (some #'contains (rest x))))))
                                            (some #'contains suffix)))
                                (tail (if has-right
                                          (retarget-last (cons 'and suffix)
                                                         (if right precedence (1+ precedence)))
                                          (cons 'and suffix)))
                                (op (list 'atn-fold label left-label
                                          (cons 'and (cons (list 'atn-precedence precedence)
                                                           (rest tail))))))
                           (if has-right (push op binary) (push op suffixes)))
                         (push (if (antlr-prefix-alternative rule alt)
                                   (retarget-last alt precedence) alt) bases)))))
               (unless bases (grammar-fail "Left-recursive rule ~S needs a base alternative" rule))
               (setf bases (nreverse bases))
               ;; The artificial Java rule places {} in the first primary alt.
               (setf (first bases) (list 'and '(atn-noop) (first bases)))
               (list rule (list 'and (cons 'or bases)
                                (list '* (cons 'or (append (nreverse binary)
                                                          (nreverse suffixes))))))))))
     left-rules)))

(eval-when (:compile-toplevel :load-toplevel :execute)
(defclass parser-range-expr (parser-expr)
  ((value :initarg :value :reader parser-expr-value)))
(defclass parser-lexer-set-expr (parser-set-expr) ())
(defclass parser-lexer-action-expr (parser-expr)
  ((value :initarg :value :reader parser-expr-value)))
(defclass parser-lexer-commands-expr (parser-unary-expr)
  ((commands :initarg :commands :reader parser-expr-commands)))
(defclass parser-lexer-optional-expr (parser-optional-expr)
  ((lazy :initarg :lazy :reader parser-expr-lazy)))
(defclass parser-lexer-star-expr (parser-star-expr)
  ((lazy :initarg :lazy :reader parser-expr-lazy)))
(defclass parser-lexer-plus-expr (parser-plus-expr)
  ((lazy :initarg :lazy :reader parser-expr-lazy))))

(defun build-java-atn (grammar definitions left-rules &key lexer-modes rule-modes)
  "Construct and compact the same parser graph as Java's ParserATNFactory."
  (declare (optimize (speed 1) (compilation-speed 3)))
  (let ((rule-index -1) (decisions 0) (event-id 0) (mode-starts (make-hash-table :test 'eq)))
    (labels
        ((state (id) (aref (parser-states grammar) id))
         (new (&optional (kind :basic))
           (let ((id (new-state grammar)))
             (setf (state-kind (state id)) kind
                   (state-rule-index (state id)) rule-index)
             id))
         (eps (a b) (add-edge grammar a :epsilon b))
         (decision (id)
           (setf (state-decision (state id)) decisions)
           (incf decisions))
         (remove-state (id target)
           ;; End-of-element annotations precede those on the next element.
           ;; Conditional close events can safely live on a shared block end.
           (setf (state-events (state target))
                 (append (state-events (state id)) (state-events (state target)))
                 (aref (parser-states grammar) id) nil))
         (atom-handle (kind &optional value)
           (let ((a (new)) (b (new)))
             (add-edge grammar a kind b value) (cons a b)))
         (join (handles)
           (loop for (h next) on handles while next do
             (let* ((a (state (car h))) (b (state (cdr h)))
                    (edges (state-edges a)) (edge (first edges)))
               (if (and (eq (state-kind a) :basic) (eq (state-kind b) :basic)
                        (= (length edges) 1) (= (transition-target edge) (cdr h)))
                   (progn (setf (transition-target edge) (car next))
                          (remove-state (cdr h) (car next)))
                   (eps (cdr h) (car next)))))
           (cons (caar handles) (cdr (car (last handles)))))
         (trim-tail (start)
           (let ((seen (make-hash-table)))
             (labels ((visit (id)
                        (unless (gethash id seen)
                          (setf (gethash id seen) t)
                          (let* ((p (state id)) (edges (state-edges p)) (edge (first edges)))
                            (when (and (eq (state-kind p) :basic) (= (length edges) 1))
                              (let* ((q (state (transition-target edge)))
                                     (out (state-edges q)) (e (first out)))
                                (when (and (eq (state-kind q) :basic) (= (length out) 1)
                                           (eq (transition-kind e) :epsilon)
                                           (member (state-kind (state (transition-target e)))
                                                   '(:block-end :plus-loop-back :star-loop-back)))
                                  (let ((old (transition-target edge)) (target (transition-target e)))
                                    (setf (transition-target edge) target)
                                    (remove-state old target)))))
                            ;; Java's ATNVisitor follows RuleTransition.target,
                            ;; not followState. That traversal detail determines
                            ;; which tail epsilons survive construction.
                            (dolist (e (state-edges p))
                              (visit (if (eq (transition-kind e) :call)
                                         (gethash (transition-value e) (parser-starts grammar))
                                         (transition-target e))))))))
               (visit start))))
         (block-handle (parts &optional quantifier lazy)
           ;; GrammarTransformPipeline.reduceBlocksToSets precedes construction.
           (let* ((parts (if (and (> (length parts) 1)
                                  (every (lambda (e) (typep e 'parser-token-expr)) parts))
                             (list (make-instance 'parser-set-expr :source nil
                                                  :value (mapcar #'parser-expr-value parts)))
                             parts))
                  (alts (mapcar #'build parts)))
             (when (and (null quantifier) (= (length alts) 1))
               (return-from block-handle (first alts)))
             (let* ((a (new (case quantifier (:star :star-block-start)
                                                   (:plus :plus-block-start) (t :block-start))))
                    (b (new :block-end)))
               (setf (state-end-state (state a)) b)
               (when (or (eq quantifier :optional) (> (length alts) 1)) (decision a))
               (dolist (h alts) (eps a (car h)) (eps (cdr h) b) (trim-tail (car h)))
               (case quantifier
                 (:optional
                  (setf (state-non-greedy-p (state a)) lazy)
                  (setf (state-exit-alternative (state a)) (length alts))
                  (eps a b)
                  (when lazy (setf (state-edges (state a)) (reverse (state-edges (state a)))))
                  (cons a b))
                 (:star
                  (let ((entry (new :star-loop-entry)) (end (new :loop-end))
                        (back (new :star-loop-back)))
                    (decision entry)
                    (setf (state-non-greedy-p (state entry)) lazy)
                    (setf (state-loop-back (state entry)) back
                          (state-loop-back (state end)) back
                          (state-exit-alternative (state entry)) 1
                          (state-repetition-p (state entry)) t)
                    (eps entry a) (eps entry end) (eps b back) (eps back entry)
                    (when lazy (setf (state-edges (state entry)) (reverse (state-edges (state entry)))))
                    (cons entry end)))
                 (:plus
                  (let ((back (new :plus-loop-back)) (end (new :loop-end)))
                    (decision back)
                    (setf (state-non-greedy-p (state back)) lazy)
                    (setf (state-loop-back (state a)) back
                          (state-loop-back (state end)) back
                          (state-exit-alternative (state back)) 1
                          (state-repetition-p (state back)) t)
                    (eps b back) (eps back a) (eps back end)
                    (when lazy (setf (state-edges (state back)) (reverse (state-edges (state back)))))
                    (cons a end)))
                 (otherwise (cons a b))))))
         (body-alts (expr)
           (if (typep expr 'parser-choice-expr) (parser-expr-parts expr) (list expr)))
         (event (id value) (setf (state-events (state id))
                                     (append (state-events (state id)) (list value))))
         (build (e)
           (typecase e
             (parser-reference-expr
              (let ((h (atom-handle :call (parser-expr-name e))))
                (setf (state-call-precedence (state (car h))) (parser-expr-precedence e)) h))
             (parser-token-expr (atom-handle :token (parser-expr-value e)))
             (parser-range-expr (atom-handle :range (parser-expr-value e)))
             (parser-set-expr (atom-handle :token-set (parser-expr-value e)))
             (parser-lexer-action-expr (atom-handle :action (parser-expr-value e)))
             (parser-lexer-commands-expr
              ;; Java lexerAltCommands connects with an epsilon rather than
              ;; elemList splicing; the difference survives state compaction.
              (let ((body (build (parser-expr-body e)))
                    (commands (join (mapcar #'build (parser-expr-commands e)))))
                (eps (cdr body) (car commands)) (cons (car body) (cdr commands))))
             (parser-not-token-expr (atom-handle :not-token (parser-expr-excluded e)))
             (parser-wildcard-expr (atom-handle :wildcard))
             (parser-noop-expr (atom-handle :action))
             (parser-precedence-expr (atom-handle :precedence (parser-expr-value e)))
             (parser-predicate-expr (atom-handle :predicate (parser-expr-callback e)))
             (parser-action-expr (atom-handle :action (parser-expr-callback e)))
             (parser-alt-label-expr
              (let ((h (build (parser-expr-body e))))
                (event (car h) (list :alternative (parser-expr-label e))) h))
             (parser-label-expr
              (let ((h (build (parser-expr-body e))) (id (incf event-id)))
                (push (list :open id (parser-expr-label e)) (state-events (state (car h))))
                (event (cdr h) (list :close id)) h))
             (parser-fold-expr
              (let ((h (build (parser-expr-body e))))
                (event (car h) (list :fold (parser-expr-label e) (parser-expr-left-label e))) h))
             (parser-choice-expr (block-handle (parser-expr-parts e)))
             (parser-sequence-expr
              (if (parser-expr-parts e) (join (mapcar #'build (parser-expr-parts e)))
                  (atom-handle :epsilon)))
             (parser-lexer-optional-expr
              (block-handle (body-alts (parser-expr-body e)) :optional (parser-expr-lazy e)))
             (parser-lexer-star-expr
              (block-handle (body-alts (parser-expr-body e)) :star (parser-expr-lazy e)))
             (parser-lexer-plus-expr
              (block-handle (body-alts (parser-expr-body e)) :plus (parser-expr-lazy e)))
             (parser-optional-expr (block-handle (body-alts (parser-expr-body e)) :optional))
             (parser-star-expr (block-handle (body-alts (parser-expr-body e)) :star))
             (parser-plus-expr (block-handle (body-alts (parser-expr-body e)) :plus))
             (t (grammar-fail "No ATN construction for ~S" e)))))
      (dolist (mode lexer-modes)
        (let ((start (new :token-start)))
          (decision start) (setf (gethash mode mode-starts) start)))
      (loop for (name expression) in definitions for index from 0 do
        (setf rule-index index)
        (let ((start (new :rule-start)) (stop (new :rule-stop)))
          (setf (gethash name (parser-starts grammar)) start
                (gethash name (parser-stops grammar)) stop
                (state-stop-rule (state stop)) name
                (state-precedence-rule-p (state start)) (not (null (member name left-rules))))))
      (loop for (name expression) in definitions for index from 0 do
        (setf rule-index index)
        (let ((h (build expression)))
          (eps (gethash name (parser-starts grammar)) (car h))
          (eps (cdr h) (gethash name (parser-stops grammar)))))
      ;; Java allocates one EOF target, including when no start-rule EOF edge
      ;; survives serialization. Runtime stop transitions are rebuilt below.
      (if lexer-modes
          (progn
            (loop for (name expression) in definitions
                  for mode in rule-modes do
              (when (gethash mode mode-starts)
                (eps (gethash mode mode-starts) (gethash name (parser-starts grammar)))))
            (optimize-lexer-atn-sets grammar))
          (new))
      (let* ((old (parser-states grammar)) (mapping (make-array (length old)))
             (fresh (make-array 0 :adjustable t :fill-pointer 0)))
        (loop for s across old for id from 0 when s do
          (setf (aref mapping id) (length fresh)) (vector-push-extend s fresh))
        (loop for s across fresh for id from 0 do
          (setf (state-id s) id)
          (dolist (edge (state-edges s))
            (setf (transition-target edge) (aref mapping (transition-target edge))))
          (when (state-end-state s) (setf (state-end-state s) (aref mapping (state-end-state s))))
          (when (state-loop-back s) (setf (state-loop-back s) (aref mapping (state-loop-back s)))))
        (dolist (table (list (parser-starts grammar) (parser-stops grammar)))
          (maphash (lambda (name id) (setf (gethash name table) (aref mapping id))) table))
        (maphash (lambda (mode id) (setf (gethash mode mode-starts) (aref mapping id))) mode-starts)
        (setf (parser-states grammar) fresh)
        ;; ATNDeserializer.markPrecedenceDecisions.
        (loop for s across fresh when (and (eq (state-kind s) :star-loop-entry)
                                           (member (first (nth (state-rule-index s) definitions)) left-rules)) do
          (let* ((last (car (last (state-edges s))))
                 (end (aref fresh (transition-target last))))
            (when (and (eq (state-kind end) :loop-end)
                       (state-stop-rule (aref fresh (transition-target (first (state-edges end))))))
              (setf (state-precedence-decision-p s) t))))))
    (values grammar mode-starts)))

(defun apply-atn-events (events builder rule children start end label labels)
  "Apply tree annotations without adding transitions or helper rules to the ATN."
  (dolist (event events)
    (case (first event)
      (:alternative (setf label (second event)))
      (:open (push (list (second event) (third event) end children) labels))
      (:close
       (when (and labels (eql (second event) (caar labels)))
         (destructuring-bind (id name begin tail) (pop labels)
           (declare (ignore id))
           (let ((selected (ldiff children tail)))
             (setf children (cons (make-labeled-parse-node builder :label
                                                         (nreverse selected) begin end name)
                                  tail))))))
      (:fold
       (let* ((left (make-labeled-parse-node builder rule (reverse children) start end label))
              (wrapped (if (third event)
                           (make-labeled-parse-node builder :label (list left) start end (third event))
                           left)))
         (setf children (list wrapped) label (second event))))))
  (values children label labels))
