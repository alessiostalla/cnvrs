# CNVRS

CNVRS compiles Common Lisp grammar forms into native parser functions and loadable FASLs. Its parser prediction runtime is a port of ANTLR Java 4.13.2. Lisp forms remain the primary grammar language; the optional `.g4` importer lowers ANTLR grammars into the same compiler.

See [CNVRS and ANTLR 4/Java: current differences](docs/runtime-comparison.md) for feature, algorithm, and benchmark comparisons.

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
| `(and a b ...)` or `(cnvrs:seq a b ...)` | Sequence; `(and)` matches empty input |
| `(or a b ...)` | Ordered alternatives; first wins if both match |
| `(* a)`, `(+ a)`, `(cnvrs:? a)` | Zero or more, one or more, optional |
| `(cnvrs:label name a)` | Wrap a match in a node with `node-label` set to `name` |
| `(cnvrs:alt-label name a)` | Set `node-label` on the enclosing rule node when this alternative matches |
| `rule-name` | Reference to the exact rule symbol |
| `(cnvrs:token value)` | Match a token with `equal` |
| Character, string, number, or symbol from a token package | Literal token |

Grammar operators are recognized by symbol identity. Use the exported `cnvrs:` operators or import them into the grammar's package. `cnvrs:and`, `cnvrs:or`, `cnvrs:*`, and `cnvrs:+` are the corresponding symbols inherited from `COMMON-LISP`. A same-named symbol in another package is a different symbol: `cnvrs:predicate`, `my-parser:predicate`, and `my-lexer:predicate` can each have a separate role. A CNVRS operator symbol cannot name a parser rule or lexer token kind; for example, `CL:AND` is `CNVRS:AND` and is rejected as a rule name. Bare parser references use exact defined rule symbols; symbols from the packages containing parser rules that are not defined signal an undefined-rule error. Use `(cnvrs:token symbol)` to match a token symbol from one of those packages explicitly.

## Defining grammars with macros

`defparser` defines a complete parser, lexer, or combined grammar in one form.
It prepares the grammar when the form is macroexpanded. Under `compile-file`,
the FASL contains the prepared graph and compiled rule functions; loading it
reconstructs the parser and fresh caches without compiling the grammar again.
Evaluating the form directly still creates a usable parser in the current Lisp
image. A `use` subform names an already defined parser definition variable and
copies its rules before compilation; the resulting
parser has one graph and one prediction context. Parser rule names are exact
Lisp symbols, so rules may live in different packages:

```lisp
;; In expr.lisp, after defining the EXPR package:
(cnvrs:defparser *expression-rules* (:rules-only t)
  (expr:expression expr:atom)
  (expr:atom :identifier))

;; In java.lisp, loaded after expr.lisp:
(cnvrs:defparser *java-parser* (:default-rule java:class)
  (cnvrs:use *expression-rules*)
  (java:class (and :class expr:expression :semi)))
```

`:rules-only t` leaves a complete definition available for import without
compiling it at definition time. It can still be compiled explicitly with
`ensure-compiled` or on first use with `parse`. Without this option, `defparser`
compiles immediately. A local rule with the exact symbol of an imported rule
replaces it throughout the composed grammar, including references from other
imported rules. The first local rule is the default entry rule unless
`:default-rule` selects another. Duplicate local rules, conflicting imports
without a local override, and import cycles signal `grammar-error`. `defrule`
and `with-mode` are only valid inside `defparser`. Reimporting the same
originating rule is harmless. Composition resolves source definitions when
`defparser` is macroexpanded. In ASDF, declare the source file as a dependency
of the importing file so a change recompiles the dependent grammar. Recompile
or re-evaluate a dependent definition after changing an imported one. `use`
composes parser rules only and signals `grammar-error` in a lexer definition.
Choose one lexer
for the resulting parser with `:lexer`, or pass an existing token sequence to
`parse`. An expression supplied as `:lexer` is evaluated when the FASL loads;
if it constructs a lexer itself, that work is separate from the compiled
`defparser` definition.

The first form after the name may be an option plist with `:kind`,
`:default-rule`, `:lexer`, `:parser-package`, and `:lexer-package`; the remaining
forms are rules or `use` clauses. Rules may be written as
`(defrule name expression ...)` or simply `(name expression ...)`:

