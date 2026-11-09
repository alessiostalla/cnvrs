;;; Port of PredictionContext, {Empty,Singleton,Array}PredictionContext,
;;; PredictionContextCache, and misc.MurmurHash, ANTLR 4.13.2 (BSD-3-Clause).
(in-package #:cnvrs/antlr-runtime)

;; Runtime policy is file-local: the standalone ASDF system is compiled before
;; the native frontend. Retain safety checks while optimizing the hot loops.
(declaim (optimize (speed 3) (safety 1) (debug 0) (space 0) (compilation-speed 1)))

(declaim (inline u32 rotate-left-32 murmur-update murmur-finish))
(declaim (ftype (function (integer) (unsigned-byte 32)) u32)
         (ftype (function ((unsigned-byte 32) (integer 0 31)) (unsigned-byte 32)) rotate-left-32)
         (ftype (function ((unsigned-byte 32) (unsigned-byte 32)) (unsigned-byte 32)) murmur-update)
         (ftype (function ((unsigned-byte 32) (integer 0 #.most-positive-fixnum)) (unsigned-byte 32)) murmur-finish))

(defconstant +empty-return-state+ #x7fffffff)
(defun u32 (n) (logand n #xffffffff))
(defun rotate-left-32 (n bits)
  (declare (type (unsigned-byte 32) n) (type (integer 0 31) bits))
  (u32 (logior (ash n bits) (ash n (- bits 32)))))
(defun murmur-update (hash value)
  (declare (type (unsigned-byte 32) hash value))
  (let* ((k (u32 (* value #xcc9e2d51)))
         (k (u32 (* (rotate-left-32 k 15) #x1b873593)))
         (h (rotate-left-32 (logxor hash k) 13)))
    (u32 (+ (* h 5) #xe6546b64))))
(defun murmur-finish (hash words)
  (declare (type (unsigned-byte 32) hash) (type (integer 0 #.most-positive-fixnum) words))
  (let ((h (u32 (logxor hash (* words 4)))))
    (setf h (logxor h (ash h -16))
          h (u32 (* h #x85ebca6b))
          h (logxor h (ash h -13))
          h (u32 (* h #xc2b2ae35)))
    (u32 (logxor h (ash h -16)))))

(defstruct (prediction-context (:constructor nil) (:copier nil))
  (hash 0 :type (unsigned-byte 32) :read-only t))
(defstruct (singleton-prediction-context
             (:include prediction-context)
             (:constructor %singleton-context (parent return-state hash)) (:copier nil))
  (parent nil :type (or null prediction-context) :read-only t)
  (return-state 0 :type (unsigned-byte 32) :read-only t))
(deftype return-state-vector () '(simple-array (unsigned-byte 32) (*)))

(defstruct (array-prediction-context
             (:include prediction-context)
             (:constructor %array-context (return-states parents hash)) (:copier nil))
  (return-states (make-array 0 :element-type '(unsigned-byte 32)) :type return-state-vector :read-only t)
  (parents #() :type simple-vector :read-only t))
(declaim (inline context-size context-return-state context-parent context-hash
                 empty-context-p empty-prediction-context context-first-entry))
(defun context-size (context)
  (etypecase context
    (singleton-prediction-context 1)
    (array-prediction-context (length (array-prediction-context-return-states context)))))
(defun context-return-state (context index)
  (declare (type fixnum index))
  (etypecase context
    (singleton-prediction-context
     (assert (zerop index)) (singleton-prediction-context-return-state context))
    (array-prediction-context
     (aref (array-prediction-context-return-states context) index))))
(defun context-parent (context index)
  (declare (type fixnum index))
  (etypecase context
    (singleton-prediction-context
     (assert (zerop index)) (singleton-prediction-context-parent context))
    (array-prediction-context (aref (array-prediction-context-parents context) index))))
;; Preserve the exported vector views. Internal traversal uses indexed accessors
;; so singleton contexts never need temporary one-element vectors.
(defun context-return-states (context)
  (etypecase context
    (singleton-prediction-context (vector (singleton-prediction-context-return-state context)))
    (array-prediction-context (coerce (array-prediction-context-return-states context) 'simple-vector))))
(defun context-parents (context)
  (etypecase context
    (singleton-prediction-context (vector (singleton-prediction-context-parent context)))
    (array-prediction-context (array-prediction-context-parents context))))
(defun context-hash (context) (if context (prediction-context-hash context) 0))
(defparameter *empty-prediction-context*
  (%singleton-context nil +empty-return-state+ (murmur-finish 1 0)))
(defun empty-prediction-context () *empty-prediction-context*)
(defun empty-context-p (context) (eq context *empty-prediction-context*))
(defun context-first-entry (context)
  (declare (type prediction-context context))
  (etypecase context
    (singleton-prediction-context
     (values (singleton-prediction-context-return-state context)
             (singleton-prediction-context-parent context)))
    (array-prediction-context
     (values (aref (array-prediction-context-return-states context) 0)
             (aref (array-prediction-context-parents context) 0)))))
(defmacro do-context-entries (((state parent) context) &body body)
  "Traverse concrete storage after one representation dispatch."
  (let ((node (gensym "CONTEXT")) (states (gensym "STATES"))
        (parents (gensym "PARENTS")) (index (gensym "INDEX")))
    `(let ((,node ,context))
       (etypecase ,node
         (singleton-prediction-context
          (let ((,state (singleton-prediction-context-return-state ,node))
                (,parent (singleton-prediction-context-parent ,node)))
            ,@body))
         (array-prediction-context
          (let ((,states (array-prediction-context-return-states ,node))
                (,parents (array-prediction-context-parents ,node)))
            (loop for ,index fixnum below (length ,states) do
              (let ((,state (aref ,states ,index)) (,parent (aref ,parents ,index)))
                ,@body))))))))
(defun context-has-empty-path-p (context)
  (declare (type prediction-context context))
  (etypecase context
    (singleton-prediction-context (= (singleton-prediction-context-return-state context) +empty-return-state+))
    (array-prediction-context
     (let ((states (array-prediction-context-return-states context)))
       (= (aref states (1- (length states))) +empty-return-state+)))))
(defun context-equal (a b)
  (declare (type (or null prediction-context) a b))
  (or (eq a b)
      (and a b (= (context-hash a) (context-hash b))
           (etypecase a
             (singleton-prediction-context
              (etypecase b
                (singleton-prediction-context
                 (and (= (singleton-prediction-context-return-state a)
                         (singleton-prediction-context-return-state b))
                      (context-equal (singleton-prediction-context-parent a)
                                     (singleton-prediction-context-parent b))))
                (array-prediction-context
                 (let ((bs (array-prediction-context-return-states b)))
                   (and (= 1 (length bs))
                        (= (singleton-prediction-context-return-state a) (aref bs 0))
                        (context-equal (singleton-prediction-context-parent a)
                                       (aref (array-prediction-context-parents b) 0)))))))
             (array-prediction-context
              (let ((as (array-prediction-context-return-states a))
                    (ap (array-prediction-context-parents a)))
                (etypecase b
                  (singleton-prediction-context
                   (and (= 1 (length as))
                        (= (aref as 0) (singleton-prediction-context-return-state b))
                        (context-equal (aref ap 0) (singleton-prediction-context-parent b))))
                  (array-prediction-context
                   (let ((bs (array-prediction-context-return-states b))
                         (bp (array-prediction-context-parents b)))
                     (and (= (length as) (length bs))
                          (loop for i fixnum below (length as)
                                always (and (= (aref as i) (aref bs i))
                                            (context-equal (aref ap i) (aref bp i))))))))))))))
(defun context-node (states parents)
  (declare (type (or simple-vector return-state-vector) states) (type simple-vector parents))
  ;; Internal builders already supply packed arrays. Accept the existing general
  ;; vector interface for fixture/front-end callers without retaining it.
  (unless (typep states 'return-state-vector)
    (setf states (make-array (length states) :element-type '(unsigned-byte 32) :initial-contents states)))
  (let ((hash 1))
    (declare (type (unsigned-byte 32) hash))
    (loop for parent across parents do
      (setf hash (murmur-update hash (context-hash parent))))
    (loop for state across states do (setf hash (murmur-update hash state)))
    (%array-context states parents (murmur-finish hash (* 2 (length states))))))
(defun singleton-context (parent return-state)
  (declare (type (unsigned-byte 32) return-state) (type (or null prediction-context) parent))
  (if (and (null parent) (= return-state +empty-return-state+))
      (empty-prediction-context)
      (%singleton-context parent return-state
                          (murmur-finish (murmur-update (murmur-update 1 (context-hash parent))
                                                       return-state) 2))))
(defun context-from-stack (stack)
  (if stack (singleton-context (context-from-stack (cdr stack)) (car stack))
      (empty-prediction-context)))

;; CL has no portable custom hash-table test. Buckets use Java's cached hash,
;; then the same structural equality as PredictionContext.equals().
(defun make-context-cache () (make-hash-table :test 'eql))
(defun context-cache-get (cache context)
  (declare (type hash-table cache) (type prediction-context context))
  (loop for candidate of-type prediction-context in (gethash (context-hash context) cache)
        when (context-equal context candidate) return candidate))
(defun context-cache-add (cache context)
  (declare (type hash-table cache) (type prediction-context context))
  (or (context-cache-get cache context)
      (progn (push context (gethash (context-hash context) cache)) context)))
(defun cached-context (context cache &optional (visited (make-hash-table :test 'eq)))
  (declare (type (or null prediction-context) context) (type hash-table cache visited))
  (when (or (null context) (empty-context-p context))
    (return-from cached-context context))
  (or (gethash context visited)
      (let ((existing (context-cache-get cache context)))
        (setf (gethash context visited)
              (or existing
                  (let ((updated
                          (etypecase context
                            (singleton-prediction-context
                             (let* ((old (singleton-prediction-context-parent context))
                                    (parent (cached-context old cache visited)))
                               (if (eq parent old) context
                                   (singleton-context parent (singleton-prediction-context-return-state context)))))
                            (array-prediction-context
                             (let* ((old (array-prediction-context-parents context))
                                    (parents (map 'vector (lambda (p) (cached-context p cache visited)) old)))
                               (if (every #'eq parents old) context
                                   (context-node (array-prediction-context-return-states context) parents)))))))
                    (context-cache-add cache updated)))))))

(defun merge-cache-get (cache a b wildcard)
  (declare (ignore wildcard) (type (or null hash-table) cache)
           (type (or null prediction-context) a b))
  (when cache
    (loop for (x y result) in
          (gethash (logxor (context-hash a) (context-hash b)) cache)
          when (or (and (context-equal x a) (context-equal y b))
                   (and (context-equal x b) (context-equal y a)))
            return result)))
(defun merge-cache-put (cache a b wildcard result)
  (declare (ignore wildcard) (type (or null hash-table) cache)
           (type (or null prediction-context) a b result))
  (when cache
    (push (list a b result)
          (gethash (logxor (context-hash a) (context-hash b)) cache)))
  result)

(declaim (inline two-return-states))
(defun two-return-states (a b)
  (declare (type (unsigned-byte 32) a b))
  (let ((states (make-array 2 :element-type '(unsigned-byte 32))))
    (setf (aref states 0) a (aref states 1) b)
    states))
(defun merge-root (a b root-is-wildcard)
  (declare (type prediction-context a b))
  (if root-is-wildcard
      (cond ((empty-context-p a) a) ((empty-context-p b) b))
      (cond ((and (empty-context-p a) (empty-context-p b)) (empty-prediction-context))
            ((empty-context-p a)
             (multiple-value-bind (state parent) (context-first-entry b)
               (context-node (two-return-states state +empty-return-state+) (vector parent nil))))
            ((empty-context-p b)
             (multiple-value-bind (state parent) (context-first-entry a)
               (context-node (two-return-states state +empty-return-state+) (vector parent nil)))))))
(defun merge-singletons (a b root-is-wildcard merge-cache)
  (declare (type prediction-context a b) (type (or null hash-table) merge-cache))
  (let ((previous (merge-cache-get merge-cache a b root-is-wildcard)))
    (when previous (return-from merge-singletons previous)))
  (let ((root (merge-root a b root-is-wildcard)))
    (when root (return-from merge-singletons (merge-cache-put merge-cache a b root-is-wildcard root))))
  (multiple-value-bind (ar ap) (context-first-entry a)
    (multiple-value-bind (br bp) (context-first-entry b)
      (if (= ar br)
          (let ((parent (merge-contexts ap bp root-is-wildcard merge-cache)))
            (cond ((eq parent ap) a) ((eq parent bp) b)
                  (t (merge-cache-put merge-cache a b root-is-wildcard (singleton-context parent ar)))))
          (let ((single-parent (and ap (context-equal ap bp) ap)))
            (merge-cache-put
             merge-cache a b root-is-wildcard
             (if (< ar br)
                 (context-node (two-return-states ar br)
                               (if single-parent (vector single-parent single-parent) (vector ap bp)))
                 (context-node (two-return-states br ar)
                               (if single-parent (vector single-parent single-parent) (vector bp ap))))))))))
(defun combine-common-parents (parents)
  (declare (type simple-vector parents))
  (let ((unique (make-context-cache)))
    (loop for parent across parents when parent do (context-cache-add unique parent))
    (loop for parent across parents for i from 0 when parent do
      (setf (aref parents i) (context-cache-get unique parent))))
  parents)
;; A normalized input view contains packed arrays or singleton scalar fields.
;; The traversal below dispatches once per input and expands four small merge
;; loops, so no indexed generic context access occurs in the element loops.
(defmacro fill-context-merge (a b wildcard cache states parents i j k)
  ;; Bodies share outer output arrays/cursors. Only input access is specialized;
  ;; the comparison, recursive merge and write order are Java's mergeArrays.
  (labels ((kernel (as ap bs bp a-single b-single)
             (let ((ar (if a-single as `(aref ,as ,i)))
                   (br (if b-single bs `(aref ,bs ,j)))
                   (ax (if a-single ap `(aref ,ap ,i)))
                   (bx (if b-single bp `(aref ,bp ,j))))
               `(progn
                  (loop while (and (< ,i ,(if a-single 1 `(length ,as)))
                                   (< ,j ,(if b-single 1 `(length ,bs)))) do
                    (let ((ar ,ar) (br ,br) (ax ,ax) (bx ,bx))
                      (cond ((= ar br)
                             (setf (aref ,states ,k) ar
                                   (aref ,parents ,k)
                                   (if (or (and (= ar +empty-return-state+) (null ax) (null bx))
                                           (and ax (context-equal ax bx))) ax
                                       (merge-contexts ax bx ,wildcard ,cache)))
                             (incf ,i) (incf ,j))
                            ((< ar br)
                             (setf (aref ,states ,k) ar (aref ,parents ,k) ax) (incf ,i))
                            (t (setf (aref ,states ,k) br (aref ,parents ,k) bx) (incf ,j)))
                      (incf ,k)))
                  (loop while (< ,i ,(if a-single 1 `(length ,as))) do
                    (setf (aref ,states ,k) ,ar (aref ,parents ,k) ,ax) (incf ,i) (incf ,k))
                  (loop while (< ,j ,(if b-single 1 `(length ,bs))) do
                    (setf (aref ,states ,k) ,br (aref ,parents ,k) ,bx) (incf ,j) (incf ,k)))))
           (view (node states parents continuation)
             `(etypecase ,node
                (singleton-prediction-context
                 (let ((,states (singleton-prediction-context-return-state ,node))
                       (,parents (singleton-prediction-context-parent ,node)))
                   ,(funcall continuation t)))
                (array-prediction-context
                 (let ((,states (array-prediction-context-return-states ,node))
                       (,parents (array-prediction-context-parents ,node)))
                   ,(funcall continuation nil))))))
    (let ((as (gensym "AS")) (ap (gensym "AP")) (bs (gensym "BS")) (bp (gensym "BP")))
      (view a as ap (lambda (a-single)
                     (view b bs bp (lambda (b-single) (kernel as ap bs bp a-single b-single))))))))

(defun merge-arrays (a b root-is-wildcard merge-cache)
  (declare (type prediction-context a b) (type (or null hash-table) merge-cache))
  (let ((previous (merge-cache-get merge-cache a b root-is-wildcard)))
    (when previous (return-from merge-arrays previous)))
  (let* ((capacity (+ (context-size a) (context-size b)))
         (states (make-array capacity :element-type '(unsigned-byte 32)))
         (parents (make-array capacity)) (i 0) (j 0) (k 0))
    (declare (type fixnum capacity i j k))
    (fill-context-merge a b root-is-wildcard merge-cache states parents i j k)
    (when (= k 1)
      (return-from merge-arrays
        (merge-cache-put merge-cache a b root-is-wildcard
                         (singleton-context (aref parents 0) (aref states 0)))))
    ;; Java trims only when duplicate payloads made the result shorter.
    (when (< k capacity)
      (setf states (subseq states 0 k) parents (subseq parents 0 k)))
    (let ((merged (context-node states parents)))
      (cond ((context-equal merged a) (setf merged a))
            ((context-equal merged b) (setf merged b))
            (t (combine-common-parents parents)))
      (merge-cache-put merge-cache a b root-is-wildcard merged))))
(defun merge-contexts (a b root-is-wildcard &optional merge-cache)
  "PredictionContext.merge, retaining Java's singleton/root/array dispatch."
  (declare (type (or null prediction-context) a b) (type (or null hash-table) merge-cache))
  (when (context-equal a b) (return-from merge-contexts a))
  (when (and (= (context-size a) 1)
             (= (context-size b) 1))
    (return-from merge-contexts (merge-singletons a b root-is-wildcard merge-cache)))
  (when root-is-wildcard
    (when (empty-context-p a) (return-from merge-contexts a))
    (when (empty-context-p b) (return-from merge-contexts b)))
  ;; Indexed access handles singleton/array inputs without Java's temporary
  ;; singleton-to-array wrappers.
  (merge-arrays a b root-is-wildcard merge-cache))

(defun context-paths (context)
  "Enumerate paths for differential tests/debugging, never for prediction."
  (if (empty-context-p context) (list nil)
      (loop for i fixnum below (context-size context)
            for state = (context-return-state context i)
            for parent = (context-parent context i)
            append (if (= state +empty-return-state+) (list nil)
                       (mapcar (lambda (tail) (cons state tail)) (context-paths parent))))))
