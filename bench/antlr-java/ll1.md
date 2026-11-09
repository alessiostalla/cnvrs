# Java-style direct LL(1) dispatch

Measured 2026-11-09 with the uncommitted LL(1) implementation on `chore/antlr4`,
based on `152100f`, native ARM64 SBCL 2.4.0 on Apple M1 Max.

This is a controlled A/B within one process per grammar. Both variants use the
same grammar ATN, tokens and rule compiler; the control clears static direct
maps on its own copy of the graph and recompiles its rule functions to always
invoke adaptive prediction. Production has no new runtime mode or tuning knob.

| Grammar | Measurement | Always adaptive | Direct LL(1) | Change |
| --- | --- | ---: | ---: | ---: |
| IRI | Warm tree parse | 0.21695 ms | 0.08345 ms | **2.60× faster** |
| IRI | Cold-cache tree parse | 1.070 ms | 0.532 ms | 2.01× faster |
| IRI | Warm allocation | 144.6 KB | 113.7 KB | 21.4% less |
| Java 8 | Warm tree parse | 521.57 ms | 514.57 ms | 1.4% faster |
| Java 8 | Cold-cache tree parse | 3623.8 ms | 3377.6 ms | 6.8% faster |
| Java 8 | Cold allocation | 2388.4 MB | 2284.4 MB | 4.4% less |
| Java 8 | Warm allocation | 367.20 MB | 367.19 MB | effectively unchanged |

These are parse-only, trees enabled, complete-input measurements. Lexing,
grammar compilation, ATN adaptation, rule compilation, cache setup and pre-cold
full GC are outside timers. Each variant gets a fresh parser clone in each of
three trials; order alternates. Each trial measures one cold-cache parse, warms
with 20 IRI calls or three Java 8 calls, then measures seven batches of 100 IRI
calls or two Java 8 calls. Warm results are the median of the three per-trial
median batch means. Cold results are the median of three samples. Allocation
is cumulative, in decimal KB/MB, not retained heap.

IRI's warm per-trial medians were 0.21695/0.21681/0.22078 ms for the control and
0.08345/0.08333/0.08455 ms with direct dispatch. Java 8's were
521.57/532.83/518.80 ms versus 514.57/514.22/516.28 ms. The Java 8 warm effect is
small relative to ordinary run variation; the result does not establish a broad
throughput improvement. Larger unrelated desktop workloads were present during
some standalone timing samples, so these interleaved A/B results are used
instead of comparing those samples to yesterday's runs.

The IRI parser now trains 5 DFA states and 20 contexts, matching generated Java,
instead of 56 states / 49 contexts. Java 8 now trains 1,160 states and 24,764
contexts, matching Java, instead of 1,350 / 25,397. Its native parser makes the
same 1,431 adaptive calls in the same order as the checked-in Java trace.
These properties are also regression-tested independently of the timings.

The previous [Java comparison](README.md) measured Java at 0.02810 ms for IRI
and 115.09 ms for Java 8 tree parsing. No new JVM comparison was run for this
A/B experiment. Java 8's warm allocation and time still point to the remaining
adaptive runtime as the main investigation target; tree construction contributes
little on this input.

[Harness](ll1.lisp), [IRI raw results](ll1-results/iri.txt),
[Java 8 raw results](ll1-results/java8.txt), [summary data](ll1-results/summary.json).
Reproduce from the repository root:

```sh
XDG_CACHE_HOME=/tmp/cnvrs-ll1-cache /path/to/native/sbcl --dynamic-space-size 2048 --script bench/antlr-java/ll1.lisp iri
XDG_CACHE_HOME=/tmp/cnvrs-ll1-cache /path/to/native/sbcl --dynamic-space-size 2048 --script bench/antlr-java/ll1.lisp java8
```
