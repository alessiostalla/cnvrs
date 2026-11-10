(in-package #:cnvrs)

(define-condition grammar-error (error)
  ((message :initarg :message :reader grammar-error-message))
  (:report (lambda (condition stream)
             (write-string (grammar-error-message condition) stream))))

(define-condition parse-error (error)
  ((position :initarg :position :reader parse-error-position)
   (token :initarg :token :reader parse-error-token)
   (expected :initarg :expected :reader parse-error-expected)
   (rule :initarg :rule :reader parse-error-rule))
  (:report (lambda (condition stream)
             (format stream "Parse error in ~S at token ~D (~S); expected ~S"
                     (parse-error-rule condition)
                     (parse-error-position condition)
                     (parse-error-token condition)
                     (parse-error-expected condition)))))

(define-condition mismatched-token (parse-error)
  ((next-state :initarg :next-state :reader mismatch-next-state)))
(define-condition no-viable-alternative (parse-error) ())
(define-condition unexpected-input (parse-error) ())

(defstruct recovery action condition token)
(defstruct (state (:include graph-state))
  stop-rule exit-alternative repetition-p
  direct-lookahead
  (kind :basic) rule-index end-state loop-back decision non-greedy-p precedence-rule-p
  precedence-decision-p (call-precedence 0) events)
(defvar *prediction-input-cache* nil)
(defvar *prediction-precedence* 0)
(defstruct parser states starts stops default-rule lexer (tree-builder :node)
  (rewrites (make-hash-table :test 'eq))
  has-negated-tokens metadata semantic-rules
  (cache-backend :hash-table)
  (full-context-strategy :recompute)
  decisions token-keys token-index runner node-runner
  atn-runtime
  (atn-runtime-lock (bordeaux-threads:make-lock "ANTLR frontend runtime")))
(defstruct parser-definition name kind default-rule lexer cache-backend metadata
  parser-package lexer-package
  (full-context-strategy :recompute)
  (tree-builder :node)
  (rules nil) (imports nil) (origins nil) compiled)
(defstruct parser-run-state
  input
  (tokens #() :type simple-vector)
  (position 0 :type fixnum)
  (logical-position 0 :type fixnum))
(declaim (ftype function ensure-parser-compiled))
(declaim (ftype function resolve-full-context-strategy))
(declaim (ftype function runtime-adaptive-predict ensure-parser-runtime))
(declaim (ftype function compile-parser-runner))
(declaim (ftype function initialize-token-index initialize-direct-lookahead java-left-recursion build-java-atn apply-atn-events))

(defun grammar-fail (control &rest arguments)
  (error 'grammar-error :message (apply #'format nil control arguments)))

(defun plist-key-p (plist key)
  (loop for tail on plist by #'cddr
        thereis (eq (first tail) key)))

(defun grammar-operator-p (symbol)
  (member symbol '(and or * + seq ? *? +? ?? range unicode-property one-of not-one-of any
                   label alt-label token not-token eof predicate action right
                   source-order-precedence defparser defrule with-mode use)))

(defun check-lexer-kind-overlap (rule-names lexer)
  (when (compiled-lexer-p lexer)
    (loop for kind across (compiled-lexer-kinds lexer)
          when (gethash kind rule-names)
            do (grammar-fail "~S is both a parser rule name and a lexer token kind"
                             kind))))

(defvar *parser-rule-packages* nil)

(defun expression-kind (expression)
  (cond ((atom expression)
         (cond ((and (symbolp expression)
                     (member (symbol-package expression)
                             *parser-rule-packages*))
                :reference)
               (t :token)))
        ((and (consp expression) (symbolp (first expression)))
         (case (first expression)
           ((and seq) :sequence) (or :choice) (* :star) (+ :plus)
           (? :optional) (label :label) (alt-label :alt-label)
           (token :token-form) (not-token :not-token)
           (predicate :predicate) (action :action)))
        (t nil)))

(defclass parser-expr ()
  ((source :initarg :source :reader parser-expr-source)))
(defclass parser-reference-expr (parser-expr)
  ((precedence :initarg :precedence :initform 0 :reader parser-expr-precedence)
   (name :initarg :name :reader parser-expr-name)))
(defclass parser-token-expr (parser-expr)
  ((value :initarg :value :reader parser-expr-value)))
(defclass parser-not-token-expr (parser-expr)
  ((excluded :initarg :excluded :reader parser-expr-excluded)))
(defclass parser-callback-expr (parser-expr)
  ((callback :initarg :callback :reader parser-expr-callback)))
(defclass parser-predicate-expr (parser-callback-expr) ())
(defclass parser-action-expr (parser-callback-expr) ())
(defclass parser-noop-expr (parser-expr) ())
(defclass parser-precedence-expr (parser-expr)
  ((value :initarg :value :reader parser-expr-value)))
(defclass parser-set-expr (parser-expr)
  ((value :initarg :value :reader parser-expr-value)))
(defclass parser-wildcard-expr (parser-expr) ())

(defun semantic-callback (form)
  (unless (and (= (length form) 2)
               (or (functionp (second form))
                   (and (symbolp (second form)) (not (keywordp (second form))))))
    (grammar-fail "~A requires a function or function name: ~S"
                  (first form) form))
  (second form))
(defclass parser-sequence-expr (parser-expr)
  ((parts :initarg :parts :reader parser-expr-parts)))
(defclass parser-choice-expr (parser-sequence-expr) ())
(defclass parser-unary-expr (parser-expr)
  ((body :initarg :body :reader parser-expr-body)))
(defclass parser-label-expr (parser-unary-expr)
  ((label :initarg :label :reader parser-expr-label)))
(defclass parser-alt-label-expr (parser-label-expr) ())
(defclass parser-fold-expr (parser-unary-expr)
  ((label :initarg :label :reader parser-expr-label)
   (left-label :initarg :left-label :reader parser-expr-left-label)))
(defclass parser-optional-expr (parser-unary-expr) ())
(defclass parser-star-expr (parser-unary-expr) ())
(defclass parser-plus-expr (parser-unary-expr) ())

(defun parser-expression-from-form (form)
  "Convert the public grammar form to an expression used during compilation."
  (when (consp form)
    (case (first form)
      (atn-call (return-from parser-expression-from-form
                  (make-instance 'parser-reference-expr :source form :name (second form)
                                 :precedence (third form))))
      (atn-precedence (return-from parser-expression-from-form
                        (make-instance 'parser-precedence-expr :source form :value (second form))))
      (atn-noop (return-from parser-expression-from-form
                  (make-instance 'parser-noop-expr :source form)))
      (atn-fold (return-from parser-expression-from-form
                  (make-instance 'parser-fold-expr :source form :label (second form)
                                 :left-label (third form)
                                 :body (parser-expression-from-form (fourth form)))))
      (eof (unless (= (length form) 1) (grammar-fail "EOF takes no arguments: ~S" form))
           (return-from parser-expression-from-form
             (make-instance 'parser-token-expr :source form :value +end-of-input+)))
      (any (unless (= (length form) 1) (grammar-fail "ANY takes no arguments: ~S" form))
           (return-from parser-expression-from-form
             (make-instance 'parser-wildcard-expr :source form)))))
  (let ((kind (expression-kind form)))
    (unless kind (grammar-fail "Invalid grammar expression: ~S" form))
    (flet ((unary (class)
             (unless (= (length form) 2)
               (grammar-fail "~A requires one expression: ~S" (first form) form))
             (make-instance class :source form
                                  :body (parser-expression-from-form (second form)))))
      (case kind
        (:reference (make-instance 'parser-reference-expr :source form :name form))
        (:token (make-instance 'parser-token-expr :source form :value form))
        (:predicate (make-instance 'parser-predicate-expr :source form
                                   :callback (semantic-callback form)))
        (:action (make-instance 'parser-action-expr :source form
                                :callback (semantic-callback form)))
        (:token-form
         (unless (= (length form) 2)
           (grammar-fail "TOKEN requires one value: ~S" form))
         (make-instance 'parser-token-expr :source form :value (second form)))
        (:not-token
         (unless (and (= (length form) 2) (consp (second form)))
           (grammar-fail "NOT-TOKEN requires a nonempty list of excluded tokens: ~S"
                         form))
         (make-instance 'parser-not-token-expr :source form
                                               :excluded (second form)))
        (:sequence
         (make-instance 'parser-sequence-expr :source form
                       :parts (mapcar #'parser-expression-from-form (rest form))))
        (:choice
         (unless (rest form)
           (grammar-fail "OR requires at least one alternative"))
         (make-instance 'parser-choice-expr :source form
                       :parts (mapcar #'parser-expression-from-form (rest form))))
        ((:label :alt-label)
         (unless (and (= (length form) 3)
                      (symbolp (second form))
                      (not (keywordp (second form))))
           (grammar-fail "~A requires a symbol label and one expression: ~S"
                         (first form) form))
         (make-instance (if (eq kind :label)
                            'parser-label-expr 'parser-alt-label-expr)
                        :source form :label (second form)
                        :body (parser-expression-from-form (third form))))
        (:optional (unary 'parser-optional-expr))
        (:star (unary 'parser-star-expr))
        (:plus (unary 'parser-plus-expr))
        (otherwise (grammar-fail "Invalid grammar expression: ~S" form))))))

(defgeneric validate-expression (expression names))
(defmethod validate-expression ((expression parser-expr) names)
  (declare (ignore names)))
(defmethod validate-expression ((expression parser-reference-expr) names)
  (unless (gethash (parser-expr-name expression) names)
    (grammar-fail "Undefined rule ~S" (parser-expr-name expression))))
(defmethod validate-expression ((expression parser-sequence-expr) names)
  (mapc (lambda (part) (validate-expression part names))
        (parser-expr-parts expression)))
(defmethod validate-expression ((expression parser-unary-expr) names)
  (validate-expression (parser-expr-body expression) names))

(defgeneric nullable-p (expression nullable))
(defmethod nullable-p ((expression parser-expr) nullable)
  (declare (ignore nullable)) nil)
(defmethod nullable-p ((expression parser-token-expr) nullable)
  (declare (ignore nullable))
  ;; EOF is an assertion in native execution and cannot advance the cursor.
  (eq (parser-expr-value expression) +end-of-input+))
(defmethod nullable-p ((expression parser-reference-expr) nullable)
  (gethash (parser-expr-name expression) nullable))
(defmethod nullable-p ((expression parser-noop-expr) nullable)
  (declare (ignore nullable)) t)
(defmethod nullable-p ((expression parser-precedence-expr) nullable)
  (declare (ignore nullable)) t)
(defmethod nullable-p ((expression parser-callback-expr) nullable)
  (declare (ignore nullable)) t)
(defmethod nullable-p ((expression parser-sequence-expr) nullable)
  (every (lambda (part) (nullable-p part nullable))
         (parser-expr-parts expression)))
(defmethod nullable-p ((expression parser-choice-expr) nullable)
  (some (lambda (part) (nullable-p part nullable))
        (parser-expr-parts expression)))
(defmethod nullable-p ((expression parser-unary-expr) nullable)
  (nullable-p (parser-expr-body expression) nullable))
(defmethod nullable-p ((expression parser-optional-expr) nullable)
  (declare (ignore nullable)) t)
(defmethod nullable-p ((expression parser-star-expr) nullable)
  (declare (ignore nullable)) t)
(defmethod nullable-p ((expression parser-plus-expr) nullable)
  (nullable-p (parser-expr-body expression) nullable))

(defgeneric leading-rules (expression nullable)
  (:documentation "Return rules reachable from EXPRESSION before any token is consumed.
NULLABLE maps rule names to whether they can match empty input."))
(defmethod leading-rules ((expression parser-expr) nullable)
  (declare (ignore nullable)) nil)
(defmethod leading-rules ((expression parser-reference-expr) nullable)
  (declare (ignore nullable)) (list (parser-expr-name expression)))
(defmethod leading-rules ((expression parser-sequence-expr) nullable)
  (loop for part in (parser-expr-parts expression)
        append (leading-rules part nullable)
        while (nullable-p part nullable)))
(defmethod leading-rules ((expression parser-choice-expr) nullable)
  (loop for part in (parser-expr-parts expression)
        append (leading-rules part nullable)))
(defmethod leading-rules ((expression parser-unary-expr) nullable)
  (leading-rules (parser-expr-body expression) nullable))

(defgeneric validate-progress-expression (expression nullable))
(defmethod validate-progress-expression ((expression parser-expr) nullable)
  (declare (ignore nullable)))
(defmethod validate-progress-expression ((expression parser-sequence-expr) nullable)
  (mapc (lambda (part) (validate-progress-expression part nullable))
        (parser-expr-parts expression)))
(defmethod validate-progress-expression ((expression parser-unary-expr) nullable)
  (validate-progress-expression (parser-expr-body expression) nullable))
(defmethod validate-progress-expression ((expression parser-star-expr) nullable)
  (when (nullable-p (parser-expr-body expression) nullable)
    (grammar-fail "Repetition body can match no tokens: ~S"
                  (parser-expr-source expression)))
  (call-next-method))
(defmethod validate-progress-expression ((expression parser-plus-expr) nullable)
  (when (nullable-p (parser-expr-body expression) nullable)
    (grammar-fail "Repetition body can match no tokens: ~S"
                  (parser-expr-source expression)))
  (call-next-method))

(defgeneric semantic-expression-p (expression))
(defmethod semantic-expression-p ((expression parser-expr)) nil)
(defmethod semantic-expression-p ((expression parser-callback-expr)) t)
(defmethod semantic-expression-p ((expression parser-sequence-expr))
  (some #'semantic-expression-p (parser-expr-parts expression)))
(defmethod semantic-expression-p ((expression parser-unary-expr))
  (semantic-expression-p (parser-expr-body expression)))
(defun validate-progress (definitions nullable)
  "Reject nullable repetition bodies and rule cycles that consume no tokens."
  (dolist (definition definitions)
    (validate-progress-expression (second definition) nullable))
  (let ((visiting (make-hash-table)) (done (make-hash-table))
        (expressions (make-hash-table)))
    (dolist (definition definitions)
      (setf (gethash (first definition) expressions) (second definition)))
    (labels ((visit (rule)
               (when (gethash rule visiting)
                 (grammar-fail "Left-recursive or zero-consumption rule cycle at ~S" rule))
               (unless (gethash rule done)
                 (setf (gethash rule visiting) t)
                 (dolist (next (leading-rules (gethash rule expressions) nullable))
                   (visit next))
                 (remhash rule visiting)
                 (setf (gethash rule done) t))))
      (dolist (definition definitions) (visit (first definition))))))

(defun direct-left-alternative (rule alternative)
  (let* ((alternative-label (and (eq (expression-kind alternative) :alt-label)
                                 (second alternative)))
         (unlabeled (if alternative-label (third alternative) alternative))
         (right (and (consp unlabeled)
                     (symbolp (first unlabeled))
                     (eq (first unlabeled) 'right)))
         (body (if right (second unlabeled) unlabeled))
         (parts (if (eq (expression-kind body) :sequence)
                    (rest body) (list body)))
         (left-label (and (eq (expression-kind (first parts)) :label)
                          (eq (third (first parts)) rule)
                          (second (first parts)))))
    (when right
      (unless (= (length unlabeled) 2)
        (grammar-fail "RIGHT requires one alternative: ~S" alternative)))
    (if (or (eq (first parts) rule) left-label)
        (progn
          (unless (rest parts)
            (grammar-fail "Left-recursive alternative must consume input: ~S" alternative))
          (values (rest parts) right alternative-label left-label))
        (progn
          (when right
            (grammar-fail "RIGHT requires a direct left-recursive alternative: ~S"
                          alternative))
          (values nil nil nil nil)))))

(defun prefix-alternative-p (rule alternative)
  (let* ((body (if (eq (expression-kind alternative) :alt-label)
                   (third alternative) alternative))
         (parts (and (eq (expression-kind body) :sequence) (rest body)))
         (last-part (car (last parts))))
    (and (rest parts)
         (or (eq last-part rule)
             (and (eq (expression-kind last-part) :label)
                  (eq (third last-part) rule))))))

(defun visible-rule (grammar rule)
  (or (second (gethash rule (parser-rewrites grammar))) rule))

(defvar *atn-state-constructor* 'make-state)
(defun new-state (grammar &optional stop-rule)
  (graph-new-state (parser-states grammar)
                   (lambda (id) (funcall *atn-state-constructor* :id id :stop-rule stop-rule))))

(defun add-edge (grammar from kind target &optional value)
  (graph-add-edge (parser-states grammar) from kind target value :append-p t))

(defun compile-grammar (definitions &key default-rule lexer
                                    (cache-backend :hash-table)
                                    (full-context-strategy :recompute)
                                    (tree-builder :node) metadata
                                    (compile-runners t))
  "Compile Lisp-form rule definitions into an in-memory parser.
DEFINITIONS is a list of (name expression) pairs. Expressions use
(AND ...), (OR ...), (* x), (+ x), (? x), (TOKEN value),
(LABEL name x), (ALT-LABEL name x), (ANY), and (EOF).
Direct left-recursive alternatives are ordered from low to high precedence;
(RIGHT alternative) gives a recursive alternative right associativity.
Bare symbols in a parser rule package name rules; symbols from other packages
and other atoms are literal tokens. (TOKEN value) forces a literal token when
a parser rule and token kind use the same package. DEFAULT-RULE chooses
the entry rule used by PARSE when no :RULE is supplied; otherwise the first
definition is used. LEXER maps source input to tokens before parsing.
CACHE-BACKEND selects :FSET, :HASH-TABLE, a custom backend, or
(:LOCKED backend). The default is :HASH-TABLE.
TREE-BUILDER selects the parse-node construction strategy. The result also
contains compiled rule runners for :NONE and the default :NODE builder.
FULL-CONTEXT-STRATEGY must be :RECOMPUTE, matching the Java predictor.
Caller-specific caches and custom full-context start hooks are unsupported."
  (resolve-full-context-strategy full-context-strategy)
  (unless (and (listp definitions) definitions)
    (grammar-fail "Expected a nonempty list of rule definitions"))
  (let* ((names (make-hash-table :test 'eq))
        (nullable (make-hash-table :test 'eq))
        (rewrites nil)
        (*parser-rule-packages*
          (cons nil (remove-duplicates
                     (mapcar (lambda (definition)
                               (and (consp definition)
                                    (symbolp (first definition))
                                    (symbol-package (first definition))))
                             definitions)))))
    (dolist (definition definitions)
      (unless (and (listp definition) (= (length definition) 2)
                   (symbolp (first definition)) (not (keywordp (first definition))))
        (grammar-fail "Expected (rule-name expression), got ~S" definition))
      (when (grammar-operator-p (first definition))
        (grammar-fail "Parser rule name ~S is a CNVRS grammar operator"
                      (first definition)))
      (when (gethash (first definition) names)
        (grammar-fail "Duplicate rule ~S" (first definition)))
      (setf (gethash (first definition) names) t))
    (check-lexer-kind-overlap names lexer)
    (setf default-rule (or default-rule (first (first definitions))))
    (unless (gethash default-rule names)
      (grammar-fail "Unknown default rule ~S" default-rule))
    (let ((left-rules nil))
      (multiple-value-setq (definitions left-rules) (java-left-recursion definitions))
      (setf rewrites (make-hash-table :test 'eq))
      (setf definitions
            (mapcar (lambda (definition)
                      (list (first definition)
                            (parser-expression-from-form (second definition))))
                    definitions))
      (dolist (definition definitions)
        (setf (gethash (first definition) names) t))
      (dolist (definition definitions)
        (validate-expression (second definition) names))
      (loop with changed = t while changed do
        (setf changed nil)
        (dolist (definition definitions)
          (when (and (not (gethash (first definition) nullable))
                     (nullable-p (second definition) nullable))
            (setf (gethash (first definition) nullable) t
                  changed t))))
      (validate-progress definitions nullable)
      (let ((grammar (make-parser :states (make-array 0 :adjustable t :fill-pointer 0)
                                   :starts (make-hash-table :test 'eq)
                                   :stops (make-hash-table :test 'eq)
                                   :default-rule default-rule :lexer lexer
                                   :metadata metadata
                                   :tree-builder tree-builder
                                   :rewrites rewrites
                                   :cache-backend cache-backend
                                   :full-context-strategy full-context-strategy
                                   :decisions (make-cache cache-backend))))
        (build-java-atn grammar definitions left-rules)
        (when (some (lambda (definition)
                      (semantic-expression-p (second definition))) definitions)
          (setf (parser-semantic-rules grammar) (make-hash-table :test 'eq))
          (dolist (definition definitions)
            (setf (gethash (first definition) (parser-semantic-rules grammar))
                  (second definition))))
        (setf (parser-has-negated-tokens grammar)
              (loop for state across (parser-states grammar)
                    thereis (find :not-token (state-edges state)
                                  :key #'transition-kind)))
        (initialize-token-index grammar)
        ;; Java performs SLL(1) decision analysis before choosing generated
        ;; switches/loop tests versus adaptive prediction.
        (initialize-direct-lookahead grammar)
        (when (and compile-runners (not (parser-semantic-rules grammar)))
          (setf (parser-runner grammar) (compile-parser-runner grammar nil)
                (parser-node-runner grammar) (compile-parser-runner grammar t)))
        grammar))))

(defun resolve-full-context-strategy (strategy)
  ;; Kept at the grammar-option boundary for explicit migration errors.
  (unless (eq strategy :recompute)
    (grammar-fail "The Java predictor uses :RECOMPUTE full context; caller-specific caches and custom start hooks are unsupported (got ~S)" strategy))
  nil)

;; Keep the original token vector. A filtered input uses physical vector
;; positions and skips tokens on excluded channels as its cursor advances.
(defstruct (filtered-token-input
            (:constructor %make-filtered-token-input (tokens channels)))
  (tokens #() :type simple-vector)
  (channels nil :type list))

;; Callback accessors cache their last logical lookup without enlarging the
;; filtered input used by ordinary parsers.
(defstruct (semantic-token-input
            (:include filtered-token-input)
            (:constructor %make-semantic-token-input (tokens channels)))
  (last-logical 0 :type fixnum)
  last-physical
  visible-count)

(declaim (inline input-size input-token input-next-position compiled-choice-index))
(defun input-size (input)
  (declare (optimize (speed 3) (safety 1) (debug 0))
           (type (or simple-vector filtered-token-input) input))
  (if (filtered-token-input-p input)
      (length (filtered-token-input-tokens input))
      (length input)))

(defun input-token (input position)
  (declare (type fixnum position))
  (declare (optimize (speed 3) (safety 1) (debug 0))
           (type (or simple-vector filtered-token-input) input))
  (aref (if (filtered-token-input-p input)
            (filtered-token-input-tokens input)
            input)
        position))

(defun input-next-position (input position)
  (declare (type fixnum position))
  (declare (optimize (speed 3) (safety 1) (debug 0))
           (type (or simple-vector filtered-token-input) input))
  (let ((next (1+ position)))
    (declare (type fixnum next))
    (when (filtered-token-input-p input)
      (let ((tokens (filtered-token-input-tokens input))
            (channels (filtered-token-input-channels input)))
        (loop while (and (< next (length tokens))
                         (not (member (token-channel (aref tokens next))
                                      channels :test #'equal)))
              do (incf next))))
    next))

(defun input-start-position (input)
  (if (filtered-token-input-p input)
      (input-next-position input -1)
      0))

(defun input-remaining-count (input position)
  (loop for index = position then (input-next-position input index)
        while (< index (input-size input))
        count t))

(defun input-remaining-values (input position)
  (loop for index = position then (input-next-position input index)
        while (< index (input-size input))
        collect (input-token input index)))

(defun make-token-input (tokens channels &optional semantic-p)
  (if (eq channels :all)
      tokens
      (if semantic-p
          (%make-semantic-token-input tokens channels)
          (%make-filtered-token-input tokens channels))))

(defun input-token-count (input)
  "Return the number of visible tokens in parser INPUT."
  (cond ((semantic-token-input-p input)
         (or (semantic-token-input-visible-count input)
             (setf (semantic-token-input-visible-count input)
                   (input-remaining-count input (input-start-position input)))))
        ((filtered-token-input-p input)
         (input-remaining-count input (input-start-position input)))
        (t (length input))))

(defun input-token-at (input index)
  "Return the visible token at zero-based INDEX in parser INPUT."
  (unless (and (integerp index) (<= 0 index))
    (error 'type-error :datum index :expected-type '(integer 0 *)))
  (if (filtered-token-input-p input)
      (let* ((cached (and (semantic-token-input-p input)
                          (semantic-token-input-last-physical input)))
             (forward (and cached (>= index
                                      (semantic-token-input-last-logical input))))
             (position (if forward cached (input-start-position input)))
             (logical (if forward
                          (semantic-token-input-last-logical input) 0)))
        (loop while (< logical index) do
          (setf position (input-next-position input position))
          (incf logical))
        (when (>= position (input-size input))
          (error "Visible token index ~D is out of bounds" index))
        (when (semantic-token-input-p input)
          (setf (semantic-token-input-last-logical input) logical
                (semantic-token-input-last-physical input) position))
        (input-token input position))
      (aref input index)))


(defun direct-choice-index (grammar table input position)
  (declare (optimize (speed 3) (safety 1) (debug 0) (compilation-speed 1)))
  (let* ((key (if (>= position (input-size input)) +end-of-input+
                  (token-key (input-token input position))))
         (index (funcall (the function (parser-token-index grammar)) key)))
    (aref table (or index (length (parser-token-keys grammar))))))

(defun predict (grammar state-id stack tokens position)
  (declare (optimize (speed 3) (safety 1) (debug 0) (compilation-speed 1)))
  (let* ((state (aref (parser-states grammar) state-id))
         (direct (state-direct-lookahead state)))
    (if direct (direct-choice-index grammar direct tokens position)
        (or (runtime-adaptive-predict grammar state-id stack tokens position)
            ;; Native PARSE permits any rule as an entry point with implicit EOF.
            ;; A recursive-only rule has no EOF follow in Java's serialized ATN;
            ;; finish its precedence loop at that entry boundary.
            (and (>= position (input-size tokens))
                 (state-precedence-decision-p state)
                 (state-exit-alternative state))))))

(defun direct-choice-form (grammar table state-id)
  "Emit Java-style one-token switches/tests in independently compiled rules."
  (let* ((keys (parser-token-keys grammar)) (groups nil)
         (other (aref table (length keys))) (eof nil))
    (loop for key across keys for alternative across table do
      (if (eq key +end-of-input+) (setf eof alternative)
          (unless (eql alternative other)
            (let ((group (assoc alternative groups)))
              (if group (push key (cdr group)) (push (list alternative key) groups))))))
    ;; A single CASE clause with hundreds of token keys expands into a large
    ;; disjunction in SBCL. Its type-constraint propagation can consume GBs,
    ;; even for a rule with very few states. Reuse the grammar's token index
    ;; and lookahead table rather than duplicating those tests at every state.
    (when (> (loop for group in groups sum (length (cdr group))) 64)
      (return-from direct-choice-form
        `(direct-choice-index grammar
                              (state-direct-lookahead
                               (aref (parser-states grammar) ,state-id))
                              input position)))
    `(if (>= position (length tokens)) ,eof
         ,(if (every #'symbolp keys)
              `(case (token-key (aref tokens position))
                 ,@(loop for (alternative . tokens) in (nreverse groups)
                         collect `(,tokens ,alternative))
                 (otherwise ,other))
              `(let ((key (token-key (aref tokens position))))
                 (cond ,@(loop for (alternative . tokens) in (nreverse groups)
                               collect `((member key ',tokens :test #'equal) ,alternative))
                       (t ,other)))))))

(defun initialize-token-index (grammar)
  (let ((keys nil))
    (loop for state across (parser-states grammar) do
      (dolist (edge (state-edges state))
        (case (transition-kind edge)
          (:token (pushnew (transition-value edge) keys :test #'equal))
          ((:token-set :not-token)
           (dolist (token (transition-value edge)) (pushnew token keys :test #'equal))))))
    (pushnew +end-of-input+ keys :test #'equal)
    (setf keys (nreverse keys))
    (setf (parser-token-keys grammar) (coerce keys 'simple-vector)
          (parser-token-index grammar)
          (compile nil
                   (if (every #'symbolp keys)
                       `(lambda (key)
                          (case key
                            ,@(loop for token in keys for index from 0
                                    collect `((,token) ,index))))
                       `(lambda (key)
                          (cond
                            ,@(loop for token in keys for index from 0
                                    collect `((equal key ',token) ,index)))))))))

(defun compiled-rule-states (grammar start)
  (let ((seen (make-hash-table :test 'eql))
        (pending (list start))
        (result nil))
    (loop while pending for id = (pop pending) do
      (unless (gethash id seen)
        (setf (gethash id seen) t)
        (push id result)
        (let ((state (aref (parser-states grammar) id)))
          (unless (state-stop-rule state)
            (dolist (edge (state-edges state))
              (push (transition-target edge) pending))))))
    (nreverse result)))

(defun token-set-member-p (key tokens)
  ;; Keep large constant sets out of the caller's optimizer component.
  (member key tokens :test #'equal))

(defun make-chunked-rule-runner (chunks first-state)
  "Join independently compiled state chunks without sharing mutable closures."
  (declare (optimize (speed 3) (safety 1) (debug 0))
           (type simple-vector chunks) (type fixnum first-state))
  (lambda (grammar run runners stack)
    (let ((state-id first-state)
          (start-position (parser-run-state-logical-position run))
          (children nil) (label nil) (labels nil))
      (declare (type fixnum state-id))
      (loop
        (multiple-value-bind (result next-state next-children next-label next-labels)
            (funcall (the function (svref chunks (ash state-id -6)))
                     grammar run runners stack state-id start-position children label labels)
          ;; A normal rule return (including failure) has no continuation state.
          (unless next-state (return result))
          (setf state-id next-state children next-children
                label next-label labels next-labels))))))

(defun compile-rule-runner-form (form)
  (if (eq (first form) 'make-chunked-rule-runner)
      (make-chunked-rule-runner
       (map 'vector (lambda (chunk) (and chunk (compile nil chunk)))
            (rest (second form)))
       (third form))
      (compile nil form)))

(defun load-rule-runners (descriptors)
  ;; Resolve names in a loop at load time. A VECTOR form with hundreds of
  ;; distinct FUNCTION arguments itself overwhelms SBCL's type propagation.
  (map 'vector
       (lambda (descriptor)
         (if (symbolp descriptor)
             (fdefinition descriptor)
             (make-chunked-rule-runner
              (map 'vector (lambda (name) (and name (fdefinition name)))
                   (rest descriptor))
              (first descriptor))))
       descriptors))

(defun release-rule-compiler-constants ()
  ;; SBCL 2.4 ARM64 retains constant caches across file components. Some
  ;; cached leaves retain REFS into finished IR, keeping entire components
  ;; alive. Releasing this optional coalescing cache between generated helpers
  ;; bounds that retention. Preserve the NIL leaf: ARM64 needs it
  ;; for a wired TN. Do not interfere with explicitly requested block compile.
  #+(and sbcl arm64)
  (let ((namespace (find-symbol "*IR1-NAMESPACE*" :sb-c))
        (constants (find-symbol "SIMILAR-CONSTANTS" :sb-c))
        (eql-constants (find-symbol "EQL-CONSTANTS" :sb-c))
        (refs (find-symbol "LEAF-REFS" :sb-c))
        (block-mode (find-symbol "*BLOCK-COMPILE-ARGUMENT*" :sb-c)))
    (when (and namespace (boundp namespace) (symbol-value namespace)
               constants (fboundp constants) eql-constants (fboundp eql-constants)
               refs (fboundp (list 'setf refs))
               (or (null block-mode) (not (boundp block-mode))
                   (null (symbol-value block-mode))))
      (let* ((table (funcall eql-constants (symbol-value namespace)))
             (nil-leaf (gethash nil table)))
        (clrhash table)
        (when nil-leaf
          (funcall (fdefinition (list 'setf refs)) nil nil-leaf)
          (setf (gethash nil table) nil-leaf)))
      (clrhash (funcall constants (symbol-value namespace)))))
  (values))

(defmacro finish-rule-compilation (&environment environment)
  (declare (ignorable environment))
  ;; Run in the file compiler's namespace. EVAL-WHEN may compile its body in
  ;; a fresh namespace, which would leave the file-wide cache untouched.
  #+(and sbcl arm64)
  (let ((lambda-accessor (find-symbol "LEXENV-LAMBDA" :sb-c)))
    (when (and *compile-file-pathname* environment lambda-accessor (fboundp lambda-accessor)
               (null (funcall lambda-accessor environment)))
      (release-rule-compiler-constants)))
  nil)

(defun parser-rule-runner-forms (grammar build-tree-p)
  "Return rule lambda/constructor forms and their dispatch names."
  (let ((rules nil)
        (rule-indices (make-hash-table :test 'eq))
        (forms (make-array (hash-table-count (parser-starts grammar)))))
    (maphash (lambda (name start)
               (setf (gethash name rule-indices) (hash-table-count rule-indices))
               (push (list name start
                           (make-symbol (format nil "PARSE-~A" name)))
                     rules))
             (parser-starts grammar))
    (labels ((membership-form (tokens)
               `(,(if (> (length tokens) 64) 'token-set-member-p 'member)
                 (token-key (aref tokens position)) ',tokens
                 ,@(unless (> (length tokens) 64) '(:test #'equal))))
             (rule-call (edge)
               `(let ((*prediction-precedence* (state-call-precedence
                                          (aref (parser-states grammar) state-id))))
                  (funcall (the function
                                (svref runners ,(gethash (transition-value edge) rule-indices)))
                           grammar run runners
                           (cons ,(transition-target edge) stack))))
             (edge-form (edge function-name)
               (let ((target (transition-target edge)))
                 (case (transition-kind edge)
                   (:epsilon `(setf state-id ,target))
                   (:action `(setf state-id ,target))
                   (:precedence `(if (>= ,(transition-value edge) *prediction-precedence*)
                                     (setf state-id ,target)
                                     (return-from ,function-name nil)))
                   (:wildcard
                    `(if (< position (length tokens))
                         (progn
                           ,@(when build-tree-p
                               `((push (aref tokens position) children) (incf logical-position)))
                           (setf state-id ,target position (input-next-position input position)))
                         (return-from ,function-name nil)))
                   (:token-set
                    `(cond
                       ,@(when (member +end-of-input+ (transition-value edge))
                           `(((= position (length tokens)) (setf state-id ,target))))
                       ((and (< position (length tokens))
                             ,(membership-form (remove +end-of-input+ (transition-value edge))))
                        ,@(when build-tree-p
                            `((push (aref tokens position) children) (incf logical-position)))
                        (setf state-id ,target position (input-next-position input position)))
                       (t (return-from ,function-name nil))))
                   (:token
                    `(if ,(if (eq (transition-value edge) +end-of-input+)
                               '(= position (length tokens))
                               `(and (< position (length tokens))
                                     (equal (token-key (aref tokens position))
                                            ',(transition-value edge))))
                         (progn
                           ,@(when (and build-tree-p (not (eq (transition-value edge) +end-of-input+)))
                               `((push (aref tokens position) children)
                                 (incf logical-position)))
                           (setf state-id ,target)
                           ,@(unless (eq (transition-value edge) +end-of-input+)
                               '((setf position (input-next-position input position)))))
                         (return-from ,function-name nil)))
                   (:not-token
                    `(if (and (< position (length tokens))
                              (not ,(membership-form (transition-value edge))))
                         (progn
                           ,@(when build-tree-p
                               `((push (aref tokens position) children)
                                 (incf logical-position)))
                           (setf state-id ,target
                                 position (input-next-position input position)))
                         (return-from ,function-name nil)))
                   (:call
                    (if build-tree-p
                        `(let ((child
                                 ,(rule-call edge)))
                           (unless child (return-from ,function-name nil))
                           (push child children)
                           (setf state-id ,target))
                        `(progn
                           (unless ,(rule-call edge)
                             (return-from ,function-name nil))
                           (setf state-id ,target)))))))
             (choice-form (id state)
               (if (state-direct-lookahead state)
                   (direct-choice-form grammar (state-direct-lookahead state) id)
                   `(predict grammar ,id stack input position)))
             (state-form (id function-name)
               (let* ((state (aref (parser-states grammar) id))
                      (edges (state-edges state)))
                 `(,id
                   ,(cond ((state-stop-rule state)
                           `(return-from ,function-name
                              ,(if build-tree-p
                                   `(make-labeled-parse-node :node ',(state-stop-rule state)
                                               (nreverse children) start-position logical-position label)
                                   t)))
                          ((null (rest edges))
                          (edge-form (first edges) function-name))
                          (t
                           `(case ,(choice-form id state)
                              ,@(loop for edge in edges for index from 0
                                      collect `(,index
                                                ,(edge-form edge function-name)))
                              (otherwise (return-from ,function-name nil)))))))))
      (loop for (name first-state function-name) in rules
            for states = (compiled-rule-states grammar first-state) do
        ;; Large state machines also need separate compiler components. Rule
        ;; calls still go through RUNNERS; chunks exchange cursor/tree state
        ;; through arguments and multiple values, never mutually local LABELS.
        (when (> (length states) 128)
          (let ((chunks (make-array (1+ (ash (reduce #'max states) -6))
                                    :initial-element nil)))
            (dolist (id states) (push id (svref chunks (ash id -6))))
            (setf (svref forms (gethash name rule-indices))
                  `(make-chunked-rule-runner
                    (vector
                     ,@(loop for ids across chunks for chunk from 0 collect
                         (when ids
                           `(lambda (grammar run runners stack state-id
                                     start-position children label labels)
                              (declare (optimize (speed 3) (safety 1) (debug 0)
                                                 (space 0) (compilation-speed 0))
                                       (type parser grammar) (type parser-run-state run)
                                       (type simple-vector runners) (type fixnum state-id)
                                       (ignorable grammar run runners stack start-position
                                                  children label labels))
                              (symbol-macrolet ((input (parser-run-state-input run))
                                                (tokens (parser-run-state-tokens run))
                                                (position (parser-run-state-position run))
                                                (logical-position (parser-run-state-logical-position run)))
                                (block ,function-name
                                  (loop
                                    (unless (= (ash state-id -6) ,chunk)
                                      (return (values nil state-id children label labels)))
                                    ,@(when build-tree-p
                                        `((multiple-value-setq (children label labels)
                                            (apply-atn-events
                                             (state-events (aref (parser-states grammar) state-id))
                                             :node ',name children start-position logical-position label labels))))
                                    (ecase state-id
                                      ,@(loop for id in (reverse ids)
                                              collect (state-form id function-name))))))))))
                    ,first-state))))
        (unless (> (length states) 128)
        (setf (svref forms (gethash name rule-indices))
              `(lambda (grammar run runners stack)
                  #+sbcl (declare (optimize (speed 3) (safety 1) (debug 0)
                                             (space 0) (compilation-speed 0)))
                  (declare (type parser grammar)
                           (type parser-run-state run)
                           (type simple-vector runners)
                           (ignorable grammar run runners stack))
                  (symbol-macrolet ((input (parser-run-state-input run))
                                    (tokens (parser-run-state-tokens run))
                                    (position (parser-run-state-position run))
                                    (logical-position
                                      (parser-run-state-logical-position run)))
                    (block ,function-name
                      (let ((state-id ,first-state)
                            ,@(when build-tree-p
                                '((start-position logical-position)
                                  (children nil) (label nil) (labels nil))))
                        (declare (type fixnum state-id))
                        (loop
                          ,@(when build-tree-p
                              `((multiple-value-setq (children label labels)
                                  (apply-atn-events
                                   (state-events (aref (parser-states grammar) state-id))
                                   :node ',name children start-position logical-position label labels))))
                          (ecase state-id
                            ,@(loop for id in states
                                    collect (state-form id function-name)))))))))))
      (values (coerce forms 'list) (mapcar #'first (reverse rules))))))

(defun make-parser-runner (runners names)
  (declare (optimize (speed 3) (safety 1) (debug 0) (compilation-speed 1)))
  ;; The table is immutable after compilation. Mutable cursor state belongs
  ;; to each invocation, so runners can be shared by clones and threads.
  (let ((rule-indices (make-hash-table :test 'eq)))
    (loop for name in names for index from 0 do
      (setf (gethash name rule-indices) index))
    (lambda (grammar input start require-eof)
      (let* ((tokens (if (filtered-token-input-p input)
                         (filtered-token-input-tokens input) input))
             (run (make-parser-run-state :input input :tokens tokens
                                         :position (input-start-position input)))
             (result (funcall (the function
                                  (svref runners (gethash start rule-indices)))
                              grammar run runners nil)))
        (and result
             (or (not require-eof)
                 (= (parser-run-state-position run) (length tokens)))
             result)))))

(defun parser-runner-form (grammar build-tree-p)
  "Return a runner constructor and separate top-level function definitions.
COMPILE-FILE must process the definitions at top level: embedding all lambdas
in the constructor retains a whole grammar's compiler IR in one component."
  (multiple-value-bind (forms names) (parser-rule-runner-forms grammar build-tree-p)
    (let ((definitions nil))
      (labels ((function-form (form)
                 (let ((name (gensym "PARSE-RULE-")))
                   (push (copy-tree `(defun ,name ,@(rest form))) definitions)
                   #+(and sbcl arm64)
                   (push '(finish-rule-compilation) definitions)
                   name))
               (rule-form (form)
                 (if (eq (first form) 'make-chunked-rule-runner)
                     (cons (third form)
                           (mapcar (lambda (chunk) (when chunk (function-form chunk)))
                                   (rest (second form))))
                     (function-form form))))
        (let ((constructor `(make-parser-runner
                             (load-rule-runners ',(mapcar #'rule-form forms)) ',names)))
          (values constructor (nreverse definitions)))))))

(defun compile-parser-runner (grammar build-tree-p)
  (multiple-value-bind (forms names) (parser-rule-runner-forms grammar build-tree-p)
    (make-parser-runner (map 'vector #'compile-rule-runner-form forms)
                       names)))

(defun possible-tokens (grammar state stack)
  "Use the shared ATN analyzer for recovery's expected-token set."
  (destructuring-bind (sim types decisions) (ensure-parser-runtime grammar)
    (declare (ignore decisions))
    (let ((look (cnvrs/runtime:state-lookahead
                 (cnvrs/runtime:simulator-atn sim) state
                 :context stack :see-through-predicates t)))
      (loop for key across (parser-token-keys grammar)
            when (member (gethash key types) look) collect key))))

(defun parse (grammar tokens &key rule start (require-eof t) recover
                              (tree-builder nil tree-builder-supplied-p)
                              (lexer nil lexer-supplied-p)
                              (channels '(:default)))
  "Parse TOKENS, returning a tree and a list of RECOVERY records.
RULE selects any parser rule; START is a compatibility alias. By default,
the selected rule must consume all input, even without explicit EOF in its
definition. Set REQUIRE-EOF to NIL to allow a prefix parse. LEXER maps the source to a
token sequence before parsing. CHANNELS selects which lexeme channels to
parse; :ALL selects every channel. TREE-BUILDER overrides the compiled
grammar's node construction strategy for this call. With RECOVER true, single-token deletion,
insertion, and choice resynchronization are attempted. Handlers may invoke
the restarts at each error site to make a different local repair."
  (declare (optimize (speed 3) (safety 1) (debug 0) (compilation-speed 1)))
  (when (parser-definition-p grammar)
    (when (eq (parser-definition-kind grammar) :lexer)
      (grammar-fail "Use LEX to run a lexer grammar"))
    (setf grammar (ensure-parser-compiled grammar)))
  (when (and rule start (not (eq rule start)))
    (grammar-fail "Conflicting :RULE ~S and :START ~S" rule start))
  (setf start (or rule start (parser-default-rule grammar)))
  (unless tree-builder-supplied-p
    (setf tree-builder (parser-tree-builder grammar)))
  (unless lexer-supplied-p
    (setf lexer (parser-lexer grammar)))
  (unless (gethash start (parser-starts grammar))
    (grammar-fail "Unknown start rule ~S" start))
  (unless (or (eq channels :all) (listp channels))
    (error 'type-error :datum channels :expected-type '(or list (eql :all))))
  (let* ((*prediction-input-cache* (make-hash-table :test 'eq))
         (build-tree-p (parse-build-tree-p tree-builder))
         (lexed (coerce (if lexer (lex lexer tokens) tokens)
                        'simple-vector))
         (input (make-token-input lexed channels
                                  (parser-semantic-rules grammar)))
         (position 0)
         (physical-position (input-start-position input))
         (state-id (gethash start (parser-starts grammar)))
         (stack nil)
         (frames (list (vector start 0 nil 0 nil nil)))
         (pending nil)
         (forced-set-token nil)
         (event-state nil)
         (recoveries nil)
         (automatic-insert-position -1)
         (automatic-insert-count 0))
    (declare (type fixnum position physical-position state-id
                   automatic-insert-position automatic-insert-count)
             (type simple-vector lexed)
             (type (or simple-vector filtered-token-input) input))
    (when lexer
      (when lexer-supplied-p
        (check-lexer-kind-overlap (parser-starts grammar) lexer))
      (unless (compiled-lexer-p lexer)
        (loop for token across lexed
              for kind = (token-key token)
              when (gethash kind (parser-starts grammar))
                do (grammar-fail
                     "~S is both a parser rule name and a lexer token kind"
                     kind))))
    (when (and recover (parser-semantic-rules grammar))
      (grammar-fail "Recovery is not supported with semantic callbacks"))
    (when (not recover)
      (let ((runner (case tree-builder
                      (:none (parser-runner grammar))
                      (:node (parser-node-runner grammar)))))
        (when runner
          (let ((result (funcall runner grammar input start require-eof)))
            (when result
              (return-from parse
                (values (if (and (eq tree-builder :node)
                                 (plusp (hash-table-count
                                         (parser-rewrites grammar))))
                            (normalize-rewritten-node
                             result (parser-rewrites grammar) tree-builder)
                            (and (eq tree-builder :node) result))
                        nil)))))))
    (unless (eq tree-builder :none)
      (parse-rule-enter tree-builder (visible-rule grammar start) 0))
    (labels ((record (action condition token)
               (push (make-recovery :action action :condition condition
                                    :token token)
                     recoveries))
             (has-token-p ()
               (or pending (< physical-position (input-size input))))
             (current-value ()
               (cond (pending (inserted-token-value (first pending)))
                     ((< physical-position (input-size input))
                      (input-token input physical-position))
                     (t +end-of-input+)))
             (next-value ()
               (cond ((rest pending)
                      (inserted-token-value (second pending)))
                     (pending
                      (if (< physical-position (input-size input))
                          (input-token input physical-position) +end-of-input+))
                     (t (let ((next (input-next-position input physical-position)))
                          (if (< next (input-size input))
                              (input-token input next) +end-of-input+)))))
             (consume-current ()
               (if pending (pop pending)
                   (prog1 (input-token input physical-position)
                     (incf position)
                     (setf physical-position
                           (input-next-position input physical-position)))))
             (available-count ()
               (+ (length pending)
                  (input-remaining-count input physical-position)))
             (delete-current (count condition)
               (unless (and (integerp count) (<= 1 count)
                            (<= count (available-count)))
                 (error "DELETE-TOKENS count ~S exceeds the ~D available tokens"
                        count (available-count)))
               (record :delete-tokens condition
                       (loop repeat count collect (consume-current))))
             (remaining-values ()
               (coerce (append (mapcar #'inserted-token-value pending)
                               (input-remaining-values input physical-position))
                       'vector))
             (predict-current ()
               (if pending
                   (predict grammar state-id stack (remaining-values) 0)
                   (predict grammar state-id stack input physical-position)))
             (inject (values condition &optional (required nil required-p))
               (let ((items (coerce values 'list)))
                 (unless items (error "INSERT-TOKENS requires a nonempty sequence"))
                 (when (and required-p (not (equal (token-key (first items)) required)))
                   (error "First inserted token ~S does not match expected ~S"
                          (first items) required))
                 (when (and (typep condition 'no-viable-alternative)
                            (not (member (token-key (first items))
                                         (parse-error-expected condition)
                                         :test #'equal)))
                   (error "First inserted token ~S cannot start this choice"
                          (first items)))
                 (let ((markers (mapcar (lambda (value)
                                          (make-inserted-token
                                           :expected value :position position))
                                        items)))
                   (setf pending (append markers pending))
                   (record :insert-tokens condition markers))))
             (can-insert-before-current-p (target)
               (and (has-token-p)
                    (member (token-key (current-value))
                            (possible-tokens grammar target stack)
                            :test #'equal))))
      (handler-bind
          ((mismatched-token
             (lambda (condition)
               (when recover
                 (let ((expected (parse-error-expected condition)))
                   (unless (and (consp expected)
                                (eq (first expected) 'not-token))
                     (cond ((and (has-token-p)
                               (equal (token-key (next-value)) expected))
                          (invoke-restart 'delete-tokens))
                         ((or (not (has-token-p))
                              (can-insert-before-current-p
                               (mismatch-next-state condition)))
                          (unless (= position automatic-insert-position)
                            (setf automatic-insert-position position
                                  automatic-insert-count 0))
                          (when (< automatic-insert-count
                                   (length (parser-states grammar)))
                            (incf automatic-insert-count)
                            (invoke-restart 'insert-tokens)))))))))
           (no-viable-alternative
             (lambda (condition)
               (declare (ignore condition))
               (when recover
                 (if (has-token-p)
                     (invoke-restart 'delete-tokens)
                     (invoke-restart 'choose-alternative
                                     (or (state-exit-alternative
                                          (aref (parser-states grammar) state-id))
                                         0))))))
           (unexpected-input
             (lambda (condition)
               (declare (ignore condition))
               (when recover (invoke-restart 'discard-input)))))
        (loop
          (let* ((state (aref (parser-states grammar) state-id))
                 (stop (state-stop-rule state))
                 (*prediction-precedence* (aref (first frames) 3)))
            (when (and build-tree-p (not (eql state-id event-state)))
              (setf event-state state-id)
              (let ((frame (first frames)))
                (multiple-value-bind (children label labels)
                    (apply-atn-events (state-events state) tree-builder (aref frame 0)
                                      (aref frame 2) (aref frame 1) position
                                      (aref frame 4) (aref frame 5))
                  (setf (aref frame 2) children (aref frame 4) label (aref frame 5) labels))))
            (when stop
              (let* ((frame (pop frames))
                     (completed (when build-tree-p
                                  (make-labeled-parse-node tree-builder (aref frame 0)
                                                   (nreverse (aref frame 2))
                                                   (aref frame 1) position (aref frame 4)))))
                (unless (eq tree-builder :none)
                  (parse-rule-exit tree-builder
                                   (visible-rule grammar (aref frame 0))
                                   (aref frame 1) position))
                (if stack
                    (progn
                      (when build-tree-p
                        (push completed (aref (first frames) 2)))
                      (setf state-id (pop stack)))
                    (progn
                      (when (and require-eof (has-token-p))
                        (let ((condition (make-condition
                                          'unexpected-input :position position
                                          :token (current-value)
                                          :expected +end-of-input+
                                          :rule start)))
                          (restart-case (error condition)
                            (discard-input ()
                              :report "Discard all remaining input."
                              (record :discard-input condition
                                      (remaining-values))
                              (setf pending nil
                                    position (+ position
                                                (input-remaining-count
                                                 input physical-position))
                                    physical-position (input-size input))))))
                      (return (values (if (and build-tree-p
                                               (plusp (hash-table-count
                                                       (parser-rewrites grammar))))
                                          (normalize-rewritten-node
                                           completed (parser-rewrites grammar)
                                           tree-builder)
                                          completed)
                                      (nreverse recoveries)))))))
            (unless stop
              (let* ((edges (state-edges state))
                     (index (if (null (rest edges))
                                0 (or (predict-current)
                                      (and recover (not (has-token-p))
                                           (state-exit-alternative state))))))
                (when (null index)
                  (let ((condition
                          (make-condition
                           'no-viable-alternative :position position
                           :token (current-value)
                           :rule (visible-rule grammar (aref (first frames) 0))
                           :expected
                           (possible-tokens grammar state-id stack))))
                    (multiple-value-bind (action value)
                        (restart-case (error condition)
                          (delete-tokens (&optional (count 1))
                            :report "Delete input tokens and retry the choice."
                            :test (lambda (condition)
                                    (declare (ignore condition))
                                    (has-token-p))
                            (values :delete-many count))
                          (insert-tokens (&optional values)
                            :report "Insert a sequence of tokens before this choice."
                            (values :insert-many values))
                          (choose-alternative (alternative)
                            :report "Choose a numbered alternative."
                            (values :choose alternative)))
                      (case action
                        (:delete-many
                         (delete-current value condition))
                        (:insert-many
                         (inject value condition))
                        (:choose
                         (unless (and (integerp value) (<= 0 value)
                                      (< value (length edges)))
                           (error "Invalid alternative ~S" value))
                         (record :choose-alternative condition value)
                         (setf index value))))))
                (when index
                  (let* ((original-edge (nth index edges))
                         (edge (if (and forced-set-token (= state-id (car forced-set-token)))
                                   (make-transition :kind :token :target (transition-target original-edge)
                                                    :value (cdr forced-set-token))
                                   original-edge)))
                    (case (transition-kind edge)
                      (:epsilon (setf state-id (transition-target edge)))
                      (:predicate
                       (unless (semantic-call (transition-value edge) input position)
                         (error 'no-viable-alternative :position position
                                :token (current-value) :expected (list 'predicate (transition-value edge))
                                :rule (visible-rule grammar (aref (first frames) 0))))
                       (setf state-id (transition-target edge)))
                      (:precedence
                       (unless (>= (transition-value edge) *prediction-precedence*)
                         (error 'no-viable-alternative :position position :token (current-value)
                                :expected nil :rule (aref (first frames) 0)))
                       (setf state-id (transition-target edge)))
                      (:action
                       (when (transition-value edge)
                         (semantic-call (transition-value edge) input position))
                       (setf state-id (transition-target edge)))
                      (:call
                       (push (vector (transition-value edge) position nil
                                     (state-call-precedence state) nil nil)
                             frames)
                       (push (transition-target edge) stack)
                       (unless (eq tree-builder :none)
                         (parse-rule-enter
                          tree-builder
                          (visible-rule grammar (transition-value edge)) position))
                       (setf state-id (gethash (transition-value edge)
                                               (parser-starts grammar))))
                      ((:not-token :token-set :wildcard)
                       (if (or (and (eq (transition-kind edge) :token-set)
                                    (not (has-token-p))
                                    (member +end-of-input+ (transition-value edge)))
                               (and (has-token-p)
                                    (case (transition-kind edge)
                                      (:wildcard t)
                                      (:token-set (member (token-key (current-value)) (transition-value edge) :test #'equal))
                                      (t (not (member (token-key (current-value))
                                                      (transition-value edge) :test #'equal))))))
                           (progn
                             (when (has-token-p)
                               (let ((start-position position) (token (consume-current)))
                                 (unless (eq tree-builder :none)
                                   (parse-token-consumed tree-builder token start-position position))
                                 (when build-tree-p (push token (aref (first frames) 2)))))
                             (setf state-id (transition-target edge)))
                           (let* ((set-p (eq (transition-kind edge) :token-set))
                                  (condition
                                    (apply #'make-condition
                                           (if set-p 'no-viable-alternative 'mismatched-token)
                                           :position position :token (current-value)
                                           :expected (if set-p (transition-value edge)
                                                         (list 'not-token (transition-value edge)))
                                           :rule (visible-rule grammar (aref (first frames) 0))
                                           (unless set-p (list :next-state (transition-target edge))))))
                             (multiple-value-bind (action value)
                                 (restart-case (error condition)
                                   (choose-alternative (alternative)
                                     :test (lambda (condition) (declare (ignore condition)) set-p)
                                     (values :choose alternative))
                                   (insert-tokens (&optional values)
                                     :test (lambda (condition) (declare (ignore condition)) set-p)
                                     (values :insert-many values))
                                   (delete-tokens (&optional (count 1))
                                     :report "Delete tokens and retry."
                                     :test (lambda (condition) (declare (ignore condition)) (has-token-p))
                                     (values :delete-many count)))
                               (case action
                                 (:delete-many (delete-current value condition))
                                 (:insert-many (inject value condition))
                                 (:choose
                                  (unless (and (integerp value) (<= 0 value)
                                               (< value (length (transition-value edge))))
                                    (error "Invalid alternative ~S" value))
                                  (record :choose-alternative condition value)
                                  (setf forced-set-token
                                        (cons state-id (nth value (transition-value edge))))))))))
                      (:token
                       (let ((expected (transition-value edge)))
                         (if (or (and (eq expected +end-of-input+) (not (has-token-p)))
                                 (and (has-token-p)
                                      (equal (token-key (current-value)) expected)))
                             (progn
                               (unless (eq expected +end-of-input+)
                                (let ((start-position position)
                                     (token (consume-current)))
                                 (unless (eq tree-builder :none)
                                   (parse-token-consumed tree-builder token
                                                         start-position position))
                                 (when build-tree-p
                                   (push token (aref (first frames) 2)))))
                               (setf forced-set-token nil
                                     state-id (transition-target edge)))
                             (let ((condition
                                     (make-condition
                                      'mismatched-token :position position
                                      :token (current-value)
                                      :expected expected
                                      :rule (visible-rule grammar (aref (first frames) 0))
                                      :next-state (transition-target edge))))
                               (multiple-value-bind (action value)
                                   (restart-case (error condition)
                                     (insert-tokens (&optional values)
                                       :report "Insert tokens; without arguments, insert the expected token."
                                       (values :insert-many
                                               (or values (list expected))))
                                     (delete-tokens (&optional (count 1))
                                       :report "Delete input tokens and retry."
                                       :test (lambda (condition)
                                               (declare (ignore condition))
                                               (has-token-p))
                                       (values :delete-many count)))
                                 (ecase action
                                   (:insert-many
                                    (inject value condition expected))
                                   (:delete-many
                                    (delete-current value condition)))))))))))))))))))
