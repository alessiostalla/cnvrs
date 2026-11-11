(in-package #:cnvrs)

(declaim (optimize (speed 3) (safety 1) (debug 0) (space 0) (compilation-speed 1)))

(defstruct node rule children start end label)
(defgeneric make-parse-node (builder rule children start end)
  (:documentation "Build a parse node for RULE and CHILDREN spanning token offsets START through END."))
(defgeneric parse-node-components (builder value)
  (:documentation "Return VALUE's rule, children, start, end, and a true presence flag for BUILDER; return a false flag for other values."))
(defmethod make-parse-node ((builder (eql :node)) rule children start end)
  (make-node :rule rule :children children :start start :end end))
(defmethod parse-node-components ((builder (eql :node)) value)
  (if (node-p value)
      (values (node-rule value) (node-children value)
              (node-start value) (node-end value) t)
      (values nil nil nil nil nil)))
(defgeneric parse-build-tree-p (builder)
  (:documentation "Return whether parsing with BUILDER should construct a parse tree."))
(defmethod parse-build-tree-p (builder)
  (declare (ignore builder))
  t)
(defmethod parse-build-tree-p ((builder (eql :none)))
  nil)
(defgeneric parse-rule-enter (builder rule position)
  (:documentation "Notify BUILDER that RULE begins at token offset POSITION."))
(defgeneric parse-token-consumed (builder token start end)
  (:documentation "Notify BUILDER that TOKEN was consumed between token offsets START and END."))
(defgeneric parse-rule-exit (builder rule start end)
  (:documentation "Notify BUILDER that RULE ended, spanning token offsets START through END."))
(defmethod parse-rule-enter (builder rule position)
  (declare (ignore builder rule position))
  nil)
(defmethod parse-token-consumed (builder token start end)
  (declare (ignore builder token start end))
  nil)
(defmethod parse-rule-exit (builder rule start end)
  (declare (ignore builder rule start end))
  nil)
(defun parse-node-children-for (builder node)
  (nth-value 1 (parse-node-components builder node)))
(defun parse-node-start-for (builder node)
  (nth-value 2 (parse-node-components builder node)))
(defun parse-node-end-for (builder node)
  (nth-value 3 (parse-node-components builder node)))

(defun make-labeled-parse-node (builder rule children start end label)
  (let ((node (make-parse-node builder rule children start end)))
    (when (node-p node)
      (setf (node-label node) label))
    node))

(defun make-visible-parse-node (builder rule children start end &optional label)
  (let ((alternative (and (= (length children) 1)
                          (first children))))
    (multiple-value-bind (alternative-rule alternative-children)
        (parse-node-components builder alternative)
      (if (eq alternative-rule :alternative-label)
          (make-labeled-parse-node builder rule alternative-children start end
                                   (and (node-p alternative)
                                        (node-label alternative)))
          (make-labeled-parse-node builder rule children start end label)))))

(defun normalize-rewritten-node (node rewrites builder)
  (multiple-value-bind (rule original-children start end present)
      (parse-node-components builder node)
    (if (not present)
        node
        (let* ((children (mapcar (lambda (child)
                                   (normalize-rewritten-node child rewrites
                                                             builder))
                                 original-children))
               (rewrite (gethash rule rewrites)))
          (case (first rewrite)
            (:wrapper (first children))
            (:element-label
             (make-labeled-parse-node builder :label children start end
                                      (second rewrite)))
            (:alternative-label
             (make-labeled-parse-node builder :alternative-label children
                                      start end (second rewrite)))
            (:primary (make-visible-parse-node builder (second rewrite)
                                               children start end))
            (:level
             (reduce (lambda (left suffix)
                       (let* ((suffix-rewrite
                                (gethash (nth-value 0
                                           (parse-node-components builder suffix))
                                         rewrites))
                              (left-child
                                (if (fourth suffix-rewrite)
                                    (make-labeled-parse-node
                                     builder :label (list left)
                                     (parse-node-start-for builder left)
                                     (parse-node-end-for builder left)
                                     (fourth suffix-rewrite))
                                    left)))
                         (make-visible-parse-node
                          builder (second rewrite)
                          (cons left-child
                                (parse-node-children-for builder suffix))
                          (parse-node-start-for builder left)
                          (parse-node-end-for builder suffix)
                          (third suffix-rewrite))))
                     (rest children) :initial-value (first children)))
            (otherwise (make-visible-parse-node
                        builder rule children start end
                        (and (node-p node) (node-label node)))))))))

