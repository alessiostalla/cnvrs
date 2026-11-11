(in-package #:cnvrs)

;; The parser and lexer use the same graph primitives. Their state payloads
;; and transition policies remain separate.
(defstruct graph-state (id 0 :type fixnum) (edges nil :type list))
(defstruct transition kind (target 0 :type fixnum) value)

(defun graph-new-state (states constructor)
  (declare (type vector states))
  (let ((id (length states)))
    (declare (type fixnum id))
    (vector-push-extend (funcall constructor id) states)
    id))

(defun graph-add-edge (states from kind target value &key (append-p nil))
  (declare (type vector states) (type fixnum from target))
  (let* ((state (aref states from))
         (edge (make-transition :kind kind :target target :value value)))
    (if append-p
        (setf (graph-state-edges state)
              (nconc (graph-state-edges state) (list edge)))
        (push edge (graph-state-edges state)))
    edge))
