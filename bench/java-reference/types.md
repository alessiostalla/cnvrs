# Typed runtime and compiler policy

Measured 2026-11-09 on Apple M1 Max, native ARM64 SBCL 2.4.0. Baseline is
`d7bb606`, including Java-style direct LL(1) dispatch. Candidate is the uncommitted
type/compiler-policy round based on that revision. ANTLR algorithms, prediction
call selection and cache lifetimes are unchanged.

## Findings and changes

The standalone runtime had no explicit per-file speed policy and compiled under
SBCL's default speed-1 policy in clean builds. The native package's declarations
do not configure earlier ASDF components. Most ATN/configuration fields were
untyped, and hash helpers made full generic arithmetic/helper calls.

- Runtime files now use `(speed 3) (safety 1) (debug 0) (space 0)
  (compilation-speed 1)`. Token/tree/cache helpers and selected native execution
  functions have explicit hot-path policies as well.
- Grammar construction and ATN adaptation use speed 1, compilation-speed 3 and
  safety 2. Generated rule functions retain their established policy.
- ATN/configuration storage, hash tables, numeric IDs, positions and line/column
  cursors have concrete types. Optional/read-only fields preserve NIL where the
  Java lifecycle permits it. Token kinds, callback forms and Lisp token values
  retain their existing representations.
- Small numeric/accessor helpers are inlined. Hash arithmetic uses explicit
  unsigned 32-bit truncation, including Java's word-count overflow behavior.
  This enables machine arithmetic without transient bignums. Character intervals,
  context state comparisons and numeric token reads have precise local types.
- No safety-0 code or SBCL-specific production intrinsics were introduced.

On ARM64, Murmur update/finalization shrank from 324/432 bytes to 120/96 bytes.
The new disassembly has no generic arithmetic/helper calls or allocation
trampolines in either helper. [Before](types-results/hash-before.asm) and
[after](types-results/hash-after.asm) machine code are saved.

At identical speed-3/safety-1 diagnostic settings, compiler notes across the four
core files fell from 847 to 218 (74%). These diagnostic copies deliberately force
the same policy on the baseline, distinguishing type information from the
baseline's default speed policy. Notes are captured explicitly because ordinary
ASDF output muffles them. Counts are saved in
[compiler-notes.json](types-results/compiler-notes.json); inlining and different
compiler versions can change counts, so they are supporting evidence, not a
performance metric. Remaining notes include adjustable-vector storage and
flexible callback/semantic interfaces; those types were not narrowed merely to
silence diagnostics.

## Repeated before/after measurements

| Grammar | Phase | Before | After | Speedup |
| --- | --- | ---: | ---: | ---: |
| IRI | Lexer | 0.04472 ms | 0.03238 ms | 1.38× |
| IRI | Tree parsing | 0.08380 ms | 0.07410 ms | 1.13× |
| Java 8 | Lexer | 0.18892 ms | 0.12906 ms | 1.46× |
| Java 8 | Tree parsing | 549.04 ms | 243.98 ms | **2.25×** |

Java 8 warm tree allocation fell from **367.17 MB to 318.44 MB** per parse,
13.3% less. Cold-cache tree parsing fell from 3421.8 ms to 1681.8 ms (2.03×),
with allocation falling from 2281.82 MB to 1973.87 MB. Lexer warm allocation is
unchanged within allocator measurement granularity. Allocation is cumulative,
not retained heap or RSS. MB is decimal.

Per-process warm Java 8 tree medians were 522.63/549.04/580.31 ms before and
243.98/241.44/262.12 ms after. Desktop workloads and frequency/thermal variation
remain possible; the large effect is present in all three pairs. No new Java
reference run was performed in this round.

Both versions produced the same token signatures and trained DFA counts:
IRI has 31 lexer states and 5 parser states; Java 8 has 111 lexer states and
1,160 parser states. Existing differential checks also preserve Java's adaptive
call sequence and per-decision cache sizes. The remaining 318 MB of warm Java 8
allocation is still substantial; this round does not change full-context
prediction policy or introduce new memoization.

## Method and reproduction

Three fresh processes per version, run sequentially, with order reversed in the
second pair. Baseline source is an isolated `git archive d7bb606` snapshot;
separate ASDF caches prevent stale FASLs from crossing versions. The same
[types.lisp](types.lisp) harness is executed from each source directory.

Inputs are unchanged: the 217-character/216-token IRI and
2,384-character/505-token Bench.java. Lexing and tree parsing are measured
separately. Parser timings reuse tokens and require complete consumption. File
I/O, grammar/code compilation, ATN adaptation, cache clearing and pre-cold full GC
are excluded. GC during measured calls is included. Both versions have a 2 GiB
SBCL dynamic heap.

Each phase warms first, measures three empty-cache calls, trains once more, and
measures seven batches. Batches use 1,000 lexes, 100 IRI parses, or two Java 8
parses. Warm summaries are the median of each process's median batch mean; cold
summaries are the median of nine calls. SBCL allocation-buffer granularity makes
small allocation differences approximate.

```sh
# Run the same absolute harness from the baseline source directory and candidate.
XDG_CACHE_HOME=/tmp/cnvrs-types-before /path/to/sbcl --dynamic-space-size 2048 --script /absolute/path/types.lisp before
XDG_CACHE_HOME=/tmp/cnvrs-types-after /path/to/sbcl --dynamic-space-size 2048 --script bench/java-reference/types.lisp after
python3 bench/java-reference/types-summary.py
# Capture detailed optimizer notes at a common speed-3 policy.
/path/to/sbcl --script bench/java-reference/compiler-notes.lisp
```

[Raw logs and summary data](types-results/). Normal and clean forced-safety-3
builds each pass **11,897 checks**, including 140 new Java-generated hash/rotate
boundary cases. To force checking even inside locally optimized code:

```lisp
(sb-ext:restrict-compiler-policy 'safety 3)
(asdf:test-system :cnvrs)
```

Use a separate empty ASDF cache when validating a different compilation policy.
The policy restriction was also verified to enforce a type check in a function
locally declaring safety 0; the checked run therefore does not silently reuse
production safety-1 code.
