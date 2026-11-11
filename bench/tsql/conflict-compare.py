"""Build isolated native cores, then measure paired warm SELECT recognition."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('before', type=Path, help='baseline source snapshot')
p.add_argument('--sbcl', default='sbcl')
p.add_argument('--results', type=Path)
a = p.parse_args()
root = Path(__file__).resolve().parents[2]
before = a.before.resolve()
results = (a.results or root / 'bench/tsql/conflict-results').resolve()
results.mkdir(parents=True, exist_ok=True)
sources = ['src/runtime/atn-config.lisp', 'src/runtime/parser-atn-simulator.lisp',
           'src/runtime/prediction-context.lisp', 'src/cnvrs.lisp']
metadata = dict(baseline=str(before), candidate_revision=subprocess.check_output(
    ['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip(),
    sbcl=subprocess.check_output([a.sbcl, '--version'], text=True).strip(), heap_mib=2048,
    source_sha256={label: {s: hashlib.sha256((base/s).read_bytes()).hexdigest() for s in sources}
                   for label, base in [('before', before), ('after', root)]},
    harness_sha256={s: hashlib.sha256((root/'bench/tsql'/s).read_bytes()).hexdigest()
                    for s in ['recognition.lisp', 'conflict-validate.lisp', 'conflict-compare.py']})
(results/'environment.json').write_text(json.dumps(metadata, indent=2)+'\n')
with tempfile.TemporaryDirectory(prefix='cnvrs-conflict-') as scratch:
    cores = {}
    for label, base in [('before', before), ('after', root)]:
        core = Path(scratch)/f'{label}.core'
        cores[label] = core
        env = os.environ.copy()
        env['ASDF_OUTPUT_TRANSLATIONS'] = f'(:output-translations (t "{scratch}/{label}-cache/") :ignore-inherited-configuration)'
        with (results/f'prepare-{label}.txt').open('w') as log:
            subprocess.run([a.sbcl, '--dynamic-space-size', '2048', '--script',
                            'bench/tsql/prepare-core.lisp', str(core)], cwd=base,
                           env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    def run(label, script, log):
        with (results/log).open('w') as output:
            subprocess.run([a.sbcl, '--core', str(cores[label]), '--dynamic-space-size', '2048',
                            '--script', str(root/'bench/tsql'/script)], cwd=root,
                           stdout=output, stderr=subprocess.STDOUT, check=True)
    for trial in (1, 2, 3):
        for label in (('after', 'before') if trial == 2 else ('before', 'after')):
            run(label, 'recognition.lisp', f'{label}-{trial}.txt')
            print(f'Completed {label} {trial}', flush=True)
    for label in ('before', 'after'):
        run(label, 'conflict-validate.lisp', f'validation-{label}.txt')
subprocess.run(['python3', str(root/'bench/tsql/conflict-summary.py'), str(results)], check=True)
