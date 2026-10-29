;; /*
;;  * [The "BSD license"]
;;  *  Copyright (c) 2012-2014 Terence Parr
;;  *  Copyright (c) 2012-2014 Sam Harwell
;;  *  Copyright (c) 2015 Gerald Rosenberg
;;  *  All rights reserved.
;;  *
;;  *  Redistribution and use in source and binary forms, with or without
;;  *  modification, are permitted provided that the following conditions
;;  *  are met:
;;  *
;;  *  1. Redistributions of source code must retain the above copyright
;;  *     notice, this list of conditions and the following disclaimer.
;;  *  2. Redistributions in binary form must reproduce the above copyright
;;  *     notice, this list of conditions and the following disclaimer in the
;;  *     documentation and/or other materials provided with the distribution.
;;  *  3. The name of the author may not be used to endorse or promote products
;;  *     derived from this software without specific prior written permission.
;;  *
;;  *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
;;  *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
;;  *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
;;  *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
;;  *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
;;  *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;  *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;  *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;  *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
;;  *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;  */

(in-package #:cnvrs/antlr4)

(cnvrs:define-parser *parser* (:kind :parser :default-rule grammar-spec :lexer 'lex)
  (cnvrs:defrule grammar-spec
               (and grammar-decl (* prequel-construct) rules (* mode-spec)))
  (cnvrs:defrule grammar-decl (and grammar-type identifier :semi))
  (cnvrs:defrule grammar-type
               (or (and :lexer :grammar) (and :parser :grammar) :grammar))
  (cnvrs:defrule prequel-construct
               (or options-spec delegate-grammars tokens-spec channels-spec
                   action_))
  (cnvrs:defrule options-spec (and :options (* (and option :semi)) :rbrace))
  (cnvrs:defrule option (and identifier :assign option-value))
  (cnvrs:defrule option-value
               (or (and identifier (* (and :dot identifier))) :string_literal
                   action-block :int))
  (cnvrs:defrule delegate-grammars
               (and :import delegate-grammar (* (and :comma delegate-grammar))
                    :semi))
  (cnvrs:defrule delegate-grammar
               (or (and identifier :assign identifier) identifier))
  (cnvrs:defrule tokens-spec (and :tokens (? id-list) :rbrace))
  (cnvrs:defrule channels-spec (and :channels (? id-list) :rbrace))
  (cnvrs:defrule id-list (and identifier (* (and :comma identifier)) (? :comma)))
  (cnvrs:defrule action_
               (and :at (? (and action-scope-name :coloncolon)) identifier
                    action-block))
  (cnvrs:defrule action-scope-name (or identifier :lexer :parser))
  (cnvrs:defrule action-block :action)
  (cnvrs:defrule arg-action-block
               (and :begin_argument (* :argument_content) :end_argument))
  (cnvrs:defrule mode-spec (and :mode identifier :semi (* lexer-rule-spec)))
  (cnvrs:defrule rules (* rule-spec))
  (cnvrs:defrule rule-spec (or parser-rule-spec lexer-rule-spec))
  (cnvrs:defrule parser-rule-spec
               (and (? rule-modifiers) :rule_ref (? arg-action-block)
                    (? rule-returns) (? throws-spec) (? locals-spec)
                    (* rule-prequel) :colon rule-block :semi exception-group))
  (cnvrs:defrule exception-group (and (* exception-handler) (? finally-clause)))
  (cnvrs:defrule exception-handler (and :catch arg-action-block action-block))
  (cnvrs:defrule finally-clause (and :finally action-block))
  (cnvrs:defrule rule-prequel (or options-spec rule-action))
  (cnvrs:defrule rule-returns (and :returns arg-action-block))
  (cnvrs:defrule throws-spec
               (and :throws qualified-identifier
                    (* (and :comma qualified-identifier))))
  (cnvrs:defrule locals-spec (and :locals arg-action-block))
  (cnvrs:defrule rule-action (and :at identifier action-block))
  (cnvrs:defrule rule-modifiers (+ rule-modifier))
  (cnvrs:defrule rule-modifier (or :public :private :protected :fragment))
  (cnvrs:defrule rule-block rule-alt-list)
  (cnvrs:defrule rule-alt-list (and labeled-alt (* (and :or labeled-alt))))
  (cnvrs:defrule labeled-alt (and alternative (? (and :pound identifier))))
  (cnvrs:defrule lexer-rule-spec
               (and (? :fragment) :token_ref (? options-spec) :colon
                    lexer-rule-block :semi))
  (cnvrs:defrule lexer-rule-block lexer-alt-list)
  (cnvrs:defrule lexer-alt-list (and lexer-alt (* (and :or lexer-alt))))
  (cnvrs:defrule lexer-alt (or (and lexer-elements (? lexer-commands)) (and)))
  (cnvrs:defrule lexer-elements (or (+ lexer-element) (and)))
  (cnvrs:defrule lexer-element
               (or (and lexer-atom (? ebnf-suffix))
                   (and lexer-block (? ebnf-suffix))
                   (and action-block (? :question))))
  (cnvrs:defrule lexer-block (and :lparen lexer-alt-list :rparen))
  (cnvrs:defrule lexer-commands
               (and :rarrow lexer-command (* (and :comma lexer-command))))
  (cnvrs:defrule lexer-command
               (or (and lexer-command-name :lparen lexer-command-expr :rparen)
                   lexer-command-name))
  (cnvrs:defrule lexer-command-name (or identifier :mode))
  (cnvrs:defrule lexer-command-expr (or identifier :int))
  (cnvrs:defrule alt-list (and alternative (* (and :or alternative))))
  (cnvrs:defrule alternative (or (and (? element-options) (+ element)) (and)))
  (cnvrs:defrule element
               (or (and labeled-element (or ebnf-suffix (and)))
                   (and atom (or ebnf-suffix (and))) ebnf
                   (and action-block (? :question) (? predicate-options))))
  (cnvrs:defrule predicate-options
               (and :lt predicate-option (* (and :comma predicate-option)) :gt))
  (cnvrs:defrule predicate-option
               (or element-option
                   (and identifier :assign
                        (or action-block :int :string_literal))))
  (cnvrs:defrule labeled-element
               (and identifier (or :assign :plus_assign) (or atom block)))
  (cnvrs:defrule ebnf (and block (? block-suffix)))
  (cnvrs:defrule block-suffix ebnf-suffix)
  (cnvrs:defrule ebnf-suffix
               (or (and :question (? :question)) (and :star (? :question))
                   (and :plus (? :question))))
  (cnvrs:defrule lexer-atom
               (or character-range terminal-def not-set :lexer_char_set wildcard))
  (cnvrs:defrule atom (or terminal-def rule-ref not-set wildcard))
  (cnvrs:defrule wildcard (and :dot (? element-options)))
  (cnvrs:defrule not-set (or (and :not set-element) (and :not block-set)))
  (cnvrs:defrule block-set
               (and :lparen set-element (* (and :or set-element)) :rparen))
  (cnvrs:defrule set-element
               (or (and :token_ref (? element-options))
                   (and :string_literal (? element-options)) character-range
                   :lexer_char_set))
  (cnvrs:defrule block
               (and :lparen (? (and (? options-spec) (* rule-action) :colon))
                    alt-list :rparen))
  (cnvrs:defrule rule-ref (and :rule_ref (? arg-action-block) (? element-options)))
  (cnvrs:defrule character-range (and :string_literal :range :string_literal))
  (cnvrs:defrule terminal-def
               (or (and :token_ref (? element-options))
                   (and :string_literal (? element-options))))
  (cnvrs:defrule element-options
               (and :lt element-option (* (and :comma element-option)) :gt))
  (cnvrs:defrule element-option
               (or qualified-identifier
                   (and identifier :assign
                        (or qualified-identifier :string_literal :int))))
  (cnvrs:defrule identifier (or :rule_ref :token_ref))
  (cnvrs:defrule qualified-identifier (and identifier (* (and :dot identifier)))))
