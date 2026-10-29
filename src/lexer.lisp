(in-package #:cnvrs)

(define-condition lexical-error (error)
  ((position :initarg :position :reader lexical-error-position)
   (character :initarg :character :reader lexical-error-character))
  (:report (lambda (condition stream)
             (format stream "No lexer rule matches ~S at character ~D"
                     (lexical-error-character condition)
                     (lexical-error-position condition)))))

(defstruct lx-state (edges nil) accept)
(defstruct lx-edge kind target value)

(defun lx-new-state (states)
  (vector-push-extend (make-lx-state) states)
  (1- (length states)))

(defun lx-edge (states from kind target &optional value)
  (push (make-lx-edge :kind kind :target target :value value)
        (lx-state-edges (aref states from))))

(defun lx-kind (form)
  (cond ((or (characterp form) (stringp form)) :literal)
        ((symbolp form) :reference)
        ((and (consp form) (symbolp (first form)))
         (let ((name (string-upcase (symbol-name (first form)))))
           (cond ((member name '("AND" "SEQ") :test #'string=) :sequence)
                 ((string= name "OR") :choice)
                 ((string= name "*") :star)
                 ((string= name "+") :plus)
                 ((string= name "?") :optional)
                 ((string= name "RANGE") :range)
                 ((string= name "ONE-OF") :one-of))))
        (t nil)))

(defun lx-validate (form definitions visiting)
  (let ((kind (lx-kind form)))
    (unless kind (grammar-fail "Invalid lexer expression: ~S" form))
    (case kind
      (:reference
       (unless (gethash form definitions)
         (grammar-fail "Undefined lexer rule ~S" form))
       (when (member form visiting)
         (grammar-fail "Recursive lexer rule ~S" form))
       (lx-validate (gethash form definitions) definitions (cons form visiting)))
      ((:star :plus :optional)
       (unless (= (length form) 2)
         (grammar-fail "~A requires one lexer expression: ~S" (first form) form))
       (lx-validate (second form) definitions visiting))
      ((:sequence :choice)
       (when (and (eq kind :choice) (null (rest form)))
         (grammar-fail "OR requires at least one lexer alternative"))
       (mapc (lambda (part) (lx-validate part definitions visiting))
             (rest form)))
      (:range
       (unless (and (= (length form) 3)
                    (characterp (second form)) (characterp (third form))
                    (char<= (second form) (third form)))
         (grammar-fail "RANGE requires ordered character bounds: ~S" form)))
      (:one-of
       (unless (and (= (length form) 2) (stringp (second form))
                    (plusp (length (second form))))
         (grammar-fail "ONE-OF requires a nonempty string: ~S" form))))))

(defun lx-compile (form definitions states entry exit)
  (case (lx-kind form)
    (:reference (lx-compile (gethash form definitions) definitions states entry exit))
    (:literal
     (let ((string (string form)) (current entry))
       (if (zerop (length string))
           (lx-edge states entry :epsilon exit)
           (loop for character across string
                 for index from 0
                 for next = (if (= index (1- (length string)))
                                exit (lx-new-state states))
                 do (lx-edge states current :character next character)
                    (setf current next)))))
    (:range (lx-edge states entry :range exit
                     (cons (second form) (third form))))
    (:one-of (lx-edge states entry :one-of exit (second form)))
    (:sequence
     (let ((parts (rest form)) (current entry))
       (if (null parts)
           (lx-edge states entry :epsilon exit)
           (loop for tail on parts
                 for next = (if (null (rest tail)) exit (lx-new-state states))
                 do (lx-compile (first tail) definitions states current next)
                    (setf current next)))))
    (:choice
     (dolist (part (rest form))
       (lx-compile part definitions states entry exit)))
    (:optional
     (lx-edge states entry :epsilon exit)
     (lx-compile (second form) definitions states entry exit))
    (:star
     (let ((body-start (lx-new-state states))
           (body-end (lx-new-state states)))
       (lx-edge states entry :epsilon exit)
       (lx-edge states entry :epsilon body-start)
       (lx-compile (second form) definitions states body-start body-end)
       (lx-edge states body-end :epsilon body-start)
       (lx-edge states body-end :epsilon exit)))
    (:plus
     (let ((middle (lx-new-state states)))
       (lx-compile (second form) definitions states entry middle)
       (lx-compile (list '* (second form)) definitions states middle exit)))))

(defun lx-closure (states seeds)
  (let ((seen (make-hash-table :test 'eql)) (pending (copy-list seeds))
        (result nil))
    (loop while pending for id = (pop pending) do
      (unless (gethash id seen)
        (setf (gethash id seen) t)
        (push id result)
        (dolist (edge (lx-state-edges (aref states id)))
          (when (eq (lx-edge-kind edge) :epsilon)
            (push (lx-edge-target edge) pending)))))
    result))

(defun lx-step (states active character)
  (lx-closure
   states
   (loop for id in active
         append (loop for edge in (lx-state-edges (aref states id))
                      when (case (lx-edge-kind edge)
                             (:character (char= character (lx-edge-value edge)))
                             (:range (char<= (car (lx-edge-value edge)) character
                                              (cdr (lx-edge-value edge))))
                             (:one-of (find character (lx-edge-value edge))))
                        collect (lx-edge-target edge)))))

(defun lx-best-accept (states active)
  (loop for id in active
        for accept = (lx-state-accept (aref states id))
        when accept collect accept into matches
        finally (return (and matches (apply #'min matches)))))

(defun compile-lexer (definitions)
  "Compile Lisp-form lexer rules into a function from strings to lexeme vectors.
Rules are (kind expression &key skip channel). The longest match wins;
ties use rule order."
  (unless (and (listp definitions) definitions)
    (grammar-fail "Expected a nonempty list of lexer rules"))
  (let ((patterns (make-hash-table :test 'eq))
        (states (make-array 0 :adjustable t :fill-pointer 0))
        (start nil)
        (kinds nil)
        (skips nil)
        (channels nil))
    (dolist (definition definitions)
      (unless (and (consp definition)
                   (>= (length definition) 2)
                   (evenp (length definition))
                   (symbolp (first definition))
                   (loop with seen = nil
                         for (key value) on (cddr definition) by #'cddr
                         always (and (member key '(:skip :channel))
                                     (not (member key seen))
                                     (prog1
                                         (if (eq key :skip)
                                             (member value '(nil t))
                                             (and (symbolp value) value))
                                       (push key seen)))))
        (grammar-fail "Expected (kind expression &key skip channel), got ~S"
                      definition))
      (when (gethash (first definition) patterns)
        (grammar-fail "Duplicate lexer rule ~S" (first definition)))
      (setf (gethash (first definition) patterns) (second definition)))
    (dolist (definition definitions)
      (lx-validate (second definition) patterns (list (first definition))))
    (setf start (lx-new-state states))
    (loop for definition in definitions for index from 0 do
      (let ((entry (lx-new-state states)) (exit (lx-new-state states)))
        (lx-edge states start :epsilon entry)
        (lx-compile (second definition) patterns states entry exit)
        (setf (lx-state-accept (aref states exit)) index)
        (push (first definition) kinds)
        (push (getf (cddr definition) :skip) skips)
        (push (getf (cddr definition) :channel :default) channels)))
    (setf kinds (coerce (nreverse kinds) 'vector)
          skips (coerce (nreverse skips) 'vector)
          channels (coerce (nreverse channels) 'vector))
    (when (lx-best-accept states (lx-closure states (list start)))
      (grammar-fail "Lexer rules must consume at least one character"))
    (lambda (source)
      (unless (stringp source)
        (error 'type-error :datum source :expected-type 'string))
      (let ((position 0) (output nil))
        (loop while (< position (length source)) do
          (let ((active (lx-closure states (list start)))
                (best-end nil) (best-rule nil))
            (loop for offset from position below (length source) do
              (setf active (lx-step states active (char source offset)))
              (when (null active) (return))
              (let ((rule (lx-best-accept states active)))
                (when rule
                  (setf best-end (1+ offset) best-rule rule))))
            (unless best-end
              (error 'lexical-error :position position
                     :character (char source position)))
            (unless (aref skips best-rule)
              (push (make-lexeme :kind (aref kinds best-rule)
                                 :text (subseq source position best-end)
                                 :start position :end best-end
                                 :channel (aref channels best-rule))
                    output))
            (setf position best-end)))
        (coerce (nreverse output) 'vector)))))
