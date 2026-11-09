(defpackage #:cnvrs/tests/parser
  (:use #:cl)
  (:shadow #:predicate)
  (:export #:start #:predicate))

(defpackage #:cnvrs/tests/lexer
  (:use #:cl)
  (:export #:predicate))

(defpackage #:cnvrs/tests/expression
  (:use #:cl)
  (:export #:expression #:atom))

(defpackage #:cnvrs/tests/java
  (:use #:cl)
  (:export #:class))

(defpackage #:cnvrs/tests
  (:use #:cl)
  (:import-from #:cnvrs #:seq #:? #:*? #:+? #:?? #:range #:one-of
                #:not-one-of #:any #:label #:alt-label #:token #:not-token
                #:predicate #:action #:right)
  (:export #:run-tests))

(in-package #:cnvrs/tests)

(defun antlr-parse (source &rest options)
  (apply #'cnvrs/antlr4:parse source
         :parser-package (find-package '#:cnvrs/antlr4)
         :lexer-package (find-package :keyword)
         options))

(cnvrs:defparser *inline-parser* (:kind :parser :default-rule start)
  (cnvrs:defrule start (and :open item :close))
  (cnvrs:defrule item :name))

(cnvrs:defparser *package-parser* (:kind :parser :default-rule item)
  (cnvrs:defrule start (and item :end))
  (cnvrs:defrule item :name))

(cnvrs:defparser *inline-lexer* (:kind :lexer)
  (cnvrs:defrule :space (+ (one-of " ")) :skip t)
  (cnvrs:defrule :name (+ (range #\a #\z))))

(cnvrs:defparser *package-lexer* (:kind :lexer)
  (cnvrs:defrule :number (+ (range #\0 #\9)))
  (cnvrs:defrule :space (+ (one-of " ")) :skip t))

(cnvrs:defparser *mode-package-lexer* (:kind :lexer)
  (cnvrs:defrule :open #\< :push-mode :tag :skip t)
  (cnvrs:with-mode :tag
    (cnvrs:defrule :tag (+ (range #\a #\z)))
    (cnvrs:defrule :close #\> :pop-mode t :skip t)))

(cnvrs:defparser *mode-inline-lexer* (:kind :lexer)
  (:open #\< :push-mode :tag :skip t)
  (cnvrs:with-mode :tag
    (:tag (+ (range #\a #\z)))
    (:close #\> :pop-mode t :skip t)))

(cnvrs:defparser *inline-combined* (:kind :combined :default-rule start)
  (cnvrs:defrule start (and :name :equals :number))
  (cnvrs:defrule :name (+ (range #\a #\z)))
  (cnvrs:defrule :equals #\=)
  (cnvrs:defrule :number (+ (range #\0 #\9))))

(cnvrs:defparser *package-combined*
    (:kind :combined :default-rule assignment)
  (cnvrs:defrule assignment (and :let :name :equals :number))
  (cnvrs:defrule :space (+ (one-of " ")) :skip t)
  (cnvrs:defrule :let "let")
  (cnvrs:defrule :name (+ (range #\a #\z)))
  (cnvrs:defrule :equals #\=)
  (cnvrs:defrule :number (+ (range #\0 #\9))))

(cnvrs:defparser *bare-parser* (:kind :parser)
  (start (and :a :b)))

(cnvrs:defparser *hash-parser* (:kind :parser :cache-backend :hash-table)
  (start (or :a :b)))

(cnvrs:defparser *recompute-parser*
    (:kind :parser :full-context-strategy :recompute)
  (start (and item #\b))
  (item (or #\a (and #\a #\b))))

(cnvrs:defparser *compiled-dfa-parser* (:kind :parser)
  (start (and item #\b))
  (item (or #\a (and #\a #\b))))

(defstruct alternate-node rule children start end)
(defmethod cnvrs:make-parse-node ((builder (eql :alternate)) rule children
                                  start end)
  (make-alternate-node :rule rule :children children :start start :end end))
(defmethod cnvrs:parse-node-components ((builder (eql :alternate)) value)
  (if (alternate-node-p value)
      (values (alternate-node-rule value) (alternate-node-children value)
              (alternate-node-start value) (alternate-node-end value) t)
      (values nil nil nil nil nil)))

(defstruct event-sink (events nil))
(defmethod cnvrs:parse-build-tree-p ((builder event-sink))
  nil)
(defmethod cnvrs:parse-rule-enter ((builder event-sink) rule position)
  (push (list :enter rule position) (event-sink-events builder)))
(defmethod cnvrs:parse-token-consumed ((builder event-sink) token start end)
  (push (list :token token start end) (event-sink-events builder)))
(defmethod cnvrs:parse-rule-exit ((builder event-sink) rule start end)
  (push (list :exit rule start end) (event-sink-events builder)))

(cnvrs:defparser *alternate-parser* (:kind :parser
                                        :tree-builder :alternate)
  (start (and item :end))
  (item :name))

(cnvrs:defparser *external-lexer-parser*
    (:kind :parser :lexer (cnvrs:compile-lexer '((:word (+ (range #\a #\z)))))
     :default-rule start)
  (cnvrs:defrule start :word))

(cnvrs:defparser *symbol-lexer-combined* (:kind :combined)
  (cnvrs:defrule start (token word))
  (cnvrs:defrule word (+ (range #\a #\z)) :lexer t))

(cnvrs:defparser *mode-combined* (:kind :combined)
  (cnvrs:defrule start (and :word :string-text :word))
  (cnvrs:defrule :word (+ (range #\a #\z)))
  (cnvrs:defrule :space #\Space :skip t)
  (cnvrs:defrule :open #\" :skip t :push-mode :string)
  (cnvrs:with-mode :string
    (cnvrs:defrule :string-text (+ (range #\a #\z)))
    (cnvrs:defrule :close #\" :skip t :pop-mode t)))

(cnvrs:defparser *packaged-combined*
    (:kind :combined
     :parser-package (find-package '#:cnvrs/tests/parser)
     :lexer-package (find-package '#:cnvrs/tests/lexer))
  (cnvrs/tests/parser:start cnvrs/tests/lexer:predicate)
  (cnvrs/tests/lexer:predicate "x"))

(cnvrs:defparser *expression-rules* (:rules-only t)
  (cnvrs/tests/expression:expression cnvrs/tests/expression:atom)
  (cnvrs/tests/expression:atom :id))

(cnvrs:defparser *java-parser*
  (cnvrs:use *expression-rules*)
  (cnvrs/tests/java:class
   (and :class cnvrs/tests/expression:expression :semi)))

(cnvrs:defparser *java-override* (:default-rule cnvrs/tests/java:class)
  (cnvrs:use *expression-rules*)
  (cnvrs/tests/java:class
   (and :class cnvrs/tests/expression:expression :semi))
  (cnvrs/tests/expression:atom :number))

(cnvrs:defparser *expression-wrapper* (:rules-only t)
  (cnvrs:use *expression-rules*))

(cnvrs:defparser *java-diamond* (:default-rule cnvrs/tests/java:class)
  (cnvrs:use *expression-rules*)
  (cnvrs:use *expression-wrapper*)
  (cnvrs/tests/java:class
   (and :class cnvrs/tests/expression:expression :semi)))

(cnvrs:defparser *contextual-fragment* (:rules-only t)
  (cnvrs/tests/expression:expression (or :id (and :id :semi))))

(cnvrs:defparser *contextual-java*
  (cnvrs:use *contextual-fragment*)
  (cnvrs/tests/java:class
   (and :class cnvrs/tests/expression:expression :semi)))

(defvar *checks* 0)

(defun check (condition description)
  (incf *checks*)
  (unless condition (error "Failed: ~A" description)))

(defmacro signals (condition form)
  `(handler-case (progn ,form nil)
     (,condition () t)))

(defmethod cnvrs:make-cache ((backend (eql :test-cache)))
  (declare (ignore backend))
  (cnvrs:make-cache :hash-table))

(defun run-tests ()
  (setf *checks* 0)
  (check (null (cnvrs::parser-definition-compiled
                cnvrs/tests/file::*expression-rules*))
         "cross-file imported rules remain uncompiled")
  (check (eq (cnvrs:node-rule
              (cnvrs:parse cnvrs/tests/file::*java-class*
                           '(:class :id :semi)))
             'cnvrs/tests/file::class)
         "a FASL composes parser rules from an earlier file")
  (check (equalp (map 'vector #'cnvrs:lexeme-kind
                      (cnvrs:lex cnvrs/tests/file::*word-lexer* "abc"))
                 #(:word))
         "a lexer FASL reconstructs its transition graph")
  (check (and (null (cnvrs::parser-definition-compiled
                     cnvrs/tests/file::*lexer-rules-only*))
              (= 1 (length (cnvrs:lex cnvrs/tests/file::*lexer-rules-only*
                                      "abc"))))
         "rules-only lexer definitions retain in-image compilation")
  (check (= 1 (length (cnvrs:lex cnvrs/tests/file::*quoted-lexer*
                                 "\"abc\"")))
         "a lexer FASL contains an ordered matcher")
  (check (cnvrs:node-p (cnvrs:parse cnvrs/tests/file::*combined-file* "abc"))
         "a combined parser and lexer load from a FASL")
  (check (cnvrs:node-p (cnvrs:parse cnvrs/tests/file::*semantic-file* '(:id)))
         "a semantic parser loads from a FASL")
  (check (= 1 (length (cnvrs:lex cnvrs/tests/file::*semantic-lexer* "abc")))
         "a semantic lexer loads from a FASL")
  (let ((definition
          (symbol-value
           (eval '(cnvrs:defparser *image-parser*
                    (start :id))))))
    (check (and (functionp (cnvrs:parser-runner
                            (cnvrs:ensure-compiled definition)))
                (cnvrs:node-p (cnvrs:parse definition '(:id))))
           "evaluating defparser directly creates a working in-image parser"))
  (check (and (null (cnvrs::parser-definition-compiled *expression-rules*))
              (cnvrs:parser-p (cnvrs:ensure-compiled *java-parser*)))
         "rules-only definitions remain uncompiled when imported")
  (check (eq (cnvrs:node-rule
              (second (cnvrs:node-children
                       (cnvrs:parse *java-parser* '(:class :id :semi)))))
             'cnvrs/tests/expression:expression)
         "composed parser calls a rule from another package")
  (check (eq (cnvrs:parser-default-rule
              (cnvrs:ensure-compiled *java-parser*))
             'cnvrs/tests/java:class)
         "a local rule becomes the default before imported rules")
  (check (eq (cnvrs:node-rule
              (cnvrs:parse *contextual-java* '(:class :id :semi)))
             'cnvrs/tests/java:class)
         "prediction in an imported rule sees its caller's context")
  (check (and (eq (cnvrs:node-rule
                   (cnvrs:parse *java-override* '(:class :number :semi)))
                  'cnvrs/tests/java:class)
              (signals cnvrs:parse-error
                (cnvrs:parse *java-override* '(:class :id :semi))))
         "a local rule replaces imported references to the same symbol")
  (check (eq (cnvrs:node-rule
              (cnvrs:parse *java-diamond* '(:class :id :semi)))
             'cnvrs/tests/java:class)
         "repeated imports of the same originating rule are harmless")
  (check (signals cnvrs:grammar-error
           (eval '(cnvrs:defrule cnvrs/tests/java:class :id)))
         "a complete defparser cannot be extended with later rules")
  (check (signals cnvrs:grammar-error
           (eval '(cnvrs:defparser *invalid-use*
                    (cnvrs:use (identity *expression-rules*))
                    (start :id))))
         "USE names a defparser definition rather than an expression")
  (check (signals cnvrs:grammar-error
           (eval '(cnvrs:defparser *invalid-lexer-use* (:kind :lexer)
                    (cnvrs:use *expression-rules*)
                    (:word "a"))))
         "lexer definitions reject USE")
  (check (signals cnvrs:grammar-error
           (let* ((left (cnvrs::make-defined-parser
                         '*import-left* :parser nil nil :hash-table
                         :node :recompute
                         '((cnvrs/tests/expression:atom :left))))
                  (right (cnvrs::make-defined-parser
                          '*import-right* :parser nil nil :hash-table
                          :node :recompute
                          '((cnvrs/tests/expression:atom :right)))))
             (cnvrs::make-defined-parser
              '*import-conflict* :parser nil nil :hash-table :node :recompute nil
              :imports (list left right))))
         "conflicting imports without a local override are rejected")
  (let* ((left (cnvrs::make-defined-parser
                '*import-left* :parser nil nil :hash-table :node :recompute
                '((cnvrs/tests/expression:atom :left)) :rules-only t))
         (right (cnvrs::make-defined-parser
                 '*import-right* :parser nil nil :hash-table :node :recompute
                 '((cnvrs/tests/expression:atom :right)) :rules-only t))
         (composed (cnvrs::make-defined-parser
                    '*import-resolved* :parser nil nil :hash-table :node :recompute
                    '((cnvrs/tests/expression:atom :local))
                    :imports (list left right))))
    (check (eq (cnvrs:node-rule (cnvrs:parse composed '(:local)))
               'cnvrs/tests/expression:atom)
           "a local override resolves a conflict between imports"))
  (check (signals cnvrs:grammar-error
           (cnvrs::make-defined-parser
            '*import-cycle* :parser nil nil :hash-table :node :recompute nil
            :imports (list (cnvrs::make-defined-parser
                            '*import-cycle* :parser nil nil :hash-table
                            :node :recompute
                            '((cnvrs/tests/expression:atom :id))))))
         "import cycles are rejected")
  (check (and (not (eq 'cnvrs:predicate
                       'cnvrs/tests/parser:predicate))
              (not (eq 'cnvrs:predicate
                       'cnvrs/tests/lexer:predicate))
              (not (eq 'cnvrs/tests/parser:predicate
                       'cnvrs/tests/lexer:predicate))
              (eq 'cnvrs:and 'cl:and))
         "operator, parser rule, and token symbols have distinct identities")
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-grammar '((cl:and :x))))
         "CL:AND cannot be used as a parser rule name because it is CNVRS:AND")
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-lexer '((cnvrs:predicate "x"))))
         "CNVRS operator cannot be used as a lexer token kind")
  (let ((lexer (cnvrs:compile-lexer
                '((cnvrs/tests/parser:start "x")))))
    (check (signals cnvrs:grammar-error
             (cnvrs:compile-grammar
              '((cnvrs/tests/parser:start
                 (cnvrs:token cnvrs/tests/parser:start)))
              :lexer lexer))
           "compiled parser rejects a rule and lexer kind with one symbol"))
  (let ((parser (cnvrs:compile-grammar
                 '((cnvrs/tests/parser:start :x)))))
    (check (signals cnvrs:grammar-error
             (cnvrs:parse parser "x"
                          :lexer (lambda (source)
                                   (declare (ignore source))
                                   (vector 'cnvrs/tests/parser:start))))
           "custom lexer overlap is detected when its tokens are returned"))
  (let* ((lexer (cnvrs:compile-lexer
                 '((cnvrs/tests/lexer:predicate "x"))))
         (parser (cnvrs:compile-grammar
                  '((cnvrs/tests/parser:start
                     (cnvrs:and cnvrs/tests/parser:predicate
                                cnvrs/tests/lexer:predicate))
                    (cnvrs/tests/parser:predicate
                     cnvrs/tests/lexer:predicate))
                  :lexer lexer)))
    (check (eq (cnvrs:node-rule (cnvrs:parse parser "xx"))
               'cnvrs/tests/parser:start)
           "native grammar distinguishes parser and lexer packages")
    (check (signals cnvrs:grammar-error
             (cnvrs:compile-grammar
              '((cnvrs/tests/parser:start
                 (cnvrs/tests/parser:predicate
                  cnvrs/tests/lexer:predicate)))))
           "same-named parser symbol cannot impersonate a CNVRS operator")
    (check (signals cnvrs:grammar-error
             (cnvrs:compile-lexer
              '((cnvrs/tests/lexer:predicate
                 (cnvrs/tests/lexer:predicate "x")))))
           "same-named lexer symbol cannot impersonate a CNVRS operator"))
  (let ((parser (cnvrs:compile-grammar
                 '((cnvrs/tests/parser:start
                    (cnvrs:token cnvrs/tests/parser:predicate))))))
    (check (eq (cnvrs:node-rule
                (cnvrs:parse parser '(cnvrs/tests/parser:predicate)))
               'cnvrs/tests/parser:start)
           "explicit token form disambiguates a token in the parser package"))
  (check (eq (cnvrs:node-rule (cnvrs:parse *packaged-combined* "x"))
             'cnvrs/tests/parser:start)
         "combined grammar classifies rules by selected packages")
  (let* ((grammar (cnvrs/antlr4:parse
                   "grammar Packaged; start : PREDICATE; PREDICATE : 'x';"
                   :parser-package (find-package '#:cnvrs/tests/parser)
                   :lexer-package (find-package '#:cnvrs/tests/lexer)))
         (tree (cnvrs:parse grammar "x")))
    (check (eq (cnvrs:node-rule tree) 'cnvrs/tests/parser:start)
           "ANTLR importer interns parser rules in the selected package")
    (check (eq (cnvrs:lexeme-kind (aref (cnvrs:lex grammar "x") 0))
               'cnvrs/tests/lexer:predicate)
           "ANTLR importer interns token kinds in the selected package"))
  (check (signals cnvrs:grammar-error
           (cnvrs/antlr4:parse "lexer grammar Missing; X : 'x';"))
         "ANTLR importer requires explicit packages")
  (check (signals cnvrs:grammar-error
           (cnvrs/antlr4:parse
            "grammar Same; start : X; X : 'x';"
            :parser-package '#:cnvrs/tests/parser
            :lexer-package '#:cnvrs/tests/parser))
         "ANTLR importer rejects identical parser and lexer packages")
  (check (signals cnvrs:grammar-error
           (cnvrs/antlr4:parse
            "grammar Clash; block : BLOCK; BLOCK : 'x';"
            :parser-package '#:cnvrs/tests/parser
            :lexer-package '#:cnvrs/tests/lexer))
         "ANTLR importer rejects one imported symbol in both roles")
  (let* ((parser (cnvrs:compile-grammar
                  '((start (and item :end)) (item :name))))
         (sink (make-event-sink)))
    (multiple-value-bind (tree repairs)
        (cnvrs:parse parser '(:name :end) :tree-builder sink)
      (check (and (null tree) (null repairs)
                  (equal (reverse (event-sink-events sink))
                         '((:enter start 0) (:enter item 0)
                           (:token :name 0 1) (:exit item 0 1)
                           (:token :end 1 2) (:exit start 0 2))))
             "event-only builder records parsing without creating nodes"))
    (check (and (cnvrs:parser-p parser)
                (eq (type-of parser) 'cnvrs::parser)
                (plusp (length (cnvrs:parser-states parser))))
           "compiled grammar is a parser structure"))
  (let* ((parser (cnvrs:compile-grammar
                  '((expr (or (and expr :bang) :n)))))
         (sink (make-event-sink)))
    (check (null (cnvrs:parse parser '(:n :bang :bang)
                              :tree-builder sink))
           "event-only builder parses rewritten left recursion")
    (check (equal (loop for event in (reverse (event-sink-events sink))
                        when (eq (first event) :token)
                          collect (second event))
                  '(:n :bang :bang))
           "left-recursive event stream contains every consumed token"))
  (let* ((parser (cnvrs:compile-grammar '((start (and :a :b)))))
         (sink (make-event-sink)))
    (multiple-value-bind (tree repairs)
        (cnvrs:parse parser '(:a) :recover t :tree-builder sink)
      (check (and (null tree) (= (length repairs) 1)
                  (some (lambda (event)
                          (and (eq (first event) :token)
                               (cnvrs:inserted-token-p (second event))))
                        (event-sink-events sink)))
             "event-only builder receives recovery tokens")))
  (check (null (cnvrs:parse (cnvrs:compile-grammar '((start :a)))
                            '(:a) :tree-builder :none))
         "built-in :none builder constructs no tree")
  (let* ((source "alpha")
         (token (aref (cnvrs:lex
                       (cnvrs:compile-lexer
                        '((:word (+ (range #\a #\z)))))
                       source) 0)))
    (check (and (eq (cnvrs::lexeme-source token) source)
                (eq (cnvrs::lexeme-stored-text token)
                    cnvrs::+deferred-lexeme-text+)
                (string= (cnvrs:lexeme-text token) "alpha")
                (string= (cnvrs:lexeme-text
                          (cnvrs:make-lexeme :kind :word :text "manual"
                                             :start 0 :end 6))
                         "manual"))
           "lexer defers text copying while explicit text stays available"))
  (let* ((compiled (cnvrs:compile-grammar
                    '((start (and item :end))
                      (item (or (and :a :b) :a)))))
         (interpreted (cnvrs:clone-compiled compiled)))
    (setf (cnvrs:parser-runner interpreted) nil
          (cnvrs:parser-node-runner interpreted) nil)
    (check (and (functionp (cnvrs:parser-runner compiled))
                (functionp (cnvrs:parser-node-runner compiled)))
           "compilation produces recognition and node-building functions")
    (dolist (tokens '((:a :end) (:a :b :end)))
      (check (equalp (cnvrs:parse compiled tokens)
                     (cnvrs:parse interpreted tokens))
             "compiled rule functions produce the same tree")
      (check (and (null (cnvrs:parse compiled tokens :tree-builder :none))
                  (null (cnvrs:parse interpreted tokens :tree-builder :none)))
             "compiled recognition matches the generic parser"))
    (check (equalp (cnvrs:parse compiled '(:a :b :extra)
                                :rule 'item :require-eof nil)
                   (cnvrs:parse interpreted '(:a :b :extra)
                                :rule 'item :require-eof nil))
           "compiled rules support alternate starts and prefix parses")
    (dolist (builder '(:none :node))
      (check (and (signals cnvrs:parse-error
                    (cnvrs:parse compiled '(:a :wrong) :tree-builder builder))
                  (signals cnvrs:parse-error
                    (cnvrs:parse interpreted '(:a :wrong) :tree-builder builder)))
             "invalid input retains generic parser errors")))
  (let* ((names (loop for i below 300
                      collect (make-symbol (format nil "LARGE-RULE-~D" i))))
         (grammar (cnvrs:compile-grammar
                   (cons (list 'start (first names))
                         (loop for (name next) on names
                               collect (list name (if next `(and :x ,next) :x))))))
         (tokens (make-array 300 :initial-element :x))
         (copy (cnvrs:clone-compiled grammar)))
    ;; Call the runners directly: PARSE can fall back to the generic engine.
    (check (funcall (cnvrs:parser-runner grammar) grammar tokens 'start t)
           "separately compiled rules recognize a large rule-call chain")
    (let ((tree (funcall (cnvrs:parser-node-runner copy) copy tokens 'start t)))
      (check (and (eq (cnvrs:node-rule tree) 'start)
                  (= (cnvrs:node-end tree) 300))
             "cloned runners build trees across independently compiled rules"))
    (check (not (funcall (cnvrs:parser-runner grammar)
                        grammar (subseq tokens 0 299) 'start t))
           "separately compiled rules propagate a nested failure")
    (check (funcall (cnvrs:parser-runner grammar) grammar tokens 'start t)
           "failed runner calls leave subsequent parse cursors independent"))
  ;; Reference-runtime integration. Context-specific eager tables and full-LL
  ;; DFA snapshots are deliberately absent from the Java baseline.
  (dolist (case '((((start (and outer :a)) (outer inner) (inner (? :a)))
                   ((:a) (:a :a)))
                  (((start (or (and :a :b :c) (and :a :b :d))))
                   ((:a :b :c) (:a :b :d)))
                  (((start (or (and (token nil) :b :c)
                               (and (token nil) :b :d))))
                   ((nil :b :c) (nil :b :d)))
                  (((start (and (+ :a) :a))) ((:a :a) (:a :a :a)))
                  (((start (and (? :a) :b))) ((:b) (:a :b)))))
    (let* ((grammar (cnvrs:compile-grammar (first case)))
           (generic (cnvrs:clone-compiled grammar)))
      (setf (cnvrs:parser-runner generic) nil (cnvrs:parser-node-runner generic) nil)
      (dolist (input (second case))
        (check (equalp (cnvrs:parse grammar input) (cnvrs:parse generic input))
               "Java predictor agrees across compiled and generic Lisp execution"))
      (check (null (cnvrs::parser-atn-runtime (cnvrs:clone-compiled grammar)))
             "parser clones start with no shared mutable Java runtime")
      (cnvrs:clear-cache grammar)
      (check (every (lambda (dfa) (zerop (hash-table-count (cnvrs/runtime:dfa-states dfa))))
                    (cnvrs/runtime:simulator-decision-dfas
                     (first (cnvrs::parser-atn-runtime grammar))))
             "clear-cache discards the Java decision DFAs")))
  (let* ((grammar (cnvrs:compile-grammar
                   '((start (and item :end)) (item :name))
                   :tree-builder :alternate))
         (tree (cnvrs:parse grammar '(:name :end)))
         (child (first (alternate-node-children tree))))
    (check (and (alternate-node-p tree)
                (eq (alternate-node-rule tree) 'start)
                (alternate-node-p child)
                (eq (alternate-node-rule child) 'item)
                (equal (alternate-node-children child) '(:name))
                (= (alternate-node-start child) 0)
                (= (alternate-node-end tree) 2))
           "custom builder receives nested rule nodes and token offsets")
    (check (cnvrs:node-p
            (cnvrs:parse grammar '(:name :end) :tree-builder :node))
           "parse can override a compiled grammar's tree builder")
    (check (eq (cnvrs:parser-tree-builder
                (cnvrs:clone-compiled grammar)) :alternate)
           "cloning preserves the tree builder"))
  (check (alternate-node-p
          (cnvrs:parse *alternate-parser* '(:name :end)))
         "defparser forwards its tree builder")
  (let* ((grammar (cnvrs:compile-grammar
                   '((expr (or (and expr :bang) :n)))
                   :tree-builder :alternate))
         (tree (cnvrs:parse grammar '(:n :bang :bang))))
    (check (and (alternate-node-p tree)
                (eq (alternate-node-rule tree) 'expr)
                (alternate-node-p
                 (first (alternate-node-children tree)))
                (= (alternate-node-end tree) 3))
           "left-recursion normalization uses the custom builder"))
  (let ((grammar (cnvrs:compile-grammar
                  '((start (and :a :b))) :tree-builder :alternate)))
    (multiple-value-bind (tree repairs)
        (cnvrs:parse grammar '(:a) :recover t)
      (check (and (alternate-node-p tree)
                  (cnvrs:inserted-token-p
                   (second (alternate-node-children tree)))
                  (= (length repairs) 1))
             "recovery tokens flow through the custom builder")))
  (check (and (typep (cnvrs:make-cache :fset) 'cnvrs::fset-cache)
              (typep (cnvrs:make-cache '(:locked :fset))
                     'cnvrs::locked-cache)
              (typep (cnvrs::locked-cache-inner
                      (cnvrs:make-cache '(:locked :fset)))
                     'cnvrs::fset-cache))
         "FSET storage and locking are separate cache layers")
  (let ((keys (list nil -1 0 1 #\a #\b :a :b
                    '(1 2) '(1 2 3) '(1 3)
                    '((1 2) #\a) '((1 2) #\b)
                    '(1 :a) '(1 :b) '(1 . :a) 1/2)))
    (check (loop for left in keys always
             (loop for right in keys always
               (eq (cnvrs::cache-key-compare left right)
                   (fset:compare left right))))
           "specialized cache comparison agrees with FSET ordering"))
  (dolist (backend '(:fset :hash-table))
    (let ((cache (cnvrs:make-cache backend))
          (computations 0))
      (let ((key (cnvrs::flat-cache-key 42 '(17 9))))
        (check (and (typep key '(simple-array fixnum (*)))
                    (equalp key #(42 17 9)))
               "flat cache keys are uniform fixnum vectors"))
      (flet ((lookup (head tail)
               (cnvrs:cache-get-or-compute
                cache (cnvrs::flat-cache-key head tail)
                (lambda () (incf computations)))))
        (check (= (lookup 42 '(17 9)) (lookup 42 '(17 9)) 1)
               "equal flat arrays share one cache entry")
        (check (= (lookup 42 '(17 8)) 2)
               "different flat array contents remain distinct")
        (check (= (lookup 42 '(17)) 3)
               "flat array length distinguishes a prefix")
        (check (= (lookup 43 '(17 9)) 4)
               "flat array head remains part of the key")
        (check (= (cnvrs:cache-get-or-compute
                   cache :ordinary (lambda () (incf computations))) 5)
               "ordinary keys share the cache without collision")
        (check (= (cnvrs:cache-count cache) 5)
               "flat and ordinary entries count toward cache size")
        (cnvrs:cache-clear cache)
        (check (= (cnvrs:cache-count cache) 0)
               "cache clear removes both cache key kinds"))))
  (dolist (backend '(:fset :hash-table (:locked :fset)
                     (:locked :hash-table)))
    (let* ((lexer (cnvrs:compile-lexer '((:a "a") (:b "b"))
                                        :cache-backend backend))
           (grammar (cnvrs:compile-grammar
                     '((start (or :a (and :a :b))))
                     :lexer lexer
                     :cache-backend backend)))
      (check (eq (cnvrs:node-rule (cnvrs:parse grammar "a")) 'start)
             "both cache backends parse compiled lexer output")
      (check (and (plusp (cnvrs:cache-count
                          (cnvrs:compiled-lexer-cache lexer)))
                  (plusp (cnvrs:cache-count
                          (cnvrs:parser-decisions grammar))))
             "lexer and parser both populate their caches")
      (let ((start (cnvrs:cache-get-or-compute
                    (cnvrs:compiled-lexer-cache lexer) :default
                    (lambda () :missing))))
        (check (cnvrs/runtime::lexer-dfa-state-p start)
               "lexer caches its initial DFA state by mode")
        (check (cnvrs/runtime::lexer-dfa-state-p
                (aref (cnvrs/runtime::lexer-dfa-state-edges start)
                      (char-code #\a)))
               "ASCII lexer transitions use direct DFA edges"))
      (let ((copy (cnvrs:clone-compiled grammar)))
        (check (and (equal (cnvrs:parser-cache-backend copy) backend)
                    (zerop (cnvrs:cache-count
                            (cnvrs:parser-decisions copy)))
                    (zerop (cnvrs:cache-count
                            (cnvrs:compiled-lexer-cache
                             (cnvrs:parser-lexer copy)))))
               "clone starts with independent parser and lexer caches"))
      (cnvrs:clear-cache grammar)
      (check (and (zerop (cnvrs:cache-count
                          (cnvrs:parser-decisions grammar)))
                  (zerop (cnvrs:cache-count
                          (cnvrs:compiled-lexer-cache lexer))))
             "one call clears parser and attached lexer caches")
      (check (eq (cnvrs:lexeme-kind (aref (cnvrs:lex lexer "b") 0)) :b)
             "cleared lexer rebuilds its DFA states")))
  (let* ((character (code-char #x03bb))
         (lexer (cnvrs:compile-lexer (list (list :unicode character)))))
    (check (= (length (cnvrs:lex lexer (make-string 2
                                                :initial-element character))) 2)
           "non-ASCII lexer transitions retain the cache fallback"))
  (let* ((grammar (cnvrs:compile-grammar '((start (or :a :b)))))
         (copy (cnvrs:clone-compiled grammar :cache-backend :fset)))
    (check (and (equal (cnvrs:parser-cache-backend grammar)
                       :hash-table)
                (eq (cnvrs:parser-cache-backend copy) :fset)
                (eq (cnvrs:node-rule (cnvrs:parse copy '(:b))) 'start))
           "cloning can select another cache backend"))
  (check (eq (cnvrs:parser-cache-backend
              (cnvrs:ensure-compiled *hash-parser*)) :hash-table)
         "defparser forwards the cache backend")
  (let ((grammar (cnvrs:compile-grammar
                  '((start (or :a (and :a :b))))
                  :cache-backend :test-cache)))
    (check (and (eq (cnvrs:node-rule
                     (cnvrs:parse grammar '(:a))) 'start)
                (plusp (cnvrs:cache-count
                        (cnvrs:parser-decisions grammar))))
           "custom cache factory participates in prediction"))
  (check (typep (cnvrs:make-cache '(:locked :test-cache))
                'cnvrs::locked-cache)
         "lock wrapper composes with a custom backend")
  (dolist (backend '((:locked :fset) (:locked :hash-table)))
    (let* ((lexer (cnvrs:compile-lexer '((:a "a") (:b "b"))
                                        :cache-backend backend))
           (grammar (cnvrs:compile-grammar '((start (or :a :b)))
                                           :lexer lexer :cache-backend backend))
           (threads (loop repeat 6 collect
                      (bt:make-thread
                       (lambda ()
                         (loop repeat 100
                               always (eq (cnvrs:node-rule
                                           (cnvrs:parse grammar "ab"
                                                        :require-eof nil))
                                          'start)))))))
      (check (every #'identity (mapcar #'bt:join-thread threads))
             "lock wrapper supports concurrent parser and lexer use")))
  (let* ((lexer (cnvrs:ensure-compiled *inline-lexer*))
         (copy (cnvrs:clone-compiled lexer)))
    (check (and (cnvrs:compiled-lexer-p lexer)
                (eq lexer (cnvrs:ensure-compiled *inline-lexer*))
                (not (eq lexer copy))
                (eq (cnvrs:compiled-lexer-states lexer)
                    (cnvrs:compiled-lexer-states copy)))
           "lexer compilation returns a cloneable structure")
    (check (eq (cnvrs:lexeme-kind (aref (cnvrs:lex copy "abc") 0)) :name)
           "cloned lexer runs independently")
    (check (eq (cnvrs:clear-cache lexer) lexer)
           "clearing an uncached lexer is safe")
    (check (eq (nth-value 0 (funcall (cnvrs:lexer-matcher lexer)
                                     "abc" 0 :default)) :name)
           "compiled lexer exposes its matcher"))
  (check (cnvrs:parser-p (cnvrs:ensure-compiled *inline-parser*))
         "parser definition can be compiled before parsing")
  (let ((grammar (cnvrs:compile-grammar
                  '((start (or :a (and :a :b)))))))
    (check (and (cnvrs:parser-p grammar)
                (plusp (length (cnvrs:parser-states grammar))))
           "compiled grammar exposes its transition states")
    (cnvrs:parse grammar '(:a))
    (let ((copy (cnvrs:clone-compiled grammar)))
      (check (and (not (eq grammar copy))
                  (eq (cnvrs:parser-states grammar)
                      (cnvrs:parser-states copy))
                  (zerop (cnvrs:cache-count
                          (cnvrs::parser-decisions copy)))
                  (plusp (cnvrs:cache-count
                          (cnvrs::parser-decisions grammar))))
             "parser clone shares its graph but starts with an empty cache")
      (cnvrs:clear-cache grammar)
      (check (zerop (cnvrs:cache-count
                    (cnvrs::parser-decisions grammar)))
             "parser prediction cache can be cleared")))
  (check (cnvrs:parser-definition-p *inline-parser*)
         "single-form parser definition")
  (check (eq (cnvrs:node-rule
               (cnvrs:parse *inline-parser* '(:open :name :close))) 'start)
         "single-form parser grammar")
  (check (eq (cnvrs:node-rule
              (cnvrs:parse *inline-parser* '(:name) :rule 'item)) 'item)
         "any parser rule can be an entry rule")
  (check (signals cnvrs:unexpected-input
           (cnvrs:parse *inline-parser* '(:name :close) :rule 'item))
         "entry rule requires end of input by default")
  (let ((tree (cnvrs:parse *inline-parser* '(:name :close)
                           :rule 'item :require-eof nil)))
    (check (eq (cnvrs:node-rule tree) 'item)
           "entry rule prefix parse")
    (check (= (cnvrs:node-end tree) 1)
           "prefix parse ends after the selected rule"))
  (check (signals cnvrs:grammar-error
           (cnvrs:parse *inline-parser* '(:name) :rule 'missing))
         "unknown entry rule")
  (check (signals cnvrs:grammar-error
           (cnvrs:parse *inline-parser* '(:name)
                        :rule 'item :start 'start))
         "conflicting entry rule aliases")
  (check (eq (cnvrs:node-rule
              (first (cnvrs:node-children
                       (cnvrs:parse *package-parser* '(:name :end)
                                    :rule 'start))))
             'item)
         "package-style parser with forward reference")
  (check (eq (cnvrs:node-rule
              (cnvrs:parse *package-parser* '(:name))) 'item)
         "macro default-rule chooses a nonfirst parser rule")
  (check (equal (map 'list #'cnvrs:lexeme-kind
                     (cnvrs:lex *inline-lexer* "a bc"))
                '(:name :name))
         "single-form lexer grammar")
  (check (equal (map 'list #'cnvrs:lexeme-kind
                     (cnvrs:lex *package-lexer* "12 3"))
                '(:number :number))
         "package-style lexer grammar")
  (check (equal (map 'list #'cnvrs:lexeme-kind
                     (cnvrs:lex *mode-package-lexer* "<name>"))
                '(:tag))
         "package-style with-mode defines lexer rules")
  (check (equal (map 'list #'cnvrs:lexeme-kind
                     (cnvrs:lex *mode-inline-lexer* "<name>"))
                '(:tag))
         "inline with-mode accepts bare lexer rules")
  (check (signals cnvrs:grammar-error
           (macroexpand-1
            '(cnvrs:with-mode :tag
               (cnvrs:defrule :name #\a :mode :other))))
         "with-mode rejects a conflicting rule mode")
  (check (signals cnvrs:grammar-error
           (cnvrs:parse *inline-lexer* "abc"))
         "lexer grammar cannot be parsed as a parser")
  (check (equal (mapcar #'cnvrs:lexeme-kind
                        (cnvrs:node-children
                         (cnvrs:parse *inline-combined* "x=42")))
                '(:name :equals :number))
         "single-form combined grammar")
  (check (equal (mapcar #'cnvrs:lexeme-kind
                        (cnvrs:node-children
                         (cnvrs:parse *package-combined* "let x = 42")))
                '(:let :name :equals :number))
         "package-style combined grammar")
  (check (equal (cnvrs:node-children
                 (cnvrs:parse *bare-parser* '(:a :b))) '(:a :b))
         "bare rule forms inside defparser")
  (check (eq (cnvrs:lexeme-kind
               (first (cnvrs:node-children
                       (cnvrs:parse *external-lexer-parser* "hello"))))
             :word)
         "parser macro accepts external lexer option")
  (check (eq (cnvrs:lexeme-kind
               (first (cnvrs:node-children
                       (cnvrs:parse *symbol-lexer-combined* "hello"))))
             'word)
         "combined grammar explicit symbol lexer rule")
  (check (equal (mapcar #'cnvrs:lexeme-kind
                        (cnvrs:node-children
                         (cnvrs:parse *mode-combined* "a \"bc\" d")))
                '(:word :string-text :word))
         "combined grammar uses lexer modes")
  (let* ((lexer (cnvrs:compile-lexer
                 '((:open #\" :push-mode :string)
                   (:word (+ (range #\a #\z)) :mode :string)
                   (:brace-open #\{ :mode :string
                    :push-mode :interpolation)
                   (:name (+ (range #\a #\z)) :mode :interpolation)
                   (:brace-close #\} :mode :interpolation :pop-mode t)
                   (:close #\" :mode :string :pop-mode t)
                   (:outside (+ (range #\a #\z))))))
         (tokens (cnvrs:lex lexer "\"ab{cd}ef\"gh")))
    (check (equal (map 'list #'cnvrs:lexeme-kind tokens)
                  '(:open :word :brace-open :name :brace-close :word
                    :close :outside))
           "pushed lexer modes restore their callers")
    (check (equal (map 'list #'cnvrs:lexeme-text tokens)
                  '("\"" "ab" "{" "cd" "}" "ef" "\"" "gh"))
           "mode-specific tokens retain source text"))
  (let ((lexer (cnvrs:compile-lexer
                '((:open #\< :set-mode :tag)
                  (:tag (+ (range #\a #\z)) :mode :tag)
                  (:close #\> :mode :tag :set-mode :default)
                  (:word (+ (range #\a #\z)))))))
    (check (equal (map 'list #'cnvrs:lexeme-kind
                       (cnvrs:lex lexer "<ab>cd"))
                  '(:open :tag :close :word))
           "set-mode changes the active mode without a stack"))
  (check (signals cnvrs:lexer-mode-error
           (cnvrs:lex (cnvrs:compile-lexer '((:close #\] :pop-mode t))) "]"))
         "pop-mode on an empty stack signals a mode error")
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-lexer '((:open #\" :push-mode :missing))))
         "mode action target must have a lexer rule")
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-lexer '((:open #\< :push-mode :tag
                                   :set-mode :tag)
                                  (:tag #\a :mode :tag))))
         "lexer rule cannot perform multiple mode actions")
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-lexer '((:default #\a)
                                  (:empty (? #\b) :mode :other))))
         "rules in nondefault modes must consume input")
  (check (eq (cnvrs:node-rule
              (cnvrs:parse *inline-parser* '(:name) :start 'item))
             'item)
         "legacy start keyword remains supported")
  (let* ((grammar (cnvrs:compile-grammar
                   '((start (and #\a (* #\b) #\c)))))
         (tree (cnvrs:parse grammar "abbbc")))
    (check (eq (cnvrs:node-rule tree) 'start) "root rule")
    (check (equal (cnvrs:node-children tree)
                  '(#\a #\b #\b #\b #\c)) "repetition and token order")
    (check (null (cnvrs:node-label tree))
           "unlabeled rule nodes have no label")
    (check (= (cnvrs:node-end tree) 5) "end position")
    (check (signals cnvrs:parse-error (cnvrs:parse grammar "abbd"))
           "unexpected token"))
  (let* ((grammar (cnvrs:compile-grammar
                   '((start (or (alt-label first (and (label item :a) :b))
                                (alt-label second :c))))))
         (tree (cnvrs:parse grammar '(:a :b)))
         (child (first (cnvrs:node-children tree))))
    (check (and (eq (cnvrs:node-label tree) 'first)
                (eq (cnvrs:node-label child) 'item)
                (equal (cnvrs:node-children child) '(:a))
                (eq (second (cnvrs:node-children tree)) :b))
           "CNVRS labels attach to alternative and element nodes")
    (check (eq (cnvrs:node-label (cnvrs:parse grammar '(:c))) 'second)
           "CNVRS chooses the matched alternative label")
    (check (and (= (cnvrs:node-start child) 0)
                (= (cnvrs:node-end child) 1))
           "labeled element node retains token offsets"))
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-grammar '((start (label :invalid :a)))))
         "CNVRS rejects a keyword label")
  (let ((grammar (cnvrs:compile-grammar
                  '((document (and item #\!))
                    (item #\a))
                  :default-rule 'item)))
    (check (eq (cnvrs:node-rule
                (cnvrs:parse grammar "a")) 'item)
           "compile-grammar default-rule chooses a nonfirst rule")
    (check (eq (cnvrs:node-rule
                (first (cnvrs:node-children
                        (cnvrs:parse grammar "a!" :rule 'document))))
               'item)
           "nested rule invocation does not require EOF")
    (check (eq (cnvrs:node-rule
                (cnvrs:parse grammar "a" :rule 'item)) 'item)
           "compiled grammar supports any entry rule")
    (check (signals cnvrs:unexpected-input
             (cnvrs:parse grammar "a!" :rule 'item))
           "compiled grammar entry rule enforces EOF")
    (check (= (cnvrs:node-end
               (cnvrs:parse grammar "a!" :rule 'item
                            :require-eof nil)) 1)
           "compiled grammar can parse a prefix"))
  (let* ((grammar (cnvrs:compile-grammar
                   '((start (or (and #\a #\b #\c)
                                (and #\a #\b #\d))))))
         (tree (cnvrs:parse grammar "abd")))
    (check (equal (cnvrs:node-children tree) '(#\a #\b #\d))
           "lookahead past shared prefix"))
  (let* ((grammar (cnvrs:compile-grammar
                   '((start (and item #\b))
                     (item (or #\a (and #\a #\b))))))
         (tree (cnvrs:parse grammar "abb")))
    (check (eq (cnvrs:node-rule (first (cnvrs:node-children tree))) 'item)
           "rule node")
    (check (equal (cnvrs:node-children
                   (first (cnvrs:node-children tree))) '(#\a #\b))
           "caller context chooses longer alternative")
    (check (plusp (cnvrs:cache-count (cnvrs:parser-decisions grammar)))
           "adaptive prediction exposes its shared decision DFA")
    (check (equal (cnvrs:node-children
                   (first (cnvrs:node-children
                           (cnvrs:parse grammar "ab")))) '(#\a))
           "cached decision adapts to another input")
    (check (signals cnvrs:parse-error (cnvrs:parse grammar "aab"))
           "full context and end of input"))
  ;; Java persists SLL DFAs, not full-context traces or caller-stack results.
  (let* ((grammar (cnvrs:compile-grammar
                   '((start (and #\l (* element) #\r))
                     (element (or #\x start)))))
         (tree (cnvrs:parse grammar "llxrr")))
    (check (= (cnvrs:node-end tree) 5) "nested recursion"))
  (let* ((grammar (cnvrs:compile-grammar
                   '((start (and (token :open) (+ thing) (token :close)))
                     (thing (or (token :a) (token :b))))))
         (tree (cnvrs:parse grammar '(:open :a :b :close))))
    (check (= (length (cnvrs:node-children tree)) 4)
           "symbol tokens and plus"))
  (check (equal (cnvrs:node-children
                 (cnvrs:parse (cnvrs:compile-grammar '((start :ok))) '(:ok)))
                '(:ok))
         "keyword literal")
  (check (signals cnvrs:grammar-error
            (cnvrs:compile-grammar '((start missing))))
         "undefined rule")
  (check (signals cnvrs:grammar-error
            (cnvrs:compile-grammar '((start (and (? #\a) (* (? #\b)))))))
         "nullable repetition")
  (let* ((grammar (cnvrs:compile-grammar
                   '((expr (or (and expr :+ expr)
                               (and expr :* expr)
                               (and :open expr :close)
                               :n)))))
         (tree (cnvrs:parse grammar '(:n :+ :n :* :n))))
    (check (equal (mapcar (lambda (child)
                            (if (cnvrs:node-p child) (cnvrs:node-rule child) child))
                          (cnvrs:node-children tree))
                  '(expr :+ expr))
           "direct left recursion retains rule nodes")
    (check (eq (second (cnvrs:node-children
                        (third (cnvrs:node-children tree)))) :*)
           "later recursive alternative has higher precedence")
    (check (eq (second (cnvrs:node-children
                        (cnvrs:parse grammar '(:n :* :n :+ :n)))) :+)
           "precedence works in both orders")
    (check (eq (second (cnvrs:node-children
                        (cnvrs:parse grammar '(:open :n :+ :n :close :* :n))))
               :*)
           "parenthesized base can contain a full expression"))
  (let* ((grammar (cnvrs:compile-grammar
                   '((expr (or (right (and expr :^ expr)) :n)))))
         (tree (cnvrs:parse grammar '(:n :^ :n :^ :n))))
    (check (eq (second (cnvrs:node-children
                        (third (cnvrs:node-children tree)))) :^)
           "right associative recursive alternative"))
  (let* ((grammar (cnvrs:compile-grammar
                   '((expr (or (and expr :bang) :n)))))
         (tree (cnvrs:parse grammar '(:n :bang :bang))))
    (check (and (eq (second (cnvrs:node-children tree)) :bang)
                (cnvrs:node-p (first (cnvrs:node-children tree)))
                (= (cnvrs:node-end tree) 3))
           "postfix alternative folds left and preserves offsets")
    (handler-case (cnvrs:parse grammar '(:n :bang :bad))
      (cnvrs:parse-error (condition)
        (check (eq (cnvrs:parse-error-rule condition) 'expr)
               "rewritten rule reports original name"))))
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-grammar '((expr (or (and expr (? :bang)) :n)))))
         "nullable recursive suffix rejected")
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-grammar '((a (or (and b :x) :n))
                                    (b a))))
         "indirect left recursion remains invalid")
  (let ((grammar (cnvrs:compile-grammar
                  '((start (and #\a #\b #\c))))))
    (check (signals cnvrs:mismatched-token (cnvrs:parse grammar "ac"))
           "strict mismatch condition")
    (multiple-value-bind (tree repairs) (cnvrs:parse grammar "ac" :recover t)
      (let ((inserted (second (cnvrs:node-children tree))))
        (check (and (cnvrs:inserted-token-p inserted)
                    (eql (cnvrs:inserted-token-expected inserted) #\b)
                    (= (cnvrs:inserted-token-position inserted) 1))
               "automatic missing-token insertion")
        (check (and (= (length repairs) 1)
                    (eq (cnvrs:recovery-action (first repairs)) :insert-tokens)
                    (= (length (cnvrs:recovery-token (first repairs))) 1)
                    (typep (cnvrs:recovery-condition (first repairs))
                           'cnvrs:mismatched-token))
               "insertion diagnostic")))
    (multiple-value-bind (tree repairs) (cnvrs:parse grammar "axbc" :recover t)
      (check (equal (cnvrs:node-children tree) '(#\a #\b #\c))
             "automatic extra-token deletion")
      (check (and (= (length repairs) 1)
                  (eq (cnvrs:recovery-action (first repairs)) :delete-tokens)
                  (equal (cnvrs:recovery-token (first repairs)) '(#\x)))
             "deletion diagnostic"))
    (multiple-value-bind (tree repairs)
        (handler-bind
            ((cnvrs:mismatched-token
               (lambda (condition)
                 (when (eql (cnvrs:parse-error-expected condition) #\b)
                   (invoke-restart 'cnvrs:delete-tokens 2)))))
          (cnvrs:parse grammar "axybc"))
      (check (and (equal (cnvrs:node-children tree) '(#\a #\b #\c))
                  (equal (cnvrs:recovery-token (first repairs)) '(#\x #\y)))
             "delete two tokens with one restart"))
    (multiple-value-bind (tree repairs)
        (handler-bind
            ((cnvrs:mismatched-token
               (lambda (condition)
                 (declare (ignore condition))
                 (invoke-restart 'cnvrs:insert-tokens))))
          (cnvrs:parse grammar "ac"))
      (check (and (cnvrs:inserted-token-p
                   (second (cnvrs:node-children tree)))
                  (= (length repairs) 1))
             "handler invokes insertion restart without automatic mode"))
    (check (signals cnvrs:mismatched-token
              (cnvrs:parse grammar "axz" :recover t))
           "automatic recovery declines uncertain repair"))
  (let ((grammar (cnvrs:compile-grammar '((start (or #\a #\b))))))
    (check (signals cnvrs:no-viable-alternative
              (cnvrs:parse grammar "xa"))
           "failed choice condition")
    (multiple-value-bind (tree repairs) (cnvrs:parse grammar "xa" :recover t)
      (check (equal (cnvrs:node-children tree) '(#\a))
             "choice resynchronization")
      (check (eq (cnvrs:recovery-action (first repairs)) :delete-tokens)
             "choice diagnostic"))
    (multiple-value-bind (tree repairs)
        (handler-bind
            ((cnvrs:no-viable-alternative
               (lambda (condition)
                 (declare (ignore condition))
                 (invoke-restart 'cnvrs:delete-tokens 2))))
          (cnvrs:parse grammar "xya"))
      (check (and (equal (cnvrs:node-children tree) '(#\a))
                  (equal (cnvrs:recovery-token (first repairs)) '(#\x #\y)))
             "delete two tokens before retrying a choice"))
    (check (signals simple-error
              (handler-bind
                  ((cnvrs:no-viable-alternative
                     (lambda (condition)
                       (declare (ignore condition))
                       (invoke-restart 'cnvrs:insert-tokens))))
                (cnvrs:parse grammar "x")))
           "choice insertion requires explicit values")
    (multiple-value-bind (tree repairs)
        (handler-bind
            ((cnvrs:no-viable-alternative
               (lambda (condition)
                 (check (eq (cnvrs:parse-error-rule condition) 'start)
                        "condition rule")
                 (invoke-restart 'cnvrs:choose-alternative 1)))
             (cnvrs:mismatched-token
               (lambda (condition)
                 (if (eq (cnvrs:parse-error-token condition)
                         cnvrs:+end-of-input+)
                     (invoke-restart 'cnvrs:insert-tokens)
                     (invoke-restart 'cnvrs:delete-tokens)))))
          (cnvrs:parse grammar "x"))
      (check (and (cnvrs:inserted-token-p
                   (first (cnvrs:node-children tree)))
                  (equal (mapcar #'cnvrs:recovery-action repairs)
                         '(:choose-alternative :delete-tokens :insert-tokens)))
             "manual restarts compose")))
  (let ((grammar (cnvrs:compile-grammar '((start #\a)))))
    (check (signals cnvrs:unexpected-input (cnvrs:parse grammar "ab"))
           "trailing input condition")
    (multiple-value-bind (tree repairs) (cnvrs:parse grammar "ab" :recover t)
      (check (and (= (cnvrs:node-end tree) 1)
                  (eq (cnvrs:recovery-action (first repairs)) :discard-input))
             "trailing input recovery")))
  (let ((grammar (cnvrs:compile-grammar
                  '((start (and (* #\a) #\b))))))
    (multiple-value-bind (tree repairs) (cnvrs:parse grammar "" :recover t)
      (check (and (= (length (cnvrs:node-children tree)) 1)
                  (eql (cnvrs:inserted-token-expected
                        (first (cnvrs:node-children tree))) #\b)
                  (= (length repairs) 1))
             "repetition exits before end-of-input insertion")))
  (let ((grammar (cnvrs:compile-grammar
                  '((start (or (and #\a start) #\b))))))
    (check (signals cnvrs:mismatched-token
              (cnvrs:parse grammar "" :recover t))
           "automatic recovery terminates on recursive missing suffix"))
  (let ((grammar (cnvrs:compile-grammar
                  '((start (and #\a #\b #\c #\d #\e))))))
    (multiple-value-bind (tree repairs)
        (handler-bind
            ((cnvrs:mismatched-token
               (lambda (condition)
                 (when (eql (cnvrs:parse-error-expected condition) #\b)
                   (invoke-restart 'cnvrs:insert-tokens '(#\b #\c #\d))))))
          (cnvrs:parse grammar "ae"))
      (let ((children (cnvrs:node-children tree)))
        (check (equal (mapcar (lambda (child)
                                (if (cnvrs:inserted-token-p child)
                                    (cnvrs:inserted-token-value child)
                                    child))
                              children)
                      '(#\a #\b #\c #\d #\e))
               "three inserted tokens are parsed normally")
        (check (and (every (lambda (child)
                             (= (cnvrs:inserted-token-position child) 1))
                           (subseq children 1 4))
                    (= (cnvrs:node-end tree) 2))
               "insertions preserve original source offsets")
        (check (and (= (length repairs) 1)
                    (eq (cnvrs:recovery-action (first repairs)) :insert-tokens)
                    (= (length (cnvrs:recovery-token (first repairs))) 3))
               "sequence recovery record"))))
  (let ((grammar (cnvrs:compile-grammar
                  '((start (and #\a (or (and #\b #\c)
                                       (and #\b #\d)) #\e))))))
    (multiple-value-bind (tree repairs)
        (handler-bind
            ((cnvrs:no-viable-alternative
               (lambda (condition)
                 (declare (ignore condition))
                 (invoke-restart 'cnvrs:insert-tokens '(#\b #\c)))))
          (cnvrs:parse grammar "ae"))
      (check (and (= (length (cnvrs:node-children tree)) 4)
                  (equal (mapcar #'cnvrs:recovery-action repairs)
                         '(:insert-tokens)))
             "inserted lookahead resolves a choice")))
  (let ((grammar (cnvrs:compile-grammar
                  '((start (and :open body :close))
                    (body (and :name :colon :value))))))
    (multiple-value-bind (tree repairs)
        (handler-bind
            ((cnvrs:mismatched-token
               (lambda (condition)
                 (when (eq (cnvrs:parse-error-expected condition) :name)
                   (invoke-restart 'cnvrs:insert-tokens
                                   '(:name :colon :value))))))
          (cnvrs:parse grammar '(:open :close)))
      (let ((body (second (cnvrs:node-children tree))))
        (check (and (eq (cnvrs:node-rule body) 'body)
                    (= (cnvrs:node-start body) 1)
                    (= (cnvrs:node-end body) 1)
                    (every #'cnvrs:inserted-token-p
                           (cnvrs:node-children body))
                    (= (length repairs) 1))
               "sequence insertion inside a called rule"))))
  (let* ((lexer (cnvrs:compile-lexer
                 '((:space (+ (one-of " ")) :skip t)
                   (:keyword "let")
                   (:identifier (and (or (range #\a #\z) #\_)
                                     (* (or (range #\a #\z)
                                            (range #\0 #\9) #\_))))
                   (:equals #\=)
                   (:number (+ (range #\0 #\9))))))
         (grammar (cnvrs:compile-grammar
                   '((start (and :keyword :identifier :equals :number)))
                   :lexer lexer))
         (tree (cnvrs:parse grammar "let answer = 42"))
         (children (cnvrs:node-children tree)))
    (check (equal (mapcar #'cnvrs:lexeme-kind children)
                  '(:keyword :identifier :equals :number))
           "generated lexer feeds parser")
    (check (equal (mapcar #'cnvrs:lexeme-text children)
                  '("let" "answer" "=" "42"))
           "lexeme text and skipped whitespace")
    (check (and (= (cnvrs:lexeme-start (second children)) 4)
                (= (cnvrs:lexeme-end (second children)) 10)
                (= (cnvrs:node-end tree) 4))
           "source offsets and token offsets")
    (check (eq (cnvrs:lexeme-kind
                (aref (cnvrs:lex lexer "letter") 0)) :identifier)
           "longest match outranks earlier rule")
    (check (eq (cnvrs:lexeme-kind
                (aref (cnvrs:lex lexer "let") 0)) :keyword)
           "rule order breaks equal-length ties")
    (check (signals cnvrs:lexical-error (cnvrs:lex lexer "let @"))
           "unmatched character signals lexical error")
    (handler-case (cnvrs:lex lexer "let @")
      (cnvrs:lexical-error (condition)
        (check (and (= (cnvrs:lexical-error-position condition) 4)
                    (char= (cnvrs:lexical-error-character condition) #\@))
               "lexical error reports source location")))
    (let ((choice (cnvrs:compile-grammar
                   '((start (or (and :keyword :identifier)
                                (and :keyword :number))))
                   :lexer lexer)))
      (check (eq (cnvrs:lexeme-kind
                  (second (cnvrs:node-children
                           (cnvrs:parse choice "let 42")))) :number)
             "lookahead uses lexeme kinds")))
  (let* ((handwritten (lambda (source)
                        (declare (ignore source))
                        (vector (cnvrs:make-lexeme :kind :a :text "a"
                                                   :start 0 :end 1)
                                :b)))
         (grammar (cnvrs:compile-grammar
                   '((start (and :a :b))) :lexer handwritten))
         (tree (cnvrs:parse grammar "ab")))
    (check (and (cnvrs:lexeme-p (first (cnvrs:node-children tree)))
                (eq (second (cnvrs:node-children tree)) :b))
           "handwritten lexer can return lexemes and plain tokens")
    (check (equal (cnvrs:node-children
                   (cnvrs:parse grammar "ignored"
                                :lexer (lambda (source)
                                         (declare (ignore source))
                                         '(:a :b))))
                  '(:a :b))
           "parse-time lexer override"))
  (let* ((lexer (cnvrs:compile-lexer
                 '((:digit (range #\0 #\9))
                   (:integer (+ :digit)))))
         (tokens (cnvrs:lex lexer "123")))
    (check (and (= (length tokens) 1)
                (eq (cnvrs:lexeme-kind (aref tokens 0)) :integer))
           "lexer rule reference and longest match"))
  (let* ((lexer (cnvrs:compile-lexer
                 '((:a "a")
                   (:space (+ (one-of " ")) :channel :trivia)
                   (:b "b")
                   (:ignored "!" :channel :trivia :skip t))))
         (tokens (cnvrs:lex lexer "a b!"))
         (grammar (cnvrs:compile-grammar
                   '((start (and :a :b))) :lexer lexer)))
    (check (equal (map 'list #'cnvrs:lexeme-channel tokens)
                  '(:default :trivia :default))
           "generated lexer retains named channels and skips tokens")
    (check (equal (mapcar #'cnvrs:lexeme-kind
                          (cnvrs:node-children (cnvrs:parse grammar "a b!")))
                  '(:a :b))
           "parser selects default channel")
    (let ((all-grammar (cnvrs:compile-grammar
                        '((start (and :a :space :b))) :lexer lexer)))
      (check (equal (mapcar #'cnvrs:lexeme-kind
                            (cnvrs:node-children
                             (cnvrs:parse all-grammar "a b!" :channels :all)))
                    '(:a :space :b))
             "parser can include every channel")
      (check (equal (mapcar #'cnvrs:lexeme-kind
                            (cnvrs:node-children
                             (cnvrs:parse all-grammar "a b!"
                                          :channels '(:default :trivia))))
                    '(:a :space :b))
             "parser can select named channels")))
  (let* ((hidden (cnvrs:make-lexeme :kind :space :channel :trivia))
         (tokens (vector hidden :a hidden :c hidden))
         (visible (vector :a :c))
         (grammar (cnvrs:compile-grammar
                   '((start (or (and :a :b) (and :a :c))))))
         (input (cnvrs::make-token-input tokens '(:default))))
    (check (and (cnvrs::filtered-token-input-p input)
                (eq (cnvrs::filtered-token-input-tokens input) tokens)
                (eq (cnvrs::filtered-token-input-tokens
                     (cnvrs::make-token-input visible '(:default)))
                    visible)
                (eq (cnvrs::make-token-input visible :all) visible))
           "filtered input retains the original token vector")
    (let ((tree (cnvrs:parse grammar tokens)))
      (check (and (equal (cnvrs:node-children tree) '(:a :c))
                  (= (cnvrs:node-start tree) 0)
                  (= (cnvrs:node-end tree) 2))
             "compiled lookahead skips leading, middle, and trailing channels"))
    (check (null (cnvrs:parse grammar tokens :tree-builder :none))
           "recognition runner skips filtered channels")
    (let ((recovery-grammar (cnvrs:compile-grammar
                             '((start (and :a :c)))))
          (with-extra (vector hidden :a hidden :x hidden :c hidden)))
      (multiple-value-bind (tree repairs)
          (cnvrs:parse recovery-grammar with-extra :recover t)
        (check (and (= (cnvrs:node-end tree) 3)
                    (equal (cnvrs:node-children tree) '(:a :c))
                    (equal (cnvrs:recovery-token (first repairs)) '(:x))
                    (= (cnvrs:parse-error-position
                        (cnvrs:recovery-condition (first repairs))) 1))
               "recovery counts visible tokens while skipping channels")))
    (let* ((seen nil)
           (semantic (cnvrs:compile-grammar
                      (list (list 'start
                                  (list 'and
                                        (list 'predicate
                                              (lambda (input position)
                                                (and (cnvrs::filtered-token-input-p input)
                                                     (eq (cnvrs::filtered-token-input-tokens input)
                                                         tokens)
                                                     (= (cnvrs:input-token-count input) 2)
                                                     (= position 0)
                                                     (eq (cnvrs:input-token-at input 0) :a)
                                                     (eq (cnvrs:input-token-at input 1) :c))))
                                        :a
                                        (list 'action
                                              (lambda (input position)
                                                (setf seen (and (= position 1)
                                                                (eq (cnvrs:input-token-at
                                                                     input position) :c)))))
                                        :c))))))
      (check (and (= (cnvrs:node-end (cnvrs:parse semantic tokens)) 2)
                  seen)
             "semantic callbacks retain visible-token positions"))
    (let* ((failure (cnvrs:compile-grammar
                     (list (list 'start
                                 (list 'or :a
                                       (list 'and :a :c
                                             (list 'predicate
                                                   (lambda (input position)
                                                     (declare (ignore input position))
                                                     t))))))))
           (bad (vector hidden :a hidden :x hidden))
           (condition (handler-case (progn (cnvrs:parse failure bad) nil)
                        (cnvrs:parse-error (error) error))))
      (check (and condition
                  (= (cnvrs:parse-error-position condition) 1)
                  (eq (cnvrs:parse-error-token condition) :x))
             "semantic parse errors use visible-token positions")))
  (let* ((handwritten (lambda (source)
                        (declare (ignore source))
                        (vector (cnvrs:make-lexeme :kind :comment :text "#"
                                                   :start 0 :end 1
                                                   :channel :comments)
                                :a)))
         (grammar (cnvrs:compile-grammar '((start :a)) :lexer handwritten)))
    (check (equal (cnvrs:node-children (cnvrs:parse grammar "#a")) '(:a))
           "hand-written lexer channels are filtered")
    (check (eq (cnvrs:lexeme-channel
                (first (cnvrs:node-children
                        (cnvrs:parse
                         (cnvrs:compile-grammar '((start :comment)) :lexer handwritten)
                         "#a" :channels '(:comments)))))
               :comments)
           "hand-written lexer channel can be selected"))
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-lexer '((:a "a" :channel 17))))
         "lexer channel name must be a symbol")
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-lexer '((:empty (* #\a)))))
         "zero-length lexer rule rejected")
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-lexer '((:a :b) (:b :a))))
         "lexer recursion without progress rejected")
  (let ((lexer (cnvrs:compile-lexer
                '((:block (and #\{ (* (or :block (not-one-of "{}"))) #\}))
                  (:other (any))))))
    (check (equal (map 'list #'cnvrs:lexeme-text
                       (cnvrs:lex lexer "{a{b}c}x"))
                  '("{a{b}c}" "x"))
           "direct recursive lexer rule balances delimiters")
    (check (equal (map 'list #'cnvrs:lexeme-kind
                       (cnvrs:lex lexer "{a{b}c}x"))
                  '(:block :other))
           "recursive lexer rule competes with ordinary rules"))
  (let ((lexer (cnvrs:compile-lexer
                '((:outer (and #\[ :inner #\]))
                  (:inner (or #\x (and #\( :outer #\))))
                  (:other (any))))))
    (check (equal (map 'list #'cnvrs:lexeme-text
                       (cnvrs:lex lexer "[( [x] )]"))
                  '("[" "(" " " "[x]" " " ")" "]"))
           "invalid nesting falls back to other rules")
    (check (equal (map 'list #'cnvrs:lexeme-text
                       (cnvrs:lex lexer "[([x])]"))
                  '("[([x])]"))
           "indirect recursive lexer rules match nested input"))
  (check (signals cnvrs:grammar-error
           (cnvrs:compile-lexer '((:a (or (and :a #\x) #\a)))))
         "left recursive lexer rule rejected")
  (multiple-value-bind (lexer match)
      (cnvrs:compile-lexer '((:long "ab") (:short "a")))
    (declare (ignore lexer))
    (multiple-value-bind (kind end)
        (funcall match "abc" 0 :default)
      (check (and (eq kind :long) (= end 2))
             "lexer matcher returns one longest token")))
  (let ((grammar (cnvrs:compile-grammar
                  '((start (or :a (not-token (:a :b)))))))
        (reversed (cnvrs:compile-grammar
                   '((start (or (not-token (:a :b)) :a))))))
    (check (cnvrs:node-p (cnvrs:parse grammar '(:c)))
           "negated token set accepts a token outside the set")
    (check (cnvrs:node-p (cnvrs:parse reversed '(:a)))
           "negated token prediction respects a later positive alternative")
    (check (signals cnvrs:parse-error (cnvrs:parse grammar '(:b)))
           "negated token set rejects excluded tokens")
    (check (signals cnvrs:parse-error (cnvrs:parse grammar '()))
           "negated token set does not consume end of input"))
  (let* ((directory (merge-pathnames "test/fixtures/"
                                     (asdf:system-source-directory :cnvrs)))
         (parser-path (merge-pathnames "ANTLRv4Parser.g4" directory))
         (lexer-path (merge-pathnames "ANTLRv4Lexer.g4" directory)))
    (check (cnvrs:parser-definition-p cnvrs/antlr4:*parser*)
           "ANTLR4 parser uses DEFINE-PARSER")
    (check (cnvrs:parser-definition-p cnvrs/antlr4:*lexer*)
           "ANTLR4 lexer uses DEFINE-PARSER")
    (let ((base-tokens (cnvrs:lex cnvrs/antlr4:*lexer*
                                  "'x' // comment
options {")))
      (check (equal (map 'list #'cnvrs:lexeme-kind base-tokens)
                    '(:string_literal :ws :line_comment :ws :options))
             "declarative lexer handles strings, comments, and options"))
    (dolist (path (list parser-path lexer-path))
      (let ((tree (cnvrs/antlr4:parse-tree (uiop:read-file-string path))))
        (check (eq (cnvrs:node-rule tree)
                   'cnvrs/antlr4::grammar-spec)
               (format nil "ANTLR4 parses ~A" (file-namestring path)))))
    (let* ((source "grammar T; start [int x] : ID EOF; ID : [a-z]+;")
           (tokens (cnvrs/antlr4:lex source))
           (kinds (map 'list #'cnvrs:lexeme-kind tokens)))
      (check (member :begin_argument kinds)
             "parser-rule bracket starts an argument")
      (check (member :lexer_char_set kinds)
             "lexer-rule bracket is a character set")
      (check (eq (cnvrs:node-rule (cnvrs/antlr4:parse-tree source))
                 'cnvrs/antlr4::grammar-spec)
             "ANTLR4 parses grammar with arguments and character set")
      (check (signals cnvrs:parse-error
               (cnvrs/antlr4:parse-tree "grammar T; start : ID"))
             "ANTLR4 parser rejects missing rule terminator")
      (check (cnvrs:node-p
              (cnvrs/antlr4:parse-tree
               "grammar Café; règle : TOKEN; TOKEN : 'x';"))
             "ANTLR4 parser accepts Unicode identifiers")
      (check (cnvrs:node-p
              (cnvrs/antlr4:parse-tree
               "grammar T; r : ID { f(\"}\"); {g();} }; ID : 'x';"))
             "ANTLR4 adaptor balances nested actions and quoted braces")
      (check (cnvrs:node-p
              (cnvrs/antlr4:parse-tree
               "grammar T; r : ID { a=`}`; b=\"\"\"}\"\"\"; }; ID : 'x';"))
             "ANTLR4 adaptor handles backtick and triple quoted actions"))
    (let* ((grammar (antlr-parse
                     "grammar Tiny; start : 'let' ID EOF; fragment LETTER : [a-z]; ID : LETTER+; WS : [ ]+ -> skip;"))
           (compiled (cnvrs:ensure-compiled grammar)))
      (check (cnvrs:parser-definition-p grammar)
             "ANTLR4 conversion returns a grammar definition")
      (check (cnvrs:parser-p compiled)
             "ANTLR4 grammar compiles")
      (check (eq (cnvrs:node-rule (cnvrs:parse grammar "let abc"))
                 'cnvrs/antlr4::start)
             "ANTLR4 grammar parses input")
      (check (signals cnvrs:parse-error (cnvrs:parse grammar "let abc abc"))
             "ANTLR4 grammar rejects invalid input"))
    (let* ((source (uiop:read-file-string
                    (merge-pathnames "JSON.g4" directory)))
           (grammar (antlr-parse source))
           (compiled (cnvrs:ensure-compiled grammar)))
      (check (cnvrs:parser-p compiled)
             "grammars-v4 JSON grammar compiles unchanged")
      (dolist (input '("null" "-0.25e+2" "{}" "[]"
                       "{\"x\": [1, true, null]}"
                       "{\"escaped\": \"a\\n\\u0041\"}"))
        (check (eq (cnvrs:node-rule (cnvrs:parse compiled input))
                   'cnvrs/antlr4::json)
               (format nil "grammars-v4 JSON accepts ~S" input)))
      (dolist (input '("01" "[1,]" "{\"x\":}" "\"\\q\""))
        (check (signals error (cnvrs:parse compiled input))
               (format nil "grammars-v4 JSON rejects ~S" input)))
      (check (signals cnvrs:lexical-error
               (cnvrs:parse compiled
                            (format nil "\"a~C\"" (code-char 31))))
             "grammars-v4 JSON excludes unescaped control characters"))
    (let* ((source (uiop:read-file-string
                    (merge-pathnames "IRI.g4" directory)))
           (grammar (antlr-parse source))
           (compiled (cnvrs:ensure-compiled grammar)))
      (check (cnvrs:parser-p compiled)
             "grammars-v4 IRI grammar compiles unchanged")
      (dolist (input '("http://example.org/x"
                       "https://example.org/path?x=1#f"
                       "mailto:alice@example.org"
                       "http://127.0.0.1:8080/a%20b"
                       "http://[2001:db8::1]/x"))
        (check (eq (cnvrs:node-rule (cnvrs:parse compiled input))
                   'cnvrs/antlr4:parse)
               (format nil "grammars-v4 IRI accepts ~S" input)))
      (dolist (input '("not-a-uri" "http://example.org/a b"
                       "http://example.org/%GG"))
        (check (signals error (cnvrs:parse compiled input))
               (format nil "grammars-v4 IRI rejects ~S" input))))
    (let* ((grammar (antlr-parse
                     "grammar LabeledToken; start : item=ID EOF; ID : [a-z]+;"))
           (tree (cnvrs:parse grammar "word"))
           (item (first (cnvrs:node-children tree))))
      (check (and (eq (cnvrs:node-label item) 'cnvrs/antlr4::item)
                  (cnvrs:lexeme-p (first (cnvrs:node-children item)))
                  (string= (cnvrs:lexeme-text
                            (first (cnvrs:node-children item)))
                           "word"))
             "combined ANTLR grammar retains token label and lexeme"))
    (let* ((vocabulary (antlr-parse
                        "lexer grammar Shared; LP : '('; RP : ')'; fragment LETTER : [a-z]; ID : LETTER+; WS : [ ]+ -> skip;"))
           (vocabs (list (cons "Shared" vocabulary)))
           (source "parser grammar Wired; options { tokenVocab = Shared; } start : '(' name=ID RP EOF;")
           (grammar (antlr-parse source :token-vocabulary vocabs)))
      (check (cnvrs:node-p (cnvrs:parse grammar "(hello)"))
             "tokenVocab attaches lexer and resolves literal and named tokens")
      (check (signals cnvrs:parse-error (cnvrs:parse grammar "(hello hello)"))
             "tokenVocab parser rejects invalid source")
      (check (eq (cnvrs:parser-lexer (cnvrs:ensure-compiled grammar)) vocabulary)
             "tokenVocab keeps the supplied lexer definition")
      (let ((table (make-hash-table :test #'equal)))
        (setf (gethash "Shared" table) vocabulary)
        (check (cnvrs:node-p
                (cnvrs:parse (antlr-parse source :token-vocabulary table) "(x)"))
               "tokenVocab accepts a hash table registry"))
      (check (signals cnvrs:grammar-error (antlr-parse source))
             "unresolved tokenVocab is rejected")
      (dolist (body '("MISSING" "LETTER" "'missing'"))
        (check (signals cnvrs:grammar-error
                 (antlr-parse
                  (format nil "parser grammar Bad; options { tokenVocab=Shared; } start : ~A EOF;" body)
                  :token-vocabulary vocabs))
               (format nil "tokenVocab rejects unknown token or literal ~A" body)))
      (check (signals cnvrs:grammar-error
               (antlr-parse source :token-vocabulary vocabs :lexer *inline-lexer*))
             "tokenVocab rejects a conflicting explicit lexer")
      (check (signals cnvrs:grammar-error
               (antlr-parse source :token-vocabulary (list (cons "Shared" grammar))))
             "tokenVocab rejects a parser definition as vocabulary")
      (check (signals cnvrs:grammar-error
               (cnvrs/antlr4:parse source :token-vocabulary vocabs
                                  :parser-package (find-package '#:cnvrs/tests/parser)
                                  :lexer-package (find-package '#:cnvrs/tests/lexer)))
             "tokenVocab rejects mismatched token packages"))
    (let* ((vocabulary (antlr-parse
                        "lexer grammar Declared; tokens { EXTRA } X : 'x';"))
           (grammar (antlr-parse
                     "parser grammar DeclaredParser; options { tokenVocab=Declared; } tokens { LOCAL } start : (EXTRA | LOCAL) EOF;"
                     :token-vocabulary (list (cons "Declared" vocabulary)))))
      (dolist (input '((:extra) (:local)))
        (check (cnvrs:node-p (cnvrs:parse grammar input :lexer nil))
               "tokenVocab preserves lexer and parser token declarations")))
    (let* ((vocabulary (cnvrs/antlr4:parse
                        "lexer grammar Modes; OPEN : '<' -> pushMode(TAG); WS : [ ]+ -> channel(HIDDEN); mode TAG; CLOSE : '>' -> popMode; ID : [a-z]+;"
                        :parser-package '#:cnvrs/tests/parser
                        :lexer-package '#:cnvrs/tests/lexer))
           (grammar (cnvrs/antlr4:parse
                     "parser grammar ModeParser; options { tokenVocab=Modes; } start : ('<' ID '>')+ EOF;"
                     :parser-package '#:cnvrs/tests/parser
                     :lexer-package '#:cnvrs/tests/lexer
                     :token-vocabulary (list (cons "Modes" vocabulary))))
           (tree (cnvrs:parse grammar " <hello> <world>")))
      (check (eq (cnvrs:node-rule tree) 'cnvrs/tests/parser:start)
             "tokenVocab preserves lexer modes, channels, and application packages")
      (check (eq (cnvrs:lexeme-kind (first (cnvrs:node-children tree)))
                 (find-symbol "OPEN" '#:cnvrs/tests/lexer))
             "tokenVocab literal aliases use vocabulary token symbols"))
    (let* ((vocabulary (antlr-parse "lexer grammar Duplicate; A : 'x'; B : 'x';")))
      (check (signals cnvrs:grammar-error
               (antlr-parse "parser grammar Bad; options { tokenVocab=Duplicate; } start : 'x';"
                            :token-vocabulary (list (cons "Duplicate" vocabulary))))
             "tokenVocab rejects ambiguous literal aliases"))
    (let ((grammar (antlr-parse "parser grammar Tokens; start : ID EOF;")))
      (check (cnvrs:parser-p (cnvrs:ensure-compiled grammar))
             "parser grammar compiles without an attached lexer"))
    (let ((grammar (antlr-parse
                    "parser grammar Negated; start : ~(A|B)+ EOF;")))
      (check (cnvrs:node-p (cnvrs:parse grammar '(:c :d)))
             "ANTLR4 parser negated block set accepts other token kinds")
      (check (signals cnvrs:parse-error (cnvrs:parse grammar '(:a)))
             "ANTLR4 parser negated block set rejects excluded token")
      (check (signals cnvrs:parse-error (cnvrs:parse grammar '()))
             "ANTLR4 parser negated block set requires input"))
    (let ((grammar (antlr-parse
                    "parser grammar NegatedSingle; start : ~A EOF;")))
      (check (cnvrs:node-p (cnvrs:parse grammar '(:b)))
             "ANTLR4 parser single negated token compiles"))
    (let* ((grammar (antlr-parse
                     "parser grammar Prequels; options { tokenVocab = Shared; language = Java; } import Base, Alias=Other; tokens { EXTERNAL, } channels { CUSTOM, } @header {class X {}} start : EXTERNAL EOF;"
                     :token-vocabulary (list (cons "Shared"
                                              (antlr-parse "lexer grammar Shared; EXTERNAL : 'x';")))))
           (metadata (cnvrs:parser-definition-metadata grammar))
           (prequels (getf metadata :prequels))
           (compiled (cnvrs:ensure-compiled grammar)))
      (check (equal (mapcar #'first prequels)
                    '(:options :imports :tokens :channels :action))
             "ANTLR4 prequel kinds retain their source order")
      (check (equal (second (first prequels))
                    '(("tokenVocab" "Shared") ("language" "Java")))
             "ANTLR4 option values are retained")
      (check (equal (second (second prequels))
                    '((nil "Base") ("Alias" "Other")))
             "ANTLR4 imports retain aliases")
      (check (equal (second (third prequels)) '("EXTERNAL"))
             "ANTLR4 token declaration retained")
      (check (equal (second (fourth prequels)) '("CUSTOM"))
             "ANTLR4 channel declaration retained")
      (check (equal (getf (second (fifth prequels)) :name) "header")
             "ANTLR4 action declaration retained")
      (check (equal metadata (cnvrs:parser-metadata compiled))
             "prequel metadata survives parser compilation")
      (check (cnvrs:node-p (cnvrs:parse grammar '(:external) :lexer nil))
             "declared external token remains usable in parser grammar"))
    (let ((grammar (antlr-parse
                    "grammar Choice; start : ('a' | 'b')+ EOF;")))
      (check (eq (cnvrs:node-rule (cnvrs:parse grammar "abba"))
                 'cnvrs/antlr4::start)
             "ANTLR4 grouped alternatives and suffix compile"))
    (let ((grammar (antlr-parse
                    "parser grammar Labels; start : first=ID more+=ID* #Many | pair=(A B)+ #Pair;")))
      (let* ((tree (cnvrs:parse grammar '(:id :id :id)))
             (children (cnvrs:node-children tree)))
        (check (eq (cnvrs:node-label tree) 'cnvrs/antlr4::many)
               "ANTLR4 alternative label appears on the rule node")
        (check (equal (mapcar #'cnvrs:node-label children)
                      '(cnvrs/antlr4::first cnvrs/antlr4::more
                        cnvrs/antlr4::more))
               "ANTLR4 assigned and list labels appear on element nodes")
        (check (every (lambda (child)
                        (equal (cnvrs:node-children child) '(:id)))
                      children)
               "ANTLR4 labeled element nodes retain matched tokens"))
      (let* ((tree (cnvrs:parse grammar '(:a :b :a :b)))
             (children (cnvrs:node-children tree)))
        (check (eq (cnvrs:node-label tree) 'cnvrs/antlr4::pair)
               "ANTLR4 second alternative label appears on the rule node")
        (check (and (= (length children) 2)
                    (every (lambda (child)
                             (and (eq (cnvrs:node-label child)
                                      'cnvrs/antlr4::pair)
                                  (equal (cnvrs:node-children child) '(:a :b))))
                           children))
               "ANTLR4 grouped element labels retain each repetition"))
      (check (signals cnvrs:parse-error
               (cnvrs:parse grammar '(:a :b :a)))
             "ANTLR4 labeled group still enforces its repetition"))
    (let* ((grammar (antlr-parse
                     "parser grammar LabeledExpr; expr : left=expr PLUS right=expr #Add | INT #Number;"))
           (tree (cnvrs:parse grammar '(:int :plus :int)))
           (children (cnvrs:node-children tree)))
      (check (eq (cnvrs:node-label tree) 'cnvrs/antlr4::add)
             "left-recursive ANTLR alternative retains its label")
      (check (and (eq (cnvrs:node-label (first children))
                      'cnvrs/antlr4::left)
                  (eq (cnvrs:node-label (third children))
                      'cnvrs/antlr4::right)
                  (eq (cnvrs:node-label
                       (first (cnvrs:node-children (first children))))
                      'cnvrs/antlr4::number))
             "left-recursive ANTLR element labels survive normalization"))
    (let* ((grammar (antlr-parse
                     "parser grammar Precedence; expr : expr STAR expr #Multiply | expr PLUS expr #Add | INT #Number;"))
           (sum (cnvrs:parse grammar '(:int :plus :int :star :int)))
           (product (cnvrs:parse grammar '(:int :star :int :plus :int))))
      (check (and (eq (cnvrs:node-label sum) 'cnvrs/antlr4::add)
                  (eq (cnvrs:node-label
                       (third (cnvrs:node-children sum)))
                      'cnvrs/antlr4::multiply)
                  (eq (cnvrs:node-label product) 'cnvrs/antlr4::add)
                  (eq (cnvrs:node-label
                       (first (cnvrs:node-children product)))
                      'cnvrs/antlr4::multiply))
             "ANTLR4 earlier recursive alternative has higher precedence"))
    (let* ((grammar (antlr-parse
                     "parser grammar Associativity; expr : <assoc=right> expr CARET expr #Power | <assoc=left> expr STAR expr #Multiply | INT #Number;"))
           (power (cnvrs:parse grammar '(:int :caret :int :caret :int)))
           (product (cnvrs:parse grammar '(:int :caret :int :star :int))))
      (check (and (eq (cnvrs:node-label power) 'cnvrs/antlr4::power)
                  (eq (cnvrs:node-label
                       (third (cnvrs:node-children power)))
                      'cnvrs/antlr4::power)
                  (eq (cnvrs:node-label product)
                      'cnvrs/antlr4::multiply)
                  (eq (cnvrs:node-label
                       (first (cnvrs:node-children product)))
                      'cnvrs/antlr4::power))
             "ANTLR4 associativity and precedence options convert"))
    (check (signals cnvrs:grammar-error
             (antlr-parse
              "parser grammar BadAssoc; expr : <assoc=middle> expr CARET expr | INT;"))
           "unsupported ANTLR4 associativity option is rejected")
    (let* ((tight (antlr-parse
                   "parser grammar TightPrefix; expr : MINUS expr #Negate | expr STAR expr #Multiply | INT #Number;"))
           (loose (antlr-parse
                   "parser grammar LoosePrefix; expr : expr STAR expr #Multiply | MINUS expr #Negate | INT #Number;"))
           (tight-tree (cnvrs:parse tight '(:minus :int :star :int)))
           (loose-tree (cnvrs:parse loose '(:minus :int :star :int))))
      (check (and (eq (cnvrs:node-label tight-tree)
                      'cnvrs/antlr4::multiply)
                  (eq (cnvrs:node-label
                       (first (cnvrs:node-children tight-tree)))
                      'cnvrs/antlr4::negate)
                  (eq (cnvrs:node-label loose-tree)
                      'cnvrs/antlr4::negate)
                  (eq (cnvrs:node-label
                       (second (cnvrs:node-children loose-tree)))
                      'cnvrs/antlr4::multiply))
             "ANTLR4 prefix alternatives use source-order precedence"))
    (let* ((grammar (antlr-parse
                     "parser grammar LabeledOperand; expr : expr STAR rhs=expr #Multiply | expr PLUS expr #Add | INT #Number;"))
           (tree (cnvrs:parse grammar '(:int :plus :int :star :int))))
      (check (and (eq (cnvrs:node-label tree) 'cnvrs/antlr4::add)
                  (eq (cnvrs:node-label
                       (third (cnvrs:node-children tree)))
                      'cnvrs/antlr4::multiply))
             "labeled right operands retain ANTLR4 precedence"))
    (let* ((grammar (antlr-parse
                     "parser grammar LabeledPower; expr : <assoc=right> expr CARET rhs=expr #Power | INT #Number;"))
           (tree (cnvrs:parse grammar '(:int :caret :int :caret :int)))
           (right-label (third (cnvrs:node-children tree))))
      (check (and (eq (cnvrs:node-label right-label)
                      'cnvrs/antlr4::rhs)
                  (eq (cnvrs:node-label
                       (first (cnvrs:node-children right-label)))
                      'cnvrs/antlr4::power))
             "labeled right operands retain ANTLR4 right associativity"))
    (let* ((grammar (antlr-parse
                     "parser grammar PrefixAssoc; expr : <assoc=right> MINUS expr #Negate | expr STAR expr #Multiply | INT #Number;"))
           (tree (cnvrs:parse grammar '(:minus :int :star :int))))
      (check (eq (cnvrs:node-label tree) 'cnvrs/antlr4::multiply)
             "associativity option on ANTLR4 prefix alternative is accepted"))
    (let ((grammar (antlr-parse "lexer grammar Letters; A : 'a';")))
      (check (equal (map 'list #'cnvrs:lexeme-kind (cnvrs:lex grammar "aa"))
                    '(:a :a))
             "ANTLR4 lexer grammar compiles"))
    (let* ((grammar (antlr-parse
                     "lexer grammar NegatedChars; options { language = Java; } NOT : ~('a' | 'b'..'d' | [x-z])+;"))
           (compiled (cnvrs:ensure-compiled grammar)))
      (check (equal (map 'list #'cnvrs:lexeme-text (cnvrs:lex grammar "ew"))
                    '("ew"))
             "ANTLR4 lexer negated block set accepts other characters")
      (check (signals cnvrs:lexical-error (cnvrs:lex grammar "b"))
             "ANTLR4 lexer negated block set excludes ranges")
      (check (equal (cnvrs:parser-definition-metadata grammar)
                    (cnvrs:compiled-lexer-metadata compiled))
             "prequel metadata survives lexer compilation"))
    (let ((grammar (antlr-parse
                    "lexer grammar Lazy; STAR : '<' .*? '>'; PLUS : '[' .+? ']'; OPTIONAL : 'a' 'x'?? 'x'; OTHER : .;")))
      (check (typep (cnvrs:lexer-simulator grammar) 'cnvrs/runtime:lexer-atn-simulator)
             "nongreedy lexer rules use the Java lexer ATN simulator")
      (check (equal (map 'list #'cnvrs:lexeme-text
                         (cnvrs:lex grammar "<1>2>"))
                    '("<1>" "2" ">"))
             "ANTLR4 nongreedy star stops at the first closing delimiter")
      (check (equal (map 'list #'cnvrs:lexeme-text
                         (cnvrs:lex grammar "[12]3]"))
                    '("[12]" "3" "]"))
             "ANTLR4 nongreedy plus requires a character and stops early")
      (check (equal (map 'list #'cnvrs:lexeme-text
                         (cnvrs:lex grammar "axx"))
                    '("ax" "x"))
             "ANTLR4 nongreedy optional prefers the empty branch"))
    (let ((grammar (cnvrs:compile-lexer
                    '((:until (and (*? (not-one-of ((#\a . #\c)))) #\c))
                      (:other (any))))))
      (check (equal (map 'list #'cnvrs:lexeme-text
                         (cnvrs:lex grammar "xxc"))
                    '("xxc"))
             "compiled nongreedy matcher honors negated character ranges"))
    (let ((grammar (antlr-parse
                    "lexer grammar LazyPriority; SHORT : '<' .*? '>'; LONG : '<' .* '>'; OTHER : .;")))
      (check (equal (map 'list #'cnvrs:lexeme-kind
                         (cnvrs:lex grammar "<x>"))
                    '(:short))
             "nongreedy rule wins an equal-length tie by rule order")
      (check (equal (map 'list #'cnvrs:lexeme-kind
                         (cnvrs:lex grammar "<x>y>"))
                    '(:long))
             "longer greedy rule wins over a nongreedy rule"))
    (let ((grammar (antlr-parse
                    "lexer grammar LazyAlternatives; TOKEN : 'a' | 'ab' .*? 'c'; OTHER : .;")))
      (check (equal (map 'list #'cnvrs:lexeme-text
                         (cnvrs:lex grammar "abc"))
                    '("abc"))
             "alternatives before a nongreedy suffix still take the longest match"))
    (let ((grammar (antlr-parse
                    "lexer grammar LazyFragment; fragment BODY : .*? '>'; SHORT : '<' BODY; OTHER : .;")))
      (check (equal (map 'list #'cnvrs:lexeme-text
                         (cnvrs:lex grammar "<x>y>"))
                    '("<x>" "y" ">"))
             "nongreedy suffix works through a fragment reference"))
    (let ((grammar (antlr-parse
                    "lexer grammar Nested; BLOCK : NESTED; fragment NESTED : '{' (NESTED | ~[{}])* '}'; OTHER : .;")))
      (check (equal (map 'list #'cnvrs:lexeme-text
                         (cnvrs:lex grammar "{a{b}c}x"))
                    '("{a{b}c}" "x"))
             "ANTLR4 recursive lexer fragment balances delimiters"))
    (let ((grammar (antlr-parse
                    "lexer grammar Modes; OPEN : '<' -> pushMode(TAG); WORD : [a-z]+; mode TAG; CLOSE : '>' -> popMode; TEXT : [a-z]+;")))
      (check (equal (map 'list #'cnvrs:lexeme-kind (cnvrs:lex grammar "<abc>abc"))
                    '(:open :text :close :word))
             "ANTLR4 lexer modes and commands compile"))
    (check (signals cnvrs:grammar-error
             (antlr-parse "grammar Actions; start : ID {run();}; ID : 'x';"))
           "ANTLR4 conversion requires explicit callbacks")
    (let* ((events nil)
           (grammar (antlr-parse
                     "grammar Semantic; start : {allow()}? ID {done()}; ID : 'x' {seen()};"
                     :callbacks
                     (list (cons "{allow()}"
                                 (lambda (input at)
                                   (declare (ignore input at)) t))
                           (cons "{done()}"
                                 (lambda (input at)
                                   (declare (ignore input))
                                   (push (list :parser at) events)))
                           (cons "{seen()}"
                                 (lambda (source at)
                                   (declare (ignore source))
                                   (push (list :lexer at) events)))))))
      (cnvrs:parse grammar "x")
      (check (equal (reverse events) '((:lexer 1) (:parser 1)))
             "ANTLR4 parser and lexer action blocks use callbacks"))
    (let* ((allowed nil)
           (grammar (antlr-parse
                     "lexer grammar Guard; GUARDED : {allowed()}? 'x'; FALLBACK : 'x';"
                     :callbacks
                     (list (cons "{allowed()}"
                                 (lambda (source at)
                                   (declare (ignore source at)) allowed))))))
      (check (eq (cnvrs:lexeme-kind (aref (cnvrs:lex grammar "x") 0))
                 :fallback)
             "ANTLR4 lexer predicate can reject a rule")
      (setf allowed t)
      (check (eq (cnvrs:lexeme-kind (aref (cnvrs:lex grammar "x") 0))
                 :guarded)
             "ANTLR4 lexer predicate can select a rule"))
    (let* ((events nil)
           (grammar (antlr-parse
                     "lexer grammar FragmentAction; fragment PART : 'a' {fragmentSeen()}; TOP : PART {topSeen()};"
                     :callbacks
                     (list (cons "{fragmentSeen()}"
                                 (lambda (source at)
                                   (declare (ignore source at))
                                   (push :fragment events)))
                           (cons "{topSeen()}"
                                 (lambda (source at)
                                   (declare (ignore source at))
                                   (push :top events)))))))
      (cnvrs:lex grammar "a")
      (check (equal events '(:top))
             "referenced lexer rule actions do not run"))
    (let* ((enabled t) (events nil)
           (parser (cnvrs:compile-grammar
                    (list (list 'start
                                (list 'or
                                      (list 'and
                                            (list 'predicate
                                                  (lambda (input at)
                                                    (declare (ignore input at))
                                                    enabled))
                                            :a
                                            (list 'action
                                                  (lambda (input at)
                                                    (declare (ignore input))
                                                    (push at events))))
                                      (list 'and :a
                                            (list 'action
                                                  (lambda (input at)
                                                    (declare (ignore input))
                                                    (push (+ at 10) events))))))))))
      (cnvrs:parse parser '(:a))
      (check (equal events '(1)) "parser action runs on selected path")
      (setf enabled nil events nil)
      (cnvrs:parse parser '(:a))
      (check (equal events '(11)) "parser predicate is reevaluated"))
    (let* ((events nil)
           (lexer (cnvrs:compile-lexer
                   (list (list :short
                               (list 'and #\a
                                     (list 'action
                                           (lambda (source at)
                                             (declare (ignore source))
                                             (push at events)))))
                         (list :long
                               (list 'and
                                     (list 'predicate
                                           (lambda (source at)
                                             (char= (char source at) #\a)))
                                     "ab"
                                     (list 'action
                                           (lambda (source at)
                                             (declare (ignore source))
                                             (push (+ at 10) events)))))))))
      (check (equal (map 'list #'cnvrs:lexeme-kind (cnvrs:lex lexer "ab"))
                    '(:long))
             "semantic lexer keeps longest-match priority")
      (check (equal events '(12)) "only winning lexer action runs"))
    (let* ((allow nil)
           (lexer (cnvrs:compile-lexer
                   (list (list :guarded
                               (list 'and
                                     (list 'predicate
                                           (lambda (source at)
                                             (declare (ignore source at))
                                             allow))
                                     #\x))
                         (list :fallback #\x)))))
      (check (eq (cnvrs:lexeme-kind (aref (cnvrs:lex lexer "x") 0))
                 :fallback)
             "false lexer predicate excludes a rule")
      (setf allow t)
      (check (eq (cnvrs:lexeme-kind (aref (cnvrs:lex lexer "x") 0))
                 :guarded)
             "lexer predicate is reevaluated on the next call"))
    (let* ((tokens (cnvrs/antlr4:lex "// note
grammar T;"))
           (channels (map 'list #'cnvrs:lexeme-channel tokens)))
      (check (member :comment channels)
             "ANTLR4 lexer preserves comment channel")
      (check (member :off_channel channels)
             "ANTLR4 lexer preserves whitespace channel")))
  (format t "~D CNVRS checks passed.~%" *checks*)
  t)
