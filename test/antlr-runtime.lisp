(defpackage #:cnvrs/antlr-runtime/tests
  (:use #:cl #:cnvrs/antlr-runtime)
  (:export #:run-tests))
(in-package #:cnvrs/antlr-runtime/tests)
(defvar *checks* 0)
(defun check (value message &rest args)
  (incf *checks*)
  (unless value (error "ANTLR reference mismatch: ~?" message args)))
(defun fixture (name)
  (asdf:system-relative-pathname :cnvrs (concatenate 'string "test/fixtures/antlr-runtime/" name)))
(defun read-atn (form)
  (destructuring-bind (tag max-type states stops decisions) form
    (declare (ignore tag))
    (make-atn :max-token-type max-type :rule-stops (coerce stops 'vector)
              :decisions (coerce decisions 'vector)
              :states
              (map 'vector
                   (let ((id -1))
                     (lambda (entry)
                       (incf id)
                       (if (null entry) (make-atn-state :number id :kind :invalid)
                           (destructuring-bind (kind rule lr pd end edges) entry
                             (make-atn-state
                              :number id :kind kind :rule rule :precedence-rule-p lr
                              :precedence-decision-p pd :end-state end
                              :transitions
                              (loop for (type target follow label outer dependent) in edges
                                    collect (make-atn-transition :kind type :target target :follow follow
                                                                 :label label :outermost-precedence-return outer
                                                                 :context-dependent-p dependent)))))))
                   states))))
(defun paths-equal (a b)
  (let ((a (sort (copy-list a) #'string< :key #'prin1-to-string))
        (b (sort (copy-list b) #'string< :key #'prin1-to-string)))
    (equal a b)))
(defun test-context-merges ()
  (with-open-file (in (fixture "contexts.sexp"))
    (loop for form = (read in nil nil) while form do
      (destructuring-bind (wildcard stacks expected-hash expected-paths) form
        (let* ((cache (make-hash-table))
               (merged (reduce (lambda (a b) (merge-contexts a (context-from-stack b) wildcard cache))
                               (cdr stacks) :initial-value (context-from-stack (car stacks)))))
          (check (= (context-hash merged) expected-hash) "context hash ~S" form)
          (check (paths-equal (context-paths merged) expected-paths) "merged paths ~S" form)
          (check (eq merged (merge-contexts merged merged wildcard cache)) "idempotent merge")
          (let ((shared (make-context-cache)))
            (check (eq (cached-context merged shared)
                       (cached-context (reduce (lambda (a b) (merge-contexts a (context-from-stack b) wildcard))
                                               (cdr stacks) :initial-value (context-from-stack (car stacks))) shared))
                   "shared-context cache canonicalizes equal graphs")))))))
(defun test-prediction-trace (name)
  (with-open-file (in (fixture name))
    (let* ((atn (read-atn (read in))) (sim nil) (tokens nil) (enabled t) (mode :ll))
      (loop for form = (read in nil nil) while form do
        (case (car form)
          (:mode (setf mode (second form)))
          (:input (setf tokens (coerce (second form) 'vector)
                        enabled (if (cddr form) (third form) t)
                        sim (make-parser-atn-simulator
                             atn :mode mode :predicate-evaluator
                             (lambda (&rest args) (declare (ignore args)) enabled))))
          (:predict
           (destructuring-bind (tag decision position precedence stack expected) form
             (declare (ignore tag))
             (check (= (adaptive-predict sim tokens decision :position position
                                         :outer-context (context-from-stack stack) :precedence precedence)
                       expected)
                    "~A prediction ~S" name form)))
          (:no-viable
           (destructuring-bind (tag decision position precedence stack &optional offending-position) form
             (declare (ignore tag))
             (check (handler-case
                        (progn (adaptive-predict sim tokens decision :position position
                                                 :precedence precedence :outer-context (context-from-stack stack)) nil)
                      (no-viable-alt (e)
                        (check (= position (cnvrs/antlr-runtime::failed-start-index e))
                               "prediction error start position")
                        (when offending-position
                          (check (= offending-position (cnvrs/antlr-runtime::failed-position e))
                                 "prediction error offending position ~S" form))
                        t))
                    "~A no-viable-alt ~S" name form)))
          ;; Parse errors after a successful adaptivePredict are outside this
          ;; runtime's scope; the Java trace records them for provenance.
          (:parse-error nil)
          (:dfa-counts
           (check (equal (map 'list (lambda (d) (hash-table-count (dfa-states d)))
                                  (simulator-decision-dfas sim))
                         (second form))
                  "~A DFA state counts" name)))))
  t))
(defun test-shared-dfa ()
  (with-open-file (in (fixture "runtime-parity.sexp"))
    (let* ((atn (read-atn (read in))) (cases nil) (tokens nil))
      (loop for form = (read in nil nil) while form do
        (case (car form)
          (:input (setf tokens (coerce (second form) 'vector)))
          (:predict (unless (>= (length cases) 12) (push (cons tokens form) cases)))))
      (let* ((sim (make-parser-atn-simulator atn :predicate-evaluator (constantly t)))
             (errors nil) (lock (bordeaux-threads:make-lock "oracle errors"))
             (workers
               (loop repeat 4 collect
                 (bordeaux-threads:make-thread
                  (lambda ()
                    (handler-case
                        (dotimes (trial 5)
                          (dolist (case cases)
                            (destructuring-bind (tag decision position precedence stack expected) (cdr case)
                              (declare (ignore tag))
                              (unless (= (adaptive-predict sim (car case) decision :position position
                                                            :precedence precedence :outer-context (context-from-stack stack)) expected)
                                (error "concurrent prediction differs")))))
                      (error (e) (bordeaux-threads:with-lock-held (lock) (push e errors)))))))))
        (mapc #'bordeaux-threads:join-thread workers)
        (check (null errors) "concurrent DFA/context interning: ~S" errors)
        (let ((contexts-before (hash-table-count (simulator-context-cache sim))))
          (clear-dfa sim)
          (check (= contexts-before (hash-table-count (simulator-context-cache sim)))
                 "Java clearDFA preserves the shared context cache"))
        (check (every (lambda (d) (zerop (hash-table-count (dfa-states d))))
                      (simulator-decision-dfas sim)) "clearDFA")))))
(defun test-hash-boundaries ()
  (with-open-file (in (fixture "murmur.sexp"))
    (loop for form = (read in nil nil) while form do
      (destructuring-bind (operation hash argument expected) form
        (let ((actual (ecase operation
                        (:update (cnvrs/antlr-runtime::murmur-update hash argument))
                        (:finish (cnvrs/antlr-runtime::murmur-finish hash argument))
                        (:rotate (cnvrs/antlr-runtime::rotate-left-32 hash argument)))))
          (check (= actual expected) "typed 32-bit hash boundary ~S" form))))))

(defun test-compact-contexts-and-buckets ()
  (let* ((root (empty-prediction-context))
         (a (singleton-context root 17))
         (b (singleton-context (empty-prediction-context) 17))
         (array (cnvrs/antlr-runtime::context-node (vector 17) (vector root)))
         (cache (make-context-cache)))
    (check (typep a 'cnvrs/antlr-runtime::singleton-prediction-context) "compact singleton storage")
    (check (typep root 'cnvrs/antlr-runtime::singleton-prediction-context) "compact empty storage")
    (check (equalp #(17) (context-return-states a)) "singleton return-state vector view")
    (check (equalp (vector root) (context-parents a)) "singleton parent vector view")
    (check (context-equal a array) "indexed singleton/array equality")
    (check (= (context-hash a) (context-hash array)) "singleton/array hash agreement")
    (check (eq a (merge-contexts a b nil)) "equal singleton merge retains identity")
    (check (eq (cached-context a cache) (cached-context b cache)) "singleton canonicalization")
    (let* ((child (singleton-context b 23)) (updated (cached-context child cache)))
      (check (eq a (cnvrs/antlr-runtime::context-parent updated 0)) "canonicalized singleton parent")
      (check (context-equal child updated) "parent canonicalization preserves graph")))
  ;; Deliberately seed a bucket with a different configuration: integer hashes
  ;; are only a bucket selector, never a substitute for field equality.
  (let* ((set (make-atn-config-set :full-context t))
         (other (make-atn-config :state 2))
         (wanted (make-atn-config :state 3 :semantic (list :predicate 7)))
         (duplicate (make-atn-config :state 3 :semantic (list :predicate 7)))
         (table (cnvrs/antlr-runtime::config-set-lookup set)))
    (config-set-add set other)
    (setf (gethash (cnvrs/antlr-runtime::config-lookup-hash wanted) table) (list other))
    (config-set-add set wanted)
    (check (= 2 (length (config-set-items set))) "colliding config remains distinct")
    (config-set-add set duplicate)
    (check (= 2 (length (config-set-items set))) "equal semantic forms deduplicate")
    (check (eq wanted (first (gethash (cnvrs/antlr-runtime::config-lookup-hash wanted) table)))
           "bucket retains actual configuration objects"))
  ;; Equal context hashes must still compare the complete graph. This also
  ;; exercises conflict grouping, which ignores alt but retains context/state.
  (let* ((root (empty-prediction-context))
         (a (cnvrs/antlr-runtime::%singleton-context root 10 123))
         (b (cnvrs/antlr-runtime::%singleton-context root 11 123))
         (x (make-atn-config :state 9 :alt 1 :context a))
         (y (make-atn-config :state 9 :alt 1 :context b))
         (busy (make-hash-table :test 'eql))
         (set (make-atn-config-set)))
    (check (cnvrs/antlr-runtime::busy-add busy x) "first busy config")
    (check (cnvrs/antlr-runtime::busy-add busy y) "context hash collision remains distinct")
    (check (not (cnvrs/antlr-runtime::busy-add busy (cnvrs/antlr-runtime::derive-config x 9)))
           "equal busy config deduplicates")
    (setf (atn-config-alt y) 2)
    (config-set-add set x) (config-set-add set y)
    (check (equal '((1) (2)) (sort (conflicting-alt-subsets set) #'< :key #'car)) "context hash collision does not merge conflict groups")))

(defun run-tests ()
  (let ((*checks* 0))
    (test-context-merges)
    (test-hash-boundaries)
    (test-compact-contexts-and-buckets)
    (test-prediction-trace "runtime-parity.sexp")
    (test-prediction-trace "runtime-sll.sexp")
    (test-prediction-trace "runtime-exact.sexp")
    (test-prediction-trace "java8.sexp")
    (test-shared-dfa)
    (format t "~D ANTLR Java 4.13.2 reference checks passed.~%" *checks*)))
