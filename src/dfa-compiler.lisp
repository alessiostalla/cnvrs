(in-package #:cnvrs)

(defun cached-dfa-states (root limit)
  "Collect at most LIMIT states reachable through already cached edges."
  (let ((seen (make-hash-table :test 'eq))
        (pending (list root))
        (result nil))
    (loop while (and pending (< (length result) limit)) do
      (let ((state (pop pending)))
        (unless (gethash state seen)
          (setf (gethash state seen) t)
          (push state result)
          (dolist (entry (cache-entries (dfa-state-edges state)))
            (push (cdr entry) pending)))))
    (nreverse result)))

(defun compile-cached-dfa-root (grammar root kind max-states decision)
  "Compile the observed part of ROOT; signal a miss for uncached edges."
  (let* ((states (coerce (cached-dfa-states root max-states) 'vector))
         (ids (make-hash-table :test 'eq))
         (exit (and (eq kind :full)
                    (state-exit-alternative
                     (aref (parser-states grammar) decision)))))
    (loop for state across states for id from 0 do
      (setf (gethash state ids) id))
    (let ((clauses
            (loop for state across states for id from 0
                  for alternatives = (dfa-state-alternatives state)
                  for accepted = (dfa-state-accepted state)
                  collect
                  (let ((edges
                          (loop for (key . target) in
                                (cache-entries (dfa-state-edges state))
                                for target-id = (gethash target ids)
                                when target-id collect (list key target-id))))
                    `(,id
                      ,@(when (and alternatives (null (rest alternatives)))
                          `((return (values ,(first alternatives) t))))
                      ,(if (eq kind :sll)
                           `(when (or ,(null alternatives)
                                      ,(not (null accepted))
                                      (= position length))
                              (return (values nil nil)))
                           `(when (or ,(null alternatives)
                                      (= position length))
                              (return
                                (values
                                 (or ,(first accepted)
                                     (and (= position length)
                                          (member ',exit ',alternatives)
                                          ',exit)
                                     ,(first alternatives))
                                 t))))
                      (let ((key (token-key (aref tokens position))))
                        (cond
                          ,@(loop for (key target-id) in edges
                                  collect `((equal key ',key)
                                            (setf state-id ,target-id)))
                          (t (return (values nil nil)))))
                      (incf position))))))
      (values
       (compile nil
                `(lambda (tokens position)
                   (declare (type vector tokens))
                   (let ((length (length tokens)) (state-id 0))
                     (loop
                       (case state-id
                         ,@clauses
                         (otherwise (return (values nil nil))))))))
       (length states)))))

(defun compile-cached-dfa (parser &key (max-states 64))
  "Compile cached DFA traces for PARSER and enable them for prediction.
Warm the parser with representative inputs first. Each DFA root compiles at
most MAX-STATES observed states. Missing transitions use normal prediction.
Return the number of roots and states compiled. Repeating this call refreshes
the snapshots after more inputs; CLEAR-CACHE removes them."
  (let ((grammar (ensure-compiled parser)))
    (unless (parser-p grammar)
      (grammar-fail "DFA compilation requires a parser, got ~S" parser))
    (unless (and (integerp max-states) (plusp max-states))
      (grammar-fail ":MAX-STATES must be a positive integer, got ~S"
                    max-states))
    (let ((sll (make-hash-table :test 'eq))
          (full (make-hash-table :test 'eq))
          (roots 0)
          (states 0))
      (dolist (entry (cache-entries (parser-sll-decisions grammar)))
        (multiple-value-bind (program count)
            (compile-cached-dfa-root grammar (cdr entry) :sll
                                     max-states (car entry))
          (setf (gethash (cdr entry) sll) program)
          (incf roots)
          (incf states count)))
      (dolist (entry (cache-entries (parser-decisions grammar)))
        (let ((key (car entry)))
          (multiple-value-bind (program count)
              (compile-cached-dfa-root grammar (cdr entry) :full max-states
                                       (if (consp key) (car key) (aref key 0)))
            (setf (gethash (cdr entry) full) program)
            (incf roots)
            (incf states count))))
      (setf (parser-compiled-sll grammar)
            (and (plusp (hash-table-count sll)) sll)
            (parser-compiled-full grammar)
            (and (plusp (hash-table-count full)) full))
      (values roots states))))
