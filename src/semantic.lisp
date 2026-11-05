(in-package #:cnvrs)

;; A semantic grammar is matched without DFA caching: a predicate may change
;; between calls even when the input and position are identical. Actions are
;; recorded on candidate paths and run once, after the winning path is known.
(defstruct semantic-result end children actions)
(defstruct semantic-node rule children start end)

(defun semantic-call (callback input position)
  (funcall (if (symbolp callback) (symbol-function callback) callback)
           input position))

(defun semantic-join (left right)
  (make-semantic-result
   :end (semantic-result-end right)
   :children (append (semantic-result-children left)
                     (semantic-result-children right))
   :actions (append (semantic-result-actions left)
                    (semantic-result-actions right))))

(defun semantic-match (grammar expression input position)
  (typecase expression
    (parser-predicate-expr
     (when (semantic-call (parser-expr-callback expression) input position)
       (list (make-semantic-result :end position))))
    (parser-action-expr
     (list (make-semantic-result
            :end position
            :actions (list (cons (parser-expr-callback expression) position)))))
    (parser-token-expr
     (when (and (< position (length input))
                (equal (token-key (aref input position))
                       (parser-expr-value expression)))
       (list (make-semantic-result :end (1+ position)
                                   :children (list (aref input position))))))
    (parser-not-token-expr
     (when (and (< position (length input))
                (not (member (token-key (aref input position))
                             (parser-expr-excluded expression) :test #'equal)))
       (list (make-semantic-result :end (1+ position)
                                   :children (list (aref input position))))))
    (parser-reference-expr
     (let* ((name (parser-expr-name expression))
            (body (gethash name (parser-semantic-rules grammar))))
       (loop for result in (semantic-match grammar body input position)
             collect (make-semantic-result
                      :end (semantic-result-end result)
                      :children (list (make-semantic-node
                                       :rule name
                                       :children (semantic-result-children result)
                                       :start position
                                       :end (semantic-result-end result)))
                      :actions (semantic-result-actions result)))))
    (parser-choice-expr
     (loop for part in (parser-expr-parts expression)
           append (semantic-match grammar part input position)))
    (parser-sequence-expr
     (let ((paths (list (make-semantic-result :end position))))
       (dolist (part (parser-expr-parts expression) paths)
         (setf paths
               (loop for path in paths
                     append (loop for next in (semantic-match grammar part input
                                                              (semantic-result-end path))
                                  collect (semantic-join path next)))))))
    (parser-optional-expr
     (append (semantic-match grammar (parser-expr-body expression)
                             input position)
             (list (make-semantic-result :end position))))
    (parser-star-expr
     (semantic-repeat grammar (parser-expr-body expression) input position))
    (parser-plus-expr
     (loop for first in (semantic-match grammar (parser-expr-body expression)
                                        input position)
           append (loop for rest in (semantic-repeat
                                     grammar (parser-expr-body expression)
                                     input (semantic-result-end first))
                        collect (semantic-join first rest))))
    (t (grammar-fail "Unsupported semantic expression ~S" expression))))

(defun semantic-repeat (grammar body input position)
  (append
   (loop for first in (semantic-match grammar body input position)
         when (> (semantic-result-end first) position)
           append (loop for rest in (semantic-repeat
                                     grammar body input
                                     (semantic-result-end first))
                        collect (semantic-join first rest)))
   (list (make-semantic-result :end position))))

(defun semantic-materialize (value builder)
  (if (semantic-node-p value)
      (make-parse-node builder (semantic-node-rule value)
                       (mapcar (lambda (child)
                                 (semantic-materialize child builder))
                               (semantic-node-children value))
                       (semantic-node-start value)
                       (semantic-node-end value))
      value))

(defun parse-semantic (grammar input start require-eof tree-builder)
  (let* ((results (semantic-match grammar
                                  (gethash start (parser-semantic-rules grammar))
                                  input 0))
         (winner (find-if (lambda (result)
                            (or (not require-eof)
                                (= (semantic-result-end result)
                                   (length input))))
                          results)))
    (unless winner
      (let ((position (if results
                          (reduce #'max results :key #'semantic-result-end)
                          0)))
        (error 'no-viable-alternative
               :position position
               :token (if (< position (length input))
                          (aref input position) +end-of-input+)
               :expected nil :rule start)))
    (dolist (event (semantic-result-actions winner))
      (semantic-call (car event) input (cdr event)))
    (unless (eq tree-builder :none)
      (let ((node (semantic-materialize
                   (make-semantic-node
                    :rule start :children (semantic-result-children winner)
                    :start 0 :end (semantic-result-end winner))
                   tree-builder)))
        (if (plusp (hash-table-count (parser-rewrites grammar)))
            (normalize-rewritten-node node (parser-rewrites grammar)
                                      tree-builder)
            node)))))
