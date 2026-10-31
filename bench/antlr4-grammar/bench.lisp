(require :asdf)
(let ((quicklisp-setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-setup)
    (load quicklisp-setup)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)

(defun median (values)
  (nth (floor (length values) 2) (sort values #'<)))

(defun bench-file (path warmup batches iterations)
  (let ((source (uiop:read-file-string path :external-format :utf-8)))
    (handler-case
        (progn
          (cnvrs:parse cnvrs/antlr4:*parser* source
                       :tree-builder (if (equal (uiop:getenv "BENCH_TREE") "1") :node :none))
          (dotimes (i warmup)
            (cnvrs:parse cnvrs/antlr4:*parser* source
                         :tree-builder (if (equal (uiop:getenv "BENCH_TREE") "1") :node :none)))
          (let ((samples nil))
            (dotimes (batch batches)
              (let ((start (get-internal-real-time)))
                (dotimes (i iterations)
                  (cnvrs:parse cnvrs/antlr4:*parser* source
                               :tree-builder (if (equal (uiop:getenv "BENCH_TREE") "1") :node :none)))
                (push (round (* 1000000000
                                (/ (- (get-internal-real-time) start)
                                   internal-time-units-per-second))
                             iterations)
                      samples)))
            (format t "OK~C~A~C~D~C~D~%"
                    #\Tab (file-namestring path) #\Tab (length source)
                    #\Tab (median samples))))
      (error (condition)
        (format t "FAIL~C~A~C~A~%"
                #\Tab (file-namestring path) #\Tab condition)))))

(let* ((args (uiop:command-line-arguments))
       (warmup (parse-integer (first args)))
       (batches (parse-integer (second args)))
       (iterations (parse-integer (third args))))
  (dolist (path (cdddr args))
    (bench-file path warmup batches iterations)))
