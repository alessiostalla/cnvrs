# Configuration-set and context-cache lookup

Baseline: **146e07c**, the committed stack-scoped configuration implementation.
Candidate: cheaper internal configuration bucket keys, inline context equality
fast paths, and bucket reuse during context-cache insertion. Native ARM64 SBCL
2.4.0, 2 GiB heap; unchanged IRI and Java 8 inputs and speed-3/safety-1 policy.

## Measured lookup traffic

One trained Java 8 parse performs **316,043 configuration-set additions**:
22,970 empty-bucket insertions and 293,073 single-candidate hits. All incoming
semantic contexts are empty (`T`). Both baseline and candidate have the same
bucket-size distribution on this input. Merge-cache lookup makes **522,671
calls**, with 283,523 hits; 129,801 hits have the exact same context objects as
the head entry's pair, in either order.

The shared canonical context cache is not consulted during this warm parse;
its work occurs while building SLL DFA states. A cold parse has 1,891,779
configuration-set additions and 3,201,424 merge-cache queries. Thus the warm
context-lookup target is the prediction-local merge cache, while canonical-cache
insertion changes primarily affect cold-cache work.

The diagnostic [probe](lookup-probe.lisp) records
[before](lookup-results/before-probe.txt) and
[after](lookup-results/after-probe.txt) traffic. Its context-get counts describe
helper invocations, not all underlying hash-table reads; insertion now uses a
shared bucket helper directly. Probe wrappers are absent from timing runs.

## Changes

- Configuration-set bucket keys use a bounded 32-bit field combiner instead of
  a full Murmur update/finalization sequence. The common empty-semantic case
  combines state and alternative directly; other cases also incorporate `sxhash`. The complete state,
  alternative, and semantic fields still decide equality after hashing. This
  changes only an internal bucket selector, including its use in visited-set
  buckets; Java-visible prediction-context hashes remain unchanged.
- `context-equal` inlines identity, NIL, and cached-hash checks. A separate
  structural comparison handles nonidentical equal-hash contexts. Recursive
  comparisons use the same inline guards, retaining singleton/array equivalence
  and complete parent comparisons after hash collisions.
- Context-cache insertion reads its bucket once and reuses it for lookup and
  linking a new entry. It no longer repeats the bucket read after a miss.

No table representation, canonical object identity, scratch-configuration
ownership, locks, prediction policy, or cache lifetime changed. Allocation is
expected to remain essentially unchanged; the target is lookup execution cost.

## Controlled before/after measurements

Three fresh processes per version run sequentially, reversing order in pair two.
Both source trees use the same absolute `types.lisp` harness and separate ASDF
caches. No diagnostic wrappers are active during timing.

| Java 8 tree parsing | Before | After | Reduction |
| --- | ---: | ---: | ---: |
| Warm elapsed | 112.21 ms | 98.35 ms | **12.4%** |
| Warm process CPU | 111.80 ms | 98.00 ms | **12.3%** |
| Warm allocation | 104.65 MB | 104.64 MB | effectively unchanged |
| Cold-cache elapsed | 786.64 ms | 696.03 ms | **11.5%** |
| Cold-cache allocation | 660.28 MB | 660.28 MB | unchanged |

Warm Java 8 parsing is **1.14× faster**. Before process medians are
112.21 / 112.13 / 113.36 ms; after medians are 98.03 / 98.35 / 99.56 ms.
Every pair improves, including CPU time. IRI parsing/lexing and Java 8 lexing
change by less than 2%; those small differences do not establish an improvement
or regression. Allocation is cumulative, not peak memory; MB is decimal.
This experiment measures the combined lookup changes and does not isolate
the contribution of each helper.

[Raw logs and numeric summary](lookup-results/summary.json),
[source/harness hashes and runtime metadata](lookup-results/environment.json).

## Fresh paired Java comparison