```lisp
(cnvrs:defparser *assignment* (:kind :combined)
  (cnvrs:defrule assignment (and :let :name :equals value))
  (cnvrs:defrule value :number)
  (cnvrs:defrule :space (+ (cnvrs:one-of " ")) :skip t)
  (cnvrs:defrule :let "let")
  (cnvrs:defrule :name (+ (cnvrs:range #\a #\z)))
  (cnvrs:defrule :equals #\=)
  (cnvrs:defrule :number (+ (cnvrs:range #\0 #\9))))

(cnvrs:parse *assignment* "let x = 42")
(cnvrs:parse *assignment* "42" :rule 'value) ; starts at any named parser rule
```

For a lexer-only definition, put all rules in the same form:

```lisp
(cnvrs:defparser *words* (:kind :lexer)
  (cnvrs:defrule :space (+ (cnvrs:one-of " ")) :skip t)
  (cnvrs:defrule :word (+ (cnvrs:range #\a #\z))))

(cnvrs:lex *words* "one two")
```

| Kind | Rules and use |
| --- | --- |
| `:parser` (default) | All rules are parser rules. `parse` accepts token sequences; an optional `:lexer` option attaches an existing lexer function. |
| `:lexer` | All rules are lexer rules. `lex` accepts a source string and returns lexemes. |
| `:combined` | Rule symbols in `:lexer-package` define lexer rules; other rule symbols define parser rules. Use `:lexer t` to select a lexer rule explicitly. `parse` lexes and parses source strings. |

For `defparser` definitions, `:parser-package` defaults to the package of the definition variable, and `:lexer-package` defaults to `KEYWORD`. Supply both to put parser rules and token kinds in separate application packages. A combined grammar requires distinct packages.
Package option expressions are evaluated while `defparser` is macroexpanded so the compiler can classify combined grammar rules.

The same symbol cannot name both a parser rule and a lexer token kind. CNVRS checks this when compiling a grammar with a compiled lexer or combined rules, and when a hand-written lexer returns tokens during parsing.

`:default-rule` changes the rule used when `parse` is called without `:rule`; otherwise the first local parser rule is the default, or the first imported rule when there are no local parser rules. Every `parse` call may select any parser rule with `:rule`, whether the grammar was built with `compile-grammar` or `defparser`. Only the selected entry rule must consume the entire input by default, even if its definition does not mention EOF. Calls to that same rule from within other rules have no EOF requirement. Use `:require-eof nil` to accept a prefix and inspect `node-end` for the position reached. This EOF check happens at parse time and does not alter the rule. The older `parse :start` argument remains an alias for `:rule`.

Lexer rules accept `:skip t` and `:channel name`. Rule order still determines ties between equal-length lexer matches. A normal `defparser` includes its prepared parser or lexer in the FASL; `:rules-only t` retains just its rules for import or later in-image compilation. `parse` on a lexer-only grammar signals `grammar-error`; use `lex` instead.

### Semantic predicates and actions

Both parser and lexer expressions accept `(cnvrs:predicate callback)` and `(cnvrs:action callback)` as zero-width elements, including inside sequences, alternatives, and repetitions. `callback` is a Common Lisp function or a non-keyword function name. In `compile-grammar` and `compile-lexer`, function objects can be placed directly in the supplied forms; in quoted `defparser` rule forms, use a function name. A callback receives `(input position)`. For parser callbacks, `input` is a view of the selected token channels and `position` is a zero-based visible-token offset; use `(cnvrs:input-token-at input position)` to read the current token and `(cnvrs:input-token-count input)` for the visible length. These accessors also accept an unfiltered token vector. Unlike ANTLR's relative `LT(k)`, `input-token-at` uses an absolute visible-token index; lookahead `k` is at `(+ position (1- k))` when that index is below `input-token-count`. Parser callbacks should not use `aref` or `length` on `input`. Lexer callbacks still receive the source string and a character offset. A predicate succeeds on a non-`nil` return value. Predicates may be evaluated repeatedly during prediction and rule execution. Parser actions ignore their return values and execute when the selected rule path reaches them; prediction never executes actions. A later parse error does not undo an action. Lexer actions execute only after a winning lexer rule has been selected.

```lisp
(defun word-allowed (source position)
  (declare (ignore position))
  (not (find #\! source)))

(defun word-seen (source position)
  (format t "Matched through character ~D in ~S~%" position source))

(cnvrs:compile-lexer
 '((:word (and (cnvrs:predicate word-allowed)
               (+ (cnvrs:range #\a #\z))
               (cnvrs:action word-seen)))))
```

