# T-SQL compiled-parser comparison

Historical run before compact conflict grouping. See the
[latest paired Java comparison](compact.md) for current results.

Fresh paired measurements on 2026-11-10, following the
[compiler resource fix](README.md). The unchanged upstream T-SQL grammar is
compiled to native rule runners in CNVRS and generated Java by ANTLR 4.13.2.

## Results

Warm times in milliseconds per call; ratio is CNVRS / Java.

| Input | Java parser + tree | CNVRS parser + tree | Ratio | Java pipeline | CNVRS pipeline | Ratio |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| SELECT | 208.161 | 245.357 | 1.18× | 203.364 | 245.460 | 1.21× |
| CREATE TABLE | 8.506 | 10.991 | 1.29× | 8.937 | 10.749 | 1.20× |
| JSON functions | 78.112 | 88.288 | 1.13× | 75.598 | 89.153 | 1.18× |
| Backup | 5.929 | 7.815 | 1.32× | 5.940 | 7.880 | 1.33× |

The compiled parser with tree construction is **13–32% slower** than Java on
these samples; the complete pipeline is **18–33% slower**. Recognition without
trees is 17–34% slower, so tree construction is not the main source of the gap.
Cold-cache pipelines range from 20–27% slower.

For SELECT, warm tree parsing allocates **244.3 MB** in CNVRS versus **326.8 MB**
in Java (25% less). The other three samples allocate 16–18% less. Both runtimes
still allocate heavily on SELECT and JSON; their matching trained parser
DFA/context-cache counts establish equivalent cache coverage, but do not by
themselves identify which internal operations dominate.

Lexing is 5.5–6.5× slower and allocates 6.8–8.4× more in CNVRS, but takes only
0.086–0.974 ms per warm call here. Parsing dominates the pipeline. On SELECT,
the lexer gap is about 0.80 ms versus a roughly 42 ms pipeline gap.

All 24 logs passed token-count, default-channel count, token text/location/channel
and kind signature checks. Parser topology and trained lexer/parser DFA states,
lexer edges, and context-cache counts match between runtimes. Full cold,
allocation, cache and per-process tables are in the [raw summary](benchmark-results/summary.md).

The subsequent [warm recognition profile](profile.md) attributes CPU, allocation,
prediction operations, and chunk traffic. The [conflict-group optimization](conflict.md)
records the subsequent implementation and controlled before/after measurements.

## Method

Native ARM64 SBCL 2.4.0 and HotSpot 24 run sequentially on the same machine,
with 2 GB heap limits. Each of the four upstream SQL examples has three fresh
processes per runtime; the second pair reverses runtime order. No grammar or
input was simplified. The source revision is pinned in the compiler report;
[environment and source hashes](benchmark-results/environment.txt) identify the
working copy, including uncommitted compiler and lookup improvements.

A fresh Lisp core saves the native-compiled parser and lexer with empty caches.
Each measurement loads that core in a fresh process. Import, native compilation,
Java generation/compilation, ATN adaptation, file I/O, cache clearing, and explicit
pre-cold GC are excluded. Normal per-call setup and any GC during calls are
included. This measures parsing throughput, rather than application startup or
parser build time. Full grammar runtime and FASL runners were independently
validated against the interpreter before this comparison.

Four phases separate lexing, recognition without tree construction, parsing
prepared tokens into native trees, and the lexer/tree pipeline. Both parsers
require EOF; CNVRS tree roots must span all default-channel tokens. Token text,
positions, lines, columns, channels, and symbolic kinds are checked by signatures.
The summary checks stable lexer ATN sizes, matching parser ATN sizes, and
matching trained DFA/context cache sizes. Both have 1,212 lexer rules and
609 parser rules / 14,516 parser ATN slots / 1,840 decisions. CNVRS has
14,857 lexer ATN slots versus Java's 14,856; this small frontend representation
difference is retained in the measured behavior.
Native tree representations differ between the runtimes.

Each phase has three cold-cache calls and seven warm batches, each containing
100 lexer calls or two parser/pipeline calls. Java trains for up to 2,000 calls
or five seconds per phase; Lisp runs ten training calls. Both train once after
the final cold call. Warm results are medians of three per-process medians of
seven batch means; cold results are medians of nine calls. Allocation measures
cumulative allocated bytes, rather than peak/live memory, using SBCL's bytes
consed counter and Java's current-thread allocation counter.

The samples exercise SQL syntax, not database execution or a representative
production traffic distribution. The largest sample is only 20,047 characters;
ratios should not be extrapolated to all T-SQL applications.

## Reproduce

From the repository root, with Java 24 first on `PATH`:

```sh
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
ASDF_OUTPUT_TRANSLATIONS='(:output-translations (t "/tmp/cnvrs-tsql-cache/") :ignore-inherited-configuration)' \
REFERENCE_JAR=/path/to/antlr-4.13.2-complete.jar \
SBCL_BIN=/path/to/native/sbcl \
  bash bench/tsql/compare.sh
```

The script builds both parsers, runs all 24 processes sequentially, validates
logs, and writes [complete tables](benchmark-results/summary.md) and
[machine-readable results](benchmark-results/summary.json). Runtime sources
are unchanged for this benchmark.
