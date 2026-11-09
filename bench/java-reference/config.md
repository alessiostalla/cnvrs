# Transient parser configuration construction

Baseline: **7f3f87a**, the parent-deduplication/compact-merge-cache implementation.
Candidate: stack-scoped scratch configurations, retention snapshots and inlined
construction. Measured with native ARM64 SBCL 2.4.0, 2 GiB heap, unchanged IRI and
Java 8 inputs. The existing speed-3/safety-1 policy is retained.

## Ownership and construction

Closure traversal previously allocated a fresh heap `atn-config` for each
transition. Many configurations were discarded or merged into existing entries.

Each active `closure-work` frame now owns one `transient-atn-config` declared
`dynamic-extent`. Epsilon-target construction fills its fields and reuses it
across that frame's transitions. `derive-config` and epsilon-target construction
are inlined to remove the repeated constructor-call and keyword overhead.
Default derivation without a destination still returns a fresh ordinary config.

`config-set-add` and `busy-add` materialize an ordinary owned configuration only
when inserting a scratch object into a retaining set. Merges and visited hits
need no copy. Already-owned inputs retain their identity. Insertion returns the
owned object as a secondary value; active traversal follows that object so later
context merges remain visible, preserving the reference aliasing behavior.
The primary success/visited results remain unchanged.

The scratch object never enters a persistent DFA, configuration set, visited set,
or error condition. Context DAGs and semantic forms retain their existing
representations and lifetimes. No predictor decisions, merge keys, closure
worklists, full-context retry policy, cache lifetime, or thread ownership changed.

## Native code and tradeoffs

The [candidate disassembly](config-results/closure-work-after.asm) allocates the
64-byte scratch payload through the control-stack pointer (`ADD CSP, TMP, #64`)
and installs the transient structure layout there. It does not allocate that
scratch object through the heap TLAB. Retained configurations and prediction
contexts still use the heap.

Inlining grows `closure-work` from **1844 to 3264 bytes** in these builds.
[Baseline disassembly](config-results/closure-work-before.asm). Each active
closure frame also uses stack space for its scratch object. These are deliberate
code-size/stack-space tradeoffs for less transient heap allocation. Standard
Common Lisp declarations are used; no implementation-specific production
allocation intrinsics or safety-0 regions were introduced.

## Repeated before/after measurements

| Java 8 tree parsing | Before | After | Reduction |
| --- | ---: | ---: | ---: |
| Warm elapsed | 135.00 ms | 113.09 ms | **16.2%** |
| Warm process CPU | 134.54 ms | 112.72 ms | **16.2%** |
| Warm allocation | 194.73 MB | 104.65 MB | **46.3%** |
| Cold-cache elapsed | 965.24 ms | 792.85 ms | **17.9%** |
| Cold-cache allocation | 1197.07 MB | 660.28 MB | **44.8%** |

Warm Java 8 parsing is **1.19× faster**, saving **90.08 MB per call**. Allocation
is cumulative, not retained heap or RSS; MB is decimal. Before process warm
medians are 132.66 / 135.23 / 135.00 ms; after medians are
110.73 / 113.09 / 114.23 ms. Every pair improves, with a corresponding CPU-time
reduction. IRI tree parsing and the lexer medians change by less than 2%; those
small differences do not establish a speed improvement.

Against the [fresh Java reference](storage.md), the optimized 113.09 ms is
approximately **1.07×** Java's 106.14 ms. Allocated bytes are about **0.52×**
Java's 200.96 MB. Java was not retimed during this A/B, so these are comparisons
with that previous reference, not a new paired Java/candidate experiment.
Recognition-only and full-pipeline candidate timings were not measured here.

[All raw process logs and numeric summary](config-results/summary.json),
[source/harness hashes and runtime metadata](config-results/environment.json).

## Correctness and instrumentation

Fresh before/after operation runs agree with the previously regenerated Java
4.13.2 reference on all **13 counters** and all **1,431 ordered decision/position
pairs**, including 1,437,208 closure checks, 316,043 config additions, 524,143
context merges, and 92 full-context fallbacks. DFA states remain 1160 and cached
contexts 24764. [Validation](config-results/operations-summary.json).

The operation-count harness now preserves the secondary ownership return value.
Its diagnostic closure copy disables epsilon-target inlining so every visit
passes through the counter wrapper. Production timing runs contain no wrappers
or diagnostic recompilation. The Java reference counting log is reused from
the preceding storage round; both Lisp counting runs are fresh.

Normal and separate clean forced-safety-3 builds each pass **12,207 checks**.
New coverage checks scratch field initialization/reset, reuse after insertion,
visited-key integrity, retained identity shared between sets, subsequent context
merges visible to active traversal, GC with live scratch/owned objects, and
prediction failures containing only owned configurations.
[Normal checks](config-results/checks-normal.txt),
[safety-3 checks](config-results/checks-safety3.txt).

## Reproduction

```sh
mkdir -p /tmp/cnvrs-config-before
git archive 7f3f87a | tar -x -C /tmp/cnvrs-config-before
python3 bench/java-reference/storage-compare.py /tmp/cnvrs-config-before \
  --sbcl /path/to/native/sbcl --cache-root /tmp/cnvrs-config-cache \
  --results bench/java-reference/config-results
```

The same absolute `types.lisp` harness runs from both source trees with separate
ASDF caches. Three fresh processes per version run sequentially, reversing order
in pair two. Each process records three cold-cache calls after full GC outside
the timer and seven warm batches. Warm medians aggregate process median batch
means; cold medians aggregate nine calls. Import, compilation, ATN adaptation,
I/O, cache clearing, and pre-cold GC are excluded. Per-call setup and GC during
measured calls are included. This is a fixed-input, single-machine comparison.
