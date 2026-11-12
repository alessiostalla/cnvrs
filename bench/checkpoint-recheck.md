# Native Java 8 and C11 rerun

Measured 2026-11-12, comparing ordinary full parsing before checkpoint support
(`c7c100caa5f5a32ffba886e6661db4438ed1752b`) with the committed implementation
(`2d3f71e`). Checkpoint sessions are not enabled in these benchmarks. No
production code was changed for this rerun.

These runs use **native ARM64 SBCL 2.4.0**, unlike the x86-64 SBCL 2.0.2 used in
the initial [incremental performance report](incremental.md). ANTLR 4.13.2 on
Java 24 supplies a fresh reference comparison. Absolute timings from these two
Lisp environments should not be compared as a before/after result.

## Before and after checkpoint support

Warm milliseconds per call. Each figure is the median of three fresh-process
medians, each computed from seven batch means. Positive changes mean slower.

| Workload | Phase | Before | Current | Change |
| --- | --- | ---: | ---: | ---: |
| Java 8 | Lexer | 0.13960 | 0.14180 | +1.6% |
| Java 8 | Recognition | 96.54000 | 98.69520 | +2.2% |
| Java 8 | With tree | 97.90780 | 96.58080 | -1.4% |
| Java 8 | Lexer + tree | 100.34360 | 97.90300 | -2.4% |
| C11 GCC fixture | Lexer | 1.33571 | 1.31233 | -1.8% |
| C11 GCC fixture | Recognition | 6.94115 | 6.91395 | -0.4% |
| C11 GCC fixture | With tree | 8.08805 | 8.20505 | +1.4% |
| C11 GCC fixture | Lexer + tree | 9.76045 | 9.69985 | -0.6% |
| C11 pointers/calls | Lexer | 0.08145 | 0.07999 | -1.8% |
| C11 pointers/calls | Recognition | 1.23325 | 1.21680 | -1.3% |
| C11 pointers/calls | With tree | 1.28120 | 1.28220 | +0.1% |
| C11 pointers/calls | Lexer + tree | 1.39795 | 1.36650 | -2.2% |

The rerun does not show a consistent broad batch regression. Java recognition
is 2.2% slower by the median, while its tree and pipeline phases are faster;
C11 tree parsing differs by +1.4% and +0.1%, while both pipelines are faster.
This is evidence for these workloads and this runtime, rather than proof of
zero overhead.

Individual process results show variability. Java tree medians are
97.908–98.001 ms in two baseline trials and 96.135 ms in the third; current
trials are 96.581, 96.095 and 100.363 ms. The large C11 current tree medians
are 8.924, 8.205 and 7.993 ms. A single run would therefore give a misleading
impression of the change.

The earlier IRI observation remains separate: this rerun does not measure IRI
or establish the cause of its x86 timing difference.

## Fresh ANTLR Java reference

Warm tree-parsing milliseconds per call, from three new Java processes per
input. Both SBCL and the Java 24 VM run natively on ARM64.

| Workload | Current CNVRS | ANTLR Java | CNVRS / Java |
| --- | ---: | ---: | ---: |
| Java 8 | 96.58080 | 105.15202 | 0.92× |
| C11 GCC fixture | 8.20505 | 5.69171 | 1.44× |
| C11 pointers/calls | 1.28220 | 1.08379 | 1.18× |

CNVRS remains faster on this Java 8 input and slower on both C11 inputs. The
[full summary](checkpoint-recheck-results/summary.md) includes lexer,
recognition and pipeline comparisons. Its [numeric results](checkpoint-recheck-results/summary.json)
also retain individual process medians, cold timings and allocations.

All 27 final process records passed the token-signature and trained-cache
comparisons; C11's normalized token-kind signatures also match. Source and input
hashes were checked again after measurement and remained unchanged.

## Method and reproduction

The unchanged Java 8 fixture has 505 tokens. C11 uses the existing GCC warning
fixture (6,811 tokens, 3,658 on the default channel) and the function-pointer/
call fixture (401 tokens, 253 on the default channel). Grammars and inputs are
unchanged. Parser-only phases reuse prepared tokens; pipeline phases include
lexing. Full-input parsing is checked, including tree end positions in Lisp.

Processes run sequentially with a 2 GiB heap limit. Lisp has a 256 MiB control
stack. CNVRS before/after order is reversed in trial two. Java reference
processes were repeated separately after fixing a log filter that omitted their
standalone token-signature records; the original CNVRS measurements were kept.

Java uses the repository's existing warm-up and sampling harness. CNVRS Java 8
uses five calls per warm batch. CNVRS C11 uses 200 lexer calls or 20 parser/
pipeline calls per warm batch to improve timing resolution. Each phase also
records three cold-cache calls, allocation per call, and trained cache counts.
Grammar import/compilation, I/O, cache clearing, and explicit pre-cold GC are
outside timed sections; normal per-call setup and measured-call GC are included.

[checkpoint-recheck-results](checkpoint-recheck-results/) retains compact raw
records, source/environment hashes, per-process medians, cold timings and
allocations. The [runner](checkpoint-recheck.py) uses an isolated archive of the
baseline and isolated ASDF caches; it leaves runtime sources unchanged.

```sh
SBCL_BIN=/path/to/native/sbcl \
REFERENCE_JAR=/path/to/antlr-4.13.2-complete.jar \
  python3 bench/checkpoint-recheck.py
```
