(defpackage #:cnvrs/tests/token-category
  (:use #:cl))

(in-package #:cnvrs/tests/token-category)

;; These declarations exist only while compiling this file. Loading the prepared
;; parsers must not consult the registry, including when callbacks are present.
(eval-when (:compile-toplevel)
  (cnvrs:def-token-category file-soft-keyword :yield :await))

(cnvrs:defparser *file-parser*
  (identifier (or :identifier (cnvrs:token-category file-soft-keyword))))

(defun accept-input (input position)
  (declare (ignore input position))
  t)

(cnvrs:defparser *file-semantic-parser*
  (identifier (and (cnvrs:predicate accept-input)
                   (cnvrs:token-category file-soft-keyword))))

(eval-when (:compile-toplevel)
  (cnvrs::register-token-category 'file-soft-keyword nil)
  (remprop 'file-soft-keyword 'cnvrs:token-category-members))

(defmacro signals (condition form)
  `(handler-case (progn ,form nil)
     (,condition () t)))

(defun run-tests ()
  (flet ((accepts (parser tokens)
           (cnvrs:node-p (cnvrs:parse parser tokens))))
    (assert (not (nth-value 1 (cnvrs:token-category-members 'file-soft-keyword))))
    (assert (accepts *file-parser* '(:await)))
    (assert (accepts *file-semantic-parser* '(:yield)))
    (cnvrs:def-token-category soft-keyword :yield :await :yield)
    (cnvrs:def-token-category contextual :await :async)
    (assert (equal '(:yield :await) (cnvrs:token-category-members 'soft-keyword)))
    (assert (equal '(contextual soft-keyword) (cnvrs:token-categories :await)))
    ;; Accessors must not expose the registry's list spines.
    (let ((members (cnvrs:token-category-members 'soft-keyword)))
      (setf (first members) :changed))
    (assert (equal '(:yield :await) (cnvrs:token-category-members 'soft-keyword)))
    (dolist (compile-runners '(t nil))
      (let ((parser (cnvrs:compile-grammar
                     '((identifier (or :identifier (cnvrs:token-category soft-keyword))))
                     :compile-runners compile-runners)))
        (assert
         (equalp (cnvrs::frozen-states (cnvrs:parser-states parser) t)
                 (cnvrs::frozen-states
                  (cnvrs:parser-states
                   (cnvrs:compile-grammar
                    '((identifier (or :identifier (cnvrs:token :yield) (cnvrs:token :await))))
                    :compile-runners compile-runners)) t)))
        (dolist (kind '(:identifier :yield :await))
          (assert (accepts parser (list kind)))
          (assert (null (cnvrs:parse parser (list (cnvrs:make-lexeme :kind kind))
                                     :tree-builder :none))))
        (assert (signals cnvrs:parse-error (cnvrs:parse parser '(:async))))))
    ;; Shared prefixes and overlapping classes participate in ordinary prediction.
    (let ((parser (cnvrs:compile-grammar
                   '((start (and item :end))
                     (item (or (and (cnvrs:token-category soft-keyword) :end)
                               (cnvrs:token-category contextual)))))))
      (assert (accepts parser '(:await :end)))
      (assert (accepts parser '(:yield :end :end))))
    ;; A category symbol that is also the recursive rule name remains literal data.
    (cnvrs:def-token-category expression :plus)
    (let ((parser (cnvrs:compile-grammar
                   '((expression (or :identifier
                                     (and expression (cnvrs:token-category expression)
                                          expression)))))))
      (assert (accepts parser '(:identifier :plus :identifier))))
    (let ((parser (cnvrs:compile-grammar
                   '((identifier (cnvrs:token-category soft-keyword))))))
      (cnvrs:def-token-category soft-keyword :async)
      (assert (accepts parser '(:yield)))
      (assert (not (member 'soft-keyword (cnvrs:token-categories :await))))
      (assert (member 'contextual (cnvrs:token-categories :await)))
      (assert (accepts (cnvrs:compile-grammar
                        '((identifier (cnvrs:token-category soft-keyword))))
                      '(:async)))))
  (dolist (form '((cnvrs:token-category unknown)
                  (cnvrs:token-category)
                  (cnvrs:token-category soft-keyword extra)
                  (cnvrs:token-category (soft-keyword))))
    (assert (signals cnvrs:grammar-error
              (cnvrs:compile-grammar `((identifier ,form))))))
  (cnvrs:def-token-category empty-category)
  (assert (nth-value 1 (cnvrs:token-category-members 'empty-category)))
  (assert (signals cnvrs:grammar-error
            (cnvrs:compile-grammar '((identifier (cnvrs:token-category empty-category))))))
  (assert (signals cnvrs:grammar-error
            (cnvrs::register-token-category 'invalid '("not a symbol")))))
