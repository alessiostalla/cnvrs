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
| ANTLRv4Lexer.g4 | 18.21 | 0.154 | 119× |
| ANTLRv4Parser.g4 | 18.67 | 0.147 | 127× |
| JavaLexer.g4 | 16.27 | 0.173 | 94× |
| JavaParser.g4 | 53.14 | 0.492 | 108× |
| JSON.g4 | 3.33 | 0.028 | 118× |
| Python3Lexer.g4 | 21.71 | 0.184 | 118× |
| Python3Parser.g4 | 38.91 | 0.320 | 122× |

The sum of these per-file medians is 170.24 ms for CNVRS and 1.498 ms for
Java, a 114× ratio. With tree construction enabled, the corresponding sums
were 170.84 ms and 1.568 ms, a 109× ratio. The earlier x86-64 SBCL 2.0.2
run under Rosetta took 224.65 ms summed over the same files, giving a 150×
ratio. Use the native ARM64 result for the comparison; the two SBCL versions
also differ, so the change cannot be attributed to architecture alone.

## SBCL profile

On `JavaParser.g4`, a warm single-threaded run using the default
`(:locked :fset)` caches took about 53 ms per full parse. Profiling 200 full
parses with SBCL's `sb-sprof` in CPU mode collected 4,680 samples. Its largest
self-sample groups were generic method dispatch (26.6%), FSET list and number
comparisons (14.4% combined), and lexer NFA closure (4.6%). Samples are an
approximation; generic dispatch includes calls from more than one subsystem.

Separately timing phases on the same file gave 46.5 ms for lexing and 9.1 ms
for parsing an already tokenized vector. Lexing therefore accounts for about
84% of the sum of those phase timings. The profiler points first to lexer
transition-cache key comparisons and repeated closure work, then to parser
prediction-cache lookups.

As a diagnostic check, cloning both the ANTLR4 lexer and parser with
`(:locked :hash-table)` caches reduced the full-file timing to 20.8 ms; bare
`:hash-table` caches gave 18.3 ms. Bare `:fset` gave 52.6 ms. This supports
cache lookup and comparison cost as a major hot spot; it does not make the
hash-table backend thread-safe without the lock wrapper. These timings came
from one 100-iteration run per backend and are not a full statistical
comparison.

Both harnesses load file contents before timing. Each timed iteration includes
lexing and parsing. CNVRS reuses its compiled objects and default cache
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
