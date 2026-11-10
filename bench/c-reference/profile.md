# C11 warm recognition and tree profile

Measured 2026-11-10 on the optimized runtime from the
[latest paired comparison](../java-reference/compact.md). The workload is the
unchanged 26,587-character GCC warning fixture: 6,811 tokens, of which 3,658
are on the default channel. Runtime code was not modified for this investigation.

## Where the gap is

The biggest absolute difference is on this larger input, primarily in recognition:

| Phase | Java ms | CNVRS ms | Difference |
| --- | ---: | ---: | ---: |
| Recognition without trees | 5.655 | 8.392 | +2.737 |
| Parsing with trees | 5.775 | 9.701 | +3.925 |
| Full lexer/tree pipeline | 6.014 | 11.088 | +5.073 |

Enabling trees increases native time by roughly 1.31 ms, versus 0.12 ms in
Java. That suggests roughly another 1.19 ms of gap in the tree path. Phases
are independently timed, so these subtractions are approximate, not an exact
cost decomposition. Lexing accounts for another approximately 1.06 ms, but
is outside the profiles below.

## Same prediction work as Java

Fresh diagnostic Java and Lisp runs agree on all **11 shared counters**, and on
all **7,166 ordered decision/logical-token-position pairs**. Java physical token
indices are mapped to default-channel logical positions before comparison.

| Warm operation | Java = CNVRS |
| --- | ---: |
| Adaptive prediction | 7,166 |
| Full-context fallbacks | 128 |
| Start computations (all full-context) | 128 |
| Reach computations (all full-context) | 269 |
| Sum of reach input/output configuration counts | 15,537 / 16,572 |
| Closure stop-state checks | 74,732 |
| Closure work | 72,356 |
| Epsilon-target checks | 99,402 |

About **98.2%** of prediction calls avoid full-context fallback. No warm SLL
start/reach construction remains. The measured algorithmic work matches Java;
the remaining difference concerns execution cost, representation, frontend
setup, or tree handling. This does not assign an exact Java/Lisp time difference
to individual functions; a matched Java CPU profile would be needed for that.

Most closure visits belong to three decisions: `parameterDeclaration` (26,274),
`declarationSpecifiers` (21,004), and `selectionStatement` (13,446). Together they
account for about 81% of closure visits, rather than 81% of measured CPU time.

## Main native recognition costs

A CPU profile of 1,000 trained recognition calls has 2,806 samples:

| Self-sample attribution | Share |
| --- | ---: |
| `closure-work`, including inlined helpers | 18.1% |
| EQL hash lookup | 6.3% |
| Configuration-set addition | 4.5% |
| Closure stop-state handling | 3.5% |
| EQL hash insertion | 3.0% |
| Hash growth / rehash / growth reallocation | 2.5% / 2.4% / 2.1% |
| Memory clearing | 7.3% |
| Compact conflict-group helper | 2.4% |

Locking-related helpers and signal-mask changes are also visible. The warm DFA
read path and frontend bookkeeping merit examination because most predictions
are cache hits. For example, `runtime-adaptive-predict` performs a generic
frontend decision-cache lookup and token-input cache lookup before invoking the
typed simulator; the simulator also retrieves its DFA and locks read access.
The profile does not isolate all those costs from configuration-table lookup.

GC is only **0.102 of 8.158 seconds wall (1.3%)** in the recognition CPU profile.
Its allocation counter records approximately 8.05 MB per call. Allocation-region
self samples attribute **40.1% to hash insertion**, **34.6% to closure work**,
and **7.3% to vector growth**. These samples are approximate allocation-region
attributions, not exact object-type byte counts; inlining and optimized stacks
limit caller attribution.

### Insertion-heavy configuration sets are the clearest next target

One trained parse has **28,574 configuration-set additions**:

- **24,397 insertions (85.4%)**;
- **4,177 existing-entry hits (14.6%)**;
- **616 populated temporary sets**, with **267 (43.3%)** finishing at size four
  or smaller, and a maximum size of 136.

This differs sharply from the earlier Java 8 lookup probe, where about 93% of
additions hit existing entries. C11 gives more relative weight to constructing,
growing, and populating tables. A small-set representation, avoiding repeated
initial growth, or parse-local reuse of temporary configuration-set storage
would directly target that pattern. Ownership must distinguish temporary
full-context sets from persistent DFA configurations and exception payloads.

Context merging is comparatively small: 5,889 merge calls and 36 common-parent
arrays, all size two. Shared canonical-context-cache reads and closure busy-set
insertions are both zero in this warm parse. The already optimized compact
conflict helper is not the largest remaining target.

## Tree path

A separate CPU profile covers 1,000 warm tree parses: 9.214 seconds wall,
9.179 seconds process CPU, with 0.307 seconds GC (3.3% wall). It allocates
approximately 9.56 MB per call. Memory clearing has 18.8% of self samples,
vector allocation 3.7%, the native node-construction generic method 3.1%,
and ATN tree-event handling 1.5%. Prediction/table work remains prominent.

The tree allocation profile still attributes 32.5% of region self samples to
closure work and 30.5% to hash insertion. Generated rule bodies account for
additional tree allocations. These profiles establish that tree handling is a
secondary target; they do not prove that a particular node-building function
accounts for the entire extra tree-phase gap.

## Method and artifacts

Each of four separate SBCL processes imports/compiles the grammar, prepares
tokens, calls both compiled runners directly to require successful full-input
recognition/tree construction, trains twenty calls, then requests full GC.
CPU sampling profiles 1,000 calls at a requested 1 ms interval; allocation
sampling profiles 300 calls using approximately 64 KiB regions. Neither mode
reaches its 200,000-sample cap. Both use a 2 GB heap and the default control stack.
Lexing, compilation, file I/O, and training are excluded. These diagnostic
profile times are separate from the uninstrumented paired benchmark.

The operation probe runs separately from sampling. It instruments recursive
closure entries in a diagnostic function body and keeps epsilon-target calls
out of line. This avoids undercounting recursive or inlined calls. Temporary
set identities and final sizes are retained only in that diagnostic process.
Java uses a counting simulator subclass with twenty training parses and tree
construction disabled. Canonical cache populations remain 206 DFA states and
994 contexts. Runtime source hashes match the paired benchmark.

[Parsed profiles/counters](profile-results/summary.json),
[environment and source hashes](profile-results/environment.json),
[recognition CPU](profile-results/cpu-none.txt),
[recognition allocation](profile-results/alloc-none.txt),
[tree CPU](profile-results/cpu-tree.txt),
[tree allocation](profile-results/alloc-tree.txt),
[native operations](profile-results/operations.txt),
[Java operations](profile-results/java-operations.txt).

With native SBCL and isolated ASDF output translations, run
`bench/c-reference/warm-profile.lisp` with `cpu-none`, `alloc-none`, `cpu-tree`,
or `alloc-tree` as its single argument. Run `operation-probe.lisp operations`
for native counts. Generate C Java classes from the pinned grammar using the
4.13.2 jar, compile them alongside `Operations.java`, then run `Operations` on
`bench/c-reference/examples/Wmisleading-indentation.pp.c`. Finally run
`python3 bench/c-reference/profile-summary.py` to validate profile accounting,
all shared counters, ordered predictions, and set traffic. No production changes
or regression-test reruns were needed for this profiling-only task.
