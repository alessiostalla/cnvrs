(defpackage #:cnvrs/tests/topology/native
  (:use #:cl)
  (:import-from #:cnvrs #:? #:label #:alt-label #:token #:not-token #:right #:any #:eof)
  (:export #:*parser* #:*eof-set*))
(in-package #:cnvrs/tests/topology/native)

;; Native forms retain their established low-to-high operator ordering.
(cnvrs:defparser *parser* (:default-rule s)
  (s (and (* piece) (eof)))
  (piece (or (and :ID (+ (and :COMMA :ID)) :SEMI)
             (and (? (or :A :B)) :ID :SEMI)
             (and (+ (or (and :A :B) (and :A :C))) :SEMI)
             (and expr :SEMI)
             (and (not-token (:A :B)) :ID :SEMI)
             (and (any) :SEMI)))
  (expr (or (alt-label add (and (label left expr) :PLUS (label right expr)))
            (alt-label power (right (and (label left expr) :POWER (label right expr))))
            (alt-label multiply (and (label left expr) :STAR (label right expr)))
            (alt-label negative (and :MINUS expr))
            (alt-label group (and :OPEN expr :CLOSE))
            (alt-label name (label value :ID)))))

;; EOF may be a member of the set produced by token-alternative reduction.
(cnvrs:defparser *eof-set* (:default-rule entry)
  (entry (or :A (eof))))
