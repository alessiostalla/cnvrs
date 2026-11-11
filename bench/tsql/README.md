# T-SQL compiler-resource investigation

[Latest paired Java performance comparison](../java-reference/configuration-storage.md)
after configuration-set storage changes; [prior comparison](compact.md)
after compact conflict grouping.

**Fixed:** the unchanged T-SQL grammar now compiles with native ARM64 SBCL
2.4.0 using a **2 GB heap and the default control stack**. Its generated runners
also compile to a FASL and load successfully under those limits. Four upstream
SQL inputs parse through the compiled runtime and FASL runners, with trees equal
to the interpreter and token streams/kinds matching ANTLR Java 4.13.2.

A separate preparation run took **38.32 seconds wall / 37.08 seconds user CPU**,
with **355,729,408 bytes peak RSS (339.25 MiB)**. This includes importing both
`.g4` files, native compilation of recognition and tree runners, and predictor
initialization. It excludes FASL compilation and SQL parsing. The process had a
2,048 MiB heap limit; RSS is measured by macOS `getrusage`, not Lisp allocation.
[Recorded command and resource data](results/preparation.json).

## What failed

The previous many-closures-in-one-`labels` issue was a useful lead, but runtime
rule functions were already independently compiled. Two other forms of excessive
compiler scope remained:

- Generated one-token switches repeated hundreds of token tests in individual
  functions. The original 2 GB trace failed while compiling `backup_database`.
  Its printed recognition form was about 399 KB despite having only 252 states.
- After bounding those switches, `built_in_functions` still exhausted the heap:
  it had **1,350 states in one function**. Its printed recognition form shrank
  from about 965 KB to 372 KB with the switch change, but remained too large.

The full FASL test revealed additional file-wide retention. A root search found
compiler IR retained through `SB-C::*IR1-NAMESPACE*` constant tables and constant
leaves' `REFS`, including backend VOPs and register-allocation data.
[Heap inventory and retention path](results/compiler-retention.txt).
SBCL 2.4.0 [intentionally retains those caches on ARM64](https://github.com/sbcl/sbcl/blob/sbcl-2.4.0/src/compiler/main.lisp)
because its `NIL` constant leaf supplies a wired register-allocation TN. Resetting
the entire namespace would violate that requirement.

These are compiler resource costs, not evidence about parser prediction
correctness or parsing throughput. The original
[2 GB](../c-reference/attempts/tsql-heap-2gb.txt) and
[8 GB](../c-reference/attempts/tsql-heap-8gb.txt) failures remain as history.
The [instrumented baseline trace](results/baseline-compile-trace.txt) and
[token-switch-only trace](results/token-tests-only-compile-trace.txt) isolate
the two runtime compilation failures.

## Changes

Large direct-lookahead tests use the existing token-index/lookahead tables
instead of repeated giant switches. Large token-set membership tests call a
shared function so SBCL does not expand a constant list into a huge local test.
Tests involving at most 64 token keys keep the previous generated code.

Rules with more than 128 states use independently compiled chunks of at most
64 states. Cursor state stays in the existing per-parse record; children, labels,
and continuation state pass through arguments and multiple values. There is no
mutually local `labels` group or new heap-allocated frame per chunk. Smaller
rules keep their previous runner shape.

FASL emission places helpers in separate top-level definitions and assembles
runners from function-name descriptors when loading. It avoids embedding a whole
grammar's lambdas or hundreds of function-valued constructor arguments in one
compiler component. Loading a FASL performs no runtime compilation.

On SBCL ARM64, a guarded compiler-boundary workaround releases constant caches
and finished `NIL` references after each helper while preserving the required
`NIL` leaf itself. It runs during top-level macro expansion, not `eval-when`
evaluation in a separate compiler namespace. It checks that the internal
accessors exist, skips nested compilation environments, and skips explicitly
requested block compilation. This is a platform-specific workaround using SBCL
compiler internals; the structural changes are portable.

## Validation

Normal and forced-safety-3 builds each pass **12,336 checks**. New tests cover
runtime and FASL compilation with 512 token alternatives, a labeled 160-token
rule spanning chunks, and 300 additional independent rules. They compare trees
with the interpreter and test failure propagation, EOF/prefix behavior, clones,
and large dispatch-vector resolution. [Check totals](results/tests.txt).

The complete T-SQL runner FASL is also compiled and loaded, then compared with
runtime runners and interpreted trees on these unchanged upstream examples:

| Input | Characters | All tokens | Default-channel tokens |
| --- | ---: | ---: | ---: |
| `backup.sql` | 1,978 | 221 | 221 |
| `built_in_functions_json.sql` | 4,472 | 822 | 808 |
| `ddl_create_table.sql` | 1,574 | 252 | 244 |
| `dml_select.sql` | 20,047 | 2,949 | 2,849 |

Both compiled recognition and tree runners are called directly so `parse`'s
interpreter fallback cannot conceal a failure. Full token text, location,
channel, and kind signatures agree with strict-EOF Java parses.
[Native log](results/validation-cnvrs.txt), [Java log](results/validation-java.txt).
The subsequent [fresh paired benchmark](benchmark.md) measures the compiled
parser against Java on these same four inputs.

## Sources and reproduction

The unchanged grammars and examples are pinned to grammars-v4 commit
[`b96e04db9d54bb313e542cc3e6ee913900a21520`](https://github.com/antlr/grammars-v4/tree/b96e04db9d54bb313e542cc3e6ee913900a21520/sql/tsql).
The parser has 609 rules, 14,516 ATN slots, and 1,840 decisions in Java; the
lexer has 1,212 rules including fragments and 14,856 ATN slots. Trailing
whitespace at EOF is normalized; upstream MIT notices are retained.

From the repository root, with Java 24 first on `PATH`:

```sh
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
ASDF_OUTPUT_TRANSLATIONS='(:output-translations (t "/tmp/cnvrs-tsql-cache/") :ignore-inherited-configuration)' \
REFERENCE_JAR=/path/to/antlr-4.13.2-complete.jar \
SBCL_BIN=/path/to/native/sbcl \
  bash bench/tsql/validate.sh
```

For preparation alone, use `sbcl --dynamic-space-size 2048 --script
bench/tsql/prepare.lisp`. The validation script records runtime versions and
source hashes because this working copy also contains earlier uncommitted lookup
optimizations. [Environment](results/environment.txt).
