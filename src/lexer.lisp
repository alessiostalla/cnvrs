(in-package #:cnvrs)

(defstruct compiled-lexer states mode-starts kinds skips channels
  push-modes pop-modes set-modes cache-backend cache function matcher)

(define-condition lexical-error (error)
  ((position :initarg :position :reader lexical-error-position)
   (character :initarg :character :reader lexical-error-character))
  (:report (lambda (condition stream)
             (format stream "No lexer rule matches ~S at character ~D"
                     (lexical-error-character condition)
                     (lexical-error-position condition)))))

(define-condition lexer-mode-error (lexical-error)
  ((mode :initarg :mode :reader lexer-mode-error-mode))
  (:report (lambda (condition stream)
             (format stream "Cannot pop lexer mode ~S at character ~D: mode stack is empty"
                     (lexer-mode-error-mode condition)
                     (lexical-error-position condition)))))

(defstruct lx-state (edges nil) accept)
(defstruct lx-edge kind target value)
(defstruct lx-dfa-state active best-rule edges
  (lock (bt:make-lock "CNVRS lexer DFA state")))

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
                 ((string= name "ONE-OF") :one-of)
                 ((string= name "NOT-ONE-OF") :not-one-of)
                 ((string= name "ANY") :any))))
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
         (grammar-fail "ONE-OF requires a nonempty string: ~S" form)))
      (:not-one-of
       (unless (and (= (length form) 2)
                    (or (and (stringp (second form))
                             (plusp (length (second form))))
                        (and (consp (second form))
                             (every #'characterp (second form)))))
         (grammar-fail "NOT-ONE-OF requires characters: ~S" form)))
      (:any
       (unless (= (length form) 1)
         (grammar-fail "ANY takes no arguments: ~S" form))))))

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
    (:not-one-of (lx-edge states entry :not-one-of exit (second form)))
    (:any (lx-edge states entry :any exit))
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
                             (:one-of (find character (lx-edge-value edge)))
                             (:not-one-of
                              (not (find character (lx-edge-value edge))))
                             (:any t))
                        collect (lx-edge-target edge)))))

