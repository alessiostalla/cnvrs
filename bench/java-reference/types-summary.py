"""Validate and summarize the six fresh-process declaration benchmarks."""
from pathlib import Path
import json
import re
import sys
from statistics import median
root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent / "types-results"
data = {}
for label in ("before", "after"):
    for trial in (1, 2, 3):
        text = (root / f"{label}-{trial}.txt").read_text()
        for grammar, signature in (("iri", "B15EEB5EE1A6F8C9"), ("java8", "F820B4EE83D8A397")):
            assert re.search(rf"^GRAMMAR {grammar} .*SIGNATURE {signature}$", text, re.M)
            for phase in ("LEXER", "PARSE-TREE"):
                row = {}
                for state, number in (("COLD", 3), ("WARM", 7)):
                    values = re.findall(rf"^{state} {grammar} {phase} (?:TRIAL|BATCH) \d+ MS ([\d.]+) BYTES ([\d.]+)$", text, re.M)
                    assert len(values) == number, (label, trial, grammar, phase, state)
                    row[state.lower()] = [[float(t), float(b)] for t, b in values]
                cache = re.search(rf"^CACHE {grammar} {phase} PARSER-STATES (\d+) LEXER-STATES (\d+)$", text, re.M)
                assert cache
                row["cache"] = tuple(map(int, cache.groups()))
                cpu = re.findall(rf"^WARM-CPU {grammar} {phase} BATCH \d+ MS ([\d.]+)$", text, re.M)
                if cpu:
                    assert len(cpu) == 7
                    row["warm_cpu"] = [float(x) for x in cpu]
                data[label, trial, grammar, phase] = row
summary = {}
for grammar in ("iri", "java8"):
    summary[grammar] = {}
    for phase in ("LEXER", "PARSE-TREE"):
        rows = {}
        for label in ("before", "after"):
            records = [data[label, trial, grammar, phase] for trial in (1, 2, 3)]
            runs = [median(t for t, b in r["warm"]) for r in records]
            caches = {r["cache"] for r in records}
            assert len(caches) == 1
            rows[label] = dict(warm_ms=median(runs), warm_runs=runs,
                               warm_bytes=median(median(b for t, b in r["warm"]) for r in records),
                               cold_ms=median(t for r in records for t, b in r["cold"]),
                               cold_bytes=median(b for r in records for t, b in r["cold"]),
                               cache=next(iter(caches)))
            if all("warm_cpu" in r for r in records):
                rows[label]["warm_cpu_ms"] = median(median(r["warm_cpu"]) for r in records)
                rows[label]["warm_cpu_runs"] = [median(r["warm_cpu"]) for r in records]
        assert rows["before"]["cache"] == rows["after"]["cache"]
        rows["speedup"] = rows["before"]["warm_ms"] / rows["after"]["warm_ms"]
        summary[grammar][phase] = rows
        print(grammar, phase, json.dumps(rows))
(root / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
