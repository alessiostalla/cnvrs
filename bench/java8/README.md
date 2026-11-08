# Java 8 parser profiling

Measured on 2026-11-07 against CNVRS `587ef77`, with native ARM64 SBCL 2.4.0.
These findings describe the original eager two-token implementation. The current
`chore/performance` implementation bounds arbitrary-depth specialization by
prefix-edge and configuration-work budgets; the harness now profiles that
implementation. `PROFILE_SKIP_TWO_TOKEN` is retained as the diagnostic flag
for disabling multi-token specialization at any depth. To reproduce the original
measurements exactly, run the harness from `587ef77`.

This runs the imported Java 8 grammar on Java source. Grammar conversion,
compilation, and lexing finish before the measured parser phase. Recognition
uses `:tree-builder :none`; the diagnostic cold timings below build trees.

## Findings

Two effects dominate runtime:

1. `contextual-choice` eagerly calls `two-token-lookahead` to build a table
   for every possible first/second token pair in the current return context.
   It does this before considering the actual next input token. This expands
   recursive expression paths that the current input never takes.
2. Closure configurations store a complete return-stack list. `graph-closure`
   deduplicates `(state stack alternative)` keys in an `equal` hash table.
   Many distinct stacks produce the same `sxhash`, leading to repeated deep
   equality comparisons. Ordinary prediction suffers from this too, even
   when eager two-token table construction is bypassed.

For `class Hello { int f() { return 1; } }` (37 characters, 13 tokens), a cold
recognition run exceeded a ten-second limit. Of 4,274 CPU samples:

| Function | Self samples |
| --- | ---: |
| `EQUAL-AUX` | 74.1% |
| `EQUAL` | 3.6% |
| `GETHASH/EQUAL` | 7.1% |
| `PUTHASH/EQUAL` | 2.3% |
| `CONFIGURATION-KEY` | 5.3% |

GC took about 28 ms of CPU time during the ten-second run, with 92 MB
allocated. The input was already tokenized. These observations identify
prediction-key comparison as the immediate bottleneck. Sampling captured
4.274 seconds of the ten-second window; percentages describe samples, not
precise fractions of wall time.

A separate instrumented run stopped after 200,000 unique configuration
visits across 667 closure calls. The largest in-progress closure belonged
to `blockStatement` at input token 8 (`return`). During speculative
`LPAREN` exploration inside `two-token-lookahead`, it had already visited
78,190 configurations, covering only 245 `(state, alternative)` pairs,
with return stacks up to 82 entries deep. Those full configuration keys
produced only 643 distinct `sxhash` values; one value was shared by 1,824
keys. These counts are lower bounds where the visit budget interrupted a
closure. Instrumented timings include counting and hashing overhead.

## Diagnostic experiments

The harness can replace functions within its own process. Neither
experiment changes CNVRS's production prediction policy.

- Bypassing eager two-token table construction made the return-literal
  example finish in approximately 160 ms cold, then 0.019 ms per warm
  recognition call over 100 iterations.
- This alone did not solve `class Hello { void f() { foo(); } }`
  (35 characters, 14 tokens). It still exceeded ten seconds. In 4,802
  samples, `EQUAL-AUX` and `EQUAL` accounted for 88.2% of samples. A bounded
  diagnostic run observed 103,080 configurations in one in-progress closure
  at `blockStatement`, with only 250 `(state, alternative)` pairs and 649
  hash values. One hash value was shared by 2,400 full keys.
- With eager two-token construction bypassed, replacing each complete stack
  by an exact canonical integer ID made both examples finish: about 30 ms
  for the return-literal method and 221 ms for the method call. These were
  single cold tree-building runs, not a throughput benchmark. The prototype
  interns `(return-state, parent-ID)` pairs and preserves stack identity;
  it does not discard caller context. It still retains many distinct
  contexts, so it is diagnostic evidence rather than a complete solution.

The next implementation should make two-token specialization demand-driven
or bounded, and use canonical context identities for closure keys. Sharing
or merging prediction contexts may also be necessary to control the number
of configurations. Reprofile larger programs after each change; these small
examples do not establish general Java 8 performance or compatibility.

