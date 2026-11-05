# CNVRS

CNVRS, the **Contextual Nonterminal Variable-lookahead Recognition System**, is a clean-room Common Lisp implementation of adaptive LL(*) parsing, inspired by the algorithm described by Parr et al. It compiles Lisp grammar forms into an in-memory parser. It does not read grammar text or generate parser source.

See [CNVRS and ANTLR 4/Java: current differences](docs/cnvrs-vs-antlr-java.md) for feature, algorithm, and benchmark comparisons.

## Example

```lisp
(asdf:load-system :cnvrs)

(defparameter *brackets*
  (cnvrs:compile-grammar
   '((document (and #\[ (* item) #\]))
     (item (or #\x document)))))

(defparameter *tree* (cnvrs:parse *brackets* "[x[x]]"))
(cnvrs:node-rule *tree*)      ; => DOCUMENT
(cnvrs:node-children *tree*)  ; => tokens and nested ITEM nodes
```

`compile-grammar` takes a list of `(rule-name expression)` pairs. The first rule is the default entry rule unless `:default-rule` names another. `parse` can start from any parser rule using `:rule`. Expressions resemble Esrap forms:

| Form | Meaning |
| --- | --- |
| `(and a b ...)` or `(seq a b ...)` | Sequence; `(and)` matches empty input |
| `(or a b ...)` | Ordered alternatives; first wins if both match |
| `(* a)`, `(+ a)`, `(? a)` | Zero or more, one or more, optional |
| `(label name a)` | Wrap a match in a node with `node-label` set to `name` |
| `(alt-label name a)` | Set `node-label` on the enclosing rule node when this alternative matches |
| `rule-name` | Reference to a rule |
| `(token value)` | Match a token with `equal` |
| Character, string, number, or keyword | Literal token |

## Defining grammars with macros

`define-parser` declares a grammar in one form. The first form after its name is an optional plist with `:kind`, `:default-rule`, and `:lexer`; the remaining forms are rules. Rules may be written as `(defrule name expression ...)` or simply `(name expression ...)`:

```lisp
(cnvrs:define-parser *assignment* (:kind :combined)
  (cnvrs:defrule assignment (and :let :name :equals value))
  (cnvrs:defrule value :number)
  (cnvrs:defrule :space (+ (one-of " ")) :skip t)
  (cnvrs:defrule :let "let")
  (cnvrs:defrule :name (+ (range #\a #\z)))
  (cnvrs:defrule :equals #\=)
  (cnvrs:defrule :number (+ (range #\0 #\9))))

(cnvrs:parse *assignment* "let x = 42")
(cnvrs:parse *assignment* "42" :rule 'value) ; starts at any named parser rule
```

The incremental style separates the declaration from its rules. `in-parser` selects the definition receiving subsequent top-level `defrule` forms, much like `in-package` selects a package:

```lisp
(cnvrs:define-parser *words* (:kind :lexer))
(cnvrs:in-parser *words*)
(cnvrs:defrule :space (+ (one-of " ")) :skip t)
(cnvrs:defrule :word (+ (range #\a #\z)))

(cnvrs:lex *words* "one two")
```

| Kind | Rules and use |
| --- | --- |
| `:parser` (default) | All rules are parser rules. `parse` accepts token sequences; an optional `:lexer` option attaches an existing lexer function. |
| `:lexer` | All rules are lexer rules. `lex` accepts a source string and returns lexemes. |
| `:combined` | Ordinary symbol names define parser rules; keyword names define lexer rules. Use `:lexer t` on a rule to give a lexer rule an ordinary symbol name. `parse` lexes and parses source strings. |

`:default-rule` only changes the rule used when `parse` is called without `:rule`; otherwise the first parser rule is the default. Every `parse` call may select any parser rule with `:rule`, whether the grammar was built with `compile-grammar` or `define-parser`. Only the selected entry rule must consume the entire input by default, even if its definition does not mention EOF. Calls to that same rule from within other rules have no EOF requirement. Use `:require-eof nil` to accept a prefix and inspect `node-end` for the position reached. This EOF check happens at parse time and does not alter the rule. The older `parse :start` argument remains an alias for `:rule`.

