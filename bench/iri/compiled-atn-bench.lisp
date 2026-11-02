(require :asdf)
(let ((setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file setup) (load setup)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)
(load "bench/iri/compiled-atn.lisp")

(defun benchmark-median (thunk batches iterations &key cold-parser)
  (let ((samples
          (loop repeat batches collect
            (let ((start (get-internal-real-time)))
              (dotimes (i iterations)
                (when cold-parser (cnvrs:clear-cache cold-parser))
                (funcall thunk))
              (* 1000 (/ (- (get-internal-real-time) start)
                         (* iterations internal-time-units-per-second)))))))
    (fourth (sort samples #'<))))

(let* ((source (uiop:read-file-string "test/fixtures/IRI.g4"))
       (definition (cnvrs/antlr4:parse source))
       (base (cnvrs:ensure-compiled definition))
       (interpreted (cnvrs:clone-compiled base))
       (generated (cnvrs:clone-compiled base))
       (input (with-output-to-string (out)
                (write-string "https://example.org/" out)
                (dotimes (i 20) (write-string "segment/" out))
                (write-string "resource?key=value&other=123#fragment" out)))
       (tokens (cnvrs:lex (cnvrs:parser-lexer base) input))
       (original-advance (symbol-function 'cnvrs::advance-dfa))
       (compile-start (get-internal-real-time)))
  (multiple-value-bind (compiled-start compiled-advance)
      (compile-iri-atn-simulator base)
    (format t "Generated ATN code in ~,3F ms~%"
            (* 1000 (/ (- (get-internal-real-time) compile-start)
                       internal-time-units-per-second)))
    (setf (cnvrs::parser-full-context-start generated) compiled-start)
    (unwind-protect
         (progn
           (setf (symbol-function 'cnvrs::advance-dfa)
                 (lambda (grammar dfa token)
                   (if (eq grammar generated)
                       (funcall compiled-advance grammar dfa token)
                       (funcall original-advance grammar dfa token))))
           (let ((cases '("http://example.org/x"
                          "https://example.org/path?x=1#f"
                          "mailto:alice@example.org"
                          "ftp://user@example.org:21/a/b"
                          "http://127.0.0.1:8080/a%20b"
                          "http://[2001:db8::1]/x"
                          "not-a-uri" "http://example.org/a b"
                          "http://example.org/%GG"
                          "http://[2001:db8::1/x")))
             (dolist (case cases)
               (flet ((result (parser)
                        (handler-case
                            (list :ok (cnvrs:parse parser case :tree-builder :none))
                          (error (condition)
                            (list :error (type-of condition))))))
                 (unless (equal (result interpreted) (result generated))
                   (error "Compiled ATN differs on ~S" case))))
             (format t "~D valid/invalid cases agree~%" (length cases)))
           (dolist (case '((cnvrs/antlr4::iri_reference
                            "//example.org/path")
                           (cnvrs/antlr4::absolute_iri
                            "http://example.org/x")
                           (cnvrs/antlr4::iri "http://example.org/x")))
             (flet ((result (parser)
                      (handler-case
                          (list :ok (cnvrs:parse parser (second case)
                                                 :rule (first case)
                                                 :tree-builder :none))
                        (error (condition)
                          (list :error (type-of condition))))))
               (unless (equal (result interpreted) (result generated))
                 (error "Compiled ATN differs on ~S" case))))
           (format t "3 alternate entry rules agree~%")
           (dolist (parser (list interpreted generated))
             (dotimes (i 10)
               (cnvrs:parse parser tokens :lexer nil :tree-builder :none)))
           (dolist (entry `((:interpreted ,interpreted)
                           (:compiled ,generated)))
             (let* ((name (first entry))
                    (parser (second entry))
                    (run (lambda ()
                           (cnvrs:parse parser tokens :lexer nil
                                        :tree-builder :none))))
               (format t "~A warm ~,3F ms/parse~%" name
                       (benchmark-median run 7 200))
               (format t "~A cold ~,3F ms/parse~%" name
                       (benchmark-median run 7 5 :cold-parser parser)))))
      (setf (symbol-function 'cnvrs::advance-dfa) original-advance))))