## Bounded n-token follow-up

The bounded-lookahead changes on `chore/performance` replace the fixed two-token table
with arbitrary-depth specialization bounded by 64 total token-prefix edges
and 4096 configuration-key visits per contextual decision. Overflow caches
an adaptive-prediction fallback. A zero edge budget disables multi-token
specialization. The configuration budget also covers contextual one-token
analysis, so a large initial closure cannot evade the limit.

On the same native SBCL 2.4.0 setup, the return-literal method completed in
186 ms cold and 0.0195 ms per warm recognition call. The method-call example
still exceeded a three-second limit: ordinary prediction's stack-key problem
remains outside these changes.

There is a warm-path cost. Three interleaved pairs of fresh processes ran the
existing ANTLR grammar-language benchmark on `ANTLRv4Lexer.g4`,
`ANTLRv4Parser.g4`, and `JSON.g4`, with 20 warmups and seven batches of 200
parses per file, without trees. The median sum of per-file medians rose from
0.806 ms on `75ebe87` to 0.854 ms with bounded n-token lookup (about 6%).
Process sums ranged from 0.793–0.819 ms before and 0.853–0.860 ms after.
These are grammar files parsed as data, distinct from the Java source tests.

Validation: 454 suite checks passed, plus 5460 differential cases comparing
bounded specialization, disabled specialization, and the generic parser,
including trees and error diagnostics. The new suite coverage includes exact
budget boundaries, repeated prefixes, three- and five-token lookahead,
filtered channels, recovery insertions, and NIL token keys.

## Reproduce

Supply the upstream
[Java8Lexer.g4](https://github.com/antlr/grammars-v4/blob/master/java/java8/Java8Lexer.g4)
and
[Java8Parser.g4](https://github.com/antlr/grammars-v4/blob/master/java/java8/Java8Parser.g4).
The measured files were downloaded unchanged from `master`; their SHA-256
checksums were:

```text
16331464b1e303b6d2d4e8813f54c82b5707a56efb11eac69c0fa174e678267d  Java8Lexer.g4
ed3ec7f0181bf6e258615ba3fae8ae4d2e8eee0ad4aab474c8a11ad16cdb1940  Java8Parser.g4
```

From the repository root, with Quicklisp/ASDF dependencies installed:

```sh
export SBCL_BIN=/path/to/native/sbcl
export JAVA8_DIR=/path/to/java8
"$SBCL_BIN" --script bench/java8/profile.lisp "$JAVA8_DIR/Java8Lexer.g4" "$JAVA8_DIR/Java8Parser.g4"
PROFILE_MODE=count "$SBCL_BIN" --script bench/java8/profile.lisp "$JAVA8_DIR/Java8Lexer.g4" "$JAVA8_DIR/Java8Parser.g4"
PROFILE_MODE=timing PROFILE_SKIP_TWO_TOKEN=1 PROFILE_INTERN_STACK_KEYS=1 \
  JAVA8_SOURCE='class Hello { void f() { foo(); } }' \
  "$SBCL_BIN" --script bench/java8/profile.lisp "$JAVA8_DIR/Java8Lexer.g4" "$JAVA8_DIR/Java8Parser.g4"
```

`PROFILE_MODE` is `sample` (default), `count`, or `timing`. `PROFILE_SECONDS`
sets the sample/timing timeout (default 10). `PROFILE_VISIT_BUDGET` bounds
unique closure visits in count mode (default 200,000). `JAVA8_SOURCE` changes
the source string. Timing mode reports one cold tree-building parse and the
mean of 1,000 subsequent recognition calls. Presence of
`PROFILE_SKIP_TWO_TOKEN` or `PROFILE_INTERN_STACK_KEYS` enables the respective
diagnostic substitution, including when its value is `0`; leave them unset
for the production parser. Start a fresh process for each experiment.

Use native SBCL for CPU sampling. SBCL 2.0.2 under Rosetta crashed in its
signal/register-state handling during the initial sampling attempt.
