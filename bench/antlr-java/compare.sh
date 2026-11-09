#!/usr/bin/env bash
set -euo pipefail
: "${ANTLR_JAR:?Set ANTLR_JAR to the ANTLR 4.13.2 complete jar}"
: "${SBCL_BIN:=sbcl}"
root=$(cd "$(dirname "$0")/../.." && pwd)
ANTLR_JAR=$(cd "$(dirname "$ANTLR_JAR")" && pwd)/$(basename "$ANTLR_JAR")
results=${1:-"$root/bench/antlr-java/results"}
mkdir -p "$results"
results=$(cd "$results" && pwd)
scratch=$(mktemp -d /tmp/cnvrs-antlr-benchmark.XXXXXX)
trap 'rm -rf "$scratch"' EXIT
cp "$root/test/fixtures/IRI.g4" "$root/test/fixtures/antlr-runtime/Java8Lexer.g4" "$root/test/fixtures/antlr-runtime/Java8Parser.g4" "$root/bench/antlr-java/Benchmark.java" "$scratch/"
cd "$scratch"
java -jar "$ANTLR_JAR" -no-listener IRI.g4 Java8Lexer.g4 Java8Parser.g4
javac -cp ".:$ANTLR_JAR" IRILexer.java IRIParser.java Java8Lexer.java Java8Parser.java Benchmark.java
cd "$root"
{
  date -u '+UTC %Y-%m-%dT%H:%M:%SZ'
  git rev-parse HEAD
  uname -m
  sysctl -n machdep.cpu.brand_string
  java -version 2>&1
  "$SBCL_BIN" --version
  shasum -a 256 "$ANTLR_JAR" test/fixtures/IRI.g4 test/fixtures/antlr-runtime/Java8Lexer.g4 test/fixtures/antlr-runtime/Java8Parser.g4 bench/antlr-java/iri.txt bench/antlr4-grammar/Bench.java
} > "$results/environment.txt"
run_java() {
  java -Xms256m -Xmx2g -cp "$scratch:$ANTLR_JAR" Benchmark "$grammar" "$input" > "$results/$grammar-java-$trial.txt" 2>&1
}
run_lisp() {
  "$SBCL_BIN" --dynamic-space-size 2048 --script bench/antlr-java/benchmark.lisp "$grammar" "$input" > "$results/$grammar-cnvrs-$trial.txt" 2>&1
}
for trial in 1 2 3; do
  for grammar in iri java8; do
    if [[ "$grammar" == iri ]]; then input=bench/antlr-java/iri.txt; else input=bench/antlr4-grammar/Bench.java; fi
    if [[ "$trial" == 2 ]]; then run_lisp; run_java; else run_java; run_lisp; fi
    printf 'Completed %s pair %s\n' "$grammar" "$trial"
  done
done
printf 'Results: %s\n' "$results"
