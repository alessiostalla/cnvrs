(asdf:defsystem #:cnvrs
  :description "In-image adaptive LL parsing of Lisp-form grammars"
  :depends-on (#:fset #:bordeaux-threads)
  :serial t
  :in-order-to ((asdf:test-op (asdf:test-op "cnvrs/tests")))
  :components ((:file "src/package")
               (:file "src/cache")
               (:file "src/graph")
               (:file "src/tokens")
               (:file "src/tree")
               (:file "src/cnvrs")
               (:file "src/dfa-compiler")
               (:file "src/lexer")
               (:file "src/macros")
               (:file "src/antlr4-package")
               (:file "src/antlr4-parser")
               (:file "src/antlr4")
               (:file "src/antlr4-convert")))

(asdf:defsystem #:cnvrs/tests
  :depends-on (#:cnvrs)
  :serial t
  :components ((:file "test/cnvrs"))
  :perform (asdf:test-op (operation system)
             (declare (ignore operation system))
             (funcall (find-symbol "RUN-TESTS" "CNVRS/TESTS"))))
