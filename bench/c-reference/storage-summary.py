"""Validate phase logs and report before/after process medians."""
import json
from pathlib import Path
import re
import statistics as stats
import sys
root=Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).resolve().parent/'storage-results'
summary={}
for workload in ('preprocessed','pointers'):
    summary[workload]={}
    headers=set(); caches=set()
    for phase in ('NONE','NODE'):
        row={}
        for variant in ('before','after'):
            runs=[]; cold=[]
            for trial in (1,2,3):
                text=(root/f'{workload}-{variant}-{trial}.txt').read_text()
                headers.add(re.search(r'^INPUT .+$',text,re.M)[0])
                caches.add(re.search(r'^CACHE .+$',text,re.M)[0])
                rows=re.findall(rf'^WARM {phase} \d+ MS ([\d.]+) CPU ([\d.]+) BYTES ([\d.]+)$',text,re.M)
                assert len(rows)==7
                runs.append([stats.median(float(r[i])for r in rows)for i in range(3)])
                rows=re.findall(rf'^COLD {phase} \d+ MS ([\d.]+) CPU ([\d.]+) BYTES ([\d.]+)$',text,re.M)
                assert len(rows)==3
                cold.extend([[float(v)for v in r]for r in rows])
            row[variant]=dict(ms=stats.median(r[0]for r in runs),cpu_ms=stats.median(r[1]for r in runs),
                bytes=stats.median(r[2]for r in runs),runs=runs,cold_ms=stats.median(r[0]for r in cold),
                cold_bytes=stats.median(r[2]for r in cold))
        summary[workload][phase.lower()]=row
        print(workload,phase,[(v,round(row[v]['ms'],4),round(row[v]['bytes']/1e6,3))for v in ('before','after')])
    assert len(headers)==len(caches)==1,(headers,caches)
validation=[]
for variant in ('before','after'):
    validation.append(re.findall(r'^VALIDATED .+$',(root/f'validation-{variant}.txt').read_text(),re.M))
assert len(validation[0])==2 and validation[0]==validation[1],validation
(root/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print('Token/kind signatures and cache populations match across all twelve processes.')
