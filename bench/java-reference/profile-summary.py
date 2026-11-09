"""Validate exact Java/Lisp operation counts and ordered decision positions."""
from pathlib import Path
import json
import re
import sys

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent / "profile-results"
records = {}
sequences = {}
for label in ("java", "before", "after"):
    text = (root / f"{label}-operations.txt").read_text()
    records[label] = {key: int(value) for key, value in re.findall(r"^COUNT ([A-Z-]+) (\d+)$", text, re.M)}
    sequences[label] = re.findall(r"^PREDICT (\d+) (\d+)$", text, re.M)
    assert re.search(r"(?:DFA ROOTS 66 STATES|DFA STATES) 1160$", text, re.M), label
    assert re.search(r"^CONTEXTS 24764$", text, re.M), label
    assert len(records[label]) == 13, (label, records[label])
    assert len(sequences[label]) == records[label]["ADAPTIVE"] == 1431
assert records["java"] == records["before"] == records["after"], records
assert sequences["java"] == sequences["before"] == sequences["after"]
(root / "operations-summary.json").write_text(json.dumps(
    {"counts": records["java"], "identical_counts": True,
     "identical_ordered_decision_position_pairs": len(sequences["java"])}, indent=2) + "\n")
print("All 13 operation counts and all 1431 ordered decision/position pairs match Java, before and after.")
