"""Sequential native-SBCL before/after and ANTLR Java benchmark rerun."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import statistics
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "bench/checkpoint-recheck-results"
SBCL = Path(os.environ.get("SBCL_BIN", "/Users/alessio/.local/opt/sbcl-2.4.0/bin/sbcl"))
JAR = Path(os.environ.get("REFERENCE_JAR", "/private/tmp/cnvrs-antlr-reference/antlr-4.13.2-complete.jar"))
BASE = "c7c100caa5f5a32ffba886e6661db4438ed1752b"
PHASES = ("lexer", "parse-none", "parse-tree", "pipeline-tree")
WORK = (
    ("java8", "bench/antlr4-grammar/Bench.java", "java"),
    ("preprocessed", "bench/c-reference/examples/Wmisleading-indentation.pp.c", "c"),
    ("pointers", "bench/c-reference/pointers.c", "c"),
)


def command(args, **kwargs):
    return subprocess.run([str(x) for x in args], check=True, **kwargs)


def summarize():
    summary = {}
    lines = ["# Native Java 8 and C11 checkpoint regression recheck", "",
             "Warm milliseconds per call; medians of three process medians of seven batch means.", "",
             "| Workload | Phase | Before CNVRS | Current CNVRS | Change | ANTLR Java | Current / Java |",
             "| --- | --- | ---: | ---: | ---: | ---: | ---: |"]
    for name, _, _ in WORK:
        signatures, kinds, caches = set(), set(), {}
        summary[name] = {}
        for runtime in ("before", "after", "java"):
            for trial in range(1, 4):
                text = (OUT / f"{name}-{runtime}-{trial}.txt").read_text()
                signatures.add(re.search(r"SIGNATURE ([0-9A-F]{16})", text)[1])
                kind = re.search(r"^KIND-SIGNATURE (.+)$", text, re.M)
                if kind:
                    kinds.add(kind[1])
                for phase in PHASES:
                    rows = re.findall(rf"^WARM {phase} BATCH \d+ MS ([\d.]+) BYTES ([\d.]+)$", text, re.M | re.I)
                    cold = re.findall(rf"^COLD {phase} TRIAL \d+ MS ([\d.]+) BYTES ([\d.]+)$", text, re.M | re.I)
                    assert len(rows) == 7 and len(cold) == 3, (name, runtime, trial, phase)
                    record = summary[name].setdefault(phase, {}).setdefault(runtime, {"runs_ms": [], "runs_bytes": [], "cold_ms": []})
                    record["runs_ms"].append(statistics.median(float(ms) for ms, _ in rows))
                    record["runs_bytes"].append(statistics.median(float(b) for _, b in rows))
                    record["cold_ms"].extend(float(ms) for ms, _ in cold)
                    cache = re.search(rf"^CACHE {phase} LEXER-STATES (\d+) LEXER-EDGES (\d+) PARSER-STATES (\d+) CONTEXTS (\d+)$", text, re.M | re.I)
                    assert cache, (name, runtime, trial, phase)
                    caches.setdefault(phase, set()).add(tuple(map(int, cache.groups())))
        assert len(signatures) == 1 and len(kinds) <= 1, (name, signatures, kinds)
        assert all(len(values) == 1 for values in caches.values()), (name, caches)
        for phase, runtimes in summary[name].items():
            for runtime, row in runtimes.items():
                row["warm_ms"] = statistics.median(row["runs_ms"])
                row["warm_bytes"] = statistics.median(row["runs_bytes"])
                row["median_cold_ms"] = statistics.median(row["cold_ms"])
            before, after, java = (runtimes[r]["warm_ms"] for r in ("before", "after", "java"))
            lines.append(f"| {name} | {phase} | {before:.6f} | {after:.6f} | {100*(after/before-1):+.1f}% | {java:.6f} | {after/java:.2f}× |")
        lines += ["", f"{name}: token signatures, normalized kinds (C11), and all trained cache counts agree across all nine processes.", ""]
    (OUT / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    (OUT / "summary.md").write_text("\n".join(lines) + "\n")
    print("\n".join(lines), flush=True)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, LANG="en_US.UTF-8", LC_ALL="en_US.UTF-8", CNVRS_BENCH_ITERATIONS="5")
    files = sorted(set([p for p in ROOT.glob("src/**/*.lisp")] +
                       [ROOT / "cnvrs.asd", ROOT / "bench/java-reference/benchmark.lisp",
                        ROOT / "bench/c-reference/benchmark.lisp", ROOT / "bench/java-reference/Benchmark.java",
                        ROOT / "bench/c-reference/Benchmark.java", ROOT / "bench/c-reference/C.g4",
                        ROOT / "test/fixtures/IRI.g4", ROOT / "test/fixtures/runtime/Java8Lexer.g4",
                        ROOT / "test/fixtures/runtime/Java8Parser.g4", Path(__file__).resolve(), JAR] +
                       [ROOT / filename for _, filename, _ in WORK]))
    metadata = {
        "date": "2026-11-12", "baseline": BASE,
        "candidate": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
        "sbcl": str(SBCL), "runtime": subprocess.check_output([str(SBCL), "--version"], text=True).strip(),
        "architecture": subprocess.check_output(["file", str(SBCL)], text=True).strip(),
        "java": subprocess.check_output(["java", "-version"], stderr=subprocess.STDOUT, text=True).strip(),
        "method": ("Three sequential fresh-process trials; CNVRS before/after order reversed in trial two; Java references repeated separately to preserve standalone token-signature records"
                   if "--references-only" in sys.argv else
                   "Three sequential fresh-process trials; reverse runtime order in trial two") + "; 7 warm batches, 3 cold calls per phase",
        "iterations": {"java8_cnvrs": 5, "c11_cnvrs_lexer": 200, "c11_cnvrs_parser": 20, "antlr_java": "unchanged repository harness"},
        "heap_mib": 2048, "control_stack_mib": 256,
        "sha256": {str(p.relative_to(ROOT) if p.is_relative_to(ROOT) else p): hashlib.sha256(p.read_bytes()).hexdigest() for p in files},
    }
    (OUT / "environment.json").write_text(json.dumps(metadata, indent=2) + "\n")
    with tempfile.TemporaryDirectory(prefix="cnvrs-checkpoint-recheck-", dir="/private/tmp") as temp:
        scratch = Path(temp)
        baseline = scratch / "before"
        baseline.mkdir()
        archive = subprocess.check_output(["git", "archive", BASE], cwd=ROOT)
        subprocess.run(["tar", "-x", "-C", str(baseline)], input=archive, check=True, env=env)
        builds = {}
        for kind, directory, grammars in (
            ("java", "bench/java-reference", ["test/fixtures/IRI.g4", "test/fixtures/runtime/Java8Lexer.g4", "test/fixtures/runtime/Java8Parser.g4"]),
            ("c", "bench/c-reference", ["bench/c-reference/C.g4"]),
        ):
            build = scratch / kind
            build.mkdir()
            for filename in grammars + [directory + "/Benchmark.java"]:
                shutil.copyfile(ROOT / filename, build / Path(filename).name)
            with (OUT / f"build-{kind}.txt").open("w") as log:
                command(["java", "-jar", JAR, "-no-listener"] + [Path(g).name for g in grammars], cwd=build, env=env, stdout=log, stderr=subprocess.STDOUT)
                command(["javac", "-cp", f".:{JAR}"] + sorted(p.name for p in build.glob("*.java")), cwd=build, env=env, stdout=log, stderr=subprocess.STDOUT)
            harness = build / "benchmark.lisp"
            text = (ROOT / directory / "benchmark.lisp").read_text()
            if kind == "c":
                text = text.replace('(iterations (if (eq phase :lexer) 100 2))', '(iterations (if (eq phase :lexer) 200 20))')
            harness.write_text(text)
            metadata[f"{kind}_effective_lisp_harness_sha256"] = hashlib.sha256(harness.read_bytes()).hexdigest()
            builds[kind] = build
        (OUT / "environment.json").write_text(json.dumps(metadata, indent=2) + "\n")
        for trial in range(1, 4):
            for name, filename, kind in WORK:
                order = ("java", "before", "after") if trial != 2 else ("after", "before", "java")
                for runtime in order:
                    local_env = dict(env)
                    raw = scratch / "run.log"
                    if runtime == "java":
                        args = ["java", "-Xms256m", "-Xmx2g", "-cp", f"{builds[kind]}:{JAR}", "Benchmark", name, str(ROOT / filename)]
                        cwd = ROOT
                    else:
                        if "--references-only" in sys.argv:
                            continue
                        cwd = baseline if runtime == "before" else ROOT
                        local_env["ASDF_OUTPUT_TRANSLATIONS"] = f'(:output-translations (t "/private/tmp/cnvrs-checkpoint-native-cache/{runtime}/") :ignore-inherited-configuration)'
                        args = [SBCL, "--dynamic-space-size", "2048", "--control-stack-size", "256", "--script", builds[kind] / "benchmark.lisp", name, filename]
                    try:
                        with raw.open("w") as log:
                            command(args, cwd=cwd, env=local_env, stdout=log, stderr=subprocess.STDOUT)
                    except subprocess.CalledProcessError:
                        shutil.copyfile(raw, OUT / f"{name}-{runtime}-{trial}-failed.txt")
                        raise
                    records = [line for line in raw.read_text().splitlines() if re.match(r"^(RUNTIME|SIGNATURE|TOPOLOGY|DEFAULT-TOKENS|KIND-SIGNATURE|FIRST|COLD|WARM|CACHE) ", line)]
                    (OUT / f"{name}-{runtime}-{trial}.txt").write_text("\n".join(records) + "\n")
                    print(f"Completed {name} {runtime} trial {trial}", flush=True)
        summarize()


if __name__ == "__main__":
    main()
