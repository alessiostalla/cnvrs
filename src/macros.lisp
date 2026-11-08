(in-package #:cnvrs)

#+sbcl (declaim (optimize (speed 3) (safety 1) (debug 0)
                           (space 0) (compilation-speed 0)))

(defun parser-option-list-p (form)
  (and (consp form)
       (member (first form) '(:kind :default-rule :lexer :cache-backend
                              :tree-builder :full-context-strategy :metadata
                              :parser-package :lexer-package :rules-only))))

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
                                       :push-mode :pop-mode :set-mode :more :type :case-insensitive :fragment)
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
                       '(:skip :channel :mode :push-mode :pop-mode :set-mode :more :type :case-insensitive :fragment)))
        (grammar-fail "Lexer options on parser rule ~S" name))
      (when (plist-key-p options :fragment)
        (unless (member (getf options :fragment) '(nil t)) (grammar-fail ":FRAGMENT must be boolean"))
        (when (getf options :fragment)
          (when (plist-key-p options :mode) (grammar-fail "A fragment cannot declare a mode"))
          (setf (getf options :mode) :cnvrs-fragment)))
      (when (plist-key-p options :case-insensitive)
        (setf expression (list 'lexer-case expression (getf options :case-insensitive))))
      (let ((commands nil))
        (when (getf options :more) (push '(:more) commands))
        (when (getf options :type) (push (list :type (getf options :type)) commands))
        (when commands (setf expression (list 'lexer-commands expression (nreverse commands)))))
      (list name expression lexer-p
            (getf options :skip nil)
            (getf options :channel :default)
            (getf options :mode :default)
            (getf options :push-mode nil)
            (getf options :pop-mode nil)
            (getf options :set-mode nil)))))

(defun compose-definition-rules (definition imports forms)
  "Merge definitions before compiling their shared graph."
  (let ((local-rules nil)
        (local-names (make-hash-table :test 'eq))
        (imported-names (make-hash-table :test 'eq))
        (imported-origins (make-hash-table :test 'eq))
        (origins (make-hash-table :test 'eq))
        (rules nil))
    (dolist (form forms)
      (let* ((rule (normalize-rule-form form
                                        (parser-definition-kind definition)
                                        (parser-definition-lexer-package definition)))
             (name (first rule)))
        (when (gethash name local-names)
          (grammar-fail "Duplicate local rule ~S in ~S"
                        name (parser-definition-name definition)))
        (setf (gethash name local-names) rule
              (gethash name origins) (parser-definition-name definition))
        (push rule local-rules)))
    (setf local-rules (nreverse local-rules))
    (labels ((reaches-definition-p (source seen)
               (let ((name (if (symbolp source) source
                               (parser-definition-name source))))
                 (cond ((eq name (parser-definition-name definition)) t)
                       ((gethash name seen) nil)
                       (t
                        (setf (gethash name seen) t)
                        (some (lambda (parent)
                                (reaches-definition-p parent seen))
                              (if (symbolp source)
                                  (and (boundp source)
                                       (parser-definition-p (symbol-value source))
                                       (parser-definition-imports
                                        (symbol-value source)))
                                  (parser-definition-imports source))))))))
      (dolist (source imports)
        (when (eq (parser-definition-kind definition) :lexer)
          (grammar-fail "A lexer definition cannot USE parser rules"))
        (unless (and (parser-definition-p source)
                     (eq (parser-definition-kind source) :parser))
          (grammar-fail "USE requires a parser definition, got ~S" source))
        (when (reaches-definition-p source (make-hash-table :test 'eq))
          (grammar-fail "Parser import cycle involving ~S"
                        (parser-definition-name definition)))
        (dolist (rule (parser-definition-rules source))
          (let* ((name (first rule))
                 (previous (gethash name imported-names))
                 (origin (gethash name (parser-definition-origins source)
                                  (parser-definition-name source))))
            (when (and (gethash name local-names)
                       (third (gethash name local-names)))
              (grammar-fail "~S is both an imported parser rule and a lexer token kind"
                            name))
            (unless (gethash name local-names)
              (cond ((null previous)
                     (setf (gethash name imported-names) rule)
                     (setf (gethash name imported-origins) origin
                           (gethash name origins) origin)
                     (push rule rules))
                    ((not (eq (gethash name imported-origins) origin))
                     (grammar-fail "Conflicting imported rule ~S in ~S"
                                   name (parser-definition-name definition)))))))))
    (setf rules (nreverse rules))
    (setf rules (nconc rules local-rules))
    (unless rules
      (grammar-fail "Definition ~S needs at least one rule"
                    (parser-definition-name definition)))
    (setf (parser-definition-rules definition) rules
          (parser-definition-imports definition) imports
          (parser-definition-origins definition) origins
          (parser-definition-compiled definition) nil)
    (unless (or (parser-definition-default-rule definition)
                (eq (parser-definition-kind definition) :lexer))
      (setf (parser-definition-default-rule definition)
            (first (or (find-if-not #'third local-rules)
                       (find-if-not #'third rules)))))
    definition))

(defun make-defined-parser (name kind default-rule lexer cache-backend
                            tree-builder full-context-strategy forms
                            &key metadata parser-package lexer-package
                              imports rules-only)
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
  (when (and (eq kind :lexer) (not (eq full-context-strategy :recompute)))
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
      (compose-definition-rules definition imports forms)
      (unless rules-only (ensure-parser-compiled definition))
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

(defun split-definition-rules (definition)
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
    (values (nreverse parser-rules) (nreverse lexer-rules))))

(defun file-compiled-definition-form (definition lexer-form cache-form
                                       tree-form strategy-form metadata-form
                                       rules-only)
  "Emit a load-time constructor from a compile-time-resolved definition."
  (let ((lexer-input lexer-form)
        (cache-input cache-form)
        (tree-input tree-form)
        (strategy-input strategy-form)
        (metadata-input metadata-form)
        (lexer-variable (gensym "LEXER-"))
        (cache-variable (gensym "CACHE-"))
        (tree-variable (gensym "TREE-"))
        (strategy-variable (gensym "STRATEGY-"))
        (metadata-variable (gensym "METADATA-")))
    (setf lexer-form lexer-variable
          cache-form cache-variable
          tree-form tree-variable
          strategy-form strategy-variable
          metadata-form metadata-variable)
  (multiple-value-bind (parser-rules lexer-rules)
      (split-definition-rules definition)
    (let* ((kind (parser-definition-kind definition))
           (prepared-lexer
             (when (and (not rules-only) lexer-rules)
               (compile-lexer lexer-rules)))
           (prepared-parser
             (when (and (not rules-only) parser-rules)
               (compile-grammar parser-rules
                                :default-rule
                                (parser-definition-default-rule definition)
                                :lexer (and (eq kind :combined) prepared-lexer)
                                :compile-runners nil)))
           (lexer-constructor
             (when prepared-lexer
               `(thawed-lexer ',(frozen-lexer prepared-lexer)
                              ,cache-form ,metadata-form)))
           (parser-constructor
             (when prepared-parser
               `(thawed-parser ',(frozen-parser prepared-parser)
                               ,(if (eq kind :combined)
                                    lexer-constructor lexer-form)
                               ,tree-form ,strategy-form ,cache-form
                               ,metadata-form
                               ,@(if (parser-semantic-rules prepared-parser)
                                     '(nil nil)
                                     (list (parser-runner-form prepared-parser nil)
                                           (parser-runner-form prepared-parser t)))))))
      `(let* ((,lexer-variable ,lexer-input)
              (,cache-variable ,cache-input)
              (,tree-variable ,tree-input)
              (,strategy-variable ,strategy-input)
              (,metadata-variable ,metadata-input)
              (definition
               (make-parser-definition
                :name ',(parser-definition-name definition)
                :kind ',kind
                :default-rule ',(parser-definition-default-rule definition)
                :lexer ,lexer-form :cache-backend ,cache-form
                :tree-builder ,tree-form
                :full-context-strategy ,strategy-form
                :metadata ,metadata-form
                :parser-package (find-package
                                 ',(package-name
                                    (parser-definition-parser-package definition)))
                :lexer-package (find-package
                                ',(package-name
                                   (parser-definition-lexer-package definition)))
                :rules ',(parser-definition-rules definition)
                :imports ',(mapcar #'parser-definition-name
                                   (parser-definition-imports definition))
                :origins (thawed-table
                          ',(frozen-table
                             (parser-definition-origins definition))))))
         ,@(unless rules-only
             `((setf (parser-definition-compiled definition)
                     ,(if (eq kind :lexer)
                          lexer-constructor parser-constructor))))
         definition)))))

(defun lex (parser source &key recover)
  "Run the lexer of a lexer or combined grammar on SOURCE."
  (let* ((compiled (if (parser-definition-p parser)
                       (ensure-parser-compiled parser)
                       parser))
         (lexer (if (parser-p compiled)
                    (parser-lexer compiled)
                    compiled)))
    (unless lexer (grammar-fail "No lexer is attached to ~S" parser))
    (if (compiled-lexer-p lexer)
        (funcall (compiled-lexer-function lexer) source :recover recover)
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
       (when (parser-atn-runtime compiled)
         (let ((sim (first (parser-atn-runtime compiled))))
           (cnvrs/antlr-runtime:clear-dfa sim)
           (bordeaux-threads:with-lock-held
               ((cnvrs/antlr-runtime::simulator-context-cache-lock sim))
             (clrhash (cnvrs/antlr-runtime:simulator-context-cache sim)))))
       (cache-clear (parser-sll-decisions compiled))
       (cache-clear (parser-decisions compiled))
       (cache-clear (parser-direct-decisions compiled))
       (cache-clear (parser-contexts compiled))
       (setf (parser-compiled-sll compiled) nil
             (parser-compiled-full compiled) nil)
       (when (compiled-lexer-p (parser-lexer compiled))
         (clear-cache (parser-lexer compiled))))
      (compiled-lexer (clear-lexer-cache compiled)))
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
         (setf (parser-atn-runtime-lock copy) (bordeaux-threads:make-lock "ANTLR frontend runtime")
               (parser-atn-runtime copy) nil
               (parser-cache-backend copy) backend
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

(defmacro defparser (name &body body)
  "Define a complete parser, lexer, or combined grammar.
USE imports parser rules before local overrides. :RULES-ONLY T retains the
definition without compiling it at definition time."
  (unless (and (symbolp name) (not (keywordp name)))
    (grammar-fail "Parser name must be a non-keyword symbol: ~S" name))
  (let* ((options (if (and body (parser-option-list-p (first body)))
                      (pop body) nil))
         (options (checked-options options '(:kind :default-rule :lexer
                                             :parser-package :lexer-package
                                             :cache-backend :tree-builder
                                             :full-context-strategy :metadata
                                             :rules-only)
                                   (format nil "parser ~S" name)))
         (kind (getf options :kind :parser))
         (rules-only (getf options :rules-only nil))
         (imports nil)
         (rules nil))
    (unless (member kind '(:parser :lexer :combined))
      (grammar-fail "Unknown grammar kind ~S" kind))
    (unless (member rules-only '(nil t))
      (grammar-fail ":RULES-ONLY must be T or NIL in ~S" name))
    (dolist (form body)
      (if (and (consp form) (eq (first form) 'use))
          (if (= (length form) 2)
              (let ((source (second form)))
                (unless (and (symbolp source) (not (keywordp source)))
                  (grammar-fail "USE requires a DEFPARSER name, got ~S"
                                source))
                (push source imports))
              (grammar-fail "USE requires one parser definition: ~S" form))
          (push form rules)))
    (when (and (eq kind :lexer) imports)
      (grammar-fail "A lexer definition cannot USE parser rules"))
    (let* ((imports (nreverse imports))
           (rules (expand-mode-rule-forms (nreverse rules)))
           (sources
             (loop for source in imports collect
               (progn
                 (unless (and (boundp source)
                              (parser-definition-p (symbol-value source)))
                   (grammar-fail "USE needs an already defined parser ~S" source))
                 (symbol-value source))))
           (definition
             (make-defined-parser
              name kind (getf options :default-rule) nil :hash-table
              :node :recompute rules :imports sources :rules-only t
              :parser-package (when (plist-key-p options :parser-package)
                                (eval (getf options :parser-package)))
              :lexer-package (when (plist-key-p options :lexer-package)
                               (eval (getf options :lexer-package)))))
           (initializer
             (file-compiled-definition-form
              definition (getf options :lexer)
              (getf options :cache-backend :hash-table)
              (getf options :tree-builder :node)
              (getf options :full-context-strategy :recompute)
              (getf options :metadata) rules-only)))
      `(progn
         (eval-when (:compile-toplevel)
           (setf (symbol-value ',name)
                 (make-defined-parser
                  ',name ',kind ',(getf options :default-rule)
                  nil :hash-table :node :recompute ',rules
                  :imports (list ,@imports) :rules-only t
                  :parser-package (find-package
                                   ',(package-name
                                      (parser-definition-parser-package
                                       definition)))
                  :lexer-package (find-package
                                  ',(package-name
                                     (parser-definition-lexer-package
                                      definition))))))
         (defparameter ,name ,initializer)))))

(defmacro use (&rest arguments)
  (declare (ignore arguments))
  (grammar-fail "USE is only valid inside DEFPARSER"))

(defmacro defrule (&rest arguments)
  "A rule subform of DEFPARSER; it is invalid at top level."
  (declare (ignore arguments))
  (grammar-fail "DEFRULE is only valid inside DEFPARSER"))

(defmacro with-mode (&rest arguments)
  "A lexer-mode subform of DEFPARSER; it is invalid at top level."
  (declare (ignore arguments))
  (grammar-fail "WITH-MODE is only valid inside DEFPARSER"))
