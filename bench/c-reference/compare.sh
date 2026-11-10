#!/usr/bin/env bash
set -euo pipefail
: "${REFERENCE_JAR:?Set REFERENCE_JAR to the ANTLR 4.13.2 complete jar}"
: "${SBCL_BIN:=sbcl}"
root=$(cd "$(dirname "$0")/../.." && pwd)
REFERENCE_JAR=$(cd "$(dirname "$REFERENCE_JAR")" && pwd)/$(basename "$REFERENCE_JAR")
results=${1:-"$root/bench/c-reference/results"}
mkdir -p "$results"
results=$(cd "$results" && pwd)
scratch=$(mktemp -d /tmp/cnvrs-c-reference-benchmark.XXXXXX)
trap 'rm -rf "$scratch"' EXIT
cp "$root"/bench/c-reference/{C.g4,Benchmark.java} "$scratch/"
cd "$scratch"
java -jar "$REFERENCE_JAR" -no-listener C.g4
javac -cp ".:$REFERENCE_JAR" CLexer.java CParser.java Benchmark.java
cd "$root"
{
  date -u '+UTC %Y-%m-%dT%H:%M:%SZ'
  git rev-parse HEAD
  uname -m
  java -version 2>&1
  "$SBCL_BIN" --version
  shasum -a 256 "$REFERENCE_JAR" bench/c-reference/*.g4 bench/c-reference/examples/*.c bench/c-reference/pointers.c bench/c-reference/*.lisp bench/c-reference/*.java src/runtime/*.lisp src/cnvrs.lisp src/parser-runtime.lisp
} > "$results/environment.txt"
run_java() {
  java -Xms256m -Xmx2g -cp "$scratch:$REFERENCE_JAR" Benchmark "$grammar" "$input" > "$results/$grammar-java-$trial.txt" 2>&1
}
run_lisp() {
  "$SBCL_BIN" --dynamic-space-size 2048 --script bench/c-reference/benchmark.lisp "$grammar" "$input" > "$results/$grammar-cnvrs-$trial.txt" 2>&1
}
for trial in 1 2 3; do
  for grammar in preprocessed pointers; do
    if [[ "$grammar" == preprocessed ]]; then input=bench/c-reference/examples/Wmisleading-indentation.pp.c; else input=bench/c-reference/pointers.c; fi
    if [[ "$trial" == 2 ]]; then run_lisp; run_java; else run_java; run_lisp; fi
    printf 'Completed %s pair %s\n' "$grammar" "$trial"
  done
done
python3 bench/c-reference/summarize.py "$results"
