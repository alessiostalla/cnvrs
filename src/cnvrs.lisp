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
  direct-lookahead)
(defstruct direct-choice table default-alternative)
(defstruct two-token-choice table)
(defstruct configuration (state 0 :type fixnum) (stack nil :type list)
  (alternative 0 :type fixnum))
(defstruct dfa-state configurations alternatives accepted edges)
(defstruct parser states starts stops default-rule lexer (tree-builder :node)
  (rewrites (make-hash-table :test 'eq))
  has-negated-tokens metadata semantic-rules
  (cache-backend :hash-table)
  (full-context-strategy :cached) full-context-start
  decisions sll-decisions direct-decisions contexts
  (context-count 0) context-shift runner node-runner
  compiled-sll compiled-full)
(defstruct parser-definition name kind default-rule lexer cache-backend metadata
  parser-package lexer-package
  (full-context-strategy :cached)
  (tree-builder :node)
  (rules nil) compiled)
(declaim (ftype function ensure-parser-compiled))
(declaim (ftype function resolve-full-context-strategy))
(declaim (ftype function compile-parser-runner))

(defun grammar-fail (control &rest arguments)
  (error 'grammar-error :message (apply #'format nil control arguments)))

(defun plist-key-p (plist key)
  (loop for tail on plist by #'cddr
        thereis (eq (first tail) key)))

(defun grammar-operator-p (symbol)
  (member symbol '(and or * + seq ? *? +? ?? range one-of not-one-of any
                   label alt-label token not-token predicate action right
                   antlr-precedence defrule with-mode)))

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
  ((name :initarg :name :reader parser-expr-name)))
(defclass parser-token-expr (parser-expr)
  ((value :initarg :value :reader parser-expr-value)))
(defclass parser-not-token-expr (parser-expr)
  ((excluded :initarg :excluded :reader parser-expr-excluded)))
(defclass parser-callback-expr (parser-expr)
  ((callback :initarg :callback :reader parser-expr-callback)))
(defclass parser-predicate-expr (parser-callback-expr) ())
(defclass parser-action-expr (parser-callback-expr) ())

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
(defclass parser-optional-expr (parser-unary-expr) ())
(defclass parser-star-expr (parser-unary-expr) ())
(defclass parser-plus-expr (parser-unary-expr) ())

