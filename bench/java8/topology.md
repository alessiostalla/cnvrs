# Java-shaped native ATN baseline

Measured 2026-11-08 on native ARM64 SBCL 2.4.0, 2 GiB heap, on
`chore/performance` with the uncommitted Java 4.13.2 runtime/frontend port.
The test suite verifies exact state/decision numbering and ordered graph edges
for the imported Java 8 parser: 2,843 states, including loop and precedence links.

The harness and 505-token Bench.java input match the [previous baseline](port-baseline.md).
Each of three fresh parser clones runs one cold tree parse and three warm tree
parses. Grammar import, native compilation, lexing, ATN adaptation and pre-trial
full GC are outside parse timing. Allocation is cumulative bytes consed.

| Measurement | Earlier native frontend | Java-shaped native frontend |
| --- | ---: | ---: |
| Median cold parse | 4,555.5 ms | 4,152.4 ms |
| Median cold allocation | 2,600.8 MB | 2,388.4 MB |
| Median of per-trial warm mean times | 621.7 ms | 601.9 ms |
| Used DFA roots | 142 | 133 |
| Cached DFA states | 1,430 | 1,350 |

This is a single-process before/after observation, not a Java-runtime speed
comparison. The frontend topology now matches Java; native execution still
invokes adaptive prediction for decisions for which Java's generated code may
use LL(1) lookahead. That is a remaining execution/code-generation difference,
not an explanation established by this timing run.

Reproduce from the repository root:

```sh
PROFILE_MODE=timing PROFILE_TRIALS=3 PROFILE_WARM_ITERATIONS=3 \
"$SBCL_BIN" --dynamic-space-size 2048 --script bench/java8/profile.lisp \
  test/fixtures/antlr-runtime/Java8Lexer.g4 test/fixtures/antlr-runtime/Java8Parser.g4
```

[Raw results](topology-results.txt).
