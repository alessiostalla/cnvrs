(require :asdf)
(let ((setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file setup) (load setup)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)
(load "bench/iri/compiled-dfa.lisp")

(defun dfa-benchmark-median (thunk &optional (iterations 200))
  (let ((samples
          (loop repeat 7 collect
            (let ((start (get-internal-real-time)))
              (dotimes (i iterations) (funcall thunk))
              (* 1000 (/ (- (get-internal-real-time) start)
                         (* iterations internal-time-units-per-second)))))))
    (fourth (sort samples #'<))))

(let* ((source (uiop:read-file-string "test/fixtures/IRI.g4"))
       (definition (cnvrs/antlr4:parse source
                                        :parser-package '#:cnvrs/antlr4
                                        :lexer-package :keyword))
       (base (cnvrs:ensure-compiled definition))
       (interpreted (cnvrs:clone-compiled base))
       (generated (cnvrs:clone-compiled base))
       (input (with-output-to-string (out)
                (write-string "https://example.org/" out)
                (dotimes (i 20) (write-string "segment/" out))
                (write-string "resource?key=value&other=123#fragment" out)))
       (tokens (cnvrs:lex (cnvrs:parser-lexer base) input))
       (original (symbol-function 'cnvrs::predict-full-context))
       (original-advance (symbol-function 'cnvrs::advance-dfa))
       (hot-states nil)
       (captured nil)
       (collecting nil)
       (fallbacks 0))
  (dolist (parser (list interpreted generated))
    (dotimes (i 10)
      (cnvrs:parse parser tokens :lexer nil :tree-builder :none)))
  (unwind-protect
       (progn
         (setf (symbol-function 'cnvrs::advance-dfa)
               (lambda (grammar dfa token)
                 (let ((next (funcall original-advance grammar dfa token)))
                   (when collecting
                     (pushnew dfa hot-states :test #'eq)
                     (pushnew next hot-states :test #'eq))
                   next))
               (symbol-function 'cnvrs::predict-full-context)
               (lambda (grammar decision stack input position)
                 (if (and (eq grammar generated) (= decision 14))
                     (progn
                       (unless captured
                         (setf captured (list grammar decision (copy-list stack)
                                              input position)))
                       (pushnew (cnvrs::cached-full-context-start
                                 grammar decision stack)
                                hot-states :test #'eq)
                       (setf collecting t)
                       (unwind-protect
                            (funcall original grammar decision stack input position)
                         (setf collecting nil)))
                     (funcall original grammar decision stack input position))))
         (cnvrs:parse generated tokens :lexer nil :tree-builder :none))
    (setf (symbol-function 'cnvrs::predict-full-context) original
          (symbol-function 'cnvrs::advance-dfa) original-advance))
  (let ((start (get-internal-real-time)))
    (multiple-value-bind (predictor state-ids state-count)
        (compile-iri-cached-dfa generated hot-states)
      (format t "Compiled ~D cached DFA states in ~,3F ms~%" state-count
              (* 1000 (/ (- (get-internal-real-time) start)
                         internal-time-units-per-second)))
      (unwind-protect
           (progn
             (setf (symbol-function 'cnvrs::predict-full-context)
                   (lambda (grammar decision stack input position)
                     (if (and (eq grammar generated) (= decision 14))
                         (funcall predictor grammar decision stack input
                                  position state-ids
                                  (lambda (&rest args)
                                    (incf fallbacks)
                                    (apply original args)))
                         (funcall original grammar decision stack input position))))
             (dolist (case '("http://example.org/x"
                             "https://example.org/path?x=1#f"
                             "mailto:alice@example.org"
                             "ftp://user@example.org:21/a/b"
                             "http://127.0.0.1:8080/a%20b"
                             "http://[2001:db8::1]/x"
                             "not-a-uri" "http://example.org/a b"
                             "http://example.org/%GG"
                             "http://[2001:db8::1/x"))
               (flet ((result (parser)
                        (handler-case
                            (list :ok (cnvrs:parse parser case :tree-builder :none))
                          (error (condition)
                            (list :error (type-of condition))))))
                 (unless (equal (result interpreted) (result generated))
                   (error "Compiled DFA differs on ~S" case))))
             (format t "10 valid/invalid cases agree~%")
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
                   (error "Compiled DFA differs on ~S" case))))
             (format t "3 alternate entry rules agree~%")
             (setf fallbacks 0)
             (cnvrs:parse generated tokens :lexer nil :tree-builder :none)
             (format t "Trained-input fallbacks: ~D~%" fallbacks)
             (destructuring-bind (grammar decision stack input position)
                 captured
               (flet ((old-predict ()
                        (funcall original grammar decision stack input position))
                      (new-predict ()
                        (funcall predictor grammar decision stack input position
                                 state-ids original)))
                 (unless (eql (old-predict) (new-predict))
                   (error "Compiled prediction differs on captured decision"))
                 (format t "INTERPRETED prediction ~,4F ms/call~%"
                         (dfa-benchmark-median #'old-predict 2000))
                 (format t "COMPILED prediction ~,4F ms/call~%"
                         (dfa-benchmark-median #'new-predict 2000))))
             (dolist (entry `((:interpreted ,interpreted)
                             (:compiled ,generated)))
               (let ((parser (second entry)))
                 (format t "~A warm ~,3F ms/parse~%" (first entry)
                         (dfa-benchmark-median
                          (lambda ()
                            (cnvrs:parse parser tokens :lexer nil
                                         :tree-builder :none)))))))
        (setf (symbol-function 'cnvrs::predict-full-context) original)))))
