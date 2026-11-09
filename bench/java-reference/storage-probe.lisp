;;; Diagnostic only: bucket traffic and parent-set sizes in one trained parse.
(require :asdf)
(let ((*package* *package*))
  (with-open-file (input "bench/java-reference/warm-profile.lisp")
    (loop for form = (read input nil nil) while form
          until (and (consp form) (eq (car form) 'dotimes)) do (eval form))))
(defun bucket-size (bucket)
  (if (listp bucket) (length bucket)
      (loop for entry = bucket then (funcall (find-symbol "MERGE-CACHE-ENTRY-NEXT" :cnvrs/runtime) entry)
            while entry count t)))
(dotimes (i 5) (run))
(let ((parents (make-hash-table)) (buckets (make-hash-table))
      (hits 0) (gets 0) (puts 0) (saved nil))
  (flet ((wrap (name wrapper)
           (let ((old (symbol-function name)))
             (push (cons name old) saved)
             (setf (symbol-function name) (funcall wrapper old)))))
    (unwind-protect
         (progn
           (wrap 'cnvrs/runtime::combine-common-parents
                 (lambda (old)
                   (lambda (array)
                     (incf (gethash (length array) parents 0))
                     (funcall old array))))
           (wrap 'cnvrs/runtime::merge-cache-get
                 (lambda (old)
                   (lambda (cache a b wildcard)
                     (incf gets)
                     (incf (gethash (if cache
                                       (bucket-size (gethash (logxor (cnvrs/runtime:context-hash a)
                                                               (cnvrs/runtime:context-hash b)) cache)) 0)
                                   buckets 0))
                     (let ((answer (funcall old cache a b wildcard)))
                       (when answer (incf hits)) answer))))
           (wrap 'cnvrs/runtime::merge-cache-put
                 (lambda (old)
                   (lambda (&rest args) (incf puts) (apply old args))))
           (run))
      (dolist (entry saved) (setf (symbol-function (car entry)) (cdr entry)))))
  (format t "MERGE-GETS ~D HITS ~D PUTS ~D~%" gets hits puts)
  (dolist (spec (list (cons "PARENT-SIZE" parents) (cons "BUCKET-SIZE" buckets)))
    (loop for size in (sort (loop for key being the hash-keys of (cdr spec) collect key) #'<)
          do (format t "~A ~D COUNT ~D~%" (car spec) size (gethash size (cdr spec))))))
(cache-summary *java8-parser*)
