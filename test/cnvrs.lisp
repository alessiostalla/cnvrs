(defpackage #:cnvrs/tests
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cnvrs/tests)

(cnvrs:define-parser *inline-parser* (:kind :parser :default-rule start)
  (cnvrs:defrule start (and :open item :close))
  (cnvrs:defrule item :name))

(cnvrs:define-parser *package-parser* (:kind :parser :default-rule item))
(cnvrs:in-parser *package-parser*)
(cnvrs:defrule start (and item :end))
(cnvrs:defrule item :name)

(cnvrs:define-parser *inline-lexer* (:kind :lexer)
  (cnvrs:defrule :space (+ (one-of " ")) :skip t)
  (cnvrs:defrule :name (+ (range #\a #\z))))

(cnvrs:define-parser *package-lexer* (:kind :lexer))
(cnvrs:in-parser *package-lexer*)
(cnvrs:defrule :number (+ (range #\0 #\9)))
(cnvrs:defrule :space (+ (one-of " ")) :skip t)

(cnvrs:define-parser *mode-package-lexer* (:kind :lexer))
(cnvrs:in-parser *mode-package-lexer*)
(cnvrs:defrule :open #\< :push-mode :tag :skip t)
(cnvrs:with-mode :tag
  (cnvrs:defrule :tag (+ (range #\a #\z)))
  (cnvrs:defrule :close #\> :pop-mode t :skip t))

(cnvrs:define-parser *mode-inline-lexer* (:kind :lexer)
  (:open #\< :push-mode :tag :skip t)
  (cnvrs:with-mode :tag
    (:tag (+ (range #\a #\z)))
    (:close #\> :pop-mode t :skip t)))

(cnvrs:define-parser *inline-combined* (:kind :combined :default-rule start)
  (cnvrs:defrule start (and :name :equals :number))
  (cnvrs:defrule :name (+ (range #\a #\z)))
  (cnvrs:defrule :equals #\=)
  (cnvrs:defrule :number (+ (range #\0 #\9))))

(cnvrs:define-parser *package-combined*
    (:kind :combined :default-rule assignment))
(cnvrs:in-parser *package-combined*)
(cnvrs:defrule assignment (and :let :name :equals :number))
(cnvrs:defrule :space (+ (one-of " ")) :skip t)
(cnvrs:defrule :let "let")
(cnvrs:defrule :name (+ (range #\a #\z)))
(cnvrs:defrule :equals #\=)
(cnvrs:defrule :number (+ (range #\0 #\9)))

(cnvrs:define-parser *bare-parser* (:kind :parser)
  (start (and :a :b)))

(cnvrs:define-parser *hash-parser* (:kind :parser :cache-backend :hash-table)
  (start (or :a :b)))

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

(cnvrs:define-parser *alternate-parser* (:kind :parser
                                        :tree-builder :alternate)
  (start (and item :end))
  (item :name))

(cnvrs:define-parser *external-lexer-parser*
    (:kind :parser :lexer (cnvrs:compile-lexer '((:word (+ (range #\a #\z)))))
     :default-rule start)
  (cnvrs:defrule start :word))

(cnvrs:define-parser *symbol-lexer-combined* (:kind :combined)
  (cnvrs:defrule start (token word))
  (cnvrs:defrule word (+ (range #\a #\z)) :lexer t))

(cnvrs:define-parser *mode-combined* (:kind :combined)
  (cnvrs:defrule start (and :word :string-text :word))
  (cnvrs:defrule :word (+ (range #\a #\z)))
  (cnvrs:defrule :space #\Space :skip t)
  (cnvrs:defrule :open #\" :skip t :push-mode :string)
  (cnvrs:with-mode :string
    (cnvrs:defrule :string-text (+ (range #\a #\z)))
    (cnvrs:defrule :close #\" :skip t :pop-mode t)))

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
         "define-parser forwards its tree builder")
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
      (flet ((lookup (head tail)
               (cnvrs:cache-get-or-compute
                cache (cnvrs::flat-cache-key head tail)
                (lambda () (incf computations)))))
        (check (= (lookup 42 '(17 9)) (lookup 42 '(17 9)) 1)
               "equal flat arrays share one cache entry")
        (check (= (lookup 42 '(17 8)) 2)
               "different flat array contents remain distinct")
        (check (= (cnvrs:cache-count cache) 2)
               "flat array entries count toward cache size")
        (cnvrs:cache-clear cache)
        (check (= (cnvrs:cache-count cache) 0)
               "cache clear removes flat array entries"))))
  (dolist (backend '(:fset :hash-table (:locked :fset)
                     (:locked :hash-table)))
    (let* ((lexer (cnvrs:compile-lexer '((:a "a") (:b "b"))
                                        :cache-backend backend))
           (grammar (cnvrs:compile-grammar '((start (or :a :b)))
                                           :lexer lexer
                                           :cache-backend backend)))
      (check (eq (cnvrs:node-rule (cnvrs:parse grammar "a")) 'start)
             "both cache backends parse compiled lexer output")
      (check (and (plusp (cnvrs:cache-count
                          (cnvrs:compiled-lexer-cache lexer)))
                  (plusp (cnvrs:cache-count
                          (cnvrs:parser-sll-decisions grammar))))
             "lexer and parser both populate their caches")
      (check (cnvrs::lx-dfa-state-p
              (cnvrs:cache-get-or-compute
               (cnvrs:compiled-lexer-cache lexer) :default
               (lambda () :missing)))
             "lexer caches its initial DFA state by mode")
      (let ((copy (cnvrs:clone-compiled grammar)))
        (check (and (equal (cnvrs:parser-cache-backend copy) backend)
                    (zerop (cnvrs:cache-count
                            (cnvrs:parser-sll-decisions copy)))
                    (zerop (cnvrs:cache-count
                            (cnvrs:compiled-lexer-cache
                             (cnvrs:parser-lexer copy)))))
               "clone starts with independent parser and lexer caches"))
      (cnvrs:clear-cache grammar)
      (check (and (zerop (cnvrs:cache-count
                          (cnvrs:parser-sll-decisions grammar)))
                  (zerop (cnvrs:cache-count
                          (cnvrs:compiled-lexer-cache lexer))))
             "one call clears parser and attached lexer caches")
      (check (eq (cnvrs:lexeme-kind (aref (cnvrs:lex lexer "b") 0)) :b)
             "cleared lexer rebuilds its DFA states")))
  (let* ((grammar (cnvrs:compile-grammar '((start (or :a :b)))))
         (copy (cnvrs:clone-compiled grammar :cache-backend :hash-table)))
    (check (and (equal (cnvrs:parser-cache-backend grammar)
                       '(:locked :fset))
                (eq (cnvrs:parser-cache-backend copy) :hash-table)
                (eq (cnvrs:node-rule (cnvrs:parse copy '(:b))) 'start))
           "cloning can select another cache backend"))
  (check (eq (cnvrs:parser-cache-backend
              (cnvrs:ensure-compiled *hash-parser*)) :hash-table)
         "define-parser forwards the cache backend")
  (let ((grammar (cnvrs:compile-grammar '((start (or :a :b)))
                                        :cache-backend :test-cache)))
    (check (and (eq (cnvrs:node-rule
                     (cnvrs:parse grammar '(:a))) 'start)
                (plusp (cnvrs:cache-count
                        (cnvrs:parser-sll-decisions grammar))))
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
  (let ((grammar (cnvrs:compile-grammar '((start (or :a :b))))))
    (check (and (cnvrs:parser-p grammar)
                (plusp (length (cnvrs:parser-states grammar))))
           "compiled grammar exposes its transition states")
    (cnvrs:parse grammar '(:a))
    (let ((copy (cnvrs:clone-compiled grammar)))
      (check (and (not (eq grammar copy))
                  (eq (cnvrs:parser-states grammar)
                      (cnvrs:parser-states copy))
                  (zerop (cnvrs:cache-count
                          (cnvrs::parser-sll-decisions copy)))
                  (plusp (cnvrs:cache-count
                          (cnvrs::parser-sll-decisions grammar))))
             "parser clone shares its graph but starts with an empty cache")
      (cnvrs:clear-cache grammar)
      (check (zerop (cnvrs:cache-count
                    (cnvrs::parser-sll-decisions grammar)))
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
         "bare rule forms inside define-parser")
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
  (eval '(cnvrs:define-parser *mutable-parser* (:kind :parser)
           (cnvrs:defrule start :a)))
  (check (eq (cnvrs:node-rule
               (cnvrs:parse (symbol-value '*mutable-parser*) '(:a))) 'start)
         "incremental definition compiles on use")
  (eval '(cnvrs:in-parser *mutable-parser*))
  (eval '(cnvrs:defrule extra :b))
  (check (eq (cnvrs:node-rule
               (cnvrs:parse (symbol-value '*mutable-parser*) '(:b)
                            :rule 'extra)) 'extra)
         "new rule invalidates an already compiled definition")
  (check (eq (cnvrs:node-rule
              (cnvrs:parse (symbol-value '*mutable-parser*) '(:b)
                           :start 'extra)) 'extra)
         "legacy start keyword remains supported")
  (let* ((grammar (cnvrs:compile-grammar
                   '((start (and #\a (* #\b) #\c)))))
         (tree (cnvrs:parse grammar "abbbc")))
    (check (eq (cnvrs:node-rule tree) 'start) "root rule")
    (check (equal (cnvrs:node-children tree)
                  '(#\a #\b #\b #\b #\c)) "repetition and token order")
    (check (= (cnvrs:node-end tree) 5) "end position")
    (check (signals cnvrs:parse-error (cnvrs:parse grammar "abbd"))
           "unexpected token"))
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
    (check (plusp (cnvrs:cache-count
                   (cnvrs:parser-decisions grammar)))
           "full-context prediction uses the selected cache backend")
    (check (equal (cnvrs:node-children
                   (first (cnvrs:node-children
                           (cnvrs:parse grammar "ab")))) '(#\a))
           "cached decision adapts to another input")
    (check (signals cnvrs:parse-error (cnvrs:parse grammar "aab"))
           "full context and end of input"))
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
         "recursive lexer rule rejected")
  (multiple-value-bind (lexer match)
      (cnvrs:compile-lexer '((:long "ab") (:short "a")))
    (declare (ignore lexer))
    (multiple-value-bind (kind end)
        (funcall match "abc" 0 :default)
      (check (and (eq kind :long) (= end 2))
             "lexer matcher returns one longest token")))
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
    (let* ((grammar (cnvrs/antlr4:parse
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
    (let ((grammar (cnvrs/antlr4:parse "parser grammar Tokens; start : ID EOF;")))
      (check (cnvrs:parser-p (cnvrs:ensure-compiled grammar))
             "parser grammar compiles without an attached lexer"))
    (let ((grammar (cnvrs/antlr4:parse
                    "grammar Choice; start : ('a' | 'b')+ EOF;")))
      (check (eq (cnvrs:node-rule (cnvrs:parse grammar "abba"))
                 'cnvrs/antlr4::start)
             "ANTLR4 grouped alternatives and suffix compile"))
    (let ((grammar (cnvrs/antlr4:parse "lexer grammar Letters; A : 'a';")))
      (check (equal (map 'list #'cnvrs:lexeme-kind (cnvrs:lex grammar "aa"))
                    '(:a :a))
             "ANTLR4 lexer grammar compiles"))
    (let ((grammar (cnvrs/antlr4:parse
                    "lexer grammar Modes; OPEN : '<' -> pushMode(TAG); WORD : [a-z]+; mode TAG; CLOSE : '>' -> popMode; TEXT : [a-z]+;")))
      (check (equal (map 'list #'cnvrs:lexeme-kind (cnvrs:lex grammar "<abc>abc"))
                    '(:open :text :close :word))
             "ANTLR4 lexer modes and commands compile"))
    (check (signals cnvrs:grammar-error
             (cnvrs/antlr4:parse "grammar Actions; start : ID {run();}; ID : 'x';"))
           "ANTLR4 conversion rejects unsupported actions")
    (let* ((tokens (cnvrs/antlr4:lex "// note
grammar T;"))
           (channels (map 'list #'cnvrs:lexeme-channel tokens)))
      (check (member :comment channels)
             "ANTLR4 lexer preserves comment channel")
      (check (member :off_channel channels)
             "ANTLR4 lexer preserves whitespace channel")))
  (format t "~D CNVRS checks passed.~%" *checks*)
  t)
