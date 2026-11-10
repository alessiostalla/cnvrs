#!/usr/bin/env bash
set -euo pipefail
: "${SBCL_BIN:=sbcl}"
root=$(cd "$(dirname "$0")/../.." && pwd)
cd "$root"
results=${1:-bench/tsql/profile-results}
mkdir -p "$results"
scratch=$(mktemp -d /tmp/cnvrs-tsql-profile.XXXXXX)
trap 'rm -rf "$scratch"' EXIT
{
  date -u '+UTC %Y-%m-%dT%H:%M:%SZ'
  git rev-parse HEAD
  uname -m
  "$SBCL_BIN" --version
  shasum -a 256 bench/tsql/*.g4 bench/tsql/examples/dml_select.sql bench/tsql/{prepare,prepare-core,warm-profile}.lisp bench/tsql/profile.sh bench/tsql/profile-summary.py src/*.lisp src/runtime/*.lisp
} > "$results/environment.txt"
"$SBCL_BIN" --dynamic-space-size 2048 --script bench/tsql/prepare-core.lisp "$scratch/parser.core" > "$results/preparation.txt" 2>&1
for mode in cpu alloc operations chunks; do
  "$SBCL_BIN" --core "$scratch/parser.core" --dynamic-space-size 2048 --script bench/tsql/warm-profile.lisp "$mode" > "$results/$mode.txt" 2>&1
  printf 'Completed %s profile\n' "$mode"
done
python3 bench/tsql/profile-summary.py
