> Historical pre-port investigation. The active predictor is now the ANTLR Java reference port; these diagnostic hooks are not a runtime backend.

# Closure-local versus prediction-local stack interning

Measured 2026-11-08 on native ARM64 SBCL 2.4.0, with a 2 GiB heap, against
`chore/performance` at `5241b83`. The comparison below used benchmark-only hooks; the production
predictor at that revision was unchanged. Both use the default unlocked hash cache and the
committed specialization limits (64 prefix edges, 4096 configuration keys).

## Result

There is no broad cold-time winner on this corpus. The sum of eight per-case
cold medians is **1243.0 ms for closure-local** and **1245.7 ms for
prediction-local**. This sum weights each small input equally and is not a
representative workload score. Prediction-local reduces the corresponding
allocation sum from **1324.8 MB to 1257.9 MB**, about **5.0%**.

Prediction-local helps some cases: the nested condition is about 11.5% faster
and the return-literal method about 7.2% faster. It is about 5.9% slower for
the lambda. Call and loop timing ranges overlap. It carries a substantially
larger transient arena: up to 12.7 times as many canonical contexts in the
nested-condition case.

For an initial production implementation, closure-local is the more conservative
choice on this evidence: similar aggregate time and smaller live arenas.
Prediction-local's allocation savings do not establish a general speed benefit.
Broader successful Java workloads are needed before making a firm throughput
choice, especially given the stress failure below.

## What differs

Both variants replace only the temporary closure key with:

```text
(grammar state, exact stack ID, alternative)
```

A stack ID is interned from `(return-state, parent-stack-ID)`. An EQ table
memoizes IDs for original stack-list objects; an EQUAL table of these shallow
pairs canonicalizes structurally equal stacks. Empty stack is ID zero. Each
variant uses precisely the same algorithm and tables.

- **Closure-local:** fresh arena for each `closure` invocation, released on
  its return or non-local exit.
- **Prediction-local:** one lazily allocated arena for an outermost compiled
  decision, shared through contextual specialization, SLL, and full-context
  retry. Standalone calls to `predict`, `predict-full-context`, or
  `contextual-choice` establish a scope if necessary. An out-of-prediction
  closure uses its own arena.

No arena is created on a prediction-cache hit that performs no closure. Both
variants install the same decision-boundary wrappers so the comparison does
not charge that wrapper cost to only one variant. Timing includes wrapper and
interning costs. The benchmark does not merge configurations or change the
original stack lists retained inside cached DFA states.

## Timing and allocation

Each scope ran in **three fresh processes**, alternated in order. Each process
ran **three cold trials per case** using fresh parser clones. Compilation and
lexing are excluded. A full GC precedes each trial, outside timing. Cold timing
builds a tree; each cold trial is followed by 1000 warm recognition calls
without trees. The runtime itself is warmed by preceding trials/cases.

The table reports the median of each process's three-trial median. Allocation
is cumulative bytes consed during the cold parse, including short-lived objects;
it is not peak live memory. MB means decimal megabytes.

| Input | Closure cold ms | Prediction cold ms | Closure allocation MB | Prediction allocation MB |
| --- | ---: | ---: | ---: | ---: |
| empty | 2.20 | 1.99 | 2.09 | 1.76 |
| field | 5.02 | 3.59 | 5.74 | 5.05 |
| return | 40.29 | 37.38 | 54.01 | 50.39 |
| call | 175.47 | 175.57 | 185.37 | 178.41 |
| arithmetic | 56.86 | 53.78 | 77.56 | 69.55 |
| lambda | 550.33 | 582.80 | 489.12 | 480.97 |
| nested | 183.02 | 161.98 | 216.67 | 199.78 |
| loop | 229.84 | 228.64 | 294.20 | 271.96 |

Input source is included in [interning.lisp](interning.lisp): empty/field
classes, a return-literal method, a method call, arithmetic, a lambda, a nested
condition, and a loop. Sizes range from 14 to 97 characters (4 to 40 tokens).
These are small grammar probes, not a real-world Java corpus.

Warm recognition times were similar: roughly 1–100 microseconds per call,
depending on input. Cached predictions need no interning arenas. Small warm
latency differences should not be read as an arena-lifetime benefit.

## Arena lifetime and retained memory

The following counters come from separate diagnostic runs, excluded from the
timing medians. Each cell lists **closure / prediction**.

| Input | Arenas created | Context IDs created across all arenas | Peak IDs in one live arena |
| --- | ---: | ---: | ---: |
| empty | 115 / 3 | 1,607 / 147 | 95 / 100 |
| field | 200 / 6 | 5,114 / 2,031 | 905 / 1,066 |
| return | 347 / 37 | 52,765 / 37,471 | 1,970 / 5,298 |
| call | 203 / 9 | 167,155 / 157,581 | 32,007 / 71,029 |
| arithmetic | 599 / 53 | 82,545 / 49,206 | 1,970 / 4,770 |
| lambda | 323 / 15 | 330,236 / 315,199 | 32,012 / 71,034 |
| nested | 806 / 112 | 216,053 / 151,902 | 3,941 / 50,032 |
| loop | 1,162 / 179 | 295,603 / 197,775 | 5,129 / 11,845 |

