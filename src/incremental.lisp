(in-package #:cnvrs)

;; Incremental sessions use the explicit-stack executor. Batch parsers retain
;; their native compiled rule functions and unobserved prediction loops.
(defstruct (incremental-parser (:constructor %make-incremental-parser))
  grammar rule channels rules tokens tree checkpoints (restart-position 0))

(defun validate-checkpoint-grammar (grammar &optional (rules (parser-checkpoint-rules grammar)))
  "Check sufficient safety conditions; lookahead dependencies are checked per edit."
  (unless (eq (parser-tree-builder grammar) :node)
    (grammar-fail "Checkpoint parsing requires the standard :NODE tree builder"))
  (when (parser-semantic-rules grammar)
    (grammar-fail "Checkpoint parsing does not support parser actions or predicates"))
  (dolist (rule rules)
    (unless (gethash rule (parser-starts grammar))
      (grammar-fail "Unknown checkpoint rule ~S" rule)))
  (let ((lexer (parser-lexer grammar)))
    (when lexer
      (when (parser-definition-p lexer) (setf lexer (ensure-compiled lexer)))
      (unless (compiled-lexer-p lexer)
        (grammar-fail "Checkpoint parsing requires a compiled lexer or token input"))
      (when (plusp (hash-table-count (compiled-lexer-predicates lexer)))
        (grammar-fail "Checkpoint parsing does not support lexer actions or predicates"))))
  grammar)

(defun make-incremental-parser (grammar &key
                                        (checkpoint-rules nil rules-supplied-p)
                                        rule (channels '(:default)))
  "Create an incremental session. Rules default to grammar :CHECKPOINT declarations.
PARSE-INCREMENTALLY accepts successive complete input revisions. Inputs, returned
trees, and the grammar must not be mutated while retained by the session."
  (let* ((compiled (ensure-compiled grammar))
         (rules (if rules-supplied-p checkpoint-rules (and (parser-p compiled)
                                                         (parser-checkpoint-rules compiled)))))
    (unless (parser-p compiled) (grammar-fail "Incremental parsing requires a parser"))
    (unless (and (listp rules) rules) (grammar-fail "Declare at least one checkpoint rule"))
    (unless (or (eq channels :all) (listp channels))
      (grammar-fail "Invalid checkpoint token channels ~S" channels))
    (setf rule (or rule (parser-default-rule compiled)))
    (unless (gethash rule (parser-starts compiled)) (grammar-fail "Unknown entry rule ~S" rule))
    (validate-checkpoint-grammar compiled rules)
    (%make-incremental-parser :grammar compiled :rule rule :rules (copy-list rules)
                              :channels (if (listp channels) (copy-list channels) channels))))

(defun copy-checkpoint-frames (frames)
  ;; Incremental execution uses REVERSE when completing nodes, so children and
  ;; open-label spines remain persistent. Sharing also preserves label tail
  ;; identities and avoids quadratic copies of an enclosing class's children.
  (mapcar #'copy-seq frames))

(defun checkpoint-token-types (input table context)
  ;; The explicit executor already knows the logical cursor. Unlike the batch
  ;; adapter, it needs no physical-to-logical hash table for every token in an
  ;; unchanged prefix. Build only the typed vector, once per revision.
  (or (checkpoint-context-prediction-tokens context)
      (setf (checkpoint-context-prediction-tokens context)
            (let ((types (make-array (input-token-count input)))
                  (extra (1+ (hash-table-count table))))
              (loop for physical = (input-start-position input)
                      then (input-next-position input physical)
                    for logical from 0
                    while (< physical (input-size input)) do
                      (setf (aref types logical)
                            (gethash (token-key (input-token input physical)) table extra)))
              types))))

(defun checkpoint-predict (grammar state stack input physical logical context)
  (let* ((state-object (aref (parser-states grammar) state))
         (direct (state-direct-lookahead state-object))
         (cnvrs/runtime::*input-read-limit* (max (checkpoint-context-read-limit context)
                                               (1+ logical))))
    (unwind-protect
         (if direct
             (direct-choice-index grammar direct input physical)
             (destructuring-bind (sim table decisions) (ensure-parser-runtime grammar)
               (cache-get-or-compute (parser-decisions grammar) state
                                     (lambda () (aref (cnvrs/runtime:simulator-decision-dfas sim)
                                                      (gethash state decisions))))
               (let ((types (checkpoint-token-types input table context)))
                 (or (handler-case
                         (1- (cnvrs/runtime::observed-adaptive-predict
                              sim types (gethash state decisions) :position logical
                              :outer-context stack :precedence *prediction-precedence*))
                       (cnvrs/runtime:no-viable-alt () nil))
                     (and (>= physical (input-size input))
                          (state-precedence-decision-p state-object)
                          (state-exit-alternative state-object))))))
      (setf (checkpoint-context-read-limit context) cnvrs/runtime::*input-read-limit*))))

(defun checkpoint-token-equal (left right)
  (if (lexeme-p left)
      (and (lexeme-p right)
           (equal (lexeme-kind left) (lexeme-kind right))
           (equal (lexeme-channel left) (lexeme-channel right))
           (eql (lexeme-start left) (lexeme-start right))
           (eql (lexeme-end left) (lexeme-end right))
           (eql (lexeme-line left) (lexeme-line right))
           (eql (lexeme-column left) (lexeme-column right))
           (equal (lexeme-text left) (lexeme-text right)))
      (and (not (lexeme-p right)) (equal left right))))

(defun parse-incrementally (session input)
  "Parse a complete revision, reusing the valid prefix and reparsing its suffix.
Return the tree and the restart position (a visible-token offset). Lexing is
currently repeated in full. Failed parses leave the previous session intact;
recovery and custom builders are unsupported. Completed prefix nodes retain EQ
identity. Neither the input tokens nor the returned trees may be mutated."
  (let* ((grammar (incremental-parser-grammar session))
         (lexer (parser-lexer grammar))
         ;; Copy source strings so lazy lexemes refer to a stable revision.
         (tokens (coerce (if lexer (lex lexer (if (stringp input) (copy-seq input) input)) input)
                         'simple-vector))
         (previous (incremental-parser-tokens session))
         (channels (incremental-parser-channels session))
         (common (if previous
                     (loop for a across previous for b across tokens
                           while (checkpoint-token-equal a b) count t)
                     0))
         (visible-common (loop for i below common
                               count (or (eq channels :all)
                                         (member (token-channel (aref tokens i)) channels :test #'equal))))
         (saved (find-if (lambda (checkpoint)
                           (and (<= (parse-checkpoint-physical-position checkpoint) common)
                                (<= (parse-checkpoint-read-limit checkpoint) visible-common)))
                         (incremental-parser-checkpoints session))))
    (when (and previous (= common (length previous) (length tokens)))
      (setf (incremental-parser-restart-position session) visible-common)
      (return-from parse-incrementally (values (incremental-parser-tree session) visible-common)))
    (let* ((retained (and saved (member saved (incremental-parser-checkpoints session))))
           (context (make-checkpoint-context
                     :rules (incremental-parser-rules session) :resume saved
                     :checkpoints (copy-list retained)
                     :read-limit (if saved (parse-checkpoint-read-limit saved) 0)))
           (restart (if saved (parse-checkpoint-position saved) 0)))
      (multiple-value-bind (tree recoveries)
          (let ((*checkpoint-context* context))
            (parse grammar tokens :lexer nil :rule (incremental-parser-rule session)
                   :channels channels))
        (when recoveries (grammar-fail "Recovery is unsupported in incremental sessions"))
        ;; Commit only after success. Every checkpoint is reusable on later edits.
        (setf (incremental-parser-tokens session) tokens
              (incremental-parser-tree session) tree
              (incremental-parser-checkpoints session) (checkpoint-context-checkpoints context)
              (incremental-parser-restart-position session) restart)
        (values tree restart)))))
