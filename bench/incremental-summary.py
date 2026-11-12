"""Summarize sequential before/after and incremental benchmark result files."""
import pathlib
import re
import statistics
import sys

root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "bench/incremental-results")
for grammar in ("iri", "java8"):
    print(grammar)
    for phase in ("LEXER", "PARSE-NONE", "PARSE-TREE", "PIPELINE-TREE"):
        medians = []
        allocations = []
        for revision in ("before", "after"):
            samples, byte_samples = [], []
            for trial in range(1, 4):
                text = (root / f"{grammar}-{revision}-{trial}.txt").read_text()
                values = re.findall(rf"^WARM {phase} BATCH \d+ MS ([\d.]+) BYTES ([\d.]+)$", text, re.M)
                assert len(values) == 7, (grammar, revision, trial, phase)
                samples.append(statistics.median(float(ms) for ms, _ in values))
                byte_samples.append(statistics.median(float(b) for _, b in values))
            medians.append(statistics.median(samples))
            allocations.append(statistics.median(byte_samples))
        change = f"{100 * (medians[1] / medians[0] - 1):+.1f}%" if medians[0] else "below timer resolution"
        print(f"  {phase:14} {medians[0]:10.6f} -> {medians[1]:10.6f} ms "
              f"({change}), "
              f"{allocations[0]:.0f} -> {allocations[1]:.0f} bytes")
    # All phase cache signatures must remain identical across every run.
    signatures = []
    for revision in ("before", "after"):
        for trial in range(1, 4):
            text = (root / f"{grammar}-{revision}-{trial}.txt").read_text()
            signatures.append(re.findall(r"^CACHE .+$", text, re.M))
    assert all(signature == signatures[0] for signature in signatures)
    print("  DFA/context cache signatures identical across all runs")

text = (root / "incremental.txt").read_text()
for case in ("CHARACTERS", "JAVA8"):
    print(case)
    batch = None
    for phase in ("BATCH", "INITIAL", "NOOP", "EDIT-EARLY", "EDIT-MIDDLE", "EDIT-LATE"):
        values = re.findall(rf"^{case}/{phase} SAMPLE \d+ MS ([\d.]+) BYTES ([\d.]+)$", text, re.M)
        assert len(values) == 7, (case, phase)
        ms = statistics.median(float(ms) for ms, _ in values)
        size = statistics.median(float(b) for _, b in values)
        if batch is None:
            batch = ms
        print(f"  {phase:14} {ms:10.6f} ms {size:12.0f} bytes ({batch / ms:.2f}x batch speed)")
