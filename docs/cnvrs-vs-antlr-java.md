# CNVRS and ANTLR 4/Java: current differences

Updated 2026-11-07. This compares the current CNVRS working tree with the
ANTLR 4.13.2 Java tool and runtime used by this repository's benchmark. Java is the
reference target here because the ANTLR tool is written in Java and the
measurements use its Java runtime; this is not a ranking of ANTLR targets.
ANTLR's tool generates code for multiple target languages. [ANTLR getting
started](https://github.com/antlr/antlr4/blob/4.13.2/doc/getting-started.md).

## Short version

Both systems use adaptive lookahead over transition graphs and cache DFA
transitions. CNVRS is a Common Lisp, in-process grammar compiler and parser
with a deliberately smaller language. ANTLR/Java is a `.g4` grammar toolchain
that generates Java recognizers backed by a mature runtime, a broader grammar
language, and more runtime facilities. CNVRS's `.g4` reader supports a subset
and should not be treated as an ANTLR-compatible replacement. See the
[CNVRS overview](../README.md) and [ANTLR grammar
structure](https://github.com/antlr/antlr4/blob/4.13.2/doc/grammars.md).

| Area | CNVRS now | ANTLR 4.13.2/Java |
| --- | --- | --- |
| Primary grammar input | Lisp rule forms via `compile-grammar`, `compile-lexer`, or complete `defparser` forms; optional `.g4` subset converter | `.g4` grammar files processed by the ANTLR tool |
| Build artifact | In-memory graphs and compiled Lisp rule runners; no generated source file | Generated Java lexer/parser classes, plus runtime ATN and DFA machinery |
| Parsing path | Compiled rule runner for ordinary strict parsing; general graph loop for recovery and custom builders | Generated recursive-descent rule methods; `ParserATNSimulator` predicts decisions. `ParserInterpreter` is also available to walk an ATN |
| Prediction | Direct one-token choices and bounded n-token specialization, then cached SLL DFA and caller-context retry | Generated direct checks where possible; adaptive SLL DFA and full-context ATN retry on conflict |
| Lexer | Character graph and DFA for ordinary rules; separate ordered matcher for recursive, nongreedy, or semantic rules | `LexerATNSimulator` with ATN/DFA simulation, lexer actions and predicates, including recursive rule calls |
| Trees | Generic `node` with rule, children, token offsets, optional label; custom builders and event hooks | Generated rule/alternative context classes, token nodes, listeners and visitors |
| Errors | Strict conditions by default; opt-in automatic recovery or caller-selected Common Lisp restarts | `DefaultErrorStrategy` recovers by default; listeners and replaceable error strategies |
| Runtime cache ownership | Per compiled object; `clone-compiled` shares graph but starts with empty caches | Generated Java parsers share decision DFAs and prediction-context cache across instances |

The ANTLR runtime descriptions above come from its [parser simulator](https://www.antlr.org/api/Java/org/antlr/v4/runtime/atn/ParserATNSimulator.html),
[parser interpreter](https://www.antlr.org/api/Java/org/antlr/v4/runtime/ParserInterpreter.html),
[lexer simulator](https://www.antlr.org/api/Java/org/antlr/v4/runtime/atn/LexerATNSimulator.html),
and [parser API](https://www.antlr.org/api/Java/org/antlr/v4/runtime/Parser.html).
The CNVRS paths are implemented in
[`src/cnvrs.lisp`](../src/cnvrs.lisp),
[`src/lexer.lisp`](../src/lexer.lisp), and
[`src/graph.lisp`](../src/graph.lisp).

## Prediction and execution

CNVRS builds parser states with token, negated-token, rule-call, and epsilon
edges. Each rule is compiled independently for recognition and node building;
rule calls use an immutable function table and a per-parse cursor state. It
chooses disjoint alternatives with compiled direct lookahead where possible. Contextual decisions can build arbitrary-depth token-prefix tries,
limited to 64 prefix edges and 4096 configuration-key visits by default.
Exhausting either budget caches a fallback for that context. Other decisions
use an SLL DFA, then retry prediction with the active return stack when caller context matters. Its default `:cached`
strategy retains a full-context DFA start for each decision and return stack;
`:recompute` is available. An optional `compile-cached-dfa` step turns observed
DFA paths into Lisp dispatch functions, with misses returning to adaptive
prediction. The grammar graph remains available for inspection. See
[`closure`, `predict`, and `compile-parser-runner`](../src/cnvrs.lisp) and
[`compile-cached-dfa`](../src/dfa-compiler.lisp).

ANTLR/Java's `ParserATNSimulator` builds and extends a context-independent
SLL DFA. On an SLL conflict requiring outer context, it rewinds and performs
full-context ATN simulation. It does **not** store those full-context results
as a separate DFA by return stack. This is a material algorithmic and cache
policy difference, not merely a different name for the same simulator.
[ANTLR `ParserATNSimulator` API](https://www.antlr.org/api/Java/org/antlr/v4/runtime/atn/ParserATNSimulator.html).
ANTLR also offers a separate `ParserInterpreter` that moves through the ATN;
CNVRS's normal parser loop is its closest analogue, though CNVRS does not
expose a separate public interpreter object.
[ANTLR `ParserInterpreter` API](https://www.antlr.org/api/Java/org/antlr/v4/runtime/ParserInterpreter.html).

The two CNVRS graphs now share a state base, edge type, construction helpers,
and closure worklist. Their policies remain distinct: the lexer searches for
the longest character match in its current mode, while the parser selects a
token alternative using rule-return context. This graph sharing does not make
their simulators interchangeable. See [`src/graph.lisp`](../src/graph.lisp).

## Grammar and semantic compatibility

- **Native grammar language.** CNVRS accepts Lisp forms and dynamically
  compiles them in the Lisp image. ANTLR consumes `.g4` files and generates
  target-language code. CNVRS can read `.g4` syntax and convert a supported
  subset, but it cannot compile arbitrary ANTLR grammars. The upstream
  ANTLRv4 lexer and parser grammar files are parsed as syntax in CNVRS tests;
  their full feature set is outside the converter. See
  [`src/antlr4-convert.lisp`](../src/antlr4-convert.lisp) and
  [ANTLR grammar structure](https://github.com/antlr/antlr4/blob/4.13.2/doc/grammars.md).

- **Actions, predicates, attributes, and options.** ANTLR parser rules can
  have arguments, returns, locals, embedded target-language actions, and
  semantic predicates; lexer rules can have actions and predicates. CNVRS's
  core has no semantic actions. The `.g4` converter rejects rule actions,
  predicates, rule arguments/returns/locals, and unsupported element or rule
  options. It preserves top-level `options`, `import`, `tokens`, `channels`,
  and named actions as metadata but does not execute actions, load imports,
  or apply options such as `caseInsensitive`. Parser `tokenVocab` wiring accepts
  an explicit registry of imported lexer definitions, resolves named tokens and
  unique literal aliases, and attaches the lexer; it does not load `.tokens`
  files or search grammar paths. Thus accepting
  the syntax is not the same as implementing its semantics. See
  [ANTLR parser rules](https://github.com/antlr/antlr4/blob/4.13.2/doc/parser-rules.md),
  [ANTLR lexer rules](https://github.com/antlr/antlr4/blob/4.13.2/doc/lexer-rules.md),
  and [`src/antlr4-convert.lisp`](../src/antlr4-convert.lisp).

- **Direct left recursion.** Both handle direct left recursion and reject
  indirect left recursion. CNVRS rewrites its native expression rules into
  precedence levels and lists recursive alternatives from *lowest to
  highest* precedence; `(right ...)` requests right associativity. ANTLR's
  direct-left-recursion rewrite assigns higher precedence to earlier
  recursive and prefix alternatives and supports `<assoc=right>`. The `.g4`
  converter keeps source order for a dedicated ANTLR precedence rewrite and
  maps recursive `<assoc=right>` to right association; it also accepts
  explicit `<assoc=left>`. Primary alternatives retain their source order.
  This matches ANTLR/Java's tree nesting on the checked mixed-precedence and
  right-associative expressions, without changing native Lisp grammar order.
  See [CNVRS direct left recursion](../README.md#direct-left-recursion),
  [`rewrite-left-recursion`](../src/cnvrs.lisp), and
  [ANTLR left recursion](https://github.com/antlr/antlr4/blob/4.13.2/doc/left-recursion.md).
  ANTLR's [published expression example](https://github.com/antlr/antlr4/blob/4.13.2/doc/getting-started.md)
  lists multiplication before addition and shows the corresponding tree.

- **Lexer coverage.** Both support modes, skips, channels, character ranges,
  nongreedy repetition, and direct or indirect lexer recursion after consuming
  input. CNVRS rejects rule cycles that can recur without consuming a character;
  ANTLR 4.13.2/Java also rejects the tested left-recursive lexer rule with
  `error(119)`. CNVRS handles rules that reach recursion with an ordered,
  backtracking matcher, while ANTLR/Java handles recursive rule calls in its
  lexer ATN simulator and caches DFA transitions. Thus recursive matching is
  supported in CNVRS, but the execution and caching paths differ. ANTLR also
  supports commands such as `more` and `type(...)`; CNVRS's converter supports
  `skip`, `channel`, `pushMode`, `popMode`, and `mode`, but not `more` or `type`.
  CNVRS restricts where converted commands can appear. See
  [`src/lexer.lisp`](../src/lexer.lisp),
  [`src/antlr4-convert.lisp`](../src/antlr4-convert.lisp),
  [ANTLR lexer rules](https://github.com/antlr/antlr4/blob/4.13.2/doc/lexer-rules.md),
  and [ANTLR's Java lexer simulator](https://github.com/antlr/antlr4/blob/4.13.2/runtime/Java/src/org/antlr/v4/runtime/atn/LexerATNSimulator.java).

  A paired ANTLR 4.13.2/Java and CNVRS check of a recursive nested-brace
  fragment produced the same tokens for `{a{b}c}{a}x`: the two brace blocks
  and then `x`. Both selected the earlier `BLOCK` rule over an equal-length
  `SHORT` rule for `{a}`. Both matched `[([x])]` as one token with mutually
  recursive rules that have consuming prefixes. These focused checks do not
  establish equivalence for all recursive grammars, especially when nongreedy
  choices, predicates, or actions interact with recursion. ANTLR's own
  [recursive lexer example](https://github.com/antlr/antlr4/blob/4.13.2/doc/lexer-rules.md#recursive-lexer-rules)
  uses nested brace blocks.

- **Entry-rule EOF.** `cnvrs:parse` requires the selected entry rule to
  consume all input by default; `:require-eof nil` permits a prefix. Calling
  a generated ANTLR rule method does not itself assert EOF: the grammar must
  include `EOF` where full-input recognition is required. CNVRS maps a final
  `.g4` `EOF` marker to its parse-time whole-input check. See
  [CNVRS rule selection](../README.md#defining-grammars-with-macros) and
  [ANTLR parser rules](https://github.com/antlr/antlr4/blob/4.13.2/doc/parser-rules.md).

- **Tree shape and recovery.** CNVRS returns generic nodes and recovery
  records; labels become node labels or labeled wrapper nodes. ANTLR/Java
  generates typed context classes, including distinct alternative context
  classes, with listeners and optional visitors. CNVRS signals a condition
  on invalid input unless `:recover t` or a caller's restart handles it.
  ANTLR's default strategy attempts single-token insertion/deletion and
  resynchronization. The two recovered trees and diagnostics should not be
  expected to match. See [CNVRS recovery](../README.md#parse-errors-and-recovery),
  [ANTLR parser rules](https://github.com/antlr/antlr4/blob/4.13.2/doc/parser-rules.md),
  and [ANTLR `DefaultErrorStrategy`](https://www.antlr.org/api/Java/org/antlr/v4/runtime/DefaultErrorStrategy.html).

## Measured performance, with limits

The [2026-11-04 benchmark](../bench/antlr4-grammar/README.md#rerun-after-shared-graph-primitives-2026-11-04)
parsed seven selected `grammars-v4` `.g4` source files as **data**, using
CNVRS's built-in grammar for the ANTLR grammar language and ANTLR 4.13.2's
generated Java lexer/parser for that same language. With tree construction
off, four fresh processes per runtime gave median sums of per-file timings
of **3.128 ms for CNVRS** and **1.349 ms for ANTLR/Java**, a **2.32×** ratio.
CNVRS process sums ranged from 3.105 to 3.165 ms; Java ranged from 1.214 to
1.470 ms. Both accepted all seven files. The run used native ARM64 SBCL 2.4.0
and Java 24. It did not generate or run parsers from the seven sampled
grammars, include grammar compilation time, or isolate the effect of the
shared-graph refactor. Results for other languages and grammars may differ.

## Practical reading

Use CNVRS when an in-image Lisp grammar, Lisp-native tree building and
restarts, or inspectable and cloneable parser objects fit the task. Use the
ANTLR/Java toolchain when a `.g4` grammar needs ANTLR's full grammar semantics,
generated Java APIs, or its established runtime
facilities. For a grammar being moved between them, verify accepted inputs,
operator precedence, tree shape, EOF behavior, token channels, and recovery
behavior with paired tests; syntax conversion alone is not a parity check.