Parser predicates participate in Java-style adaptive prediction and are checked again on the selected execution path. Parser actions execute at their position on that path. Predicates should be free of side effects; actions may establish state for subsequent predicates. Callback grammars support `:node`, `:none`, and custom tree builders; native recovery is unavailable for them. Callbacks receive `(input position)`, rather than Java's mutable parser context. Lexer actions retain deferred timing, including suppression in referenced lexer rules.

### Direct left recursion

An alternative may start with its own rule name. Recursive alternatives are listed from lowest to highest precedence; repetitions of one alternative associate to the left. Wrap an alternative in `(cnvrs:right ...)` to associate to the right:

```lisp
(defparameter *expr*
  (cnvrs:compile-grammar
   '((expr (or (and expr :+ expr)
               (and expr :* expr)
               (cnvrs:right (and expr :^ expr))
               (and :open expr :close)
               :number)))))
```

Here multiplication binds more tightly than addition, and exponentiation binds more tightly than both. The result contains nested `expr` nodes with the original rule name and token offsets. A recursive alternative can also be postfix, such as `(and expr :bang)`. A rule needs at least one non-left-recursive base alternative, and every recursive suffix must consume input. Indirect left recursion and cycles that consume no input remain invalid.

`parse` accepts a sequence of tokens: a string is a sequence of characters, while a list or vector can contain arbitrary token values. It consumes the whole input and returns `node` structs. Each node has a rule name, ordered children, start/end token offsets, and an optional `node-label` (NIL when absent). Children are literal tokens or nodes for referenced rules. A labeled element produces a `:label` node containing its matched tokens or rule nodes; repetition produces one such node per match. An alternative label appears on the enclosing rule node. Invalid grammars signal `cnvrs:grammar-error`.

Use `(cnvrs:eof)` for an explicit end-of-input assertion, including when `:require-eof nil` permits a prefix parse. `(cnvrs:any)` consumes any one token. Use `(cnvrs:not-token (:a :b))` in a parser rule to consume one token whose kind is neither `:a` nor `:b`. It never matches end of input. With `lexeme` input, the comparison uses `lexeme-kind`.

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

`compile-lexer` compiles lexer rules in the Lisp image and returns a `compiled-lexer` structure. Pass it to `lex`, or attach it to a parser with `:lexer`. Rules have the form `(kind expression &key skip channel mode push-mode pop-mode set-mode more type fragment case-insensitive)`. Expressions support characters, strings, rule references, `(and ...)`/`(cnvrs:seq ...)`, `(or ...)`, `(* expression)`, `(+ expression)`, `(cnvrs:? expression)`, nongreedy `(cnvrs:*? expression)`, `(cnvrs:+? expression)`, `(cnvrs:?? expression)`, `(cnvrs:range low high)`, `(cnvrs:one-of "characters")`, `(cnvrs:not-one-of (#\a #\b ...))`, `(cnvrs:unicode-property "L")` (an optional third argument inverts the property), `(cnvrs:eof)`, and `(cnvrs:any)`. Lexer references may use symbols or keywords, including direct and indirect recursion for nested constructs. Every recursive path must consume a character before returning to the same rule; left recursion and cycles without progress are rejected. A rule must consume input or explicitly match EOF; repetition bodies must make progress. A second return value matches one token at a given source position; `lexer-matcher` exposes it for compiled lexers and macro-defined lexer grammars. The compiled lexer itself is no longer a function designator, so use `lex` instead of `funcall`.

For example, `((:block (and #\{ (* (or :block (cnvrs:not-one-of "{}"))) #\})) (:other (cnvrs:any)))` matches `{a{b}c}` as one token. Recursive, nongreedy, predicate and ordinary rules all use the same Java-style lexer ATN simulator and mode DFA.

```lisp
(defparameter *lexer*
  (cnvrs:compile-lexer
   '((:space (+ (cnvrs:one-of " ")) :skip t)
     (:let "let")
     (:name (+ (cnvrs:range #\a #\z)))
     (:equals #\=)
     (:number (+ (cnvrs:range #\0 #\9))))))

(defparameter *parser*
  (cnvrs:compile-grammar
   '((assignment (and :let :name :equals :number)))
   :lexer *lexer*))

(cnvrs:parse *parser* "let x = 42")
```

