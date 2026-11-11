# Fresh Java comparison and context-storage optimization

Measured 2026-11-09 with native ARM64 SBCL 2.4.0 and HotSpot 24, using
ANTLR Java 4.13.2 and the unchanged IRI and Java 8 fixtures. The starting revision
is **85fbde9**, after integration of the runtime into the main system.

## Fresh paired baseline

Three fresh processes per runtime and grammar, sequential, reversing runtime
order in pair two. Java recognizers were freshly generated. The established
[comparison harness](compare.sh) measures lexing, recognition, tree parsing,
and the complete pipeline separately. Compilation, import, ATN adaptation,
file I/O, cache reset, and pre-cold full GC are outside the timers. Per-call
recognizer setup and GC during measured calls are included.

| Warm phase | Java (ms) | CNVRS (ms) | CNVRS / Java |
| --- | ---: | ---: | ---: |
| IRI lexer | 0.006786 | 0.033840 | 4.99× |
| IRI recognition | 0.020803 | 0.031230 | 1.50× |
| IRI tree parse | 0.026996 | 0.069470 | 2.57× |
| IRI pipeline | 0.031430 | 0.103560 | 3.29× |
| Java 8 lexer | 0.024146 | 0.147000 | 6.09× |
| Java 8 recognition | 107.116709 | 177.835500 | 1.66× |
| Java 8 tree parse | 106.137271 | 183.641000 | 1.73× |
| Java 8 pipeline | 107.227021 | 186.633500 | 1.74× |

Warm Java 8 tree allocation is **263.32 MB versus Java's 200.96 MB** per call.
Cold-cache tree parsing takes **1272.45 versus 755.54 ms**. Allocation is
cumulative, not retained heap or RSS; MB is decimal.

All twelve processes agree on token signatures. Trained cache counts agree
across runtimes and processes: IRI has 31 lexer states/89 edges, 5 parser states,
and 20 contexts; Java 8 has 111 lexer states/367 edges, 1160 parser states,
and 24764 contexts. [Raw logs and summaries](fresh-results/summary.md),
[numeric summary](fresh-results/summary.json), and
[environment and input hashes](fresh-results/environment.txt) identify this run.
The harness tolerates sandbox denial of the optional CPU-model sysctl; that
metadata field is marked unavailable rather than aborting the benchmark.

## Allocation probe and changes

A diagnostic warm Java 8 parse records **132,818 parent-canonicalization calls**,
with result arrays ranging from 2 to 14 entries. Previously each call allocated
a temporary context hash table and bucket links. Merge-cache lookup runs
522,671 times, with 283,523 hits and 239,067 puts; observed buckets have zero or
one entry. These are diagnostic counts, excluded from timing runs.
[Probe](storage-probe.lisp), [recorded baseline](storage-results/before-probe.txt).

Two internal storage changes address that traffic:

- Canonicalize parent arrays of at most 16 entries in place, retaining the first
  structurally equal parent. Larger arrays retain hashed canonicalization to
  bound the quadratic scan. No temporary table is needed for the small case.
- Store each merge-cache result as one typed linked entry rather than a
  three-cons list plus a bucket cons. Pair hashing, symmetric lookup, collision
  handling, structural equality, and prediction-local cache lifetime are unchanged.

No predictor decision selection, configuration-set merge semantics, full-context
retry policy, persistent memoization, or safety level was changed.

## Controlled before/after measurements

Three fresh processes per version ran sequentially, reversing order in pair two.
Both source trees used the same absolute [types.lisp](types.lisp) harness with
separate ASDF caches. Each process measured three cold-cache calls and seven
warm batches. Results are medians of process median batch means; cold results
are medians of nine calls. No profiling wrappers were active during timing.

| Java 8 tree parsing | Before | After | Reduction |
| --- | ---: | ---: | ---: |
| Warm elapsed | 179.59 ms | 133.09 ms | **25.9%** |
| Warm process CPU | 179.30 ms | 132.58 ms | **26.1%** |
| Warm allocation | 263.32 MB | 194.73 MB | **26.0%** |
| Cold-cache elapsed | 1263.32 ms | 953.92 ms | **24.5%** |
| Cold-cache allocation | 1629.93 MB | 1197.07 MB | **26.6%** |

This is **1.35× faster**, saving **68.59 MB per warm Java 8 parse**.
Before process medians are 178.92 / 180.13 / 179.59 ms; after medians are
133.09 / 131.43 / 134.37 ms. Improvement appears in every pair and in both
elapsed and CPU time. IRI parsing and both lexer results change by less than
1%; those changes do not establish a speed improvement.

