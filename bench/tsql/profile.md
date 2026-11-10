# Warm T-SQL SELECT recognition profile

Measured 2026-11-10 on native ARM64 SBCL 2.4.0, with the same sources and
unchanged 20,047-character `dml_select.sql` used in the [paired benchmark](benchmark.md).
The sources are now committed as `66ae344`; runtime hashes match the preceding
benchmark. Prepared tokens contain 2,949 tokens / 2,849 default-channel tokens.
Lexing, tree construction, grammar preparation, and cache training are excluded.
No production code was changed for this investigation.

## Findings

Prediction traversal and temporary maps dominate. The CPU profile's leading
self samples are:

| Function/path | CPU samples |
| --- | ---: |
| `closure-work` (including inlined helpers) | 27.5% |
| EQL hash lookup | 11.9% |
| `closure-checking-stop-state` | 6.3% |
| `config-set-add` | 5.0% |
| EQL hash insertion | 4.3% |
| Left-recursive loop-entry check | 3.7% |
| Memory clearing | 3.4% |
| Structural context equality | 3.3% |
| Singleton context construction | 3.1% |
| `conflicting-alt-subsets` | 3.0% |
| Hash-table growth / rehash / growth reallocation | 2.8% / 2.4% / 1.8% |

These are sampled self costs, not inclusive path totals. Inlined helpers are
attributed to their callers. The CPU process performed 60 recognition calls:
15.540 seconds wall, 15.043 seconds process CPU, 14.609 GB cumulative allocation.
GC took 0.449 seconds wall, about **2.9%**. This diagnostic run is not a new
paired throughput measurement or an attribution of the gap to Java.

### Conflict-group construction is a concrete optimization target

One warm parse calls `conflicting-alt-subsets` **1,328 times**. A diagnostic
bytes-consed bracket around the original helper attributes about **62.2 MB**
to those calls, roughly **26%** of the 243.5 MB recognition allocation. Counter
reads have allocation-region granularity, so this is approximate. The helper
builds a new hash table, state/context group lists, and copied/sorted alternative
lists on every invocation. CPU spent in its hash helpers is additional to its
3.0% self sample share.

**127 calls** receive an already unique alternative and could potentially skip
group construction. Most calls still need conflict resolution, making compact
grouping or avoiding full subset-list materialization the larger investigation.
Any change must preserve normal LL and exact-ambiguity behavior. The Java 4.13.2
reference also computes these groups before its unique-alternative check;
this is an optimization opportunity, not evidence of extra Lisp prediction steps.

### Warm DFA caches still leave substantial full-context work

| Operation | Calls per warm parse |
| --- | ---: |
| Adaptive prediction | 5,297 |
| Full-context fallback / start construction | 529 |
| Reach computation (all full-context) | 1,328 |
| Closure stop-state checks | 3,340,043 |
| Closure work | 3,329,034 |
| Epsilon-target checks | 4,595,794 |
| Configuration-set additions | 1,279,902 |
| Context merges | 794,269 |
| Merge-cache queries / hits | 353,708 / 263,386 |

All start/reach computations observed after training are full-context. Persistent
SLL DFA coverage therefore does not eliminate these repeated traversals.
These operation counts have not yet been independently matched against a
T-SQL Java counter run; the preceding benchmark matched token streams and final
cache populations, which does not prove complete operation-count parity.

Most closure work belongs to a few decisions:

| Decision | Owning rule | Calls | Full-context fallbacks | Closure checks | Share |
| --- | --- | ---: | ---: | ---: | ---: |
| 6 | `batch` | 246 | 123 | 827,723 | 24.8% |
| 1526 | `query_expression` | 105 | 33 | 672,197 | 20.1% |
| 813 | `select_statement` | 104 | 67 | 460,424 | 13.8% |
| 12 | `sql_clauses` | 66 | 63 | 323,946 | 9.7% |
| 1776 | `full_table_name` | 186 | 98 | 323,046 | 9.7% |

Shares count closure visits, not measured CPU time. The first three account
for 58.7%; the first five for 78.1%.

### Allocation samples favor tables/configurations over array merging

Allocation-region self samples attribute 40.6% to `closure-work` and its inlined
construction paths, 33.2% to SBCL hash insertion, 11.1% to `adaptive-predict`,
and 7.8% to vector growth. These are approximate region-attribution signals,
not exact object-type percentages; optimized stacks and inlining limit caller
attribution. `merge-arrays` has only 0.5% of allocation-region self samples.

There are **zero shared canonical-context-cache reads** in the warm parse.
The 10,948 calls to the generic context-cache lookup helper instead come from
644 local parent-deduplication arrays of size 17. The other 41,226 parent arrays
use the small-array path. Context merging remains relevant, but its current
cost profile makes it a lower priority than traversal and temporary grouping.
The closure busy-set insertion helper is also never called on this warm input.

### Chunk dispatch is a low priority

Instrumentation of the actual compiled chunk vectors records:

| Rule | Chunk calls | Continuations between chunks |
| --- | ---: | ---: |
| `built_in_functions` | 95 | 76 |
| `ddl_clause` | 42 | 30 |
| Total | **137** | **106** |

The chunk dispatcher itself has 4 of 6,910 CPU samples (about 0.06%). Counts
and samples do not isolate an exact chunking overhead, but provide no evidence
that it is a major cost compared with millions of prediction visits.

## Method and reproduction

Each mode runs in a separate process loading a freshly generated native parser
core, with a 2,048 MiB heap and default stack. Direct compiled recognition is
asserted before ten training parses, followed by full GC outside profiling.
CPU sampling covers 60 warm parses at a requested 1 ms interval (6,910 samples;
one sample lacks a listed function). Allocation sampling covers 30 warm parses
(112,958 samples, approximately 64 KiB regions). Total bytes come from SBCL's
allocation counter, not sample percentages. Neither profiler reaches its sample cap.

Operation counting wraps non-inlined helpers for one warm parse. Diagnostic
copies count recursive stop-state closure entries in the function body and
keep epsilon-target calls out of line, avoiding undercounts from local recursion
or inlining. These copies are absent from the CPU/allocation processes. The
chunk mode uses SBCL closure introspection to wrap existing compiled chunk
vectors temporarily; it verifies successful direct recognition and restores
every vector entry. Its wrappers are absent from all other modes.

[CPU profile](profile-results/cpu.txt), [allocation profile](profile-results/alloc.txt),
[operations and decision attribution](profile-results/operations.txt),
[chunk counts](profile-results/chunks.txt), [parsed summary](profile-results/summary.json),
[environment](profile-results/environment.txt), [source hashes](profile-results/source-sha256.txt).

From the repository root:

```sh
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
ASDF_OUTPUT_TRANSLATIONS='(:output-translations (t "/tmp/cnvrs-tsql-profile-cache/") :ignore-inherited-configuration)' \
SBCL_BIN=/path/to/native/sbcl \
  bash bench/tsql/profile.sh
```

The summary script checks profile sample accounting, stable prediction counts,
closure/call/fallback sums across decisions, and chunk totals. Runtime source
hashes agree with the preceding paired benchmark. No full test suite was rerun
for this benchmark-only addition.
