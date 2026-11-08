> Historical pre-port investigation. The active predictor is now the ANTLR Java reference port; these diagnostic hooks are not a runtime backend.

# Remaining Java 8 prediction expansion

Investigated 2026-11-08 on native ARM64 SBCL 2.4.0, 2 GiB heap, after the
closure-local implementation at `b68a54f`. The production source is unchanged
by this investigation. New code is confined to the profiling harness.

## Finding

The main remaining bottleneck on `Bench.java` is enumeration of return-stack
paths during **full-context prediction**. Closure-local interning speeds up
key comparisons, but still visits each distinct `(state, stack, alternative)`.
It neither merges stack sets nor teaches prediction when an ambiguity has
already resolved to the same preferred alternative on every remaining path.

The first problematic decision is `unannReferenceType` (state 136), at
zero-based token position 50: the `BaseErrorListener` field type. It keeps
looking into the initializer's anonymous class and method bodies. The earlier
commentary identifying the `Recognizer` parameter was incorrect; that
parameter occurs later in the source.

A three-million-key diagnostic cap interrupts prediction after 50 input-token
advances inside this decision. The unfinished closure alone visits **2,092,775
configurations** over only **500 state/alternative pairs**, with stacks up to
182 entries deep. That closure accounts for roughly **734 MB** of cumulative
allocation, including instrumentation. Its lack of a returned result is an
interruption, not an empty closure.

## Controlled experiments

Each full-source experiment used a fresh process and stopped at three million
attempted graph-closure key computations. Grammar compilation and lexing were
outside the measured region. These are bounded work profiles, not successful
parse timings or throughput comparisons. Counts include attempted keys that
abort an eager speculation at its existing budget.

| Configuration | Full-context keys | SLL keys | Bounded specialization keys | Direct contextual keys |
| --- | ---: | ---: | ---: | ---: |
| Defaults | 2,975,540 | 7,340 | 16,262 | 858 |
| Eager specialization disabled | 2,991,678 | 7,464 | 0 | 858 |
| Recompute full-context starts | 2,975,540 | 7,340 | 16,262 | 858 |

Full-context work is **99.2%** of the default sample. Disabling specialization
or avoiding cached full-context starts does not remove the explosion. The
recompute experiment retains fewer full-context cache objects, but still
follows the same expanding paths. Overall post-GC heap usage was about 89.7 MB
with caching versus 63.8 MB with recomputation; those totals include the runtime
and grammar, not just caches or the transient working set.

The default run allocated about **1.05 GB cumulatively** before the cap. This
is not 1.05 GB of retained data. Instrumentation itself allocates temporary keys
and counters, so these allocation numbers characterize this diagnostic run.

## Small reproducer

This **63-character, 24-token** source already exceeds the same work cap:

```java
class Demo { Object x = new Object() { void f() { foo(); } }; }
```

Prediction is still deciding the type `Object` at token 3. One unfinished
closure visits **2,474,696 configurations**, again across only **500
state/alternative pairs**, before the cap interrupts it.

The reduced cases use fresh parser clones in one process. Timings are omitted
because these profiles instrument every key and are not independent timing
trials. In the table, `>3,000,000` means the cap interrupted the parse, not a
known complete work total.

| Source feature | Characters / tokens | Default keys | Experimental termination keys |
| --- | ---: | ---: | ---: |
| Method calling `foo()` | 34 / 14 | 530,337 | 530,337 |
| Method throwing `new E("a" + ":" + "b" + " " + "c")` | 69 / 25 | 757,260 | 757,260 |
| Field `Object x;` | 24 / 7 | 17,285 | 17,285 |
| Field `Object x = new Object();` | 39 / 12 | 658,685 | 319,161 |
| Anonymous-class field with method calling `foo()` | 63 / 24 | >3,000,000 | >3,000,000 |
| Anonymous-class field with the throwing method above | 98 / 35 | >3,000,000 | >3,000,000 |

The method and throwing-method cases are wrapped in `class Demo`. Field cases
are wrapped in the same class. Anonymous cases put the method in
`Object x = new Object() { ... };`.

