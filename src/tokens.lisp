(in-package #:cnvrs)

(defparameter +end-of-input+ (gensym "END-OF-INPUT-"))

(defparameter +deferred-lexeme-text+ (gensym "DEFERRED-LEXEME-TEXT-"))
(defstruct (lexeme (:constructor %make-lexeme))
  kind stored-text start end (channel :default) source)
(defun make-lexeme (&key kind (text nil text-supplied-p) start end
                         (channel :default) source)
  "Make a lexeme. SOURCE defers copying its START..END text until requested."
  (%make-lexeme :kind kind
                :stored-text (if (and source (not text-supplied-p))
                                 +deferred-lexeme-text+ text)
                :start start :end end :channel channel :source source))
(defun lexeme-text (lexeme)
  (let ((text (lexeme-stored-text lexeme)))
    (if (eq text +deferred-lexeme-text+)
        (subseq (lexeme-source lexeme)
                (lexeme-start lexeme) (lexeme-end lexeme))
        text)))
(defun (setf lexeme-text) (value lexeme)
  (setf (lexeme-stored-text lexeme) value))

(defun token-key (token)
  (if (lexeme-p token) (lexeme-kind token) token))
(defun token-channel (token)
  (if (lexeme-p token) (lexeme-channel token) :default))

(defstruct inserted-token expected position)
(defun inserted-token-value (token)
  (inserted-token-expected token))
