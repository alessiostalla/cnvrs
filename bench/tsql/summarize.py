"""Validate complete benchmark logs and summarize medians (standard library only)."""
from pathlib import Path
import json
import re
import statistics as stats
import sys

root = Path(__file__).resolve().parent
results = Path(sys.argv[1]) if len(sys.argv) > 1 else root / "results"
phases = ("lexer", "parse-none", "parse-tree", "pipeline-tree")
data = {}
for grammar in ("select", "schema", "json", "backup"):
    signatures = set()
    kinds = set()
    topologies = set()
    lexer_topologies = {"java": set(), "cnvrs": set()}
    counts = set()
    for runtime in ("java", "cnvrs"):
        for trial in (1, 2, 3):
            path = results / f"{grammar}-{runtime}-{trial}.txt"
            text = path.read_text()
            signature = re.search(r"(?:^| )SIGNATURE ([0-9A-F]{16})", text, re.M)
            assert signature, f"Missing token signature: {path}"
            signatures.add(signature[1])
            kind = re.search(r"^KIND-SIGNATURE ([0-9A-F]{16})$", text, re.M)
            assert kind, path
            kinds.add(kind[1])
            topology = re.search(r"^TOPOLOGY (.+)$", text, re.M)
            assert topology, path
            topologies.add(re.search(r"PARSER-RULES .+", topology[1])[0])
            lexer_topologies[runtime].add(re.search(r"LEXER-RULES (\d+) LEXER-STATES (\d+)", topology[1]).groups())
            counts.add(tuple(re.search(r"CHARACTERS (\d+) TOKENS (\d+)", text).groups()) +
                       (re.search(r"^DEFAULT-TOKENS (\d+)$", text, re.M)[1],))
            for phase in phases:
                record = {}
                for state, count in (("COLD", 3), ("WARM", 7)):
                    rows = re.findall(rf"^{state} {phase} (?:TRIAL|BATCH) \d+ MS ([\d.]+) BYTES ([\d.]+)$", text, re.M | re.I)
                    assert len(rows) == count, (path, phase, state, len(rows))
                    record[state.lower()] = [[float(a), float(b)] for a, b in rows]
                cache = re.search(rf"^CACHE {phase} LEXER-STATES (\d+) LEXER-EDGES (\d+) PARSER-STATES (\d+) CONTEXTS (\d+)$", text, re.M | re.I)
                assert cache, (path, phase, "cache")
                record["cache"] = [int(x) for x in cache.groups()]
                data[grammar, runtime, phase, trial] = record
    assert len(signatures) == 1, (grammar, signatures)
    assert len(kinds) == 1, (grammar, kinds)
    assert len(topologies) == 1, (grammar, topologies)
    assert lexer_topologies == {"java": {("1212", "14856")}, "cnvrs": {("1212", "14857")}}, lexer_topologies
    assert len(counts) == 1, (grammar, counts)
    print(f"{grammar}: matching token kinds {next(iter(kinds))}, topology {next(iter(topologies))}")
    print(f"{grammar}: identical token signatures in all six processes: {next(iter(signatures))}")

summary = {}
for grammar in ("select", "schema", "json", "backup"):
    print(f"\n{grammar}\nphase java-warm-ms cnvrs-warm-ms ratio java-cold-ms cnvrs-cold-ms java-warm-bytes cnvrs-warm-bytes")
    summary[grammar] = {}
    for phase in phases:
        row = {}
        for runtime in ("java", "cnvrs"):
            records = [data[grammar, runtime, phase, t] for t in (1, 2, 3)]
            warm_runs = [stats.median(r["warm"][i][0] for i in range(7)) for r in records]
            caches = {tuple(r["cache"]) for r in records}
            assert len(caches) == 1, (grammar, runtime, phase, caches)
            row[runtime] = {
                "warm_ms": stats.median(warm_runs),
                "warm_run_medians_ms": warm_runs,
                "cold_ms": stats.median(x[0] for r in records for x in r["cold"]),
                "cold_bytes": stats.median(x[1] for r in records for x in r["cold"]),
                "warm_bytes": stats.median(stats.median(x[1] for x in r["warm"]) for r in records),
                "cache": next(iter(caches)),
            }
        assert row["java"]["cache"] == row["cnvrs"]["cache"], (grammar, phase, "cache mismatch")
        row["ratio"] = row["cnvrs"]["warm_ms"] / row["java"]["warm_ms"]
        summary[grammar][phase] = row
        j, c = row["java"], row["cnvrs"]
        print(f'{phase} {j["warm_ms"]:.6f} {c["warm_ms"]:.6f} {row["ratio"]:.2f} {j["cold_ms"]:.6f} {c["cold_ms"]:.6f} {j["warm_bytes"]:.1f} {c["warm_bytes"]:.1f}')
(results / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")

lines = ["# Benchmark summary", "", "Times are milliseconds per call. Ratios are CNVRS / Java.", ""]
for metric, title in (("warm_ms", "Warm caches"), ("cold_ms", "Cold DFA/context caches")):
    lines += [f"## {title}", "", "| Grammar | Phase | Java | CNVRS | Ratio |", "| --- | --- | ---: | ---: | ---: |"]
    for grammar, phases_data in summary.items():
        for phase, row in phases_data.items():
            j, c = row["java"][metric], row["cnvrs"][metric]
            lines.append(f"| {grammar} | {phase} | {j:.6f} | {c:.6f} | {c/j:.2f}× |")
    lines.append("")
lines += ["## Warm allocation per call", "", "Decimal MB; cumulative allocation, not live heap.", "",
          "| Grammar | Phase | Java MB | CNVRS MB | Ratio |", "| --- | --- | ---: | ---: | ---: |"]
for grammar, phases_data in summary.items():
    for phase, row in phases_data.items():
        j, c = row["java"]["warm_bytes"], row["cnvrs"]["warm_bytes"]
        lines.append(f"| {grammar} | {phase} | {j/1e6:.6f} | {c/1e6:.6f} | {c/j:.2f}× |")
lines += ["", "## Per-process warm medians", "", "Each value is the median of seven batch means.", "",
          "| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |", "| --- | --- | --- | --- |"]
for grammar, phases_data in summary.items():
    for phase, row in phases_data.items():
        j = ", ".join(f"{x:.6f}" for x in row["java"]["warm_run_medians_ms"])
        c = ", ".join(f"{x:.6f}" for x in row["cnvrs"]["warm_run_medians_ms"])
        lines.append(f"| {grammar} | {phase} | {j} | {c} |")
lines += ["", "## Trained pipeline caches", "",
          "| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |",
          "| --- | --- | ---: | ---: | ---: | ---: |"]
for grammar, phases_data in summary.items():
    for runtime in ("java", "cnvrs"):
        cache = phases_data["pipeline-tree"][runtime]["cache"]
        lines.append(f"| {grammar} | {runtime} | " + " | ".join(map(str, cache)) + " |")
(results / "summary.md").write_text("\n".join(lines) + "\n")