Lexer rules accept `:skip t` and `:channel name`. Rule order still determines ties between equal-length lexer matches. Definitions compile in the current Lisp image on first use, allowing forward references in the incremental style. Adding a rule invalidates the compiled definition. `parse` on a lexer-only grammar signals `grammar-error`; use `lex` instead.

### Semantic predicates and actions

Both parser and lexer expressions accept `(predicate callback)` and `(action callback)` as zero-width elements, including inside sequences, alternatives, and repetitions. `callback` is a Common Lisp function or a non-keyword function name. In `compile-grammar` and `compile-lexer`, function objects can be placed directly in the supplied forms; in quoted `define-parser` and `defrule` forms, use a function name. A callback receives `(input position)`: parser input is the filtered token vector and position is a token offset; lexer input is the source string and position is a character offset. A predicate succeeds on a non-`nil` return value. Actions ignore their return values and run once, in source order, after the winning parse path or lexer rule has been selected. A failed or losing candidate does not run its actions.

```lisp
(defun word-allowed (source position)
  (declare (ignore position))
  (not (find #\! source)))

(defun word-seen (source position)
  (format t "Matched through character ~D in ~S~%" position source))

(cnvrs:compile-lexer
 '((:word (and (predicate word-allowed)
               (+ (range #\a #\z))
               (action word-seen)))))
```

Predicates are reevaluated for each parse or lex call; grammars containing them use an ordered semantic matcher instead of cached DFA prediction. The parser semantic matcher supports `:node`, `:none`, and custom node builders, but error recovery is unavailable for semantic grammars. Semantic callbacks can affect application state, so callers should keep predicates free of side effects. Action callbacks should also avoid changing input used by the active match.