## ANTLR/Java comparison and diagnostic experiment

ANTLR/Java's normal LL mode can stop before only one alternative remains:
it groups configurations by state and prediction context, finds the minimum
alternative in each group, and stops when every group prefers the same one.
CNVRS currently waits for a singleton overall alternative set, empty reach,
or end of input. See [ParserATNSimulator.execATNWithFullContext](https://github.com/antlr/antlr4/blob/4.13.2/runtime/Java/src/org/antlr/v4/runtime/atn/ParserATNSimulator.java)
and [PredictionMode.getSingleViableAlt](https://github.com/antlr/antlr4/blob/4.13.2/runtime/Java/src/org/antlr/v4/runtime/atn/PredictionMode.java).

A benchmark-only adaptation of this rule resolves the full source's
`unannReferenceType` and nested `unannClassOrInterfaceType` decisions after
**two token advances**, choosing alternative zero while `(0 1)` remains in the
DFA. It also cuts the simple `new Object()` field case's key work by **51.5%**.
It passes all **457 existing checks**, but this does not establish complete
ANTLR equivalence.

It is not sufficient by itself. The full source then reaches
`assignmentExpression` (state 440) at token 53, `new`, and again hits the cap.
A completed closure there visits **1,159,650 configurations** over **500
state/alternative pairs**, returning **406,575** configurations. Both anonymous
reproducers also still hit the cap. The experiment adds a scan over each
full-context reach set and can increase allocation; it is not an optimized
production implementation.

ANTLR also merges configurations with the same state, alternative, and semantic
context, combining their prediction contexts into a graph-structured stack.
Our current temporary stack IDs canonicalize individual stacks but do not
combine sets of stacks into one configuration. See
[ATNConfigSet.add](https://github.com/antlr/antlr4/blob/4.13.2/runtime/Java/src/org/antlr/v4/runtime/atn/ATNConfigSet.java).

The measured multiplicity strongly motivates context-set merging as the next
representation change. The ratios above are evidence of duplicate work over
state/alternative pairs, not a forecast of the speedup from merging. Distinct
return paths must remain represented; simply dropping the stack from the key
would change prediction semantics.

## Next implementation steps

1. Implement and validate full-context conflict termination, with explicit
   regression grammars for ambiguous types and caller-dependent alternatives.
2. Represent and merge prediction-context sets, starting with the anonymous
   class reproducer. Measure both closure visits and output configuration counts.
3. Revisit full-context caching once prediction work is bounded in practice.
   The recompute control shows that cache policy alone cannot fix this case.

## Reproduce

Use the grammar versions and checksums linked from [README.md](README.md).
From the repository root, with a native SBCL executable:

```sh
PROFILE_MODE=expansion PROFILE_VISIT_BUDGET=3000000 PROFILE_SECONDS=8 \
JAVA8_SOURCE_FILE=bench/antlr4-grammar/Bench.java \
"$SBCL_BIN" --dynamic-space-size 2048 --script bench/java8/profile.lisp \
  "$JAVA8_DIR/Java8Lexer.g4" "$JAVA8_DIR/Java8Parser.g4"
```

Run each control in a fresh process with one additional environment variable:

- `PROFILE_SKIP_TWO_TOKEN=1`: disable all eager n-token specialization.
- `PROFILE_RECOMPUTE_FULL=1`: recompute full-context starts.
- `PROFILE_SINGLE_VIABLE_ALT=1`: enable the diagnostic termination rule.
- `PROFILE_EXPERIMENT_TESTS=1`: run the suite with that diagnostic rule, instead
  of profiling. This option belongs to expansion mode and installs no key counters.

Use `JAVA8_SOURCE_FILE` for a reduced source file, or `JAVA8_SOURCE` for literal
source text. The file option takes precedence. Expansion mode defaults to the
existing 200,000-key visit cap unless explicitly overridden as above.

[Raw diagnostic output](expansion-results.txt) includes the four full-source
runs and both six-case reduced runs. The hooks install only within the profiling
process and are not loaded by the CNVRS ASDF system. All new investigation files
and harness changes are uncommitted after `b68a54f`.
