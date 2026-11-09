;;; Pinned ANTLR 4.13.2 Unicode data; BSD-3-Clause, see runtime/LICENSE.txt.
(in-package #:cnvrs)
(defparameter *unicode-properties* (make-hash-table :test 'equal))
(defparameter *unicode-aliases* (make-hash-table :test 'equal))
(defparameter *character-cases* (make-hash-table :test 'eql))
;; Keep the large generated tables as data rather than compiler forms. Grammars
;; freeze the final expanded intervals in their own FASLs and need no Java runtime.
(with-open-file (input (asdf:system-relative-pathname :cnvrs "src/unicode-data.sexp"))
  (let* ((*read-eval* nil) (data (read input)))
    (loop for key in '(:properties :aliases :cases)
          for table in (list *unicode-properties* *unicode-aliases* *character-cases*) do
      (dolist (entry (getf data key))
        (setf (gethash (first entry) table) (second entry))))))
