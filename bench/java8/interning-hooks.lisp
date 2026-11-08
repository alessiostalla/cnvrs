(defpackage #:cnvrs/java8-interning
  (:use #:cl)
  (:export #:install #:*metrics* #:make-metrics #:metrics-arenas
           #:metrics-contexts #:metrics-peak-contexts #:metrics-peak-stacks
           #:metrics-keys #:metrics-closures #:live-arenas))
(in-package #:cnvrs/java8-interning)

(defstruct arena
  (by-stack (make-hash-table :test 'eq))
  (by-pair (make-hash-table :test 'equal))
  (next-id 0 :type fixnum))
(defstruct metrics
  (arenas 0) (contexts 0) (peak-contexts 0) (peak-stacks 0)
  (keys 0) (closures 0) weak-arenas)
(defvar *metrics* nil)
(defvar *arena* nil)
(defvar *prediction-active* nil)
(defvar *scope* nil)

(defun new-arena ()
  (let ((arena (make-arena)))
    (when *metrics*
      (incf (metrics-arenas *metrics*))
      (push (sb-ext:make-weak-pointer arena) (metrics-weak-arenas *metrics*)))
    arena))

(defun finish-arena (arena)
  (when (and arena *metrics*)
    (incf (metrics-contexts *metrics*) (arena-next-id arena))
    (setf (metrics-peak-contexts *metrics*)
          (max (metrics-peak-contexts *metrics*) (arena-next-id arena))
          (metrics-peak-stacks *metrics*)
          (max (metrics-peak-stacks *metrics*)
               (hash-table-count (arena-by-stack arena))))))

(defun live-arenas (metrics)
  (count-if #'sb-ext:weak-pointer-value (metrics-weak-arenas metrics)))

(defun stack-id (stack arena)
  (declare (type list stack) (type arena arena))
  (if (null stack) 0
      (or (gethash stack (arena-by-stack arena))
          (setf (gethash stack (arena-by-stack arena))
                (let ((pair (cons (car stack) (stack-id (cdr stack) arena))))
                  (or (gethash pair (arena-by-pair arena))
                      (setf (gethash pair (arena-by-pair arena))
                            (incf (arena-next-id arena)))))))))

(defmacro with-prediction-scope (&body body)
  `(if *prediction-active*
       (progn ,@body)
       (let ((*prediction-active* t) (*arena* nil))
         (unwind-protect (progn ,@body)
           (finish-arena *arena*)))))

(defun install (scope)
  "Install exactly once in a fresh process; production source is unchanged."
  (unless (member scope '(:closure :prediction))
    (error "Unknown interning scope ~S" scope))
  (when *scope* (error "Interning hooks are already installed"))
  (setf *scope* scope)
  (let ((old (symbol-function 'cnvrs::configuration-key)))
    (setf (symbol-function 'cnvrs::configuration-key)
          (lambda (configuration)
            (when *metrics* (incf (metrics-keys *metrics*)))
            (if *arena*
                (list (cnvrs::configuration-state configuration)
                      (stack-id (cnvrs::configuration-stack configuration) *arena*)
                      (cnvrs::configuration-alternative configuration))
                (funcall old configuration)))))
  ;; Override the production closure-local factory for this comparison, so
  ;; only the chosen experimental arena is allocated and supplies stack IDs.
  (setf (symbol-function 'cnvrs::make-closure-key-function)
        (lambda ()
          (if cnvrs::*eager-lookahead-work-left*
              #'cnvrs::eager-configuration-key #'cnvrs::configuration-key)))
  (let ((old (symbol-function 'cnvrs::closure)))
    (setf (symbol-function 'cnvrs::closure)
          (lambda (grammar seeds)
            (when *metrics* (incf (metrics-closures *metrics*)))
            (if (and (eq *scope* :prediction) *prediction-active*)
                (progn
                  (unless *arena* (setf *arena* (new-arena)))
                  (funcall old grammar seeds))
                (let ((*arena* (new-arena)))
                  (unwind-protect (funcall old grammar seeds)
                    (finish-arena *arena*)))))))
  ;; The outermost decision shares one lazily created arena through contextual
  ;; specialization, SLL, and full-context retry. Direct lower-level entry points
  ;; establish the same scope if there is no surrounding compiled decision.
  (let ((old (symbol-function 'cnvrs::compiled-choice-index)))
    (setf (symbol-function 'cnvrs::compiled-choice-index)
          (lambda (grammar id stack context input position)
            (with-prediction-scope
              (funcall old grammar id stack context input position)))))
  (let ((old (symbol-function 'cnvrs::predict)))
    (setf (symbol-function 'cnvrs::predict)
          (lambda (grammar id stack input position)
            (with-prediction-scope
              (funcall old grammar id stack input position)))))
  (let ((old (symbol-function 'cnvrs::predict-full-context)))
    (setf (symbol-function 'cnvrs::predict-full-context)
          (lambda (grammar id stack input position)
            (with-prediction-scope
              (funcall old grammar id stack input position)))))
  (let ((old (symbol-function 'cnvrs::contextual-choice)))
    (setf (symbol-function 'cnvrs::contextual-choice)
          (lambda (grammar id stack)
            (with-prediction-scope
              (funcall old grammar id stack))))))
