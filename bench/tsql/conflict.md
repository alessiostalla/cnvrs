# Compact conflict grouping and temporary prediction storage

Baseline: **66ae344**. Candidate: the uncommitted changes identified by
[source and harness hashes](conflict-results/environment.json).
Measured 2026-11-10 on native ARM64 SBCL 2.4.0, with 2,048 MiB heaps.

Warm T-SQL SELECT recognition allocates **243.48 → 182.21 MB per call**,
a **25.2% reduction**. All three paired processes improve in CPU and elapsed
time: CPU reductions are **9.9%, 20.4%, and 13.0%**; elapsed reductions are
**7.3%, 26.3%, and 17.5%**. The median paired reductions are therefore
**13.0% CPU / 17.5% elapsed**. Allocation is stable across all six processes.

| Pair | Before elapsed ms | After elapsed ms | Before CPU ms | After CPU ms |
| --- | ---: | ---: | ---: | ---: |
| 1 | 243.905 | 226.184 | 238.938 | 215.185 |
| 2 (reversed order) | 303.300 | 223.604 | 267.919 | 213.242 |
| 3 | 304.918 | 251.647 | 263.891 | 229.703 |

Elapsed timings show substantial scheduling variability. The differences of
aggregate medians are 25.4% elapsed and 18.5% CPU, but the paired ranges above
are a better description of the observed spread than a single precise speedup.
These are fixed-input measurements, not a fresh Java comparison. The
[earlier paired Java benchmark](benchmark.md) predates this change.

## Implementation

Normal LL full-context prediction needs the minimum alternative from each
state/context group, then checks whether those minima agree. It previously
constructed a new generic hash table, group lists, and copied/sorted alternative
lists on every reach computation. The [profile](profile.md) attributed about
62 MB of warm allocation to that helper.

The new internal helper keeps one representative configuration and one minimum
alternative per group. An open-addressed fixnum array maps hashes to entries
in parallel representative/minimum arrays. State and complete structural context
equality resolve collisions; semantic context and alternative are deliberately
excluded from grouping keys, as in the reference algorithm. No subset lists,
sorting, group conses, or per-call general hash table are needed on this path.
Already unique alternatives skip grouping entirely.

Each frontend parse owns a workspace reused across its predictions. A standalone
runtime prediction creates its own workspace when one is not already bound.
Capacity grows geometrically; each operation clears/probes only the power-of-two
span needed by its current input. `unwind-protect` releases borrowed configuration
references on every return. Mutable scratch storage is not added to shared
simulators, DFA states, or canonical context caches.

Exact ambiguity detection and the public full-subset helper keep their original
representation. SLL DFA construction also retains its original grouping path.
The change targets repeated normal LL full-context work; it does not replace
configuration-set lookup tables or alter prediction/cache lifetime policy.

### Hash distribution matters

The initial compact table reduced allocation but did not improve throughput.
Using the intermediate Murmur update directly for a power-of-two slot mask
created expensive probing. Finishing the hash before masking fixed that cost;
context-node hashes themselves are unchanged.

A replay captures 1,201 grouping inputs / 403,935 configurations from one trained
SELECT recognition. Ten passes take 0.502 seconds with the raw update,
0.505 seconds when applying `sxhash` to that update, and **0.073 seconds with
Murmur finalization**. All answers agree; the warmed workspace allocates zero
bytes in these replay loops. These are diagnostic helper timings, not whole-parser
speedups. [Replay harness](conflict-table-probe.lisp),
[recorded output](conflict-results/table-probe-final.txt).

The final [CPU profile](conflict-results/after-cpu.txt) attributes 2.2% of self
samples to the compact grouping helper, versus 15.7% in the diagnostic version
before finalization. The final profile covers 60 warm calls; profiling timings
are separate from the uninstrumented A/B results.

## Correctness and method

Normal and clean forced-safety-3 builds each pass **12,843 checks**, including
507 new checks. They compare the compact result with independently materialized
subsets over deterministic generated sets, exercise real context-hash collisions,
singleton/array equivalence, NIL contexts, fixnum endpoints, converging group
minima, growth followed by small/empty reuse, source immutability, reference
cleanup, and independent workspace ownership. Existing LL, SLL, exact-ambiguity,
Java-reference prediction traces, and concurrent shared-DFA checks also pass.
[Test outputs](conflict-results/tests-normal.txt),
[safety-3 output](conflict-results/tests-safety3.txt).

Four unchanged SQL inputs have identical before/after tree signatures, including
rules, labels, spans, child order, token kinds/text/locations/channels. Direct
compiled recognition/tree runners succeed and their trees equal the interpreter.
One trained SELECT recognition has exactly the same **5,297 ordered
decision/position/alternative triples** before and after. Warm caches remain
**1,475 DFA states / 8,923 canonical contexts**.
[Before validation](conflict-results/validation-before.txt),
[after validation](conflict-results/validation-after.txt).

The A/B builds each native parser in an isolated source/cache location, then
loads it in three fresh processes. Processes run sequentially, reversing order
in pair two. Each process validates direct compiled recognition, trains ten
parses, requests a full GC outside measurement, and measures seven batches of
five recognition calls with prepared tokens and no tree construction. Process
results are medians of batch means. Import, compilation, core loading, lexing,
I/O, and training are excluded. Normal per-call setup and measured-call GC are
included. Allocation is cumulative bytes consed, not live or peak memory.

[Numeric summary](conflict-results/summary.json) retains aggregate medians,
per-process medians, and paired reductions. The summary script validates all
six timing logs, cache counts, full tree-validation output, and ordered predictions.

## Reproduce

Create an isolated baseline snapshot, then run from the candidate checkout:

```sh
mkdir -p /tmp/cnvrs-conflict-before
git archive 66ae344 | tar -x -C /tmp/cnvrs-conflict-before
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
  python3 bench/tsql/conflict-compare.py /tmp/cnvrs-conflict-before \
    --sbcl /path/to/native/sbcl
```

The script builds both cores, runs all six processes sequentially, validates
all four SQL inputs and the ordered SELECT predictions, then summarizes results.
To replay hash variants separately, use a prepared candidate core with
`--script bench/tsql/conflict-table-probe.lisp` from the repository root.
