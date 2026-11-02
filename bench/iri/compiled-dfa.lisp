;; Compile the observed full-context DFA trace into token dispatch. Other
;; contexts and transitions use the existing predictor.
(in-package #:cl-user)

(defun compile-iri-cached-dfa (grammar hot-states)
  (let ((state-ids (make-hash-table :test 'eq))
        (states (coerce (remove-duplicates hot-states :test #'eq) 'vector)))
    (loop for state across states for id from 0 do
      (setf (gethash state state-ids) id))
    (let* ((clauses
             (loop for state across states for id from 0
                   for alternatives = (cnvrs::dfa-state-alternatives state)
                   for accepted = (cnvrs::dfa-state-accepted state)
                   collect
                   (let ((transitions nil))
                     (maphash (lambda (key target)
                                (multiple-value-bind (next present)
                                    (gethash target state-ids)
                                  (when present
                                    (push (list key next) transitions))))
                              (cnvrs::hash-cache-table
                               (cnvrs::dfa-state-edges state)))
                     `(,id
                       ,@(when (and alternatives (null (rest alternatives)))
                           `((return-from compiled-predictor
                               ,(first alternatives))))
                       (when (or ,(null alternatives) (= position length))
                         (return-from compiled-predictor
                           (or ,(first accepted)
                               (and (= position length)
                                    (member exit ',alternatives) exit)
                               ,(first alternatives))))
                       (let ((key (cnvrs::token-key (aref tokens position))))
                         (cond
                           ,@(loop for (key target) in transitions
                                   collect `((equal key ',key)
                                             (setf state-id ,target)))
                           (t (return-from compiled-predictor
                                (funcall fallback grammar decision stack
                                         tokens start-position)))))
                       (incf position)))))
           (exit (cnvrs:state-exit-alternative
                  (aref (cnvrs:parser-states grammar) 14)))
           (function
             (compile
              nil
              `(lambda (grammar decision stack tokens position state-ids fallback)
                 (declare (type vector tokens))
                 (block compiled-predictor
                   (let* ((start-position position)
                          (length (length tokens))
                          (exit ,exit)
                          (dfa (cnvrs::cached-full-context-start
                                grammar decision stack))
                          (state-id (gethash dfa state-ids)))
                     (unless state-id
                       (return-from compiled-predictor
                         (funcall fallback grammar decision stack tokens position)))
                     (loop
                       (case state-id
                         ,@clauses
                         (otherwise
                          (return-from compiled-predictor
                            (funcall fallback grammar decision stack
                                     tokens start-position)))))))))))
      (values function state-ids (length states)))))
