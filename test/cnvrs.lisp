(defpackage #:cnvrs/tests
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cnvrs/tests)

(defvar *checks* 0)

(defun check (condition description)
  (incf *checks*)
  (unless condition (error "Failed: ~A" description)))

(defmacro signals (condition form)
  `(handler-case (progn ,form nil)
     (,condition () t)))

(defun run-tests ()
  (setf *checks* 0)
  (let* ((grammar (cnvrs:compile-grammar
                   '((start (and #\a (* #\b) #\c)))))
         (tree (cnvrs:parse grammar "abbbc")))
    (check (eq (cnvrs:node-rule tree) 'start) "root rule")
    (check (equal (cnvrs:node-children tree)
                  '(#\a #\b #\b #\b #\c)) "repetition and token order")
    (check (= (cnvrs:node-end tree) 5) "end position")
    (check (signals cnvrs:parse-error (cnvrs:parse grammar "abbd"))
           "unexpected token"))
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
  (check (signals cnvrs:grammar-error
            (cnvrs:compile-grammar '((start (or (and start #\a) #\b)))))
         "left recursion")
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
                (aref (funcall lexer "letter") 0)) :identifier)
           "longest match outranks earlier rule")
    (check (eq (cnvrs:lexeme-kind
                (aref (funcall lexer "let") 0)) :keyword)
           "rule order breaks equal-length ties")
    (check (signals cnvrs:lexical-error (funcall lexer "let @"))
           "unmatched character signals lexical error")
    (handler-case (funcall lexer "let @")
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
         (tokens (funcall lexer "123")))
    (check (and (= (length tokens) 1)
                (eq (cnvrs:lexeme-kind (aref tokens 0)) :integer))
           "lexer rule reference and longest match"))
  (let* ((lexer (cnvrs:compile-lexer
                 '((:a "a")
                   (:space (+ (one-of " ")) :channel :trivia)
                   (:b "b")
                   (:ignored "!" :channel :trivia :skip t))))
         (tokens (funcall lexer "a b!"))
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
  (format t "~D CNVRS checks passed.~%" *checks*)
  t)
