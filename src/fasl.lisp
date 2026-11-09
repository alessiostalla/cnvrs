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
                                 (state-call-precedence state) (state-events state) (state-non-greedy-p state)))
                     (list (lx-state-accept state))))))

(defun thawed-states (data parser-p)
  (coerce
   (loop for entry in data
         collect
         (destructuring-bind (id edges &rest payload) entry
           (let ((state (if parser-p
                            (funcall (if (eq parser-p :lexer) #'make-lx-state #'make-state) :id id :stop-rule (first payload)
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
               (destructuring-bind (kind rule end back decision lr pd precedence events non-greedy) (fifth payload)
                 (setf (state-kind state) kind (state-rule-index state) rule
                       (state-end-state state) end (state-loop-back state) back
                       (state-decision state) decision (state-precedence-rule-p state) lr
                       (state-precedence-decision-p state) pd (state-call-precedence state) precedence
                       (state-events state) events (state-non-greedy-p state) non-greedy)))
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
        :semantic-rules
        (when (parser-semantic-rules parser)
          (loop for name being the hash-keys of (parser-semantic-rules parser)
                  using (hash-value expression)
                collect (cons name (parser-expr-source expression))))))

(defun thawed-parser (data lexer tree-builder full-context-strategy
                     cache-backend metadata runner node-runner)
  (resolve-full-context-strategy full-context-strategy)
  (let ((parser
          (make-parser
           :states (thawed-states (getf data :states) t)
           :starts (thawed-table (getf data :starts))
           :stops (thawed-table (getf data :stops))
           :rewrites (thawed-table (getf data :rewrites))
           :default-rule (getf data :default-rule)
           :has-negated-tokens (getf data :has-negated-tokens)
           :lexer lexer :tree-builder tree-builder
           :full-context-strategy full-context-strategy
           :cache-backend cache-backend :metadata metadata
           :decisions (make-cache cache-backend)
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
  (list :states (frozen-states (compiled-lexer-states lexer) t)
        :mode-starts (frozen-table (compiled-lexer-mode-starts lexer))
        :rule-starts (frozen-table (compiled-lexer-rule-starts lexer))
        :modes (coerce (compiled-lexer-modes lexer) 'list)
        :actions (coerce (compiled-lexer-actions lexer) 'list)
        :predicates (frozen-table (compiled-lexer-predicates lexer))
        :kinds (coerce (compiled-lexer-kinds lexer) 'list)
        :skips (coerce (compiled-lexer-skips lexer) 'list)
        :channels (coerce (compiled-lexer-channels lexer) 'list)
        :push-modes (coerce (compiled-lexer-push-modes lexer) 'list)
        :pop-modes (coerce (compiled-lexer-pop-modes lexer) 'list)
        :set-modes (coerce (compiled-lexer-set-modes lexer) 'list)))
(defun thawed-lexer (data cache-backend metadata)
  (initialize-compiled-lexer
   (make-compiled-lexer
    :states (thawed-states (getf data :states) :lexer)
    :mode-starts (thawed-table (getf data :mode-starts))
    :rule-starts (thawed-table (getf data :rule-starts))
    :modes (coerce (getf data :modes) 'vector)
    :actions (coerce (getf data :actions) 'vector)
    :predicates (thawed-table (getf data :predicates))
    :kinds (coerce (getf data :kinds) 'vector)
    :skips (coerce (getf data :skips) 'vector)
    :channels (coerce (getf data :channels) 'vector)
    :push-modes (coerce (getf data :push-modes) 'vector)
    :pop-modes (coerce (getf data :pop-modes) 'vector)
    :set-modes (coerce (getf data :set-modes) 'vector)
    :cache-backend cache-backend :metadata metadata :cache (make-cache cache-backend))))