The generated lexer takes the longest match at each source position. Equal-length matches use the earlier rule. Skipped rules consume text without returning tokens. Returned lexemes expose `lexeme-kind`, `lexeme-text`, `lexeme-start`, `lexeme-end`, and `lexeme-channel`; the parser matches their kinds and keeps the lexeme objects in the tree. Lexer-produced lexemes retain the source and extract their text only when `lexeme-text` is called; `make-lexeme :text` still stores caller-supplied text directly. Node and parse-error offsets count the selected tokens, while lexeme offsets count source characters. Unmatched input signals `lexical-error`. Its `position`, `line` and `column` readers identify the token start; `failed-position` identifies the cursor where matching failed. A handler can invoke the `cnvrs:skip-character` restart to discard the failed prefix and one offending character. `(lex lexer source :recover t)` selects Java's default consume-and-continue recovery and still signals the condition for handlers.

`make-lexer-state` and `lexer-next-token` expose streaming lexing. The latter returns a final lexeme of kind `cnvrs:+end-of-input+`; bulk `lex` keeps its vector API and omits EOF. Lexeme offsets are half-open character offsets, with one-based `lexeme-line` and zero-based `lexeme-column`. Newline tracking follows Java: LF advances the line, CR advances the column.

`:more t` accumulates text into the next match, including across modes; `:type token-symbol` overrides the emitted kind. `:fragment t` declares a referenced rule that is never a mode entry. `:case-insensitive t` applies Java's simple case expansion to literals, ranges and scalar sets. Unicode properties use ANTLR 4.13.2's checked-in tables; simple case mappings are pinned to JDK 24. No Java installation is needed to compile or run Lisp grammars.

Lexer callbacks retain `(source position)` and can inspect `cnvrs:*lexer-state*`. Actions may set `lexer-state-type`, `lexer-state-channel` and `lexer-state-text`, or change modes. Predicates see the speculative cursor, line and column; these are restored on return. Actions run only for the accepted rule after maximal-match rewind. Indexed custom actions see their recorded character position and Java's accepted line/column. Referenced-rule actions are suppressed.

### Lexer modes

Lexer rules belong to `:default` mode unless they specify `:mode`. Only rules in the current mode can match. A rule may use one of `:push-mode`, `:pop-mode t`, or `:set-mode` to change modes after it matches. Mode actions also run for `:skip t` rules. These options work in `compile-lexer` definitions and in lexer rules declared inside `defparser`, including combined grammars. `(with-mode mode rules...)` assigns one mode to a group of lexer rules inside `defparser`.

```lisp
(cnvrs:defparser *quoted-words* (:kind :lexer)
  (cnvrs:defrule :word (+ (cnvrs:range #\a #\z)))
  (cnvrs:defrule :space #\Space :skip t)
  (cnvrs:defrule :open #\" :push-mode :string :skip t)
  (cnvrs:with-mode :string
    (cnvrs:defrule :text (+ (cnvrs:range #\a #\z)))
    (cnvrs:defrule :close #\" :pop-mode t :skip t)))

(map 'list #'cnvrs:lexeme-kind
     (cnvrs:lex *quoted-words* "one \"two\" three"))
; => (:WORD :TEXT :WORD)
```

`push-mode` saves the current mode, and `pop-mode` restores it, so nested mode changes work. `set-mode` switches directly without using the stack. Every target mode must have a rule, and popping an empty mode stack signals `lexer-mode-error`, a subclass of `lexical-error` with a `lexer-mode-error-mode` reader.

Within `defparser`, a `with-mode` block also accepts bare `(name expression ...)` rule forms. An explicit `:mode` on a rule inside the block must match the block's mode.

### Channels

Rules use the `:default` channel unless they specify `:channel`. Tokens on other channels remain in the lexer's output, so callers can inspect them. `parse` consumes only `:default` tokens unless given `:channels`, a list of channel names, or `:all`:

```lisp
(defparameter *lexer*
  (cnvrs:compile-lexer
   '((:name (+ (cnvrs:range #\a #\z)))
     (:space (+ (cnvrs:one-of " ")) :channel :trivia))))

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
(defpackage #:example/parser (:use #:cl) (:export #:start))
(defpackage #:example/lexer (:use #:cl) (:export #:id #:ws))

(let* ((grammar (cnvrs/antlr4:parse
                 "grammar Example; start : ID EOF; ID : [a-z]+; WS : [ ]+ -> skip;"
                 :parser-package (find-package '#:example/parser)
                 :lexer-package (find-package '#:example/lexer)))
       (compiled (cnvrs:ensure-compiled grammar)))
  (cnvrs:parse compiled "hello"))
;; => a START node
```

