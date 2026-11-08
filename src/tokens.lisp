(in-package #:cnvrs)

;; PARSE checks compiled lexers before the lexer implementation is loaded.
(defstruct compiled-lexer states mode-starts kinds skips channels
  push-modes pop-modes set-modes metadata cache-backend cache function matcher
  rule-starts modes actions predicates runtime)

(defparameter +end-of-input+ (gensym "END-OF-INPUT-"))

(defparameter +deferred-lexeme-text+ (gensym "DEFERRED-LEXEME-TEXT-"))
(defstruct (lexeme (:constructor %make-lexeme))
  kind stored-text start end (channel :default) source line column)
(defun make-lexeme (&key kind (text nil text-supplied-p) start end
                         (channel :default) source line column)
  "Make a lexeme. SOURCE defers copying its START..END text until requested."
  (%make-lexeme :kind kind
                :stored-text (if (and source (not text-supplied-p))
                                 +deferred-lexeme-text+ text)
                :start start :end end :channel channel :source source :line line :column column))
(defun lexeme-text (lexeme)
  "Return the lexeme text, extracting it from SOURCE when stored lazily."
  (let ((text (lexeme-stored-text lexeme)))
    (if (eq text +deferred-lexeme-text+)
        (subseq (lexeme-source lexeme)
                (lexeme-start lexeme) (lexeme-end lexeme))
        text)))
(defun (setf lexeme-text) (value lexeme)
  (setf (lexeme-stored-text lexeme) value))

(defun token-key (token)
  "Return a lexeme's kind or a plain token value for parser matching."
  (if (lexeme-p token) (lexeme-kind token) token))
(defun token-channel (token)
  "Return a lexeme's channel, or :DEFAULT for a plain token."
  (if (lexeme-p token) (lexeme-channel token) :default))

(defstruct inserted-token expected position)
(defun inserted-token-value (token)
  "Return the token value supplied by a parser recovery insertion."
  (inserted-token-expected token))
