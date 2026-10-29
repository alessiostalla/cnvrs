# CNVRS

CNVRS, the **Contextual Nonterminal Variable-lookahead Recognition System**, is a clean-room Common Lisp implementation of adaptive LL(*) parsing, inspired by the algorithm described by Parr et al. It compiles Lisp grammar forms into an in-memory parser. It does not read grammar text or generate parser source.

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

`compile-grammar` takes a list of `(rule-name expression)` pairs. The first rule is the start rule unless `:start` names another. Expressions resemble Esrap forms:

| Form | Meaning |
| --- | --- |
| `(and a b ...)` or `(seq a b ...)` | Sequence; `(and)` matches empty input |
| `(or a b ...)` | Ordered alternatives; first wins if both match |
| `(* a)`, `(+ a)`, `(? a)` | Zero or more, one or more, optional |
| `rule-name` | Reference to a rule |
| `(token value)` | Match a token with `equal` |
| Character, string, number, or keyword | Literal token |

## Defining grammars with macros

`define-parser` declares a grammar in one form. The first form after its name is an optional plist with `:kind`, `:start`, and `:lexer`; the remaining forms are rules. Rules may be written as `(defrule name expression ...)` or simply `(name expression ...)`:

```lisp
(cnvrs:define-parser *assignment* (:kind :combined :start assignment)
  (cnvrs:defrule assignment (and :let :name :equals :number))
  (cnvrs:defrule :space (+ (one-of " ")) :skip t)
  (cnvrs:defrule :let "let")
  (cnvrs:defrule :name (+ (range #\a #\z)))
  (cnvrs:defrule :equals #\=)
  (cnvrs:defrule :number (+ (range #\0 #\9))))

(cnvrs:parse *assignment* "let x = 42")
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

`:start` selects a parser rule; otherwise the first parser rule is the start. Lexer rules accept `:skip t` and `:channel name`. Rule order still determines ties between equal-length lexer matches. Definitions compile in the current Lisp image on first use, allowing forward references in the incremental style. Adding a rule invalidates the compiled definition. `parse` on a lexer-only grammar signals `grammar-error`; use `lex` instead.

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

`parse` accepts a sequence of tokens: a string is a sequence of characters, while a list or vector can contain arbitrary token values. It consumes the whole input and returns `node` structs. Each node has a rule name, ordered children, and start/end token offsets. Children are literal tokens or nodes for referenced rules. Invalid grammars signal `cnvrs:grammar-error`.

## Lexing

Supply a lexer to `compile-grammar` with `:lexer`, or override it for one call with `parse`'s `:lexer` argument. A lexer is a function designator taking the source and returning a list or vector of tokens. A hand-written lexer can return plain values, `cnvrs:lexeme` objects made with `make-lexeme`, or both:

```lisp
(defparameter *lexer*
  (lambda (source)
    (declare (ignore source))
    (vector (cnvrs:make-lexeme :kind :name :text "x" :start 0 :end 1))))

(defparameter *parser*
  (cnvrs:compile-grammar '((start :name)) :lexer *lexer*))
(cnvrs:parse *parser* "x")
```

`compile-lexer` compiles lexer rules in the Lisp image and returns the same kind of function. Rules have the form `(kind expression &key skip channel)`. Expressions support characters, strings, rule references, `(and ...)`/`(seq ...)`, `(or ...)`, `(* expression)`, `(+ expression)`, `(? expression)`, `(range low high)`, and `(one-of "characters")`. Lexer references may use symbols or keywords. A rule must consume at least one character; recursive lexer references are rejected.

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

The generated lexer takes the longest match at each source position. Equal-length matches use the earlier rule. Skipped rules consume text without returning tokens. Returned lexemes expose `lexeme-kind`, `lexeme-text`, `lexeme-start`, `lexeme-end`, and `lexeme-channel`; the parser matches their kinds and keeps the lexeme objects in the tree. Node and parse-error offsets count the selected tokens, while lexeme offsets count source characters. Unmatched input signals `lexical-error` with `lexical-error-position` and `lexical-error-character`.

### Channels

Rules use the `:default` channel unless they specify `:channel`. Tokens on other channels remain in the lexer's output, so callers can inspect them. `parse` consumes only `:default` tokens unless given `:channels`, a list of channel names, or `:all`:

```lisp
(defparameter *lexer*
  (cnvrs:compile-lexer
   '((:name (+ (range #\a #\z)))
     (:space (+ (one-of " ")) :channel :trivia))))

(funcall *lexer* "x ")  ; => lexemes on :default and :trivia
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

## Implementation

Compilation builds an in-memory transition graph with rule calls, token edges, and epsilon edges. At a choice or repetition, prediction explores graph configurations with unbounded lookahead. A shared SLL DFA tries first; when alternatives need caller context, prediction retries with the active rule-return stack. DFA transitions are cached as input is encountered. Parsing then follows the selected path and constructs the tree.

Compilation rewrites direct left recursion into precedence levels before building the transition graph. It rejects indirect or zero-consumption rule cycles and repetitions whose body can match empty input. It has no semantic actions or external grammar syntax. Ambiguous alternatives use their written order. The DFA caches live on the compiled grammar object, so sharing one object across threads requires synchronization. File compilation and an external grammar syntax are future work.

## Tests

```sh
XDG_CACHE_HOME=/tmp/cnvrs-asdf-cache sbcl --non-interactive --eval '(require :asdf)' \
  --eval '(asdf:load-asd (truename "cnvrs.asd"))' \
  --eval '(asdf:test-system :cnvrs)'
```
