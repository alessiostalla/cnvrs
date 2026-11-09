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
(defstruct (array-prediction-context
             (:include prediction-context)
             (:constructor %array-context (return-states parents hash)) (:copier nil))
  (return-states #() :type simple-vector :read-only t)
  (parents #() :type simple-vector :read-only t))
(declaim (inline context-size context-return-state context-parent context-hash
                 empty-context-p empty-prediction-context))
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
     (the (unsigned-byte 32) (aref (array-prediction-context-return-states context) index)))))
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
    (array-prediction-context (array-prediction-context-return-states context))))
(defun context-parents (context)
  (etypecase context
    (singleton-prediction-context (vector (singleton-prediction-context-parent context)))
    (array-prediction-context (array-prediction-context-parents context))))
(defun context-hash (context) (if context (prediction-context-hash context) 0))
(defparameter *empty-prediction-context*
  (%singleton-context nil +empty-return-state+ (murmur-finish 1 0)))
(defun empty-prediction-context () *empty-prediction-context*)
(defun empty-context-p (context) (eq context *empty-prediction-context*))
(defun context-has-empty-path-p (context)
  (= (context-return-state context (1- (context-size context))) +empty-return-state+))
(defun context-equal (a b)
  (or (eq a b)
      (and a b (= (context-hash a) (context-hash b))
           (= (context-size a) (context-size b))
           (loop for i fixnum below (context-size a)
                 always (and (= (context-return-state a i) (context-return-state b i))
                             (context-equal (context-parent a i) (context-parent b i)))))))
(defun context-node (states parents)
  (declare (type simple-vector states parents))
  (let ((hash 1))
    (declare (type (unsigned-byte 32) hash))
    (loop for parent across parents do
      (setf hash (murmur-update hash (context-hash parent))))
    (loop for state across states do (setf hash (murmur-update hash (the (unsigned-byte 32) state))))
    (%array-context states parents (murmur-finish hash (* 2 (length states))))))
(defun singleton-context (parent return-state)
  (declare (type (unsigned-byte 32) return-state))
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
  (find context (gethash (context-hash context) cache) :test #'context-equal))
(defun context-cache-add (cache context)
  (or (context-cache-get cache context)
      (progn (push context (gethash (context-hash context) cache)) context)))
(defun cached-context (context cache &optional (visited (make-hash-table :test 'eq)))
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
  (declare (ignore wildcard))
  (when cache
    (loop for (x y result) in
          (gethash (logxor (context-hash a) (context-hash b)) cache)
          when (or (and (context-equal x a) (context-equal y b))
                   (and (context-equal x b) (context-equal y a)))
            return result)))
(defun merge-cache-put (cache a b wildcard result)
  (declare (ignore wildcard))
  (when cache
    (push (list a b result)
          (gethash (logxor (context-hash a) (context-hash b)) cache)))
  result)

(defun merge-root (a b root-is-wildcard)
  (if root-is-wildcard
      (cond ((empty-context-p a) a) ((empty-context-p b) b))
      (cond ((and (empty-context-p a) (empty-context-p b)) (empty-prediction-context))
            ((empty-context-p a)
             (context-node (vector (context-return-state b 0) +empty-return-state+)
                           (vector (context-parent b 0) nil)))
            ((empty-context-p b)
             (context-node (vector (context-return-state a 0) +empty-return-state+)
                           (vector (context-parent a 0) nil))))))
(defun merge-singletons (a b root-is-wildcard merge-cache)
  (let ((previous (merge-cache-get merge-cache a b root-is-wildcard)))
    (when previous (return-from merge-singletons previous)))
  (let ((root (merge-root a b root-is-wildcard)))
    (when root (return-from merge-singletons (merge-cache-put merge-cache a b root-is-wildcard root))))
  (let ((ar (the (unsigned-byte 32) (context-return-state a 0)))
        (br (the (unsigned-byte 32) (context-return-state b 0)))
        (ap (context-parent a 0)) (bp (context-parent b 0)))
    (if (= ar br)
        (let ((parent (merge-contexts ap bp root-is-wildcard merge-cache)))
          (cond ((eq parent ap) a) ((eq parent bp) b)
                (t (merge-cache-put merge-cache a b root-is-wildcard (singleton-context parent ar)))))
        (let ((single-parent (and ap (context-equal ap bp) ap)))
          (merge-cache-put
           merge-cache a b root-is-wildcard
           (if (< ar br)
               (context-node (vector ar br) (if single-parent (vector single-parent single-parent) (vector ap bp)))
               (context-node (vector br ar) (if single-parent (vector single-parent single-parent) (vector bp ap)))))))))
(defun combine-common-parents (parents)
  (let ((unique (make-context-cache)))
    (loop for parent across parents when parent do (context-cache-add unique parent))
    (loop for parent across parents for i from 0 when parent do
      (setf (aref parents i) (context-cache-get unique parent))))
  parents)
(defun merge-arrays (a b root-is-wildcard merge-cache)
  (let ((previous (merge-cache-get merge-cache a b root-is-wildcard)))
    (when previous (return-from merge-arrays previous)))
  (let ((i 0) (j 0) (states nil) (parents nil)
        (as (context-size a)) (bs (context-size b)))
    (declare (type fixnum i j))
    (loop while (and (< i as) (< j bs)) do
      (cond ((= (the (unsigned-byte 32) (context-return-state a i)) (the (unsigned-byte 32) (context-return-state b j)))
             (let* ((payload (context-return-state a i)) (x (context-parent a i)) (y (context-parent b j))
                    (both-empty (and (= payload +empty-return-state+) (null x) (null y)))
                    (same-parent (and x y (context-equal x y))))
               (push payload states)
               (push (if (or both-empty same-parent) x
                         (merge-contexts x y root-is-wildcard merge-cache)) parents))
             (incf i) (incf j))
            ((< (the (unsigned-byte 32) (context-return-state a i)) (the (unsigned-byte 32) (context-return-state b j)))
             (push (context-return-state a i) states) (push (context-parent a i) parents) (incf i))
            (t (push (context-return-state b j) states) (push (context-parent b j) parents) (incf j))))
    (loop while (< i as) do
      (push (context-return-state a i) states) (push (context-parent a i) parents) (incf i))
    (loop while (< j bs) do
      (push (context-return-state b j) states) (push (context-parent b j) parents) (incf j))
    (let* ((states (coerce (nreverse states) 'vector))
           (parents (coerce (nreverse parents) 'vector)))
      (when (= (length states) 1)
        (return-from merge-arrays
          (merge-cache-put merge-cache a b root-is-wildcard
                           (singleton-context (aref parents 0) (aref states 0)))))
      (let ((merged (context-node states parents)))
        (cond ((context-equal merged a) (setf merged a))
              ((context-equal merged b) (setf merged b))
              (t (combine-common-parents parents)))
        (merge-cache-put merge-cache a b root-is-wildcard merged)))))
(defun merge-contexts (a b root-is-wildcard &optional merge-cache)
  "PredictionContext.merge, retaining Java's singleton/root/array dispatch."
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
