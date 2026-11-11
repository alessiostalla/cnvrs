# Paired Java comparison after configuration-set storage changes

Fresh measurements on 2026-11-11 (Europe/Rome), using the current
[configuration-set representation](../c-reference/storage.md). Native ARM64
SBCL 2.4.0 versus ANTLR 4.13.2 on HotSpot Java 24, with unchanged grammars
and fixtures. These are fresh cross-runtime comparisons, not a controlled
before/after measurement of the optimization.

## Warm parser timing

Milliseconds per call; ratios are CNVRS / Java. Lower is faster.

| Workload | Java recognition | CNVRS recognition | Ratio | Java with tree | CNVRS with tree | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Java 8 | 109.522 | 93.150 | 0.85× | 106.161 | 94.839 | 0.89× |
| C11: GCC warning fixture | 5.514 | 7.344 | 1.33× | 5.805 | 8.628 | 1.49× |
| C11: pointers/calls | 1.168 | 1.274 | 1.09× | 1.077 | 1.294 | 1.20× |
| T-SQL: SELECT | 204.442 | 195.482 | 0.96× | 203.937 | 197.678 | 0.97× |
| T-SQL: CREATE TABLE | 8.912 | 8.749 | 0.98× | 8.869 | 8.619 | 0.97× |
| T-SQL: JSON functions | 75.352 | 69.422 | 0.92× | 75.776 | 69.233 | 0.91× |
| T-SQL: Backup | 5.799 | 6.487 | 1.12× | 5.874 | 6.457 | 1.10× |

Java 8 favors CNVRS in all three pairs: recognition takes 15% less time,
and tree parsing 11% less. C11 remains the largest measured warm parser gap:
the GCC fixture takes 33% more time for recognition and 49% more with trees.
The pointer fixture takes 9% and 20% more respectively.

T-SQL SELECT and CREATE TABLE are close to parity, with medians slightly
favoring CNVRS. SELECT tree medians are Java 203.94 / 202.71 / 210.61 ms
versus CNVRS 195.83 / 204.46 / 197.68 ms; pair two favors Java. Its 3%
aggregate tree advantage should not be read as a robust general lead. JSON
takes about 8–9% less time; Backup still takes about 10–12% more. These are
individual syntax fixtures, not a representative application traffic mix.

## Tree allocation, cold caches, and pipelines

Allocation is decimal MB per call; cold times clear prediction caches.

| Workload | Java warm allocation MB | CNVRS warm allocation MB | Less allocation | Java cold tree ms | CNVRS cold tree ms | Java warm pipeline ms | CNVRS warm pipeline ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Java 8 | 200.964 | 98.832 | 50.8% | 753.572 | 655.572 | 106.090 | 93.791 |
| C11: GCC warning fixture | 10.779 | 7.581 | 29.7% | 9.617 | 13.058 | 5.988 | 10.059 |
| C11: pointers/calls | 2.367 | 1.240 | 47.6% | 3.448 | 4.293 | 1.136 | 1.425 |
| T-SQL: SELECT | 326.755 | 149.347 | 54.3% | 647.032 | 720.613 | 205.335 | 200.272 |
| T-SQL: CREATE TABLE | 13.060 | 6.774 | 48.1% | 56.438 | 59.907 | 8.938 | 8.798 |
| T-SQL: JSON functions | 124.796 | 60.882 | 51.2% | 331.026 | 363.159 | 76.337 | 70.057 |
| T-SQL: Backup | 9.496 | 5.168 | 45.6% | 30.500 | 33.168 | 5.951 | 6.697 |

CNVRS allocates fewer bytes in every large-grammar parser workload here:
about 30–48% less for C11, 51% for Java 8, and 46–54% for T-SQL tree
parsing. Lower allocation alone does not eliminate the C11 timing gap.
Cold-cache C11 GCC and T-SQL tree parsing remain slower; Java 8 cold tree
parsing favors CNVRS.

The larger C11 pipeline takes 10.06 ms versus Java's 5.99 ms (1.68×).
Lexer timing remains substantially slower and was not the focus of the
recent optimization. Full phase tables, including lexer results and IRI,
are linked below. IRI tree parsing is 0.06990 ms native versus 0.026945 ms
Java; its very short timings are particularly sensitive to warmup and scheduling.

