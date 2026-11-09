# IRI and Java 8 versus ANTLR Java

The [native-code audit](disassembly.md) disassembles closure checks, configuration
insertion, context merging and their helpers, with controlled type experiments.

The [warm profiling follow-up](profile.md) compares Java/Lisp operation counts
and measures compact singleton contexts and allocation-free lookup keys.

The [latest matched Java comparison](optimized.md) benchmarks optimized revision
`a640f58` against freshly generated ANTLR 4.13.2 parsers and lexers.

The [type declarations and compiler-policy follow-up](types.md) measures the next
optimization round against the committed LL(1) baseline.

The [direct LL(1) follow-up](ll1.md) removes the extra adaptive decisions described
in this baseline and records a controlled before/after performance comparison.

This comparison measures CNVRS commit `152100f` (Java lexer/runtime port) against
ANTLR **4.13.2**, generated from the same checked-in grammars. Runs use native
ARM64 SBCL 2.4.0 and Oracle HotSpot 24 on an Apple M1 Max. Measurements started
2026-11-09 Europe/Rome (2026-11-08 UTC). No production changes were made
for this benchmark. Harnesses and results are separate from the lexer commit.

## Results

Warm-cache median time per call, in milliseconds:

| Grammar | Phase | ANTLR Java | CNVRS | CNVRS / Java |
| --- | --- | ---: | ---: | ---: |
| IRI | Lexer | 0.00618 | 0.04694 | 7.60× |
| IRI | Recognition only | 0.02170 | 0.16761 | 7.73× |
| IRI | Parse with tree | 0.02810 | 0.22158 | 7.89× |
| IRI | Lexer + parse with tree | 0.03324 | 0.27128 | 8.16× |
| Java 8 | Lexer | 0.02325 | 0.20700 | 8.90× |
| Java 8 | Recognition only | 114.72 | 522.95 | 4.56× |
| Java 8 | Parse with tree | 115.09 | 522.22 | 4.54× |
| Java 8 | Lexer + parse with tree | 114.75 | 521.29 | 4.54× |

For Java 8, disabling tree building barely changes timing or allocation. Warm
tree parses allocate 367.2 MB in CNVRS versus 201.0 MB in Java (1.83×); cold-cache
tree parses take 3,682 ms versus 806 ms (4.57×), allocating 2,386 MB versus
1,254 MB. Allocation is cumulative, not peak heap. Lexer throughput has a larger
relative gap, but lexing takes about 0.04% of CNVRS's Java 8 pipeline time on this
input. Parser work dominates. For IRI, lexing is about 17% of pipeline time.

CNVRS's per-process warm Java 8 tree medians were 521.26, 522.22 and 526.07 ms;
Java's were 114.14, 115.09 and 115.43 ms. IRI tree medians were 0.22039–0.22339 ms
in CNVRS and 0.02555–0.02871 ms in Java. Separately measured pipeline and parser
medians can invert slightly because their variation exceeds the small lexer cost.

All six processes per grammar produced identical token signatures. Both runtimes
learned exactly 31 lexer states / 89 ASCII edges for IRI, and 111 states / 367
edges for Java 8. The parser caches differ: IRI has 5 Java states versus 56 Lisp
states; Java 8 has 1,160 versus 1,350. Java's direct LL(1) generated checks versus
CNVRS's more frequent adaptive predictions remain an execution difference. These
measurements do not isolate how much of the slowdown comes from that difference,
configuration/object handling, or GC.

[Full cold/warm, allocation, variation and cache tables](results/summary.md),
[machine-readable summary](results/summary.json), and raw per-process logs in
[results](results/).

## Inputs and validation

- IRI: the unchanged `test/fixtures/IRI.g4`, entry `parse`; the existing benchmark's
  fixed 217-character IRI, 216 tokens, now saved as [iri.txt](iri.txt).
- Java 8: the checked-in split Java8Lexer/Java8Parser grammars, entry
  `compilationUnit`; [Bench.java](../antlr4-grammar/Bench.java), 2,384 characters,
  505 tokens.
