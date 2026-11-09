;;; Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
;;; LL1Analyzer.getDecisionLookahead / _LOOK and AnalysisPipeline.disjoint,
;;; ANTLR Java 4.13.2. See LICENSE.txt.
(in-package #:cnvrs/runtime)

(defun state-lookahead (atn state-number &key context see-through-predicates
                                             follow-global-stops)
  "Return token types reachable before consumption, using exact rule returns.
Type zero marks an opaque predicate. Recovery sees through predicates and stops
at the outermost return; decision analysis follows global rule-stop edges."
  (let ((states (atn-states atn))
        (busy (make-hash-table :test 'equal))
        (look (make-hash-table :test 'eql)))
    (labels ((walk (number context called)
               (let* ((state (aref states number)) (key (cons number context)))
                 (when (gethash key busy) (return-from walk))
                 (setf (gethash key busy) t)
                 (when (eq (atn-state-kind state) :rule-stop)
                   (cond (context
                          (walk (car context) (cdr context)
                                (logandc2 called (ash 1 (atn-state-rule state))))
                          (return-from walk))
                         ((not follow-global-stops) (return-from walk))))
                 (dolist (transition (atn-state-transitions state))
                   (let ((target (atn-transition-target transition))
                         (label (atn-transition-label transition)))
                     (case (atn-transition-kind transition)
                       (:rule
                        (let ((bit (ash 1 (atn-state-rule (aref states target)))))
                          (when (zerop (logand called bit))
                            (walk target (cons (atn-transition-follow transition) context)
                                  (logior called bit)))))
                       ((:predicate :precedence)
                        (if see-through-predicates (walk target context called)
                            (setf (gethash 0 look) t)))
                       ((:epsilon :action) (walk target context called))
                       (:atom (setf (gethash label look) t))
                       (:set (dolist (token label) (setf (gethash token look) t)))
                       (:range (loop for token from (first label) to (second label)
                                     do (setf (gethash token look) t)))
                       ((:wildcard :not-set)
                        (loop for token from 1 to (atn-max-token-type atn)
                              unless (and (eq (atn-transition-kind transition) :not-set)
                                          (member token label))
                                do (setf (gethash token look) t)))))))))
      (walk state-number context 0))
    (sort (loop for token being the hash-keys of look collect token) #'<)))

(defun decision-lookahead (atn state-number)
  "Return ordered SLL(1) token sets, NIL for empty/predicate-blocked alternatives."
  (map 'vector
       (lambda (edge)
         (let ((look (state-lookahead atn (atn-transition-target edge)
                                     :follow-global-stops t)))
           (unless (member 0 look) look)))
       (atn-state-transitions (aref (atn-states atn) state-number))))

(defun lookahead-disjoint-p (alternatives)
  "Java AnalysisPipeline.disjoint: every alternative must have a disjoint set."
  (when alternatives
    (let ((combined (make-hash-table :test 'eql)))
      (loop for look across alternatives always
        (and look (loop for token in look never (prog1 (gethash token combined)
                                                 (setf (gethash token combined) t))))))))
