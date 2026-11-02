;; A grammar-specific ATN simulator. This is a benchmark experiment, not a
;; parser API: compile the fixed graph once while keeping return stacks and
;; tokens as runtime inputs.
(in-package #:cl-user)

(defun compile-iri-atn-simulator (grammar)
  (let ((closure-clauses nil)
        (step-clauses nil))
    (loop for state across (cnvrs:parser-states grammar)
          for id from 0 do
      (let ((stop (cnvrs:state-stop-rule state))
            (token-edges nil)
            (closure-forms nil))
        (unless stop
          (dolist (edge (cnvrs:state-edges state))
            (case (cnvrs:transition-kind edge)
              (:epsilon
               (push `(push (cnvrs::make-configuration
                             :state ,(cnvrs:transition-target edge)
                             :stack stack :alternative alternative)
                            pending)
                     closure-forms))
              (:call
               (push `(push (cnvrs::make-configuration
                             :state ,(gethash (cnvrs:transition-value edge)
                                              (cnvrs:parser-starts grammar))
                             :stack (cons ,(cnvrs:transition-target edge) stack)
                             :alternative alternative)
                            pending)
                     closure-forms))
              (:token (push edge token-edges)))))
        (push `(,id
                ,(if stop
                     `(if stack
                          (push (cnvrs::make-configuration
                                 :state (first stack) :stack (rest stack)
                                 :alternative alternative)
                                pending)
                          (push configuration result))
                     `(progn
                        ,@(nreverse closure-forms)
                        ,@(when token-edges '((push configuration result))))))
              closure-clauses)
        (when token-edges
          (push `(,id
                  ,@(loop for edge in (nreverse token-edges)
                          collect
                          `(when (equal key ',(cnvrs:transition-value edge))
                             (push (cnvrs::make-configuration
                                    :state ,(cnvrs:transition-target edge)
                                    :stack (cnvrs::configuration-stack configuration)
                                    :alternative
                                    (cnvrs::configuration-alternative configuration))
                                   next))))
                step-clauses))))
    (let* ((form
             `(lambda ()
                (labels
                    ((compiled-closure (initial)
                       (let ((pending (copy-list initial))
                             (seen (make-hash-table :test 'equal))
                             (result nil))
                         (loop while pending do
                           (let* ((configuration (pop pending))
                                  (key (cnvrs::configuration-key configuration)))
                             (unless (gethash key seen)
                               (setf (gethash key seen) t)
                               (let ((stack (cnvrs::configuration-stack configuration))
                                     (alternative
                                       (cnvrs::configuration-alternative configuration)))
                                 (case (cnvrs::configuration-state configuration)
                                   ,@(nreverse closure-clauses))))))
                         (nreverse result)))
                     (compiled-dfa-state-for (grammar configurations)
                       (let* ((closed (compiled-closure configurations))
                              (alternatives
                                (sort (remove-duplicates
                                       (mapcar #'cnvrs::configuration-alternative closed))
                                      #'<))
                              (accepted
                                (sort (remove-duplicates
                                       (loop for configuration in closed
                                             for state = (aref (cnvrs:parser-states grammar)
                                                               (cnvrs::configuration-state
                                                                configuration))
                                             when (and (cnvrs:state-stop-rule state)
                                                       (null (cnvrs::configuration-stack
                                                              configuration)))
                                               collect (cnvrs::configuration-alternative
                                                        configuration)))
                                      #'<)))
                         (cnvrs::make-dfa-state
                          :configurations closed :alternatives alternatives
                          :accepted accepted
                          :edges (cnvrs:make-cache (cnvrs:parser-cache-backend grammar)))))
                     (compiled-start (grammar state-id stack)
                       (cnvrs:cache-get-or-compute
                        (cnvrs:parser-decisions grammar)
                        (cnvrs::parser-context-key state-id stack)
                        (lambda ()
                          (compiled-dfa-state-for
                           grammar
                           (loop for edge in (cnvrs:state-edges
                                              (aref (cnvrs:parser-states grammar)
                                                    state-id))
                                 for alternative from 0
                                 collect (cnvrs::configuration-after-edge
                                          grammar edge stack alternative))))))
                     (compiled-advance (grammar dfa token)
                       (let ((key (cnvrs::token-key token)))
                         (cnvrs:cache-get-or-compute
                          (cnvrs::dfa-state-edges dfa) key
                          (lambda ()
                            (let ((next nil))
                              (dolist (configuration
                                       (cnvrs::dfa-state-configurations dfa))
                                (case (cnvrs::configuration-state configuration)
                                  ,@(nreverse step-clauses)))
                              (compiled-dfa-state-for grammar (nreverse next))))))))
                  (values #'compiled-start #'compiled-advance))))
           (function (compile nil form)))
      (funcall function))))
