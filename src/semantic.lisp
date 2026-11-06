(in-package #:cnvrs)

;; A semantic grammar is matched without DFA caching: a predicate may change
;; between calls even when the input and position are identical. Actions are
;; recorded on candidate paths and run once, after the winning path is known.
;; END is a physical position in the original vector; LOGICAL-END counts only
;; tokens on selected channels, as callback and tree positions do.
(defstruct semantic-result end logical-end children actions)
(defstruct semantic-node rule children start end)

(defun semantic-call (callback input position)
  (funcall (if (symbolp callback) (symbol-function callback) callback)
           input position))

(defun semantic-join (left right)
  (make-semantic-result
   :end (semantic-result-end right)
   :logical-end (semantic-result-logical-end right)
   :children (append (semantic-result-children left)
                     (semantic-result-children right))
   :actions (append (semantic-result-actions left)
                    (semantic-result-actions right))))

(defun semantic-match (grammar expression input position logical-position)
  (typecase expression
    (parser-predicate-expr
     (when (semantic-call (parser-expr-callback expression)
                          input logical-position)
       (list (make-semantic-result :end position
                                   :logical-end logical-position))))
    (parser-action-expr
     (list (make-semantic-result
            :end position :logical-end logical-position
            :actions (list (cons (parser-expr-callback expression)
                                 logical-position)))))
    (parser-token-expr
     (when (and (< position (input-size input))
                (equal (token-key (input-token input position))
                       (parser-expr-value expression)))
       (list (make-semantic-result
              :end (input-next-position input position)
              :logical-end (1+ logical-position)
              :children (list (input-token input position))))))
    (parser-not-token-expr
     (when (and (< position (input-size input))
                (not (member (token-key (input-token input position))
                             (parser-expr-excluded expression) :test #'equal)))
       (list (make-semantic-result
              :end (input-next-position input position)
              :logical-end (1+ logical-position)
              :children (list (input-token input position))))))
    (parser-reference-expr
     (let* ((name (parser-expr-name expression))
            (body (gethash name (parser-semantic-rules grammar))))
       (loop for result in (semantic-match grammar body input position
                                           logical-position)
             collect (make-semantic-result
                      :end (semantic-result-end result)
                      :logical-end (semantic-result-logical-end result)
                      :children (list (make-semantic-node
                                       :rule name
                                       :children (semantic-result-children result)
                                       :start logical-position
                                       :end (semantic-result-logical-end result)))
                      :actions (semantic-result-actions result)))))
    (parser-choice-expr
     (loop for part in (parser-expr-parts expression)
           append (semantic-match grammar part input position logical-position)))
    (parser-sequence-expr
     (let ((paths (list (make-semantic-result
                         :end position :logical-end logical-position))))
       (dolist (part (parser-expr-parts expression) paths)
         (setf paths
               (loop for path in paths
                     append (loop for next in
                                  (semantic-match grammar part input
                                                  (semantic-result-end path)
                                                  (semantic-result-logical-end
                                                   path))
                                  collect (semantic-join path next)))))))
    (parser-optional-expr
     (append (semantic-match grammar (parser-expr-body expression)
                             input position logical-position)
             (list (make-semantic-result
                    :end position :logical-end logical-position))))
    (parser-star-expr
     (semantic-repeat grammar (parser-expr-body expression)
                      input position logical-position))
    (parser-plus-expr
     (loop for first in (semantic-match grammar (parser-expr-body expression)
                                        input position logical-position)
           append (loop for rest in (semantic-repeat
                                     grammar (parser-expr-body expression)
                                     input (semantic-result-end first)
                                     (semantic-result-logical-end first))
                        collect (semantic-join first rest))))
    (t (grammar-fail "Unsupported semantic expression ~S" expression))))

(defun semantic-repeat (grammar body input position logical-position)
  (append
   (loop for first in (semantic-match grammar body input position
                                      logical-position)
         when (> (semantic-result-end first) position)
           append (loop for rest in (semantic-repeat
                                     grammar body input
                                     (semantic-result-end first)
                                     (semantic-result-logical-end first))
                        collect (semantic-join first rest)))
   (list (make-semantic-result
          :end position :logical-end logical-position))))

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
                                  input (input-start-position input) 0))
         (winner (find-if (lambda (result)
                            (or (not require-eof)
                                (= (semantic-result-end result)
                                   (input-size input))))
                          results)))
    (unless winner
      (let* ((best (when results
                     (reduce (lambda (left right)
                               (if (>= (semantic-result-end left)
                                       (semantic-result-end right))
                                   left right))
                             results)))
             (position (if best (semantic-result-end best)
                           (input-start-position input)))
             (logical-position (if best (semantic-result-logical-end best) 0)))
        (error 'no-viable-alternative
               :position logical-position
               :token (if (< position (input-size input))
                          (input-token input position) +end-of-input+)
               :expected nil :rule start)))
    (dolist (event (semantic-result-actions winner))
      (semantic-call (car event) input (cdr event)))
    (unless (eq tree-builder :none)
      (let ((node (semantic-materialize
                   (make-semantic-node
                    :rule start :children (semantic-result-children winner)
                    :start 0 :end (semantic-result-logical-end winner))
                   tree-builder)))
        (if (plusp (hash-table-count (parser-rewrites grammar)))
            (normalize-rewritten-node node (parser-rewrites grammar)
                                      tree-builder)
            node)))))
