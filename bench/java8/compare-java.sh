#!/usr/bin/env bash
# Run from anywhere. ANTLR_JAR must point to antlr-4.13.2-complete.jar.
set -euo pipefail
: "${ANTLR_JAR:?Set ANTLR_JAR to the ANTLR 4.13.2 complete jar}"
: "${SBCL_BIN:=sbcl}"
root=$(cd "$(dirname "$0")/../.." && pwd)
ANTLR_JAR=$(cd "$(dirname "$ANTLR_JAR")" && pwd)/$(basename "$ANTLR_JAR")
results=${1:-$(mktemp -d /tmp/cnvrs-java8-comparison.XXXXXX)}
mkdir -p "$results"
results=$(cd "$results" && pwd)
scratch=$(mktemp -d /tmp/cnvrs-java8-generated.XXXXXX)
trap 'rm -rf "$scratch"' EXIT
cp "$root"/test/fixtures/antlr-runtime/Java8{Lexer,Parser}.g4 "$scratch/"
cp "$root/bench/java8/Java8Benchmark.java" "$scratch/"
cd "$scratch"
java -jar "$ANTLR_JAR" -no-listener Java8Lexer.g4 Java8Parser.g4
javac -cp ".:$ANTLR_JAR" Java8Lexer.java Java8Parser.java Java8Benchmark.java
for trial in 1 2 3; do
  java -Xms256m -Xmx2g -cp ".:$ANTLR_JAR" Java8Benchmark \
    "$root/bench/antlr4-grammar/Bench.java" > "$results/java-$trial.txt"
done
cd "$root"
PROFILE_MODE=timing PROFILE_TRIALS=3 PROFILE_WARM_ITERATIONS=10 \
  "$SBCL_BIN" --dynamic-space-size 2048 --script bench/java8/profile.lisp \
  test/fixtures/antlr-runtime/Java8Lexer.g4 \
  test/fixtures/antlr-runtime/Java8Parser.g4 > "$results/cnvrs.txt"
printf 'Results: %s\n' "$results"
