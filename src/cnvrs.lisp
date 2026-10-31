(defpackage #:cnvrs
  (:use #:cl)
  (:shadow #:parse-error)
  (:export #:compile-grammar #:compile-lexer #:parse #:lex
           #:ensure-compiled #:clone-compiled #:clear-cache
           #:make-parse-node #:parse-node-components
           #:parse-build-tree-p #:parse-rule-enter #:parse-token-consumed
           #:parse-rule-exit
           #:make-cache #:cache-get-or-compute #:cache-clear #:cache-count
           #:parser-cache-backend #:parser-full-context-strategy
           #:make-full-context-start
           #:compiled-lexer-cache-backend
           #:compiled-lexer-cache
           #:parser-p #:parser-states #:parser-starts #:parser-stops
           #:parser-default-rule #:parser-lexer #:parser-rewrites
           #:parser-tree-builder
           #:parser-decisions #:parser-sll-decisions #:parser-direct-decisions
           #:state-id #:state-edges #:state-stop-rule #:state-exit-alternative
           #:state-direct-lookahead
           #:transition-kind #:transition-target #:transition-value
           #:compiled-lexer-p #:compiled-lexer-states
           #:compiled-lexer-mode-starts #:compiled-lexer-kinds
           #:compiled-lexer-skips #:compiled-lexer-channels
           #:compiled-lexer-push-modes #:compiled-lexer-pop-modes
           #:compiled-lexer-set-modes
           #:lx-state-edges #:lx-state-accept
           #:lx-edge-kind #:lx-edge-target #:lx-edge-value
           #:define-parser #:in-parser #:defrule #:with-mode
           #:parser-definition-p #:lexer-matcher
           #:grammar-error #:parse-error
           #:lexical-error #:lexical-error-position #:lexical-error-character
           #:lexer-mode-error #:lexer-mode-error-mode
           #:make-lexeme #:lexeme-p #:lexeme-kind #:lexeme-text
           #:lexeme-start #:lexeme-end #:lexeme-channel
           #:parse-error-position #:parse-error-token #:parse-error-expected
           #:mismatched-token #:no-viable-alternative #:unexpected-input
           #:parse-error-rule #:+end-of-input+
           #:insert-tokens #:delete-tokens
           #:choose-alternative
           #:discard-input #:recovery-p #:recovery-action #:recovery-condition
           #:recovery-token #:inserted-token-p #:inserted-token-expected
           #:inserted-token-value #:inserted-token-position
           #:node-p #:node-rule #:node-children #:node-start #:node-end))

(in-package #:cnvrs)

;; Backends can be added by specializing MAKE-CACHE on a new backend name
;; and implementing these three operations for the returned cache object.
(defgeneric make-cache (backend))
(defgeneric cache-get-or-compute (cache key thunk))
(defgeneric cache-clear (cache))
(defgeneric cache-count (cache))

(defparameter +flat-cache-key-marker+ (gensym "FLAT-CACHE-KEY-"))

(defun flat-cache-key (head tail)
  "Make a structural cache key from HEAD and a list of integer IDs."
  (let ((key (make-array (+ 2 (length tail)))))
    (setf (aref key 0) +flat-cache-key-marker+
          (aref key 1) head)
    (loop for value in tail
          for index from 2
          do (setf (aref key index) value))
    key))

(defun parser-context-key (head stack)
  "Use a small pair for shallow stacks and a flat array for deeper ones."
  (if (null (cdr stack))
      (cons head (first stack))
      (flat-cache-key head stack)))

(defun flat-cache-key-p (key)
  (and (vectorp key) (plusp (length key))
       (eq (aref key 0) +flat-cache-key-marker+)))

(defstruct hash-cache
  (table (make-hash-table :test 'equal))
  flat-table)
(defmethod make-cache ((backend (eql :hash-table)))
  (make-hash-cache))
(defmethod cache-get-or-compute ((cache hash-cache) key thunk)
  (let ((table (if (flat-cache-key-p key)
                   (or (hash-cache-flat-table cache)
                       (setf (hash-cache-flat-table cache)
                             (make-hash-table :test 'equalp)))
                   (hash-cache-table cache))))
    (multiple-value-bind (value present) (gethash key table)
      (if present value
          (setf (gethash key table) (funcall thunk))))))
(defmethod cache-clear ((cache hash-cache))
  (clrhash (hash-cache-table cache))
  (when (hash-cache-flat-table cache)
    (clrhash (hash-cache-flat-table cache)))
  cache)
(defmethod cache-count ((cache hash-cache))
  (+ (hash-table-count (hash-cache-table cache))
     (if (hash-cache-flat-table cache)
         (hash-table-count (hash-cache-flat-table cache))
         0)))

(defun cache-key-compare (a b)
  "Compare common cache key components without FSET's generic dispatch."
  (let ((a (fset2:unwrap-equivalent-node a))
        (b (fset2:unwrap-equivalent-node b)))
    (cond ((eql a b) :equal)
          ((and (typep a 'fixnum) (typep b 'fixnum))
           (if (< a b) :less :greater))
          ((and (characterp a) (characterp b))
           (if (char< a b) :less :greater))
          ((and (flat-cache-key-p a) (flat-cache-key-p b))
           (loop for index from 1 below (min (length a) (length b))
                 for left = (aref a index)
                 for right = (aref b index)
                 unless (= left right)
                   do (return-from cache-key-compare
                        (if (< left right) :less :greater)))
           (cond ((< (length a) (length b)) :less)
                 ((> (length a) (length b)) :greater)
                 (t :equal)))
          ((and (consp a) (consp b))
           (do ((left a (cdr left))
                (right b (cdr right))
                (default :equal))
               ((or (atom left) (atom right))
                (if (eql left right) default
                    (let ((comparison (cache-key-compare left right)))
                      (if (eq comparison :equal) default comparison))))
             (let ((comparison (cache-key-compare (car left) (car right))))
               (case comparison
                 ((:less :greater) (return comparison))
                 (:unequal (setf default :unequal))))))
          (t (fset:compare a b)))))

(defstruct fset-cache (map (fset:empty-wb-map nil 'cache-key-compare)))
(defmethod make-cache ((backend (eql :fset)))
  (make-fset-cache))
(defmethod cache-get-or-compute ((cache fset-cache) key thunk)
  (multiple-value-bind (value present) (fset:lookup (fset-cache-map cache) key)
    (if present value
        (let ((value (funcall thunk)))
          (setf (fset-cache-map cache)
                (fset:with (fset-cache-map cache) key value))
          value))))
(defmethod cache-clear ((cache fset-cache))
  (setf (fset-cache-map cache)
        (fset:empty-wb-map nil 'cache-key-compare))
  cache)
(defmethod cache-count ((cache fset-cache))
  (fset:size (fset-cache-map cache)))

(defstruct locked-cache inner (lock (bt:make-lock "CNVRS cache")))
(defmethod make-cache ((backend cons))
  (unless (and (eq (first backend) :locked)
               (consp (rest backend))
               (null (cddr backend)))
    (error "Expected (:LOCKED backend), got ~S" backend))
  (make-locked-cache :inner (make-cache (second backend))))
(defmethod cache-get-or-compute ((cache locked-cache) key thunk)
  (bt:with-lock-held ((locked-cache-lock cache))
    (cache-get-or-compute (locked-cache-inner cache) key thunk)))
(defmethod cache-clear ((cache locked-cache))
  (bt:with-lock-held ((locked-cache-lock cache))
    (cache-clear (locked-cache-inner cache)))
  cache)
(defmethod cache-count ((cache locked-cache))
  (bt:with-lock-held ((locked-cache-lock cache))
    (cache-count (locked-cache-inner cache))))

(defparameter +end-of-input+ (gensym "END-OF-INPUT-"))

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

(defstruct node rule children start end)
(defgeneric make-parse-node (builder rule children start end))
(defgeneric parse-node-components (builder value))
(defmethod make-parse-node ((builder (eql :node)) rule children start end)
  (make-node :rule rule :children children :start start :end end))
(defmethod parse-node-components ((builder (eql :node)) value)
  (if (node-p value)
      (values (node-rule value) (node-children value)
              (node-start value) (node-end value) t)
      (values nil nil nil nil nil)))
(defgeneric parse-build-tree-p (builder))
(defmethod parse-build-tree-p (builder)
  (declare (ignore builder))
  t)
(defmethod parse-build-tree-p ((builder (eql :none)))
  nil)
(defgeneric parse-rule-enter (builder rule position))
(defgeneric parse-token-consumed (builder token start end))
(defgeneric parse-rule-exit (builder rule start end))
(defmethod parse-rule-enter (builder rule position)
  (declare (ignore builder rule position))
  nil)
(defmethod parse-token-consumed (builder token start end)
  (declare (ignore builder token start end))
  nil)
(defmethod parse-rule-exit (builder rule start end)
  (declare (ignore builder rule start end))
  nil)
(defstruct lexeme kind text start end (channel :default))
(defun token-key (token)
  (if (lexeme-p token) (lexeme-kind token) token))
(defun token-channel (token)
  (if (lexeme-p token) (lexeme-channel token) :default))
(defstruct inserted-token expected position)
(defun inserted-token-value (token)
  (inserted-token-expected token))
(defstruct recovery action condition token)
(defstruct transition kind target value)
(defstruct state id (edges nil) stop-rule exit-alternative direct-lookahead)
(defstruct configuration state stack alternative)
(defstruct dfa-state configurations alternatives accepted edges)
(defstruct parser states starts stops default-rule lexer (tree-builder :node)
  (rewrites (make-hash-table :test 'eq))
  (cache-backend :hash-table)
  (full-context-strategy :cached) full-context-start
  decisions sll-decisions direct-decisions)
(defstruct parser-definition name kind default-rule lexer cache-backend
  (full-context-strategy :cached)
  (tree-builder :node)
  (rules nil) compiled)
(declaim (ftype function ensure-parser-compiled))
(declaim (ftype function resolve-full-context-strategy))

(defun grammar-fail (control &rest arguments)
  (error 'grammar-error :message (apply #'format nil control arguments)))

(defun plist-key-p (plist key)
  (loop for tail on plist by #'cddr
        thereis (eq (first tail) key)))

(defun expression-kind (expression)
  (cond ((atom expression)
         (cond ((and (symbolp expression) (not (keywordp expression)))
                :reference)
               (t :token)))
        ((and (consp expression) (symbolp (first expression)))
         (let ((operator (string-upcase (symbol-name (first expression)))))
           (cond ((member operator '("AND" "SEQ") :test #'string=) :sequence)
                 ((string= operator "OR") :choice)
                 ((string= operator "*") :star)
                 ((string= operator "+") :plus)
                 ((string= operator "?") :optional)
                 ((string= operator "TOKEN") :token-form)
                 (t nil))))
        (t nil)))

(defun validate-expression (expression names)
  (let ((kind (expression-kind expression)))
    (unless kind (grammar-fail "Invalid grammar expression: ~S" expression))
    (case kind
      (:reference
       (unless (gethash expression names)
         (grammar-fail "Undefined rule ~S" expression)))
      (:token-form
       (unless (= (length expression) 2)
         (grammar-fail "TOKEN requires one value: ~S" expression)))
      ((:star :plus :optional)
       (unless (= (length expression) 2)
         (grammar-fail "~A requires one expression: ~S" (first expression) expression))
       (validate-expression (second expression) names))
      ((:sequence :choice)
       (when (and (eq kind :choice) (null (rest expression)))
         (grammar-fail "OR requires at least one alternative"))
       (dolist (child (rest expression))
         (validate-expression child names))))))

(defun nullable-p (expression nullable)
  (case (expression-kind expression)
    (:reference (gethash expression nullable))
    (:token nil)
    (:token-form nil)
    (:sequence (every (lambda (part) (nullable-p part nullable)) (rest expression)))
    (:choice (some (lambda (part) (nullable-p part nullable)) (rest expression)))
    ((:star :optional) t)
    (:plus (nullable-p (second expression) nullable))))

(defun leading-rules (expression nullable)
  (case (expression-kind expression)
    (:reference (list expression))
    (:sequence
     (loop for part in (rest expression)
           append (leading-rules part nullable)
           while (nullable-p part nullable)))
    (:choice (loop for part in (rest expression)
                   append (leading-rules part nullable)))
    ((:star :plus :optional) (leading-rules (second expression) nullable))
    (otherwise nil)))

(defun validate-progress (definitions nullable)
  (dolist (definition definitions)
    (labels ((walk (expression)
               (case (expression-kind expression)
                 ((:star :plus)
                  (when (nullable-p (second expression) nullable)
                    (grammar-fail "Repetition body can match no tokens: ~S" expression))
                  (walk (second expression)))
                 (:optional (walk (second expression)))
                 ((:sequence :choice) (mapc #'walk (rest expression))))))
      (walk (second definition))))
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
  (let* ((right (and (consp alternative)
                     (symbolp (first alternative))
                     (string= (symbol-name (first alternative)) "RIGHT")))
         (body (if right (second alternative) alternative))
         (parts (if (eq (expression-kind body) :sequence)
                    (rest body) (list body))))
    (when right
      (unless (= (length alternative) 2)
        (grammar-fail "RIGHT requires one alternative: ~S" alternative)))
    (if (eq (first parts) rule)
        (progn
          (unless (rest parts)
            (grammar-fail "Left-recursive alternative must consume input: ~S" alternative))
          (values (rest parts) right))
        (progn
          (when right
            (grammar-fail "RIGHT requires a direct left-recursive alternative: ~S"
                          alternative))
          (values nil nil)))))

(defun rewrite-left-recursion (definitions)
  (let ((rewrites (make-hash-table :test 'eq))
        (output nil))
    (dolist (definition definitions)
      (destructuring-bind (rule expression) definition
        (let ((bases nil) (recursive nil)
              (alternatives (if (eq (expression-kind expression) :choice)
                                (rest expression) (list expression))))
          (dolist (alternative alternatives)
            (multiple-value-bind (suffix right)
                (direct-left-alternative rule alternative)
              (if suffix
                  (push (list suffix right) recursive)
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
                       (generated (list (list primary
                                              (if (rest bases) (cons 'or bases)
                                                  (first bases))))))
                  (setf (gethash primary rewrites) (list :primary rule))
                  (dolist (alternative (reverse recursive))
                    (destructuring-bind (suffix right) alternative
                      (let* ((level (gensym "LEVEL-"))
                             (suffix-rule (gensym "SUFFIX-"))
                             (parts (copy-list suffix)))
                        (when (eq (car (last parts)) rule)
                          (setf (car (last parts)) (if right level higher)))
                        (push (list suffix-rule
                                    (if (rest parts) (cons 'and parts) (first parts)))
                              generated)
                        (push (list level (list 'and higher (list '* suffix-rule)))
                              generated)
                        (setf (gethash suffix-rule rewrites) (list :suffix rule)
                              (gethash level rewrites) (list :level rule)
                              higher level))))
                  (setf (gethash rule rewrites) (list :wrapper rule))
                  (push (list rule higher) output)
                  (dolist (item (nreverse generated)) (push item output))))))))
    (values (nreverse output) rewrites)))

(defun parse-node-children-for (builder node)
  (nth-value 1 (parse-node-components builder node)))
(defun parse-node-start-for (builder node)
  (nth-value 2 (parse-node-components builder node)))
(defun parse-node-end-for (builder node)
  (nth-value 3 (parse-node-components builder node)))

(defun normalize-rewritten-node (node rewrites builder)
  (multiple-value-bind (rule original-children start end present)
      (parse-node-components builder node)
    (if (not present)
        node
        (let* ((children (mapcar (lambda (child)
                                   (normalize-rewritten-node child rewrites
                                                             builder))
                                 original-children))
               (rewrite (gethash rule rewrites)))
          (case (first rewrite)
            (:wrapper (first children))
            (:primary (make-parse-node builder (second rewrite) children
                                       start end))
            (:level
             (reduce (lambda (left suffix)
                       (make-parse-node
                        builder (second rewrite)
                        (cons left (parse-node-children-for builder suffix))
                        (parse-node-start-for builder left)
                        (parse-node-end-for builder suffix)))
                     (rest children) :initial-value (first children)))
            (otherwise (make-parse-node builder rule children start end)))))))

(defun visible-rule (grammar rule)
  (or (second (gethash rule (parser-rewrites grammar))) rule))

(defun new-state (grammar &optional stop-rule)
  (let* ((states (parser-states grammar))
         (id (length states)))
    (vector-push-extend (make-state :id id :stop-rule stop-rule) states)
    id))

(defun add-edge (grammar from kind target &optional value)
  (let ((state (aref (parser-states grammar) from)))
    (setf (state-edges state)
          (nconc (state-edges state)
                 (list (make-transition :kind kind :target target :value value))))))

(defun compile-expression (grammar expression entry exit)
  (case (expression-kind expression)
    (:reference (add-edge grammar entry :call exit expression))
    (:token (add-edge grammar entry :token exit expression))
    (:token-form (add-edge grammar entry :token exit (second expression)))
    (:sequence
     (let ((parts (rest expression)) (current entry))
       (if (null parts)
           (add-edge grammar entry :epsilon exit)
           (loop for tail on parts
                 for next = (if (null (rest tail)) exit (new-state grammar))
                 do (compile-expression grammar (first tail) current next)
                    (setf current next)))))
    (:choice
     (dolist (part (rest expression))
       (let ((branch (new-state grammar)))
         (add-edge grammar entry :epsilon branch)
         (compile-expression grammar part branch exit))))
    (:optional
     (let ((branch (new-state grammar)))
       (setf (state-exit-alternative (aref (parser-states grammar) entry)) 1)
       (add-edge grammar entry :epsilon branch)
       (add-edge grammar entry :epsilon exit)
       (compile-expression grammar (second expression) branch exit)))
    (:star
     (let ((branch (new-state grammar)) (body-end (new-state grammar)))
       (setf (state-exit-alternative (aref (parser-states grammar) entry)) 1)
       (add-edge grammar entry :epsilon branch)
       (add-edge grammar entry :epsilon exit)
       (compile-expression grammar (second expression) branch body-end)
       (add-edge grammar body-end :epsilon entry)))
    (:plus
     (let ((loop-state (new-state grammar)))
       (compile-expression grammar (second expression) entry loop-state)
       (compile-expression grammar (list '* (second expression)) loop-state exit)))))

(defun compile-grammar (definitions &key default-rule lexer
                                    (cache-backend :hash-table)
                                    (full-context-strategy :cached)
                                    (tree-builder :node))
  "Compile Lisp-form rule definitions into an in-memory parser.
DEFINITIONS is a list of (name expression) pairs. Expressions use
(AND ...), (OR ...), (* x), (+ x), (? x), and (TOKEN value).
Direct left-recursive alternatives are ordered from low to high precedence;
(RIGHT alternative) gives a recursive alternative right associativity.
Bare symbols name rules; other atoms are literal tokens. DEFAULT-RULE chooses
the entry rule used by PARSE when no :RULE is supplied; otherwise the first
definition is used. LEXER maps source input to tokens before parsing.
CACHE-BACKEND selects :FSET, :HASH-TABLE, a custom backend, or
(:LOCKED backend). The default is :HASH-TABLE.
TREE-BUILDER selects the parse-node construction strategy.
FULL-CONTEXT-STRATEGY selects :CACHED (the default), :RECOMPUTE, or a
function of (parser state-id return-stack) that returns a start DFA state."
  (unless (and (listp definitions) definitions)
    (grammar-fail "Expected a nonempty list of rule definitions"))
  (let ((names (make-hash-table :test 'eq))
        (nullable (make-hash-table :test 'eq))
        (rewrites nil))
    (dolist (definition definitions)
      (unless (and (listp definition) (= (length definition) 2)
                   (symbolp (first definition)) (not (keywordp (first definition))))
        (grammar-fail "Expected (rule-name expression), got ~S" definition))
      (when (gethash (first definition) names)
        (grammar-fail "Duplicate rule ~S" (first definition)))
      (setf (gethash (first definition) names) t))
    (setf default-rule (or default-rule (first (first definitions))))
    (unless (gethash default-rule names)
      (grammar-fail "Unknown default rule ~S" default-rule))
    (multiple-value-setq (definitions rewrites)
      (rewrite-left-recursion definitions))
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
                                 :tree-builder tree-builder
                                 :rewrites rewrites
                                 :cache-backend cache-backend
                                 :full-context-strategy full-context-strategy
                                 :full-context-start
                                 (resolve-full-context-strategy
                                  full-context-strategy)
                                 :decisions (make-cache cache-backend)
                                 :sll-decisions (make-cache cache-backend)
                                 :direct-decisions (make-cache cache-backend))))
      (dolist (definition definitions)
        (setf (gethash (first definition) (parser-starts grammar)) (new-state grammar)
              (gethash (first definition) (parser-stops grammar))
              (new-state grammar (first definition))))
      (dolist (definition definitions)
        (compile-expression grammar (second definition)
                            (gethash (first definition) (parser-starts grammar))
                            (gethash (first definition) (parser-stops grammar))))
      (initialize-direct-lookahead grammar)
      grammar)))

(defun configuration-key (configuration)
  (list (configuration-state configuration)
        (configuration-stack configuration)
        (configuration-alternative configuration)))

(defun closure (grammar initial)
  (let ((pending (copy-list initial))
        (seen (make-hash-table :test 'equal))
        (result nil))
    (loop while pending do
      (let* ((configuration (pop pending))
             (key (configuration-key configuration)))
        (unless (gethash key seen)
          (setf (gethash key seen) t)
          (let* ((state (aref (parser-states grammar)
                              (configuration-state configuration)))
                 (stack (configuration-stack configuration))
                 (alternative (configuration-alternative configuration)))
            (cond
              ((state-stop-rule state)
               (if stack
                   (push (make-configuration :state (first stack)
                                             :stack (rest stack)
                                             :alternative alternative)
                         pending)
                   (push configuration result)))
              (t
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
                     (:token (setf has-token t))))
                 (when has-token (push configuration result)))))))))
    (nreverse result)))

(defun dfa-state-for (grammar configurations)
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
  (cache-get-or-compute
   (dfa-state-edges dfa) (token-key token)
   (lambda ()
     (dfa-state-for grammar
                    (loop for configuration in (dfa-state-configurations dfa)
                          for state = (aref (parser-states grammar)
                                            (configuration-state configuration))
                          append (loop for edge in (state-edges state)
                                       when (and (eq (transition-kind edge) :token)
                                                 (equal (token-key token) (transition-value edge)))
                                         collect (make-configuration
                                                  :state (transition-target edge)
                                                  :stack (configuration-stack configuration)
                                                  :alternative
                                                  (configuration-alternative configuration))))))))

(defun make-full-context-start (grammar state-id stack)
  (dfa-state-for grammar
                 (loop for edge in (state-edges
                                    (aref (parser-states grammar) state-id))
                       for alternative from 0
                       collect (configuration-after-edge
                                grammar edge stack alternative))))

(defun cached-full-context-start (grammar state-id stack)
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
  (let* ((dfa (funcall (parser-full-context-start grammar)
                       grammar state-id stack))
         (length (length tokens)))
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
  (let ((table (make-hash-table :test 'equal))
        (nullable nil)
        (overlap nil))
    (loop for edge in (state-edges state) for alternative from 0 do
      (let ((found-token nil))
        (dolist (configuration
                 (closure grammar
                          (list (configuration-after-edge
                                 grammar edge stack alternative))))
          (let ((next (aref (parser-states grammar)
                            (configuration-state configuration))))
            (if (state-stop-rule next)
                (setf nullable t)
                (dolist (transition (state-edges next))
                  (when (eq (transition-kind transition) :token)
                    (setf found-token t)
                    (let* ((key (transition-value transition))
                           (prior (gethash key table)))
                      (when (and prior (/= prior (1+ alternative)))
                        (setf overlap t))
                      (setf (gethash key table) (1+ alternative))))))))
        (unless found-token (setf nullable t))))
    (values (unless (or nullable overlap) table) nullable overlap)))

(defun initialize-direct-lookahead (grammar)
  "Record one-token choices independent of the caller, and contextual candidates."
  (loop for state across (parser-states grammar)
        when (> (length (state-edges state)) 1) do
          (multiple-value-bind (table nullable overlap)
              (direct-lookahead-table grammar state nil)
            (setf (state-direct-lookahead state)
                  (or table (and nullable (not overlap) :contextual))))))

(defun contextual-direct-lookahead (grammar state-id stack context-hash)
  (let* ((cache (parser-direct-decisions grammar))
         (entry (cache-get-or-compute
                 cache (cons state-id context-hash)
                 (lambda ()
                   (cons stack
                         (or (direct-lookahead-table
                              grammar (aref (parser-states grammar) state-id)
                              stack)
                             :unavailable))))))
    (if (equal stack (car entry))
        (cdr entry)
        ;; The rolling hash is only a filter; collisions retain exact keys.
        (cache-get-or-compute
         cache (flat-cache-key state-id stack)
         (lambda ()
           (or (direct-lookahead-table grammar
                                       (aref (parser-states grammar) state-id)
                                       stack)
               :unavailable))))))

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
                        'vector))
         (input (if (eq channels :all)
                    lexed
                    (remove-if-not (lambda (token)
                                     (member (token-channel token) channels
                                             :test #'equal))
                                   lexed)))
         (position 0)
         (state-id (gethash start (parser-starts grammar)))
         (stack nil)
         (context-hash 0)
         (frames (list (vector start 0 nil 0)))
         (pending nil)
         (recoveries nil)
         (automatic-insert-position -1)
         (automatic-insert-count 0))
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
                      (table (if (eq choice :contextual)
                                 (contextual-direct-lookahead
                                  grammar state-id stack context-hash)
                                 choice))
                      (direct (and (hash-table-p table) (has-token-p)
                                   (gethash (token-key (current-value)) table))))
                 (if direct
                     (1- direct)
                     (if pending
                         (predict grammar state-id stack (remaining-values) 0)
                         (predict grammar state-id stack input position)))))
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
                            (invoke-restart 'insert-tokens))))))))
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
                      (setf context-hash (aref frame 3))
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
                                     context-hash)
                             frames)
                       (setf context-hash
                             (logand #xffffffff
                                     (+ (transition-target edge)
                                        (* 65599 context-hash))))
                       (push (transition-target edge) stack)
                       (unless (eq tree-builder :none)
                         (parse-rule-enter
                          tree-builder
                          (visible-rule grammar (transition-value edge)) position))
                       (setf state-id (gethash (transition-value edge)
                                               (parser-starts grammar))))
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
