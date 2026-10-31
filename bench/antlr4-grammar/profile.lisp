(require :asdf)
(let ((quicklisp-setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-setup)
    (load quicklisp-setup)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)
(require :sb-sprof)

(let ((backend (uiop:getenv "PROFILE_CACHE_BACKEND")))
  (when backend
    (let ((designator
            (cond ((equal backend "hash-table") :hash-table)
                  ((equal backend "locked-hash-table") '(:locked :hash-table))
                  ((equal backend "fset") :fset)
                  ((equal backend "locked-fset") '(:locked :fset))
                  (t (error "Unknown PROFILE_CACHE_BACKEND: ~A" backend)))))
      (setf cnvrs/antlr4:*lexer*
            (cnvrs:clone-compiled cnvrs/antlr4:*lexer*
                                  :cache-backend designator)
            cnvrs/antlr4:*parser*
            (cnvrs:clone-compiled cnvrs/antlr4:*parser*
                                  :cache-backend designator)))))

(let* ((args (uiop:command-line-arguments))
       (source (uiop:read-file-string (first args) :external-format :utf-8))
       (iterations (parse-integer (second args)))
       (tree-builder (if (equal (uiop:getenv "BENCH_TREE") "1") :node :none))
       (phase (or (uiop:getenv "PROFILE_PHASE") "full"))
       (tokens (when (equal phase "parser") (cnvrs/antlr4:lex source))))
  (flet ((run-one ()
           (cond ((equal phase "lexer") (cnvrs/antlr4:lex source))
                 ((equal phase "parser")
                  (cnvrs:parse cnvrs/antlr4:*parser* tokens :lexer nil
                               :tree-builder tree-builder))
                 ((equal phase "full")
                  (cnvrs:parse cnvrs/antlr4:*parser* source
                               :tree-builder tree-builder))
                 (t (error "Unknown PROFILE_PHASE: ~A" phase)))))
  (dotimes (i 10)
    (run-one))
  (let ((start (get-internal-real-time)))
    (dotimes (i iterations) (run-one))
    (format t "Elapsed without profiler: ~,3F ms/iteration~%"
            (* 1000 (/ (- (get-internal-real-time) start)
                       (* iterations internal-time-units-per-second)))))
  (sb-sprof:with-profiling (:reset t :mode :cpu :sample-interval 0.001
                            :max-samples 20000 :report :flat)
    (dotimes (i iterations)
      (run-one)))))
