#!/usr/bin/env bash
set -euo pipefail
: "${REFERENCE_JAR:?Set REFERENCE_JAR to the ANTLR 4.13.2 complete jar}"
: "${SBCL_BIN:=sbcl}"
root=$(cd "$(dirname "$0")/../.." && pwd)
REFERENCE_JAR=$(cd "$(dirname "$REFERENCE_JAR")" && pwd)/$(basename "$REFERENCE_JAR")
results=${1:-"$root/bench/tsql/results"}
mkdir -p "$results"
results=$(cd "$results" && pwd)
scratch=$(mktemp -d /tmp/cnvrs-tsql-validation.XXXXXX)
trap 'rm -rf "$scratch"' EXIT
cp "$root"/bench/tsql/{TSqlLexer.g4,TSqlParser.g4,Validation.java} "$scratch/"
cd "$scratch"
java -jar "$REFERENCE_JAR" -no-listener TSqlLexer.g4 TSqlParser.g4
javac -cp ".:$REFERENCE_JAR" TSqlLexer.java TSqlParser.java Validation.java
cd "$root"
java -Xmx2g -cp "$scratch:$REFERENCE_JAR" Validation bench/tsql/examples/*.sql > "$results/validation-java.txt" 2>&1
"$SBCL_BIN" --dynamic-space-size 2048 --script bench/tsql/validate.lisp > "$results/validation-cnvrs.txt" 2>&1
python3 - "$results" <<'PY'
from pathlib import Path
import re,sys
root=Path(sys.argv[1])
c=(root/'validation-cnvrs.txt').read_text();j=(root/'validation-java.txt').read_text()
a=re.findall(r'^INPUT .+$',c,re.M);b=re.findall(r'^INPUT .+$',j,re.M)
assert len(a)==len(b)==4 and a==b, (a,b)
assert 'FASL full T-SQL runners compiled and loaded.' in c
assert 'VALIDATED runtime and FASL' in c
print('All four token streams/kinds match Java; runtime and FASL trees match the interpreter.')
PY
{
  date -u '+UTC %Y-%m-%dT%H:%M:%SZ'
  git rev-parse HEAD
  uname -m
  "$SBCL_BIN" --version
  java -version 2>&1
  shasum -a 256 "$REFERENCE_JAR" src/*.lisp src/runtime/*.lisp cnvrs.asd bench/tsql/*.lisp bench/tsql/*.java bench/tsql/*.sh bench/tsql/*.g4 bench/tsql/examples/*.sql
} > "$results/environment.txt"
