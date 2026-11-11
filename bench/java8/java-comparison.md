# CNVRS versus ANTLR Java: Java 8 parser

Measured 2026-11-08 on the same ARM64 macOS machine, sequentially without
concurrent benchmark runs. CNVRS is the uncommitted `chore/performance`
Java-reference runtime and native-ATN port based on `b68a54f`.
Java is Oracle HotSpot 24 (`24+36-3646`); Lisp is native ARM64 SBCL 2.4.0.

Both parse the same repository `bench/antlr4-grammar/Bench.java`: 2,384
characters, 505 visible tokens. Both build parse trees and require complete
input consumption. The generated Java parser and native Lisp frontend use the
same checked-in Java 8 grammar snapshots, ANTLR 4.13.2, and 2,843-state ATN
topology. Tree objects have their respective host-language representations.

## Results

| Measurement | ANTLR Java | CNVRS / SBCL | CNVRS / Java |
| --- | ---: | ---: | ---: |
| Cold DFA parse, median | 891.7 ms | 4122.9 ms | 4.62× |
| Warm parse, median of run means | 123.9 ms | 575.8 ms | 4.65× |
| Cold allocation, median | 1,254.4 MB | 2,388.4 MB | 1.90× |
| Warm allocation per parse | 201.0 MB | 367.2 MB | 1.83× |
| Used decision DFA roots | 66 | 133 | |
| Cached DFA states | 1,160 | 1,350 | |

Java's per-process warm means were 122.7, 123.9 and 128.1 ms.
CNVRS's per-clone warm means were 575.8, 567.7 and 583.7 ms.
Java's first parse before JVM warmup had a median of 1,064.5 ms;
process startup, grammar loading and lexing were still outside that timer.

On this input CNVRS is about **4.6× slower**, with **1.83× the warm allocation**.
Java also allocates approximately 201 MB per warm parse, so the large allocation
cost is present in the reference parser as well. These are cumulative allocation
counts, not peak live heap or resident memory.

## Measurement method

- Parsing only: source reading, lexing, token buffering, grammar/code compilation,
  ATN deserialization/adaptation, DFA-array construction and explicit pre-cold
  garbage collection are excluded. Cursor reset and per-parse execution objects
  are included. The JVM and SBCL both have a 2 GiB maximum heap; Java uses
  `-Xms256m -Xmx2g`, SBCL `--dynamic-space-size 2048`.
- Java: three fresh JVM processes. Each records its first parse, warms the JVM
  and prediction caches for at least five seconds (maximum 2,000 parses), then
  measures three fresh-DFA/fresh-context-cache parses. Warm timing uses twenty
  batches of ten parses per process, sharing its warmed DFA/context cache.
  The cold table is the median of nine samples; warm is the median of the
  three process means. Allocation uses `ThreadMXBean` on the parsing thread.
- CNVRS: three fresh parser clones in one SBCL process, with a fresh simulator,
  empty DFAs/context cache and full GC before each cold timer. Each cold parse
  is followed by ten warm tree parses sharing that clone's caches. Cold is the
  median of three samples; warm is the median of three ten-parse means.
  Allocation uses `sb-ext:get-bytes-consed`.
- Each Java parse checks syntax-error count, EOF and token endpoint; every
  CNVRS cold parse reports endpoint 505 and all parses require EOF.

The execution paths still differ despite identical ATN topology. Java's generated
parser uses direct LL(1) checks for some decisions; CNVRS currently asks adaptive
prediction at every multi-edge state. The 66 versus 133 used DFA roots demonstrate
this difference. The timing does not isolate how much of the gap comes from that,
Lisp runtime overhead, object representation or garbage collection.

This is a small, fixed-source baseline, not a general throughput claim across
Java programs. No production parser changes were made for this benchmark.

## Reproduce

From the repository root, using the pinned complete jar:

```sh
ANTLR_JAR=/absolute/path/antlr-4.13.2-complete.jar \
SBCL_BIN=/absolute/path/sbcl \
XDG_CACHE_HOME=/tmp/cnvrs-benchmark-cache \
  bash bench/java8/compare-java.sh /tmp/java8-comparison-results
```

The runner regenerates the Java parser from the checked-in grammars in a temporary
directory. It requires a modern JDK (measured with JDK 24) and the existing Lisp
build dependencies. [Java harness](Java8Benchmark.java),
[runner](compare-java.sh), [CNVRS raw results](java-comparison-results/cnvrs.txt),
[Java run 1](java-comparison-results/java-1.txt),
[run 2](java-comparison-results/java-2.txt),
[run 3](java-comparison-results/java-3.txt).
