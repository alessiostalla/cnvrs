;;; Pinned ANTLR 4.13.2 Unicode data; BSD-3-Clause, see antlr-runtime/LICENSE-ANTLR.txt.
(in-package #:cnvrs)
(defparameter *antlr-unicode-properties* (make-hash-table :test 'equal))
(defparameter *antlr-unicode-aliases* (make-hash-table :test 'equal))
(defparameter *antlr-character-cases* (make-hash-table :test 'eql))
;; Keep the large generated tables as data rather than compiler forms. Grammars
;; freeze the final expanded intervals in their own FASLs and need no Java runtime.
(with-open-file (input (asdf:system-relative-pathname :cnvrs "src/antlr-unicode-data.sexp"))
  (let* ((*read-eval* nil) (data (read input)))
    (loop for key in '(:properties :aliases :cases)
          for table in (list *antlr-unicode-properties* *antlr-unicode-aliases* *antlr-character-cases*) do
      (dolist (entry (getf data key))
        (setf (gethash (first entry) table) (second entry))))))
