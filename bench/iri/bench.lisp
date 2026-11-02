(require :asdf)
(let ((setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file setup) (load setup)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)

(let* ((source (uiop:read-file-string
                (merge-pathnames "test/fixtures/IRI.g4"
                                 (asdf:system-source-directory :cnvrs))))
       (definition (cnvrs/antlr4:parse source))
       (base (cnvrs:ensure-compiled definition))
       (input (with-output-to-string (out)
                (write-string "https://example.org/" out)
                (dotimes (i 20) (write-string "segment/" out))
                (write-string "resource?key=value&other=123#fragment" out)))
       (tokens (cnvrs:lex (cnvrs:parser-lexer base) input)))
  (format t "~D characters, ~D tokens, ~D parser states~%"
          (length input) (length tokens) (length (cnvrs:parser-states base)))
  (dolist (strategy '(:cached :recompute))
    (let ((parser (cnvrs:clone-compiled base :full-context-strategy strategy)))
      (dotimes (i 10)
        (cnvrs:parse parser tokens :lexer nil :tree-builder :none))
      (let ((samples
              (loop repeat 7 collect
                (let ((start (get-internal-real-time)))
                  (dotimes (i 200)
                    (cnvrs:parse parser tokens :lexer nil :tree-builder :none))
                  (* 1000 (/ (- (get-internal-real-time) start)
                             (* 200 internal-time-units-per-second)))))))
        (format t "~A: ~,3F ms/parse median (~D full-context starts cached)~%"
                strategy (fourth (sort samples #'<))
                (cnvrs:cache-count (cnvrs:parser-decisions parser)))))))
