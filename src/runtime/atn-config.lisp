;;; Port of ATNConfig, ATNConfigSet and PredictionMode, ANTLR 4.13.2.
(in-package #:cnvrs/runtime)

;; Runtime policy is file-local: the standalone ASDF system is compiled before
;; the native frontend. Retain safety checks while optimizing the hot loops.
(declaim (optimize (speed 3) (safety 1) (debug 0) (space 0) (compilation-speed 1)))

(defstruct atn
  (states #() :type simple-vector) (rule-stops #() :type simple-vector)
  (decisions #() :type simple-vector) (max-token-type 0 :type fixnum)
  (mode-starts #() :type simple-vector) (rule-starts #() :type simple-vector)
  (rule-token-types #() :type simple-vector) (lexer-actions #() :type simple-vector))
(defstruct atn-state (number 0 :type fixnum) (kind :basic :type symbol)
  (rule 0 :type fixnum) (transitions nil :type list)
  precedence-rule-p precedence-decision-p
  (loop-back nil :type (or null fixnum)) (end-state nil :type (or null fixnum)) non-greedy-p)
(defstruct atn-transition (kind :epsilon :type symbol) (target 0 :type fixnum)
  (follow nil :type (or null fixnum)) label
  (outermost-precedence-return -1 :type fixnum) context-dependent-p (precedence 0 :type fixnum))
(defstruct atn-config (state 0 :type fixnum) (alt 1 :type fixnum)
  (context (empty-prediction-context) :type (or null prediction-context))
  (semantic t) (outer-depth 0 :type fixnum) precedence-filter-suppressed-p)
(defstruct (transient-atn-config (:include atn-config)
             (:constructor make-transient-atn-config ()) (:copier nil)))
(defstruct (atn-config-set (:conc-name config-set-))
  (items (make-array 4 :adjustable t :fill-pointer 0) :type (vector t))
  ;; Tiny sets scan ITEMS directly. Larger sets index the same owned objects
  ;; in a half-full open-addressed array, without per-entry bucket conses.
  (lookup nil :type (or null simple-vector)) full-context
  (unique-alt nil :type (or null fixnum)) conflicting-alts has-semantic-context dips-into-outer-context read-only-p)
(defvar *merge-cache* nil)

(declaim (inline derive-config retained-config))
(defun derive-config (config state &key (context (atn-config-context config))
                                      (semantic (atn-config-semantic config)) destination)
  (declare (type atn-config config) (type fixnum state)
           (type (or null prediction-context) context)
           (type (or null transient-atn-config) destination))
  (if destination
      (progn
        (setf (atn-config-state destination) state
              (atn-config-alt destination) (atn-config-alt config)
              (atn-config-context destination) context
              (atn-config-semantic destination) semantic
              (atn-config-outer-depth destination) (atn-config-outer-depth config)
              (atn-config-precedence-filter-suppressed-p destination)
              (atn-config-precedence-filter-suppressed-p config))
        destination)
      (make-atn-config :state state :alt (atn-config-alt config) :context context
                      :semantic semantic :outer-depth (atn-config-outer-depth config)
                      :precedence-filter-suppressed-p
                      (atn-config-precedence-filter-suppressed-p config))))
(defun retained-config (config)
  "Snapshot stack-scoped scratch configurations at an ownership boundary."
  (declare (type atn-config config))
  (if (transient-atn-config-p config)
      (derive-config config (atn-config-state config)) config))
(declaim (inline config-lookup-hash config-lookup-equal))
(defun config-lookup-hash (config)
  (declare (type atn-config config))
  ;; This is an internal bucket key, not a Java-visible context/config hash.
  ;; Full field equality still resolves collisions. Keep intermediate values
  ;; bounded for machine arithmetic on the measured 64-bit runtime.
  (let ((key (u32 (+ (* 31 (u32 (atn-config-state config)))
                     (u32 (atn-config-alt config))))))
    (if (eq (atn-config-semantic config) t) key
        (u32 (+ (* 31 key) (u32 (sxhash (atn-config-semantic config))))))))
(defun config-lookup-equal (a b)
  (declare (type atn-config a b))
  (and (= (atn-config-state a) (atn-config-state b))
       (= (atn-config-alt a) (atn-config-alt b))
       (equal (atn-config-semantic a) (atn-config-semantic b))))
(declaim (inline find-config-in-bucket))
(defun find-config-in-bucket (config bucket)
  (declare (type atn-config config) (type list bucket))
  (loop for candidate of-type atn-config in bucket
        when (config-lookup-equal config candidate) return candidate))
(declaim (inline config-table-slot find-config-in-set))
(defun config-table-slot (table config)
  (declare (type simple-vector table) (type atn-config config))
  (let* ((mask (1- (length table)))
         (slot (logand mask (murmur-finish (config-lookup-hash config) 3))))
    (declare (type fixnum mask slot))
    (loop for candidate = (svref table slot)
          when (or (null candidate) (config-lookup-equal config candidate)) return slot
          do (setf slot (logand mask (1+ slot))))))
(defun find-config-in-set (set config)
  "Return an existing entry and its index slot (when a hash index exists)."
  (declare (type atn-config-set set) (type atn-config config))
  (let ((lookup (config-set-lookup set)))
    (if lookup
        (let ((slot (config-table-slot lookup config)))
          (values (svref lookup slot) slot))
        (loop for candidate of-type atn-config across (config-set-items set)
              when (config-lookup-equal config candidate) return candidate))))
(defun grow-config-index (set)
  (declare (type atn-config-set set))
  (let* ((items (config-set-items set))
         (capacity (max 16 (ash 1 (integer-length (* 2 (length items))))))
         (lookup (make-array capacity :initial-element nil)))
    (loop for config of-type atn-config across items do
      (setf (svref lookup (config-table-slot lookup config)) config))
    (setf (config-set-lookup set) lookup)))
(defun config-set-add (set config &optional (merge-cache *merge-cache*))
  "Return T and the source configuration to use for continued traversal.
An inserted scratch configuration is promoted to an owned object; a merged
input remains the traversal source, preserving the reference aliasing rules."
  (declare (type atn-config-set set) (type atn-config config)
           (type (or null hash-table) merge-cache))
  (when (config-set-read-only-p set) (error "ATNConfigSet is read-only"))
  (unless (eq (atn-config-semantic config) t)
    (setf (config-set-has-semantic-context set) t))
  (when (plusp (atn-config-outer-depth config))
    (setf (config-set-dips-into-outer-context set) t))
  (multiple-value-bind (existing slot) (find-config-in-set set config)
    (let ((source config))
      (if existing
          (setf (atn-config-context existing)
                (merge-contexts (atn-config-context existing) (atn-config-context config)
                                (not (config-set-full-context set)) merge-cache)
                (atn-config-outer-depth existing)
                (max (atn-config-outer-depth existing) (atn-config-outer-depth config))
                (atn-config-precedence-filter-suppressed-p existing)
                (or (atn-config-precedence-filter-suppressed-p existing)
                    (atn-config-precedence-filter-suppressed-p config)))
          (let ((owned (retained-config config)))
            (when (>= (length (config-set-items set)) 4)
              (when (or (null (config-set-lookup set))
                        (> (* 2 (1+ (length (config-set-items set))))
                            (length (config-set-lookup set))))
                (grow-config-index set)
                (setf slot (config-table-slot (config-set-lookup set) config)))
              (setf (svref (config-set-lookup set) slot) owned))
            (setf source owned)
            (vector-push-extend owned (config-set-items set))))
      ;; Continue traversal with the retained object on insertion. Later merges
      ;; must update the same object the active traversal uses, as in Java.
      (values t source))))
(defun config-set-alternatives (set)
  (sort (remove-duplicates (map 'list #'atn-config-alt (config-set-items set))) #'<))
(defun unique-alt (set)
  (declare (type atn-config-set set))
  (let ((alt nil))
    (loop for config across (config-set-items set) do
      (if alt (unless (= alt (atn-config-alt config)) (return-from unique-alt nil))
          (setf alt (atn-config-alt config))))
    alt))
(defun stop-config-p (atn config)
  (eq (atn-state-kind (aref (atn-states atn) (atn-config-state config))) :rule-stop))
(defun all-configs-in-rule-stop-states (atn set)
  (every (lambda (c) (stop-config-p atn c)) (config-set-items set)))
(defun conflicting-alt-subsets (set)
  ;; Java AltAndContextMap ignores alt and semantic context, but compares
  ;; complete prediction contexts. Hash buckets avoid flattening the DAG.
  (let ((buckets (make-hash-table :test 'eql)) (groups nil))
    (loop for c across (config-set-items set) do
      (let* ((context (atn-config-context c))
             (key (murmur-update (u32 (atn-config-state c)) (context-hash context)))
             (group (loop for g in (gethash key buckets)
                          when (and (= (atn-config-state c) (the fixnum (first g)))
                                    (context-equal context (second g))) return g)))
        (unless group
          (setf group (list (atn-config-state c) context))
          (push group (gethash key buckets)) (push group groups))
        (pushnew (atn-config-alt c) (cddr group))))
    (mapcar (lambda (g) (sort (copy-list (cddr g)) #'<)) groups)))
(defun single-viable-alt (alt-subsets)
  (let ((answer nil))
    (dolist (subset alt-subsets)
      (let ((minimum (reduce #'min subset)))
        (when (and answer (/= answer minimum)) (return-from single-viable-alt nil))
        (setf answer minimum)))
    answer))

(defstruct (conflict-workspace (:constructor make-conflict-workspace ()))
  ;; A workspace belongs to one parse (or one standalone prediction). Groups
  ;; borrow configurations only for the duration of a single grouping call.
  (buckets (make-array 0 :element-type 'fixnum) :type (simple-array fixnum (*)))
  (representatives #() :type simple-vector)
  (minima (make-array 0 :element-type 'fixnum) :type (simple-array fixnum (*))))
(defvar *conflict-workspace* nil)

(defun config-set-single-viable-alt (set workspace)
  "Compute the common minimum alternative without materializing subsets."
  (declare (type atn-config-set set) (type conflict-workspace workspace))
  (let* ((items (config-set-items set)) (size (length items))
         (capacity (max 16 (ash 1 (integer-length (max 0 (1- (* 2 size))))))))
    (when (< (length (conflict-workspace-buckets workspace)) capacity)
      (setf (conflict-workspace-buckets workspace)
            (make-array capacity :element-type 'fixnum :initial-element 0)
            (conflict-workspace-representatives workspace)
            (make-array (ash capacity -1) :initial-element nil)
            (conflict-workspace-minima workspace)
            (make-array (ash capacity -1) :element-type 'fixnum :initial-element 0)))
    (let* ((buckets (conflict-workspace-buckets workspace))
           (representatives (conflict-workspace-representatives workspace))
           (minima (conflict-workspace-minima workspace))
           (mask (1- capacity)) (groups 0))
      (declare (type fixnum mask groups))
      ;; A large earlier decision must not make every small decision clear the
      ;; entire high-water allocation. Probe only the active power-of-two span.
      (fill buckets 0 :end capacity)
      (unwind-protect
           (progn
             (loop for config of-type atn-config across items do
               (let* ((context (atn-config-context config))
                      ;; Finalize before masking: Murmur's update alone has
                      ;; badly clustered low bits on real prediction contexts.
                      (slot (logand mask (murmur-finish
                                         (murmur-update (u32 (atn-config-state config))
                                                        (context-hash context)) 2))))
                 (declare (type fixnum slot))
                 (loop for entry fixnum = (aref buckets slot) do
                   (cond
                     ((zerop entry)
                      (setf (aref buckets slot) (1+ groups)
                            (svref representatives groups) config
                            (aref minima groups) (atn-config-alt config))
                      (incf groups) (return))
                     (t
                      (let* ((index (1- entry))
                             (candidate (the atn-config (svref representatives index))))
                        (when (and (= (atn-config-state config) (atn-config-state candidate))
                                   (context-equal context (atn-config-context candidate)))
                          (setf (aref minima index) (min (aref minima index) (atn-config-alt config)))
                          (return)))))
                   (setf slot (logand mask (1+ slot))))))
             (when (plusp groups)
               (let ((answer (aref minima 0)))
                 (loop for i fixnum from 1 below groups
                       unless (= answer (aref minima i)) do (return-from config-set-single-viable-alt nil))
                 answer)))
        ;; Never retain configurations or their context DAGs between calls.
        (fill representatives nil :end groups)))))
(defun has-sll-conflict-terminating-prediction (atn set &optional (mode :ll))
  (when (all-configs-in-rule-stop-states atn set)
    (return-from has-sll-conflict-terminating-prediction t))
  (when (and (eq mode :sll) (config-set-has-semantic-context set))
    (let ((stripped (make-atn-config-set)))
      (loop for c across (config-set-items set) do
        (config-set-add stripped (derive-config c (atn-config-state c) :semantic t)))
      (setf set stripped)))
  (and (some #'cdr (conflicting-alt-subsets set))
       (let ((state-alts (make-hash-table)))
         (loop for c across (config-set-items set) do
           (pushnew (atn-config-alt c) (gethash (atn-config-state c) state-alts)))
         (not (loop for alts being the hash-values of state-alts
                    thereis (null (cdr alts)))))))

;; SemanticContext uses T for Empty.Instance, NIL for no predicate/false,
;; and immutable predicate/operator forms for the remaining Java subclasses.
(defun semantic-operator (operator a b)
  (cond ((eq operator :and)
         (when (or (null a) (eq a t)) (return-from semantic-operator b))
         (when (or (null b) (eq b t)) (return-from semantic-operator a)))
        (t
         (when (null a) (return-from semantic-operator b))
         (when (null b) (return-from semantic-operator a))
         (when (or (eq a t) (eq b t)) (return-from semantic-operator t))))
  (when (equal a b) (return-from semantic-operator a))
  (let* ((operands (remove-duplicates
                    (append (if (eq (car a) operator) (cdr a) (list a))
                            (if (eq (car b) operator) (cdr b) (list b))) :test #'equal))
         (precedences (remove-if-not (lambda (p) (eq (car p) :precedence)) operands)))
    (when precedences
      (setf operands (remove-if (lambda (p) (eq (car p) :precedence)) operands))
      (push (list :precedence (reduce (if (eq operator :and) #'min #'max)
                                     precedences :key #'second)) operands))
    (if (null (cdr operands)) (car operands)
        (cons operator (sort operands #'string< :key #'prin1-to-string)))))
