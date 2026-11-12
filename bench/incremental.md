# Checkpoint parsing: behavior and performance

Measured 2026-11-12 against baseline
`c7c100caa5f5a32ffba886e6661db4438ed1752b`.

For a subsequent before/after rerun of Java 8 and both C11 inputs on native
ARM64 SBCL 2.4.0, see the [native benchmark recheck](checkpoint-recheck.md).
The measurements below retain their original x86-64 SBCL 2.0.2 environment.

Incremental sessions retain completed prefix nodes and parser continuations at
declared rule returns. Every edit reparses the suffix from the latest checkpoint
whose consumed tokens and lookahead dependencies are unchanged. Source input is
fully relexed. Checkpoints share persistent child-list spines, so accumulating
methods in a class does not copy the entire class prefix at every checkpoint.

Sessions use the explicit-stack executor. Batch parsing still uses native rule
functions and prediction loops without observation. An observed predictor is
generated from the same forms as the batch predictor and tracks lookahead in
both SLL and full-context execution. The session's typed-token adapter uses the
executor's logical cursor directly, avoiding a physical-to-logical hash entry
for every unchanged prefix token.

## Method

The batch regression comparison uses the existing IRI and Java 8 workloads in
[benchmark.lisp](java-reference/benchmark.lisp). Before and after run in separate
processes, sequentially, with order reversed in trial two. Both versions use the
same harness and dependencies. Each phase has seven warm batches in each of
three process trials; reported values are medians of the three batch medians.
IRI uses 2,000 iterations per batch and Java uses five. Grammar import and
compilation are outside the timed sections. Timing uses SBCL's millisecond wall
clock, so very short lexer measurements can fall below timer resolution.

[incremental.lisp](incremental.lisp) measures seven warm samples per case:

- Character input: 1,000 bracketed methods, 10,000 characters, 100 iterations per
  sample. This isolates parsing without a lexer.
- Java 8: a class with 12 small methods, 20 iterations per sample, including full
  source lexing. Checkpoints select the imported `methodDeclaration` rule.
- Initial sessions, unchanged revisions, and alternating edits in the first,
  middle, and final method. Edits preserve text length. Batch and incremental
  execution construct trees.

The environment is macOS on an arm64 host running x86-64 SBCL 2.0.2 through
`/usr/local/bin/sbcl`, with a 2 GiB heap and 256 MiB control stack. These are
within-environment comparisons; they do not update the repository's native SBCL
versus Java performance comparison.

## Results

### Ordinary batch parsing

Times are milliseconds per call. The Java 8 reference workload contains 505
tokens; it is separate from the smaller 12-method incremental workload below.

| Workload | Phase | Before | After | Change |
| --- | --- | ---: | ---: | ---: |
| IRI | Lexer | 0.0440 | 0.0460 | +4.5% |
| IRI | Recognition | 0.0630 | 0.0640 | +1.6% |
| IRI | Tree parsing | 0.1280 | 0.1335 | +4.3% |
| IRI | Lexer + tree parsing | 0.1740 | 0.1790 | +2.9% |
| Java 8 | Lexer | 0.2000 | 0.2000 | 0.0% |
| Java 8 | Recognition | 157.4000 | 155.6000 | -1.1% |
| Java 8 | Tree parsing | 158.4000 | 157.2000 | -0.8% |
| Java 8 | Lexer + tree parsing | 159.0000 | 160.6000 | +1.0% |

The small IRI timing regression remains visible in this comparison: approximately
5.5 microseconds for tree parsing. Its unchanged lexer also measured slower, so
the measurements do not isolate all of that drift to parser changes. Java batch
results stay within approximately 1% of baseline. These observations do not
establish zero overhead on every workload.

An intermediate implementation allocated an extra 16 bytes per batch call.
Moving generic-executor initialization after the native fast-path return removed
that overhead and avoided allocating unused fallback frames. Final IRI tree
allocation fell from approximately 79,167 to 79,054 bytes per call; Java tree
allocation fell by approximately 112 bytes on a roughly 93 MB baseline. Lexer
allocation stayed unchanged. Every DFA/context-cache signature matches the
baseline across all three runs.

