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
(defstruct lookahead-choice table)
(defparameter *eager-lookahead-limit* 64
  "Maximum token-prefix edges explored for one contextual specialization.
Zero disables multi-token specialization. Clear parser caches after changing.")
(defparameter *eager-lookahead-configuration-limit* 4096
  "Maximum configuration keys examined during one speculative contextual choice.
This bounds work before the token-prefix limit can be checked.")
(defvar *eager-lookahead-work-left* nil)
(defstruct indexed-choice raw direct lookahead default-alternative)
(defstruct (rule-context
            (:constructor make-rule-context (return-state parent)))
  (return-state 0 :type fixnum)
  parent
  canonical-id)
(defstruct configuration (state 0 :type fixnum) (stack nil :type list)
  (alternative 0 :type fixnum))
(defstruct dfa-state configurations alternatives accepted edges)
(defstruct parser states starts stops default-rule lexer (tree-builder :node)
  (rewrites (make-hash-table :test 'eq))
  has-negated-tokens metadata semantic-rules
  (cache-backend :hash-table)
  (full-context-strategy :cached) full-context-start
  decisions sll-decisions direct-decisions contexts
  (context-count 0) context-shift token-keys token-index runner node-runner
  compiled-sll compiled-full)
(defstruct parser-definition name kind default-rule lexer cache-backend metadata
  parser-package lexer-package
  (full-context-strategy :cached)
  (tree-builder :node)
  (rules nil) (imports nil) (origins nil) compiled)
(defstruct parser-run-state
  input
  (tokens #() :type simple-vector)
  (position 0 :type fixnum)
  (logical-position 0 :type fixnum))
(declaim (ftype function ensure-parser-compiled))
(declaim (ftype function resolve-full-context-strategy))
(declaim (ftype function compile-parser-runner))
(declaim (ftype function initialize-token-index))

(defun grammar-fail (control &rest arguments)
  (error 'grammar-error :message (apply #'format nil control arguments)))

(defun plist-key-p (plist key)
  (loop for tail on plist by #'cddr
        thereis (eq (first tail) key)))

(defun grammar-operator-p (symbol)
  (member symbol '(and or * + seq ? *? +? ?? range one-of not-one-of any
                   label alt-label token not-token predicate action right
                   antlr-precedence defparser defrule with-mode use)))

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
                                    (tree-builder :node) metadata
                                    (compile-runners t))
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
      (initialize-token-index grammar)
      (unless (or (parser-has-negated-tokens grammar)
                  (parser-semantic-rules grammar))
        (initialize-direct-lookahead grammar)
        (initialize-follow-lookahead grammar))
      (when (and compile-runners (not (parser-semantic-rules grammar)))
        (setf (parser-runner grammar) (compile-parser-runner grammar nil)
              (parser-node-runner grammar) (compile-parser-runner grammar t)))
      grammar)))

(defun configuration-key (configuration)
  (declare (type configuration configuration))
  (list (configuration-state configuration)
        (configuration-stack configuration)
        (configuration-alternative configuration)))

