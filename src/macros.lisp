(in-package #:cnvrs)

(defvar *current-parser-name* nil)

(defun parser-option-list-p (form)
  (and (consp form)
       (member (first form) '(:kind :default-rule :lexer))))

(defun checked-options (options allowed context)
  (unless (and (listp options) (evenp (length options)))
    (grammar-fail "Invalid options for ~A: ~S" context options))
  (let ((seen nil))
    (loop for pair on options by #'cddr
          for key = (first pair) do
      (unless (member key allowed)
        (grammar-fail "Unknown option ~S for ~A" key context))
      (when (member key seen)
        (grammar-fail "Duplicate option ~S for ~A" key context))
      (push key seen)))
  options)

(defun rule-with-mode (form mode)
  (let* ((defrule-p (and (consp form) (eq (first form) 'defrule)))
         (body (if defrule-p (rest form) form)))
    (unless (and (consp body) (consp (rest body)))
      (grammar-fail "WITH-MODE expects rule forms, got ~S" form))
    (let ((options (cddr body)))
      (when (plist-key-p options :mode)
        (unless (eq (getf options :mode) mode)
          (grammar-fail "Rule ~S has :MODE ~S inside WITH-MODE ~S"
                        (first body) (getf options :mode) mode))
        (return-from rule-with-mode form)))
    (if defrule-p
        (append form (list :mode mode))
        (append body (list :mode mode)))))

(defun expand-mode-rule-forms (forms &optional mode)
  (loop for form in forms append
    (if (and (consp form) (eq (first form) 'with-mode))
        (destructuring-bind (operator new-mode &rest nested) form
          (declare (ignore operator))
          (unless (and (symbolp new-mode) new-mode)
            (grammar-fail "WITH-MODE requires a mode name, got ~S" new-mode))
          (expand-mode-rule-forms nested new-mode))
        (list (if mode (rule-with-mode form mode) form)))))

(defun normalize-rule-form (form kind)
  (let* ((body (if (and (consp form)
                        (symbolp (first form))
                        (string-equal (symbol-name (first form)) "DEFRULE"))
                   (rest form)
                   form)))
    (unless (and (consp body) (>= (length body) 2)
                 (symbolp (first body)))
      (grammar-fail "Expected (defrule name expression &key lexer skip channel mode push-mode pop-mode set-mode), got ~S"
                    form))
    (let* ((name (first body))
           (expression (second body))
           (options (checked-options (cddr body)
                                     '(:lexer :skip :channel :mode
                                       :push-mode :pop-mode :set-mode)
                                     (format nil "rule ~S" name)))
           (lexer-option (getf options :lexer :unspecified))
           (lexer-p (case kind
                      (:lexer t)
                      (:parser nil)
                      (:combined (if (eq lexer-option :unspecified)
                                     (keywordp name) lexer-option)))))
      (unless (member lexer-option '(:unspecified nil t))
        (grammar-fail ":LEXER for ~S must be T or NIL" name))
      (when (and (eq kind :parser) (eq lexer-option t))
        (grammar-fail "Lexer rule ~S is not allowed in a parser grammar" name))
      (when (and (eq kind :lexer) (eq lexer-option nil))
        (grammar-fail "Parser rule ~S is not allowed in a lexer grammar" name))
      (when (and (not lexer-p) (keywordp name))
        (grammar-fail "Parser rule name cannot be a keyword: ~S" name))
      (when (and (not lexer-p)
                 (some (lambda (key) (plist-key-p options key))
                       '(:skip :channel :mode :push-mode :pop-mode :set-mode)))
        (grammar-fail "Lexer options on parser rule ~S" name))
      (list name expression lexer-p
            (getf options :skip nil)
            (getf options :channel :default)
            (getf options :mode :default)
            (getf options :push-mode nil)
            (getf options :pop-mode nil)
            (getf options :set-mode nil)))))

(defun register-parser-rule (definition form)
  (unless (parser-definition-p definition)
    (grammar-fail "DEFRULE target is not a parser definition: ~S" definition))
  (let* ((rule (normalize-rule-form form (parser-definition-kind definition)))
         (name (first rule)))
    (when (find name (parser-definition-rules definition)
                :key #'first :test #'eq)
      (grammar-fail "Duplicate rule ~S in ~S"
                    name (parser-definition-name definition)))
    (setf (parser-definition-rules definition)
          (append (parser-definition-rules definition) (list rule))
          (parser-definition-compiled definition) nil)
    name))

(defun make-defined-parser (name kind default-rule lexer forms)
  (unless (and (symbolp name) (not (keywordp name)))
    (grammar-fail "Parser name must be a non-keyword symbol: ~S" name))
  (unless (member kind '(:parser :lexer :combined))
    (grammar-fail "Unknown grammar kind ~S" kind))
  (when (and (eq kind :lexer) default-rule)
    (grammar-fail "A lexer grammar has no default parser rule"))
  (when (and (eq kind :lexer) lexer)
    (grammar-fail "A lexer grammar defines its own lexer rules"))
  (when (and (eq kind :combined) lexer)
    (grammar-fail "A combined grammar defines its lexer rules in the same form"))
  (let ((definition (make-parser-definition
                     :name name :kind kind :default-rule default-rule
                     :lexer lexer)))
    (dolist (form forms)
      (register-parser-rule definition form))
    definition))

(defun ensure-parser-compiled (definition)
  (or (parser-definition-compiled definition)
      (let ((parser-rules nil) (lexer-rules nil))
        (dolist (rule (parser-definition-rules definition))
          (destructuring-bind (name expression lexer-p skip channel mode
                               push-mode pop-mode set-mode) rule
            (if lexer-p
                (push (append (list name expression :skip skip :channel channel
                                    :mode mode)
                              (when push-mode (list :push-mode push-mode))
                              (when pop-mode (list :pop-mode pop-mode))
                              (when set-mode (list :set-mode set-mode)))
                      lexer-rules)
                (push (list name expression) parser-rules))))
        (setf parser-rules (nreverse parser-rules)
              lexer-rules (nreverse lexer-rules))
        (case (parser-definition-kind definition)
          (:lexer
           (unless lexer-rules
             (grammar-fail "Lexer grammar ~S has no rules"
                           (parser-definition-name definition)))
           (multiple-value-bind (lexer matcher)
               (compile-lexer lexer-rules)
             (setf (parser-definition-compiled definition) lexer
                   (parser-definition-matcher definition) matcher)))
          (:parser
           (unless parser-rules
             (grammar-fail "Parser grammar ~S has no rules"
                           (parser-definition-name definition)))
           (setf (parser-definition-compiled definition)
                 (compile-grammar parser-rules
                                  :default-rule
                                  (parser-definition-default-rule definition)
                                  :lexer (parser-definition-lexer definition))))
          (:combined
           (unless (and lexer-rules parser-rules)
             (grammar-fail "Combined grammar ~S needs lexer and parser rules"
                           (parser-definition-name definition)))
           (setf (parser-definition-compiled definition)
                 (compile-grammar parser-rules
                                  :default-rule
                                  (parser-definition-default-rule definition)
                                  :lexer (compile-lexer lexer-rules)))))
        (parser-definition-compiled definition))))

(defun lex (parser source)
  "Run the lexer of a lexer or combined grammar on SOURCE."
  (let* ((compiled (if (parser-definition-p parser)
                       (ensure-parser-compiled parser)
                       parser))
         (lexer (if (grammar-p compiled)
                    (grammar-lexer compiled)
                    compiled)))
    (unless lexer (grammar-fail "No lexer is attached to ~S" parser))
    (funcall (coerce lexer 'function) source)))

(defun lexer-matcher (parser)
  "Return a one-token matcher for a lexer DEFINE-PARSER definition.
The matcher takes source, character position, and mode, and returns kind,
end position, and rule index."
  (unless (and (parser-definition-p parser)
               (eq (parser-definition-kind parser) :lexer))
    (grammar-fail "Expected a lexer parser definition, got ~S" parser))
  (ensure-parser-compiled parser)
  (parser-definition-matcher parser))

(defmacro define-parser (name &body body)
  "Define NAME as a parser definition. The first body form may be a plist
(:KIND :PARSER|:LEXER|:COMBINED :DEFAULT-RULE rule :LEXER function).
Remaining forms are DEFRULE forms, (name expression ...) rule forms, or
WITH-MODE blocks containing lexer rules."
  (unless (and (symbolp name) (not (keywordp name)))
    (grammar-fail "Parser name must be a non-keyword symbol: ~S" name))
  (let* ((options (if (and body (parser-option-list-p (first body)))
                      (pop body) nil))
         (options (checked-options options '(:kind :default-rule :lexer)
                                   (format nil "parser ~S" name)))
         (kind (getf options :kind :parser))
         (default-rule (getf options :default-rule nil))
         (lexer (getf options :lexer nil)))
    `(defparameter ,name
       (make-defined-parser ',name ',kind ',default-rule ,lexer
                            ',(expand-mode-rule-forms body)))))

(defmacro in-parser (name)
  "Select the parser definition receiving subsequent top-level DEFRULE forms."
  (unless (symbolp name)
    (grammar-fail "IN-PARSER requires a parser variable name: ~S" name))
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (setf *current-parser-name* ',name)
     ',name))

(defmacro defrule (&whole form &rest arguments)
  (declare (ignore arguments))
  (unless *current-parser-name*
    (grammar-fail "DEFRULE requires an earlier IN-PARSER form"))
  `(eval-when (:load-toplevel :execute)
     (register-parser-rule (symbol-value ',*current-parser-name*) ',form)))

(defmacro with-mode (mode &body rules)
  "Define RULES in lexer MODE within an incremental IN-PARSER definition.
Also accepted inside DEFINE-PARSER, where rules may omit DEFRULE."
  (unless (and (symbolp mode) mode)
    (grammar-fail "WITH-MODE requires a mode name, got ~S" mode))
  `(progn
     ,@(mapcar (lambda (form)
                 (if (and (consp form) (eq (first form) 'defrule))
                     form
                     (cons 'defrule form)))
               (expand-mode-rule-forms rules mode))))
