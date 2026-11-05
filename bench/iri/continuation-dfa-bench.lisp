(require :asdf)
(let ((setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file setup) (load setup)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)
(load "bench/iri/continuation-dfa.lisp")

(defun median-ms (thunk iterations)
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
       (ordinary (cnvrs:clone-compiled base))
       (continuation (cnvrs:clone-compiled base))
       (functions (multiple-value-list
                   (make-continuation-predictor continuation)))
       (predictor (first functions))
       (to-chain (second functions))
       (original (symbol-function 'cnvrs::predict-full-context))
       (calls nil)
       (collecting t)
       (long-input (with-output-to-string (out)
                     (write-string "https://example.org/" out)
                     (dotimes (i 20) (write-string "segment/" out))
                     (write-string "resource?key=value&other=123#fragment" out)))
       (cases '("http://example.org/x"
                "https://example.org/path?x=1#f"
                "mailto:alice@example.org"
                "ftp://user@example.org:21/a/b"
                "http://127.0.0.1:8080/a%20b"
                "http://[2001:db8::1]/x"
                "not-a-uri" "http://example.org/a b"
                "http://example.org/%GG" "http://[2001:db8::1/x")))
  (flet ((result (parser input &optional rule)
           (handler-case
               (list :ok (if rule
                             (cnvrs:parse parser input :rule rule
                                          :tree-builder :none)
                             (cnvrs:parse parser input :tree-builder :none)))
             (error (condition) (list :error (type-of condition))))))
    (unwind-protect
         (progn
           (setf (symbol-function 'cnvrs::predict-full-context)
                 (lambda (grammar state stack tokens position)
                   (if (eq grammar continuation)
                       (progn
                         (when collecting
                           (push (list state (copy-list stack) tokens position)
                                 calls))
                         (funcall predictor state stack tokens position))
                       (funcall original grammar state stack tokens position))))
           (dolist (input cases)
             (let ((left (result ordinary input))
                   (right (result continuation input)))
               (unless (equal left right)
                 (error "Mismatch on ~S: ~S versus ~S" input left right))))
           (unless (equal (result ordinary long-input)
                          (result continuation long-input))
             (error "Mismatch on long IRI"))
           (dolist (case '((cnvrs/antlr4::iri_reference "//example.org/path")
                           (cnvrs/antlr4::absolute_iri "http://example.org/x")
                           (cnvrs/antlr4::iri "http://example.org/x")))
             (unless (equal (result ordinary (second case) (first case))
                            (result continuation (second case) (first case)))
               (error "Mismatch on entry rule ~S" (first case))))
           (format t "14 parsing cases agree; ~D full-context calls captured.~%"
                   (length calls))
           (setf collecting nil)
           (unless calls (error "No full-context decisions exercised"))
           (dolist (call calls)
             (destructuring-bind (state stack tokens position) call
               (unless (eql (funcall original ordinary state stack tokens position)
                            (funcall predictor state stack tokens position))
                 (error "Prediction mismatch at state ~D" state))))
           (let ((call (reduce (lambda (left right)
                                 (if (> (length (second left))
                                        (length (second right)))
                                     left right))
                               calls)))
             (destructuring-bind (state stack tokens position) call
               (let ((chain (funcall to-chain stack)))
                 (format t "Measured return depth: ~D~%" (length stack))
                 (format t "Original warm prediction: ~,5F ms/call~%"
                         (median-ms
                          (lambda () (funcall original ordinary state stack
                                              tokens position)) 100000))
                 (format t "Continuation warm prediction: ~,5F ms/call~%"
                         (median-ms
                          (lambda () (funcall predictor state stack tokens position))
                          100000))
                 (format t "Continuation with chain ready: ~,5F ms/call~%"
                         (median-ms
                          (lambda () (funcall predictor state chain tokens position))
                          100000)))))
           (format t "Original warm parse: ~,4F ms/parse~%"
                   (median-ms (lambda () (result ordinary long-input)) 2000))
           (format t "Continuation warm parse: ~,4F ms/parse~%"
                   (median-ms (lambda () (result continuation long-input)) 2000)))
      (setf (symbol-function 'cnvrs::predict-full-context) original))))
