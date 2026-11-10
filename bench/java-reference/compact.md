# Java 8 and C11 after compact conflict grouping

Fresh paired measurements on 2026-11-10, after the
[conflict-group and temporary-table optimization](../tsql/conflict.md).
Native ARM64 SBCL 2.4.0 versus ANTLR Java 4.13.2 on HotSpot 24; unchanged
grammars and inputs. This report complements the [updated T-SQL comparison](../tsql/compact.md).

## Warm parser and pipeline results

Milliseconds per call; ratios are CNVRS / Java.

| Workload | Java parser + tree | CNVRS parser + tree | Ratio | Java pipeline | CNVRS pipeline | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Java 8 | 119.572 | 99.085 | 0.83× | 126.039 | 102.099 | 0.81× |
| C11: GCC warning fixture | 5.775 | 9.700 | 1.68× | 6.014 | 11.088 | 1.84× |
| C11: function pointers/calls | 1.091 | 1.629 | 1.49× | 1.143 | 1.635 | 1.43× |

Java 8 tree parsing takes **17% less time** than Java in this run; its pipeline
takes 19% less. Recognition alone takes 12% less. C11 remains slower: tree
parsing is **1.49–1.68× Java**, versus 1.80–1.95× in the historical
[C11 run](../c-reference/README.md). Current C11 recognition gaps are 1.28–1.48×
and pipeline gaps 1.43–1.84×.

The old and new runs are not a controlled optimization A/B. In particular,
Java 8 tree times vary across fresh processes: Java 122.51 / 107.75 / 119.57 ms,
CNVRS 98.07 / 120.32 / 99.09 ms. The ranges overlap and one pair favors Java.
The median favors CNVRS, but neither a universal lead nor an additional 17%
optimization speedup follows from this run. The earlier CNVRS Java 8 tree
median was 97.67 ms; the current 99.09 ms is close to that historical value.

## Allocation and cold-cache tree parsing

Allocation is cumulative bytes allocated per tree parse, not live/peak memory.

| Workload | Java warm allocation MB | CNVRS warm allocation MB | Reduction | Java cold ms | CNVRS cold ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| Java 8 | 200.964 | 100.788 | 49.8% | 820.591 | 736.113 |
| C11: GCC warning fixture | 10.779 | 9.545 | 11.4% | 9.583 | 14.424 |
| C11: function pointers/calls | 2.367 | 1.765 | 25.4% | 3.946 | 4.943 |

Java 8 allocates approximately half as many bytes during tree parsing. C11
now also allocates less in the parser phase: 11% less on the large GCC fixture
and 25% less on function pointers/calls. This does not cover lexer allocation:
the large C11 pipeline still allocates 12.03 MB versus Java's 11.29 MB.

## Method and validation

The unchanged [Java 8/IRI](compare.sh) and [C11](../c-reference/compare.sh)
harnesses ran sequentially, with three fresh processes per runtime and workload,
reversing order in pair two. The IRI control was included, for 24 processes total.
Every phase has three cold-cache calls and seven warm batches. Java 8/C11
parser batches have two calls; IRI batches have 100; warm headline times are medians of three per-process medians
of seven batch means. Cold times are medians of nine calls. Java trains up to
2,000 calls or five seconds per phase; native Java 8 trains three calls, C11 ten,
and IRI twenty. Both train once after the final cold call. Both runtimes use
2 GB heaps. Preparation, compilation, file I/O, cache clearing, and explicit
pre-cold GC are excluded. Normal per-call setup and measured-call GC are included.

All input character/token counts and token text/location/channel signatures
match across runtimes. C11 also checks normalized token-kind signatures and
matching parser ATN rule/state/decision counts. Its known lexer frontend
difference remains: literal aliases produce 244 native lexer rules versus
158 Java rules; the [original C11 method](../c-reference/README.md#method-and-validation)
describes normalization and hidden channels. Trees use native runtime representations.

Every phase has identical trained cache populations between runtimes, stable
across all three processes. Runtime/harness hashes match before and after the
complete run. No runtime code was changed, and no test suites were rerun for
this benchmark-only task.

The IRI control records 0.07081 ms native / 0.03080 ms Java for tree parsing
and 0.12631 / 0.04061 ms for the pipeline. These short timings are particularly
sensitive to warmup, timer, and scheduling effects.

## Raw results and reproduction

- Java 8/IRI: [complete tables](compact-results/summary.md), [numeric results](compact-results/summary.json), [runtime metadata](compact-results/environment.txt), [source hashes](compact-results/source-sha256.json), [additional validation](compact-results/validation-extra.txt).
- C11: [complete tables](../c-reference/compact-results/summary.md), [numeric results](../c-reference/compact-results/summary.json), [runtime metadata](../c-reference/compact-results/environment.txt), [source hashes](../c-reference/compact-results/source-sha256.json), [additional validation](../c-reference/compact-results/validation-extra.txt).

From the repository root, with Java 24 first on `PATH`, set `LANG` and `LC_ALL`
to `en_US.UTF-8`, `SBCL_BIN` to native SBCL, `REFERENCE_JAR` to the ANTLR 4.13.2
complete jar, and an isolated `ASDF_OUTPUT_TRANSLATIONS` directory. Then run:

```sh
bash bench/java-reference/compare.sh bench/java-reference/compact-results
python3 bench/java-reference/summarize.py bench/java-reference/compact-results
bash bench/c-reference/compare.sh bench/c-reference/compact-results
```