(defun lx-best-accept (states active)
  (loop for id in active
        for accept = (lx-state-accept (aref states id))
        when accept collect accept into matches
        finally (return (and matches (apply #'min matches)))))

(defun lx-make-dfa-state (states active)
  (make-lx-dfa-state :active active
                     :best-rule (lx-best-accept states active)))

(defun lx-next-dfa-state (states cache current character locked-p)
  (let ((code (char-code character)))
    (flet ((compute ()
             (cache-get-or-compute
              cache (flat-cache-key code (lx-dfa-state-active current))
              (lambda ()
                (lx-make-dfa-state
                 states (lx-step states
                                 (lx-dfa-state-active current)
                                 character))))))
      (if (< code 128)
          (flet ((ascii-next ()
                   (let ((edges (lx-dfa-state-edges current)))
                     (or (and edges (aref edges code))
                         (let ((next (compute)))
                           (unless edges
                             (setf edges (make-array 128 :initial-element nil)
                                   (lx-dfa-state-edges current) edges))
                           (setf (aref edges code) next))))))
            (if locked-p
                (bt:with-lock-held ((lx-dfa-state-lock current))
                  (ascii-next))
                (ascii-next)))
          (compute)))))

(defun initialize-compiled-lexer (lexer)
  "Bind a compiled lexer's runtime functions to its own transition cache."
  (let ((states (compiled-lexer-states lexer))
        (mode-starts (compiled-lexer-mode-starts lexer))
        (kinds (compiled-lexer-kinds lexer))
        (skips (compiled-lexer-skips lexer))
        (channels (compiled-lexer-channels lexer))
        (push-modes (compiled-lexer-push-modes lexer))
        (pop-modes (compiled-lexer-pop-modes lexer))
        (set-modes (compiled-lexer-set-modes lexer))
        (cache (compiled-lexer-cache lexer))
        (locked-p (typep (compiled-lexer-cache lexer) 'locked-cache)))
    (labels ((match-one (source position mode)
               (declare (type string source) (type fixnum position))
               (let ((dfa (cache-get-or-compute
                           cache mode
                           (lambda ()
                             (lx-make-dfa-state
                              states
                              (lx-closure states
                                          (list (gethash mode mode-starts)))))))
                     (best-end nil) (best-rule nil))
                 (loop for offset from position below (length source) do
                   (setf dfa (lx-next-dfa-state
                              states cache dfa (char source offset) locked-p))
                   (when (null (lx-dfa-state-active dfa)) (return))
                   (let ((rule (lx-dfa-state-best-rule dfa)))
                     (when rule
                       (setf best-end (1+ offset) best-rule rule))))
                 (values (and best-rule (aref kinds best-rule))
                         best-end best-rule))))
      (setf (compiled-lexer-matcher lexer) #'match-one
            (compiled-lexer-function lexer)
            (lambda (source)
              (unless (stringp source)
                (error 'type-error :datum source :expected-type 'string))
              (let ((position 0) (output nil) (mode :default) (mode-stack nil))
                (declare (type fixnum position))
                (loop while (< position (length source)) do
                  (multiple-value-bind (kind best-end best-rule)
                      (match-one source position mode)
                    (unless best-end
                      (error 'lexical-error :position position
                             :character (char source position)))
                    (unless (aref skips best-rule)
                      (push (make-lexeme :kind kind
                                         :text (subseq source position best-end)
                                         :start position :end best-end
                                         :channel (aref channels best-rule))
                            output))
                    (cond ((aref push-modes best-rule)
                           (push mode mode-stack)
                           (setf mode (aref push-modes best-rule)))
                          ((aref pop-modes best-rule)
                           (unless mode-stack
                             (error 'lexer-mode-error :position position
                                    :character (char source position) :mode mode))
                           (setf mode (pop mode-stack)))
                          ((aref set-modes best-rule)
                           (setf mode (aref set-modes best-rule))))
                    (setf position best-end)))
                (coerce (nreverse output) 'vector)))))
    lexer))

(defun compile-lexer (definitions &key (cache-backend :hash-table))
  "Compile Lisp-form lexer rules into an inspectable lexer object.
Rules are (kind expression &key skip channel mode push-mode pop-mode set-mode).
MODE selects the active mode for a rule, defaulting to :DEFAULT. A matched
rule may change modes, including when it is skipped. The longest match wins;
ties use rule order among rules in the current mode. The second return value
is a matcher taking (source position mode), returning kind, end, and rule
index for one token without consuming the rest of the source.
CACHE-BACKEND selects :FSET, :HASH-TABLE, a custom backend, or
(:LOCKED backend). The default is :HASH-TABLE."
  (unless (and (listp definitions) definitions)
    (grammar-fail "Expected a nonempty list of lexer rules"))
  (let ((patterns (make-hash-table :test 'eq))
        (states (make-array 0 :adjustable t :fill-pointer 0))
        (mode-starts (make-hash-table :test 'eq))
        (kinds nil)
        (skips nil)
        (channels nil)
        (push-modes nil)
        (pop-modes nil)
        (set-modes nil))
    (dolist (definition definitions)
      (unless (and (consp definition)
                   (>= (length definition) 2)
                   (evenp (length definition))
                   (symbolp (first definition))
                   (loop with seen = nil
                         for (key value) on (cddr definition) by #'cddr
                         always (and (member key '(:skip :channel :mode
                                                   :push-mode :pop-mode
                                                   :set-mode))
                                     (not (member key seen))
                                     (prog1
                                         (case key
                                           ((:skip :pop-mode)
                                            (member value '(nil t)))
                                           (otherwise
                                            (and (symbolp value) value)))
                                       (push key seen)))))
        (grammar-fail "Invalid lexer rule or options: ~S"
                      definition))
      (let* ((options (cddr definition))
             (actions (count-if (lambda (key) (plist-key-p options key))
                                '(:push-mode :pop-mode :set-mode))))
        (when (> actions 1)
          (grammar-fail "Lexer rule ~S has more than one mode action"
                        (first definition)))
        (when (and (plist-key-p options :pop-mode)
                   (not (eq (getf options :pop-mode) t)))
          (grammar-fail ":POP-MODE must be T in lexer rule ~S"
                        (first definition))))
      (when (gethash (first definition) patterns)
        (grammar-fail "Duplicate lexer rule ~S" (first definition)))
      (setf (gethash (first definition) patterns) (second definition))
      (let ((mode (getf (cddr definition) :mode :default)))
        (unless (gethash mode mode-starts)
          (setf (gethash mode mode-starts) (lx-new-state states)))))
    (unless (gethash :default mode-starts)
      (grammar-fail "A lexer needs at least one rule in :DEFAULT mode"))
    (dolist (definition definitions)
      (lx-validate (second definition) patterns (list (first definition)))
      (dolist (key '(:push-mode :set-mode))
        (when (and (plist-key-p (cddr definition) key)
                   (not (gethash (getf (cddr definition) key) mode-starts)))
          (grammar-fail "Lexer rule ~S targets undefined mode ~S"
                        (first definition) (getf (cddr definition) key)))))
    (loop for definition in definitions for index from 0 do
      (let ((entry (lx-new-state states)) (exit (lx-new-state states)))
        (lx-edge states (gethash (getf (cddr definition) :mode :default)
                                 mode-starts)
                 :epsilon entry)
        (lx-compile (second definition) patterns states entry exit)
        (setf (lx-state-accept (aref states exit)) index)
        (push (first definition) kinds)
        (push (getf (cddr definition) :skip) skips)
        (push (getf (cddr definition) :channel :default) channels)
        (push (getf (cddr definition) :push-mode) push-modes)
        (push (getf (cddr definition) :pop-mode) pop-modes)
        (push (getf (cddr definition) :set-mode) set-modes)))
    (setf kinds (coerce (nreverse kinds) 'vector)
          skips (coerce (nreverse skips) 'vector)
          channels (coerce (nreverse channels) 'vector)
          push-modes (coerce (nreverse push-modes) 'vector)
          pop-modes (coerce (nreverse pop-modes) 'vector)
          set-modes (coerce (nreverse set-modes) 'vector))
    (maphash (lambda (mode start)
               (declare (ignore mode))
               (when (lx-best-accept states (lx-closure states (list start)))
                 (grammar-fail "Lexer rules must consume at least one character")))
             mode-starts)
    (let ((lexer (make-compiled-lexer
                  :states states :mode-starts mode-starts :kinds kinds
                  :skips skips :channels channels :push-modes push-modes
                  :pop-modes pop-modes :set-modes set-modes
                  :cache-backend cache-backend :cache (make-cache cache-backend))))
      (initialize-compiled-lexer lexer)
      (values lexer (compiled-lexer-matcher lexer)))))
