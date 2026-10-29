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

`parse` accepts a sequence of tokens: a string is a sequence of characters, while a list or vector can contain arbitrary token values. It consumes the whole input and returns `node` structs. Each node has a rule name, ordered children, and start/end token offsets. Children are literal tokens or nodes for referenced rules. Invalid grammars signal `cnvrs:grammar-error`; invalid input signals `cnvrs:parse-error` with position, token, and expected value readers.

## Implementation

Compilation builds an in-memory transition graph with rule calls, token edges, and epsilon edges. At a choice or repetition, prediction explores graph configurations with unbounded lookahead. A shared SLL DFA tries first; when alternatives need caller context, prediction retries with the active rule-return stack. DFA transitions are cached as input is encountered. Parsing then follows the selected path and constructs the tree.

This initial implementation rejects left-recursive or zero-consumption rule cycles and repetitions whose body can match empty input. It has no lexer, semantic actions, error recovery, direct-left-recursion rewrite, or external grammar syntax. Ambiguous alternatives use their written order. The DFA caches live on the compiled grammar object, so sharing one object across threads requires synchronization. File compilation and an external grammar syntax are future work.

## Tests

```sh
sbcl --non-interactive --eval '(require :asdf)' \
  --eval '(asdf:load-asd (truename "cnvrs.asd"))' \
  --eval '(asdf:test-system :cnvrs)'
```