`cnvrs/antlr4:parse` requires distinct `:parser-package` and `:lexer-package` package designators. It interns parser rule names in the former and lexer rule names, token kinds, and lexer mode names in the latter. Imported symbols remain the user's package choice; it does not force token kinds into `KEYWORD`. If both packages make the same symbol available under a parser rule and token name, import signals a grammar error. The returned definition also works directly with `cnvrs:parse` and `cnvrs:lex`; compilation happens on first use. `cnvrs/antlr4:parse-tree` returns the ANTLR syntax tree and accepts `:rule` to select a grammar entry rule. `cnvrs/antlr4:*parser*` and `cnvrs/antlr4:*lexer*` are defined with complete `defparser` forms. The lexer adaptor handles action blocks, brackets, and context-dependent identifier token types.

Conversion supports parser and lexer rules, alternatives, groups, `?`, `*`, `+`, nongreedy lexer suffixes `??`, `*?`, `+?`, literals, character ranges and sets, negated block sets (`~(A|B)` in parser rules and `~('a'|'b'..'d')` in lexer rules), fragments, lexer modes, `skip`, `channel(...)`, `pushMode(...)`, `popMode`, `mode(...)`, `more`, `type(...)`, Unicode properties, and grammar/rule `caseInsensitive` options. Parser element labels (`name=atom`, `names+=atom`, and labeled groups) become labeled element nodes; alternative labels (`#Name`) appear on the matching rule node. A parser grammar can use an external CNVRS lexer through `:lexer`, or parse a token sequence without one. A combined grammar creates lexer rules for string literals. `EOF` at the end of an alternative maps to CNVRS's whole-input check. Parser negated token sets compile to `(cnvrs:not-token (:a :b))` and consume one token whose kind is outside the set.

For split ANTLR grammars, resolve `options { tokenVocab = Shared; }` with
`:token-vocabulary`, an alist or `equal` hash table mapping the exact vocabulary
name to an imported lexer definition:

```lisp
(let* ((lexer (cnvrs/antlr4:parse
               "lexer grammar Shared; OPEN : '('; CLOSE : ')'; ID : [a-z]+; WS : [ ]+ -> skip;"
               :parser-package '#:example/parser :lexer-package '#:example/lexer))
       (parser (cnvrs/antlr4:parse
                "parser grammar Example; options { tokenVocab = Shared; } start : '(' ID CLOSE EOF;"
                :parser-package '#:example/parser :lexer-package '#:example/lexer
                :token-vocabulary (list (cons "Shared" lexer)))))
  (cnvrs:parse parser "(hello)"))
```

The parser attaches that lexer definition and uses its token symbols. Both imports
must use the same lexer package. Parser literals resolve to unique lexer rules
whose complete expression is a string literal; fragments do not provide token
aliases. Missing vocabularies, unknown token names, missing or ambiguous literal
aliases, and conflicting `:lexer` arguments signal `grammar-error`. This wiring
supports parser grammars and lexer definitions; it does not read `.tokens` files,
search the filesystem, or resolve ANTLR `import` declarations. Grammars without
`tokenVocab` retain the existing external-lexer and token-sequence behavior.

ANTLR rule action blocks and semantic predicates (`{...}?`) can be connected to Common Lisp callbacks with `cnvrs/antlr4:parse`'s `:callbacks` argument. Supply an alist or hash table mapping the exact block text, including braces, to function names or function objects. The callback contract is the same as for Lisp grammar forms. Every rule action or predicate block needs a mapping; CNVRS does not evaluate code written in another ANTLR target language.

```lisp
(cnvrs/antlr4:parse
 "grammar Example; start : {ready()}? WORD {record()}; WORD : [a-z]+;"
 :parser-package (find-package '#:example/parser)
 :lexer-package (find-package '#:example/lexer)
 :callbacks (list (cons "{ready()}" #'ready-p)
                  (cons "{record()}" #'record-match)))
```

For direct left recursion in `.g4` input, the converter preserves ANTLR's source-order precedence for recursive and prefix alternatives: earlier alternatives bind more tightly. It accepts `<assoc=right>` and `<assoc=left>` on outer parser alternatives. Native Lisp grammar forms continue to list recursive alternatives from lowest to highest precedence, with `(cnvrs:right ...)` for right associativity.

