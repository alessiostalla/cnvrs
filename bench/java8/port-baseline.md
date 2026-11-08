# Initial Java-reference predictor baseline

Historical measurement before the native ATN factory port. See the
[current native-topology baseline](topology.md).

Measured 2026-11-08 on native ARM64 SBCL 2.4.0, with a 2 GiB heap, in the
uncommitted Java prediction-runtime port based on `b68a54f`.

The repository's Bench.java (2384 characters, 505 tokens) completes using the
normal Lisp grammar frontend and imported Java 8 grammar. All three fresh-parser
cold trials build trees ending at token 505. Each trial is followed by three
warm parses, also building trees. Grammar import, native rule compilation,
lexing, ATN lowering and pre-trial full GC are outside parse timing.

| Measurement | Result |
| --- | ---: |
| Median cold parse | 4555.5 ms |
| Cold allocation, median | 2600.8 MB |
| Median of per-trial warm mean times | 621.7 ms |
| Used native decision DFA roots | 142 |
| Native decision DFA states after each run | 1,430 |

Allocation is cumulative bytes consed, not peak live heap. This is one process,
three cold parser clones, and nine warm calls, establishing an initial baseline
rather than a cross-runtime performance claim. The earlier closure-local
prototype could not complete this file within its 20-second limit. No speculative
lookahead or caller-specific full-context cache is enabled in the port.

At this measurement, the native frontend's graph and precedence rewrites differed from Java's grammar
tool, so its decision/state counts are not expected to match a Java-generated
parser. The separate differential suite uses **identical Java-generated ATNs**
and matches **1,620 predictions**, every recorded DFA-state count, and error
outcomes across LL, SLL and exact-ambiguity modes. See the
[port map and boundary notes](../../src/antlr-runtime/README.md).

To reproduce from the repository root:

```sh
PROFILE_MODE=timing PROFILE_TRIALS=3 PROFILE_WARM_ITERATIONS=3 \
"$SBCL_BIN" --dynamic-space-size 2048 --script bench/java8/profile.lisp \
  "$JAVA8_DIR/Java8Lexer.g4" "$JAVA8_DIR/Java8Parser.g4"
```

[Raw results](port-baseline-results.txt). No changes in this port have been
committed.
