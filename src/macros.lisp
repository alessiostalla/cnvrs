(in-package #:cnvrs)

#+sbcl (declaim (optimize (speed 3) (safety 1) (debug 0)
                           (space 0) (compilation-speed 0)))

(defvar *current-parser-name* nil)

(defun parser-option-list-p (form)
  (and (consp form)
       (member (first form) '(:kind :default-rule :lexer :cache-backend
                              :tree-builder :full-context-strategy :metadata
                              :parser-package :lexer-package))))

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

(defun grammar-package (designator context)
  (or (and designator (find-package designator))
      (grammar-fail "Unknown ~A package ~S" context designator)))

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

(defun normalize-rule-form (form kind lexer-package)
  (let* ((body (if (and (consp form) (eq (first form) 'defrule))
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
                                     (eq (symbol-package name) lexer-package)
                                     lexer-option)))))
      (when (grammar-operator-p name)
        (grammar-fail "Rule name or token kind ~S is a CNVRS grammar operator"
                      name))
      (unless (member lexer-option '(:unspecified nil t))
        (grammar-fail ":LEXER for ~S must be T or NIL" name))
      (when (and (eq kind :parser) (eq lexer-option t))
        (grammar-fail "Lexer rule ~S is not allowed in a parser grammar" name))
      (when (and (eq kind :lexer) (eq lexer-option nil))
        (grammar-fail "Parser rule ~S is not allowed in a lexer grammar" name))
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
  (let* ((rule (normalize-rule-form
                form (parser-definition-kind definition)
                (parser-definition-lexer-package definition)))
         (name (first rule)))
    (let ((previous (find name (parser-definition-rules definition)
                          :key #'first :test #'eq)))
      (when previous
        (if (eq (third previous) (third rule))
            (grammar-fail "Duplicate rule ~S in ~S"
                          name (parser-definition-name definition))
            (grammar-fail
             "~S is both a parser rule name and a lexer token kind in ~S"
             name (parser-definition-name definition)))))
    (setf (parser-definition-rules definition)
          (append (parser-definition-rules definition) (list rule))
          (parser-definition-compiled definition) nil)
    name))

(defun make-defined-parser (name kind default-rule lexer cache-backend
                            tree-builder full-context-strategy forms
                            &key metadata parser-package lexer-package)
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
  (when (and (eq kind :lexer) (not (eq full-context-strategy :cached)))
    (grammar-fail "A lexer grammar has no full-context prediction"))
  (let* ((parser-package (grammar-package
                          (or parser-package (symbol-package name)) "parser"))
         (lexer-package (grammar-package
                         (or lexer-package :keyword) "lexer")))
    (when (and (eq kind :combined) (eq parser-package lexer-package))
      (grammar-fail "Combined grammar needs distinct parser and lexer packages"))
    (let ((definition (make-parser-definition
                     :name name :kind kind :default-rule default-rule
                     :lexer lexer :cache-backend cache-backend
                     :parser-package parser-package
                     :lexer-package lexer-package
                     :metadata metadata
                     :full-context-strategy full-context-strategy
                     :tree-builder tree-builder)))
      (dolist (form forms)
        (register-parser-rule definition form))
      definition)))

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
           (setf (parser-definition-compiled definition)
                 (compile-lexer lexer-rules :cache-backend
                                (parser-definition-cache-backend definition)
                                :metadata (parser-definition-metadata definition))))
          (:parser
           (unless parser-rules
             (grammar-fail "Parser grammar ~S has no rules"
                           (parser-definition-name definition)))
           (setf (parser-definition-compiled definition)
                 (compile-grammar parser-rules
                                  :default-rule
                                  (parser-definition-default-rule definition)
                                  :lexer (parser-definition-lexer definition)
                                  :tree-builder
                                  (parser-definition-tree-builder definition)
                                  :full-context-strategy
                                  (parser-definition-full-context-strategy definition)
                                  :cache-backend
                                  (parser-definition-cache-backend definition)
                                  :metadata (parser-definition-metadata definition))))
          (:combined
           (unless (and lexer-rules parser-rules)
             (grammar-fail "Combined grammar ~S needs lexer and parser rules"
                           (parser-definition-name definition)))
           (setf (parser-definition-compiled definition)
                 (compile-grammar parser-rules
                                  :default-rule
                                  (parser-definition-default-rule definition)
                                  :lexer (compile-lexer lexer-rules :cache-backend
                                                        (parser-definition-cache-backend
                                                         definition)
                                                        :metadata
                                                        (parser-definition-metadata
                                                         definition))
                                  :tree-builder
                                  (parser-definition-tree-builder definition)
                                  :full-context-strategy
                                  (parser-definition-full-context-strategy definition)
                                  :cache-backend
                                  (parser-definition-cache-backend definition)
                                  :metadata (parser-definition-metadata definition)))))
        (parser-definition-compiled definition))))

