"""Generate Java 8 and instrument ANTLR 4.13.2 for counting, never timing.

ANTLR_JAR: pinned complete jar. ANTLR_SOURCE_DIR: directory containing the
matching ATNConfigSet.java and PredictionContext.java runtime sources.
"""
from pathlib import Path
import hashlib
import json
import os
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[2]
jar = Path(os.environ["ANTLR_JAR"]).resolve()
reference = Path(os.environ["ANTLR_SOURCE_DIR"]).resolve()
output = Path(sys.argv[1]) if len(sys.argv) > 1 else root / "bench/antlr-java/profile-results"
output.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix="cnvrs-operations-") as temp:
    scratch = Path(temp)
    for name in ("Java8Lexer.g4", "Java8Parser.g4"):
        (scratch / name).write_bytes((root / "test/fixtures/antlr-runtime" / name).read_bytes())
    (scratch / "Operations.java").write_bytes((root / "bench/antlr-java/Operations.java").read_bytes())
    package = scratch / "org/antlr/v4/runtime/atn"
    package.mkdir(parents=True)
    (package / "OperationCounts.java").write_text(
        "package org.antlr.v4.runtime.atn; public class OperationCounts { "
        "public static boolean enabled; public static long adds, merges; }")
    source = (reference / "ATNConfigSet.java").read_text()
    marker = 'if ( readonly ) throw new IllegalStateException("This set is readonly");'
    assert source.count(marker) >= 1
    (package / "ATNConfigSet.java").write_text(source.replace(
        marker, "if(OperationCounts.enabled) OperationCounts.adds++;\n" + marker, 1))
    source = (reference / "PredictionContext.java").read_text()
    start = source.index("public static PredictionContext merge(")
    brace = source.index("{", start)
    (package / "PredictionContext.java").write_text(
        source[:brace + 1] + "\n if(OperationCounts.enabled) OperationCounts.merges++;\n" + source[brace + 1:])
    subprocess.run(["java", "-jar", str(jar), "-no-listener", "Java8Lexer.g4", "Java8Parser.g4"], cwd=scratch, check=True)
    subprocess.run(["javac", "-cp", str(jar), "-d", ".",
                    *[str(p.relative_to(scratch)) for p in scratch.rglob("*.java")]], cwd=scratch, check=True)
    with (output / "java-operations.txt").open("w") as log:
        subprocess.run(["java", "-Xmx2g", "-cp", f"{scratch}:{jar}", "Operations",
                        str(root / "bench/antlr4-grammar/Bench.java")], cwd=scratch,
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    hashes = {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
              for p in (jar, reference / "ATNConfigSet.java", reference / "PredictionContext.java")}
    (output / "java-instrumentation.json").write_text(json.dumps(hashes, indent=2) + "\n")
