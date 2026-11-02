# IRI parser prediction benchmark

This benchmark compiles the unchanged grammars-v4 IRI grammar in
`test/fixtures/IRI.g4`. It parses a fixed 217-character IRI with 216 tokens,
using the generated recognition runner without a tree. Lexing and grammar
compilation are outside the timed region. Each strategy gets 10 warmup parses
and seven batches of 200 timed parses; the median batch time per parse is
reported.

Run from the repository root with `sbcl --script bench/iri/bench.lisp`. Set
`ASDF_OUTPUT_TRANSLATIONS` to a writable cache directory if needed.

On repeated x86-64 SBCL 2.0.2 runs, cached full-context prediction took about
0.07–0.08 ms per parse; recomputing it took about 0.65–0.74 ms. A warm parse
still invokes full-context prediction once at the `iauthority` decision,
which distinguishes optional user information from the host. These results
are a baseline for a compiled predictor experiment, not a comparison with
ANTLR/Java.

## Runtime compilation experiment

Run `sbcl --script bench/iri/compiled-atn-bench.lisp` to compile the grammar's
ATN closure and token transitions once while keeping tokens and return stacks
as runtime inputs. The script installs the generated functions only in a
separate parser clone and restores the original runtime functions on exit.
On x86-64 SBCL 2.0.2, code generation took about 0.52 seconds. Repeated runs
gave roughly 0.06–0.07 ms per warm parse for both paths. With caches cleared
before each parse, the existing simulator took about 230–250 ms and the
compiled simulator about 245–253 ms. The generated code therefore did not
improve this input.

Run `sbcl --script bench/iri/compiled-dfa-bench.lisp` to compile the observed
`iauthority` DFA trace into a function. The trace has 13 states and compiles
in about 5–7 ms. A trained input uses the generated function without fallback;
unseen contexts or transitions use the original predictor. Repeated runs measured
about 0.06–0.08 ms per complete warm parse for both paths, and the isolated
prediction call took about 0.0005 ms with either path. Compiling all 3,160
states reachable from the learned `iauthority` start exceeded this SBCL's
1 GiB heap, so the script intentionally compiles only the observed trace.

Both experiments compare acceptance or error type on ten valid and invalid IRI
inputs and three alternate entry rules before timing. These short,
single-machine timings are directional.
