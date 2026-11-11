# Warm Java 8 profiling and compact prediction storage

Baseline: **a640f58**. Candidate: the uncommitted compact-context/hash-bucket
changes on that revision. Measured 2026-11-09 on Apple M1 Max, ARM64 SBCL 2.4.0;
reference runtime is ANTLR Java **4.13.2** on HotSpot 24. Inputs and grammars are
unchanged from the [matched Java comparison](optimized.md).

## Operation counts agree

After five complete training parses, one warm tree parse has exactly the same
13 counters in Java, baseline Lisp and candidate Lisp. The entire ordered stream
of **1431 decision/position pairs** also agrees. Matching counters include:

| Operation | Java = baseline = candidate |
| --- | ---: |
| ADAPTIVE | 1,431 |
| FALLBACK | 92 |
| START | 92 |
| FULL-START | 92 |
| REACH | 368 |
| FULL-REACH | 368 |
| REACH-INPUT | 17,378 |
| REACH-OUTPUT | 19,047 |
| CLOSURE-CHECK | 1,437,208 |
| CLOSURE-WORK | 1,430,300 |
| EPSILON | 1,737,404 |
| CONFIG-ADD | 316,043 |
| MERGE | 524,143 |

REACH-INPUT/OUTPUT sum configuration-set sizes over reach calls. EPSILON counts
`getEpsilonTarget` checks, including edges that do not produce an epsilon target.
There are no warm SLL reach computations on this trained input: all 368 reach
calls are full-context. Persistent caches remain **1160 DFA states and 24764
contexts**. Warm caches therefore still leave over a million closure visits;
Java performs that same measured work.

[Operation counts](profile-results/operations-summary.json) and the three raw
`*-operations.txt` logs save the counters and ordered calls. Instrumentation is
absent from the timing and profiling processes. The Java harness subclasses
ParserATNSimulator and compiles diagnostic copies of ATNConfigSet and
PredictionContext with counters at config addition and context merge.
[Source/jar hashes](profile-results/java-instrumentation.json) identify the
unmodified inputs to those copies. Lisp wraps non-inlined functions; the
self-recursive stop-state closure is instrumented inside a diagnostic function
body, because SBCL local recursive calls can bypass an fdefinition wrapper.
This avoids undercounting recursion.

## CPU and allocation profiles

Each [warm-profile.lisp](warm-profile.lisp) process trains for five complete
parses, performs a full GC outside measurement, then profiles 30 tree parses.
Lexing, grammar import/compilation, and ATN adaptation are excluded. CPU samples
use 1 ms intervals; allocation samples use approximately 64 KiB allocation
regions, with enough capacity to cover all 30 parses. These samples attribute
allocation regions to stacks, not exact individual object sizes. Inlining can
attribute configuration/context construction to closure-work.

Baseline CPU self samples prominently include memory clearing (`__bzero`, 18.5%),
configuration derivation (8.8%), closure-work (7.0%), EQL lookups (6.6%), vector
allocation (5.4%), array merging (4.9%) and context-node construction (3.9%).
Allocation-region samples principally point to closure-work/inlined construction,
configuration sets and hash-table growth, common-parent deduplication and array
merging. No single percentage establishes an exact cost breakdown.

GC alone does not explain the time gap: in the baseline CPU profile, GC accounts
for 0.628 of 7.720 elapsed seconds (8.1%). Much of the cost occurs while creating,
initializing, hashing and traversing temporary data, before collection. Candidate
GC falls to 0.446 seconds, but desktop contention makes direct profile timing
comparisons unreliable. Profiled CPU totals are 7.510 versus 7.408 seconds for
30 parses; this is not evidence of a large CPU speedup.

[Raw before/after CPU and allocation profiles](profile-results/) and
[parsed profiles](profile-results/profiles-summary.json) include the complete
flat and graph reports. They show remaining work in configuration construction,
array-context merges, hash lookup/growth and memory initialization. The profiles
do not isolate exactly how much of each cost differs from Java.

## Implemented changes

- Configuration-set membership, closure-busy membership and conflict grouping
  use integer-hash buckets. They compare the same configuration fields and full
  context equality after hashing, so collisions remain safe. Lookups no longer
  allocate temporary list/cons keys; bucket links are allocated on insertion.
  Lisp semantic forms retain structural equality.