(defun lex (parser source)
  "Run the lexer of a lexer or combined grammar on SOURCE."
  (let* ((compiled (if (parser-definition-p parser)
                       (ensure-parser-compiled parser)
                       parser))
         (lexer (if (parser-p compiled)
                    (parser-lexer compiled)
                    compiled)))
    (unless lexer (grammar-fail "No lexer is attached to ~S" parser))
    (if (compiled-lexer-p lexer)
        (funcall (compiled-lexer-function lexer) source)
        (funcall (coerce lexer 'function) source))))

(defun lexer-matcher (parser)
  "Return a one-token matcher for a compiled lexer or lexer definition.
The matcher takes source, character position, and mode, and returns kind,
end position, and rule index."
  (let ((compiled (ensure-compiled parser)))
    (unless (compiled-lexer-p compiled)
      (grammar-fail "Expected a compiled lexer or lexer definition, got ~S"
                    parser))
    (compiled-lexer-matcher compiled)))

(defun ensure-compiled (parser)
  "Return a compiled grammar or lexer, compiling a definition on first use."
  (typecase parser
    (parser-definition (ensure-parser-compiled parser))
    (parser parser)
    (compiled-lexer parser)
    (t (error 'type-error :datum parser
              :expected-type '(or parser-definition parser compiled-lexer)))))

(defun clear-cache (parser)
  "Clear every cache owned by a compiled grammar or lexer."
  (let ((compiled (ensure-compiled parser)))
    (typecase compiled
      (parser
       (cache-clear (parser-sll-decisions compiled))
       (cache-clear (parser-decisions compiled))
       (cache-clear (parser-direct-decisions compiled))
       (cache-clear (parser-contexts compiled))
       (setf (parser-compiled-sll compiled) nil
             (parser-compiled-full compiled) nil)
       (when (compiled-lexer-p (parser-lexer compiled))
         (clear-cache (parser-lexer compiled))))
      (compiled-lexer (cache-clear (compiled-lexer-cache compiled))))
    compiled))

(defun clone-compiled (parser &key cache-backend
                             (full-context-strategy nil strategy-supplied-p))
  "Copy a compiled grammar or lexer with independent, empty caches.
The transition graph and lexer automaton are immutable and shared."
  (let ((compiled (ensure-compiled parser)))
    (typecase compiled
      (parser
       (let* ((copy (copy-parser compiled))
              (backend (or cache-backend (parser-cache-backend compiled)))
              (strategy (if strategy-supplied-p full-context-strategy
                            (parser-full-context-strategy compiled))))
         (setf (parser-cache-backend copy) backend
               (parser-full-context-strategy copy) strategy
               (parser-full-context-start copy)
               (resolve-full-context-strategy strategy)
               (parser-sll-decisions copy) (make-cache backend)
               (parser-decisions copy) (make-cache backend)
               (parser-direct-decisions copy) (make-cache backend)
               (parser-contexts copy) (make-cache backend)
               (parser-context-count copy) 0
               (parser-compiled-sll copy) nil
               (parser-compiled-full copy) nil
               (parser-lexer copy)
               (if (compiled-lexer-p (parser-lexer compiled))
                   (clone-compiled (parser-lexer compiled)
                                   :cache-backend backend)
                   (parser-lexer compiled)))
         copy))
      (compiled-lexer
       (when strategy-supplied-p
         (grammar-fail "A lexer has no full-context prediction"))
       (let* ((copy (copy-compiled-lexer compiled))
              (backend (or cache-backend
                           (compiled-lexer-cache-backend compiled))))
         (setf (compiled-lexer-cache-backend copy) backend
               (compiled-lexer-cache copy) (make-cache backend))
         (initialize-compiled-lexer copy))))))

(defmacro define-parser (name &body body)
  "Define NAME as a parser definition. The first body form may be a plist
(:KIND :PARSER|:LEXER|:COMBINED :DEFAULT-RULE rule :LEXER function
 :CACHE-BACKEND :HASH-TABLE|:FSET|(:LOCKED backend)
 :TREE-BUILDER builder-expression :METADATA metadata-expression
 :FULL-CONTEXT-STRATEGY :CACHED|:RECOMPUTE|function).
Remaining forms are DEFRULE forms, (name expression ...) rule forms, or
WITH-MODE blocks containing lexer rules."
  (unless (and (symbolp name) (not (keywordp name)))
    (grammar-fail "Parser name must be a non-keyword symbol: ~S" name))
  (let* ((options (if (and body (parser-option-list-p (first body)))
                      (pop body) nil))
         (options (checked-options options '(:kind :default-rule :lexer
                                             :parser-package :lexer-package
                                             :cache-backend :tree-builder
                                             :full-context-strategy :metadata)
                                   (format nil "parser ~S" name)))
         (kind (getf options :kind :parser))
         (default-rule (getf options :default-rule nil))
         (lexer (getf options :lexer nil))
         (cache-backend (getf options :cache-backend :hash-table))
         (tree-builder (getf options :tree-builder :node))
         (metadata (getf options :metadata nil))
         (parser-package (getf options :parser-package nil))
         (lexer-package (getf options :lexer-package nil))
         (full-context-strategy
           (getf options :full-context-strategy :cached)))
    `(defparameter ,name
       (make-defined-parser ',name ',kind ',default-rule ,lexer ',cache-backend
                            ,tree-builder ,full-context-strategy
                            ',(expand-mode-rule-forms body)
                            :metadata ,metadata
                            :parser-package ,parser-package
                            :lexer-package ,lexer-package))))

(defmacro in-parser (name)
  "Select the parser definition receiving subsequent top-level DEFRULE forms."
  (unless (symbolp name)
    (grammar-fail "IN-PARSER requires a parser variable name: ~S" name))
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (setf *current-parser-name* ',name)
     ',name))

(defmacro defrule (&whole form &rest arguments)
  "Add a rule to the parser selected by IN-PARSER at load time."
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
