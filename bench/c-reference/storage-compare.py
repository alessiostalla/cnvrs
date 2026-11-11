"""Sequential fresh-process configuration-storage A/B benchmark."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('before', type=Path)
p.add_argument('--sbcl', default='sbcl')
p.add_argument('--cache-root', type=Path, required=True)
p.add_argument('--results', type=Path)
a = p.parse_args()
root = Path(__file__).resolve().parents[2]
before = a.before.resolve()
results = (a.results or root/'bench/c-reference/storage-results').resolve()
results.mkdir(parents=True, exist_ok=True)
sources = ['src/runtime/atn-config.lisp','src/runtime/prediction-context.lisp',
           'src/runtime/parser-atn-simulator.lisp','src/cnvrs.lisp']
metadata = dict(baseline=str(before),base_revision=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),
    runtime=subprocess.check_output([a.sbcl,'--version'],text=True).strip(),heap_mib=2048,
    source_sha256={label:{s:hashlib.sha256((base/s).read_bytes()).hexdigest()for s in sources}
                   for label,base in [('before',before),('after',root)]},
    harness_sha256=hashlib.sha256((root/'bench/c-reference/storage.lisp').read_bytes()).hexdigest())
(results/'environment.json').write_text(json.dumps(metadata,indent=2)+'\n')
for trial in (1,2,3):
    for workload,filename in [('preprocessed','examples/Wmisleading-indentation.pp.c'),('pointers','pointers.c')]:
        for label in (('after','before') if trial==2 else ('before','after')):
            env=os.environ.copy()
            env['ASDF_OUTPUT_TRANSLATIONS']=f'(:output-translations (t "{a.cache_root.resolve()}/{label}/") :ignore-inherited-configuration)'
            with (results/f'{workload}-{label}-{trial}.txt').open('w') as log:
                subprocess.run([a.sbcl,'--dynamic-space-size','2048','--script',str(root/'bench/c-reference/storage.lisp'),
                                workload,'bench/c-reference/'+filename],cwd=before if label=='before' else root,
                               env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
            print(f'Completed {workload} {label} {trial}',flush=True)
for label, base in [('before',before),('after',root)]:
    env=os.environ.copy()
    env['ASDF_OUTPUT_TRANSLATIONS']=f'(:output-translations (t "{a.cache_root.resolve()}/{label}/") :ignore-inherited-configuration)'
    with (results/f'validation-{label}.txt').open('w') as log:
        subprocess.run([a.sbcl,'--dynamic-space-size','2048','--script',str(root/'bench/c-reference/storage-validate.lisp')],
                       cwd=base,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
subprocess.run(['python3',str(root/'bench/c-reference/storage-summary.py'),str(results)],check=True)
