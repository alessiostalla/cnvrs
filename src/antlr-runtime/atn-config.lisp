;;; Port of ATNConfig, ATNConfigSet and PredictionMode, ANTLR 4.13.2.
(in-package #:cnvrs/antlr-runtime)

;; Runtime policy is file-local: the standalone ASDF system is compiled before
;; the native frontend. Retain safety checks while optimizing the hot loops.
(declaim (optimize (speed 3) (safety 1) (debug 0) (space 0) (compilation-speed 1)))

(defstruct atn
  (states #() :type simple-vector) (rule-stops #() :type simple-vector)
  (decisions #() :type simple-vector) (max-token-type 0 :type fixnum)
  (mode-starts #() :type simple-vector) (rule-starts #() :type simple-vector)
  (rule-token-types #() :type simple-vector) (lexer-actions #() :type simple-vector))
(defstruct atn-state (number 0 :type fixnum) (kind :basic :type symbol)
  (rule 0 :type fixnum) (transitions nil :type list)
  precedence-rule-p precedence-decision-p
  (loop-back nil :type (or null fixnum)) (end-state nil :type (or null fixnum)) non-greedy-p)
(defstruct atn-transition (kind :epsilon :type symbol) (target 0 :type fixnum)
  (follow nil :type (or null fixnum)) label
  (outermost-precedence-return -1 :type fixnum) context-dependent-p (precedence 0 :type fixnum))
(defstruct atn-config (state 0 :type fixnum) (alt 1 :type fixnum)
  (context (empty-prediction-context) :type (or null prediction-context))
  (semantic t) (outer-depth 0 :type fixnum) precedence-filter-suppressed-p)
(defstruct (atn-config-set (:conc-name config-set-))
  (items (make-array 0 :adjustable t :fill-pointer 0) :type (vector t))
  (lookup (make-hash-table :test 'equal) :type (or null hash-table)) full-context
  (unique-alt nil :type (or null fixnum)) conflicting-alts has-semantic-context dips-into-outer-context read-only-p)
(defvar *merge-cache* nil)

(defun derive-config (config state &key (context (atn-config-context config))
                                      (semantic (atn-config-semantic config)))
  (make-atn-config :state state :alt (atn-config-alt config) :context context
                   :semantic semantic :outer-depth (atn-config-outer-depth config)
                   :precedence-filter-suppressed-p
                   (atn-config-precedence-filter-suppressed-p config)))
(defun config-set-add (set config &optional (merge-cache *merge-cache*))
  (when (config-set-read-only-p set) (error "ATNConfigSet is read-only"))
  (unless (eq (atn-config-semantic config) t)
    (setf (config-set-has-semantic-context set) t))
  (when (plusp (atn-config-outer-depth config))
    (setf (config-set-dips-into-outer-context set) t))
  (let* ((key (list (atn-config-state config) (atn-config-alt config)
                    (atn-config-semantic config)))
         (existing (gethash key (config-set-lookup set))))
    (if existing
        (setf (atn-config-context existing)
              (merge-contexts (atn-config-context existing) (atn-config-context config)
                              (not (config-set-full-context set)) merge-cache)
              (atn-config-outer-depth existing)
              (max (atn-config-outer-depth existing) (atn-config-outer-depth config))
              (atn-config-precedence-filter-suppressed-p existing)
              (or (atn-config-precedence-filter-suppressed-p existing)
                  (atn-config-precedence-filter-suppressed-p config)))
        (progn (setf (gethash key (config-set-lookup set)) config)
               (vector-push-extend config (config-set-items set)))))
  t)
(defun config-set-alternatives (set)
  (sort (remove-duplicates (map 'list #'atn-config-alt (config-set-items set))) #'<))
(defun unique-alt (set)
  (let ((alt nil))
    (loop for config across (config-set-items set) do
      (if alt (unless (= alt (atn-config-alt config)) (return-from unique-alt nil))
          (setf alt (atn-config-alt config))))
    alt))
(defun stop-config-p (atn config)
  (eq (atn-state-kind (aref (atn-states atn) (atn-config-state config))) :rule-stop))
(defun all-configs-in-rule-stop-states (atn set)
  (every (lambda (c) (stop-config-p atn c)) (config-set-items set)))
(defun conflicting-alt-subsets (set)
  ;; Java AltAndContextMap ignores alt and semantic context, but compares
  ;; complete prediction contexts. Hash buckets avoid flattening the DAG.
  (let ((buckets (make-hash-table :test 'equal)) (groups nil))
    (loop for c across (config-set-items set) do
      (let* ((context (atn-config-context c))
             (key (cons (atn-config-state c) (context-hash context)))
             (group (find context (gethash key buckets) :key #'car :test #'context-equal)))
        (unless group
          (setf group (list context))
          (push group (gethash key buckets)) (push group groups))
        (pushnew (atn-config-alt c) (cdr group))))
    (mapcar (lambda (g) (sort (copy-list (cdr g)) #'<)) groups)))
(defun single-viable-alt (alt-subsets)
  (let ((answer nil))
    (dolist (subset alt-subsets)
      (let ((minimum (reduce #'min subset)))
        (when (and answer (/= answer minimum)) (return-from single-viable-alt nil))
        (setf answer minimum)))
    answer))
(defun has-sll-conflict-terminating-prediction (atn set &optional (mode :ll))
  (when (all-configs-in-rule-stop-states atn set)
    (return-from has-sll-conflict-terminating-prediction t))
  (when (and (eq mode :sll) (config-set-has-semantic-context set))
    (let ((stripped (make-atn-config-set)))
      (loop for c across (config-set-items set) do
        (config-set-add stripped (derive-config c (atn-config-state c) :semantic t)))
      (setf set stripped)))
  (and (some #'cdr (conflicting-alt-subsets set))
       (let ((state-alts (make-hash-table)))
         (loop for c across (config-set-items set) do
           (pushnew (atn-config-alt c) (gethash (atn-config-state c) state-alts)))
         (not (loop for alts being the hash-values of state-alts
                    thereis (null (cdr alts)))))))

;; SemanticContext uses T for Empty.Instance, NIL for no predicate/false,
;; and immutable predicate/operator forms for the remaining Java subclasses.
(defun semantic-operator (operator a b)
  (cond ((eq operator :and)
         (when (or (null a) (eq a t)) (return-from semantic-operator b))
         (when (or (null b) (eq b t)) (return-from semantic-operator a)))
        (t
         (when (null a) (return-from semantic-operator b))
         (when (null b) (return-from semantic-operator a))
         (when (or (eq a t) (eq b t)) (return-from semantic-operator t))))
  (when (equal a b) (return-from semantic-operator a))
  (let* ((operands (remove-duplicates
                    (append (if (eq (car a) operator) (cdr a) (list a))
                            (if (eq (car b) operator) (cdr b) (list b))) :test #'equal))
         (precedences (remove-if-not (lambda (p) (eq (car p) :precedence)) operands)))
    (when precedences
      (setf operands (remove-if (lambda (p) (eq (car p) :precedence)) operands))
      (push (list :precedence (reduce (if (eq operator :and) #'min #'max)
                                     precedences :key #'second)) operands))
    (if (null (cdr operands)) (car operands)
        (cons operator (sort operands #'string< :key #'prin1-to-string)))))