This callback API is not fully equivalent to ANTLR's generated Java parser. CNVRS currently tests predicates while exploring complete candidate paths and runs parser actions after a complete path wins. ANTLR uses predicates on the left edge of an alternative during local prediction, ignores later predicates during that prediction, and executes parser actions at their position after committing to an alternative. Consequently, CNVRS can accept an alternate path after a later predicate fails where ANTLR reports a failed predicate; a parser action cannot establish state for a later predicate in the same CNVRS parse. Lexer actions have ANTLR's deferred timing, including suppression of actions in referenced lexer rules, and lexer predicates run before selected-rule actions. The callback receives input and position, but not ANTLR's mutable lexer token state or parser rule context. See [ANTLR's predicate rules](https://github.com/antlr/antlr4/blob/dev/doc/predicates.md), [parser rule elements](https://github.com/antlr/antlr4/blob/dev/doc/parser-rules.md), and [lexer rule elements](https://github.com/antlr/antlr4/blob/dev/doc/lexer-rules.md).

### Direct left recursion

An alternative may start with its own rule name. Recursive alternatives are listed from lowest to highest precedence; repetitions of one alternative associate to the left. Wrap an alternative in `(right ...)` to associate to the right:

```lisp
(defparameter *expr*
  (cnvrs:compile-grammar
   '((expr (or (and expr :+ expr)
               (and expr :* expr)
               (right (and expr :^ expr))
               (and :open expr :close)
               :number)))))
```

Here multiplication binds more tightly than addition, and exponentiation binds more tightly than both. The result contains nested `expr` nodes with the original rule name and token offsets. A recursive alternative can also be postfix, such as `(and expr :bang)`. A rule needs at least one non-left-recursive base alternative, and every recursive suffix must consume input. Indirect left recursion and cycles that consume no input remain invalid.

`parse` accepts a sequence of tokens: a string is a sequence of characters, while a list or vector can contain arbitrary token values. It consumes the whole input and returns `node` structs. Each node has a rule name, ordered children, start/end token offsets, and an optional `node-label` (NIL when absent). Children are literal tokens or nodes for referenced rules. A labeled element produces a `:label` node containing its matched tokens or rule nodes; repetition produces one such node per match. An alternative label appears on the enclosing rule node. Invalid grammars signal `cnvrs:grammar-error`.

Use `(not-token (:a :b))` in a parser rule to consume one token whose kind is neither `:a` nor `:b`. It never matches end of input. With `lexeme` input, the comparison uses `lexeme-kind`.

## Lexing

Supply a lexer to `compile-grammar` with `:lexer`, or override it for one call with `parse`'s `:lexer` argument. A lexer can be a compiled lexer object or a hand-written function designator taking the source and returning a list or vector of tokens. A hand-written lexer can return plain values, `cnvrs:lexeme` objects made with `make-lexeme`, or both:

```lisp
(defparameter *lexer*
  (lambda (source)
    (declare (ignore source))
    (vector (cnvrs:make-lexeme :kind :name :text "x" :start 0 :end 1))))

(defparameter *parser*
  (cnvrs:compile-grammar '((start :name)) :lexer *lexer*))
(cnvrs:parse *parser* "x")
```

`compile-lexer` compiles lexer rules in the Lisp image and returns a `compiled-lexer` structure. Pass it to `lex`, or attach it to a parser with `:lexer`. Rules have the form `(kind expression &key skip channel mode push-mode pop-mode set-mode)`. Expressions support characters, strings, rule references, `(and ...)`/`(seq ...)`, `(or ...)`, `(* expression)`, `(+ expression)`, `(? expression)`, nongreedy `(*? expression)`, `(+? expression)`, `(?? expression)`, `(range low high)`, `(one-of "characters")`, `(not-one-of (#\a #\b ...))`, and `(any)`. Lexer references may use symbols or keywords. A rule must consume at least one character; recursive lexer references are rejected. A second return value matches one token at a given source position; `lexer-matcher` exposes it for compiled lexers and macro-defined lexer grammars. The compiled lexer itself is no longer a function designator, so use `lex` instead of `funcall`.

```lisp
(defparameter *lexer*
  (cnvrs:compile-lexer
   '((:space (+ (one-of " ")) :skip t)
     (:let "let")
     (:name (+ (range #\a #\z)))
     (:equals #\=)
     (:number (+ (range #\0 #\9))))))

(defparameter *parser*
  (cnvrs:compile-grammar
   '((assignment (and :let :name :equals :number)))
   :lexer *lexer*))

(cnvrs:parse *parser* "let x = 42")
```

The generated lexer takes the longest match at each source position. Equal-length matches use the earlier rule. Skipped rules consume text without returning tokens. Returned lexemes expose `lexeme-kind`, `lexeme-text`, `lexeme-start`, `lexeme-end`, and `lexeme-channel`; the parser matches their kinds and keeps the lexeme objects in the tree. Lexer-produced lexemes retain the source and extract their text only when `lexeme-text` is called; `make-lexeme :text` still stores caller-supplied text directly. Node and parse-error offsets count the selected tokens, while lexeme offsets count source characters. Unmatched input signals `lexical-error` with `lexical-error-position` and `lexical-error-character`.

### Lexer modes

Lexer rules belong to `:default` mode unless they specify `:mode`. Only rules in the current mode can match. A rule may use one of `:push-mode`, `:pop-mode t`, or `:set-mode` to change modes after it matches. Mode actions also run for `:skip t` rules. These options work in `compile-lexer` definitions and in lexer rules declared with `defrule`, including combined grammars. In the macro layer, `(with-mode mode rules...)` assigns one mode to a group of lexer rules. It works inside `define-parser` and after `in-parser`.

```lisp
(cnvrs:define-parser *quoted-words* (:kind :lexer)
  (cnvrs:defrule :word (+ (range #\a #\z)))
  (cnvrs:defrule :space #\Space :skip t)
  (cnvrs:defrule :open #\" :push-mode :string :skip t)
  (cnvrs:with-mode :string
    (cnvrs:defrule :text (+ (range #\a #\z)))
    (cnvrs:defrule :close #\" :pop-mode t :skip t)))

(map 'list #'cnvrs:lexeme-kind
     (cnvrs:lex *quoted-words* "one \"two\" three"))
; => (:WORD :TEXT :WORD)
```

`push-mode` saves the current mode, and `pop-mode` restores it, so nested mode changes work. `set-mode` switches directly without using the stack. Every target mode must have a rule, and popping an empty mode stack signals `lexer-mode-error`, a subclass of `lexical-error` with a `lexer-mode-error-mode` reader.

For an incremental definition, use `(in-parser *quoted-words*)` followed by a top-level `(cnvrs:with-mode :string (cnvrs:defrule ...) ...)`. Within `define-parser`, the block also accepts bare `(name expression ...)` rule forms. An explicit `:mode` on a rule inside the block must match the block's mode.

### Channels

Rules use the `:default` channel unless they specify `:channel`. Tokens on other channels remain in the lexer's output, so callers can inspect them. `parse` consumes only `:default` tokens unless given `:channels`, a list of channel names, or `:all`:

```lisp
(defparameter *lexer*
  (cnvrs:compile-lexer
   '((:name (+ (range #\a #\z)))
     (:space (+ (one-of " ")) :channel :trivia))))

(cnvrs:lex *lexer* "x ")  ; => lexemes on :default and :trivia
(cnvrs:parse (cnvrs:compile-grammar '((start :name)) :lexer *lexer*) "x ")
                           ; => parses the :name token
```

A hand-written lexer can set `:channel` in `make-lexeme`. Plain token values and lexemes without an explicit channel belong to `:default`. `:skip t` drops a token entirely, regardless of its channel. Pass `:channels '(:default :trivia)` to parse both, or `:channels :all` to parse every channel.

## Parse errors and recovery

Strict parsing is the default. Parse failures are `cnvrs:parse-error` conditions with `parse-error-position`, `parse-error-token`, `parse-error-expected`, and `parse-error-rule` readers. At end of input, `parse-error-token` is `eq` to `cnvrs:+end-of-input+`. The three subclasses identify the failure site:

| Condition | Restarts available while it is signaled |
| --- | --- |
| `mismatched-token` | `insert-tokens` inserts the expected token with no arguments, or queues a supplied sequence; `delete-tokens` deletes one token by default, or a supplied count, then retries |
| `no-viable-alternative` | `insert-tokens` queues a supplied sequence before retrying the choice; `delete-tokens` deletes one token by default, or a supplied count; `choose-alternative` takes a zero-based alternative index |
| `unexpected-input` | `discard-input` ignores the remaining input |

Handlers can select a repair using Common Lisp's `handler-bind` and `invoke-restart`:

```lisp
(handler-bind
    ((cnvrs:mismatched-token
       (lambda (condition)
         (when (eql (cnvrs:parse-error-expected condition) #\])
           (invoke-restart 'cnvrs:insert-tokens)))))
  (cnvrs:parse *brackets* "[x"))
```

For a larger repair, invoke `insert-tokens` with a nonempty list, vector, or string. The tokens are placed before the current input token and parsed through the normal choice and rule logic:

```lisp
(defparameter *record-parser*
  (cnvrs:compile-grammar
   '((record (and :open :name :colon :value :close)))))

(handler-bind
    ((cnvrs:mismatched-token
       (lambda (condition)
         (when (eq (cnvrs:parse-error-expected condition) :name)
           (invoke-restart 'cnvrs:insert-tokens
                           '(:name :colon :value))))))
  (cnvrs:parse *record-parser* '(:open :close)))
```

At a token mismatch, no argument to `insert-tokens` inserts the expected token. When you supply a sequence, its first token must match that expectation. At a failed choice, there is no unique expected token, so `insert-tokens` requires a sequence beginning with a viable token. The original input sequence is not changed.

`(invoke-restart 'cnvrs:delete-tokens)` deletes one token. Pass a positive count to delete more, for example `(invoke-restart 'cnvrs:delete-tokens 3)`. The count must not exceed the remaining input. Each deletion returns one recovery record whose `recovery-token` is a list of the deleted tokens.

`(cnvrs:parse parser tokens :recover t)` enables a built-in policy: delete a token when the next one matches the expected token; insert the expected token when the current token can follow it or input has ended; delete tokens at a failed choice until prediction can resume; and discard trailing input. It stops and signals the condition if it cannot make a conservative repair. Automatic insertion at one input position is bounded to prevent recovery loops.

`parse` returns two values: the tree and a list of recovery records in input order. `recovery-action`, `recovery-condition`, and `recovery-token` describe each repair. Inserted tokens appear in the tree as `inserted-token` objects with `inserted-token-value` and `inserted-token-position` (`inserted-token-expected` remains an alias); deleted tokens appear only in recovery records. For insertion and deletion, `recovery-token` is a list, including for a one-token repair. A recovered tree's offsets refer to the original input, and its root end may precede discarded trailing input.

## Parsing ANTLR4 grammars

The ANTLR4 language grammar from [grammars-v4](https://github.com/antlr/grammars-v4/tree/master/antlr/antlr4) is implemented in the `cnvrs/antlr4` package with CNVRS parser and lexer rules. `parse` converts supported `.g4` syntax into a CNVRS grammar definition:

```lisp
(let* ((grammar (cnvrs/antlr4:parse
                 "grammar Example; start : ID EOF; ID : [a-z]+; WS : [ ]+ -> skip;"))
       (compiled (cnvrs:ensure-compiled grammar)))
  (cnvrs:parse compiled "hello"))
;; => a START node
```

The returned definition also works directly with `cnvrs:parse` and `cnvrs:lex`; compilation happens on first use. `cnvrs/antlr4:parse-tree` returns the ANTLR syntax tree and accepts `:rule` to select a grammar entry rule. `cnvrs/antlr4:*parser*` and `cnvrs/antlr4:*lexer*` are defined with `define-parser` and `defrule` macros. The lexer adaptor handles action blocks, brackets, and context-dependent identifier token types.

Conversion supports parser and lexer rules, alternatives, groups, `?`, `*`, `+`, nongreedy lexer suffixes `??`, `*?`, `+?`, literals, character ranges and sets, negated block sets (`~(A|B)` in parser rules and `~('a'|'b'..'d')` in lexer rules), fragments, lexer modes, `skip`, `channel(...)`, `pushMode(...)`, `popMode`, and `mode(...)`. Parser element labels (`name=atom`, `names+=atom`, and labeled groups) become labeled element nodes; alternative labels (`#Name`) appear on the matching rule node. A parser grammar can use an external CNVRS lexer through `:lexer`, or parse a token sequence without one. A combined grammar creates lexer rules for string literals. `EOF` at the end of an alternative maps to CNVRS's whole-input check. Parser negated token sets compile to `(not-token (:a :b))` and consume one token whose kind is outside the set.

ANTLR rule action blocks and semantic predicates (`{...}?`) can be connected to Common Lisp callbacks with `cnvrs/antlr4:parse`'s `:callbacks` argument. Supply an alist or hash table mapping the exact block text, including braces, to function names or function objects. The callback contract is the same as for Lisp grammar forms. Every rule action or predicate block needs a mapping; CNVRS does not evaluate code written in another ANTLR target language.

```lisp
(cnvrs/antlr4:parse
 "grammar Example; start : {ready()}? WORD {record()}; WORD : [a-z]+;"
 :callbacks (list (cons "{ready()}" #'ready-p)
                  (cons "{record()}" #'record-match)))
```

For direct left recursion in `.g4` input, the converter preserves ANTLR's source-order precedence for recursive and prefix alternatives: earlier alternatives bind more tightly. It accepts `<assoc=right>` and `<assoc=left>` on outer parser alternatives. Native Lisp grammar forms continue to list recursive alternatives from lowest to highest precedence, with `(right ...)` for right associativity.

Grammar prequels (`options`, `import`, `tokens`, `channels`, and `@` actions) are retained in source order as `(:prequels ...)` metadata. Read them through `parser-definition-metadata` on the returned definition, `parser-metadata` on a compiled parser, or `compiled-lexer-metadata` on a compiled lexer. Each entry is `(:options ((name value) ...))`, `(:imports ((alias name) ...))` (alias is `nil` when absent), `(:tokens (name ...))`, `(:channels (name ...))`, or `(:action (:scope scope :name name :body source))`. These declarations are available for inspection; CNVRS does not execute prequel actions, load imported grammars, or apply grammar options such as `caseInsensitive` and `tokenVocab`. Rule actions and predicates without callback mappings, and unsupported lexer commands, raise `cnvrs:grammar-error` during conversion.

The integration tests parse the upstream `ANTLRv4Lexer.g4` and `ANTLRv4Parser.g4` syntax trees offline. Those grammars use ANTLR features outside the current conversion subset.

## Implementation

Compilation builds an in-memory transition graph with rule calls, token edges, and epsilon edges. Decisions with disjoint first tokens use a direct one-token table; caller-dependent tables are cached by return stack. Remaining decisions explore graph configurations with unbounded lookahead. A shared SLL DFA tries first; when alternatives need caller context, prediction retries with the active rule-return stack. DFA transitions are cached as input is encountered. Parsing then follows the selected path and constructs the tree.

The parser and lexer graphs use a common state base and transition type, with shared state creation, edge insertion, and closure traversal. Their matching policies remain distinct: the lexer finds the longest character match in its current mode, while the parser predicts token alternatives using rule-return context.

Compilation rewrites direct left recursion into precedence levels before building the transition graph. It rejects indirect or zero-consumption rule cycles and repetitions whose body can match empty input. Ambiguous alternatives use their written order.

### Compiled objects and caches

`compile-grammar` returns a `parser` structure; `compile-lexer` returns a `compiled-lexer` structure. `define-parser` returns a definition that compiles on first use. Call `ensure-compiled` on a definition to compile it before parsing or lexing. It returns the same compiled object on later calls until a new `defrule` invalidates the definition.

The exported `parser-states`, `parser-starts`, `parser-stops`, and `parser-lexer` accessors expose a parser's transition graph. `compiled-lexer-states`, `compiled-lexer-mode-starts`, and `compiled-lexer-kinds` expose a lexer's automaton. State and edge accessors are exported for inspection. Treat these graphs as immutable.

Parser compilation also stores compiled rule functions in `parser-runner` (recognition without a tree) and `parser-node-runner` (the default node builder). Each runner has named local functions for the rules and takes the parser, token vector, start rule, and `require-eof` flag. `parse` selects one of them for valid input when recovery is off; custom builders and recovery use the general parser loop. The lexer already uses a compiled DFA matcher with a named local `match-one` function.

`compile-cached-dfa` is an optional second compilation step for any compiled
parser or `define-parser` definition. Parse representative inputs first, then
call `(compile-cached-dfa parser :max-states 64)`. It compiles the currently
observed SLL and full-context DFA states into parser-owned token dispatch
functions and returns two values: the number of DFA roots and the total number
of states compiled. Each root is capped at `:max-states` (default 64); unseen
contexts and transitions use normal adaptive prediction. Call it again after
training on more inputs to refresh the snapshots. It does not change the
grammar graph or the parser's public parse behavior. `clear-cache` removes the
compiled snapshots; `clone-compiled` starts with independent, empty caches and
no snapshots. A custom cache backend can support this operation by implementing
`cache-entries` in addition to the usual cache methods.

For a parser created with `define-parser`, the opt-in workflow is:

```lisp
(cnvrs:parse *my-parser* training-input)
(cnvrs:compile-cached-dfa *my-parser* :max-states 32)
(cnvrs:parse *my-parser* next-input)
```

Both compilers accept `:cache-backend`. The storage backends are `:fset`, using persistent [FSET maps](https://fset.common-lisp.dev/Site/FSet-Tutorial.html), and `:hash-table`. The FSET backend uses a custom key comparison function for common cache key types and falls back to FSET's general comparison for other types. Both backends are bare, unsynchronized strategies. Wrap either with `(:locked backend)` when a compiled parser or lexer will be shared across threads. The default is the unlocked `:hash-table` backend. The lexer caches DFA states and transitions; the parser caches SLL decisions, full-context decisions, caller-dependent direct lookahead tables, and canonical return-context IDs. The decision caches are exposed through `parser-sll-decisions`, `parser-decisions`, and `parser-direct-decisions`; `clear-cache` clears all of them, including context IDs.

Parsers also accept `:full-context-strategy`. The default `:cached` retains a start DFA for each decision and caller return stack. `:recompute` builds a fresh start DFA whenever SLL prediction needs caller context, without storing those full-context DFAs. This changes the cache policy, not the predicted result. Pass a function of `(parser state-id return-stack)` for a custom strategy; it must return a start DFA state, which can be built with `make-full-context-start`. `parser-full-context-strategy` exposes the choice, and `clone-compiled` accepts the same keyword to compare strategies with independent caches.

`clone-compiled` accepts either kind of compiled object or a definition. A clone shares its immutable graph and starts with independent, empty caches. A parser clone also clones an attached compiled lexer. Pass `:cache-backend` to choose a different backend for the clone. `clear-cache` is the single public clearing operation: on a parser it clears all three parser caches and its attached compiled lexer's cache; on a lexer it clears its DFA state and transition cache. Select a locked backend before sharing an object across threads.

Custom backends specialize `make-cache` on a backend name and implement `cache-get-or-compute`, `cache-clear`, and `cache-count` for the returned cache object. `cache-get-or-compute` must return the stored value or compute, store, and return one value for an absent key. The generic `(:locked backend)` wrapper also works with custom backends.

```lisp
(defparameter *ready* (cnvrs:ensure-compiled *assignment*))
(defparameter *worker* (cnvrs:clone-compiled *ready*))
(cnvrs:clear-cache *ready*)

(defparameter *local* (cnvrs:clone-compiled *ready*
                                           :cache-backend :hash-table))
(defparameter *shared-hash* (cnvrs:clone-compiled *ready*
                                                 :cache-backend '(:locked :hash-table)))
```

### Parse tree builders

The default `:node` builder returns `cnvrs:node` structures. Supply `:tree-builder` to `compile-grammar` or `define-parser` to choose another builder for a parser, or to `parse` to override it for one call. A clone retains its parser's builder. Use `:tree-builder :none` to recognize input without constructing a tree; the first return value of `parse` is then `NIL`, while the second still contains any recovery records.

A custom builder implements two generic functions. `make-parse-node` receives the builder, rule name, ordered children, start token offset, and end token offset. Children are tokens, inserted-token markers from recovery, or nodes already produced by that builder. `parse-node-components` receives the builder and a value and returns five values: rule, children, start, end, and a true value if the value is one of its nodes. Return a false fifth value for tokens. The parser uses these methods when normalizing direct left recursion, so custom nodes retain the original rule names and tree shape.

```lisp
(defstruct my-node rule children start end)

(defmethod cnvrs:make-parse-node ((builder (eql :my-node)) rule children start end)
  (make-my-node :rule rule :children children :start start :end end))

(defmethod cnvrs:parse-node-components ((builder (eql :my-node)) value)
  (if (my-node-p value)
      (values (my-node-rule value) (my-node-children value)
              (my-node-start value) (my-node-end value) t)
      (values nil nil nil nil nil)))

(cnvrs:parse (cnvrs:compile-grammar '((start :name))
                                    :tree-builder :my-node)
             '(:name))
```

For an event-only strategy, specialize `parse-build-tree-p` to return `NIL` and implement any of `parse-rule-enter`, `parse-token-consumed`, and `parse-rule-exit`. No node or child list is built, and `make-parse-node` and `parse-node-components` are not called. The events include token offsets; inserted recovery tokens are reported through `parse-token-consumed`. Events follow the compiled rule traversal, so direct left recursion can produce additional enter and exit events for its rewritten levels.

## Tests

```sh
XDG_CACHE_HOME=/tmp/cnvrs-asdf-cache sbcl --non-interactive --eval '(require :asdf)' \
  --eval '(asdf:load-asd (truename "cnvrs.asd"))' \
  --eval '(asdf:test-system :cnvrs)'
```