After the A/B, three fresh processes per runtime and grammar ran sequentially,
reversing runtime order in pair two. Java recognizers were regenerated with
ANTLR 4.13.2 and run on HotSpot 24; CNVRS used ARM64 SBCL 2.4.0. The unchanged
[paired harness](compare.sh) uses the same grammar/input files and a 2 GiB heap.

| Warm Java 8 phase | Java (ms) | CNVRS (ms) | CNVRS / Java |
| --- | ---: | ---: | ---: |
| Lexer | 0.023896 | 0.145000 | 6.07× |
| Recognition | 108.912688 | 98.663500 | 0.91× |
| Tree parse | 107.323063 | 97.674500 | 0.91× |
| Lexer + tree parse | 107.438563 | 98.381000 | 0.92× |

Tree parsing takes **9.0% less time** than Java on this input; warm allocation is
**104.64 MB versus 200.96 MB**. Cold-cache tree parsing is **693.72 versus
761.08 ms**. Java tree process medians are 107.32 / 107.49 / 107.27 ms; CNVRS
medians are 97.49 / 97.67 / 98.86 ms. The parser-only phases reuse prepared
tokens; lexing is measured separately.

IRI tree parsing remains **0.06998 versus 0.02719 ms** (2.57×); the IRI pipeline
is 0.10391 versus 0.03178 ms (3.27×). The paired run does not establish a general
Java/Lisp throughput ranking. Short lexer timings are more sensitive to warmup
and timer noise than the Java 8 parser timings.

All twelve processes have identical token signatures, with matching trained
lexer state/edge counts, parser DFA states, and context counts across runtimes.
Compilation, import, ATN adaptation, I/O, cache reset, and pre-cold full GC are
outside timers; per-call setup and measured-call GC are included.
[Full timing/allocation tables](lookup-java-results/summary.md),
[numeric summary](lookup-java-results/summary.json),
[environment and input/jar hashes](lookup-java-results/environment.txt),
[candidate source hashes](lookup-java-results/source-sha256.json).

## Correctness

Normal and separate clean forced-safety-3 builds each pass **12,296 checks**.
The 89 new checks cover real numeric configuration-key collisions, distinct
state/alternative pairs, structural semantic keys, signed fixnum endpoints,
NIL contexts, identity hits, singleton/array equality, nested context-hash
collisions, canonical insertion identity, and cache misses.
[Normal checks](lookup-results/checks-normal.txt),
[safety-3 checks](lookup-results/checks-safety3.txt).

Fresh baseline and candidate Lisp operation runs agree with the existing Java
4.13.2 reference on all **13 counters** and **1,431 ordered decision/position
pairs**. Java 8 retains 1,160 DFA states, 24,764 cached contexts, 92 full-context
fallbacks, 1,437,208 closure checks, 316,043 configuration additions, and 524,143
context merges. [Operation validation](lookup-results/operations-summary.json).
The Java counting reference is reused from the preceding rounds.

## Reproduction

```sh
mkdir -p /tmp/cnvrs-lookup-before
git archive 146e07c | tar -x -C /tmp/cnvrs-lookup-before
python3 bench/java-reference/storage-compare.py /tmp/cnvrs-lookup-before \
  --sbcl /path/to/native/sbcl --cache-root /tmp/cnvrs-lookup-cache \
  --results bench/java-reference/lookup-results
```

The same absolute harness runs from both source snapshots with separate ASDF
caches. Three fresh processes per version run sequentially, reversing order
in pair two. Warm results aggregate process median batch means; cold-cache
results aggregate nine calls after full GC outside the timer. Import,
compilation, ATN adaptation, I/O, cache reset, and pre-cold GC are excluded.
Per-call setup and GC during calls are included. These are fixed-input,
single-machine results.

To rerun the paired comparison:

```sh
REFERENCE_JAR=/path/to/antlr-4.13.2-complete.jar \
SBCL_BIN=/path/to/native/sbcl XDG_CACHE_HOME=/tmp/cnvrs-lookup-cache/after \
  bash bench/java-reference/compare.sh bench/java-reference/lookup-java-results
python3 bench/java-reference/summarize.py bench/java-reference/lookup-java-results
```
