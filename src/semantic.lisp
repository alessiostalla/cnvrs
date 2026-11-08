(in-package #:cnvrs)

(defun semantic-call (callback input position)
  (funcall (if (symbolp callback) (symbol-function callback) callback)
           input position))
