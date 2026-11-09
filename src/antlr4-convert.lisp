(in-package #:cnvrs/antlr4)

#+sbcl (declaim (optimize (speed 3) (safety 1) (debug 0)
                           (space 0) (compilation-speed 0)))

;; The ANTLR syntax tree is kept separate from the CNVRS grammar definition.
;; Conversion deliberately rejects constructs whose semantics CNVRS cannot keep.
(defun conversion-error (node control &rest arguments)
  (error 'cnvrs:grammar-error :message
         (format nil "ANTLR4 ~A: ~A" (if (cnvrs:node-p node)
                                        (cnvrs:node-rule node) node)
                 (apply #'format nil control arguments))))

(defvar *semantic-callbacks* nil)
(defvar *antlr-parser-package* nil)
(defvar *antlr-lexer-package* nil)
(defvar *token-vocabulary* nil)

(defun action-expression (node predicate-p)
  (let* ((source (cnvrs:lexeme-text (first-token node)))
         (callback (if (hash-table-p *semantic-callbacks*)
                       (gethash source *semantic-callbacks*)
                       (cdr (assoc source *semantic-callbacks* :test #'string=)))))
    (unless callback
      (conversion-error node "no callback supplied for action block ~S" source))
    (unless (or (functionp callback)
                (and (symbolp callback) (not (keywordp callback))))
      (conversion-error node "callback for ~S must be a function or function name"
                        source))
    (list (if predicate-p 'predicate 'action) callback)))

(defun child-nodes (node &optional rule)
  (remove-if-not (lambda (child)
                   (and (cnvrs:node-p child)
                        (or (null rule) (eq (cnvrs:node-rule child) rule))))
                 (cnvrs:node-children node)))

(defun first-node (node rule)
  (first (child-nodes node rule)))

(defun first-token (node)
  (labels ((visit (value)
             (if (cnvrs:node-p value)
                 (some #'visit (cnvrs:node-children value))
                 (and (cnvrs:lexeme-p value) value))))
    (visit node)))

(defun tokens-of (node)
  (remove-if-not #'cnvrs:lexeme-p (cnvrs:node-children node)))

(defun token-of-kind (node kind)
  (find kind (tokens-of node) :key #'cnvrs:lexeme-kind))

(defun antlr-name (node &optional token-p)
  (let ((name (cnvrs:lexeme-text (first-token node))))
    (let ((symbol (intern (string-upcase name)
                          (if token-p *antlr-lexer-package* *antlr-parser-package*))))
      (when (and token-p *token-vocabulary*
                 (not (find symbol *token-vocabulary* :key #'first)))
        (conversion-error node "unknown token ~A in tokenVocab" name))
      symbol)))

(defun antlr-char (text position node)
  (if (char/= (char text position) #\\)
      (values (char text position) (1+ position))
      (let ((escape (char text (1+ position))))
        (case escape
          (#\n (values #\Newline (+ position 2)))
          (#\r (values #\Return (+ position 2)))
          (#\t (values #\Tab (+ position 2)))
          (#\b (values #\Backspace (+ position 2)))
          (#\f (values #\Page (+ position 2)))
          (#\u (let* ((start (+ position 2))
                      (braced (and (< start (length text))
                                   (char= (char text start) #\{)))
                      (digits-start (if braced (1+ start) start))
                      (digits-end (if braced (position #\} text :start digits-start)
                                      (+ start 4))))
                 (unless (and digits-end (<= digits-end (length text)))
                   (conversion-error node "invalid Unicode escape ~S" text))
                 (let ((code (ignore-errors
                               (parse-integer text :start digits-start
                                              :end digits-end :radix 16))))
                   (unless (and code (code-char code))
                     (conversion-error node "invalid Unicode escape ~S" text))
                   (values (code-char code) (if braced (1+ digits-end) digits-end)))))
          (otherwise
           (unless (find escape "\\'\"-]" )
             (conversion-error node "invalid escape in ~S" text))
           (values escape (+ position 2)))))))

(defun antlr-string (node)
  (let* ((text (cnvrs:lexeme-text (if (cnvrs:lexeme-p node) node
                                     (first-token node))))
         (end (1- (length text))))
    (with-output-to-string (output)
      (loop with position = 1 while (< position end) do
        (multiple-value-bind (character next) (antlr-char text position node)
          (write-char character output)
          (setf position next))))))

(defun unicode-property-ranges (name node)
  (let* ((key (string-downcase (substitute #\_ #\- name)))
         (canonical (or (gethash key cnvrs::*unicode-aliases*) key))
         (ranges (gethash canonical cnvrs::*unicode-properties*)))
    (unless ranges (conversion-error node "unknown Unicode property ~S" name))
    ranges))
(defvar *lexer-case-insensitive* nil)
(defun charset-expression (node &optional invert)
  (let* ((text (cnvrs:lexeme-text (first-token node)))
         (end (1- (length text))) (at 1) (ranges nil) (scalars nil))
    (labels ((element ()
               (if (and (< (+ at 2) end) (char= (char text at) #\\)
                        (find (char text (1+ at)) "pP") (char= (char text (+ at 2)) #\{))
                   (let* ((inverted (char= (char text (1+ at)) #\P))
                          (close (position #\} text :start (+ at 3))))
                     (unless close (conversion-error node "unterminated Unicode property"))
                     (let ((set (unicode-property-ranges (subseq text (+ at 3) close) node)))
                       (setf at (1+ close))
                       (values (if inverted (cnvrs::complement-character-intervals set) set) nil)))
                   (multiple-value-bind (character next) (antlr-char text at node)
                     (setf at next)
                     (let ((code (char-code character))) (values (list (list code code)) code))))))
      (loop while (< at end) do
        (multiple-value-bind (set scalar) (element)
          (if (and scalar (< (1+ at) end) (char= (char text at) #\-))
              (progn
                (incf at)
                (multiple-value-bind (right-set right) (element)
                  (declare (ignore right-set))
                  (unless (and right (<= scalar right)) (conversion-error node "invalid character range"))
                  (push (list scalar right) scalars)))
              (if scalar (setf scalars (append set scalars))
                  (setf ranges (append set ranges)))))))
    (unless (or ranges scalars) (conversion-error node "empty character set"))
    (list 'cnvrs::codepoint-set (cnvrs::normalize-character-intervals ranges) invert
          scalars)))

(defun sequence-form (parts)
  (cond ((null parts) '(and))
        ((null (rest parts)) (first parts))
        (t (cons 'and parts))))

(defun choice-form (parts)
  (if (rest parts) (cons 'or parts) (first parts)))

(defun suffix-form (node expression &optional lexer-p)
  (let ((suffix (first-token node)))
    (when (and (not lexer-p) (> (length (tokens-of node)) 1))
      (conversion-error node "nongreedy suffix is not supported"))
    (list (ecase (cnvrs:lexeme-kind suffix)
            (:question (if (> (length (tokens-of node)) 1) '?? '?))
            (:star (if (> (length (tokens-of node)) 1) '*? '*))
            (:plus (if (> (length (tokens-of node)) 1) '+? '+)))
          expression)))

(defvar *implicit-literals*)

(defun lexer-literal-body (expression)
  (if (and (consp expression) (member (first expression) '(cnvrs::lexer-commands cnvrs::lexer-case)))
      (lexer-literal-body (second expression)) expression))

(defun implicit-token (node)
  (let* ((literal (antlr-string node))
         (entry (assoc literal *implicit-literals* :test #'string=)))
    (when *token-vocabulary*
      (let ((matches (remove-if-not
                      (lambda (rule)
                        (and (stringp (lexer-literal-body (second rule)))
                             (string= literal (lexer-literal-body (second rule)))
                             (not (eq (sixth rule) :cnvrs-fragment))))
                      *token-vocabulary*)))
        (unless (= (length matches) 1)
          (conversion-error node "literal ~S has ~D token aliases in tokenVocab"
                            literal (length matches)))
        (return-from implicit-token (caar matches))))
    (unless entry
      (setf entry (cons literal
                        (intern (format nil "ANTLR-LITERAL-~D"
                                        (length *implicit-literals*))
                                *antlr-lexer-package*)))
      (setf *implicit-literals* (append *implicit-literals* (list entry))))
    (cdr entry)))

(defun parser-associativity (options)
  (let* ((entries (child-nodes options 'element-option))
         (entry (first entries))
         (value (and entry (first-node entry 'qualified-identifier))))
    (unless (and (= (length entries) 1)
                 (string= (cnvrs:lexeme-text (first-token entry)) "assoc")
                 (token-of-kind entry :assign)
                 value
                 (= (length (child-nodes value 'identifier)) 1)
                 (member (cnvrs:lexeme-text (first-token value))
                         '("left" "right") :test #'string=))
      (conversion-error options
                        "only <assoc=left> or <assoc=right> is supported on parser alternatives"))
    (if (string= (cnvrs:lexeme-text (first-token value)) "right")
        :right :left)))

(defun parser-expression (node &optional allow-associativity)
  (case (cnvrs:node-rule node)
    (rule-alt-list
     (choice-form (mapcar #'parser-expression (child-nodes node 'labeled-alt))))
    (alt-list
     (choice-form (mapcar #'parser-expression (child-nodes node 'alternative))))
    (labeled-alt
     (let ((expression (parser-expression (first-node node 'alternative)
                                          allow-associativity))
           (label (first-node node 'identifier)))
       (if label (list 'alt-label (antlr-name label) expression)
           expression)))
    (alternative
     (let* ((options (first-node node 'element-options))
            (associativity (and options allow-associativity
                                (parser-associativity options)))
            (parts (mapcar #'parser-expression (child-nodes node 'element))))
       (when (and options (not allow-associativity))
         (conversion-error node "element options are not supported"))
       (setf parts (subst '(cnvrs:eof) :eof parts))
       (let ((expression (sequence-form parts)))
         (if (eq associativity :right)
             (list 'right expression)
             expression))))
    (element
     (when (first-node node 'action-block)
       (when (first-node node 'predicate-options)
         (conversion-error node "predicate options are not supported"))
       (return-from parser-expression
         (action-expression (first-node node 'action-block)
                            (not (null (token-of-kind node :question))))))
     (let* ((base (or (first-node node 'labeled-element)
                      (first-node node 'atom) (first-node node 'ebnf)))
            (expression (parser-expression base))
            (suffix (first-node node 'ebnf-suffix)))
       (if suffix (suffix-form suffix expression) expression)))
    (labeled-element
     (list 'label (antlr-name (first-node node 'identifier))
           (parser-expression (or (first-node node 'atom)
                                  (first-node node 'block)))))
    (ebnf
     (let ((expression (parser-expression (first-node node 'block)))
           (suffix (first-node node 'block-suffix)))
       (if suffix (suffix-form (first-node suffix 'ebnf-suffix) expression)
           expression)))
    (block
     (when (or (first-node node 'options-spec) (first-node node 'rule-action))
       (conversion-error node "block options and actions are not supported"))
     (let* ((expression (parser-expression (first-node node 'alt-list)))
            (suffix (first-node node 'block-suffix)))
       (if suffix (suffix-form (first-node suffix 'ebnf-suffix) expression)
           expression)))
    (atom
     (let ((child (first (child-nodes node))))
       (case (cnvrs:node-rule child)
         (terminal-def (parser-expression child))
         (rule-ref (parser-expression child))
         (not-set (parser-expression child))
         (wildcard
          (when (first-node child 'element-options)
            (conversion-error child "wildcard options are not supported"))
          '(cnvrs:any))
         (otherwise (conversion-error node "unsupported parser atom")))))
    (not-set
     (let* ((set (first (child-nodes node)))
            (elements (if (eq (cnvrs:node-rule set) 'block-set)
                          (child-nodes set 'set-element)
                          (list set))))
       (list 'not-token (mapcar #'parser-expression elements))))
    (set-element
     (when (first-node node 'element-options)
       (conversion-error node "element options are not supported"))
     (let ((token (first-token node)))
       (case (cnvrs:lexeme-kind token)
         (:token_ref (antlr-name node t))
         (:string_literal (implicit-token node))
         (otherwise
          (conversion-error node "parser negated sets require token names or literals")))))
    (rule-ref
     (when (or (first-node node 'arg-action-block)
               (first-node node 'element-options))
       (conversion-error node "rule arguments and element options are not supported"))
     (antlr-name node))
    (terminal-def
     (when (first-node node 'element-options)
       (conversion-error node "element options are not supported"))
     (let ((token (first-token node)))
       (case (cnvrs:lexeme-kind token)
         (:token_ref (if (string= (cnvrs:lexeme-text token) "EOF")
                         :eof (antlr-name node t)))
         (:string_literal (implicit-token node)))))
    (otherwise (conversion-error node "unsupported parser expression"))))

(defun lexer-set-items (node)
  (let ((range (first-node node 'character-range))
        (token (first-token node)))
    (cond
      (range
       (let ((bounds (remove :range (tokens-of range)
                             :key #'cnvrs:lexeme-kind)))
         (let ((low (antlr-string (first bounds)))
               (high (antlr-string (second bounds))))
           (unless (and (= (length low) 1) (= (length high) 1)
                        (char<= (char low 0) (char high 0)))
             (conversion-error node "invalid negated character range"))
           (list (cons (char low 0) (char high 0))))))
      ((eq (cnvrs:lexeme-kind token) :string_literal)
       (let ((value (antlr-string token)))
         (unless (= (length value) 1)
           (conversion-error node "negated set elements must be single characters"))
         (list (char value 0))))
      ((eq (cnvrs:lexeme-kind token) :lexer_char_set)
       (mapcar (lambda (range)
                 (if (= (first range) (second range)) (code-char (first range))
                     (cons (code-char (first range)) (code-char (second range)))))
               (let ((form (charset-expression node)))
                 (cnvrs::normalize-character-intervals (append (second form) (fourth form))))))
      (t (conversion-error node
                           "lexer negated sets require characters or ranges")))))

(defun lexer-expression (node)
  (case (cnvrs:node-rule node)
    (lexer-alt-list
     (choice-form (mapcar #'lexer-expression (child-nodes node 'lexer-alt))))
    (lexer-alt
     (if (first-node node 'lexer-elements)
         (lexer-expression (first-node node 'lexer-elements))
         '(and)))
    (lexer-elements
     (sequence-form (mapcar #'lexer-expression (child-nodes node 'lexer-element))))
    (lexer-element
     (when (first-node node 'action-block)
       (return-from lexer-expression
         (action-expression (first-node node 'action-block)
                            (not (null (token-of-kind node :question))))))
     (let* ((base (or (first-node node 'lexer-atom)
                      (first-node node 'lexer-block)))
            (expression (lexer-expression base))
            (suffix (first-node node 'ebnf-suffix)))
       (if suffix (suffix-form suffix expression t) expression)))
    (lexer-block (lexer-expression (first-node node 'lexer-alt-list)))
    (lexer-atom
     (if (child-nodes node)
         (lexer-expression (first (child-nodes node)))
         (case (cnvrs:lexeme-kind (first-token node))
           (:token_ref (if (string= (cnvrs:lexeme-text (first-token node)) "EOF")
                           '(cnvrs:eof) (antlr-name node t)))
           (:lexer_char_set (charset-expression node))
           (otherwise (conversion-error node "unsupported lexer atom")))))
    (character-range
     (let ((bounds (remove :range (tokens-of node) :key #'cnvrs:lexeme-kind)))
       (let ((first (antlr-string (first bounds)))
             (last (antlr-string (second bounds))))
         (unless (and (= (length first) 1) (= (length last) 1))
           (conversion-error node "range bounds must be single characters"))
         (list 'range (char first 0) (char last 0)))))
    (terminal-def
     (when (first-node node 'element-options)
       (conversion-error node "element options are not supported"))
     (if (eq (cnvrs:lexeme-kind (first-token node)) :token_ref)
         (if (string= (cnvrs:lexeme-text (first-token node)) "EOF") '(cnvrs:eof) (antlr-name node t))
         (antlr-string node)))
    (wildcard
     (when (first-node node 'element-options)
       (conversion-error node "wildcard options are not supported"))
     '(any))
    (not-set
     (let* ((set (first (child-nodes node)))
            (elements (if (eq (cnvrs:node-rule set) 'block-set) (child-nodes set 'set-element) (list set)))
            (properties nil) (scalars nil))
       (dolist (element elements)
         (if (eq (cnvrs:lexeme-kind (first-token element)) :lexer_char_set)
             (let ((form (charset-expression element)))
               (setf properties (append properties (second form)) scalars (append scalars (fourth form))))
             (setf scalars (append scalars (cnvrs::character-items-intervals (lexer-set-items element))))))
       (list 'cnvrs::codepoint-set (cnvrs::normalize-character-intervals properties) t
             scalars)))
    (set-element
     (let ((token (first-token node)))
       (when (eq (cnvrs:lexeme-kind token) :lexer_char_set)
         (return-from lexer-expression (charset-expression node)))
       (unless (eq (cnvrs:lexeme-kind token) :string_literal)
         (conversion-error node "unsupported set element"))
       (let ((value (antlr-string node)))
         (unless (= (length value) 1)
           (conversion-error node "set element must be one character"))
         (char value 0))))
    (otherwise
     (let ((token (first-token node)))
       (if (and token (eq (cnvrs:lexeme-kind token) :lexer_char_set))
           (charset-expression node)
           (conversion-error node "unsupported lexer expression"))))))

(defun lexer-command-actions (node)
  (loop for command in (child-nodes node 'lexer-command)
        for name = (string-downcase (cnvrs:lexeme-text (first-token (first-node command 'lexer-command-name))))
        for argument = (first-node command 'lexer-command-expr)
        collect
        (cond ((member name '("skip" "more" "popmode") :test #'string=)
               (when argument (conversion-error command "unexpected command argument"))
               (list (cond ((string= name "skip") :skip) ((string= name "more") :more) (t :pop-mode))))
              ((member name '("channel" "type" "mode" "pushmode") :test #'string=)
               (unless argument (conversion-error command "missing command argument"))
               (let* ((text (cnvrs:lexeme-text (first-token argument)))
                      (value (cond ((every #'digit-char-p text)
                                    (conversion-error command "numeric lexer command arguments need symbolic names in Lisp"))
                                   ((string= text "DEFAULT_MODE") :default)
                                   ((string= text "DEFAULT_TOKEN_CHANNEL") :default)
                                   (t (antlr-name argument t)))))
                 (list (cond ((string= name "channel") :channel) ((string= name "type") :type)
                             ((string= name "mode") :mode) (t :push-mode)) value)))
              (t (conversion-error command "lexer command ~A is not supported" name)))))

(defun lexer-case-option (options default)
  (unless options (return-from lexer-case-option default))
  (let ((value default))
    (dolist (option (child-nodes options 'option))
      (let ((name (identifier-text (first-node option 'identifier))))
        (unless (string= name "caseInsensitive")
          (conversion-error option "unsupported lexer rule option ~A" name))
        (let ((text (cnvrs:lexeme-text (first-token (first-node option 'option-value)))))
          (unless (member text '("true" "false") :test #'string=)
            (conversion-error option "caseInsensitive requires true or false"))
          (setf value (string= text "true"))))) value))

(defun lexer-rule-form (node &optional (mode :default))
  (let* ((name (antlr-name (token-of-kind node :token_ref) t))
         (fragment (token-of-kind node :fragment))
         (block (first-node node 'lexer-rule-block))
         (alternatives (first-node block 'lexer-alt-list))
         (commands (remove nil
                           (mapcar (lambda (alt) (first-node alt 'lexer-commands))
                                   (child-nodes alternatives 'lexer-alt)))))
    (when (> (length commands) 1)
      (conversion-error node "commands on multiple alternatives are not supported"))
    (when (and commands (> (length (child-nodes alternatives 'lexer-alt)) 1))
      (conversion-error node "commands on one of several alternatives are not supported"))
    (let* ((rule-case (lexer-case-option (first-node node 'options-spec) *lexer-case-insensitive*))
           (body (list 'cnvrs::lexer-case (lexer-expression alternatives) rule-case)))
      (list name (if commands
                     (list 'cnvrs::lexer-commands body (lexer-command-actions (first commands))) body)
            :mode (if fragment :cnvrs-fragment mode)))))

(defun parser-rule-form (node)
  (when (or (first-node node 'rule-modifiers)
            (first-node node 'arg-action-block)
            (first-node node 'rule-returns)
            (first-node node 'throws-spec)
            (first-node node 'locals-spec)
            (first-node node 'rule-prequel)
            (child-nodes (first-node node 'exception-group)))
    (conversion-error node "rule modifiers, arguments, actions, and exceptions are not supported"))
  (let* ((rule (antlr-name node))
         (alternatives (child-nodes
                        (first-node (first-node node 'rule-block) 'rule-alt-list)
                        'labeled-alt))
         (forms (mapcar
                 (lambda (alternative)
                   (let* ((form (parser-expression alternative t))
                          (labeled (eq (cnvrs::expression-kind form)
                                       :alt-label))
                          (body (if labeled (third form) form)))
                     (if (and (consp body) (eq (first body) 'right))
                         (let ((plain (if labeled
                                          (list 'alt-label (second form)
                                                (second body))
                                          (second body))))
                           ;; ANTLR accepts assoc on primary alternatives,
                           ;; but only recursive operators use its value.
                           (if (nth-value 0
                                (cnvrs::direct-left-alternative rule plain))
                               form plain))
                         form)))
                 alternatives))
         (recursive (loop for form in forms
                          when (nth-value 0
                                (cnvrs::direct-left-alternative rule form))
                            collect form)))
    ;; Keep ANTLR's source order so the left-recursion rewrite can assign
    ;; precedence to prefix as well as recursive alternatives.
    (list rule (if recursive
                   (list 'cnvrs::source-order-precedence (choice-form forms))
                   (choice-form forms)))))

(defun identifier-text (node)
  (cnvrs:lexeme-text (first-token node)))

(defun descendant-tokens (node)
  (if (cnvrs:lexeme-p node)
      (list node)
      (mapcan #'descendant-tokens (cnvrs:node-children node))))

(defun prequel-metadata (node)
  (let ((construct (first (child-nodes node))))
    (case (cnvrs:node-rule construct)
      (options-spec
       (list :options
             (mapcar (lambda (option)
                       (list (identifier-text (first-node option 'identifier))
                             (apply #'concatenate 'string
                                    (mapcar #'cnvrs:lexeme-text
                                            (descendant-tokens
                                             (first-node option 'option-value))))))
                     (child-nodes construct 'option))))
      (delegate-grammars
       (list :imports
             (mapcar (lambda (entry)
                       (let ((names (mapcar #'identifier-text
                                            (child-nodes entry 'identifier))))
                         (if (rest names) names (list nil (first names)))))
                     (child-nodes construct 'delegate-grammar))))
      ((tokens-spec channels-spec)
       (list (if (eq (cnvrs:node-rule construct) 'tokens-spec)
                 :tokens :channels)
             (mapcar #'identifier-text
                     (child-nodes (first-node construct 'id-list)
                                  'identifier))))
      (action_
       (let ((scope (first-node construct 'action-scope-name)))
         (list :action
               (list :scope (and scope (identifier-text scope))
                     :name (identifier-text
                            (first-node construct 'identifier))
                     :body (cnvrs:lexeme-text
                            (first-token (first-node construct
                                                     'action-block)))))))
      (otherwise (conversion-error node "unsupported prequel construct")))))

(defun resolve-token-vocabulary (tree metadata kind lexer token-vocabulary lexer-package)
  (let ((names (loop for prequel in (getf metadata :prequels)
                     when (eq (first prequel) :options)
                       append (loop for (name value) in (second prequel)
                                    when (string= name "tokenVocab") collect value))))
    (unless names (return-from resolve-token-vocabulary nil))
    (unless (and (eq kind :parser) (= (length names) 1))
      (conversion-error tree "tokenVocab requires a parser grammar and one vocabulary"))
    (let* ((name (first names))
           (vocabulary (if (hash-table-p token-vocabulary)
                           (gethash name token-vocabulary)
                           (cdr (assoc name token-vocabulary :test #'string=)))))
      (unless (and (cnvrs:parser-definition-p vocabulary)
                   (eq (cnvrs::parser-definition-kind vocabulary) :lexer))
        (conversion-error tree "tokenVocab ~A requires a lexer definition in :TOKEN-VOCABULARY" name))
      (unless (eq lexer-package (cnvrs:parser-definition-lexer-package vocabulary))
        (conversion-error tree "tokenVocab ~A uses a different lexer package" name))
      (when (and lexer (not (eq lexer vocabulary)))
        (conversion-error tree ":LEXER conflicts with tokenVocab ~A" name))
      vocabulary)))

(defun vocabulary-token-rules (vocabulary metadata)
  (let ((rules (remove-if (lambda (rule) (eq (sixth rule) :cnvrs-fragment))
                          (cnvrs::parser-definition-rules vocabulary))))
    ;; Declared tokens have no literal alias, but are legal named references.
    (dolist (prequel (append (getf (cnvrs:parser-definition-metadata vocabulary)
                                   :prequels)
                            (getf metadata :prequels)))
      (when (eq (first prequel) :tokens)
        (dolist (name (second prequel))
          (let ((symbol (intern (string-upcase name) *antlr-lexer-package*)))
            (unless (find symbol rules :key #'first)
              (setf rules (append rules (list (list symbol nil)))))))))
    rules))

(defun grammar-from-tree (tree &key lexer token-vocabulary parser-package lexer-package)
  (unless (eq (cnvrs:node-rule tree) 'grammar-spec)
    (conversion-error tree "expected a complete grammar"))
  (let* ((*antlr-parser-package* parser-package)
         (*antlr-lexer-package* lexer-package)
         (declaration (first-node tree 'grammar-decl))
         (type-token (first-token (first-node declaration 'grammar-type)))
         (kind (case (cnvrs:lexeme-kind type-token)
                 (:lexer :lexer) (:parser :parser) (:grammar :combined)))
         (name (antlr-name (first-node declaration 'identifier)))
         (metadata (list :prequels
                         (mapcar #'prequel-metadata
                                 (child-nodes tree 'prequel-construct))))
         (vocabulary (resolve-token-vocabulary tree metadata kind lexer
                                                token-vocabulary lexer-package))
         (*token-vocabulary*
           (when vocabulary
             (vocabulary-token-rules vocabulary metadata)))
         (*implicit-literals* nil)
         (*lexer-case-insensitive*
           (some (lambda (prequel)
                   (and (eq (first prequel) :options)
                        (let ((option (assoc "caseInsensitive" (second prequel) :test #'string=)))
                          (when option
                            (unless (member (second option) '("true" "false") :test #'string=)
                              (conversion-error tree "caseInsensitive requires true or false"))
                            (string= (second option) "true")))))
                 (getf metadata :prequels)))
         (parser-rules nil) (lexer-rules nil))
    (dolist (rule (child-nodes (first-node tree 'rules) 'rule-spec))
      (let ((spec (first (child-nodes rule))))
        (case (cnvrs:node-rule spec)
          (parser-rule-spec (push (parser-rule-form spec) parser-rules))
          (lexer-rule-spec (push (lexer-rule-form spec) lexer-rules)))))
    (dolist (mode (child-nodes tree 'mode-spec))
      (let ((mode-name (antlr-name (first-node mode 'identifier) t)))
        (dolist (rule (child-nodes mode 'lexer-rule-spec))
          (push (lexer-rule-form rule mode-name) lexer-rules))))
    (setf parser-rules (nreverse parser-rules)
          lexer-rules (nreverse lexer-rules))
    (when (and (eq kind :lexer) parser-rules)
      (conversion-error tree "parser rules in lexer grammar"))
    (when (and (eq kind :parser) lexer-rules)
      (conversion-error tree "lexer rules in parser grammar"))
    (when (and (eq kind :parser) *implicit-literals*)
      (conversion-error tree "string literals in parser grammars require a token vocabulary"))
    (when (and (eq kind :combined) (null parser-rules))
      (conversion-error tree "combined grammar has no parser rules"))
    (let ((forms (append (mapcar (lambda (entry)
                                   (list (cdr entry) (car entry) :lexer t))
                                 *implicit-literals*)
                         (mapcar (lambda (rule) (append rule '(:lexer t)))
                                 lexer-rules)
                         parser-rules)))
      (cnvrs::make-defined-parser name kind
                                  (caar parser-rules) (or vocabulary lexer)
                                  :hash-table :node :recompute forms
                                  :metadata metadata
                                  :parser-package parser-package
                                  :lexer-package lexer-package
                                  :rules-only t))))

(defun parse (source &key lexer token-vocabulary callbacks parser-package lexer-package)
  "Parse ANTLR4 SOURCE into a CNVRS grammar definition ready for ENSURE-COMPILED.
For parser grammars, :LEXER optionally supplies a CNVRS lexer; otherwise
PARSE accepts token sequences. TOKEN-VOCABULARY is an alist or EQUAL hash table
mapping tokenVocab names (strings) to lexer definitions in :LEXER-PACKAGE.
:PARSER-PACKAGE and :LEXER-PACKAGE are required
package designators for parser rule names and lexer token kinds. CALLBACKS maps exact action block text,
including braces, to functions of (input position). Parser callbacks use
INPUT-TOKEN-AT and INPUT-TOKEN-COUNT to inspect visible tokens. Use PARSE-TREE to inspect
the syntax tree."
  (let ((*semantic-callbacks* callbacks)
        (parser-package (cnvrs::grammar-package parser-package "parser"))
        (lexer-package (cnvrs::grammar-package lexer-package "lexer")))
    (when (eq parser-package lexer-package)
      (cnvrs::grammar-fail "ANTLR parser and lexer packages must differ"))
    (grammar-from-tree (parse-tree source) :lexer lexer :token-vocabulary token-vocabulary
                       :parser-package parser-package
                       :lexer-package lexer-package)))
