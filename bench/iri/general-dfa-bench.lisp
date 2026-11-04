(require :asdf)
(let ((setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file setup) (load setup)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)

(defun dfa-median-ms (thunk)
  (fourth
   (sort (loop repeat 7 collect
           (let ((start (get-internal-real-time)))
             (dotimes (i 1000) (funcall thunk))
             (* 1000 (/ (- (get-internal-real-time) start)
                        (* 1000 internal-time-units-per-second)))))
         #'<)))

(let* ((source (uiop:read-file-string "test/fixtures/IRI.g4"))
       (definition (cnvrs/antlr4:parse source))
       (base (cnvrs:ensure-compiled definition))
       (ordinary (cnvrs:clone-compiled base))
       (generated (cnvrs:clone-compiled base))
       (input (with-output-to-string (out)
                (write-string "https://example.org/" out)
                (dotimes (i 20) (write-string "segment/" out))
                (write-string "resource?key=value&other=123#fragment" out)))
       (tokens (cnvrs:lex (cnvrs:parser-lexer base) input)))
  (dolist (parser (list ordinary generated))
    (dotimes (i 10)
      (cnvrs:parse parser tokens :lexer nil :tree-builder :none)))
  (let ((start (get-internal-real-time)))
    (multiple-value-bind (roots states)
        (cnvrs:compile-cached-dfa generated :max-states 32)
      (format t "Compiled ~D roots, ~D observed states in ~,3F ms~%"
              roots states
              (* 1000 (/ (- (get-internal-real-time) start)
                         internal-time-units-per-second)))))
  (dolist (case '("http://example.org/x"
                  "https://example.org/path?x=1#f"
                  "mailto:alice@example.org"
                  "ftp://user@example.org:21/a/b"
                  "http://127.0.0.1:8080/a%20b"
                  "http://[2001:db8::1]/x"
                  "not-a-uri" "http://example.org/a b"
                  "http://example.org/%GG" "http://[2001:db8::1/x"))
    (flet ((result (parser)
             (handler-case
                 (list :ok (cnvrs:parse parser case :tree-builder :none))
               (error (condition) (list :error (type-of condition))))))
      (unless (equal (result ordinary) (result generated))
        (error "Compiled DFA differs on ~S" case))))
  (format t "10 varied IRI cases agree~%")
  (format t "Ordinary: ~,5F ms/parse~%"
          (dfa-median-ms
           (lambda () (cnvrs:parse ordinary tokens :lexer nil
                                   :tree-builder :none))))
  (format t "Compiled: ~,5F ms/parse~%"
          (dfa-median-ms
           (lambda () (cnvrs:parse generated tokens :lexer nil
                                   :tree-builder :none)))))
