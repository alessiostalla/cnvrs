(asdf:defsystem #:cnvrs
  :description "Adaptive LL parsing of Lisp-form grammars with FASL compilation"
  :depends-on (#:fset #:bordeaux-threads)
  :serial t
  :in-order-to ((asdf:test-op (asdf:test-op "cnvrs/tests")))
  :components ((:file "src/package")
               (:file "src/cache")
               (:file "src/graph")
               (:file "src/tokens")
               (:file "src/tree")
               (:file "src/cnvrs")
               (:file "src/semantic")
               (:file "src/dfa-compiler")
               (:file "src/lexer")
               (:file "src/fasl")
               (:file "src/macros")
               (:file "src/antlr4-package")
               (:file "src/antlr4-parser")
               (:file "src/antlr4")
               (:file "src/antlr4-convert")))

(asdf:defsystem #:cnvrs/tests
  :depends-on (#:cnvrs)
  :serial t
  :components ((:file "test/file-expression")
               (:file "test/file-java")
               (:file "test/cnvrs"))
  :perform (asdf:test-op (operation system)
             (declare (ignore operation system))
             (funcall (find-symbol "RUN-TESTS" "CNVRS/TESTS"))))
