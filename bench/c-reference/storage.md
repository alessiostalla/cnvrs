# Configuration-set representation and allocation

The subsequent [fresh paired Java comparison](../java-reference/configuration-storage.md)
measures the updated runtime on C11, Java 8, and T-SQL.

Baseline: **142ce0c**. Candidate: the working source identified in
[metadata](storage-results/environment.json). Native ARM64 SBCL 2.4.0, 2 GB
heap, unchanged grammars and inputs. Measured 2026-11-10.

The change replaces general hash tables and linked-list buckets in parser
configuration sets with small linear sets and an array-backed index. The
set-merging algorithm, ordered entries, configuration ownership, prediction
policy, and persistent DFA/cache lifetime remain the same.

## Controlled C11 results

Warm milliseconds per call; allocation is decimal MB, cumulative rather than live memory.

| Input | Phase | Before ms | After ms | Time reduction | Before MB | After MB | Allocation reduction |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| GCC warning fixture | Recognition | 7.7297 | 6.7726 | 12.4% | 8.048 | 6.057 | 24.7% |
| GCC warning fixture | Tree parse | 9.1110 | 8.1674 | 10.4% | 9.558 | 7.565 | 20.8% |
| Function pointers/calls | Recognition | 1.4469 | 1.2100 | 16.4% | 1.698 | 1.162 | 31.6% |
| Function pointers/calls | Tree parse | 1.5180 | 1.3023 | 14.2% | 1.772 | 1.231 | 30.5% |

Every C11 process pair improves. CPU reductions closely track elapsed time:
12.3% recognition / 10.3% tree parsing on the large input, and 16.4% / 14.3%
on pointers. The larger twenty-call batches reduce the noise seen in earlier
two-call paired-Java measurements. These are before/after native measurements,
not a fresh Java comparison.

Cold-cache recognition improves from 13.055 to 11.374 ms on the large fixture,
and 4.589 to 3.972 ms on pointers. Cold tree parsing improves from 14.111 to
13.109 ms and 4.662 to 4.079 ms respectively.

## Representation

The ordered item vector starts with capacity four. Sets with at most four
entries scan that vector directly and allocate no lookup index. The fifth
distinct entry promotes the set to a power-of-two, open-addressed array of
references to the same owned configurations. A finalized internal hash selects
a slot; full state/alternative/semantic equality resolves collisions. Hash
placement excludes prediction context because equal lookup keys merge contexts.

The index grows geometrically at half load. A successful lookup/insertion search
returns both the existing configuration and its slot, so an ordinary insertion
does not repeat the hash lookup. Growth reindexes existing references in insertion
order without cloning configurations. There are no per-entry bucket conses.

Each set owns its storage. Stack-scoped configurations still get promoted at
the original ownership boundary, and merges still update the original retained
objects. Freezing DFA configurations drops the lookup index, as before. Error
payloads can retain their original sets. This implementation does not pool or
reuse storage across different sets.

The current C11 and Java 8 diagnostic lookup probes accept both the archived
hash-table representation and the new vector representation. Historical bucket
statistics remain historical; current Java 8 diagnostics label whole-set sizes.

## Validation

Normal and forced-safety-3 builds each pass **13,307 checks** (464 more than the
baseline). New checks cover tiny sets, promotion, repeated growth, insertion
order and identity, complete numeric hash collisions, wraparound probing, half-load
growth boundaries, read-only behavior, and differential context/flag merging
against an independent linear ordered model. Existing stack-ownership/full-GC,
LL/SLL/exact-ambiguity reference traces, FASL, clone, and concurrent-DFA tests pass.

All before/after C11 operation counters match, including 28,574 additions,
24,397 insertions, and 4,177 hits. Both versions also match all 11 shared Java
prediction counters and all **7,166 ordered decision/position pairs**. Token/kind
signatures and cache populations match in every timing process. Compiled
recognition and tree runners succeed directly on both C11 inputs; before/after
tree signatures match, and compiled trees equal the interpreter.

[Operation validation](storage-results/operations-summary.json),
[before tree validation](storage-results/validation-before.txt),
[after tree validation](storage-results/validation-after.txt),
[normal tests](storage-results/tests-normal.txt),
[safety-3 tests](storage-results/tests-safety3.txt).

## Java 8, IRI, and T-SQL checks

Three fresh process pairs per source version also check the earlier workloads:

| Workload / phase | Before ms | After ms | Before MB | After MB |
| --- | ---: | ---: | ---: | ---: |
| Java 8 tree parsing | 98.288 | 97.349 | 100.788 | 98.833 |
| T-SQL SELECT recognition | 215.553 | 192.968 | 182.208 | 148.545 |

Java 8 elapsed time is within about 1% and CPU within 0.5%; this establishes no
large throughput change. Warm allocation decreases about 2%, and cold tree time
improves from 695.686 to 661.354 ms. IRI and lexing controls are effectively unchanged.

T-SQL recognition improves **10.5% elapsed / 9.3% CPU**, with **18.5% less
allocation**. All three pairs improve. Its four SQL examples retain identical
before/after trees matching the interpreter, and all **5,297 ordered SELECT
decision/position/alternative triples** agree. Caches remain 1,475 states /
8,923 contexts. The archived T-SQL core was verified against the baseline source
hashes before reuse; candidate preparation compiled the updated runtime.

[Java 8/IRI guard results](storage-results/java8-guard/summary.json),
[T-SQL guard results](storage-results/tsql-guard/summary.json),
[T-SQL core/source metadata](storage-results/tsql-guard/environment.json).

## Allocation profile

A separate post-change C11 recognition allocation profile shifts hash-insertion
self attribution from 40.1% of regions in the motivating profile to 9.5%.
Closure work now accounts for 56.4% and vector growth 11.6%. Region sampling
is approximate and affected by inlining; these percentages are not exact
object-type byte counts. The allocation counter confirms the total reduction.
[Post-change profile](storage-results/after-alloc.txt).

## Method and reproduction

The C11 experiment runs three fresh processes per version and input, sequentially,
reversing version order in pair two. Each process trains twenty calls, measures
three cold calls after cache clearing and explicit full GC outside timing, then
seven warm batches of twenty calls. Process results are medians of batch means;
reported values are medians of three process results. Parsing uses prepared
tokens and native tree builders. Normal per-call setup and measured-call GC
are included; grammar import, compilation, I/O, lexing, cache clearing, and explicit
pre-cold GC are excluded. Separate ASDF caches isolate source versions.

[C11 numeric results and per-process medians](storage-results/summary.json) retain
cold results, CPU time, and allocation. Metadata records measured sources and a
final indentation-only cleanup whose Lisp reader forms were verified equivalent.

From the candidate repository root:

```sh
mkdir -p /tmp/cnvrs-set-before
git archive 142ce0c | tar -x -C /tmp/cnvrs-set-before
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
  python3 bench/c-reference/storage-compare.py /tmp/cnvrs-set-before \
    --sbcl /path/to/native/sbcl --cache-root /tmp/cnvrs-set-ab-cache
```

For Java 8/IRI, run `bench/java-reference/storage-compare.py` with the same
baseline, a distinct cache root, and `--results` pointing to a separate directory.
For T-SQL, build one core per source tree with `bench/tsql/prepare-core.lisp`,
then alternate fresh processes running the same absolute
`bench/tsql/recognition.lisp` harness and validate with
`bench/tsql/conflict-validate.lisp`. Those core-based harnesses do not reload
runtime sources.