- Singleton contexts now contain a parent, return state and cached hash directly.
  Array contexts retain their vectors. Internal indexed traversal avoids two
  one-element vectors per singleton; exported vector views remain available.
  Parent canonicalization preserves the graph and cached hashes.
- Prediction algorithms, alternative order, closure-local busy-set lifetime,
  prediction-local merge-cache lifetime and persistent SLL context caching are
  unchanged. Full-context predictions do not acquire persistent caches.

## Repeated measurements

The unchanged [types.lisp](types.lisp) harness runs three fresh processes per
version, sequentially, reversing order in pair two. Baseline is an isolated
`git archive a640f58` snapshot, with separate ASDF caches. It uses the same
cold/warm phase boundaries and seven warm batches as the previous declaration
round. [Raw logs and summary](profile-results/summary.json) preserve all samples.

| Warm phase | Before (ms) | After (ms) | Before bytes | After bytes |
| --- | ---: | ---: | ---: | ---: |
| iri lexer | 0.035675 | 0.035586 | 64,506.3 | 64,506.3 |
| iri parse-tree | 0.080130 | 0.074270 | 113,660.8 | 113,663.2 |
| java8 lexer | 0.139626 | 0.139244 | 294,325.8 | 294,328.6 |
| java8 parse-tree | 303.442500 | 249.622000 | 318,438,856.0 | 271,332,888.0 |

The robust result is **47.11 MB less allocation per warm Java 8 parse
(14.8%)**, from 318.44 to 271.33 MB.
This is cumulative allocation, not retained heap/RSS. Relative to the previous
Java measurement (200.96 MB), the allocation ratio drops from 1.58× to about
1.35×; no new Java timing measurement was performed in this round.

**Timing is noisy and the aggregate speedup must not be treated as a controlled
effect estimate.** Java 8 process medians before are
269.76 / 431.41 / 303.44 ms; after,
234.67 / 250.94 / 249.62 ms. An unrelated Kotlin compiler
was observed using roughly two CPU cores during pair two, alongside desktop
activity. All measurements are retained, rather than selectively dropping that
pair. The earlier, less contended exploratory CPU profiles suggested a modest
improvement; the final CPU profiles differ little. Allocation reduction is
consistent across runs; the CPU benefit needs a quiet-machine confirmation.

Both versions have matching token signatures and trained cache counts. IRI warm
allocation is effectively unchanged; its small timing change is not strong
evidence of a speed improvement. The main remaining candidates are temporary
ATN configuration storage and the allocation/lookup costs of array-context merges
and their maps, preserving Java's operations and cache lifetimes.

## Validation and reproduction

Normal and clean builds forcing **safety 3** each pass **11914 checks**. The 17
new checks cover compact singleton storage/views, singleton/array hashes and
merging, parent canonicalization, colliding configuration/context buckets and
structurally equal semantic forms. Existing Java hash, prediction, topology,
lexer, error and concurrency fixtures continue to pass. Candidate production
source hashes are saved in [source-hashes.json](profile-results/source-hashes.json).

```sh
# From either source directory; use an absolute harness for an archived baseline.
PROFILE_MODE=cpu XDG_CACHE_HOME=/tmp/cnvrs-profile-cache \
  /path/to/sbcl --dynamic-space-size 2048 --script /absolute/path/warm-profile.lisp \
  test/fixtures/runtime/Java8Lexer.g4 test/fixtures/runtime/Java8Parser.g4
# Repeat with PROFILE_MODE=alloc and PROFILE_MODE=operations, saving each log.
REFERENCE_JAR=/path/to/antlr-4.13.2-complete.jar REFERENCE_SOURCE_DIR=/path/to/runtime-sources \
  python3 bench/java-reference/operations.py bench/java-reference/profile-results
python3 bench/java-reference/profile-summary.py
python3 bench/java-reference/types-summary.py bench/java-reference/profile-results
```

The source directory must contain the matching 4.13.2 ATNConfigSet.java and
PredictionContext.java. Profiling/instrumentation helpers are benchmark-only.
All changes from this round are **uncommitted**.
