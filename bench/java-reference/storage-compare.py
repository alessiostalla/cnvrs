"""Run sequential, alternating fresh-process storage A/B benchmarks."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("before", type=Path, help="isolated baseline source snapshot")
parser.add_argument("--sbcl", default="sbcl")
parser.add_argument("--results", type=Path)
parser.add_argument("--cache-root", type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
output = (args.results or root / "bench/java-reference/storage-results").resolve()
output.mkdir(parents=True, exist_ok=True)
baseline = args.before.resolve()
harness = root / "bench/java-reference/types.lisp"
sources = ("src/runtime/prediction-context.lisp", "src/runtime/atn-config.lisp",
           "src/runtime/parser-atn-simulator.lisp", "src/runtime/lexer-atn-simulator.lisp")
metadata = {"baseline": str(baseline), "candidate_revision": subprocess.check_output(
    ["git", "rev-parse", "HEAD"], cwd=root, text=True).strip(),
    "machine": platform.machine(), "runtime": subprocess.check_output(
        [args.sbcl, "--version"], text=True).strip(), "heap_mib": 2048,
    "harness_sha256": hashlib.sha256(harness.read_bytes()).hexdigest(),
    "source_sha256": {label: {name: hashlib.sha256((source / name).read_bytes()).hexdigest()
                             for name in sources}
                      for label, source in (("before", baseline), ("after", root))}}
(output / "environment.json").write_text(json.dumps(metadata, indent=2) + "\n")
for trial in (1, 2, 3):
    for label in (("after", "before") if trial == 2 else ("before", "after")):
        env = os.environ.copy()
        env["XDG_CACHE_HOME"] = str(args.cache_root.resolve() / label)
        with (output / f"{label}-{trial}.txt").open("w") as log:
            subprocess.run([args.sbcl, "--dynamic-space-size", "2048", "--script",
                            str(harness), label], cwd=baseline if label == "before" else root,
                           env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
        print(f"Completed {label} {trial}", flush=True)
subprocess.run(["python3", str(root / "bench/java-reference/types-summary.py"),
                str(output)], check=True)
summary = json.loads((output / "summary.json").read_text())
for grammar, phases in summary.items():
    for phase, row in phases.items():
        assert row["before"]["cache"] == row["after"]["cache"], (grammar, phase)
print("Token signatures and before/after cache counts agree.")
