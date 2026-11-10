(defpackage #:cnvrs/tests/wide
  (:use #:cl)
  (:export #:*parser* #:entry #:long-rule #:tail))
(in-package #:cnvrs/tests/wide)

;; A DEFPARSER evaluated while a file compiles has no lexical macro
;; environment. Compiler-boundary maintenance must leave that case alone.
(eval-when (:compile-toplevel)
  (eval '(cnvrs:defparser *compile-time-parser* (entry :item))))

;; Exercise COMPILE-FILE with both a wide token test and a large rule. This
;; deliberately uses enough states to cross several independent chunks, with
;; a labeled group spanning those boundaries.
(macrolet ((fixture ()
             `(cnvrs:defparser *parser* (:default-rule entry)
                (entry (and (cnvrs:? wide) long-rule (cnvrs:eof)))
                (wide (or ,@(loop for i below 512
                                 collect (intern (format nil "WIDE-~D" i) :keyword))))
                (long-rule
                 (cnvrs:label tail
                   (and ,@(loop repeat 160 collect :item))))
                ;; A large dispatch vector must not put all helper functions
                ;; back into one compiler component in its initializer.
                ,@(loop for i below 300 collect
                    (list (intern (format nil "STUB-~D" i) :cnvrs/tests/wide) :item)))))
  (fixture))