- Both runtimes require full input consumption. Java throws on any lexer/parser
  error. Lisp uses its strict condition behavior and asserts token counts and
  tree endpoints. A common 64-bit token signature checks exact token text,
  half-open offsets, line/column and channel across all six processes per grammar;
  symbol/token-number differences are excluded from that signature.
- Inputs, grammar files, pinned jar hash, machine, runtime versions and source
  revision are recorded in [results/environment.txt](results/environment.txt).

## Method

Four phases are measured independently:

1. `lexer`: source string to buffered tokens, including lexer construction/cursor
   initialization. Java produces CommonTokenStream including EOF; Lisp produces
   its usual lexeme vector without EOF.
2. `parse-none`: prepared tokens to complete recognition, tree building disabled.
3. `parse-tree`: prepared tokens to a complete native parse tree.
4. `pipeline-tree`: fresh tokenization plus tree-building parse.

File I/O, grammar import/compilation, Java generation/deserialization and Lisp ATN
adaptation are outside every timer. Parser-only runs reuse the prepared tokens;
lexing is not accidentally charged to prediction. Per-invocation parser/lexer
objects and cursor reset are inside timers. Trees have their respective Java
and Lisp representations, not identical object layouts.

Three fresh JVMs and three fresh SBCL processes are run per grammar, sequentially.
Runtime order is reversed in the second pair. Java uses `-Xms256m -Xmx2g`, SBCL
`--dynamic-space-size 2048`. An abandoned historical profiler was stopped before
recorded measurements; the benchmark runner never runs Java/Lisp concurrently.

Each phase records an initial timed call, then warms its execution path. Java
warmup runs at most 2,000 iterations or until five seconds have elapsed. Lisp
code is already native compiled; warmup uses 20 IRI calls or three Java 8 calls.
Each process then measures three calls with empty DFA/context caches and explicit
full GC outside the timer. Both compiled Lisp lexer and parser are explicitly
cleared: the split Java 8 parser retains a lexer definition, which is not reset
by `clear-cache` on the parser alone. Reset/allocation of DFA arrays is excluded
in both runtimes. These are cold-*cache*, warm-runtime samples, not startup times.

Warm measurements use seven batches of 100 IRI calls or two Java 8 calls. Caches
are trained by the final cold sample and one additional call before batching.
The summary takes each process's median batch mean, then the median of those
three medians. Cold values are the median of nine samples. GC during measured
calls is included. Warm allocation uses the analogous medians; these are
cumulative bytes allocated per call, not retained heap. Java reads per-thread
ThreadMXBean allocation; SBCL reads `get-bytes-consed`, which has allocation-buffer
granularity. Benchmarks have no user worker threads.

Java's generated parser uses direct LL(1) tests for many choices. CNVRS currently
uses adaptive prediction at more native multi-edge states. Different trained
parser DFA counts therefore do not by themselves indicate a simulator mismatch.
The lexer uses the same mode DFA strategy and should have equal state/edge counts.

## Reproduce

From the repository root with Java 24, the pinned jar and Lisp dependencies:

```sh
ANTLR_JAR=/absolute/path/antlr-4.13.2-complete.jar \
SBCL_BIN=/absolute/path/native/sbcl \
XDG_CACHE_HOME=/tmp/cnvrs-benchmark-cache \
  bash bench/antlr-java/compare.sh /tmp/antlr-java-results
python3 bench/antlr-java/summarize.py /tmp/antlr-java-results
```

The runner generates Java sources in a fresh temporary directory and removes it
on exit. [Benchmark.java](Benchmark.java) and [benchmark.lisp](benchmark.lisp)
implement the same phase boundaries. [summarize.py](summarize.py) rejects incomplete
logs, differing token signatures and varying cache counts before producing
`summary.json`. The checked-in results are raw logs and derived summaries.

This fixed-input, single-machine baseline does not establish general parser
throughput or isolate individual runtime/representation costs.
