;;; Lisp token-source adaptation of ANTLR Java 4.13.2 Lexer.nextToken.
(in-package #:cnvrs)
(declaim (optimize (speed 3) (compilation-speed 1) (safety 1) (debug 0) (space 0)))
(defstruct (lexer-state (:constructor %make-lexer-state)) lexer (source "" :type string)
  (position 0 :type fixnum) (line 1 :type fixnum) (column 0 :type fixnum)
  (start 0 :type fixnum) (start-line 1 :type fixnum) (start-column 0 :type fixnum)
  (mode :default) mode-stack type (channel :default) text hit-eof)
(defvar *lexer-state* nil)
(defun lexer-simulator (lexer)
  "Return the compiled lexer ATN simulator for inspection."
  (compiled-lexer-runtime (ensure-compiled lexer)))
(defun make-lexer-state (lexer source)
  (unless (stringp source) (error 'type-error :datum source :expected-type 'string))
  (let ((compiled (ensure-compiled lexer)))
    (when (parser-p compiled) (setf compiled (ensure-compiled (parser-lexer compiled))))
    (unless (compiled-lexer-p compiled) (grammar-fail "Expected a compiled lexer"))
    (%make-lexer-state :lexer compiled :source source)))
(defun lexer-execute-actions (state actions match-start end)
  (dolist (entry actions)
    (let* ((indexed (eq (first entry) :indexed))
           (action (if indexed (third entry) entry))
           (position (if indexed (+ match-start (second entry)) end)))
      (case (first action)
        (:skip (setf (lexer-state-type state) -3))
        (:more (setf (lexer-state-type state) -2))
        (:type (setf (lexer-state-type state) (second action)))
        (:channel (setf (lexer-state-channel state) (second action)))
        (:mode (setf (lexer-state-mode state) (second action)))
        (:push-mode (push (lexer-state-mode state) (lexer-state-mode-stack state))
                    (setf (lexer-state-mode state) (second action)))
        (:pop-mode
         (unless (lexer-state-mode-stack state)
           (error 'lexer-mode-error :position position
                  :character (when (< position (length (lexer-state-source state)))
                               (char (lexer-state-source state) position)) :mode (lexer-state-mode state)))
         (setf (lexer-state-mode state) (pop (lexer-state-mode-stack state))))
        (:custom
         (let ((saved (lexer-state-position state)))
           (unwind-protect
                (let ((*lexer-state* state))
                  (setf (lexer-state-position state) position)
                  (semantic-call (gethash (list :action (second action) (third action))
                                         (compiled-lexer-predicates (lexer-state-lexer state)))
                                 (lexer-state-source state) position))
             (setf (lexer-state-position state) saved))))))))
(defun lexer-match-state (state)
  (let* ((lexer (lexer-state-lexer state))
         (sim (compiled-lexer-runtime lexer))
         (mode (position (lexer-state-mode state) (compiled-lexer-modes lexer)))
         (source (lexer-state-source state)))
    (unless mode (grammar-fail "Unknown lexer mode ~S" (lexer-state-mode state)))
    (multiple-value-bind (kind end line column)
        (cnvrs/antlr-runtime::lexer-match
         sim source (lexer-state-position state) mode
         :line (lexer-state-line state) :column (lexer-state-column state)
         :predicate
         (lambda (label at line column)
           (let ((old-position (lexer-state-position state)) (old-line (lexer-state-line state))
                 (old-column (lexer-state-column state)) (*lexer-state* state))
             (unwind-protect
                  (progn (setf (lexer-state-position state) at (lexer-state-line state) line
                               (lexer-state-column state) column)
                         (semantic-call (gethash (subseq label 0 2) (compiled-lexer-predicates lexer)) source at))
               (setf (lexer-state-position state) old-position (lexer-state-line state) old-line
                     (lexer-state-column state) old-column)))))
        (setf (lexer-state-position state) end (lexer-state-line state) line (lexer-state-column state) column)
        ;; The Java executor runs after rewinding to the accepted position.
        ;; Extract it through the simulator's ACTION callback below in match-one.
        (let ((start (cnvrs/antlr-runtime::lexer-dfa-start
                      (aref (cnvrs/antlr-runtime::lexer-simulator-dfas sim) mode))))
          (when start (cache-get-or-compute (compiled-lexer-cache lexer) (lexer-state-mode state) (lambda () start))))
        (values kind end))))

(defun lexer-match-with-actions (state)
  (let ((executor nil) (match-start (lexer-state-position state)))
    ;; Bind the acceptance callback independently from predicate evaluation so
    ;; effects occur only after the simulator has chosen the winning rule.
    (let ((cnvrs/antlr-runtime::*lexer-accept-executor* (lambda (actions start end)
                                                        (declare (ignore start end)) (setf executor actions))))
      (multiple-value-bind (kind end) (lexer-match-state state)
        (lexer-execute-actions state executor match-start end)
        (values kind end)))))
(defun lexer-next-token (state &key recover)
  "Return the next lexeme, including an EOF lexeme. Errors offer SKIP-CHARACTER.
RECOVER selects Java's default consume-and-continue recovery; the default signals."
  (let ((source (lexer-state-source state)))
    (block next-token
      (loop
        (when (lexer-state-hit-eof state)
          (return-from next-token
            (make-lexeme :kind +end-of-input+ :text "<EOF>" :start (lexer-state-position state)
                         :end (lexer-state-position state) :line (lexer-state-line state) :column (lexer-state-column state))))
        (setf (lexer-state-start state) (lexer-state-position state)
              (lexer-state-start-line state) (lexer-state-line state)
              (lexer-state-start-column state) (lexer-state-column state)
              (lexer-state-channel state) :default (lexer-state-text state) nil)
        (loop
          (setf (lexer-state-type state) nil)
          (let ((kind
                  (handler-case
                      (nth-value 0 (lexer-match-with-actions state))
                    (cnvrs/antlr-runtime::lexer-no-viable-alt (failure)
                      (let* ((at (cnvrs/antlr-runtime::lexer-error-position failure))
                             (condition (make-condition 'lexical-error
                                         :position (lexer-state-start state)
                                         :failed-position at
                                         :line (lexer-state-start-line state) :column (lexer-state-start-column state)
                                         :character (when (< (lexer-state-start state) (length source))
                                                      (char source (lexer-state-start state))))))
                        (restart-case
                            (if recover (signal condition) (error condition))
                          (skip-character () :report "Discard the failed token prefix and one character, then continue lexing."))
                        (setf (lexer-state-position state) at
                              (lexer-state-line state) (cnvrs/antlr-runtime::lexer-error-line failure)
                              (lexer-state-column state) (cnvrs/antlr-runtime::lexer-error-column failure))
                        (when (< at (length source))
                          (if (char= (char source at) #\Newline)
                              (setf (lexer-state-line state) (1+ (lexer-state-line state)) (lexer-state-column state) 0)
                              (incf (lexer-state-column state)))
                          (incf (lexer-state-position state)))
                        -3)))))
            (when (>= (lexer-state-position state) (length source)) (setf (lexer-state-hit-eof state) t))
            (unless (lexer-state-type state) (setf (lexer-state-type state) kind))
            (when (eql (lexer-state-type state) -3) (return))
            (unless (eql (lexer-state-type state) -2)
              (return-from next-token
                (let ((kind (if (eql (lexer-state-type state) -1) +end-of-input+ (lexer-state-type state))))
                  (if (or (lexer-state-text state)
                          (= (lexer-state-start state) (lexer-state-position state) (length source)))
                      (make-lexeme :kind kind :text (or (lexer-state-text state) "<EOF>") :start (lexer-state-start state)
                                   :end (lexer-state-position state) :channel (lexer-state-channel state)
                                   :line (lexer-state-start-line state) :column (lexer-state-start-column state))
                      (make-lexeme :kind kind :source source :start (lexer-state-start state)
                                   :end (lexer-state-position state) :channel (lexer-state-channel state)
                                   :line (lexer-state-start-line state) :column (lexer-state-start-column state))))))))))))
(defun initialize-compiled-lexer (lexer)
  (setf (compiled-lexer-runtime lexer) (cnvrs/antlr-runtime::new-lexer-atn-simulator (lexer-runtime-atn lexer)))
  (setf (compiled-lexer-matcher lexer)
        (lambda (source position mode)
          (let ((state (%make-lexer-state :lexer lexer :source source :position position :mode mode)))
            (handler-case
                (multiple-value-bind (kind end) (lexer-match-with-actions state)
                  (values kind end (position kind (compiled-lexer-kinds lexer))))
              (cnvrs/antlr-runtime::lexer-no-viable-alt () (values nil nil nil))))))
  (setf (compiled-lexer-function lexer)
        (lambda (source &key recover)
          (let ((state (make-lexer-state lexer source)) (tokens nil))
            (loop for token = (lexer-next-token state :recover recover)
                  until (eq (lexeme-kind token) +end-of-input+) do (push token tokens))
            (coerce (nreverse tokens) 'vector))))
  (values lexer (compiled-lexer-matcher lexer)))
(defun clear-lexer-cache (lexer)
  (cache-clear (compiled-lexer-cache lexer))
  (cnvrs/antlr-runtime::lexer-clear-dfa (compiled-lexer-runtime lexer)))