## Per-process warm tree medians

Fresh process pairs in execution order, milliseconds per call.

| Workload | Java pairs 1 / 2 / 3 | CNVRS pairs 1 / 2 / 3 |
| --- | --- | --- |
| Java 8 | 106.161 / 105.449 / 109.309 | 96.353 / 94.537 / 94.839 |
| C11: GCC warning fixture | 5.858 / 5.805 / 5.616 | 8.628 / 8.646 / 8.414 |
| C11: pointers/calls | 1.122 / 1.067 / 1.077 | 1.322 / 1.232 / 1.294 |
| T-SQL: SELECT | 203.937 / 202.705 / 210.611 | 195.833 / 204.462 / 197.678 |
| T-SQL: CREATE TABLE | 8.708 / 8.869 / 8.955 | 8.378 / 8.699 / 8.619 |
| T-SQL: JSON functions | 73.957 / 75.776 / 76.364 | 69.772 / 68.638 / 69.233 |
| T-SQL: Backup | 5.874 / 5.834 / 6.116 | 6.457 / 6.348 / 6.505 |

All 48 measurement processes completed successfully. Token text/location/channel
signatures and input counts match across runtimes; C11 and T-SQL also match
normalized token kinds and parser topology. Every phase has matching trained
cache populations between runtimes. Recorded runtime/harness hashes remained
unchanged throughout the run.

## Method and limits

The existing C11, Java 8/IRI, and T-SQL comparison scripts ran sequentially.
Each workload has three fresh processes per runtime, reversing runtime order
in pair two. Every phase has three cold-cache calls and seven warm batches;
parser batches contain two calls. Headline warm times are medians of three
per-process medians of seven batch means. Cold times are medians of nine calls.
Java trains up to 2,000 calls or five seconds per phase; native C11/T-SQL
trains ten calls, Java 8 three, and IRI twenty. Both runtimes train once after
the last cold call.

Parser-only phases reuse prepared tokens; pipelines include lexing. Recognition
disables tree building. Tree phases use each runtime's native representation,
so equal tree structure across Java and Lisp is not asserted. The C11 importer
retains its known implicit-literal lexer aliases; normalized token-kind
signatures account for those aliases.

Both runtimes use 2 GB heap limits. Grammar import, Java generation, native
compilation, typed ATN preparation, file I/O, cache clearing, and explicit
pre-cold GC are excluded. Normal per-call setup and measured-call GC are
included. T-SQL preparation saves freshly compiled code with empty caches;
each measurement starts a fresh process from that core. Allocation means
cumulative bytes allocated, not live or peak heap.

No runtime code was changed for this comparison. The working tree includes
the uncommitted representation changes, so source hashes identify the measured
code more precisely than the Git revision alone. Earlier controlled before/after
tests already verified direct compiled runners, interpreter/tree equality, and
ordered prediction traces for these representation changes.

## Raw results and reproduction

- C11: [tables](../c-reference/storage-java-results/summary.md), [numeric results](../c-reference/storage-java-results/summary.json), [environment](../c-reference/storage-java-results/environment.txt).
- Java 8 and IRI control: [tables](storage-java-results/summary.md), [numeric results](storage-java-results/summary.json), [environment](storage-java-results/environment.txt).
- T-SQL: [tables](../tsql/storage-java-results/summary.md), [numeric results](../tsql/storage-java-results/summary.json), [environment](../tsql/storage-java-results/environment.txt).
- [Source and harness hashes](storage-java-results/source-sha256.json).

From the repository root, with Java 24 first on `PATH`, `LANG` and `LC_ALL`
set to `en_US.UTF-8`, `SBCL_BIN` pointing to native SBCL, `REFERENCE_JAR` to
the ANTLR 4.13.2 complete jar, and `ASDF_OUTPUT_TRANSLATIONS` set to an
isolated cache directory:

```sh
bash bench/c-reference/compare.sh bench/c-reference/storage-java-results
bash bench/java-reference/compare.sh bench/java-reference/storage-java-results
python3 bench/java-reference/summarize.py bench/java-reference/storage-java-results
bash bench/tsql/compare.sh bench/tsql/storage-java-results
```