The total ID count includes reinterning a stack in multiple arenas. Peak IDs
are a proxy for the live interner footprint, not a byte measurement. The
original-object memo table also grows: for the nested condition, its peak is
5772 stack objects with closure-local versus 74094 with prediction-local.

Both scopes perform identical numbers of closure calls and configuration-key
lookups for each case. All eight diagnostic runs per scope found **zero live
arenas after a full GC**, using weak pointers. Both lifetimes release their
arenas; this is a transient-retention difference rather than a leak.

Post-GC heap deltas while keeping the parser and result tree alive were nearly
identical across scopes (about 0.21–42.54 MB depending on case). This is expected:
the persistent DFA configurations still retain the same original stack lists.
The measurements do not establish peak total heap usage during each parse.

## Larger Java source stress case

The repository's [Bench.java](../antlr4-grammar/Bench.java), 2384 characters
and 505 tokens, was run separately with a 20-second timeout and a 2 GiB heap.

| Scope | Outcome |
| --- | --- |
| Closure-local | Timed out at 20 seconds |
| Prediction-local | SBCL exhausted the 2 GiB heap during full-context prediction |

Neither completed the source file. The timeout bounds work only when SBCL can
deliver it; heap exhaustion can terminate the process first. This makes the
larger input opt-in, excluded from the default corpus. These outcomes rule out
calling either prototype a complete Java parser performance solution.

## Correctness checks

Both variants pass all **454 CNVRS suite checks**. Across timing and diagnostic
runs, each of the eight successful inputs produced 20 identical tree signatures
covering both scopes: 18 timed trials plus two diagnostic trials. Signatures
include rule names, labels, node spans, token kinds, token text, and token spans.
They establish agreement between variants, not complete ANTLR/Java equivalence.

## Initial production integration

The production closure now uses the same interning algorithm, with two lexical
hash tables and an ID counter allocated by `make-closure-key-function` for each
closure invocation. No global or prediction-local arena is retained. Cached
configurations continue to hold their original stacks, and speculative
configuration-work accounting still happens before each key computation.

All **457 checks** pass, including three new regression checks covering equal
stack deduplication, distinct deep tails and alternatives, preservation of the
original configurations, and agreement across independent closures.

A validation run using `production` mode (no experimental hooks), three cold
trials per input and 1000 warm calls per trial, completed all eight small inputs.
All **24 tree signatures** matched the earlier comparison. The sum of cold
medians was **1257.9 ms**, with **1324.8 MB** cumulative allocation. This single
process validates integration; it does not establish a new performance result
or resolve the larger Java source stress failure above.

## Reproduce

Use the Java8Lexer.g4 and Java8Parser.g4 files/checksums documented in
[the profiling report](README.md). From the repository root:

```sh
export SBCL_BIN=/path/to/native/sbcl
export JAVA8_DIR=/path/to/java8
"$SBCL_BIN" --dynamic-space-size 2048 --script bench/java8/interning.lisp \
  "$JAVA8_DIR/Java8Lexer.g4" "$JAVA8_DIR/Java8Parser.g4" closure
"$SBCL_BIN" --dynamic-space-size 2048 --script bench/java8/interning.lisp \
  "$JAVA8_DIR/Java8Lexer.g4" "$JAVA8_DIR/Java8Parser.g4" prediction
```

Default: three trials, 1000 warm iterations, ten seconds per trial, and the eight
small inputs. Use a fresh process for each scope. Pass `production` as the final argument
to measure the integrated implementation without installing experimental hooks.
Relevant variables:

- `BENCH_TRIALS`, `BENCH_WARM_ITERATIONS`, `BENCH_SECONDS` change trial sizes.
- `BENCH_CASES` selects comma-separated input names. `bench-source` explicitly
  enables the larger Java source stress case.
- `BENCH_DIAGNOSTICS=1` collects arena/key counters and weak pointers instead
  of warm timings for the experimental scopes. Keep these results separate
  from timing results; production mode does not collect arena counters.
- `BENCH_OUTPUT_DIR` selects the directory for complete tree signatures
  (default `/tmp/cnvrs-interning-results/`). Use a separate directory per process.
- `BENCH_RUN_TESTS=1` runs the CNVRS suite with the chosen hooks and exits.

The hooks install once per process and affect its function definitions. They
are never loaded by the CNVRS ASDF system. [Raw measurements](interning-results.tsv)
include all 144 timed rows and 16 diagnostic rows; stress outcomes are recorded
above because the heap-exhausted process could not emit a completed row.
