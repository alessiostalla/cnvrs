"""Validate C11 samples and Java-matched warm prediction work."""
import json
from pathlib import Path
import re

root = Path(__file__).resolve().parent/'profile-results'
result = {}
for mode in ('cpu-none', 'alloc-none', 'cpu-tree', 'alloc-tree'):
    text = (root/f'{mode}.txt').read_text()
    assert 'unhandled' not in text.lower()
    assert 'SIGNATURE 3C195515C9FBC094 KINDS 9068C913A4518FBE' in text
    n = int(re.search(r'Number of samples:\s+(\d+)', text)[1])
    rows = [dict(samples=int(m[1]), self_percent=float(m[2]), function=m[5]) for m in
            re.finditer(r'^\s*(\d+)\s+([\d.]+)\s+(\d+)\s+([\d.]+)\s+(.+?) \[\d+\]$',text,re.M)]
    missing = n-sum(r['samples'] for r in rows)
    assert 0 <= missing < max(2,n//100)
    result[mode] = dict(samples=n, unattributed_samples=missing, rows=rows,
                        real_seconds=float(re.search(r'([\d.]+) seconds of real time',text)[1]),
                        gc_seconds=float(re.search(r'([\d.]+) seconds GC time',text)[1]),
                        bytes=int(re.search(r'([\d,]+) bytes consed',text)[1].replace(',','')))
a,b=[(root/n).read_text()for n in ('operations.txt','java-operations.txt')]
counts,java_counts=[dict((k,int(v))for k,v in re.findall(r'^COUNT (\S+) (\d+)$',s,re.M))for s in(a,b)]
assert len(java_counts)==11
assert all(counts[k]==v for k,v in java_counts.items())
assert re.findall(r'^PREDICT .+$',a,re.M)==re.findall(r'^PREDICT .+$',b,re.M)
assert len(re.findall(r'^PREDICT ',a,re.M))==7166
assert counts['CONFIG-HIT']+counts['CONFIG-INSERT']==counts['CONFIG-ADD']
sizes={int(k.removeprefix('CONFIG-SET-SIZE-')):v for k,v in counts.items() if k.startswith('CONFIG-SET-SIZE-')}
assert sum(sizes.values())==counts['CONFIG-SETS']==616
assert sum(n*c for n,c in sizes.items())==counts['CONFIG-INSERT']
result.update(counts=counts,java_counts=java_counts,ordered_predictions=7166)
result['decisions']=sorted([dict(decision=int(d),calls=int(n),fallbacks=int(f),closures=int(c),rule=r)
    for d,n,f,c,r in re.findall(r'^DECISION (\d+) CALLS (\d+) FALLBACKS (\d+) CLOSURES (\d+) RULE (\S+)$',a,re.M)],key=lambda v:-v['closures'])
assert sum(r['closures']for r in result['decisions'])==counts['CLOSURE-CHECK']
(root/'summary.json').write_text(json.dumps(result,indent=2)+'\n')
print('Validated four profiles, all eleven shared Java counters, 7,166 ordered predictions, and configuration-set traffic.')
