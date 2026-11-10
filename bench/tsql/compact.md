# Fresh paired T-SQL comparison after compact conflict grouping

Measured 2026-11-10 after the [conflict-group and temporary-storage optimization](conflict.md).
Native ARM64 SBCL 2.4.0 versus ANTLR Java 4.13.2 on HotSpot 24, with unchanged
grammars and four upstream SQL inputs. Runtime sources were unchanged during this run;
[environment and source hashes](compact-results/environment.txt) identify the working copy.

## Warm results

Milliseconds per call. Parser phases reuse prepared tokens; pipelines include lexing.

| Input | Java parser + tree | CNVRS parser + tree | CNVRS / Java | Java pipeline | CNVRS pipeline | CNVRS / Java |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| SELECT | 208.451 | 214.513 | 1.03× | 207.164 | 217.566 | 1.05× |
| CREATE TABLE | 8.599 | 9.313 | 1.08× | 8.555 | 9.378 | 1.10× |
| JSON functions | 74.224 | 75.082 | 1.01× | 75.726 | 75.070 | 0.99× |
| Backup | 5.660 | 6.692 | 1.18× | 5.674 | 7.221 | 1.27× |

Warm tree parsing is **1–18% slower** than Java, compared with 13–32% in the
[earlier run](benchmark.md). SELECT is about 3% slower, and JSON about 1%.
The JSON pipeline is effectively at parity; SELECT is about 5% slower, CREATE
TABLE 10%, and Backup 27%. Small phase differences should not be treated as
precise additive cost breakdowns; phases are timed independently.

## Allocation and cold caches

Tree-parse allocation is cumulative allocated bytes, not live or peak memory.
Cold times clear prediction caches and request GC outside the measured call.

| Input | Java warm allocation MB | CNVRS warm allocation MB | Reduction | Java cold tree ms | CNVRS cold tree ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| SELECT | 326.75 | 183.03 | 44.0% | 648.31 | 756.40 |
| CREATE TABLE | 13.06 | 8.43 | 35.5% | 55.62 | 63.09 |
| JSON functions | 124.80 | 74.97 | 39.9% | 327.69 | 383.06 |
| Backup | 9.50 | 6.36 | 33.0% | 28.96 | 35.41 |

CNVRS allocates **33–44% fewer bytes** during warm tree parsing. Cold-cache
tree parsing remains about **13–22% slower** than Java. Recognition without
trees shows gaps of approximately 1–17%. These measurements do not establish
a runtime-wide ranking across other grammars.

## Method and validation

The [unchanged paired harness](compare.sh) ran three fresh processes per runtime
and input (24 processes total), sequentially, reversing order in pair two.
Each phase measures three cold-cache calls and seven warm batches; batches have
two parser/pipeline calls or 100 lexer calls. Java trains for up to 2,000 calls
or five seconds per phase; Lisp trains ten calls. Both train once after the
final cold call. Warm results are medians of three per-process medians of batch
means; cold results are medians of nine calls. Both runtimes have 2 GB heap limits.

The script freshly generates/compiles Java and prepares a native Lisp core with
empty caches. Timings exclude grammar preparation, compilation, core loading,
ATN adaptation, I/O, cache clearing, and explicit pre-cold GC. They include normal
per-call setup and GC during measured calls. Trees use the native representation
of each runtime. The [earlier method description](benchmark.md#method) provides
the remaining details. No runtime source or tests were modified for this rerun.

All logs pass token-count, default-channel count, text/location/channel signature,
and symbolic-kind signature checks. Parser topology and trained lexer/parser DFA
states, lexer edges, and context-cache populations match across runtimes. The
known lexer ATN representation difference remains: CNVRS has 14,857 slots versus
Java's 14,856, with the same 1,212 lexer rules.

[Complete tables and per-process medians](compact-results/summary.md),
[numeric results](compact-results/summary.json),
[orchestration hashes](compact-results/orchestration-hashes.txt).

The historical runs are useful context, but the separate
[controlled before/after experiment](conflict.md) provides the evidence for the
optimization's causal effect. This fresh run provides the updated Java comparison.

## Reproduce

```sh
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
ASDF_OUTPUT_TRANSLATIONS='(:output-translations (t "/tmp/cnvrs-tsql-cache/") :ignore-inherited-configuration)' \
REFERENCE_JAR=/path/to/antlr-4.13.2-complete.jar \
SBCL_BIN=/path/to/native/sbcl \
  bash bench/tsql/compare.sh bench/tsql/compact-results
```

Place Java 24 first on `PATH` before running.
