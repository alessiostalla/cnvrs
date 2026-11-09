(asdf:defsystem #:cnvrs
  :description "Adaptive LL parsing of Lisp-form grammars with FASL compilation"
  :depends-on (#:fset #:bordeaux-threads #:cnvrs/antlr-runtime)
  :serial t
  :in-order-to ((asdf:test-op (asdf:test-op "cnvrs/tests")))
  :components ((:file "src/package")
               (:file "src/cache")
               (:file "src/graph")
               (:file "src/tokens")
               (:file "src/tree")
               (:file "src/cnvrs")
               (:file "src/native-atn")
               (:file "src/antlr-runtime-adapter")
               (:file "src/semantic")
               (:static-file "src/antlr-unicode-data.sexp")
               (:file "src/antlr-unicode-data")
               (:file "src/lexer")
               (:file "src/lexer-atn")
               (:file "src/lexer-runtime")
               (:file "src/fasl")
               (:file "src/macros")
               (:file "src/antlr4-package")
               (:file "src/antlr4-parser")
               (:file "src/antlr4")
               (:file "src/antlr4-convert")))

(asdf:defsystem #:cnvrs/tests
  :depends-on (#:cnvrs #:cnvrs/antlr-runtime-tests)
  :serial t
  :components ((:file "test/file-expression")
               (:file "test/file-java")
               (:file "test/file-topology")
               (:file "test/atn-topology")
               (:file "test/file-ll1")
               (:file "test/ll1")
               (:file "test/file-lexer-atn")
               (:file "test/lexer-atn")
               (:file "test/cnvrs"))
  :perform (asdf:test-op (operation system)
             (declare (ignore operation system))
             (funcall (find-symbol "RUN-TESTS" "CNVRS/TESTS"))
             (funcall (find-symbol "RUN-TESTS" "CNVRS/TESTS/TOPOLOGY"))
             (funcall (find-symbol "RUN-TESTS" "CNVRS/TESTS/LEXER-ATN"))
             (funcall (find-symbol "RUN-TESTS" "CNVRS/TESTS/LL1"))
             (funcall (find-symbol "RUN-TESTS" "CNVRS/ANTLR-RUNTIME/TESTS"))))

(asdf:defsystem #:cnvrs/antlr-runtime
  :description "Reference port of the ANTLR Java 4.13.2 parser and lexer ATN runtimes"
  :depends-on (#:bordeaux-threads)
  :serial t
  :in-order-to ((asdf:test-op (asdf:test-op "cnvrs/antlr-runtime-tests")))
  :components ((:file "src/antlr-runtime/package")
               (:file "src/antlr-runtime/prediction-context")
               (:file "src/antlr-runtime/atn-config")
               (:file "src/antlr-runtime/ll1-analyzer")
               (:file "src/antlr-runtime/parser-atn-simulator")
               (:file "src/antlr-runtime/lexer-atn-simulator")))

(asdf:defsystem #:cnvrs/antlr-runtime-tests
  :depends-on (#:cnvrs/antlr-runtime)
  :components ((:file "test/antlr-runtime"))
  :perform (asdf:test-op (operation system)
             (declare (ignore operation system))
             (funcall (find-symbol "RUN-TESTS" "CNVRS/ANTLR-RUNTIME/TESTS"))))
