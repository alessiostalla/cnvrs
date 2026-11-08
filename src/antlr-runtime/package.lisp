;;; ANTLR Java runtime 4.13.2 port. See LICENSE-ANTLR.txt.
(defpackage #:cnvrs/antlr-runtime
  (:use #:cl)
  (:export #:prediction-context #:empty-prediction-context #:singleton-context
           #:context-return-states #:context-parents #:context-hash
           #:context-equal #:merge-contexts #:make-context-cache #:cached-context
           #:context-from-stack #:context-paths #:+empty-return-state+
           #:atn #:make-atn #:atn-states #:atn-rule-stops #:atn-decisions
           #:atn-state #:make-atn-state #:atn-state-number #:atn-state-kind
           #:atn-state-rule #:atn-state-transitions
           #:atn-transition #:make-atn-transition #:atn-transition-kind
           #:atn-transition-target #:atn-transition-follow #:atn-transition-label
           #:atn-transition-precedence
           #:atn-config #:make-atn-config #:atn-config-state #:atn-config-alt
           #:atn-config-context #:atn-config-semantic #:atn-config-outer-depth
           #:atn-config-set #:make-atn-config-set #:config-set-items
           #:config-set-full-context #:config-set-add #:config-set-alternatives
           #:conflicting-alt-subsets #:has-sll-conflict-terminating-prediction
           #:single-viable-alt #:unique-alt
           #:parser-atn-simulator #:make-parser-atn-simulator #:adaptive-predict
           #:simulator-decision-dfas #:simulator-context-cache #:simulator-atn
           #:simulator-mode #:simulator-trace #:clear-dfa
           #:compute-start-state #:compute-reach-set
           #:dfa #:dfa-start #:dfa-states #:dfa-state #:dfa-state-configs
           #:dfa-state-accept-p #:dfa-state-prediction #:dfa-state-requires-full-context
           #:dfa-state-edges #:no-viable-alt
           #:lexer-atn-simulator #:new-lexer-atn-simulator #:lexer-match #:lexer-clear-dfa
           #:lexer-simulator-atn #:lexer-simulator-dfas
           #:atn-mode-starts #:atn-rule-starts #:atn-rule-token-types #:atn-lexer-actions
           #:atn-state-non-greedy-p
           #:lexer-dfa #:lexer-dfa-start #:lexer-dfa-states #:lexer-dfa-state-count
           #:lexer-dfa-state #:lexer-dfa-state-number #:lexer-dfa-state-configs
           #:lexer-dfa-state-prediction #:lexer-dfa-state-actions #:lexer-dfa-state-edges
           #:lexer-config-state #:lexer-config-alt #:lexer-config-context
           #:lexer-config-actions #:lexer-config-non-greedy
           #:lexer-no-viable-alt #:lexer-error-start #:lexer-error-position #:lexer-error-line #:lexer-error-column))
(in-package #:cnvrs/antlr-runtime)
