# CNVRS and ANTLR 4/Java: current differences

Updated 2026-11-09. CNVRS's parser prediction and lexer simulation runtimes are
ports of ANTLR Java 4.13.2. Native Lisp grammar forms and the optional `.g4`
importer use the same compiler and runtime. See the [CNVRS overview](../README.md)
and the [runtime source map and fidelity checks](../src/runtime/README.md).

## Prediction and execution

CNVRS compiles each parser rule independently for recognition and tree building.
Disjoint one-token alternatives use direct LL(1) dispatch. Other decisions use
shared SLL decision DFAs and retry with the active return stack on conflicts.
Full-context reach sets are recomputed; merge caches belong to one prediction.
Prediction contexts are canonicalized in the simulator's shared context cache.

The former eager token-prefix tries, caller-specific DFA starts, ordered
backtracking matcher, and observed-DFA compiler have been removed.
`:full-context-strategy` accepts only `:recompute`. `parser-decisions` exposes
the shared decision DFAs; the previous empty inspection views and unused
caller-context cache fields have been removed.

Parser prediction and recovery use the same runtime ATN analyzer. Recovery sees
through predicates and follows exact caller returns to compute expected tokens;
direct LL(1) analysis treats predicates as opaque and follows global rule stops.
The Lisp condition/restart recovery policy and tree builders remain native.

The lexer uses one ATN simulator for ordinary, recursive, nongreedy, and semantic
rules. It supports lazy per-mode DFAs, exact return contexts, speculative
predicates, action executors, maximal-match rewind, and the token-source
lifecycle for MORE/SKIP, modes, channels, token overrides, and EOF.

The runtime is compiled as part of the main `cnvrs` ASDF system, using the internal
`cnvrs/runtime` package. The `.g4` importer remains in `cnvrs/antlr4`.
The parser frontend maps arbitrary Lisp token values to runtime integer types.
Parser and lexer frontends share graph construction primitives, while their
simulators implement token prediction and longest-character-match policies.

## Remaining frontend and API differences

| Area | CNVRS | ANTLR 4.13.2/Java |
| --- | --- | --- |
| Grammar input | Lisp forms, with optional `.g4` subset import | `.g4` toolchain with generated target-language code |
| Build artifact | Compiled Lisp rule functions and loadable FASLs | Generated Java recognizers with serialized ATNs |
| Actions and predicates | Lisp callbacks; imported action/predicate blocks require explicit mappings | Embedded target-language code and semantic predicates |
| Attributes and options | No rule arguments/returns/locals; prequels retained as metadata; lexer `caseInsensitive` and explicit `tokenVocab` wiring supported | Broader grammar attributes, options, and import resolution |
| Native precedence | Recursive alternatives listed from low to high; `(right ...)` requests right association | Earlier recursive and prefix alternatives have higher precedence |
| Imported precedence | Source order and associativity preserved through `source-order-precedence` | Source-order precedence transformation |
| Entry-rule EOF | Selected entry must consume all input unless `:require-eof nil` | Rule methods require explicit grammar EOF to enforce whole-input recognition |
| Trees | Generic nodes, custom builders, and event hooks | Generated context classes, listeners, and visitors |
| Recovery | Conditions and restarts; optional automatic recovery | Default error strategy and replaceable listeners/strategies |
| Cache ownership | Per compiled object; clones share immutable graphs and start with fresh caches | Generated recognizers share decision DFAs and context caches across instances |

The `.g4` importer does not execute foreign code or prequel actions, load
ANTLR `import` declarations, read `.tokens` files, or search grammar paths.
Unsupported options and unmapped callbacks signal grammar errors. Token
vocabularies are resolved through an explicit registry of imported lexer
definitions. The upstream grammar-language fixtures are parsed as syntax;
their full conversion feature set is outside the importer.

Native offsets count Lisp characters (Unicode code points). Unicode properties
and case mappings are pinned in [unicode-data.sexp](../src/unicode-data.sexp).
Tree shape, error diagnostics, and recovered output remain CNVRS API behavior;
the runtime port does not make those APIs identical to generated Java recognizers.

## Validation and performance

`asdf:test-system :cnvrs` checks runtime prediction traces, contexts and hashes,
complete parser/lexer graph topology, direct LL(1) dispatch, token records,
action cursors, recovery positions, and DFA counts against frozen Java fixtures.
It also checks native compilation, FASLs, grammar composition, cache clearing,
and cloning. Java is needed only to regenerate reference fixtures.

Current paired benchmark and profiling records are in
[bench/java-reference](../bench/java-reference/README.md). Earlier measurements
in [bench/antlr4-grammar](../bench/antlr4-grammar/README.md) and
[bench/java8](../bench/java8/README.md) document historical implementations and
should not be treated as measurements of the current runtime.
