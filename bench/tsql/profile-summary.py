"""Validate and summarize warm recognition diagnostics; standard library only."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parent / 'profile-results'
result = {}
for mode in ('cpu', 'alloc'):
    text = (root / f'{mode}.txt').read_text()
    assert 'unhandled' not in text.lower()
    n = int(re.search(r'Number of samples:\s+(\d+)', text)[1])
    rows = []
    for m in re.finditer(r'^\s*(\d+)\s+([\d.]+)\s+(\d+)\s+([\d.]+)\s+(.+?) \[\d+\]$', text, re.M):
        rows.append(dict(samples=int(m[1]), self_percent=float(m[2]),
                         total_samples=int(m[3]), function=m[5]))
    missing = n - sum(r['samples'] for r in rows)
    assert 0 <= missing < max(2, n // 100)
    result[mode] = dict(samples=n, unattributed_samples=missing, rows=rows,
        real_seconds=float(re.search(r'([\d.]+) seconds of real time', text)[1]),
        gc_seconds=float(re.search(r'([\d.]+) seconds GC time', text)[1]),
        allocated_bytes=int(re.search(r'([\d,]+) bytes consed', text)[1].replace(',', '')))
text = (root / 'operations.txt').read_text()
assert 'unhandled' not in text.lower()
counts = {k: int(v) for k, v in re.findall(r'^COUNT (\S+) (\d+)$', text, re.M)}
assert counts['CLOSURE-CHECK'] == 3340043
assert counts['FALLBACK'] == 529
assert counts['REACH'] == counts['FULL-REACH'] == 1328
assert counts['START'] == counts['FULL-START'] == 529
assert counts['SHARED-CONTEXT-CACHE-GET'] == counts['BUSY-ADD'] == 0
result['counts'] = counts
result['decisions'] = sorted([
    dict(decision=int(d), calls=int(n), fallbacks=int(f), closures=int(c), rule=r)
    for d, n, f, c, r in re.findall(r'^DECISION (\d+) CALLS (\d+) FALLBACKS (\d+) CLOSURES (\d+) RULE (\S+)$', text, re.M)
], key=lambda r: -r['closures'])
assert sum(r['calls'] for r in result['decisions']) == counts['ADAPTIVE']
assert sum(r['closures'] for r in result['decisions']) == counts['CLOSURE-CHECK']
assert sum(r['fallbacks'] for r in result['decisions']) == counts['FALLBACK']
text = (root / 'chunks.txt').read_text()
assert 'unhandled' not in text.lower()
result['chunks'] = [dict(rule=r, calls=int(n), continuations=int(c))
    for r, n, c in re.findall(r'^CHUNKS (\S+) CALLS (\d+) CONTINUATIONS (\d+)$', text, re.M)]
assert sum(r['calls'] for r in result['chunks']) == 137
assert sum(r['continuations'] for r in result['chunks']) == 106
(root / 'summary.json').write_text(json.dumps(result, indent=2) + '\n')
print('Validated CPU/allocation sample totals, prediction counters, decision attribution and chunk counts.')
