(in-package #:cnvrs)

;; Backends can be added by specializing MAKE-CACHE on a new backend name
;; and implementing these three operations for the returned cache object.
(defgeneric make-cache (backend))
(defgeneric cache-get-or-compute (cache key thunk))
(defgeneric cache-clear (cache))
(defgeneric cache-count (cache))

(defun flat-cache-key (head tail)
  "Make a structural cache key from HEAD and a list of integer IDs."
  (declare (type fixnum head) (type list tail))
  (let ((key (make-array (1+ (length tail)) :element-type 'fixnum)))
    (setf (aref key 0) head)
    (loop for value in tail
          for index from 1
          do (setf (aref key index) value))
    key))

(defun parser-context-key (head stack)
  "Use a small pair for shallow stacks and a flat array for deeper ones."
  (if (null (cdr stack))
      (cons head (first stack))
      (flat-cache-key head stack)))

(defun flat-cache-key-p (key)
  (typep key '(simple-array fixnum (*))))

(defstruct hash-cache
  (table (make-hash-table :test 'equal))
  flat-table)
(defmethod make-cache ((backend (eql :hash-table)))
  (make-hash-cache))
(defmethod cache-get-or-compute ((cache hash-cache) key thunk)
  (let ((table (if (flat-cache-key-p key)
                   (or (hash-cache-flat-table cache)
                       (setf (hash-cache-flat-table cache)
                             (make-hash-table :test 'equalp)))
                   (hash-cache-table cache))))
    (multiple-value-bind (value present) (gethash key table)
      (if present value
          (setf (gethash key table) (funcall thunk))))))
(defmethod cache-clear ((cache hash-cache))
  (clrhash (hash-cache-table cache))
  (when (hash-cache-flat-table cache)
    (clrhash (hash-cache-flat-table cache)))
  cache)
(defmethod cache-count ((cache hash-cache))
  (+ (hash-table-count (hash-cache-table cache))
     (if (hash-cache-flat-table cache)
         (hash-table-count (hash-cache-flat-table cache))
         0)))

(defun cache-key-compare (a b)
  "Compare common cache key components without FSET's generic dispatch."
  (let ((a (fset2:unwrap-equivalent-node a))
        (b (fset2:unwrap-equivalent-node b)))
    (cond ((eql a b) :equal)
          ((and (typep a 'fixnum) (typep b 'fixnum))
           (if (< a b) :less :greater))
          ((and (characterp a) (characterp b))
           (if (char< a b) :less :greater))
          ((and (consp a) (consp b))
           (do ((left a (cdr left))
                (right b (cdr right))
                (default :equal))
               ((or (atom left) (atom right))
                (if (eql left right) default
                    (let ((comparison (cache-key-compare left right)))
                      (if (eq comparison :equal) default comparison))))
             (let ((comparison (cache-key-compare (car left) (car right))))
               (case comparison
                 ((:less :greater) (return comparison))
                 (:unequal (setf default :unequal))))))
          (t (fset:compare a b)))))

(defun flat-cache-key-compare (a b)
  "Compare uniform fixnum vectors by their contents."
  (loop for index below (min (length a) (length b))
        for left = (aref a index)
        for right = (aref b index)
        unless (= left right)
          do (return-from flat-cache-key-compare
               (if (< left right) :less :greater)))
  (cond ((< (length a) (length b)) :less)
        ((> (length a) (length b)) :greater)
        (t :equal)))

(defstruct fset-cache
  (map (fset:empty-wb-map nil 'cache-key-compare))
  (flat-map (fset:empty-wb-map nil 'flat-cache-key-compare)))
(defmethod make-cache ((backend (eql :fset)))
  (make-fset-cache))
(defmethod cache-get-or-compute ((cache fset-cache) key thunk)
  (let ((flat-p (flat-cache-key-p key)))
    (multiple-value-bind (value present)
        (fset:lookup (if flat-p (fset-cache-flat-map cache)
                         (fset-cache-map cache)) key)
      (if present value
          (let ((value (funcall thunk)))
            (if flat-p
                (setf (fset-cache-flat-map cache)
                      (fset:with (fset-cache-flat-map cache) key value))
                (setf (fset-cache-map cache)
                      (fset:with (fset-cache-map cache) key value)))
            value)))))
(defmethod cache-clear ((cache fset-cache))
  (setf (fset-cache-map cache)
        (fset:empty-wb-map nil 'cache-key-compare)
        (fset-cache-flat-map cache)
        (fset:empty-wb-map nil 'flat-cache-key-compare))
  cache)
(defmethod cache-count ((cache fset-cache))
  (+ (fset:size (fset-cache-map cache))
     (fset:size (fset-cache-flat-map cache))))

(defstruct locked-cache inner (lock (bt:make-lock "CNVRS cache")))
(defmethod make-cache ((backend cons))
  (unless (and (eq (first backend) :locked)
               (consp (rest backend))
               (null (cddr backend)))
    (error "Expected (:LOCKED backend), got ~S" backend))
  (make-locked-cache :inner (make-cache (second backend))))
(defmethod cache-get-or-compute ((cache locked-cache) key thunk)
  (bt:with-lock-held ((locked-cache-lock cache))
    (cache-get-or-compute (locked-cache-inner cache) key thunk)))
(defmethod cache-clear ((cache locked-cache))
  (bt:with-lock-held ((locked-cache-lock cache))
    (cache-clear (locked-cache-inner cache)))
  cache)
(defmethod cache-count ((cache locked-cache))
  (bt:with-lock-held ((locked-cache-lock cache))
    (cache-count (locked-cache-inner cache))))

