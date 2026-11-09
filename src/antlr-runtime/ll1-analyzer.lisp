;;; Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
;;; LL1Analyzer.getDecisionLookahead / _LOOK and AnalysisPipeline.disjoint,
;;; ANTLR Java 4.13.2. See LICENSE-ANTLR.txt.
(in-package #:cnvrs/antlr-runtime)

(defun decision-lookahead (atn state-number)
  "Return ordered SLL(1) token sets, NIL for empty/predicate-blocked alternatives.
As in Java, outermost rule stops follow the ATN's global follow edges; actual
nested rule returns use their exact invocation-local context. Predicates are opaque."
  (let* ((states (atn-states atn)) (state (aref states state-number))
         (edges (atn-state-transitions state)) (result (make-array (length edges))))
    (loop for edge in edges for alt from 0 do
      (let ((busy (make-hash-table :test 'equal)) (look (make-hash-table :test 'eql)))
        (labels ((walk (number context called)
                   (let* ((state (aref states number)) (key (cons number context)))
                     (when (gethash key busy) (return-from walk))
                     (setf (gethash key busy) t)
                     (when (and (eq (atn-state-kind state) :rule-stop) context)
                       ;; Temporarily clear this rule's recursion guard while returning.
                       (walk (car context) (cdr context)
                             (logandc2 called (ash 1 (atn-state-rule state))))
                       (return-from walk))
                     (dolist (transition (atn-state-transitions state))
                       (let ((target (atn-transition-target transition)) (label (atn-transition-label transition)))
                         (case (atn-transition-kind transition)
                           (:rule
                            (let ((bit (ash 1 (atn-state-rule (aref states target)))))
                              (when (zerop (logand called bit))
                                (walk target (cons (atn-transition-follow transition) context) (logior called bit)))))
                           ((:predicate :precedence) (setf (gethash 0 look) t))
                           ((:epsilon :action) (walk target context called))
                           (:atom (setf (gethash label look) t))
                           (:set (dolist (token label) (setf (gethash token look) t)))
                           (:range (loop for token from (first label) to (second label) do (setf (gethash token look) t)))
                           ((:wildcard :not-set)
                            (loop for token from 1 to (atn-max-token-type atn)
                                  unless (and (eq (atn-transition-kind transition) :not-set) (member token label))
                                    do (setf (gethash token look) t)))))))))
          (walk (atn-transition-target edge) nil 0))
        (setf (aref result alt)
              (unless (gethash 0 look)
                (sort (loop for token being the hash-keys of look collect token) #'<)))))
    result))

(defun lookahead-disjoint-p (alternatives)
  "Java AnalysisPipeline.disjoint: every alternative must have a disjoint set."
  (when alternatives
    (let ((combined (make-hash-table :test 'eql)))
      (loop for look across alternatives always
        (and look (loop for token in look never (prog1 (gethash token combined)
                                                 (setf (gethash token combined) t))))))))
