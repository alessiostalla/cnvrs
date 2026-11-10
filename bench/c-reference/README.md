# C11 versus ANTLR Java

Historical results below predate compact conflict grouping. See the
[latest C11 and Java 8 comparison](../java-reference/compact.md) for updated measurements.
The [warm C11 profile](profile.md) locates remaining costs and matches prediction
work against Java.

A full C11 grammar provides a second language comparison after the
[configuration/context lookup optimization](../java-reference/lookup.md).
It has **1,116 lines, 88 parser rules, 1,113 parser ATN slots, and 135 decisions**.
It is smaller than Java 8, but covers a complete language, including C11
constructs and several GCC extensions.

## Results

Warm-cache milliseconds per call, from three fresh process pairs per input:

| Workload | Phase | ANTLR Java | CNVRS | CNVRS / Java |
| --- | --- | ---: | ---: | ---: |
| GCC warning fixture | Lexer | 0.28761 | 1.32885 | 4.62× |
| GCC warning fixture | Recognition only | 5.61329 | 9.88200 | 1.76× |
| GCC warning fixture | Parse with tree | 5.69290 | 11.07700 | 1.95× |
| GCC warning fixture | Lexer + parse with tree | 6.12873 | 12.74600 | 2.08× |
| Function pointers/calls | Lexer | 0.01467 | 0.08392 | 5.72× |
| Function pointers/calls | Recognition only | 1.13265 | 1.94650 | 1.72× |
| Function pointers/calls | Parse with tree | 1.17610 | 2.11950 | 1.80× |
| Function pointers/calls | Lexer + parse with tree | 1.15315 | 2.06550 | 1.79× |

C11 remains slower than Java on these inputs: recognition alone is 1.72–1.76×,
tree parsing 1.80–1.95×, and the full pipeline 1.79–2.08×. The lexer gap is
4.62–5.72×, but recognition contributes the largest absolute difference on the
larger input. This differs from the prior Java 8 workload, where the latest
lookup changes put CNVRS slightly ahead; that result does not generalize to all
grammars. These measurements do not identify the remaining internal hotspots.

| Workload | Cold tree: Java ms | Cold tree: CNVRS ms | Warm tree allocation: Java MB | Warm tree allocation: CNVRS MB |
| --- | ---: | ---: | ---: | ---: |
| GCC warning fixture | 10.082 | 15.864 | 10.779 | 12.482 |
| Function pointers/calls | 3.342 | 5.265 | 2.367 | 2.649 |

All twelve processes passed the token-stream/kind checks and full-input parse
checks. Parser ATN counts and all trained cache counts match between runtimes:
the large input learns 106 lexer states / 588 edges and 206 parser states /
994 contexts; the small input learns 62 / 193 and 115 / 665 respectively.
Warm tree allocation is 1.16× Java on the larger input and 1.12× on the smaller.

The [detailed summary](results/summary.md) contains all cold times, allocations,
and per-process warm medians. [Raw logs and source hashes](results/) are retained.
Small differences between separately timed tree and pipeline medians are within
run-to-run variation.

## Sources and inputs

The grammar and examples are pinned to grammars-v4 commit
[`753536777d827ccc0c9b108531ea67375c2039ac`](https://github.com/antlr/grammars-v4/tree/753536777d827ccc0c9b108531ea67375c2039ac/c).
This version predates the target-specific C base classes in newer revisions.
No grammar rules or example statements were changed; trailing whitespace at EOF is
normalized. The grammar retains Sam Harwell's upstream BSD license notice.

| Workload | Input | Characters | All tokens | Default-channel tokens |
| --- | --- | ---: | ---: | ---: |
| GCC warning fixture | `examples/Wmisleading-indentation.pp.c` | 26,587 | 6,811 | 3,658 |
| Function pointers/calls | `pointers.c` | 1,180 | 401 | 253 |

`pointers.c` joins `FuncCallAsFuncArgument.c`, `FuncCallwithVarArgs.c`, and
`FunctionPointer.c`, in that order, with one newline between files. These are
upstream syntax/test inputs, not an application traffic distribution.
Preprocessor directives, whitespace, and comments follow the grammar's hidden
channels; neither runtime executes a C preprocessor or checks C type semantics.

## Method and validation

Runs use native ARM64 SBCL 2.4.0 and HotSpot 24 on the same machine as the prior
Java 8 comparison, with ANTLR 4.13.2. The environment file records the Git commit
and hashes of the working runtime sources, grammars, inputs, and harnesses.
The lookup optimizations were still uncommitted, so the commit alone does not
identify the measured code.

Each input has three fresh processes per runtime, sequentially, reversing
runtime order for the second pair. Every phase has three cold-cache calls and
seven warm batches. Lexer batches have 100 calls; parser/pipeline batches have
two. Headline warm times are medians of three per-process medians of seven
batch means; cold times are medians of nine individual calls. Java trains for
up to 2,000 calls or five seconds per phase, and Lisp runs ten training calls
before the cold trials. Both train once after the final cold call.

Parser-only phases reuse prepared tokens. Pipeline phases include lexing and
filtering hidden tokens. Both runtimes retain DFA/context caches during warm
calls, clear them before cold calls, and require successful parsing through
EOF. CNVRS tree calls also check that the root spans every default-channel
token. Token counts and FNV64 signatures check text, positions, lines, columns,
and channels. A separate signature checks kinds after normalizing literal
aliases to their literal text; other kinds retain their symbolic names.

The importer creates a separate implicit lexer rule for a parser literal even
when a named lexer rule already matches it. Thus CNVRS has 244 lexer rules /
1,906 ATN slots versus Java's 158 / 1,327, although both use the same grammar
and produce equivalent token streams. The parser rule/state/decision counts
match. This frontend difference is retained in the measured product behavior.

Timing excludes grammar import, generation, compilation, ATN adaptation, I/O,
cache clearing, and explicit pre-cold GC. It includes normal per-call setup and
GC during a measured call. Both processes use 2 GB heap limits. Allocation
means cumulative bytes allocated, not peak/live heap. Trees use each runtime's
native node representation; this benchmark does not establish identical tree
shape or semantic analysis.

## Reproduce

From the repository root, with Java 24 first on `PATH`:

```sh
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
ASDF_OUTPUT_TRANSLATIONS='(:output-translations (t "/tmp/cnvrs-c-cache/") :ignore-inherited-configuration)' \
REFERENCE_JAR=/path/to/antlr-4.13.2-complete.jar \
SBCL_BIN=/path/to/native/sbcl \
  bash bench/c-reference/compare.sh
```

The script generates Java, runs all twelve processes sequentially, and validates
and summarizes the logs. No production code was changed for this comparison.

## Other large-grammar attempts

[T-SQL](../tsql/README.md) initially exhausted both the 2 GB and 8 GB compilation
heap settings. The subsequent investigation fixed the compiler scope/retention
problems and validates runtime and FASL compilation within 2 GB using the default
stack. This C11 report predates those compiler changes. SQLite was also inspected;
the importer rejects its nongreedy parser repetitions. Neither grammar was
simplified to force a comparison.