(defun eager-configuration-key (configuration)
  (when (minusp (decf *eager-lookahead-work-left*))
    (throw 'eager-lookahead-limit nil))
  (configuration-key configuration))

(defun make-closure-key-function ()
  "Return a key function whose exact stack IDs live for one closure only."
  (let ((by-stack (make-hash-table :test 'eq))
        (by-pair (make-hash-table :test 'equal))
        (next-id 0))
    ;; Lists remain in configurations and persistent DFA states. Only the
    ;; temporary seen-table keys use IDs. Canonicalize shallow pairs so deep
    ;; stacks do not require deep EQUAL comparisons in that table.
    (labels ((stack-id (stack)
               (if (null stack) 0
                   (or (gethash stack by-stack)
                       (setf (gethash stack by-stack)
                             (let ((pair (cons (car stack) (stack-id (cdr stack)))))
                               (or (gethash pair by-pair)
                                   (setf (gethash pair by-pair) (incf next-id))))))))
             (key (configuration)
               (declare (type configuration configuration))
               (when (and *eager-lookahead-work-left*
                          (minusp (decf *eager-lookahead-work-left*)))
                 (throw 'eager-lookahead-limit nil))
               (list (configuration-state configuration)
                     (stack-id (configuration-stack configuration))
                     (configuration-alternative configuration))))
      #'key)))

(defun closure (grammar initial)
  (declare (type parser grammar) (type list initial))
  (nreverse
   (graph-closure
    initial (make-closure-key-function)
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

(declaim (inline input-size input-token input-next-position))
(defun input-size (input)
  (if (filtered-token-input-p input)
      (length (filtered-token-input-tokens input))
      (length input)))

(defun input-token (input position)
  (aref (if (filtered-token-input-p input)
            (filtered-token-input-tokens input)
            input)
        position))

(defun input-next-position (input position)
  (let ((next (1+ position)))
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


(defun predict-full-context (grammar state-id stack tokens position)
  (declare (type parser grammar) (type fixnum state-id position)
           (type list stack) (type (or simple-vector filtered-token-input) tokens))
  (let* ((dfa (funcall (parser-full-context-start grammar)
                       grammar state-id stack))
         (length (input-size tokens)))
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
      (setf dfa (advance-dfa grammar dfa (input-token tokens position)))
      (setf position (input-next-position tokens position)))))

(defun predict (grammar state-id stack tokens position)
  ;; The first DFA omits the caller's return stack. If an alternative can
  ;; finish in that shortened context while another remains viable, the
  ;; result depends on the caller and prediction retries with the full stack.
  (declare (type parser grammar) (type fixnum state-id position)
           (type list stack) (type (or simple-vector filtered-token-input) tokens))
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
         (length (input-size tokens)))
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
      (setf dfa (advance-dfa grammar dfa (input-token tokens position)))
      (setf position (input-next-position tokens position)))))

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
                      (and overlap :contextual-lookahead))))))

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
                              '(:contextual :contextual-lookahead))) do
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

(defun bounded-lookahead (grammar state-id stack)
  "Specialize arbitrary-depth prefixes within the cumulative edge budget."
  (when (plusp *eager-lookahead-limit*)
    (let ((remaining *eager-lookahead-limit*))
      (labels ((build (dfa)
                 (let* ((keys (dfa-token-keys grammar dfa))
                        (table (make-hash-table
                                :test (if (every #'symbolp keys) 'eq 'equal))))
                   ;; Charge the whole frontier before expanding any of it.
                   ;; Unary prefixes consume budget too, so cycles and long
                   ;; common prefixes cannot lead to unbounded eager work.
                   (when (> (length keys) remaining)
                     (throw 'eager-lookahead-limit nil))
                   (decf remaining (length keys))
                   (dolist (key keys)
                     (let* ((next (advance-dfa grammar dfa key))
                            (alternatives (dfa-state-alternatives next))
                            (entry (if (and alternatives (null (rest alternatives)))
                                       (1+ (first alternatives))
                                       (and alternatives (build next)))))
                       (when entry (setf (gethash key table) entry))))
                   (when (plusp (hash-table-count table)) table))))
        (let ((table (build (funcall (parser-full-context-start grammar)
                                     grammar state-id stack))))
          (when table (make-lookahead-choice :table table)))))))

(defun contextual-choice (grammar state-id stack)
  (or (let ((*eager-lookahead-work-left* *eager-lookahead-configuration-limit*))
        (catch 'eager-lookahead-limit
          (multiple-value-bind (table nullable overlap
                                default-alternative partial-table)
              (direct-lookahead-table grammar
                                      (aref (parser-states grammar) state-id) stack)
            (declare (ignore nullable overlap))
            (or table
                (and default-alternative
                     (make-direct-choice :table partial-table
                                         :default-alternative default-alternative))
                (bounded-lookahead grammar state-id stack)))))
      :unavailable))

(defun initialize-token-index (grammar)
  (let ((keys nil))
    (loop for state across (parser-states grammar) do
      (dolist (edge (state-edges state))
        (when (eq (transition-kind edge) :token)
          (pushnew (transition-value edge) keys :test #'equal))))
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

(defun index-choice-table (grammar table)
  (let* ((keys (parser-token-keys grammar))
         (result (make-array (length keys) :initial-element nil)))
    (loop for key across keys for index from 0 do
      (setf (aref result index) (gethash key table)))
    result))

(defun index-contextual-choice (grammar choice)
  (cond
    ((hash-table-p choice)
     (make-indexed-choice :raw choice
                          :direct (index-choice-table grammar choice)))
    ((direct-choice-p choice)
     (make-indexed-choice
      :raw choice
      :direct (index-choice-table grammar (direct-choice-table choice))
      :default-alternative (direct-choice-default-alternative choice)))
    ((lookahead-choice-p choice)
     (labels ((index-tree (table)
                (let ((row (index-choice-table grammar table)))
                  (loop for entry across row for index from 0
                        when (hash-table-p entry) do
                          (setf (svref row index) (index-tree entry)))
                  row)))
       (make-indexed-choice :raw choice
                            :lookahead (index-tree (lookahead-choice-table choice)))))
    (t (make-indexed-choice :raw choice))))

(defun context-key (grammar state-id parent-id)
  (declare (type fixnum state-id parent-id))
  (logior (ash parent-id (parser-context-shift grammar)) state-id))

(defun intern-context (grammar return-state parent-id)
  "Return the unique numeric ID for RETURN-STATE below PARENT-ID."
  (declare (type fixnum return-state parent-id))
  (flet ((compute ()
           (incf (the fixnum (parser-context-count grammar)))))
    (declare (dynamic-extent #'compute))
    (cache-get-or-compute
     (parser-contexts grammar) (context-key grammar return-state parent-id)
     #'compute)))

(defun context-id (grammar context)
  "Intern a rule-context chain only when a decision needs its numeric ID."
  (etypecase context
    (fixnum context)
    (null 0)
    (rule-context
     (or (rule-context-canonical-id context)
         (setf (rule-context-canonical-id context)
               (intern-context grammar (rule-context-return-state context)
                               (context-id grammar
                                           (rule-context-parent context))))))))

(defun contextual-direct-lookahead (grammar state-id stack context
                                    &optional indexed-p)
  (flet ((compute ()
           (index-contextual-choice
            grammar (contextual-choice grammar state-id stack))))
    (declare (dynamic-extent #'compute))
    (let ((entry (cache-get-or-compute
                  (parser-direct-decisions grammar)
                  (context-key grammar state-id (context-id grammar context))
                  #'compute)))
      (if indexed-p entry (indexed-choice-raw entry)))))

(declaim (inline lookahead-alternative))
(defun lookahead-alternative (table input position
                             &optional grammar (first-index nil first-index-p))
  "Return a one-based proven alternative, or NIL without consuming input.
GRAMMAR selects indexed vector rows; FIRST-INDEX reuses the caller's lookup."
  (when first-index-p
    (unless first-index (return-from lookahead-alternative nil))
    (setf table (svref table first-index))
    (when (integerp table) (return-from lookahead-alternative table))
    (setf position (input-next-position input position)))
  (loop while (and table (< position (input-size input))) do
    (let ((key (token-key (input-token input position))))
      (setf table
            (if grammar
                (let ((index (funcall (parser-token-index grammar) key)))
                  (and index (svref table index)))
                (gethash key table))))
    (when (integerp table) (return-from lookahead-alternative table))
    (setf position (input-next-position input position))))

(defun compiled-choice-index (grammar state-id stack context input position)
  (declare (type (or simple-vector filtered-token-input) input)
           (type fixnum state-id position))
  (when (parser-has-negated-tokens grammar)
    (return-from compiled-choice-index
      (predict grammar state-id stack input position)))
  (let* ((choice (state-direct-lookahead
                  (aref (parser-states grammar) state-id)))
         (table (if (member choice '(:contextual :contextual-lookahead))
                    (contextual-direct-lookahead
                     grammar state-id stack context t)
                    choice))
         (current (when (< position (input-size input))
                    (token-key (input-token input position))))
         (token-index (and (indexed-choice-p table)
                           (< position (input-size input))
                           (funcall (parser-token-index grammar) current)))
         (direct (cond ((indexed-choice-p table)
                        (and token-index (indexed-choice-direct table)
                             (svref (indexed-choice-direct table) token-index)))
                       ((hash-table-p table) (and current (gethash current table)))
                       ((direct-choice-p table)
                        (and current (gethash current (direct-choice-table table))))))
         (lookahead (cond ((and (indexed-choice-p table) (indexed-choice-lookahead table))
                           (lookahead-alternative (indexed-choice-lookahead table)
                                                  input position grammar token-index))
                          ((lookahead-choice-p table)
                           (lookahead-alternative (lookahead-choice-table table)
                                                  input position)))))
    (cond (direct (1- (the fixnum direct)))
          (lookahead (1- (the fixnum lookahead)))
          ((and (indexed-choice-p table) (indexed-choice-default-alternative table))
           (indexed-choice-default-alternative table))
          ((direct-choice-p table) (direct-choice-default-alternative table))
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

(defun parser-rule-runner-forms (grammar build-tree-p)
  "Return independent rule lambda forms and their dispatch names."
  (let ((rules nil)
        (rule-indices (make-hash-table :test 'eq))
        (forms (make-array (hash-table-count (parser-starts grammar)))))
    (maphash (lambda (name start)
               (setf (gethash name rule-indices) (hash-table-count rule-indices))
               (push (list name start
                           (make-symbol (format nil "PARSE-~A" name)))
                     rules))
             (parser-starts grammar))
    (labels ((rule-call (edge)
               `(funcall (the function
                              (svref runners ,(gethash (transition-value edge)
                                                       rule-indices)))
                         grammar run runners
                         (cons ,(transition-target edge) stack)
                         (make-rule-context ,(transition-target edge) context)))
             (edge-form (edge function-name)
               (let ((target (transition-target edge)))
                 (case (transition-kind edge)
                   (:epsilon `(setf state-id ,target))
                   (:token
                    `(if (and (< position (length tokens))
                              (equal (token-key (aref tokens position))
                                     ',(transition-value edge)))
                         (progn
                           ,@(when build-tree-p
                               `((push (aref tokens position) children)
                                 (incf logical-position)))
                           (setf state-id ,target
                                 position (input-next-position input position)))
                         (return-from ,function-name nil)))
                   (:not-token
                    `(if (and (< position (length tokens))
                              (not (member (token-key (aref tokens position))
                                           ',(transition-value edge)
                                           :test #'equal)))
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
               (let ((table (state-direct-lookahead state)))
                 (if (hash-table-p table)
                     (let ((entries nil))
                       (maphash (lambda (key alternative)
                                  (push (cons key (1- alternative)) entries))
                                table)
                       `(or (let ((key (if (< position (length tokens))
                                           (token-key (aref tokens position))
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
                                               :end logical-position)
                                   t)))
                          ((null (rest edges))
                          (edge-form (first edges) function-name))
                          (t
                           `(case ,(choice-form id state)
                              ,@(loop for edge in edges for index from 0
                                      collect `(,index
                                                ,(edge-form edge function-name)))
                              (otherwise (return-from ,function-name nil)))))))))
      (loop for (name first-state function-name) in rules do
        (setf (svref forms (gethash name rule-indices))
              `(lambda (grammar run runners stack context)
                  #+sbcl (declare (optimize (speed 3) (safety 1) (debug 0)
                                             (space 0) (compilation-speed 0)))
                  (declare (type parser grammar)
                           (type parser-run-state run)
                           (type simple-vector runners)
                           (ignorable grammar run runners stack context))
                  (symbol-macrolet ((input (parser-run-state-input run))
                                    (tokens (parser-run-state-tokens run))
                                    (position (parser-run-state-position run))
                                    (logical-position
                                      (parser-run-state-logical-position run)))
                    (block ,function-name
                      (let ((state-id ,first-state)
                            ,@(when build-tree-p
                                '((start-position logical-position)
                                  (children nil))))
                        (declare (type fixnum state-id))
                        (loop
                          (ecase state-id
                            ,@(loop for id in
                                    (compiled-rule-states grammar first-state)
                                    collect (state-form id function-name))))))))))
      (values (coerce forms 'list) (mapcar #'first (reverse rules))))))

(defun make-parser-runner (runners names)
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
                              grammar run runners nil nil)))
        (and result
             (or (not require-eof)
                 (= (parser-run-state-position run) (length tokens)))
             result)))))

(defun parser-runner-form (grammar build-tree-p)
  "Emit independent rule functions for COMPILE-FILE without runtime compilation."
  (multiple-value-bind (forms names) (parser-rule-runner-forms grammar build-tree-p)
    `(make-parser-runner (vector ,@forms) ',names)))

(defun compile-parser-runner (grammar build-tree-p)
  (multiple-value-bind (forms names) (parser-rule-runner-forms grammar build-tree-p)
    (make-parser-runner (map 'vector (lambda (form) (compile nil form)) forms)
                       names)))

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
         (input (make-token-input lexed channels
                                  (parser-semantic-rules grammar)))
         (position 0)
         (physical-position (input-start-position input))
         (state-id (gethash start (parser-starts grammar)))
         (stack nil)
         (context 0)
         (frames (list (vector start 0 nil 0)))
         (pending nil)
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
    ;; Semantic callbacks use logical positions and access the shared input view.
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
               (let* ((state (aref (parser-states grammar) state-id))
                      (choice (state-direct-lookahead state))
                      (table (if (member choice '(:contextual :contextual-lookahead))
                                 (contextual-direct-lookahead
                                  grammar state-id stack context)
                                 choice))
                      (direct-table (if (direct-choice-p table)
                                        (direct-choice-table table) table))
                      (direct (and (hash-table-p direct-table) (has-token-p)
                                   (gethash (token-key (current-value))
                                            direct-table)))
                      (lookahead (and (lookahead-choice-p table)
                                      (lookahead-alternative
                                       (lookahead-choice-table table)
                                       (if pending (remaining-values) input)
                                       (if pending 0 physical-position)))))
                 (cond (direct (1- direct))
                       (lookahead (1- lookahead))
                       ((direct-choice-p table)
                        (direct-choice-default-alternative table))
                       (pending
                        (predict grammar state-id stack (remaining-values) 0))
                       (t (predict grammar state-id stack input physical-position)))))
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