(defun parser-expression-from-form (form)
  "Convert the public grammar form to an expression used during compilation."
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
(defmethod nullable-p ((expression parser-reference-expr) nullable)
  (gethash (parser-expr-name expression) nullable))
(defmethod nullable-p ((expression parser-callback-expr) nullable)
  (declare (ignore nullable)) t)
(defmethod nullable-p ((expression parser-sequence-expr) nullable)
  (every (lambda (part) (nullable-p part nullable))
         (parser-expr-parts expression)))
(defmethod nullable-p ((expression parser-choice-expr) nullable)
  (some (lambda (part) (nullable-p part nullable))
        (parser-expr-parts expression)))
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

(defgeneric compile-expression (grammar expression entry exit))
(defmethod compile-expression (grammar (expression parser-reference-expr) entry exit)
  (add-edge grammar entry :call exit (parser-expr-name expression)))
(defmethod compile-expression (grammar (expression parser-token-expr) entry exit)
  (add-edge grammar entry :token exit (parser-expr-value expression)))
(defmethod compile-expression (grammar (expression parser-not-token-expr) entry exit)
  (add-edge grammar entry :not-token exit (parser-expr-excluded expression)))
(defmethod compile-expression (grammar (expression parser-callback-expr) entry exit)
  ;; Semantic grammars use the ordered matcher; the graph remains inspectable.
  (add-edge grammar entry :epsilon exit))

(defgeneric semantic-expression-p (expression))
(defmethod semantic-expression-p ((expression parser-expr)) nil)
(defmethod semantic-expression-p ((expression parser-callback-expr)) t)
(defmethod semantic-expression-p ((expression parser-sequence-expr))
  (some #'semantic-expression-p (parser-expr-parts expression)))
(defmethod semantic-expression-p ((expression parser-unary-expr))
  (semantic-expression-p (parser-expr-body expression)))
(defmethod compile-expression (grammar (expression parser-sequence-expr) entry exit)
  (let ((parts (parser-expr-parts expression)) (current entry))
    (if (null parts)
        (add-edge grammar entry :epsilon exit)
        (loop for tail on parts
              for next = (if (null (rest tail)) exit (new-state grammar))
              do (compile-expression grammar (first tail) current next)
                 (setf current next)))))
(defmethod compile-expression (grammar (expression parser-choice-expr) entry exit)
  (dolist (part (parser-expr-parts expression))
    (let ((branch (new-state grammar)))
      (add-edge grammar entry :epsilon branch)
      (compile-expression grammar part branch exit))))
(defmethod compile-expression (grammar (expression parser-optional-expr) entry exit)
  (let ((branch (new-state grammar)))
    (setf (state-exit-alternative (aref (parser-states grammar) entry)) 1)
    (add-edge grammar entry :epsilon branch)
    (add-edge grammar entry :epsilon exit)
    (compile-expression grammar (parser-expr-body expression) branch exit)))
(defmethod compile-expression (grammar (expression parser-star-expr) entry exit)
  (let ((branch (new-state grammar)) (body-end (new-state grammar)))
    (setf (state-exit-alternative (aref (parser-states grammar) entry)) 1
          (state-repetition-p (aref (parser-states grammar) entry)) t)
    (add-edge grammar entry :epsilon branch)
    (add-edge grammar entry :epsilon exit)
    (compile-expression grammar (parser-expr-body expression) branch body-end)
    (add-edge grammar body-end :epsilon entry)))
(defmethod compile-expression (grammar (expression parser-plus-expr) entry exit)
  (let ((loop-state (new-state grammar)))
    (compile-expression grammar (parser-expr-body expression) entry loop-state)
    (compile-expression
     grammar (make-instance 'parser-star-expr :source (parser-expr-source expression)
                                         :body (parser-expr-body expression))
     loop-state exit)))

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

(defun antlr-prefix-alternative (rule alternative)
  (let* ((body (if (eq (expression-kind alternative) :alt-label)
                   (third alternative) alternative))
         (parts (and (eq (expression-kind body) :sequence) (rest body)))
         (last-part (car (last parts))))
    (and (rest parts)
         (or (eq last-part rule)
             (and (eq (expression-kind last-part) :label)
                  (eq (third last-part) rule))))))

(defun retarget-antlr-prefix (alternative target)
  (let* ((labeled (eq (expression-kind alternative) :alt-label))
         (body (if labeled (third alternative) alternative))
         (parts (copy-list (rest body)))
         (last-part (car (last parts))))
    (setf (car (last parts))
          (if (eq (expression-kind last-part) :label)
              (list 'label (second last-part) target)
              target))
    (let ((result (cons 'and parts)))
      (if labeled (list 'alt-label (second alternative) result) result))))

(defun rewrite-left-recursion (definitions)
  (let ((rewrites (make-hash-table :test 'eq))
        (output nil))
    (dolist (definition definitions)
      (destructuring-bind (rule expression) definition
        (let* ((bases nil) (recursive nil)
               (antlr-p (and (consp expression)
                             (eq (first expression) 'antlr-precedence)))
               (body (if antlr-p (second expression) expression))
               (alternatives (if (eq (expression-kind body) :choice)
                                 (rest body) (list body))))
          (dolist (alternative alternatives)
            (multiple-value-bind (suffix right alternative-label left-label)
                (direct-left-alternative rule alternative)
              (if suffix
                  (push (list alternative suffix right alternative-label left-label)
                        recursive)
                  (push alternative bases))))
          (if (null recursive)
              (push definition output)
              (progn
                (unless bases
                  (grammar-fail "Left-recursive rule ~S needs a base alternative" rule))
                (setf bases (nreverse bases)
                      recursive (nreverse recursive))
                (let* ((primary (gensym "PRIMARY-"))
                       (higher primary)
                       (primary-definition (list primary nil))
                       (generated (list primary-definition))
                       (prefix-targets (make-hash-table :test 'eq)))
                  (setf (gethash primary rewrites) (list :primary rule))
                  (labels ((add-recursive-level (alternative)
                             (destructuring-bind
                                 (source suffix right alternative-label left-label)
                                 alternative
                               (declare (ignore source))
                               (let* ((level (gensym "LEVEL-"))
                                      (suffix-rule (gensym "SUFFIX-"))
                                      (parts (copy-list suffix)))
                                 (let* ((last-part (car (last parts)))
                                        (target (if right level higher)))
                                   (cond ((eq last-part rule)
                                          (setf (car (last parts)) target))
                                         ((and (eq (expression-kind last-part)
                                                   :label)
                                               (eq (third last-part) rule))
                                          (setf (car (last parts))
                                                (list 'label
                                                      (second last-part)
                                                      target)))))
                                 (push (list suffix-rule
                                             (if (rest parts)
                                                 (cons 'and parts) (first parts)))
                                       generated)
                                 (push (list level
                                             (list 'and higher (list '* suffix-rule)))
                                       generated)
                                 (setf (gethash suffix-rule rewrites)
                                       (list :suffix rule alternative-label left-label)
                                       (gethash level rewrites) (list :level rule)
                                       higher level)))))
                    (if antlr-p
                        (dolist (alternative alternatives)
                          (let ((recursive-entry
                                  (assoc alternative recursive :test #'eq)))
                            (cond (recursive-entry
                                   (add-recursive-level recursive-entry))
                                  ((antlr-prefix-alternative rule alternative)
                                   (setf (gethash alternative prefix-targets)
                                         higher)))))
                        (dolist (alternative (reverse recursive))
                          (add-recursive-level alternative))))
                  (setf (second primary-definition)
                        (let ((primary-alternatives
                                (mapcar (lambda (alternative)
                                          (let ((target
                                                  (gethash alternative
                                                           prefix-targets)))
                                            (if target
                                                (retarget-antlr-prefix
                                                 alternative target)
                                                alternative)))
                                        bases)))
                          (if (rest primary-alternatives)
                              (cons 'or primary-alternatives)
                              (first primary-alternatives))))
                  (setf (gethash rule rewrites) (list :wrapper rule))
                  (push (list rule higher) output)
                  (dolist (item (nreverse generated)) (push item output))))))))
    (values (nreverse output) rewrites)))

(defvar *parser-generated-label-rules* nil)
(defvar *parser-label-rewrites* nil)

(defgeneric expand-parser-labels (expression))
(defmethod expand-parser-labels ((expression parser-expr))
  expression)
(defmethod expand-parser-labels ((expression parser-sequence-expr))
  (make-instance (class-of expression)
                 :source (parser-expr-source expression)
                 :parts (mapcar #'expand-parser-labels
                                (parser-expr-parts expression))))
(defmethod expand-parser-labels ((expression parser-unary-expr))
  (make-instance (class-of expression)
                 :source (parser-expr-source expression)
                 :body (expand-parser-labels (parser-expr-body expression))))
(defmethod expand-parser-labels ((expression parser-label-expr))
  (let ((rule (gensym "LABEL-"))
        (body (expand-parser-labels (parser-expr-body expression))))
    (setf (gethash rule *parser-label-rewrites*)
          (list (if (typep expression 'parser-alt-label-expr)
                    :alternative-label :element-label)
                (parser-expr-label expression)))
    (push (list rule body) *parser-generated-label-rules*)
    (make-instance 'parser-reference-expr :source rule :name rule)))

(defun expand-labels (definitions rewrites)
  (let ((*parser-generated-label-rules* nil)
        (*parser-label-rewrites* rewrites))
    (values (append (mapcar (lambda (definition)
                              (list (first definition)
                                    (expand-parser-labels (second definition))))
                            definitions)
                    (nreverse *parser-generated-label-rules*))
            rewrites)))

(defun visible-rule (grammar rule)
  (or (second (gethash rule (parser-rewrites grammar))) rule))

(defun new-state (grammar &optional stop-rule)
  (graph-new-state (parser-states grammar)
                   (lambda (id) (make-state :id id :stop-rule stop-rule))))

(defun add-edge (grammar from kind target &optional value)
  (graph-add-edge (parser-states grammar) from kind target value :append-p t))

(defun compile-grammar (definitions &key default-rule lexer
                                    (cache-backend :hash-table)
                                    (full-context-strategy :cached)
                                    (tree-builder :node) metadata)
  "Compile Lisp-form rule definitions into an in-memory parser.
DEFINITIONS is a list of (name expression) pairs. Expressions use
(AND ...), (OR ...), (* x), (+ x), (? x), (TOKEN value),
(LABEL name x), and (ALT-LABEL name x).
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
FULL-CONTEXT-STRATEGY selects :CACHED (the default), :RECOMPUTE, or a
function of (parser state-id return-stack) that returns a start DFA state."
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
    (multiple-value-setq (definitions rewrites)
      (rewrite-left-recursion definitions))
    (setf definitions
          (mapcar (lambda (definition)
                    (list (first definition)
                          (parser-expression-from-form (second definition))))
                  definitions))
    (multiple-value-setq (definitions rewrites)
      (expand-labels definitions rewrites))
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
                                 :full-context-start
                                 (resolve-full-context-strategy
                                  full-context-strategy)
                                 :decisions (make-cache cache-backend)
                                 :sll-decisions (make-cache cache-backend)
                                 :direct-decisions (make-cache cache-backend)
                                 :contexts (make-cache cache-backend))))
      (dolist (definition definitions)
        (setf (gethash (first definition) (parser-starts grammar)) (new-state grammar)
              (gethash (first definition) (parser-stops grammar))
              (new-state grammar (first definition))))
      (dolist (definition definitions)
        (compile-expression grammar (second definition)
                            (gethash (first definition) (parser-starts grammar))
                            (gethash (first definition) (parser-stops grammar))))
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
      (setf (parser-context-shift grammar)
            (integer-length (1- (length (parser-states grammar)))))
      (unless (or (parser-has-negated-tokens grammar)
                  (parser-semantic-rules grammar))
        (initialize-direct-lookahead grammar)
        (initialize-follow-lookahead grammar))
      (unless (parser-semantic-rules grammar)
        (setf (parser-runner grammar) (compile-parser-runner grammar nil)
              (parser-node-runner grammar) (compile-parser-runner grammar t)))
      grammar)))

(defun configuration-key (configuration)
  (declare (type configuration configuration))
  (list (configuration-state configuration)
        (configuration-stack configuration)
        (configuration-alternative configuration)))

(defun closure (grammar initial)
  (declare (type parser grammar) (type list initial))
  (nreverse
   (graph-closure
    initial #'configuration-key
    (lambda (configuration pending result)
      (let* ((state (aref (parser-states grammar)
                          (configuration-state configuration)))
             (stack (configuration-stack configuration))
             (alternative (configuration-alternative configuration)))
        (if (state-stop-rule state)
            (if stack
                (push (make-configuration :state (first stack)
                                          :stack (rest stack)
                                          :alternative alternative)
                      pending)
                (push configuration result))
            (let ((has-token nil))
              (dolist (edge (state-edges state))
                (case (transition-kind edge)
                  (:epsilon
                   (push (make-configuration :state (transition-target edge)
                                             :stack stack :alternative alternative)
                         pending))
                  (:call
                   (push (make-configuration
                          :state (gethash (transition-value edge)
                                          (parser-starts grammar))
                          :stack (cons (transition-target edge) stack)
                          :alternative alternative)
                         pending))
                  ((:token :not-token) (setf has-token t))))
              (when has-token (push configuration result))))
        (values pending result))))))

(defun dfa-state-for (grammar configurations)
  (declare (type parser grammar) (type list configurations))
  (let* ((closed (closure grammar configurations))
         (alternatives (sort (remove-duplicates
                              (mapcar #'configuration-alternative closed)) #'<))
         (accepted (sort (remove-duplicates
                          (loop for configuration in closed
                                for state = (aref (parser-states grammar)
                                                  (configuration-state configuration))
                                when (and (state-stop-rule state)
                                          (null (configuration-stack configuration)))
                                  collect (configuration-alternative configuration))) #'<)))
    (make-dfa-state :configurations closed
                    :alternatives alternatives :accepted accepted
                    :edges (make-cache (parser-cache-backend grammar)))))

(defun advance-dfa (grammar dfa token)
  (declare (type parser grammar) (type dfa-state dfa))
  (cache-get-or-compute
   (dfa-state-edges dfa) (token-key token)
   (lambda ()
     (dfa-state-for grammar
                    (loop for configuration in (dfa-state-configurations dfa)
                          for state = (aref (parser-states grammar)
                                            (configuration-state configuration))
                          nconc (loop for edge in (state-edges state)
                                       when (case (transition-kind edge)
                                              (:token
                                               (equal (token-key token)
                                                      (transition-value edge)))
                                              (:not-token
                                               (not (member (token-key token)
                                                            (transition-value edge)
                                                            :test #'equal))))
                                         collect (make-configuration
                                                  :state (transition-target edge)
                                                  :stack (configuration-stack configuration)
                                                  :alternative
                                                  (configuration-alternative configuration))))))))

(defun make-full-context-start (grammar state-id stack)
  "Build the initial full-context DFA state for a decision and return stack."
  (declare (type parser grammar) (type fixnum state-id) (type list stack))
  (dfa-state-for grammar
                 (loop for edge in (state-edges
                                    (aref (parser-states grammar) state-id))
                       for alternative from 0
                       collect (configuration-after-edge
                                grammar edge stack alternative))))

(defun cached-full-context-start (grammar state-id stack)
  (declare (type parser grammar) (type fixnum state-id) (type list stack))
  (cache-get-or-compute
   (parser-decisions grammar) (parser-context-key state-id stack)
   (lambda () (make-full-context-start grammar state-id stack))))

(defun resolve-full-context-strategy (strategy)
  (case strategy
    (:cached #'cached-full-context-start)
    (:recompute #'make-full-context-start)
    (otherwise
     (if (functionp strategy) strategy
         (grammar-fail
          "Full-context strategy must be :CACHED, :RECOMPUTE, or a function, got ~S"
          strategy)))))

(defun predict-full-context (grammar state-id stack tokens position)
  (declare (type parser grammar) (type fixnum state-id position)
           (type list stack) (type simple-vector tokens))
  (let* ((dfa (funcall (parser-full-context-start grammar)
                       grammar state-id stack))
         (length (length tokens)))
    (declare (type fixnum length))
    (when (parser-compiled-full grammar)
      (let ((program (gethash dfa (parser-compiled-full grammar))))
        (when program
          (multiple-value-bind (alternative found)
              (funcall program tokens position)
            (when found (return-from predict-full-context alternative))))))
    (loop
      (let ((alternatives (dfa-state-alternatives dfa)))
        (when (= (length alternatives) 1)
          (return (first alternatives)))
        (when (or (null alternatives) (= position length))
          (return (or (first (dfa-state-accepted dfa))
                      (let ((exit (state-exit-alternative
                                   (aref (parser-states grammar) state-id))))
                        (and (= position length)
                             (member exit alternatives)
                             exit))
                      (first alternatives)))))
      (setf dfa (advance-dfa grammar dfa (aref tokens position)))
      (incf position))))

(defun predict (grammar state-id stack tokens position)
  ;; The first DFA omits the caller's return stack. If an alternative can
  ;; finish in that shortened context while another remains viable, the
  ;; result depends on the caller and prediction retries with the full stack.
  (declare (type parser grammar) (type fixnum state-id position)
           (type list stack) (type simple-vector tokens))
  (let* ((start-position position)
         (cache (parser-sll-decisions grammar))
         (dfa (cache-get-or-compute
               cache state-id
               (lambda ()
                 (dfa-state-for grammar
                                (loop for edge in (state-edges
                                                   (aref (parser-states grammar) state-id))
                                      for alternative from 0
                                      collect (configuration-after-edge
                                               grammar edge nil alternative))))))
         (length (length tokens)))
    (declare (type fixnum start-position length))
    (when (parser-compiled-sll grammar)
      (let ((program (gethash dfa (parser-compiled-sll grammar))))
        (when program
          (multiple-value-bind (alternative found)
              (funcall program tokens position)
            (when found (return-from predict alternative))))))
    (loop
      (let ((alternatives (dfa-state-alternatives dfa)))
        (when (= (length alternatives) 1)
          (return (first alternatives)))
        (when (or (null alternatives)
                  (dfa-state-accepted dfa)
                  (= position length))
          (return (predict-full-context grammar state-id stack tokens
                                        start-position))))
      (setf dfa (advance-dfa grammar dfa (aref tokens position)))
      (incf position))))

(defun configuration-after-edge (grammar edge stack alternative)
  (case (transition-kind edge)
    (:call (make-configuration :state (gethash (transition-value edge)
                                               (parser-starts grammar))
                               :stack (cons (transition-target edge) stack)
                               :alternative alternative))
    (otherwise (make-configuration :state (transition-target edge)
                                   :stack stack :alternative alternative))))

(defun direct-lookahead-table (grammar state stack)
  "Return a table for a disjoint one-token decision, or why it is unsafe."
  (let ((table (make-hash-table :test 'eq))
        (nullable nil)
        (overlap nil)
        (unresolved-nullability nil)
        (nullable-alternatives nil))
    (loop for edge in (state-edges state) for alternative from 0 do
      (let ((found-token nil)
            (can-stop nil))
        (dolist (configuration
                 (closure grammar
                          (list (configuration-after-edge
                                 grammar edge stack alternative))))
          (let ((next (aref (parser-states grammar)
                            (configuration-state configuration))))
            (if (state-stop-rule next)
                (setf nullable t can-stop t)
                (dolist (transition (state-edges next))
                  (when (eq (transition-kind transition) :token)
                    (setf found-token t)
                    (let ((key (transition-value transition)))
                      (when (and (not (symbolp key))
                                 (eq (hash-table-test table) 'eq))
                        (let ((general (make-hash-table :test 'equal)))
                          (maphash (lambda (token alternative)
                                     (setf (gethash token general) alternative))
                                   table)
                          (setf table general)))
                      (let ((prior (gethash key table)))
                        (when (and prior (/= prior (1+ alternative)))
                          (setf overlap t))
                        (setf (gethash key table) (1+ alternative)))))))))
        (unless found-token
          (setf nullable t)
          (unless can-stop (setf unresolved-nullability t)))
        (when can-stop (push alternative nullable-alternatives))))
    (values (unless (or nullable overlap) table)
            nullable overlap
            (when (and nullable (not overlap) (not unresolved-nullability)
                       (null (rest nullable-alternatives)))
              (first nullable-alternatives))
            table)))

(defun initialize-direct-lookahead (grammar)
  "Record one-token choices independent of the caller, and contextual candidates."
  (loop for state across (parser-states grammar)
        when (> (length (state-edges state)) 1) do
          (multiple-value-bind (table nullable overlap)
              (direct-lookahead-table grammar state nil)
            (setf (state-direct-lookahead state)
                  (or table
                      (and nullable (not overlap) :contextual)
                      (and overlap :contextual-two))))))

(defun initialize-follow-lookahead (grammar)
  "Compile nullable decisions whose alternatives have disjoint FIRST/FOLLOW sets.
The sets include every rule's possible caller and end of input, so an
overlapping decision keeps its contextual predictor."
  (let* ((states (parser-states grammar))
         (count (length states))
         (first (make-array count :initial-element nil))
         (nullable (make-array count :initial-element nil))
         (owners (make-array count :initial-element nil))
         (follow (make-hash-table :test 'eq)))
    (maphash (lambda (rule start)
               (dolist (id (compiled-rule-states grammar start))
                 (setf (aref owners id) rule))
               ;; PARSE permits any rule as its entry point.
               (setf (gethash rule follow) (list +end-of-input+)))
             (parser-starts grammar))
    (labels ((edge-first (edge)
               (case (transition-kind edge)
                 (:token (list (transition-value edge)))
                 (:epsilon (aref first (transition-target edge)))
                 (:call
                  (let ((start (gethash (transition-value edge)
                                        (parser-starts grammar))))
                    (if (aref nullable start)
                        (union (aref first start)
                               (aref first (transition-target edge))
                               :test #'equal)
                        (aref first start))))))
             (edge-nullable (edge)
               (case (transition-kind edge)
                 (:token nil)
                 (:epsilon (aref nullable (transition-target edge)))
                 (:call
                  (and (aref nullable
                             (gethash (transition-value edge)
                                      (parser-starts grammar)))
                       (aref nullable (transition-target edge)))))))
      ;; Monotone fixed point over the finite set of states and token keys.
      (loop with changed = t while changed do
        (setf changed nil)
        (loop for state across states for id from 0 do
          (when (state-stop-rule state)
            (unless (aref nullable id)
              (setf (aref nullable id) t changed t)))
          (dolist (edge (state-edges state))
            (let ((new (union (edge-first edge) (aref first id)
                              :test #'equal)))
              (unless (= (length new) (length (aref first id)))
                (setf (aref first id) new changed t)))
            (when (and (edge-nullable edge) (not (aref nullable id)))
              (setf (aref nullable id) t changed t)))))
      (loop with changed = t while changed do
        (setf changed nil)
        (loop for state across states for id from 0
              for owner = (aref owners id)
              when owner do
                (dolist (edge (state-edges state))
                  (when (eq (transition-kind edge) :call)
                    (let* ((callee (transition-value edge))
                           (target (transition-target edge))
                           (items (if (aref nullable target)
                                      (union (aref first target)
                                             (gethash owner follow)
                                             :test #'equal)
                                      (aref first target)))
                           (old (gethash callee follow))
                           (new (union items old :test #'equal)))
                      (unless (= (length new) (length old))
                        (setf (gethash callee follow) new changed t)))))))
      (loop for state across states for id from 0
            for owner = (aref owners id)
            when (and owner (state-exit-alternative state)
                      (member (state-direct-lookahead state)
                              '(:contextual :contextual-two))) do
              (let ((table (make-hash-table :test 'equal))
                    (overlap nil))
                (loop for edge in (state-edges state)
                      for alternative from 0 do
                        (let ((keys (if (edge-nullable edge)
                                        (union (edge-first edge)
                                               (gethash owner follow)
                                               :test #'equal)
                                        (edge-first edge))))
                          (dolist (key keys)
                            (let ((prior (gethash key table)))
                              (when (and prior (/= prior (1+ alternative)))
                                (setf overlap t))
                              (setf (gethash key table) (1+ alternative))))))
                (unless overlap
                  (setf (state-direct-lookahead state) table)))))))

(defun dfa-token-keys (grammar dfa)
  (remove-duplicates
   (loop for configuration in (dfa-state-configurations dfa)
         for state = (aref (parser-states grammar)
                           (configuration-state configuration))
         append (loop for edge in (state-edges state)
                      when (eq (transition-kind edge) :token)
                        collect (transition-value edge)))
   :test #'equal))

(defun two-token-lookahead (grammar state-id stack)
  "Cache choices proved unique after at most two tokens in this context."
  (let* ((start (funcall (parser-full-context-start grammar)
                         grammar state-id stack))
         (first-keys (dfa-token-keys grammar start))
         (table (make-hash-table :test (if (every #'symbolp first-keys)
                                          'eq 'equal))))
    (dolist (first first-keys)
      (let* ((one (advance-dfa grammar start first))
             (alternatives (dfa-state-alternatives one)))
        (if (and alternatives (null (rest alternatives)))
            (setf (gethash first table) (1+ (first alternatives)))
            (let* ((second-keys (dfa-token-keys grammar one))
                   (second-table
                     (make-hash-table :test (if (every #'symbolp second-keys)
                                                'eq 'equal))))
              (dolist (second second-keys)
                (let ((two (advance-dfa grammar one second)))
                  (when (and (dfa-state-alternatives two)
                             (null (rest (dfa-state-alternatives two))))
                    (setf (gethash second second-table)
                          (1+ (first (dfa-state-alternatives two)))))))
              (when (plusp (hash-table-count second-table))
                (setf (gethash first table) second-table))))))
    (when (plusp (hash-table-count table))
      (make-two-token-choice :table table))))

(defun contextual-choice (grammar state-id stack)
  (multiple-value-bind (table nullable overlap
                        default-alternative partial-table)
      (direct-lookahead-table grammar
                              (aref (parser-states grammar) state-id) stack)
    (declare (ignore nullable overlap))
    (or table
        (and default-alternative
             (make-direct-choice :table partial-table
                                 :default-alternative default-alternative))
        (two-token-lookahead grammar state-id stack)
        :unavailable)))

(defun context-key (grammar state-id parent-id)
  (declare (type fixnum state-id parent-id))
  (logior (ash parent-id (parser-context-shift grammar)) state-id))

(defun intern-context (grammar return-state parent-id)
  "Return the unique numeric ID for RETURN-STATE below PARENT-ID."
  (declare (type fixnum return-state parent-id))
  (cache-get-or-compute
   (parser-contexts grammar) (context-key grammar return-state parent-id)
   (lambda () (incf (the fixnum (parser-context-count grammar))))))

(defun contextual-direct-lookahead (grammar state-id stack context)
  (cache-get-or-compute
   (parser-direct-decisions grammar) (context-key grammar state-id context)
   (lambda () (contextual-choice grammar state-id stack))))

(defun compiled-choice-index (grammar state-id stack context input position)
  (declare (type simple-vector input) (type fixnum state-id context position))
  (when (parser-has-negated-tokens grammar)
    (return-from compiled-choice-index
      (predict grammar state-id stack input position)))
  (let* ((choice (state-direct-lookahead
                  (aref (parser-states grammar) state-id)))
         (table (if (member choice '(:contextual :contextual-two))
                    (contextual-direct-lookahead
                     grammar state-id stack context)
                    choice))
         (direct-table (if (direct-choice-p table)
                           (direct-choice-table table) table))
         (current (when (< position (length input))
                    (token-key (aref input position))))
         (direct (and current (hash-table-p direct-table)
                      (gethash current direct-table)))
         (two-token (and current (two-token-choice-p table)
                         (gethash current (two-token-choice-table table))))
         (two-token-result
           (if (hash-table-p two-token)
               (gethash (if (< (1+ position) (length input))
                            (token-key (aref input (1+ position)))
                            +end-of-input+)
                        two-token)
               two-token)))
    (cond (direct (1- (the fixnum direct)))
          (two-token-result (1- (the fixnum two-token-result)))
          ((direct-choice-p table)
           (direct-choice-default-alternative table))
          (t (predict grammar state-id stack input position)))))

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

(defun compile-parser-runner (grammar build-tree-p)
  "Compile one named local function per rule for recognition or node building."
  (let ((rules nil))
    (maphash (lambda (name start)
               (push (list name start
                           (make-symbol (format nil "PARSE-~A" name)))
                     rules))
             (parser-starts grammar))
    (labels ((rule-function (name)
               (third (assoc name rules :test #'eq)))
             (edge-form (edge function-name)
               (let ((target (transition-target edge)))
                 (case (transition-kind edge)
                   (:epsilon `(setf state-id ,target))
                   (:token
                    `(if (and (< position (length input))
                              (equal (token-key (aref input position))
                                     ',(transition-value edge)))
                         (progn
                           ,@(when build-tree-p
                               `((push (aref input position) children)))
                           (setf state-id ,target
                                 position (1+ position)))
                         (return-from ,function-name nil)))
                   (:not-token
                    `(if (and (< position (length input))
                              (not (member (token-key (aref input position))
                                           ',(transition-value edge)
                                           :test #'equal)))
                         (progn
                           ,@(when build-tree-p
                               `((push (aref input position) children)))
                           (setf state-id ,target
                                 position (1+ position)))
                         (return-from ,function-name nil)))
                   (:call
                    (if build-tree-p
                        `(let ((child
                                 (,(rule-function (transition-value edge))
                                  (cons ,target stack)
                                  (intern-context grammar ,target context))))
                           (unless child (return-from ,function-name nil))
                           (push child children)
                           (setf state-id ,target))
                        `(progn
                           (unless (,(rule-function (transition-value edge))
                                    (cons ,target stack)
                                    (intern-context grammar ,target context))
                             (return-from ,function-name nil))
                           (setf state-id ,target)))))))
             (choice-form (id state)
               (let ((table (state-direct-lookahead state)))
                 (if (hash-table-p table)
                     (let ((entries nil))
                       (maphash (lambda (key alternative)
                                  (push (cons key (1- alternative)) entries))
                                table)
                       `(or (let ((key (if (< position (length input))
                                           (token-key (aref input position))
                                           +end-of-input+)))
                                (when key
                                  ,(if (every (lambda (entry)
                                                (symbolp (car entry)))
                                              entries)
                                       `(case key
                                          ,@(loop for (key . alternative) in entries
                                                  collect `((,key) ,alternative)))
                                       `(cond
                                          ,@(loop for (key . alternative) in entries
                                                  collect `((equal key ',key)
                                                            ,alternative))))))
                            (predict grammar ,id stack input position)))
                     `(compiled-choice-index grammar ,id stack context
                                             input position))))
             (state-form (id function-name)
               (let* ((state (aref (parser-states grammar) id))
                      (edges (state-edges state)))
                 `(,id
                   ,(cond ((state-stop-rule state)
                           `(return-from ,function-name
                              ,(if build-tree-p
                                   `(make-node :rule ',(state-stop-rule state)
                                               :children (nreverse children)
                                               :start start-position
                                               :end position)
                                   t)))
                          ((null (rest edges))
                          (edge-form (first edges) function-name))
                          (t
                           `(case ,(choice-form id state)
                              ,@(loop for edge in edges for index from 0
                                      collect `(,index
                                                ,(edge-form edge function-name)))
                              (otherwise (return-from ,function-name nil)))))))))
      (compile
       nil
       `(lambda (grammar input start require-eof)
          #+sbcl (declare (optimize (speed 3) (safety 1) (debug 0)
                                     (space 0) (compilation-speed 0)))
          (declare (type simple-vector input) (ignorable grammar))
          (let ((position 0))
            (declare (type fixnum position))
            (labels
                ,(loop for (name first-state function-name) in rules
                       collect `(,function-name (stack context)
                                 (declare (ignorable stack context))
                                 (let ((state-id ,first-state)
                                       ,@(when build-tree-p
                                           '((start-position position)
                                             (children nil))))
                                   (declare (type fixnum state-id))
                                   (loop
                                     (ecase state-id
                                       ,@(loop for id in
                                               (compiled-rule-states grammar
                                                                     first-state)
                                               collect (state-form id function-name)))))))
              (let ((result
                      (case start
                        ,@(loop for (name first-state function-name) in rules
                                collect `(,name (,function-name nil 0))))))
                (and result
                     (or (not require-eof)
                         (= position (length input)))
                     result)))))))))

(defun possible-tokens (grammar configurations)
  (remove-duplicates
   (loop for configuration in (closure grammar configurations)
         for state = (aref (parser-states grammar)
                           (configuration-state configuration))
         append (loop for edge in (state-edges state)
                      when (eq (transition-kind edge) :token)
                        collect (transition-value edge)))
   :test #'equal))

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
  (let* ((build-tree-p (parse-build-tree-p tree-builder))
         (lexed (coerce (if lexer (lex lexer tokens) tokens)
                        'simple-vector))
         (input (if (eq channels :all)
                    lexed
                    (coerce (remove-if-not (lambda (token)
                                             (member (token-channel token) channels
                                                     :test #'equal))
                                           lexed)
                            'simple-vector)))
         (position 0)
         (state-id (gethash start (parser-starts grammar)))
         (stack nil)
         (context 0)
         (frames (list (vector start 0 nil 0)))
         (pending nil)
         (recoveries nil)
         (automatic-insert-position -1)
         (automatic-insert-count 0))
    (declare (type fixnum position state-id
                   automatic-insert-position automatic-insert-count)
             (type simple-vector lexed input))
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
    (when (parser-semantic-rules grammar)
      (when recover
        (grammar-fail "Recovery is not supported with semantic callbacks"))
      (return-from parse
        (values (parse-semantic grammar input start require-eof tree-builder)
                nil)))
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
               (or pending (< position (length input))))
             (current-value ()
               (cond (pending (inserted-token-value (first pending)))
                     ((< position (length input)) (aref input position))
                     (t +end-of-input+)))
             (next-value ()
               (cond ((rest pending)
                      (inserted-token-value (second pending)))
                     (pending
                      (if (< position (length input))
                          (aref input position) +end-of-input+))
                     ((< (1+ position) (length input))
                      (aref input (1+ position)))
                     (t +end-of-input+)))
             (consume-current ()
               (if pending (pop pending)
                   (prog1 (aref input position) (incf position))))
             (available-count ()
               (+ (length pending) (- (length input) position)))
             (delete-current (count condition)
               (unless (and (integerp count) (<= 1 count)
                            (<= count (available-count)))
                 (error "DELETE-TOKENS count ~S exceeds the ~D available tokens"
                        count (available-count)))
               (record :delete-tokens condition
                       (loop repeat count collect (consume-current))))
             (remaining-values ()
               (coerce (append (mapcar #'inserted-token-value pending)
                               (coerce (subseq input position) 'list))
                       'vector))
             (predict-current ()
               (let* ((state (aref (parser-states grammar) state-id))
                      (choice (state-direct-lookahead state))
                      (table (if (member choice '(:contextual :contextual-two))
                                 (contextual-direct-lookahead
                                  grammar state-id stack context)
                                 choice))
                      (direct-table (if (direct-choice-p table)
                                        (direct-choice-table table) table))
                      (direct (and (hash-table-p direct-table) (has-token-p)
                                   (gethash (token-key (current-value))
                                            direct-table)))
                      (two-token (and (two-token-choice-p table)
                                      (has-token-p)
                                      (gethash (token-key (current-value))
                                               (two-token-choice-table table))))
                      (two-token-result
                        (if (hash-table-p two-token)
                            (gethash (token-key (next-value)) two-token)
                            two-token)))
                 (cond (direct (1- direct))
                       (two-token-result (1- two-token-result))
                       ((direct-choice-p table)
                        (direct-choice-default-alternative table))
                       (pending
                        (predict grammar state-id stack (remaining-values) 0))
                       (t (predict grammar state-id stack input position)))))
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
                            (possible-tokens grammar
                                             (list (make-configuration
                                                    :state target :stack stack
                                                    :alternative 0)))
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
                     (invoke-restart 'choose-alternative 0)))))
           (unexpected-input
             (lambda (condition)
               (declare (ignore condition))
               (when recover (invoke-restart 'discard-input)))))
        (loop
          (let* ((state (aref (parser-states grammar) state-id))
                 (stop (state-stop-rule state)))
            (when stop
              (let* ((frame (pop frames))
                     (completed (when build-tree-p
                                  (make-parse-node tree-builder (aref frame 0)
                                                   (nreverse (aref frame 2))
                                                   (aref frame 1) position))))
                (unless (eq tree-builder :none)
                  (parse-rule-exit tree-builder
                                   (visible-rule grammar (aref frame 0))
                                   (aref frame 1) position))
                (if stack
                    (progn
                      (when build-tree-p
                        (push completed (aref (first frames) 2)))
                      (setf context (aref frame 3))
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
                                    position (length input))))))
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
                                0 (predict-current))))
                (when (null index)
                  (let ((condition
                          (make-condition
                           'no-viable-alternative :position position
                           :token (current-value)
                           :rule (visible-rule grammar (aref (first frames) 0))
                           :expected
                           (possible-tokens
                            grammar
                            (loop for edge in edges for alternative from 0
                                  collect (configuration-after-edge
                                           grammar edge stack alternative))))))
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
                  (let ((edge (nth index edges)))
                    (case (transition-kind edge)
                      (:epsilon (setf state-id (transition-target edge)))
                      (:call
                       (push (vector (transition-value edge) position nil
                                     context)
                             frames)
                       (setf context
                             (intern-context grammar
                                             (transition-target edge) context))
                       (push (transition-target edge) stack)
                       (unless (eq tree-builder :none)
                         (parse-rule-enter
                          tree-builder
                          (visible-rule grammar (transition-value edge)) position))
                       (setf state-id (gethash (transition-value edge)
                                               (parser-starts grammar))))
                      (:not-token
                       (if (and (has-token-p)
                                (not (member (token-key (current-value))
                                             (transition-value edge)
                                             :test #'equal)))
                           (let ((start-position position)
                                 (token (consume-current)))
                             (unless (eq tree-builder :none)
                               (parse-token-consumed tree-builder token
                                                     start-position position))
                             (when build-tree-p
                               (push token (aref (first frames) 2)))
                             (setf state-id (transition-target edge)))
                           (let ((condition
                                   (make-condition
                                    'mismatched-token :position position
                                    :token (current-value)
                                    :expected (list 'not-token
                                                    (transition-value edge))
                                    :rule (visible-rule
                                           grammar (aref (first frames) 0))
                                    :next-state (transition-target edge))))
                             (multiple-value-bind (action count)
                                 (restart-case (error condition)
                                   (delete-tokens (&optional (count 1))
                                     :report "Delete tokens and retry."
                                     :test (lambda (condition)
                                             (declare (ignore condition))
                                             (has-token-p))
                                     (values :delete-many count)))
                               (when (eq action :delete-many)
                                 (delete-current count condition))))))
                      (:token
                       (let ((expected (transition-value edge)))
                         (if (and (has-token-p)
                                  (equal (token-key (current-value)) expected))
                             (progn
                               (let ((start-position position)
                                     (token (consume-current)))
                                 (unless (eq tree-builder :none)
                                   (parse-token-consumed tree-builder token
                                                         start-position position))
                                 (when build-tree-p
                                   (push token (aref (first frames) 2))))
                               (setf state-id (transition-target edge)))
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
