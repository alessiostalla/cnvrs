(load "bench/tsql/prepare.lisp")
(in-package #:tsql-reference/bench)

(defvar *file-runners*)
(defun signature (tokens kinds-p)
  (let ((hash #xcbf29ce484222325))
    (flet ((mix (n) (setf hash (ldb (byte 64 0) (* (logxor hash n) #x100000001b3)))))
      (loop for token across tokens do
        (map nil (lambda (c) (mix (char-code c)))
             (if kinds-p (symbol-name (cnvrs:lexeme-kind token)) (cnvrs:lexeme-text token)))
        (mix #xffffffff)
        (unless kinds-p
          (dolist (n (list (cnvrs:lexeme-start token) (cnvrs:lexeme-end token)
                           (cnvrs:lexeme-line token) (cnvrs:lexeme-column token)
                           (if (eq (cnvrs:lexeme-channel token) :default) 0 1)))
            (mix n)))))
    (format nil "~16,'0X" hash)))

(defmacro file-fixture ()
  ;; Expand exactly the helper/constructor forms used by the file compiler.
  ;; Keeping them in memory avoids changing uninterned-symbol identity or
  ;; introducing reader-label sharing while serializing generated source.
  (multiple-value-bind (recognition recognition-definitions)
      (cnvrs::parser-runner-form *benchmark-parser* nil)
    (multiple-value-bind (tree tree-definitions)
        (cnvrs::parser-runner-form *benchmark-parser* t)
      `(progn ,@recognition-definitions ,@tree-definitions
              (defparameter *file-runners* (list ,recognition ,tree))))))

(let* ((parser *benchmark-parser*)
       (lexer (cnvrs:ensure-compiled (cnvrs:parser-lexer parser)))
       (generic (cnvrs:clone-compiled parser))
       (file-parser (cnvrs:clone-compiled parser))
       (source (merge-pathnames (format nil "cnvrs-tsql-runners-~A.lisp" (get-universal-time))
                                (uiop:temporary-directory)))
       (fasl nil))
  (setf (cnvrs:parser-runner generic) nil (cnvrs:parser-node-runner generic) nil)
  (unwind-protect
       (progn
         ;; Same constructor emitted by DEFParser's file compiler, with the
         ;; full T-SQL helpers as separate top-level forms.
         (with-open-file (s source :direction :output :if-exists :supersede
                                   :external-format :utf-8)
           (write-line "(tsql-reference/bench::file-fixture)" s))
         (multiple-value-bind (output warnings failure) (handler-bind ((sb-ext:compiler-note #'muffle-warning))
               (compile-file source :verbose nil))
           (declare (ignore warnings))
           (assert (not failure))
           (setf fasl output))
         (load fasl :verbose nil)
         (setf (cnvrs:parser-runner file-parser) (first *file-runners*)
               (cnvrs:parser-node-runner file-parser) (second *file-runners*))
         (format t "FASL full T-SQL runners compiled and loaded.~%")
         (dolist (path (sort (directory "bench/tsql/examples/*.sql") #'string< :key #'namestring))
           (let* ((text (uiop:read-file-string path :external-format :utf-8))
                  (tokens (cnvrs:lex lexer text))
                  (input (cnvrs::make-token-input tokens '(:default)))
                  (expected (count :default tokens :key #'cnvrs:lexeme-channel))
                  (reference (cnvrs:parse generic tokens :lexer nil :rule 'tsql-reference/bench/parser::tsql_file)))
             (dolist (compiled (list parser file-parser))
               ;; PARSE can fall back to the interpreter; directly call both
               ;; runners first so that fallback cannot conceal a broken chunk.
               (assert (funcall (cnvrs:parser-runner compiled) compiled input 'tsql-reference/bench/parser::tsql_file t))
               (let ((tree (funcall (cnvrs:parser-node-runner compiled) compiled input 'tsql-reference/bench/parser::tsql_file t)))
                 (assert (and tree (= expected (cnvrs:node-end tree)))))
               (assert (equalp reference (cnvrs:parse compiled tokens :lexer nil :rule 'tsql-reference/bench/parser::tsql_file))))
             (format t "INPUT ~A CHARACTERS ~D TOKENS ~D DEFAULT ~D SIGNATURE ~A KINDS ~A~%"
                     (file-namestring path) (length text) (length tokens) expected
                     (signature tokens nil) (signature tokens t))
             (finish-output)))
         (format t "VALIDATED runtime and FASL runners against interpreted trees for all inputs.~%"))
    (when (probe-file source) (delete-file source))
    (when (and fasl (probe-file fasl)) (delete-file fasl))))
