# Optimized CNVRS versus ANTLR Java

Measured 2026-11-09 on Apple M1 Max, ARM64 SBCL 2.4.0 and Oracle HotSpot 24.
CNVRS revision **a640f58** includes direct LL(1) dispatch and the type/compiler-policy
optimizations. Java parsers and lexers were freshly generated with **ANTLR 4.13.2**
from the same checked-in grammars. These are new runs of both runtimes.

## Warm time per call

| Grammar | Phase | Java (ms) | CNVRS (ms) | CNVRS / Java |
| --- | --- | ---: | ---: | ---: |
| IRI | lexer | 0.007275 | 0.035120 | 4.83× |
| IRI | parse-none | 0.020298 | 0.034260 | 1.69× |
| IRI | parse-tree | 0.026263 | 0.072970 | 2.78× |
| IRI | pipeline-tree | 0.030308 | 0.109230 | 3.60× |
| Java 8 | lexer | 0.024084 | 0.150000 | 6.23× |
| Java 8 | parse-none | 103.839042 | 240.916000 | 2.32× |
| Java 8 | parse-tree | 104.917042 | 241.832500 | 2.30× |
| Java 8 | pipeline-tree | 106.650292 | 243.056000 | 2.28× |

Java 8 warm tree parsing takes **241.83 ms versus 104.92 ms**, a **2.30×** gap.
Allocation is **318.44 MB versus 200.96 MB** per tree parse, **1.58×**. Recognition
without trees takes nearly the same time and allocation, so tree construction
continues to account for little of the Java 8 cost. Cold-cache tree parsing takes
**1655.60 ms versus 740.64 ms**, a **2.24×** gap. Allocation is cumulative, not
retained heap or RSS; MB is decimal.

For comparison, the original lexer-port baseline measured a 4.54× Java 8 tree
parsing gap (522.22 ms versus 115.09 ms). Direct LL(1) dispatch and the type/policy
round together reduce the observed gap substantially. This historical comparison
uses separate sessions; the table above is the current matched measurement.
Lexer gaps remain larger (4.83× for IRI, 6.23× for Java 8), although lexing is a
small fraction of the Java 8 pipeline time on this input.

## Equivalence and method

All six processes per grammar produce identical token signatures (text,
start/end offsets, line/column and channel), require complete input consumption,
and reject lexer/parser errors. Every measured phase also has identical trained
lexer state/edge counts, parser DFA state counts and cached context counts across
runtimes. Pipeline caches are:

| Grammar | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | ---: | ---: | ---: | ---: |
| IRI | 31 | 89 | 5 | 20 |
| Java 8 | 111 | 367 | 1160 | 24764 |

These checks support equivalent execution on these inputs; they do not assert
identical Java/Lisp tree object layouts or establish general grammar performance.

The unchanged [comparison harness](compare.sh) runs three fresh processes per
runtime and grammar, sequentially, reversing order in the second pair. Inputs
are the same 217-character/216-token IRI and 2384-character/505-token Java 8
Bench.java. Lexing, recognition, tree parsing and the full pipeline are measured
separately. Parser-only phases reuse prepared tokens. Grammar import, code
compilation, ATN adaptation, cache reset and pre-cold full GC are excluded.
Per-call recognizer setup and GC during calls are included. Both runtimes have
a 2 GiB maximum heap.

Java warms each path for at most 2000 calls or five seconds; native-compiled Lisp
warms for 20 IRI calls or three Java 8 calls. Each process records three
cold-cache calls and seven warm batches (100 IRI calls or two Java 8 calls per
batch). Reported warm time is the median of the three process medians. Cold time
is the median of nine calls. Small lexer timings use short batches and are more
sensitive to timer granularity and desktop noise than the Java 8 parser result.
Java 8 tree medians by process are 108.65/104.92/104.89 ms in Java and
240.62/241.83/243.60 ms in CNVRS; see raw summaries for full precision.

[Full timing/allocation/variation tables](optimized-results/summary.md),
[machine-readable summary](optimized-results/summary.json),
[cache validation](optimized-results/validation.txt) and
[environment, revision and input/jar hashes](optimized-results/environment.txt)
are saved alongside all twelve raw process logs. Benchmark artifacts from this
run are uncommitted; production source was not changed after a640f58.

To reproduce from the repository root:

```sh
REFERENCE_JAR=/absolute/path/antlr-4.13.2-complete.jar \
SBCL_BIN=/absolute/path/sbcl XDG_CACHE_HOME=/tmp/cnvrs-comparison-cache \
  bash bench/java-reference/compare.sh /tmp/cnvrs-optimized-results
python3 bench/java-reference/summarize.py /tmp/cnvrs-optimized-results
```
