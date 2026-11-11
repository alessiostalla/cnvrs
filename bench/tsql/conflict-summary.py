"""Validate paired logs and summarize seven-batch process medians."""
import json
from pathlib import Path
import re
import statistics as stats
import sys

root = Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).resolve().parent/'conflict-results'
summary = {}
for variant in ('before', 'after'):
    runs = []
    for trial in (1, 2, 3):
        text = (root/f'{variant}-{trial}.txt').read_text()
        rows = re.findall(r'^WARM \d+ MS ([\d.]+) CPU ([\d.]+) BYTES ([\d.]+)$', text, re.M)
        assert len(rows) == 7
        assert 'CACHE STATES 1475 CONTEXTS 8923' in text
        runs.append([stats.median(float(r[i]) for r in rows) for i in range(3)])
    summary[variant] = dict(warm_ms=stats.median(r[0] for r in runs),
                            cpu_ms=stats.median(r[1] for r in runs),
                            bytes=stats.median(r[2] for r in runs), run_medians=runs)
before = (root/'validation-before.txt').read_text().splitlines()
after = (root/'validation-after.txt').read_text().splitlines()
assert before == after, 'Tree/input validation or ordered decision/position/alternative mismatch'
assert len([r for r in after if r.startswith('VALIDATED ')]) == 4
assert len([r for r in after if r.startswith('PREDICT ')]) == 5297
summary['paired_reductions_percent'] = {
    key: [100*(1-a[i]/b[i]) for b, a in zip(summary['before']['run_medians'], summary['after']['run_medians'])]
    for i, key in enumerate(('warm_ms', 'cpu_ms', 'bytes'))}
summary['validation'] = dict(inputs=4, ordered_predictions=5297, dfa_states=1475, contexts=8923)
(root/'summary.json').write_text(json.dumps(summary, indent=2)+'\n')
for key in ('warm_ms', 'cpu_ms', 'bytes'):
    b, a = summary['before'][key], summary['after'][key]
    print(f'{key}: {b:.3f} -> {a:.3f}, reduction {(1-a/b)*100:.1f}%')
print('Matched trees/interpreter checks, ordered predictions, and cache populations.')