Grammar prequels (`options`, `import`, `tokens`, `channels`, and `@` actions) are retained in source order as `(:prequels ...)` metadata. Read them through `parser-definition-metadata` on the returned definition, `parser-metadata` on a compiled parser, or `compiled-lexer-metadata` on a compiled lexer. Each entry is `(:options ((name value) ...))`, `(:imports ((alias name) ...))` (alias is `nil` when absent), `(:tokens (name ...))`, `(:channels (name ...))`, or `(:action (:scope scope :name name :body source))`. These declarations are available for inspection; CNVRS does not execute prequel actions, load imported grammars, or apply unimplemented grammar options. Lexer `caseInsensitive` is applied during construction. Parser `tokenVocab` options are resolved through `:token-vocabulary` as described above. Rule actions and predicates without callback mappings, and unsupported lexer commands (including numeric command arguments, which require symbolic names in Lisp), raise `cnvrs:grammar-error` during conversion.

The integration tests parse the upstream `ANTLRv4Lexer.g4` and `ANTLRv4Parser.g4` syntax trees offline. Those grammars use ANTLR features outside the current conversion subset.

## Implementation

Lisp grammar forms compile to a rule-call graph and independently compiled recognition and tree-building functions. The parser frontend lowers the graph and token kinds to the typed ATN and positive token types used by `cnvrs/runtime`, an internal package compiled as part of the main `cnvrs` system. Runtime compilation, `compile-file`/FASL loading, grammar composition, and optional `.g4` import all use this frontend.

Runtime files carry explicit optimization policies and typed ATN/configuration/cursor fields; grammar construction retains conservative compilation settings. The [type and compiler-policy benchmark](bench/java-reference/types.md) records the effects, including a fully checked safety-3 build. The [fresh Java comparison and context-storage measurements](bench/java-reference/storage.md) record the latest performance and allocation results.

The prediction core follows ANTLR Java **4.13.2**, including graph-structured prediction contexts, configuration-set merging, SLL conflict detection, full-context retry and ambiguity termination, predicates, precedence filtering, and DFA/context-cache lifetimes. The old eager lookahead tries, caller-specific prediction caches, ordered semantic backtracking matcher, and cached-DFA trace compiler have been removed. The lexer now follows Java's `LexerATNFactory`, `LexerATNSimulator`, `LexerATNConfig`, `OrderedATNConfigSet`, action executors and token-source lifecycle. Errors use Lisp conditions and restarts; parser error recovery remains the Lisp implementation.

The native frontend follows Java 4.13.2's `ParserATNFactory`, left-recursion transformation, tail-epsilon removal and state compaction. Both Lisp forms and optional `.g4` import produce the same parser ATN topology: typed rule/block/loop states, ordered transitions, rule follows, precedence links, state numbers and decision numbers. Labels are tree-building annotations; they introduce no helper rules. Native low-to-high operator order maps to the equivalent Java rule's high-to-low order. Arbitrary Lisp token values are mapped to runtime token IDs.

Parser compilation also follows Java's `LL1Analyzer`, `AnalysisPipeline` and
code-generation selection: alternatives with nonempty, pairwise disjoint
one-token lookahead sets use direct dispatch. Predicates before consumption
prevent specialization; actions are transparent to analysis. Eligible optional,
star and plus blocks use Java's default exit behavior. Overlapping or opaque
choices retain adaptive prediction. Compiled rule functions contain direct token
switches; the generic execution path uses the same immutable decision maps.
These maps are grammar data preserved in FASLs, not trained DFA caches.

The offline tests compare complete graphs for native runtime and file compilation, `.g4` import, and the Java 8 parser (2,843 states) and lexer (1,117 states). Lexer fixtures also compare complete token records, recovery positions, action cursors and DFA state/edge counts, including native runtime/FASL compilation. They also test the prediction core independently against Java-generated ATNs. See the [reference-port map and fidelity checks](src/runtime/README.md) for representation boundaries and fixture provenance.

### Compiled objects and caches

`compile-grammar` returns a `parser` structure; `compile-lexer` returns a `compiled-lexer` structure. `defparser` returns a complete definition containing a prepared parser or lexer unless `:rules-only t` is supplied. Call `ensure-compiled` on a rules-only definition to compile it before parsing or lexing. It returns the same compiled object on later calls. Definitions returned by the `.g4` converter also compile on first use.

