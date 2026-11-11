(in-package #:cnvrs/tests/file)

(cnvrs:defparser *java-class* (:default-rule class)
  (cnvrs:use *expression-rules*)
  (class (cnvrs:and :class expression :semi)))

(cnvrs:defparser *word-lexer* (:kind :lexer)
  (:word (cnvrs:+ (cnvrs:range #\a #\z))))

(cnvrs:defparser *lexer-rules-only* (:kind :lexer :rules-only t)
  (:word (cnvrs:+ (cnvrs:range #\a #\z))))

(cnvrs:defparser *quoted-lexer* (:kind :lexer)
  (:quoted (cnvrs:and #\" (cnvrs:*? (cnvrs:any)) #\")))

(cnvrs:defparser *combined-file* (:kind :combined)
  (start :word)
  (:word (cnvrs:+ (cnvrs:range #\a #\z))))

(defun accept-input (input position)
  (declare (ignore input position))
  t)

(cnvrs:defparser *semantic-file*
  (start (cnvrs:and (cnvrs:predicate accept-input) :id)))

(cnvrs:defparser *semantic-lexer* (:kind :lexer)
  (:word (cnvrs:and (cnvrs:predicate accept-input)
                    (cnvrs:+ (cnvrs:range #\a #\z)))))
