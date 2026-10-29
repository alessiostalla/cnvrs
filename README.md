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

`parse` accepts a sequence of tokens: a string is a sequence of characters, while a list or vector can contain arbitrary token values. It consumes the whole input and returns `node` structs. Each node has a rule name, ordered children, and start/end token offsets. Children are literal tokens or nodes for referenced rules. Invalid grammars signal `cnvrs:grammar-error`.

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

This initial implementation rejects left-recursive or zero-consumption rule cycles and repetitions whose body can match empty input. It has no lexer, semantic actions, direct-left-recursion rewrite, or external grammar syntax. Ambiguous alternatives use their written order. The DFA caches live on the compiled grammar object, so sharing one object across threads requires synchronization. File compilation and an external grammar syntax are future work.

## Tests

```sh
sbcl --non-interactive --eval '(require :asdf)' \
  --eval '(asdf:load-asd (truename "cnvrs.asd"))' \
  --eval '(asdf:test-system :cnvrs)'
```
