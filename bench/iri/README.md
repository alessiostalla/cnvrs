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

The generalized, public version is `compile-cached-dfa`. Run
`sbcl --script bench/iri/general-dfa-bench.lisp` to train a parser clone and
compile its observed SLL and full-context DFA roots with a 32-state cap per
root. On x86-64 SBCL 2.0.2, it compiled 3 roots and 65 states in about 15 ms.
Ten varied IRI inputs agreed. Two local runs measured 0.072 versus 0.075 ms
and 0.063 versus 0.060 ms per warm parse (normal versus compiled). The change
is within run-to-run variation here; the generic compiler is opt-in and leaves
unseen paths on the adaptive predictor.

Both experiments compare acceptance or error type on ten valid and invalid IRI
inputs and three alternate entry rules before timing. These short,
single-machine timings are directional.

## Callable return continuations

Run `sbcl --script bench/iri/continuation-dfa-bench.lisp` to compare the
full-context predictor with a benchmark-only variant. Each grammar return site
has a compiled continuation factory. A continuation node holds the callable
resume closure and a canonical context ID, so speculative rule returns can
invoke the closure while DFA caches still recognize equivalent contexts. The
variant converts the current compiled runner's list stack when prediction is
entered; it does not change the parser's public API or production path.

On x86-64 SBCL 2.0.2, 14 IRI parsing cases agreed, including a long IRI and
three alternate entry rules. The deepest captured predictor call had seven
return frames. Median warm prediction was 0.00033 ms with lists, 0.00101 ms
with list-to-continuation conversion, and 0.00026 ms when the continuation
chain was prepared before the timed call. Median long-IRI warm parse was
0.0855 ms with lists and 0.0865 ms with conversion. These numbers are
directional: they come from one machine and one grammar. The conversion
dominates this prototype's isolated cost; a parser runner that passes
continuation nodes directly would be needed to test the no-conversion path
end to end. The prototype also duplicates about 150 lines of DFA simulation,
so it has not improved code clarity in its current form.
