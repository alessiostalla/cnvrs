(defpackage #:cnvrs
  (:use #:cl)
  (:shadow #:parse-error)
  (:export #:compile-grammar #:compile-lexer #:parse #:grammar-error #:parse-error
           #:lexical-error #:lexical-error-position #:lexical-error-character
           #:make-lexeme #:lexeme-p #:lexeme-kind #:lexeme-text
           #:lexeme-start #:lexeme-end
           #:parse-error-position #:parse-error-token #:parse-error-expected
           #:mismatched-token #:no-viable-alternative #:unexpected-input
           #:parse-error-rule #:+end-of-input+
           #:insert-tokens #:delete-tokens
           #:choose-alternative
           #:discard-input #:recovery-p #:recovery-action #:recovery-condition
           #:recovery-token #:inserted-token-p #:inserted-token-expected
           #:inserted-token-value #:inserted-token-position
           #:node-rule #:node-children #:node-start #:node-end))

(in-package #:cnvrs)

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
(defstruct lexeme kind text start end)
(defun token-key (token)
  (if (lexeme-p token) (lexeme-kind token) token))
(defstruct inserted-token expected position)
(defun inserted-token-value (token)
  (inserted-token-expected token))
(defstruct recovery action condition token)
(defstruct transition kind target value)
(defstruct state id (edges nil) stop-rule exit-alternative)
(defstruct configuration state stack alternative)
(defstruct dfa-state configurations alternatives accepted (edges (make-hash-table :test 'equal)))
(defstruct grammar states starts stops start-rule lexer
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
       (setf (state-exit-alternative (aref (grammar-states grammar) entry)) 1)
       (add-edge grammar entry :epsilon branch)
       (add-edge grammar entry :epsilon exit)
       (compile-expression grammar (second expression) branch exit)))
    (:star
     (let ((branch (new-state grammar)) (body-end (new-state grammar)))
       (setf (state-exit-alternative (aref (grammar-states grammar) entry)) 1)
       (add-edge grammar entry :epsilon branch)
       (add-edge grammar entry :epsilon exit)
       (compile-expression grammar (second expression) branch body-end)
       (add-edge grammar body-end :epsilon entry)))
    (:plus
     (let ((loop-state (new-state grammar)))
       (compile-expression grammar (second expression) entry loop-state)
       (compile-expression grammar (list '* (second expression)) loop-state exit)))))

(defun compile-grammar (definitions &key start lexer)
  "Compile Lisp-form rule definitions into an in-memory parser.
DEFINITIONS is a list of (name expression) pairs. Expressions use
(AND ...), (OR ...), (* x), (+ x), (? x), and (TOKEN value).
Bare symbols name rules; other atoms are literal tokens. LEXER, when
supplied, maps source input to tokens before parsing."
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
                                 :start-rule start :lexer lexer)))
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
  (multiple-value-bind (cached present) (gethash (token-key token) (dfa-state-edges dfa))
    (if present cached
        (setf (gethash (token-key token) (dfa-state-edges dfa))
              (dfa-state-for grammar
                             (loop for configuration in (dfa-state-configurations dfa)
                                   for state = (aref (grammar-states grammar)
                                                     (configuration-state configuration))
                                   append (loop for edge in (state-edges state)
                                                when (and (eq (transition-kind edge) :token)
                                                          (equal (token-key token) (transition-value edge)))
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
                      (let ((exit (state-exit-alternative
                                   (aref (grammar-states grammar) state-id))))
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

(defun possible-tokens (grammar configurations)
  (remove-duplicates
   (loop for configuration in (closure grammar configurations)
         for state = (aref (grammar-states grammar)
                           (configuration-state configuration))
         append (loop for edge in (state-edges state)
                      when (eq (transition-kind edge) :token)
                        collect (transition-value edge)))
   :test #'equal))

(defun parse (grammar tokens &key (start (grammar-start-rule grammar)) recover
                              (lexer (grammar-lexer grammar)))
  "Parse TOKENS, returning a NODE and a list of RECOVERY records.
Strict parsing is the default. LEXER, when supplied, maps the source to a
token sequence before parsing. With RECOVER true, single-token deletion,
insertion, and choice resynchronization are attempted. Handlers may invoke
the restarts at each error site to make a different local repair."
  (unless (gethash start (grammar-starts grammar))
    (grammar-fail "Unknown start rule ~S" start))
  (let* ((input (coerce (if lexer (funcall (coerce lexer 'function) tokens) tokens)
                        'vector))
         (position 0)
         (state-id (gethash start (grammar-starts grammar)))
         (stack nil)
         (frames (list (list start 0 nil)))
         (pending nil)
         (recoveries nil)
         (automatic-insert-position -1)
         (automatic-insert-count 0))
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
               (if pending
                   (predict grammar state-id stack (remaining-values) 0)
                   (predict grammar state-id stack input position)))
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
                                   (length (grammar-states grammar)))
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
                      (when (has-token-p)
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
                      (return (values completed (nreverse recoveries)))))))
            (unless stop
              (let* ((edges (state-edges state))
                     (index (if (= (length edges) 1)
                                0 (predict-current))))
                (when (null index)
                  (let ((condition
                          (make-condition
                           'no-viable-alternative :position position
                           :token (current-value)
                           :rule (first (first frames))
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
                       (push (transition-target edge) stack)
                       (push (list (transition-value edge) position nil) frames)
                       (setf state-id (gethash (transition-value edge)
                                               (grammar-starts grammar))))
                      (:token
                       (let ((expected (transition-value edge)))
                         (if (and (has-token-p)
                                  (equal (token-key (current-value)) expected))
                             (progn
                               (push (consume-current) (third (first frames)))
                               (setf state-id (transition-target edge)))
                             (let ((condition
                                     (make-condition
                                      'mismatched-token :position position
                                      :token (current-value)
                                      :expected expected
                                      :rule (first (first frames))
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
