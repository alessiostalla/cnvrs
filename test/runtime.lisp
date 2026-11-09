(defpackage #:cnvrs/runtime/tests
  (:use #:cl #:cnvrs/runtime)
  (:export #:run-tests))
(in-package #:cnvrs/runtime/tests)
(defvar *checks* 0)
(defun check (value message &rest args)
  (incf *checks*)
  (unless value (error "ANTLR reference mismatch: ~?" message args)))
(defun fixture (name)
  (asdf:system-relative-pathname :cnvrs (concatenate 'string "test/fixtures/runtime/" name)))
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
                        (check (= position (cnvrs/runtime::failed-start-index e))
                               "prediction error start position")
                        (when offending-position
                          (check (= offending-position (cnvrs/runtime::failed-position e))
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
                        (:update (cnvrs/runtime::murmur-update hash argument))
                        (:finish (cnvrs/runtime::murmur-finish hash argument))
                        (:rotate (cnvrs/runtime::rotate-left-32 hash argument)))))
          (check (= actual expected) "typed 32-bit hash boundary ~S" form))))))

(defun test-compact-contexts-and-buckets ()
  (let* ((root (empty-prediction-context))
         (a (singleton-context root 17))
         (b (singleton-context (empty-prediction-context) 17))
         (array (cnvrs/runtime::context-node (vector 17) (vector root)))
         (cache (make-context-cache)))
    (check (typep a 'cnvrs/runtime::singleton-prediction-context) "compact singleton storage")
    (check (typep root 'cnvrs/runtime::singleton-prediction-context) "compact empty storage")
    (check (equalp #(17) (context-return-states a)) "singleton return-state vector view")
    (check (equalp (vector root) (context-parents a)) "singleton parent vector view")
    (check (context-equal a array) "indexed singleton/array equality")
    (check (= (context-hash a) (context-hash array)) "singleton/array hash agreement")
    (check (eq a (merge-contexts a b nil)) "equal singleton merge retains identity")
    (check (eq (cached-context a cache) (cached-context b cache)) "singleton canonicalization")
    (let* ((child (singleton-context b 23)) (updated (cached-context child cache)))
      (check (eq a (cnvrs/runtime::context-parent updated 0)) "canonicalized singleton parent")
      (check (context-equal child updated) "parent canonicalization preserves graph")))
  ;; Deliberately seed a bucket with a different configuration: integer hashes
  ;; are only a bucket selector, never a substitute for field equality.
  (let* ((set (make-atn-config-set :full-context t))
         (other (make-atn-config :state 2))
         (wanted (make-atn-config :state 3 :semantic (list :predicate 7)))
         (duplicate (make-atn-config :state 3 :semantic (list :predicate 7)))
         (table (cnvrs/runtime::config-set-lookup set)))
    (config-set-add set other)
    (setf (gethash (cnvrs/runtime::config-lookup-hash wanted) table) (list other))
    (config-set-add set wanted)
    (check (= 2 (length (config-set-items set))) "colliding config remains distinct")
    (config-set-add set duplicate)
    (check (= 2 (length (config-set-items set))) "equal semantic forms deduplicate")
    (check (eq wanted (first (gethash (cnvrs/runtime::config-lookup-hash wanted) table)))
           "bucket retains actual configuration objects"))
  ;; Equal context hashes must still compare the complete graph. This also
  ;; exercises conflict grouping, which ignores alt but retains context/state.
  (let* ((root (empty-prediction-context))
         (a (cnvrs/runtime::%singleton-context root 10 123))
         (b (cnvrs/runtime::%singleton-context root 11 123))
         (x (make-atn-config :state 9 :alt 1 :context a))
         (y (make-atn-config :state 9 :alt 1 :context b))
         (busy (make-hash-table :test 'eql))
         (set (make-atn-config-set)))
    (check (cnvrs/runtime::busy-add busy x) "first busy config")
    (check (cnvrs/runtime::busy-add busy y) "context hash collision remains distinct")
    (check (not (cnvrs/runtime::busy-add busy (cnvrs/runtime::derive-config x 9)))
           "equal busy config deduplicates")
    (setf (atn-config-alt y) 2)
    (config-set-add set x) (config-set-add set y)
    (check (equal '((1) (2)) (sort (conflicting-alt-subsets set) #'< :key #'car)) "context hash collision does not merge conflict groups")))

(defun test-direct-context-arrays ()
  (let* ((root (empty-prediction-context))
         (a (singleton-context root 1)) (b (singleton-context root 2))
         (c (singleton-context root 3))
         (ab (merge-contexts a b nil)) (bc (merge-contexts b c nil))
         (nested (singleton-context (singleton-context root 9) 1))
         (one (cnvrs/runtime::context-node #(1) (vector root)))
         (contexts (list root a b ab bc nested one)))
    (dolist (x (list ab bc one))
      (check (typep (cnvrs/runtime::array-prediction-context-return-states x)
                    '(simple-array (unsigned-byte 32) (*))) "packed context payload storage")
      (check (typep (context-return-states x) 'simple-vector) "general-vector payload view compatibility"))
    ;; Includes all singleton/array input pairs, duplicate payloads, exact empty
    ;; paths, recursive parent merging, trimming and singleton collapse.
    (dolist (x contexts)
      (dolist (y contexts)
        (let* ((cache (make-hash-table :test 'eql))
               (merged (merge-contexts x y nil cache))
               (expected (remove-duplicates (append (context-paths x) (context-paths y)) :test #'equal)))
          (check (and (null (set-difference (context-paths merged) expected :test #'equal))
                      (null (set-difference expected (context-paths merged) :test #'equal))) "direct array merge preserves path union")
          (check (context-equal merged (merge-contexts y x nil)) "direct array merge commutes")
          (check (eq merged (merge-contexts x y nil cache)) "direct array merge cache retains identity"))))))

(defun test-specialized-loop-entry-traversal ()
  (let* ((edge (lambda (target) (list (make-atn-transition :kind :epsilon :target target))))
         (atn (make-atn :states
                       (vector
                        (make-atn-state :number 0 :kind :star-loop-entry :rule 0
                                        :precedence-decision-p t :transitions (funcall edge 1))
                        (make-atn-state :number 1 :kind :block-start :rule 0 :end-state 5)
                        (make-atn-state :number 2 :rule 1 :transitions (funcall edge 5))
                        (make-atn-state :number 3 :rule 0 :transitions (funcall edge 5))
                        (make-atn-state :number 4 :rule 1 :transitions (funcall edge 5))
                        (make-atn-state :number 5 :kind :block-end :rule 0 :transitions (funcall edge 0)))))
         (cnvrs/runtime::*simulator* (make-parser-atn-simulator atn)))
    (labels ((context (states)
               (reduce (lambda (a b) (merge-contexts a b nil)) states
                       :key (lambda (state) (singleton-context (empty-prediction-context) state))))
             (drop-p (states)
               (cnvrs/runtime::can-drop-loop-entry-edge-in-left-recursive-rule
                (make-atn-config :state 0 :context (context states)))))
      (check (not (drop-p '(2))) "singleton return with wrong rule prevents dropping")
      (check (drop-p '(3)) "singleton valid return permits dropping")
      (check (not (drop-p '(2 3))) "first failing array entry exits the complete traversal")
      (check (not (drop-p '(3 4))) "later failing array entry exits the complete traversal")
      (check (drop-p '(3 5)) "all valid array entries permit dropping"))))

(defun test-recovery-lookahead ()
  ;; A nullable guarded rule has two different caller continuations. Decision
  ;; analysis must keep the predicate opaque; recovery needs the exact caller.
  (let* ((atn
           (make-atn
            :max-token-type 7
            :states
            (vector
             (make-atn-state :number 0 :rule 1
                             :transitions (list (make-atn-transition :kind :rule :target 1 :follow 3)))
             (make-atn-state :number 1 :rule 0
                             :transitions (list (make-atn-transition :kind :predicate :target 2)))
             (make-atn-state :number 2 :rule 0 :kind :rule-stop
                             :transitions (list (make-atn-transition :kind :epsilon :target 3)))
             (make-atn-state :number 3 :rule 1
                             :transitions (list (make-atn-transition :kind :atom :target 4 :label 4)))
             (make-atn-state :number 4 :rule 1 :kind :rule-stop)
             (make-atn-state :number 5 :rule 1
                             :transitions (list (make-atn-transition :kind :atom :target 4 :label 7)))))))
    (check (equal '(0) (state-lookahead atn 0)) "decision predicate stays opaque")
    (check (equal '(4) (state-lookahead atn 0 :see-through-predicates t))
           "recovery traverses a nullable guarded call")
    (check (equal '(4) (state-lookahead atn 1 :context '(3) :see-through-predicates t))
           "recovery follows the first caller")
    (check (equal '(7) (state-lookahead atn 1 :context '(5) :see-through-predicates t))
           "recovery follows another caller without global follows")
    (check (null (state-lookahead atn 2)) "recovery stops at the entry rule boundary")
    (check (equal '(4) (state-lookahead atn 2 :follow-global-stops t))
           "decision analysis retains global follows")))

(defun run-tests ()
  (let ((*checks* 0))
    (test-recovery-lookahead)
    (test-context-merges)
    (test-hash-boundaries)
    (test-compact-contexts-and-buckets)
    (test-direct-context-arrays)
    (test-specialized-loop-entry-traversal)
    (test-prediction-trace "runtime-parity.sexp")
    (test-prediction-trace "runtime-sll.sexp")
    (test-prediction-trace "runtime-exact.sexp")
    (test-prediction-trace "java8.sexp")
    (test-shared-dfa)
    (format t "~D ANTLR Java 4.13.2 reference checks passed.~%" *checks*)))
