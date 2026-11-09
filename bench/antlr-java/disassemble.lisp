;;; Native ARM64/SBCL code for warm prediction hot paths and their helpers.
(require :asdf)
(let ((setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file setup) (load setup)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)
(let* ((directory (uiop:ensure-directory-pathname
                   (or (first (uiop:command-line-arguments)) "bench/antlr-java/disassembly-results/")))
       (names '(cnvrs/antlr-runtime::closure-checking-stop-state
                cnvrs/antlr-runtime::closure-work
                cnvrs/antlr-runtime::get-epsilon-target
                cnvrs/antlr-runtime::derive-config
                cnvrs/antlr-runtime::can-drop-loop-entry-edge-in-left-recursive-rule
                cnvrs/antlr-runtime::find-config-in-bucket
                cnvrs/antlr-runtime::context-first-entry
                cnvrs/antlr-runtime:config-set-add
                cnvrs/antlr-runtime::config-lookup-hash
                cnvrs/antlr-runtime::config-lookup-equal
                cnvrs/antlr-runtime:merge-contexts
                cnvrs/antlr-runtime::merge-singletons
                cnvrs/antlr-runtime::merge-arrays
                cnvrs/antlr-runtime:context-equal
                cnvrs/antlr-runtime::context-size
                cnvrs/antlr-runtime::context-return-state
                cnvrs/antlr-runtime::context-parent
                cnvrs/antlr-runtime::context-node
                cnvrs/antlr-runtime:singleton-context
                cnvrs/antlr-runtime::merge-cache-get
                cnvrs/antlr-runtime::merge-cache-put
                cnvrs/antlr-runtime::combine-common-parents)))
  (ensure-directories-exist directory)
  (dolist (name names)
    (with-open-file (out (merge-pathnames (format nil "~(~A~).asm" (symbol-name name)) directory)
                         :direction :output :if-exists :supersede)
      (let ((*standard-output* out)) (disassemble (symbol-function name))))))
