(defpackage #:cnvrs
  (:use #:cl)
  (:shadow #:parse-error)
  (:export #:compile-grammar #:compile-lexer #:compile-cached-dfa #:parse #:lex
           #:ensure-compiled #:clone-compiled #:clear-cache
           #:make-parse-node #:parse-node-components
           #:parse-build-tree-p #:parse-rule-enter #:parse-token-consumed
           #:parse-rule-exit
           #:make-cache #:cache-get-or-compute #:cache-clear #:cache-count
           #:cache-entries
           #:parser-cache-backend #:parser-full-context-strategy
           #:make-full-context-start
           #:compiled-lexer-cache-backend
           #:compiled-lexer-cache
           #:parser-p #:parser-states #:parser-starts #:parser-stops
           #:parser-default-rule #:parser-lexer #:parser-rewrites
           #:parser-metadata #:parser-definition-metadata
           #:parser-tree-builder #:parser-runner #:parser-node-runner
           #:parser-decisions #:parser-sll-decisions #:parser-direct-decisions
           #:state-id #:state-edges #:state-stop-rule #:state-exit-alternative
           #:state-direct-lookahead
           #:transition-kind #:transition-target #:transition-value
           #:compiled-lexer-p #:compiled-lexer-states
           #:compiled-lexer-metadata
           #:compiled-lexer-mode-starts #:compiled-lexer-kinds
           #:compiled-lexer-skips #:compiled-lexer-channels
           #:compiled-lexer-push-modes #:compiled-lexer-pop-modes
           #:compiled-lexer-set-modes
           #:lx-state-edges #:lx-state-accept
           #:lx-edge-kind #:lx-edge-target #:lx-edge-value
           #:define-parser #:in-parser #:defrule #:with-mode
           #:parser-definition-p #:lexer-matcher
           #:grammar-error #:parse-error
           #:lexical-error #:lexical-error-position #:lexical-error-character
           #:lexer-mode-error #:lexer-mode-error-mode
           #:make-lexeme #:lexeme-p #:lexeme-kind #:lexeme-text
           #:lexeme-start #:lexeme-end #:lexeme-channel
           #:parse-error-position #:parse-error-token #:parse-error-expected
           #:mismatched-token #:no-viable-alternative #:unexpected-input
           #:parse-error-rule #:+end-of-input+
           #:insert-tokens #:delete-tokens
           #:choose-alternative
           #:discard-input #:recovery-p #:recovery-action #:recovery-condition
           #:recovery-token #:inserted-token-p #:inserted-token-expected
           #:inserted-token-value #:inserted-token-position
           #:node-p #:node-rule #:node-children #:node-start #:node-end
           #:node-label))

(in-package #:cnvrs)

#+sbcl (declaim (optimize (speed 3) (safety 1) (debug 0)
                           (space 0) (compilation-speed 0)))
