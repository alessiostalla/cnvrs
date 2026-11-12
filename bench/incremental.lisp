;; Run from the repository root:
;; LC_ALL=en_US.UTF-8 XDG_CACHE_HOME=/tmp/cnvrs-cache sbcl
;;   --dynamic-space-size 2048 --control-stack-size 256 --script bench/incremental.lisp
(require :asdf)
(load (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)
(defpackage #:cnvrs/bench/incremental (:use #:cl))
(defpackage #:cnvrs/bench/incremental/parser (:use))
(defpackage #:cnvrs/bench/incremental/lexer (:use))
(in-package #:cnvrs/bench/incremental)
(defvar *sink*)
(defun measure (name thunk iterations)
  (dotimes (i 5) (funcall thunk))
  (dotimes (sample 7)
    (sb-ext:gc :full t)
    (let ((start (get-internal-real-time)) (bytes (sb-ext:get-bytes-consed)))
      (dotimes (i iterations) (setf *sink* (funcall thunk)))
      (format t "~A SAMPLE ~D MS ~,6F BYTES ~,1F~%" name (1+ sample)
              (/ (* 1000d0 (- (get-internal-real-time) start))
                 (* iterations internal-time-units-per-second))
              (/ (- (sb-ext:get-bytes-consed) bytes) (float iterations 1d0)))
      (finish-output))))
(defun exercise (name grammar base replacements iterations &key rule checkpoint-rules)
  (format t "CASE ~A CHARACTERS ~D~%" name (length base))
  (flet ((session () (if checkpoint-rules
                        (cnvrs:make-incremental-parser grammar :rule rule :checkpoint-rules checkpoint-rules)
                        (cnvrs:make-incremental-parser grammar :rule rule))))
  (let ((session (session)))
    (measure (concatenate 'string name "/BATCH") (lambda () (cnvrs:parse grammar base :rule rule)) iterations)
    (measure (concatenate 'string name "/INITIAL")
             (lambda () (cnvrs:parse-incrementally (session) base)) iterations)
    (cnvrs:parse-incrementally session base)
    (measure (concatenate 'string name "/NOOP")
             (lambda () (cnvrs:parse-incrementally session base)) iterations)
    (dolist (replacement replacements)
      (let* ((label (car replacement)) (revision (cdr replacement)) (toggle nil))
        (cnvrs:parse-incrementally session base)
        (measure (concatenate 'string name "/EDIT-" label)
                 (lambda ()
                   (setf toggle (not toggle))
                   (cnvrs:parse-incrementally session (if toggle revision base))) iterations)
        (format t "RESTART ~A/~A TOKEN ~D~%" name label
                (cnvrs:incremental-parser-restart-position session)))))))

(let* ((count 1000)
       (grammar (cnvrs:compile-grammar
                 '((document (* method))
                   (method (and #\[ (* (cnvrs:not-token (#\[ #\]))) #\]) :checkpoint t))))
       (base (format nil "~{~A~}" (make-list count :initial-element "[aaaaaaaa]"))))
  (exercise "CHARACTERS" grammar base
            (loop for (label index) in `(("EARLY" 0) ("MIDDLE" ,(/ count 2)) ("LATE" ,(1- count)))
                  collect (let ((revision (copy-seq base)))
                            (setf (char revision (+ 1 (* index 10))) #\b)
                            (cons label revision))) 100))

(let* ((lexer (cnvrs/antlr4:parse (uiop:read-file-string "test/fixtures/runtime/Java8Lexer.g4")
                                :parser-package :cnvrs/bench/incremental/parser
                                :lexer-package :cnvrs/bench/incremental/lexer))
       (definition (cnvrs/antlr4:parse (uiop:read-file-string "test/fixtures/runtime/Java8Parser.g4")
                                     :parser-package :cnvrs/bench/incremental/parser
                                     :lexer-package :cnvrs/bench/incremental/lexer
                                     :token-vocabulary (list (cons "Java8Lexer" lexer))))
       (grammar (cnvrs:ensure-compiled definition))
       (method (find-symbol "METHODDECLARATION" :cnvrs/bench/incremental/parser))
       (count 12)
       (base (format nil "class C {~{~A~}}"
                     (loop for i below count collect (format nil " int m~D() { return 1; }" i)))))
  ;; Imported .g4 rules can be selected without modifying their source grammar.
  (exercise "JAVA8" grammar base
            (loop for (label index) in '(("EARLY" 0) ("MIDDLE" 6) ("LATE" 11))
                  collect (let* ((revision (copy-seq base))
                                 (start (search (format nil "m~D()" index) revision))
                                 (number (+ (search "return 1" revision :start2 start) 7)))
                            (setf (char revision number) #\2)
                            (cons label revision))) 20
            :rule (find-symbol "COMPILATIONUNIT" :cnvrs/bench/incremental/parser)
            :checkpoint-rules (list method)))
