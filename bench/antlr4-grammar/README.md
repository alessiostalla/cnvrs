# Parsing ANTLR4 grammar files: CNVRS versus ANTLR4/Java

This benchmark parses `.g4` source files as data. CNVRS uses its built-in
`cnvrs/antlr4` grammar; Java uses `ANTLRv4Lexer.g4`, `ANTLRv4Parser.g4`, and
`LexerAdaptor.java` generated/compiled with ANTLR 4.13.2. CNVRS does not yet
compile arbitrary `.g4` files into parsers, so this is a comparison of the two
ANTLR4-language parsers, **not** of parsers generated from the sampled files.

Corpus: [antlr/grammars-v4](https://github.com/antlr/grammars-v4/) at commit
[`b96e04db9d54bb313e542cc3e6ee913900a21520`](https://github.com/antlr/grammars-v4/commit/b96e04db9d54bb313e542cc3e6ee913900a21520):

| File | Bytes |
| --- | ---: |
| `antlr/antlr4/ANTLRv4Lexer.g4` | 9,235 |
| `antlr/antlr4/ANTLRv4Parser.g4` | 8,206 |
| `java/java/JavaLexer.g4` | 6,305 |
| `java/java/JavaParser.g4` | 19,951 |
| `json/JSON.g4` | 1,221 |
| `python/python3/Python3Lexer.g4` | 10,139 |
| `python/python3/Python3Parser.g4` | 12,649 |

## Results

Measured 2026-10-31 on one macOS 14.6 ARM64 machine, native ARM64 SBCL 2.4.0,
native ARM64 Java 24, and ANTLR 4.13.2. All seven files parsed successfully
in both implementations.

Numbers are median elapsed milliseconds per parse across seven timed batches.
Tree construction was disabled for this table.

| Input | CNVRS ms | ANTLR4/Java ms | CNVRS / Java |
| --- | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 12.41 | 0.154 | 81× |
| ANTLRv4Parser.g4 | 12.77 | 0.147 | 87× |
| JavaLexer.g4 | 11.47 | 0.173 | 66× |
| JavaParser.g4 | 37.02 | 0.492 | 75× |
| JSON.g4 | 2.36 | 0.028 | 84× |
| Python3Lexer.g4 | 14.95 | 0.184 | 81× |
| Python3Parser.g4 | 27.25 | 0.320 | 85× |

The sum of these per-file medians is 118.21 ms for CNVRS and 1.498 ms for
Java, a 79× ratio. With tree construction enabled, the corresponding sums
were 120.65 ms and 1.568 ms, a 77× ratio. An earlier x86-64 SBCL 2.0.2
run under Rosetta, before the custom comparator, took 224.65 ms summed over
the same files, giving a 150× ratio against Java at that time. The runtime
architecture, SBCL version, and comparator all changed, so the two CNVRS runs
do not isolate any one of those effects.

## SBCL profile

Before the custom FSET comparator, a warm single-threaded run on
`JavaParser.g4` using the default `(:locked :fset)` caches took about 53 ms
per full parse. Profiling 200 full parses with SBCL's `sb-sprof` in CPU mode
collected 4,680 samples. Its largest
self-sample groups were generic method dispatch (26.6%), FSET list and number
comparisons (14.4% combined), and lexer NFA closure (4.6%). Samples are an
approximation; generic dispatch includes calls from more than one subsystem.

Separately timing phases on the same file gave 46.5 ms for lexing and 9.1 ms
for parsing an already tokenized vector. Lexing therefore accounts for about
84% of the sum of those phase timings. The profiler points first to lexer
transition-cache key comparisons and repeated closure work, then to parser
prediction-cache lookups.

An experiment replacing CNVRS's per-lookup generic cache method calls with
bound functions changed the seven-file no-tree sum from 170.24 to 169.07 ms
(0.7%), a difference that may be measurement noise. That change was reverted.
FSET supports a named key comparator for WB maps, so the current FSET backend
uses a function specialized for common cache keys. In a subsequent 100-parse
CPU profile of `JavaParser.g4`, the generic dispatch frame fell from 26.6% to
2.2% of samples; the new comparator accounted for 28.6%. Those percentages
come from separate sampling runs and are directional, while the elapsed-time
measurements below show the overall effect.

## Cache backend comparison

Using native ARM64 SBCL 2.4.0 and the same seven files, each configuration ran
in a fresh process. The two current-code runs cloned both the ANTLR4 lexer and
parser to the named backend; the old FSET run used the default compiled objects
before the comparator change. Each run used 10 warmup parses per file, then
seven batches of 20 parses;
the table gives the median milliseconds per parse with tree construction
disabled. The old default-FSET column predates the custom comparator; the
other two columns use the current code.

| Input | Old locked FSET | Custom-compare locked FSET | Locked hash table |
| --- | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 18.21 | 12.41 | 6.90 |
| ANTLRv4Parser.g4 | 18.67 | 12.77 | 6.95 |
| JavaLexer.g4 | 16.27 | 11.47 | 6.74 |
| JavaParser.g4 | 53.14 | 37.02 | 20.96 |
| JSON.g4 | 3.33 | 2.36 | 1.36 |
| Python3Lexer.g4 | 21.71 | 14.95 | 8.18 |
| Python3Parser.g4 | 38.91 | 27.25 | 16.91 |
| Sum of per-file medians | 170.24 | 118.21 | 68.00 |

The custom comparator made locked FSET 1.44× faster by this aggregate. Locked
hash tables remain 1.74× faster than custom-compare locked FSET. These are
single runs per configuration, and the sums weight larger files more heavily.

## Flat array cache keys

The lexer transition cache now uses a flat array containing a character code
and active state IDs. The full-context parser decision cache uses a flat array
containing a decision state ID and return stack IDs. The hash-table backend
looks up these keys structurally in a separate `equalp` table; other keys keep
their original `equal` behavior.

Rerunning the seven-file benchmark on the same ARM64 SBCL and Java runtimes,
with 10 warmups and seven batches of 20 Lisp parses (200 warmups and seven
batches of 200 Java parses), gave these median milliseconds per parse:

| Input | Flat locked FSET | Flat locked hash table | ANTLR4/Java |
| --- | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 11.326 | 7.109 | 0.148 |
| ANTLRv4Parser.g4 | 11.573 | 7.211 | 0.150 |
| JavaLexer.g4 | 10.414 | 6.866 | 0.172 |
| JavaParser.g4 | 34.124 | 21.410 | 0.503 |
| JSON.g4 | 2.171 | 1.416 | 0.029 |
| Python3Lexer.g4 | 13.811 | 8.365 | 0.189 |
| Python3Parser.g4 | 25.389 | 16.178 | 0.323 |
| Sum of per-file medians | 108.809 | 68.556 | 1.515 |

Against the earlier list-key runs above, flat keys improved locked FSET's sum
by about 8%; the locked hash-table sum was essentially unchanged. Java's sum
was also close to its previous result. The new locked FSET and locked hash
table sums are about 72× and 45× Java's sum, respectively.

For `JavaParser.g4`, separate 100-iteration phase timings with locked FSET
measured 26.6 ms for lexing and 7.1 ms for parsing pretokenized input. With
locked hash tables, lexing took 17.7 ms. The SBCL CPU profile for the latter
showed lexer epsilon closure and its newly allocated hash table among the
largest self-time groups; array allocation and structural hashing also
appeared. With FSET, key comparison remained a prominent cost. This suggests
that repeated lexer state-set work and cache lookup are the main opportunities
for narrowing the gap. The phase timings and sampled profiles do not by
themselves assign the entire Lisp/Java difference to any one operation.

## Cached lexer DFA start states

The lexer now caches an initial DFA state for each mode in its pluggable
cache. Each DFA state stores its epsilon-closed active states and best
accepting rule. A transition-cache miss creates the next DFA state; a hit
reuses it. Clearing or cloning the lexer gives it an empty cache, including
the mode start states.

With the same benchmark settings and corpus, the new results were:

| Input | Locked FSET | Locked hash table | ANTLR4/Java |
| --- | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 7.206 | 2.925 | 0.146 |
| ANTLRv4Parser.g4 | 7.759 | 3.167 | 0.151 |
| JavaLexer.g4 | 6.601 | 2.778 | 0.169 |
| JavaParser.g4 | 22.458 | 9.193 | 0.499 |
| JSON.g4 | 1.331 | 0.556 | 0.030 |
| Python3Lexer.g4 | 8.973 | 3.547 | 0.188 |
| Python3Parser.g4 | 16.605 | 6.796 | 0.325 |
| Sum of per-file medians | 70.933 | 28.962 | 1.508 |

Relative to the flat-key run, this cut the locked FSET sum by 35% and the
locked hash-table sum by 58%. The remaining gaps are about 47× and 19× Java,
respectively. In a separate warmed 100-iteration lexer-only timing on
`JavaParser.g4`, locked hash-table lexing fell from 17.7 ms to 5.6 ms per
iteration. Its new CPU profile no longer showed epsilon closure among the
sampled hot spots; flat-key construction and structural hashing were prominent.

Both harnesses load file contents before timing. Each timed iteration includes
lexing and parsing. CNVRS reuses its compiled objects and selected cache
backend, warmed across iterations; Java creates fresh
lexer/parser objects per iteration and the JVM is warmed before timing. CNVRS
uses `:tree-builder :none` for recognition mode and `:node` for tree mode;
Java uses `setBuildParseTree(false/true)`. These APIs do not guarantee identical
allocation or tree shapes. This is a single-threaded runtime comparison on a
small set of valid grammar files, not an isolated algorithm benchmark or a
measurement of memory use, concurrency, or grammar compilation.

## Reproduce

From the repository root, set `ANTLR_JAR` to an ANTLR 4.13.2 complete JAR and
`SBCL_BIN` to a native ARM64 SBCL binary.
The commands below require `curl`, Java, `javac`, SBCL, and CNVRS dependencies
available through Quicklisp or ASDF.

```sh
export ANTLR_JAR=/path/to/antlr4-4.13.2-complete.jar
export SBCL_BIN=/path/to/arm64/sbcl
export BENCH_DIR=/tmp/cnvrs-antlr4-grammar-bench
export GRAMMARS_REV=b96e04db9d54bb313e542cc3e6ee913900a21520
mkdir -p "$BENCH_DIR/corpus" "$BENCH_DIR/java"
for path in \
  antlr/antlr4/ANTLRv4Lexer.g4 \
  antlr/antlr4/ANTLRv4Parser.g4 \
  java/java/JavaLexer.g4 \
  java/java/JavaParser.g4 \
  json/JSON.g4 \
  python/python3/Python3Lexer.g4 \
  python/python3/Python3Parser.g4; do
  name=$(printf '%s' "$path" | tr / _)
  curl -fLsS "https://raw.githubusercontent.com/antlr/grammars-v4/$GRAMMARS_REV/$path" \
    -o "$BENCH_DIR/corpus/$name"
done
for name in ANTLRv4Lexer.g4 ANTLRv4Parser.g4 LexerAdaptor.java; do
  curl -fLsS "https://raw.githubusercontent.com/antlr/grammars-v4/$GRAMMARS_REV/antlr/antlr4/$name" \
    -o "$BENCH_DIR/java/$name"
done
cp bench/antlr4-grammar/Bench.java "$BENCH_DIR/java/"
(cd "$BENCH_DIR/java" && \
  java -jar "$ANTLR_JAR" -Dlanguage=Java -no-listener -no-visitor \
    ANTLRv4Lexer.g4 ANTLRv4Parser.g4 && \
  javac -cp "$ANTLR_JAR" *.java)
"$SBCL_BIN" --script bench/antlr4-grammar/bench.lisp 10 7 20 "$BENCH_DIR"/corpus/*.g4
java -cp "$ANTLR_JAR:$BENCH_DIR/java" Bench 200 7 200 "$BENCH_DIR"/corpus/*.g4
BENCH_TREE=1 "$SBCL_BIN" --script bench/antlr4-grammar/bench.lisp 10 7 20 "$BENCH_DIR"/corpus/*.g4
BENCH_TREE=1 java -cp "$ANTLR_JAR:$BENCH_DIR/java" Bench 200 7 200 "$BENCH_DIR"/corpus/*.g4
```

The harnesses print tab-separated rows of `OK`, file name, source character
count, and median nanoseconds per parse; failures print `FAIL`. Warmup and
batch sizes are command-line arguments. Run the two programs separately and
avoid other heavy work during measurement.

To reproduce the profile and phase timings with ARM64 SBCL, run:

```sh
"$SBCL_BIN" --script bench/antlr4-grammar/profile.lisp "$BENCH_DIR/corpus/java_java_JavaParser.g4" 200
PROFILE_PHASE=lexer "$SBCL_BIN" --script bench/antlr4-grammar/profile.lisp "$BENCH_DIR/corpus/java_java_JavaParser.g4" 100
PROFILE_PHASE=parser "$SBCL_BIN" --script bench/antlr4-grammar/profile.lisp "$BENCH_DIR/corpus/java_java_JavaParser.g4" 100
PROFILE_CACHE_BACKEND=locked-hash-table "$SBCL_BIN" --script bench/antlr4-grammar/profile.lisp "$BENCH_DIR/corpus/java_java_JavaParser.g4" 100
```

`PROFILE_CACHE_BACKEND` also accepts `hash-table`, `fset`, and `locked-fset`.
On macOS, `sb-sprof`'s CPU mode can under-sample some threads; these runs
profile the main parsing thread, and the sample counts should be read as
directional evidence.

To repeat a current-code cache comparison, run the Lisp benchmark command above four
times with `BENCH_CACHE_BACKEND` set to `locked-fset`, `locked-hash-table`,
`fset`, and `hash-table`. Each process clones both CNVRS's ANTLR4 lexer and
parser so the selected backend applies to both. The old FSET column above
requires the version before `cache-key-compare` was added.