### Incremental sessions

Times include tree construction and, for Java, full source lexing. Changes
alternate between two complete revisions, so each timed edit actually changes
the input. A no-op returns the existing root after validating the tokens.

| Operation | Character input, ms | Java 8, ms |
| --- | ---: | ---: |
| Ordinary batch parse | 3.58 | 0.65 |
| Initial incremental parse | 5.53 | 0.65 |
| No-op revision | 0.32 | 0.15 |
| Edit first method | 5.52 | 0.70 |
| Edit middle method | 3.16 | 0.50 |
| Edit final method | 0.76 | 0.35 |

Late edits are **4.71× faster** in the character workload and **1.86× faster** in
the Java workload. Their restart offsets are 9,990 and 102 visible tokens,
respectively. Late-edit allocations are approximately 193 KB versus 1,643 KB
for character batch parsing, and 74 KB versus 124 KB for Java batch parsing.

The initial and early-edit character cases cost about **54% more time** than
ordinary batch parsing, while allocating fewer bytes. The Java initial case is
similar to batch parsing; an early Java edit costs about 8% more in this small
workload. Middle and late edits benefit from prefix reuse. Incremental execution
therefore has a workload-dependent cost, rather than an unconditional speedup.

## Validation

`asdf:test-system :cnvrs` passes **13,480 checks**, including 173 incremental
checks. Coverage includes FASL declarations, grammar composition and cloning,
prefix node identity, unchanged old trees, repeated edit orders, insertion and
deletion, caller lookahead into the suffix, EOF dependencies, filtered and all
channels, lexer token merges and modes, left and right recursion, open tree
labels, rejected callbacks/builders, caller-supplied lexeme values, and
transactional failure. Imported Java method edits are compared with fresh batch
trees. Existing Java prediction, topology, lexer and dispatch checks remain
unchanged.

Raw measurements are in [incremental-results](incremental-results/). Reproduce
the incremental workload and summarize the saved comparison with:

```sh
LC_ALL=en_US.UTF-8 XDG_CACHE_HOME=/tmp/cnvrs-cache \
  sbcl --dynamic-space-size 2048 --control-stack-size 256 \
  --script bench/incremental.lisp
python3 bench/incremental-summary.py
```

To repeat the batch comparison, archive the baseline commit into a separate
directory, copy the current benchmark harness into that archive, and run the
following in each checkout. Alternate process order across three trials and
save the `RUNTIME`, `FIRST`, `COLD`, `WARM` and `CACHE` records with the filenames
used in `incremental-results`.

```sh
LC_ALL=en_US.UTF-8 XDG_CACHE_HOME=/tmp/cnvrs-cache \
CNVRS_BENCH_ITERATIONS=2000 \
  sbcl --dynamic-space-size 2048 --control-stack-size 256 \
  --script bench/java-reference/benchmark.lisp iri bench/java-reference/iri.txt
LC_ALL=en_US.UTF-8 XDG_CACHE_HOME=/tmp/cnvrs-cache \
CNVRS_BENCH_ITERATIONS=5 \
  sbcl --dynamic-space-size 2048 --control-stack-size 256 \
  --script bench/java-reference/benchmark.lisp java8 bench/antlr4-grammar/Bench.java
```

## Limits

Full lexing, token-prefix comparison, and typed-token encoding remain linear in
input size. A late edit does not provide constant-time reparsing. Initial parses
and edits near the start can pay more for the explicit executor and checkpoint
construction than a normal compiled batch parse. These costs should guide the
choice between batch and incremental parsing.

Allocation figures count cumulative bytes per call, rather than retained heap.
Reused lazy lexemes can retain earlier complete source revisions; retained-memory
behavior on long editing sessions has not been benchmarked here.

Checkpoints are validated dynamically as well as statically. A method whose
text is unchanged can still be invalidated by a caller's lookahead. Lexer token
merges, source-location changes, EOF reads, and edits to hidden channels can
also force an earlier restart. Unsupported callbacks and builders are rejected;
recovery is unsupported. See the [API documentation](../README.md#incremental-parsing).
