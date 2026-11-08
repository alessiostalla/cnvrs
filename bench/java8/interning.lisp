(require :asdf)
(let ((setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file setup) (load setup)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)
(load (merge-pathnames "interning-hooks.lisp" *load-truename*))
(defpackage #:java8/intern-bench/parser (:use))
(defpackage #:java8/intern-bench/lexer (:use))
(defparameter *args* (uiop:command-line-arguments))
(unless (= (length *args*) 3)
  (error "Usage: interning.lisp Java8Lexer.g4 Java8Parser.g4 closure|prediction|production"))
(defparameter *scope* (cond ((equal (third *args*) "closure") :closure)
                           ((equal (third *args*) "prediction") :prediction)
                           ((equal (third *args*) "production") :production)
                           (t (error "Unknown scope"))))
(defparameter *lexer*
  (cnvrs/antlr4:parse (uiop:read-file-string (first *args*))
                    :parser-package '#:java8/intern-bench/parser
                    :lexer-package '#:java8/intern-bench/lexer))
(defparameter *parser*
  (cnvrs:ensure-compiled
   (cnvrs/antlr4:parse (uiop:read-file-string (second *args*))
                     :parser-package '#:java8/intern-bench/parser
                     :lexer-package '#:java8/intern-bench/lexer
                     :token-vocabulary (list (cons "Java8Lexer" *lexer*)))))
(cnvrs:ensure-compiled *lexer*)
(when (and (eq *scope* :production) (uiop:getenv "BENCH_DIAGNOSTICS"))
  (error "BENCH_DIAGNOSTICS requires closure or prediction experimental hooks"))
;; Compilation and lexing are outside all measured regions.
(unless (eq *scope* :production)
  (cnvrs/java8-interning:install *scope*))
(when (uiop:getenv "BENCH_RUN_TESTS")
  (asdf:test-system :cnvrs)
  (uiop:quit 0))
(defparameter *entry* (find-symbol "COMPILATIONUNIT" '#:java8/intern-bench/parser))
(defparameter *trials* (parse-integer (or (uiop:getenv "BENCH_TRIALS") "3")))
(defparameter *iterations* (parse-integer (or (uiop:getenv "BENCH_WARM_ITERATIONS") "1000")))
(defparameter *seconds* (parse-integer (or (uiop:getenv "BENCH_SECONDS") "10")))
(defparameter *output*
  (uiop:ensure-directory-pathname
   (or (uiop:getenv "BENCH_OUTPUT_DIR") "/tmp/cnvrs-interning-results/")))
(ensure-directories-exist (merge-pathnames "placeholder" *output*))
(defparameter *cases*
  (list (cons "empty" "class Hello {}")
        (cons "field" "class Hello { int x; }")
        (cons "return" "class Hello { int f() { return 1; } }")
        (cons "call" "class Hello { void f() { foo(); } }")
        (cons "arithmetic" "class Calc { int f(int x) { return x * 2 + 1; } }")
        (cons "lambda" "class Demo { Runnable r = () -> { foo(); }; }")
        (cons "nested" "class Flow { int f(int x) { if (x > 0) { return x; } else { return -x; } } }")
        (cons "loop" "class Counter { int sum(int n) { int s = 0; for (int i = 0; i < n; i++) { s += i; } return s; } }")
        (cons "bench-source" (uiop:read-file-string "bench/antlr4-grammar/Bench.java"))))

(defun tree-signature (value)
  (typecase value
    (cnvrs::node
     (list (cnvrs:node-rule value) (cnvrs:node-label value)
           (cnvrs:node-start value) (cnvrs:node-end value)
           (mapcar #'tree-signature (cnvrs:node-children value))))
    (cnvrs::lexeme
     (list (cnvrs:lexeme-kind value) (cnvrs:lexeme-text value)
           (cnvrs:lexeme-start value) (cnvrs:lexeme-end value)))
    (t value)))

(defun emit (fields)
  (format t "~&RESULT~{~C~A~}~%"
          (loop for value in fields append (list #\Tab value)))
  (finish-output))

(defun run-case (name source trial)
  (let* ((tokens (cnvrs:lex *lexer* source))
         (parser (cnvrs:clone-compiled *parser*))
         (metrics (when (uiop:getenv "BENCH_DIAGNOSTICS")
                    (cnvrs/java8-interning:make-metrics))))
    (sb-ext:gc :full t)
    (let* ((live-before (sb-kernel:dynamic-usage))
           (bytes-before (sb-ext:get-bytes-consed))
           (begin (get-internal-real-time))
           (tree nil))
      (handler-case
          (sb-ext:with-timeout *seconds*
            (let ((cnvrs/java8-interning:*metrics* metrics))
              (setf tree (cnvrs:parse parser tokens :lexer nil :rule *entry*)))
            (let ((cold-ms (* 1000.0 (/ (- (get-internal-real-time) begin)
                                        internal-time-units-per-second)))
                  (allocated (- (sb-ext:get-bytes-consed) bytes-before)))
              (sb-ext:gc :full t)
              (let ((retained (- (sb-kernel:dynamic-usage) live-before)))
                (with-open-file (out (merge-pathnames
                                      (format nil "~(~A~)-~A-~D.signature" *scope* name trial)
                                      *output*)
                                     :direction :output :if-exists :supersede)
                  (let ((*print-pretty* nil) (*print-length* nil) (*print-level* nil)
                        (*package* (find-package :keyword)))
                    (prin1 (tree-signature tree) out)))
                (if metrics
                    (emit (list *scope* name trial "stats" (length source) (length tokens)
                                cold-ms allocated retained
                                (cnvrs/java8-interning:metrics-closures metrics)
                                (cnvrs/java8-interning:metrics-keys metrics)
                                (cnvrs/java8-interning:metrics-arenas metrics)
                                (cnvrs/java8-interning:metrics-contexts metrics)
                                (cnvrs/java8-interning:metrics-peak-contexts metrics)
                                (cnvrs/java8-interning:metrics-peak-stacks metrics)
                                (cnvrs/java8-interning:live-arenas metrics)))
                    (let ((begin (get-internal-real-time))
                          (bytes-before (sb-ext:get-bytes-consed)))
                      (dotimes (i *iterations*)
                        (cnvrs:parse parser tokens :lexer nil :rule *entry* :tree-builder :none))
                      (emit (list *scope* name trial "ok" (length source) (length tokens)
                                  cold-ms allocated retained
                                  (* 1000.0 (/ (- (get-internal-real-time) begin)
                                               (* *iterations* internal-time-units-per-second)))
                                  (/ (- (sb-ext:get-bytes-consed) bytes-before) (float *iterations*)))))))))
        (sb-ext:timeout () (emit (list *scope* name trial "timeout" (length source) (length tokens))))
        (error (e) (emit (list *scope* name trial "error" (type-of e) e)))))))

(let ((selected (uiop:getenv "BENCH_CASES")))
  (dolist (case *cases*)
    (when (if selected
              (member (car case) (uiop:split-string selected :separator ",") :test #'equal)
              (not (equal (car case) "bench-source")))
      (loop for trial from 1 to *trials* do
        (run-case (car case) (cdr case) trial)))))
