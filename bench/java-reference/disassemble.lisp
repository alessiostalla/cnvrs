;;; Native ARM64/SBCL code for warm prediction hot paths and their helpers.
(require :asdf)
(let ((setup (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file setup) (load setup)))
(asdf:load-asd (truename "cnvrs.asd"))
(asdf:load-system :cnvrs)
(let* ((directory (uiop:ensure-directory-pathname
                   (or (first (uiop:command-line-arguments)) "bench/java-reference/disassembly-results/")))
       (names '(cnvrs/runtime::closure-checking-stop-state
                cnvrs/runtime::closure-work
                cnvrs/runtime::get-epsilon-target
                cnvrs/runtime::derive-config
                cnvrs/runtime::can-drop-loop-entry-edge-in-left-recursive-rule
                cnvrs/runtime::find-config-in-bucket
                cnvrs/runtime::context-first-entry
                cnvrs/runtime:config-set-add
                cnvrs/runtime::config-lookup-hash
                cnvrs/runtime::config-lookup-equal
                cnvrs/runtime:merge-contexts
                cnvrs/runtime::merge-singletons
                cnvrs/runtime::merge-arrays
                cnvrs/runtime:context-equal
                cnvrs/runtime::context-size
                cnvrs/runtime::context-return-state
                cnvrs/runtime::context-parent
                cnvrs/runtime::context-node
                cnvrs/runtime:singleton-context
                cnvrs/runtime::merge-cache-get
                cnvrs/runtime::merge-cache-put
                cnvrs/runtime::combine-common-parents)))
  (ensure-directories-exist directory)
  (dolist (name names)
    (with-open-file (out (merge-pathnames (format nil "~(~A~).asm" (symbol-name name)) directory)
                         :direction :output :if-exists :supersede)
      (let ((*standard-output* out)) (disassemble (symbol-function name))))))
