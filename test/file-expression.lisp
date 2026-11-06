(defpackage #:cnvrs/tests/file
  (:use #:cl))

(in-package #:cnvrs/tests/file)

(cnvrs:defparser *expression-rules* (:rules-only t)
  (expression :id))
