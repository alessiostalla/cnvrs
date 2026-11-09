# Direct arrays and typed prediction traversal

Baseline: **b2e29bd**, the committed compact-context/hash-bucket implementation.
Candidate: the uncommitted helper-declaration, direct-array and specialized
traversal round. Apple M1 Max, ARM64 SBCL 2.4.0, 2 GiB dynamic heap. Both versions
use speed 3 / safety 1; no safety-0 regions or implementation-specific production
intrinsics were added. Inputs and grammars are unchanged.

## Changes

- Typed configuration-copy, membership/equality, epsilon-target, context-cache
  and merge helpers. The closure transition-loop index is explicitly fixnum.
- Replaced generic FIND/FIND-IF membership traversals with typed bucket loops.
  Configuration insertion and closure-busy insertion reuse the bucket already
  read, avoiding a second lookup on insertion. Hash collisions still compare
  the same fields and complete contexts.
- Array contexts store packed unsigned 32-bit return states and general parent
  vectors. Exported return-state vector views retain their simple-vector form.
- Array merges allocate upper-bound output arrays, merge directly with an output
  cursor, and trim only when duplicate payloads shortened the result. This is
  Java's direct-array strategy; the two temporary linked lists, reversals, length
  walks and list-to-vector copies are gone.
- Context equality, parser/lexer return-context traversal and the left-recursive
  loop-entry check dispatch on representation outside their element loops.
  The merge kernel expands four singleton/array input combinations from one
  implementation, avoiding generic indexed accessors inside the loops.

Alternative ordering, context equality, merge-cache lifetime, closure-busy-set
lifetime, full-context fallback and persistent SLL caching are preserved.
No additional memoization was introduced.

## Repeated before/after measurements

Three fresh processes per version, sequential, reversing order in pair two.
The baseline is an isolated `git archive b2e29bd` snapshot with a separate ASDF
cache. The same absolute [types.lisp](types.lisp) harness runs from both source
directories. Warm summaries are medians of three process medians, each derived
from seven batch means. Batches use 1000 lexes, 100 IRI tree parses, or two Java 8
tree parses. Cold-cache summaries use nine calls after full GC outside each timer.
Compilation, grammar import, ATN adaptation, I/O and cache reset are excluded;
per-call parser setup and GC during measured calls are included.

The harness now also records process CPU time for every warm batch. Capturing
elapsed time, CPU time and allocation happens before formatting the result lines.
Both versions use the identical harness. CPU time helps detect scheduling delays;
it does not eliminate thermal/frequency or memory-contention effects.

| Warm phase | Before elapsed (ms) | After elapsed (ms) | Before CPU (ms) | After CPU (ms) |
| --- | ---: | ---: | ---: | ---: |
| iri lexer | 0.032695 | 0.032145 | 0.032524 | 0.032080 |
| iri parse-tree | 0.075260 | 0.073270 | 0.074770 | 0.073020 |
| java8 lexer | 0.133275 | 0.134528 | 0.129040 | 0.131710 |
| java8 parse-tree | 240.345000 | 198.610500 | 235.673500 | 191.952500 |

Java 8 warm tree parsing improves from **240.34 to 198.61 ms**,
**1.21×** faster (17.4% less elapsed time).
CPU time falls **18.6%**, from
235.67 to 191.95 ms. The change combines declarations,
collection traversal and array construction; this run does not isolate each one's
contribution. IRI and lexer changes are small and are not persuasive evidence of
a separate speed improvement.

Warm Java 8 allocation falls from **271.33 to 263.42 MB**,
**2.9% less**. This is cumulative allocation,
not retained heap or RSS. Removing staging lists does not save their entire
estimated size: the Java strategy first allocates an upper-bound buffer and may
allocate trimmed arrays afterward. Packed payloads and fewer passes also improve
memory access, even where allocator alignment limits the size reduction.