The optimized 133.09 ms is approximately **1.25×** the fresh Java reference's
106.14 ms; optimized allocation is approximately **0.97×** Java's 200.96 MB.
These ratios use the Java run above, followed by the separate controlled Lisp
A/B; Java was not retimed during that A/B. Recognition and full-pipeline timings
were measured in the paired baseline, not repeated for the candidate. Small
lexing timings vary between harnesses because batch sizes differ.

[Raw logs and numeric summary](storage-results/summary.json),
[source hashes and runtime metadata](storage-results/environment.json).
These results support a storage/lookup improvement on the measured Java 8 input,
not a general throughput or peak-memory claim.

## Validation

Fresh Java, baseline Lisp, and optimized Lisp runs agree on all **13 prediction
operation counts** and all **1,431 ordered decision/position pairs**, with 1,160
DFA states and 24,764 cached contexts. They retain 92 full-context fallbacks,
368 reach computations, 1,437,208 closure checks, 316,043 configuration additions,
and 524,143 context merges. [Operation validation](storage-results/operations-summary.json).

Normal and separate clean builds forcing **safety 3** each pass **12,182 checks**.
The 109 new checks exercise colliding and reversed merge-cache pairs,
structurally equal objects, cache misses and replacement, NIL paths, first-parent
identity, and canonicalization on both sides of the small-array boundary.
[Normal](storage-results/checks-normal.txt), [safety 3](storage-results/checks-safety3.txt).

## Remaining warm Java 8 costs

Fresh CPU and allocation profiles of revision **7f3f87a** use the same harness:
five training parses, a full GC, then 30 tree parses of prepared Java 8 tokens.
The runtime source hashes still match the measured storage candidate. These
profiles are diagnostic and are separate from the uninstrumented timing results.

CPU self samples put memory zeroing (`__bzero`) at about 22%, `derive-config`
at 12%, closure traversal at 11%, EQL hash lookup at 7%, and context equality
at 5%. Smaller costs include singleton construction, vector allocation, array
merging, configuration-set addition, and hash-table growth. GC accounts for
0.208 of 3.970 elapsed seconds (about 5%). Allocation-region sampling primarily
attributes allocations to closure-work and its inlined construction paths;
these are stack/region samples, not exact per-object byte accounting.
[CPU profile](storage-results/after-cpu.txt),
[allocation profile](storage-results/after-alloc.txt).

The measured algorithm-operation counts match Java, so the remaining evidence
points to the cost of executing those operations, including transient config
construction and initialization, hashed membership, and structural context
comparison. The 92 full-context retries still perform about 1.44 million closure
checks on a warm parse; Java performs the same measured work. Reducing those
counts through additional persistent caches would change the reference policy.

Total allocated bytes are now slightly below the prior Java reference, so excess
byte volume alone cannot explain the timing gap. Similar byte totals need not
imply similar object counts, allocation/initialization costs, or cache locality.
A matched Java CPU profile is still needed to attribute the approximately 27 ms
remaining difference to particular costs. The percentages above describe where
Lisp spends sampled CPU time, not percentages of that difference. This diagnosis
covers the Java 8 parser; the separate IRI/tree and lexer gaps require their own
profiles.

## Reproduction

```sh
REFERENCE_JAR=/path/to/antlr-4.13.2-complete.jar \
SBCL_BIN=/path/to/native/sbcl XDG_CACHE_HOME=/tmp/cnvrs-fresh-cache \
  bash bench/java-reference/compare.sh /tmp/cnvrs-fresh-results
python3 bench/java-reference/summarize.py /tmp/cnvrs-fresh-results

mkdir -p /tmp/cnvrs-storage-before
# Extract the baseline without changing the working tree.
git archive 85fbde9 | tar -x -C /tmp/cnvrs-storage-before
python3 bench/java-reference/storage-compare.py /tmp/cnvrs-storage-before \
  --sbcl /path/to/native/sbcl --cache-root /tmp/cnvrs-storage-cache
```

The before/after runner uses the same absolute harness with separate source
snapshots and ASDF caches, three fresh processes per version, reversing order
in pair two. It records elapsed time, process CPU time, cumulative allocation,
token signatures, cache counts, and source hashes. All benchmark processes run
sequentially. These are fixed-input, single-machine results.
