#!/usr/bin/env bash
set -euo pipefail
: "${REFERENCE_JAR:?Set REFERENCE_JAR to the ANTLR 4.13.2 complete jar}"
: "${SBCL_BIN:=sbcl}"
root=$(cd "$(dirname "$0")/../.." && pwd)
REFERENCE_JAR=$(cd "$(dirname "$REFERENCE_JAR")" && pwd)/$(basename "$REFERENCE_JAR")
results=${1:-"$root/bench/tsql/benchmark-results"}
mkdir -p "$results"
results=$(cd "$results" && pwd)
scratch=$(mktemp -d /tmp/cnvrs-tsql-benchmark.XXXXXX)
trap 'rm -rf "$scratch"' EXIT
cp "$root"/bench/tsql/{TSqlLexer.g4,TSqlParser.g4,Benchmark.java} "$scratch/"
cd "$scratch"
java -jar "$REFERENCE_JAR" -no-listener TSqlLexer.g4 TSqlParser.g4
javac -cp ".:$REFERENCE_JAR" TSqlLexer.java TSqlParser.java Benchmark.java
cd "$root"
{
  date -u '+UTC %Y-%m-%dT%H:%M:%SZ'
  git rev-parse HEAD
  uname -m
  java -version 2>&1
  "$SBCL_BIN" --version
  shasum -a 256 "$REFERENCE_JAR" bench/tsql/*.g4 bench/tsql/examples/*.sql bench/tsql/*.lisp bench/tsql/*.java src/runtime/*.lisp src/cnvrs.lisp src/macros.lisp src/parser-runtime.lisp
} > "$results/environment.txt"
# Save only compiled code and empty caches; each measurement gets a fresh process.
"$SBCL_BIN" --dynamic-space-size 2048 --script bench/tsql/prepare-core.lisp "$scratch/parser.core" > "$results/core-preparation.txt" 2>&1
run_java() {
  java -Xms256m -Xmx2g -cp "$scratch:$REFERENCE_JAR" Benchmark "$grammar" "$input" > "$results/$grammar-java-$trial.txt" 2>&1
}
run_lisp() {
  "$SBCL_BIN" --core "$scratch/parser.core" --dynamic-space-size 2048 --script bench/tsql/benchmark.lisp "$grammar" "$input" > "$results/$grammar-cnvrs-$trial.txt" 2>&1
}
for trial in 1 2 3; do
  for grammar in select schema json backup; do
    case "$grammar" in
      select) input=bench/tsql/examples/dml_select.sql ;;
      schema) input=bench/tsql/examples/ddl_create_table.sql ;;
      json) input=bench/tsql/examples/built_in_functions_json.sql ;;
      backup) input=bench/tsql/examples/backup.sql ;;
    esac
    if [[ "$trial" == 2 ]]; then run_lisp; run_java; else run_java; run_lisp; fi
    printf 'Completed %s pair %s\n' "$grammar" "$trial"
  done
done
python3 bench/tsql/summarize.py "$results"
