(in-package #:cnvrs)

;; Only immutable grammar data is written to a FASL. Runtime caches and the
;; closures that capture them are created afresh when the FASL is loaded.
(defun frozen-table (table)
  (when table
    (list (hash-table-test table)
          (loop for key being the hash-keys of table using (hash-value value)
                collect (cons key value)))))

(defun thawed-table (data)
  (when data
    (let ((table (make-hash-table :test (first data))))
      (dolist (entry (second data) table)
        (setf (gethash (car entry) table) (cdr entry))))))

(defun frozen-states (states parser-p)
  (loop for state across states
        collect (append
                 (list (graph-state-id state)
                       (loop for edge in (graph-state-edges state)
                             collect (list (transition-kind edge)
                                           (transition-target edge)
                                           (if (and parser-p (eq (transition-value edge) +end-of-input+))
                                               '%frozen-end-of-input%
                                               (if (and parser-p (eq (transition-kind edge) :token-set))
                                                   (subst '%frozen-end-of-input% +end-of-input+ (transition-value edge))
                                                   (transition-value edge))))))
                 (if parser-p
                     (list (state-stop-rule state)
                           (state-exit-alternative state)
                           (state-repetition-p state)
                           (if (hash-table-p (state-direct-lookahead state))
                               (list :table (frozen-table (state-direct-lookahead state)))
                               (state-direct-lookahead state))
                           (list (state-kind state) (state-rule-index state)
                                 (state-end-state state) (state-loop-back state) (state-decision state)
                                 (state-precedence-rule-p state) (state-precedence-decision-p state)
                                 (state-call-precedence state) (state-events state)))
                     (list (lx-state-accept state))))))

(defun thawed-states (data parser-p)
  (coerce
   (loop for entry in data
         collect
         (destructuring-bind (id edges &rest payload) entry
           (let ((state (if parser-p
                            (make-state :id id :stop-rule (first payload)
                                        :exit-alternative (second payload)
                                        :repetition-p (third payload)
                                        :direct-lookahead
                                        (let ((choice (fourth payload)))
                                          (if (and (consp choice)
                                                   (eq (first choice) :table))
                                              (thawed-table (second choice))
                                              choice)))
                            (make-lx-state :id id :accept (first payload)))))
             (when parser-p
               (destructuring-bind (kind rule end back decision lr pd precedence events) (fifth payload)
                 (setf (state-kind state) kind (state-rule-index state) rule
                       (state-end-state state) end (state-loop-back state) back
                       (state-decision state) decision (state-precedence-rule-p state) lr
                       (state-precedence-decision-p state) pd (state-call-precedence state) precedence
                       (state-events state) events)))
             (setf (graph-state-edges state)
                   (loop for (kind target value) in edges
                         collect (make-transition :kind kind :target target
                                                  :value (if (and parser-p (eq value '%frozen-end-of-input%))
                                                             +end-of-input+
                                                             (if (and parser-p (eq kind :token-set))
                                                                 (subst +end-of-input+ '%frozen-end-of-input% value) value)))))
             state)))
   'vector))

(defun frozen-parser (parser)
  (list :states (frozen-states (parser-states parser) t)
        :starts (frozen-table (parser-starts parser))
        :stops (frozen-table (parser-stops parser))
        :rewrites (frozen-table (parser-rewrites parser))
        :default-rule (parser-default-rule parser)
        :has-negated-tokens (not (null (parser-has-negated-tokens parser)))
        :context-shift (parser-context-shift parser)
        :semantic-rules
        (when (parser-semantic-rules parser)
          (loop for name being the hash-keys of (parser-semantic-rules parser)
                  using (hash-value expression)
                collect (cons name (parser-expr-source expression))))))

(defun thawed-parser (data lexer tree-builder full-context-strategy
                     cache-backend metadata runner node-runner)
  (let ((parser
          (make-parser
           :states (thawed-states (getf data :states) t)
           :starts (thawed-table (getf data :starts))
           :stops (thawed-table (getf data :stops))
           :rewrites (thawed-table (getf data :rewrites))
           :default-rule (getf data :default-rule)
           :has-negated-tokens (getf data :has-negated-tokens)
           :context-shift (getf data :context-shift)
           :lexer lexer :tree-builder tree-builder
           :full-context-strategy full-context-strategy
           :full-context-start (resolve-full-context-strategy
                                full-context-strategy)
           :cache-backend cache-backend :metadata metadata
           :decisions (make-cache cache-backend)
           :sll-decisions (make-cache cache-backend)
           :direct-decisions (make-cache cache-backend)
           :contexts (make-cache cache-backend)
           :runner runner :node-runner node-runner)))
    (initialize-token-index parser)
    (when (getf data :semantic-rules)
      (setf (parser-semantic-rules parser) (make-hash-table :test 'eq))
      (dolist (entry (getf data :semantic-rules))
        (setf (gethash (car entry) (parser-semantic-rules parser))
              (parser-expression-from-form (cdr entry)))))
    (when (compiled-lexer-p lexer)
      (check-lexer-kind-overlap (parser-starts parser) lexer))
    parser))

(defun frozen-lexer (lexer)
  (list :states (frozen-states (compiled-lexer-states lexer) nil)
        :mode-starts (frozen-table (compiled-lexer-mode-starts lexer))
        :kinds (coerce (compiled-lexer-kinds lexer) 'list)
        :skips (coerce (compiled-lexer-skips lexer) 'list)
        :channels (coerce (compiled-lexer-channels lexer) 'list)
        :push-modes (coerce (compiled-lexer-push-modes lexer) 'list)
        :pop-modes (coerce (compiled-lexer-pop-modes lexer) 'list)
        :set-modes (coerce (compiled-lexer-set-modes lexer) 'list)))

(defun thawed-lexer (data ordered-rules cache-backend metadata)
  (initialize-compiled-lexer
   (make-compiled-lexer
    :states (thawed-states (getf data :states) nil)
    :mode-starts (thawed-table (getf data :mode-starts))
    :kinds (coerce (getf data :kinds) 'vector)
    :skips (coerce (getf data :skips) 'vector)
    :channels (coerce (getf data :channels) 'vector)
    :push-modes (coerce (getf data :push-modes) 'vector)
    :pop-modes (coerce (getf data :pop-modes) 'vector)
    :set-modes (coerce (getf data :set-modes) 'vector)
    :ordered-rules ordered-rules
    :cache-backend cache-backend :metadata metadata
    :cache (make-cache cache-backend))))

(defun lexer-matcher-form (expression)
  "Emit a compiled closure for the ordered matcher of EXPRESSION."
  (typecase expression
    (lx-reference-expr
     `(let ((name ',(lx-expr-name expression)))
        (lambda (source at next)
          (unless (member (cons name at) *lx-reference-stack* :test #'equal)
            (let ((outer *lx-suppress-actions*)
                  (*lx-reference-stack*
                    (cons (cons name at) *lx-reference-stack*)))
              (let ((*lx-suppress-actions* t))
                (funcall (gethash name matchers) source at
                         (lambda (end)
                           (let ((*lx-suppress-actions* outer))
                             (funcall next end))))))))))
    (lx-literal-expr
     `(let ((literal ,(lx-expr-text expression)))
        (lambda (source at next)
          (let ((end (+ at (length literal))))
            (and (<= end (length source))
                 (string= literal source :start2 at :end2 end)
                 (funcall next end))))))
    (lx-range-expr
     `(lambda (source at next)
        (and (< at (length source))
             (char<= ,(lx-expr-lower expression) (char source at)
                     ,(lx-expr-upper expression))
             (funcall next (1+ at)))))
    (lx-one-of-expr
     `(let ((items ',(lx-expr-items expression)))
        (lambda (source at next)
          (and (< at (length source))
               (find (char source at) items)
               (funcall next (1+ at))))))
    (lx-not-one-of-expr
     `(let ((items ',(lx-expr-items expression)))
        (lambda (source at next)
          (and (< at (length source))
               (not (lx-char-excluded-p (char source at) items))
               (funcall next (1+ at))))))
    (lx-any-expr
     `(lambda (source at next)
        (and (< at (length source)) (funcall next (1+ at)))))
    (lx-predicate-expr
     `(let ((callback ',(lx-expr-callback expression)))
        (lambda (source at next)
          (and (semantic-call callback source at) (funcall next at)))))
    (lx-action-expr
     `(let ((callback ',(lx-expr-callback expression)))
        (lambda (source at next)
          (let ((end (funcall next at)))
            (when (and end (not *lx-suppress-actions*))
              (push (cons callback at) *lx-action-events*))
            end))))
    (lx-choice-expr
     `(let ((parts (list ,@(mapcar #'lexer-matcher-form
                                 (lx-expr-parts expression)))))
        (lambda (source at next)
          (if *lx-after-nongreedy*
              (some (lambda (part) (funcall part source at next)) parts)
              (let ((best nil) (best-events nil)
                    (baseline *lx-action-events*))
                (dolist (part parts)
                  (setf *lx-action-events* baseline)
                  (let ((end (funcall part source at next)))
                    (when (and end (or (null best) (> end best)))
                      (setf best end best-events *lx-action-events*))))
                (setf *lx-action-events* (if best best-events baseline))
                best)))))
    (lx-sequence-expr
     `(let ((parts (list ,@(mapcar #'lexer-matcher-form
                                 (lx-expr-parts expression)))))
        (lambda (source at next)
          (labels ((match-parts (tail position)
                     (if (null tail)
                         (funcall next position)
                         (funcall (first tail) source position
                                  (lambda (end)
                                    (match-parts (rest tail) end))))))
            (match-parts parts at)))))
    (lx-lazy-plus-expr
     `(let* ((body ,(lexer-matcher-form (lx-expr-body expression)))
             (repeat (lx-repeat-matcher body t)))
        (lambda (source at next)
          (funcall body source at
                   (lambda (end) (funcall repeat source end next))))))
    (lx-plus-expr
     `(let* ((body ,(lexer-matcher-form (lx-expr-body expression)))
             (repeat (lx-repeat-matcher body nil)))
        (lambda (source at next)
          (funcall body source at
                   (lambda (end) (funcall repeat source end next))))))
    (lx-lazy-star-expr
     `(lx-repeat-matcher ,(lexer-matcher-form (lx-expr-body expression)) t))
    (lx-star-expr
     `(lx-repeat-matcher ,(lexer-matcher-form (lx-expr-body expression)) nil))
    (lx-lazy-optional-expr
     `(let ((body ,(lexer-matcher-form (lx-expr-body expression))))
        (lambda (source at next)
          (let ((*lx-after-nongreedy* t))
            (or (funcall next at) (funcall body source at next))))))
    (lx-optional-expr
     `(let ((body ,(lexer-matcher-form (lx-expr-body expression))))
        (lambda (source at next)
          (or (funcall body source at next) (funcall next at)))))
    (t (grammar-fail "Cannot emit lexer matcher for ~S" expression))))

(defun ordered-lexer-form (definitions ordered-rules)
  (when ordered-rules
    (let ((patterns (make-hash-table :test 'eq)))
      (dolist (definition definitions)
        (setf (gethash (first definition) patterns)
              (lx-expression-from-form (second definition))))
      `(let ((matchers (make-hash-table :test 'eq)))
         ,@(loop for definition in definitions
                 collect `(setf (gethash ',(first definition) matchers)
                                ,(lexer-matcher-form
                                  (gethash (first definition) patterns))))
         (list
          ,@(loop for entry in ordered-rules
                  for mode = (first entry)
                  for index = (second entry)
                  for name = (first (nth index definitions))
                  collect `(list ',mode ,index
                                   (lambda (source position)
                                     (let ((*lx-after-nongreedy* nil)
                                           (*lx-action-events* nil)
                                           (*lx-reference-stack*
                                             (list (cons ',name position))))
                                       (let ((end (funcall (gethash ',name matchers)
                                                           source position
                                                           #'identity)))
                                         (values end *lx-action-events*)))))))))))