The exported `parser-states`, `parser-starts`, `parser-stops`, and `parser-lexer` accessors expose a parser's transition graph. `compiled-lexer-states`, `compiled-lexer-mode-starts`, and `compiled-lexer-kinds` expose a lexer's automaton. State and edge accessors are exported for inspection. Treat these graphs as immutable.

Parser compilation also stores compiled rule functions in `parser-runner` (recognition without a tree) and `parser-node-runner` (the default node builder). Each runner has named local functions for the rules and takes the parser, token vector, start rule, and `require-eof` flag. `parse` selects one of them for valid input when recovery is off; custom builders and recovery use the general parser loop. The lexer uses the shared ATN simulator with lazy per-mode DFAs; there is no separate recursive or semantic matcher.

`lexer-simulator` returns the lexer reference simulator; `cnvrs/runtime:lexer-simulator-dfas` exposes its DFAs. ASCII edges (0–127) are cached as in Java; Unicode and EOF edges are recomputed. Predicate-dependent starts/edges are not cached, and predicate results are never cached. Lexer configuration sets retain complete nested return contexts without parser-style context merging or shared context canonicalization.

`parser-prediction-simulator` returns a parser's reference simulator for inspection. Its decision DFAs are available through `cnvrs/runtime:simulator-decision-dfas`. The simulator supports `:ll` (the default), `:sll`, and `:ll-exact-ambig-detection` modes through `simulator-mode`.

SLL DFA states and their canonical prediction contexts persist between parses. Full-context reach sets are recomputed, and the merge cache belongs to one prediction. There are no caller-stack keys or full-context DFAs in the persistent cache. `parser-decisions` exposes the decision DFAs used by a parser. The former empty inspection views and caller-context cache fields have been removed.

`clear-cache` clears a parser's DFAs, shared prediction contexts, inspection views, and attached lexer cache, including attachments stored as grammar definitions. Static LL(1) decision maps are retained. `clone-compiled` shares the immutable grammar graph and starts with independent, empty runtime caches. FASLs contain grammar data and native rule functions, never trained prediction caches.

Recompile dependent grammar FASLs and start a fresh Lisp image after this runtime replacement. Simulator inspection uses `cnvrs/runtime`; the shared decision cache is exposed through `parser-decisions`.

The old `*eager-lookahead-limit*`, `*eager-lookahead-configuration-limit*`, `compile-cached-dfa`, and `make-full-context-start` APIs are gone. `:full-context-strategy` accepts only `:recompute`; `:cached` and custom hooks signal a grammar error. This makes the new baseline's behavior explicit rather than silently retaining a non-Java path.

`:cache-backend` controls the lexer and parser compatibility inspection views (`:hash-table`, `:fset`, or `(:locked backend)`). The reference simulators own their Java-style hashed DFA caches with synchronized updates; parser context interning is synchronized too. Predicates and actions run outside cache locks. When sharing the entire compiled grammar, select a locked backend for the lexer and inspection view as before.

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

The default `:node` builder returns `cnvrs:node` structures. Supply `:tree-builder` to `compile-grammar` or `defparser` to choose another builder for a parser, or to `parse` to override it for one call. A clone retains its parser's builder. Use `:tree-builder :none` to recognize input without constructing a tree; the first return value of `parse` is then `NIL`, while the second still contains any recovery records.

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

For an event-only strategy, specialize `parse-build-tree-p` to return `NIL` and implement any of `parse-rule-enter`, `parse-token-consumed`, and `parse-rule-exit`. No node or child list is built, and `make-parse-node` and `parse-node-components` are not called. The events include token offsets; inserted recovery tokens are reported through `parse-token-consumed`. Events follow rule traversal. Precedence loops build nested expression nodes without synthetic rule-enter or rule-exit events.

## Tests

```sh
XDG_CACHE_HOME=/tmp/cnvrs-asdf-cache sbcl --non-interactive --eval '(require :asdf)' \
  --eval '(asdf:load-asd (truename "cnvrs.asd"))' \
  --eval '(asdf:test-system :cnvrs)'
```

The normal suite also replays Java-generated ATNs and prediction traces in pure Lisp; running it does not require Java or the ANTLR tool. The [fixture README](test/fixtures/runtime/README.md) documents optional regeneration with the pinned Java tool.
