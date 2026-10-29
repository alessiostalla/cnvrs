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
  (format t "~D CNVRS checks passed.~%" *checks*)
  t)
