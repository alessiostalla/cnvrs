(defpackage #:cnvrs
  (:use #:cl)
  (:shadow #:parse-error)
  (:export #:compile-grammar #:parse #:grammar-error #:parse-error
           #:parse-error-position #:parse-error-token #:parse-error-expected
           #:node-rule #:node-children #:node-start #:node-end))

(in-package #:cnvrs)

(define-condition grammar-error (error)
  ((message :initarg :message :reader grammar-error-message))
  (:report (lambda (condition stream)
             (write-string (grammar-error-message condition) stream))))

(define-condition parse-error (error)
  ((position :initarg :position :reader parse-error-position)
   (token :initarg :token :reader parse-error-token)
   (expected :initarg :expected :reader parse-error-expected))
  (:report (lambda (condition stream)
             (format stream "Parse error at token ~D (~S); expected ~S"
                     (parse-error-position condition)
                     (parse-error-token condition)
                     (parse-error-expected condition)))))

(defstruct node rule children start end)
(defstruct transition kind target value)
(defstruct state id (edges nil) stop-rule)
(defstruct configuration state stack alternative)
(defstruct dfa-state configurations alternatives accepted (edges (make-hash-table :test 'equal)))
(defstruct grammar states starts stops start-rule
  (decisions (make-hash-table))
  (sll-decisions (make-hash-table)))

(defun grammar-fail (control &rest arguments)
  (error 'grammar-error :message (apply #'format nil control arguments)))

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

(defun new-state (grammar &optional stop-rule)
  (let* ((states (grammar-states grammar))
         (id (length states)))
    (vector-push-extend (make-state :id id :stop-rule stop-rule) states)
    id))

(defun add-edge (grammar from kind target &optional value)
  (let ((state (aref (grammar-states grammar) from)))
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
       (add-edge grammar entry :epsilon branch)
       (add-edge grammar entry :epsilon exit)
       (compile-expression grammar (second expression) branch exit)))
    (:star
     (let ((branch (new-state grammar)) (body-end (new-state grammar)))
       (add-edge grammar entry :epsilon branch)
       (add-edge grammar entry :epsilon exit)
       (compile-expression grammar (second expression) branch body-end)
       (add-edge grammar body-end :epsilon entry)))
    (:plus
     (let ((loop-state (new-state grammar)))
       (compile-expression grammar (second expression) entry loop-state)
       (compile-expression grammar (list '* (second expression)) loop-state exit)))))

(defun compile-grammar (definitions &key start)
  "Compile Lisp-form rule definitions into an in-memory parser.
DEFINITIONS is a list of (name expression) pairs. Expressions use
(AND ...), (OR ...), (* x), (+ x), (? x), and (TOKEN value).
Bare symbols name rules; other atoms are literal tokens."
  (unless (and (listp definitions) definitions)
    (grammar-fail "Expected a nonempty list of rule definitions"))
  (let ((names (make-hash-table :test 'eq))
        (nullable (make-hash-table :test 'eq)))
    (dolist (definition definitions)
      (unless (and (listp definition) (= (length definition) 2)
                   (symbolp (first definition)) (not (keywordp (first definition))))
        (grammar-fail "Expected (rule-name expression), got ~S" definition))
      (when (gethash (first definition) names)
        (grammar-fail "Duplicate rule ~S" (first definition)))
      (setf (gethash (first definition) names) t))
    (setf start (or start (first (first definitions))))
    (unless (gethash start names) (grammar-fail "Unknown start rule ~S" start))
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
    (let ((grammar (make-grammar :states (make-array 0 :adjustable t :fill-pointer 0)
                                 :starts (make-hash-table :test 'eq)
                                 :stops (make-hash-table :test 'eq)
                                 :start-rule start)))
      (dolist (definition definitions)
        (setf (gethash (first definition) (grammar-starts grammar)) (new-state grammar)
              (gethash (first definition) (grammar-stops grammar))
              (new-state grammar (first definition))))
      (dolist (definition definitions)
        (compile-expression grammar (second definition)
                            (gethash (first definition) (grammar-starts grammar))
                            (gethash (first definition) (grammar-stops grammar))))
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
          (let* ((state (aref (grammar-states grammar)
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
                                             (grammar-starts grammar))
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
                                for state = (aref (grammar-states grammar)
                                                  (configuration-state configuration))
                                when (and (state-stop-rule state)
                                          (null (configuration-stack configuration)))
                                  collect (configuration-alternative configuration))) #'<)))
    (make-dfa-state :configurations closed
                    :alternatives alternatives :accepted accepted)))

(defun advance-dfa (grammar dfa token)
  (multiple-value-bind (cached present) (gethash token (dfa-state-edges dfa))
    (if present cached
        (setf (gethash token (dfa-state-edges dfa))
              (dfa-state-for grammar
                             (loop for configuration in (dfa-state-configurations dfa)
                                   for state = (aref (grammar-states grammar)
                                                     (configuration-state configuration))
                                   append (loop for edge in (state-edges state)
                                                when (and (eq (transition-kind edge) :token)
                                                          (equal token (transition-value edge)))
                                                  collect (make-configuration
                                                           :state (transition-target edge)
                                                           :stack (configuration-stack configuration)
                                                           :alternative
                                                           (configuration-alternative configuration)))))))))

(defun predict-full-context (grammar state-id stack tokens position)
  (let* ((cache (or (gethash state-id (grammar-decisions grammar))
                    (setf (gethash state-id (grammar-decisions grammar))
                          (make-hash-table :test 'equal))))
         (dfa (or (gethash stack cache)
                  (setf (gethash stack cache)
                        (dfa-state-for grammar
                                       (loop for edge in (state-edges
                                                          (aref (grammar-states grammar) state-id))
                                             for alternative from 0
                                             collect (configuration-after-edge
                                                      grammar edge stack alternative))))))
         (length (length tokens)))
    (loop
      (let ((alternatives (dfa-state-alternatives dfa)))
        (when (= (length alternatives) 1)
          (return (first alternatives)))
        (when (or (null alternatives) (= position length))
          (return (or (first (dfa-state-accepted dfa))
                      (first alternatives)
                      0))))
      (setf dfa (advance-dfa grammar dfa (aref tokens position)))
      (incf position))))

(defun predict (grammar state-id stack tokens position)
  ;; The first DFA omits the caller's return stack. If an alternative can
  ;; finish in that shortened context while another remains viable, the
  ;; result depends on the caller and prediction retries with the full stack.
  (let* ((start-position position)
         (cache (grammar-sll-decisions grammar))
         (dfa (or (gethash state-id cache)
                  (setf (gethash state-id cache)
                        (dfa-state-for grammar
                                       (loop for edge in (state-edges
                                                          (aref (grammar-states grammar) state-id))
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
                                               (grammar-starts grammar))
                               :stack (cons (transition-target edge) stack)
                               :alternative alternative))
    (otherwise (make-configuration :state (transition-target edge)
                                   :stack stack :alternative alternative))))

(defun parse (grammar tokens &key (start (grammar-start-rule grammar)))
  "Parse a sequence of tokens, returning a tree of NODE structs.
Each rule call creates a node. Every input token must be consumed."
  (unless (gethash start (grammar-starts grammar))
    (grammar-fail "Unknown start rule ~S" start))
  (let* ((input (coerce tokens 'vector))
         (position 0)
         (state-id (gethash start (grammar-starts grammar)))
         (stack nil)
         (frames (list (list start 0 nil))))
    (labels ((fail (expected)
               (error 'parse-error :position position
                      :token (if (< position (length input))
                                 (aref input position) :eof)
                      :expected expected)))
      (loop
        (let* ((state (aref (grammar-states grammar) state-id))
               (stop (state-stop-rule state)))
          (when stop
            (let* ((frame (pop frames))
                   (completed (make-node :rule (first frame)
                                         :start (second frame) :end position
                                         :children (nreverse (third frame)))))
              (if stack
                  (progn
                    (push completed (third (first frames)))
                    (setf state-id (pop stack)))
                  (progn
                    (unless (= position (length input)) (fail :eof))
                    (return completed)))))
          (unless stop
            (let* ((edges (state-edges state))
                   (edge (if (= (length edges) 1)
                             (first edges)
                             (nth (predict grammar state-id stack input position) edges))))
              (unless edge (fail :transition))
              (case (transition-kind edge)
                (:epsilon (setf state-id (transition-target edge)))
                (:call
                 (push (transition-target edge) stack)
                 (push (list (transition-value edge) position nil) frames)
                 (setf state-id (gethash (transition-value edge)
                                         (grammar-starts grammar))))
                (:token
                 (unless (and (< position (length input))
                              (equal (aref input position) (transition-value edge)))
                   (fail (transition-value edge)))
                 (push (aref input position) (third (first frames)))
                 (incf position)
                 (setf state-id (transition-target edge)))))))))))
