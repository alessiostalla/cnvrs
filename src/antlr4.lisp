;; /*
;;  * [The "BSD license"]
;;  *  Copyright (c) 2012-2015 Terence Parr
;;  *  Copyright (c) 2012-2015 Sam Harwell
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

(cnvrs:define-parser *lexer* (:kind :lexer)
  (cnvrs:defrule :doc_comment
    (and "/**" (* (or (not-one-of (#\*))
                       (and #\* (not-one-of (#\/))))) "*/")
    :channel :comment)
  (cnvrs:defrule :block_comment
    (and "/*" (* (or (not-one-of (#\*))
                      (and #\* (not-one-of (#\/))))) "*/")
    :channel :comment)
  (cnvrs:defrule :line_comment
    (and "//" (* (not-one-of (#\Return #\Newline))))
    :channel :comment)
  (cnvrs:defrule :string_literal
    (and "'" (* (or (and #\\ (any))
                     (not-one-of (#\' #\Return #\Newline #\\)))) "'"))
  (cnvrs:defrule :unterminated_string_literal
    (and "'" (* (or (and #\\ (any))
                     (not-one-of (#\' #\Return #\Newline #\\))))))
  (cnvrs:defrule :options (and "options" (* :ws) #\{))
  (cnvrs:defrule :tokens (and "tokens" (* :ws) #\{))
  (cnvrs:defrule :channels (and "channels" (* :ws) #\{))
  (cnvrs:defrule :import "import")
  (cnvrs:defrule :fragment "fragment")
  (cnvrs:defrule :lexer "lexer")
  (cnvrs:defrule :parser "parser")
  (cnvrs:defrule :grammar "grammar")
  (cnvrs:defrule :protected "protected")
  (cnvrs:defrule :public "public")
  (cnvrs:defrule :private "private")
  (cnvrs:defrule :returns "returns")
  (cnvrs:defrule :locals "locals")
  (cnvrs:defrule :throws "throws")
  (cnvrs:defrule :catch "catch")
  (cnvrs:defrule :finally "finally")
  (cnvrs:defrule :mode "mode")
  (cnvrs:defrule :ws (+ (or #\Space #\Tab #\Newline #\Return #\Page))
    :channel :off_channel)
  (cnvrs:defrule :int (or "0" (and (range #\1 #\9) (* (range #\0 #\9)))))
  (cnvrs:defrule :id (and name-start (* name-char)))
  (cnvrs:defrule :coloncolon "::")
  (cnvrs:defrule :colon ":")
  (cnvrs:defrule :comma ",")
  (cnvrs:defrule :semi ";")
  (cnvrs:defrule :lparen "(")
  (cnvrs:defrule :rparen ")")
  (cnvrs:defrule :rarrow "->")
  (cnvrs:defrule :rbrace "}")
  (cnvrs:defrule :lt "<")
  (cnvrs:defrule :gt ">")
  (cnvrs:defrule :plus_assign "+=")
  (cnvrs:defrule :assign "=")
  (cnvrs:defrule :question "?")
  (cnvrs:defrule :star "*")
  (cnvrs:defrule :plus "+")
  (cnvrs:defrule :or "|")
  (cnvrs:defrule :dollar "$")
  (cnvrs:defrule :range "..")
  (cnvrs:defrule :dot ".")
  (cnvrs:defrule :at "@")
  (cnvrs:defrule :pound "#")
  (cnvrs:defrule :not "~")
  (cnvrs:defrule name-start
    (or (range #\A #\Z) (range #\a #\z)
        (range #.(code-char #x00C0) #.(code-char #x00D6))
        (range #.(code-char #x00D8) #.(code-char #x00F6))
        (range #.(code-char #x00F8) #.(code-char #x02FF))
        (range #.(code-char #x0370) #.(code-char #x037D))
        (range #.(code-char #x037F) #.(code-char #x1FFF))
        (range #.(code-char #x200C) #.(code-char #x200D))
        (range #.(code-char #x2070) #.(code-char #x218F))
        (range #.(code-char #x2C00) #.(code-char #x2FEF))
        (range #.(code-char #x3001) #.(code-char #xD7FF))
        (range #.(code-char #xF900) #.(code-char #xFDCF))
        (range #.(code-char #xFDF0) #.(code-char #xFFFD))))
  (cnvrs:defrule name-char
    (or name-start (range #\0 #\9) #\_
        #.(code-char #x00B7)
        (range #.(code-char #x0300) #.(code-char #x036F))
        (range #.(code-char #x203F) #.(code-char #x2040)))))

(defun prefix-at-p (source position prefix)
  (and (<= (+ position (length prefix)) (length source))
       (string= prefix source :start2 position
                :end2 (+ position (length prefix)))))

(defun scan-quote-end (source start)
  (let* ((triple (prefix-at-p source start "\"\"\""))
         (position (+ start (if triple 3 1)))
         (length (length source)))
    (loop while (< position length) do
      (let ((character (char source position)))
        (incf position)
        (cond ((char= character #\\)
               (when (< position length) (incf position)))
              ((and triple
                    (prefix-at-p source (1- position) "\"\"\""))
               (return-from scan-quote-end
                 (values (+ position 2) t)))
              ((char= character (char source start))
               (unless triple
                 (return-from scan-quote-end (values position t)))))))
    (values position nil)))

(defun scan-action-end (source start)
  (let ((position start) (depth 0) (length (length source)))
    (loop while (< position length) do
      (let ((character (char source position)))
        (cond
          ((prefix-at-p source position "//")
           (incf position 2)
           (loop while (and (< position length)
                            (not (find (char source position)
                                       '(#\Newline #\Return))))
                 do (incf position)))
          ((prefix-at-p source position "/*")
           (incf position 2)
           (loop while (and (< position length)
                            (not (prefix-at-p source position "*/")))
                 do (incf position))
           (when (prefix-at-p source position "*/") (incf position 2)))
          ((find character '(#\' #\" #\`))
           (setf position (scan-quote-end source position)))
          ((char= character #\{)
           (incf depth) (incf position))
          ((char= character #\})
           (decf depth) (incf position)
           (when (zerop depth)
             (return-from scan-action-end position)))
          (t (incf position)))))
    position))

(defun scan-bracket-end (source start)
  (let ((position (1+ start)) (depth 1) (length (length source)))
    (loop while (< position length) do
      (let ((character (char source position)))
        (incf position)
        (cond ((char= character #\\)
               (when (< position length) (incf position)))
              ((char= character #\[) (incf depth))
              ((char= character #\])
               (decf depth)
               (when (zerop depth)
                 (return-from scan-bracket-end position))))))
    position))

(defun lex (source)
  "Tokenize ANTLR4 grammar text with CNVRS lexer rules and LexerAdaptor logic.
  Only actions, brackets, and token-context changes need custom handling."
  (unless (stringp source)
    (error 'type-error :datum source :expected-type 'string))
  (let ((position 0) (length (length source)) (result nil)
        (rule-context nil) (construct nil) (action-header nil)
        (matcher (cnvrs:lexer-matcher *lexer*)))
    (labels ((emit (kind start end &optional (channel :default))
               (push (cnvrs:make-lexeme
                      :kind kind :source source
                      :start start :end end :channel channel)
                     result)))
      (loop while (< position length) do
        (let ((start position) (character (char source position)))
          (cond
            ((and construct (char= character #\}))
             (incf position)
             (emit :rbrace start position)
             (setf rule-context (cdr construct)
                   construct nil))
            ((char= character #\{)
             (setf position (scan-action-end source position))
             (emit :action start position)
             (when action-header
               (setf rule-context
                     (unless (eq action-header :outside) action-header)
                     action-header nil)))
            ((char= character #\[)
             (setf position (scan-bracket-end source position))
             (if (eq rule-context :token_ref)
                 (emit :lexer_char_set start position)
                 (progn
                   (emit :begin_argument start (1+ start))
                   (when (> (- position start) 2)
                     (emit :argument_content (1+ start) (1- position)))
                   (emit :end_argument (1- position) position))))
            (t
             (multiple-value-bind (kind end)
                 (funcall matcher source position :default)
               (unless end
                 (error 'cnvrs:lexical-error :position position
                        :character character))
               (setf position end)
               (when (eq kind :id)
                 (setf kind (if (upper-case-p character)
                                :token_ref :rule_ref)))
               (emit kind start position
                     (case kind
                       ((:line_comment :block_comment :doc_comment) :comment)
                       (:ws :off_channel)
                       (otherwise :default)))
               (cond
                 ((member kind '(:options :tokens :channels))
                  (setf construct (cons kind rule-context)))
                 ((eq kind :at)
                  (setf action-header (or rule-context :outside)))
                 ((eq kind :semi)
                  (unless construct (setf rule-context nil)))
                 ((and (null rule-context) (not action-header)
                       (member kind '(:token_ref :rule_ref)))
                  (setf rule-context kind))))))))
      (coerce (nreverse result) 'vector))))

(defun parse-tree (source &key (rule 'grammar-spec))
  "Parse ANTLR4 grammar SOURCE and return its syntax tree."
  (cnvrs:parse *parser* source :rule rule))