Cold-cache Java 8 parsing improves from **1623.14 to 1363.21 ms**;
allocation falls from 1690.41 to 1629.93 MB.
Java 8 process warm elapsed medians are
258.88 / 240.34 / 230.76 ms before and
198.61 / 195.36 / 199.82 ms after. CPU medians are
242.67 / 235.67 / 228.28 ms before and
192.31 / 191.95 / 188.54 ms after. Desktop/IDE indexing
activity was observed, but the CPU reduction and improvement in every pair
support the result. It remains a fixed-input, single-machine measurement.
No new Java timing benchmark was run in this round.

[All raw process logs and numeric summary](arrays-results/summary.json).

## Java equivalence and safety validation

All **13 prediction-operation counters**, all **1431 ordered decision/position
pairs**, **1160 DFA states** and **24764 cached contexts** agree between Java
4.13.2, the baseline and the candidate. Warm Java 8 parsing still has 92 LL
fallbacks, 368 full-context reach calls, 1437208 closure checks, 316043 config-set
addition attempts and 524143 context merges. Only 22970 additions append a new
configuration; the rest merge with an existing one.

The before/Java counting logs are the previously saved matching reference runs
for the committed baseline; the candidate was counted afresh. Timing runs contain
no operation-counter wrappers. [Validation](arrays-results/operations-summary.json)
checks the complete ordered streams and counts. Token signatures and trained
lexer/parser cache counts also agree in all six benchmark processes.

Normal and separate clean builds forcing **safety 3** both pass **12072 checks**.
The 158 new checks cover all singleton/array input combinations, packed storage
and exported general-vector views, path-set unions, trimming/singleton collapse,
commutativity and cache identity, and early failure during array-context
loop-entry traversal. That early-exit regression was caught by the Java operation
counters during development; final counters agree exactly.

## Native-code confirmation

Fresh [disassembly](arrays-results/disassembly/) confirms:

- DERIVE-CONFIG shrinks from 340 to 208 bytes.
- Closure-work has no generic TWO-ARG-+ increment.
- Config-set membership no longer calls generic FIND.
- Stop-state closure and array merging have no singleton-index ASSERT-ERROR
  references. Required array bounds checks remain.
- Array merging has no LIST-NREVERSE or generic REPLACE calls for list staging;
  payload reads/writes use packed 32-bit storage.

Specialization duplicates a small merge loop for concrete input combinations:
MERGE-ARRAYS grows from 4236 to 4692 bytes; stop-state closure grows from 1120 to
1328 bytes. This is an explicit code-size tradeoff for removing dispatch and
assertion guards inside traversals. CONTEXT-EQUAL shrinks from 984 to 844 bytes.
Static sizes are supporting evidence, not runtime speed estimates.
[Static before/after summary](arrays-results/disassembly-summary.json) and
[environment/source hashes](arrays-results/environment.json) identify the result.

## Reproduction

Use the absolute same harness from archived and candidate source directories,
with separate XDG_CACHE_HOME values:

```sh
# Save three logs per version, reversing execution order in the second pair.
XDG_CACHE_HOME=/tmp/cnvrs-array-bench-cache /path/to/sbcl --dynamic-space-size 2048 \
  --script /absolute/path/bench/java-reference/types.lisp after
python3 bench/java-reference/types-summary.py bench/java-reference/arrays-results
PROFILE_MODE=operations XDG_CACHE_HOME=/tmp/cnvrs-array-bench-cache \
  /path/to/sbcl --dynamic-space-size 2048 --script bench/java-reference/warm-profile.lisp \
  test/fixtures/runtime/Java8Lexer.g4 test/fixtures/runtime/Java8Parser.g4
python3 bench/java-reference/profile-summary.py bench/java-reference/arrays-results
/path/to/sbcl --script bench/java-reference/disassemble.lisp bench/java-reference/arrays-results/disassembly
```

All implementation and measurement changes in this round remain **uncommitted**.
