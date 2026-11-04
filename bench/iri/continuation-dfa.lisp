;; Experimental full-context DFA whose grammar return stack is a chain of
;; callable continuations. Keep the normal parser and caches untouched.
(in-package #:cl-user)

(defstruct return-continuation id resume)

(defun compile-return-factories (grammar)
  (let ((factories (make-hash-table)))
    (loop for state across (cnvrs:parser-states grammar) do
      (loop for edge in (cnvrs:state-edges state)
            when (eq (cnvrs:transition-kind edge) :call) do
              (let ((target (cnvrs:transition-target edge)))
                (unless (gethash target factories)
                  (setf (gethash target factories)
                        (compile nil
                                 `(lambda (parent)
                                    (lambda () (values ,target parent)))))))))
    factories))

(defun make-return-chain (grammar factories target parent)
  (make-return-continuation
   :id (cnvrs::intern-context grammar target
                                  (if parent (return-continuation-id parent) 0))
   :resume (funcall (gethash target factories) parent)))

(defun list-to-return-chain (grammar factories stack)
  (let ((result nil))
    (dolist (target (reverse stack) result)
      (setf result (make-return-chain grammar factories target result)))))

(defun continuation-configuration-after-edge (grammar factories edge chain alt)
  (case (cnvrs:transition-kind edge)
    (:call
     (cnvrs::make-configuration
      :state (gethash (cnvrs:transition-value edge)
                      (cnvrs:parser-starts grammar))
      :stack (make-return-chain grammar factories
                                (cnvrs:transition-target edge) chain)
      :alternative alt))
    (otherwise
     (cnvrs::make-configuration :state (cnvrs:transition-target edge)
                                :stack chain :alternative alt))))

(defun continuation-closure (grammar factories initial)
  (let ((pending initial) (seen (make-hash-table :test 'equal)) (result nil))
    (loop while pending do
      (let* ((configuration (pop pending))
             (chain (cnvrs::configuration-stack configuration))
             (key (list (cnvrs::configuration-state configuration)
                        (if chain (return-continuation-id chain) 0)
                        (cnvrs::configuration-alternative configuration))))
        (unless (gethash key seen)
          (setf (gethash key seen) t)
          (let* ((state (aref (cnvrs:parser-states grammar)
                              (cnvrs::configuration-state configuration)))
                 (alt (cnvrs::configuration-alternative configuration)))
            (if (cnvrs:state-stop-rule state)
                (if chain
                    (multiple-value-bind (target parent)
                        (funcall (return-continuation-resume chain))
                      (push (cnvrs::make-configuration
                             :state target :stack parent :alternative alt)
                            pending))
                    (push configuration result))
                (let ((has-token nil))
                  (dolist (edge (cnvrs:state-edges state))
                    (case (cnvrs:transition-kind edge)
                      ((:epsilon :call)
                       (push (continuation-configuration-after-edge
                              grammar factories edge chain alt)
                             pending))
                      ((:token :not-token) (setf has-token t))))
                  (when has-token (push configuration result))))))))
    (nreverse result)))

(defun continuation-dfa-state-for (grammar factories configurations)
  (let* ((closed (continuation-closure grammar factories configurations))
         (alternatives (sort (remove-duplicates
                              (mapcar #'cnvrs::configuration-alternative closed)) #'<))
         (accepted (sort (remove-duplicates
                          (loop for config in closed
                                for state = (aref (cnvrs:parser-states grammar)
                                                  (cnvrs::configuration-state config))
                                when (and (cnvrs:state-stop-rule state)
                                          (null (cnvrs::configuration-stack config)))
                                  collect (cnvrs::configuration-alternative config)))
                          #'<)))
    (cnvrs::make-dfa-state :configurations closed :alternatives alternatives
                           :accepted accepted
                           :edges (cnvrs:make-cache
                                   (cnvrs:parser-cache-backend grammar)))))

(defun continuation-advance (grammar factories dfa token)
  (cnvrs:cache-get-or-compute
   (cnvrs::dfa-state-edges dfa) (cnvrs::token-key token)
   (lambda ()
     (continuation-dfa-state-for
      grammar factories
      (loop for config in (cnvrs::dfa-state-configurations dfa)
            for state = (aref (cnvrs:parser-states grammar)
                              (cnvrs::configuration-state config))
            nconc (loop for edge in (cnvrs:state-edges state)
                        when (case (cnvrs:transition-kind edge)
                               (:token
                                (equal (cnvrs::token-key token)
                                       (cnvrs:transition-value edge)))
                               (:not-token
                                (not (member (cnvrs::token-key token)
                                             (cnvrs:transition-value edge)
                                             :test #'equal))))
                          collect (cnvrs::make-configuration
                                   :state (cnvrs:transition-target edge)
                                   :stack (cnvrs::configuration-stack config)
                                   :alternative
                                   (cnvrs::configuration-alternative config))))))))

(defun make-continuation-predictor (grammar)
  (let ((factories (compile-return-factories grammar))
        (starts (cnvrs:make-cache (cnvrs:parser-cache-backend grammar))))
    (values (lambda (state-id stack tokens position)
      (let* ((chain (if (or (null stack) (return-continuation-p stack))
                        stack
                        (list-to-return-chain grammar factories stack)))
             (dfa (cnvrs:cache-get-or-compute
                   starts (cons state-id
                                (if chain (return-continuation-id chain) 0))
                   (lambda ()
                     (continuation-dfa-state-for
                      grammar factories
                      (loop for edge in (cnvrs:state-edges
                                         (aref (cnvrs:parser-states grammar)
                                               state-id))
                            for alt from 0
                            collect (continuation-configuration-after-edge
                                     grammar factories edge chain alt))))))
             (length (length tokens)))
        (loop
          (let ((alternatives (cnvrs::dfa-state-alternatives dfa)))
            (when (= (length alternatives) 1)
              (return (first alternatives)))
            (when (or (null alternatives) (= position length))
              (return (or (first (cnvrs::dfa-state-accepted dfa))
                          (let ((exit (cnvrs:state-exit-alternative
                                       (aref (cnvrs:parser-states grammar)
                                             state-id))))
                            (and (= position length)
                                 (member exit alternatives) exit))
                          (first alternatives)))))
          (setf dfa (continuation-advance grammar factories dfa
                                          (aref tokens position)))
          (incf position))))
            (lambda (stack)
              (list-to-return-chain grammar factories stack)))))
