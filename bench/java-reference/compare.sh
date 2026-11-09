#!/usr/bin/env bash
set -euo pipefail
: "${REFERENCE_JAR:?Set REFERENCE_JAR to the ANTLR 4.13.2 complete jar}"
: "${SBCL_BIN:=sbcl}"
root=$(cd "$(dirname "$0")/../.." && pwd)
REFERENCE_JAR=$(cd "$(dirname "$REFERENCE_JAR")" && pwd)/$(basename "$REFERENCE_JAR")
results=${1:-"$root/bench/java-reference/results"}
mkdir -p "$results"
results=$(cd "$results" && pwd)
scratch=$(mktemp -d /tmp/cnvrs-reference-benchmark.XXXXXX)
trap 'rm -rf "$scratch"' EXIT
cp "$root/test/fixtures/IRI.g4" "$root/test/fixtures/runtime/Java8Lexer.g4" "$root/test/fixtures/runtime/Java8Parser.g4" "$root/bench/java-reference/Benchmark.java" "$scratch/"
cd "$scratch"
java -jar "$REFERENCE_JAR" -no-listener IRI.g4 Java8Lexer.g4 Java8Parser.g4
javac -cp ".:$REFERENCE_JAR" IRILexer.java IRIParser.java Java8Lexer.java Java8Parser.java Benchmark.java
cd "$root"
{
  date -u '+UTC %Y-%m-%dT%H:%M:%SZ'
  git rev-parse HEAD
  uname -m
  sysctl -n machdep.cpu.brand_string 2>/dev/null || printf 'CPU model unavailable\n'
  java -version 2>&1
  "$SBCL_BIN" --version
  shasum -a 256 "$REFERENCE_JAR" test/fixtures/IRI.g4 test/fixtures/runtime/Java8Lexer.g4 test/fixtures/runtime/Java8Parser.g4 bench/java-reference/iri.txt bench/antlr4-grammar/Bench.java
} > "$results/environment.txt"
run_java() {
  java -Xms256m -Xmx2g -cp "$scratch:$REFERENCE_JAR" Benchmark "$grammar" "$input" > "$results/$grammar-java-$trial.txt" 2>&1
}
run_lisp() {
  "$SBCL_BIN" --dynamic-space-size 2048 --script bench/java-reference/benchmark.lisp "$grammar" "$input" > "$results/$grammar-cnvrs-$trial.txt" 2>&1
}
for trial in 1 2 3; do
  for grammar in iri java8; do
    if [[ "$grammar" == iri ]]; then input=bench/java-reference/iri.txt; else input=bench/antlr4-grammar/Bench.java; fi
    if [[ "$trial" == 2 ]]; then run_lisp; run_java; else run_java; run_lisp; fi
    printf 'Completed %s pair %s\n' "$grammar" "$trial"
  done
done
printf 'Results: %s\n' "$results"
