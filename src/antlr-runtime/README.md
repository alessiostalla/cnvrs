# ANTLR Java 4.13.2 parser prediction runtime

This is a Common Lisp port of the parser prediction runtime from the fixed
[ANTLR 4.13.2 tag](https://github.com/antlr/antlr4/tree/4.13.2/runtime/Java/src/org/antlr/v4/runtime).
It replaces the former predictor; it is not another heuristic layered on it.
Upstream's BSD-3-Clause notice is retained in [LICENSE-ANTLR.txt](LICENSE-ANTLR.txt).

## Source map

| Java reference | Lisp implementation |
| --- | --- |
| `PredictionContext`, `EmptyPredictionContext`, `SingletonPredictionContext`, `ArrayPredictionContext`, `PredictionContextCache` | [prediction-context.lisp](prediction-context.lisp): context nodes, `merge-contexts`, `merge-singletons`, `merge-root`, `merge-arrays`, `combine-common-parents`, `cached-context` |
| `misc.MurmurHash` | `murmur-update`, `murmur-finish`, unsigned 32-bit cached context hashes |
| `ATNConfig`, `ATNConfigSet` | [atn-config.lisp](atn-config.lisp): configuration identity, context merging, read-only DFA configuration sets |
| `PredictionMode` | `conflicting-alt-subsets`, `has-sll-conflict-terminating-prediction`, `single-viable-alt`, `unique-alt` |
| `SemanticContext` | Immutable predicate/operator forms, conjunction/disjunction flattening and precedence reduction, `semantic-eval`, `eval-precedence` |
| `ParserATNSimulator` | [parser-atn-simulator.lisp](parser-atn-simulator.lisp): `adaptive-predict`, `exec-atn`, `compute-start-state`, `compute-reach-set`, stop-state/epsilon closure, SLL conflict handling, `exec-atn-with-full-context`, precedence filtering and loop-entry elimination |
| `DFA`, `DFAState` | Decision DFA interning, accept/conflict/predicate states, cached token edges, precedence-specific start states |
| Tool: `ParserATNFactory`, `TailEpsilonRemover`, `ATNOptimizer.optimizeStates` | [native-atn.lisp](../native-atn.lisp): typed rule/block/loop construction, element splicing, exact rule-target visitor traversal, tail-epsilon removal and state compaction |
| Tool: `LeftRecursiveRuleAnalyzer`, `LeftRecursiveRuleTransformer`, `LeftRecursiveRules.stg` | `java-left-recursion`: primary block, initial empty action, precedence-predicate loop, operand precedence and associativity; no helper rules |

The merge cache is allocated lazily during one prediction and discarded on every
exit. Its pair keys match Java's `DoubleKeyMap`, including the absence of an
SLL/LL mode component. SLL merging treats the empty context as a wildcard;
full-context merging keeps the exact empty path. Only SLL DFA configuration
contexts enter the persistent shared cache. Full-context starts and transitions
are not cached. `clear-dfa` preserves the shared context cache, matching Java;
the higher-level Lisp `clear-cache` explicitly clears both.

The Java configuration-set equality details are retained, including identity
comparison of conflicting-alt bit sets when interning DFA states. The oracle
checks DFA state counts in addition to returned alternatives so these details
cannot be replaced casually with a merely similar result.

## Host-language and frontend boundaries

- Immutable vector-backed context nodes implement Java's singleton/array
  interface. A one-element node is a singleton; the distinguished empty node
  uses `EMPTY_RETURN_STATE`. Java's temporary singleton-to-array view does not
  need an allocated wrapper in this representation.
- Lisp hash buckets use the cached Java context hash and structural equality.
  Portable Common Lisp does not provide arbitrary hash-table equality tests.
- Java's null/invalid-alt sentinel becomes `nil`; predicted alternatives inside
  the port remain one-based, ordinary token types positive, invalid type `0`, and EOF `-1`.
- Input is an immutable token vector with a prediction-local cursor, so Java's
  mark/seek/release restoration is implicit, including non-local exits.
- The [frontend adapter](../antlr-runtime-adapter.lisp) maps Lisp token values
  and filtered physical positions to token types and logical offsets. An extra
  type represents arbitrary Lisp values outside a grammar's explicit vocabulary.
  The native execution layer continues to expose zero-based choice indices.
- A Lisp caller stack already contains the follow-state numbers which Java
  obtains through invoking states. It becomes a prediction-context graph only
  when full-context fallback requires it. Native callbacks retain their
  `(input position)` interface; predicates have distinct rule/site identities.
- The native grammar frontend constructs the Java tool's parser ATN topology.
  Element/alternative labels and left-recursion tree folding are annotations,
  not extra states or rules. Rule indices and decision numbers follow declaration
  and construction order. Runtime and FASL compilation preserve these fields.
  Java-generated prediction fixtures additionally test the core in isolation.
- Native recursive alternatives retain low-to-high precedence ordering; `.g4`
  alternatives retain Java's high-to-low order. Token IDs may differ because
  Lisp supports arbitrary token values; structural comparisons normalize IDs
  through the Java vocabulary while checking all graph numbers exactly.
- Native PARSE accepts any rule as an entry point with implicit EOF. At EOF it
  may finish a precedence loop whose recursive-only Java ATN has no EOF follow.
  This execution-boundary behavior does not change the ATN or prediction core.

No eager multi-token tables, global caller-stack IDs, persistent full-context
DFA caches, predicate-result caches, or native DFA trace snapshots are used.
Lexer simulation and recovery remain outside the port. Parser actions now run
on the selected execution path, never during prediction; predicates are collected
in SLL and evaluated on full-context closure as in Java.

## Fidelity checks

`asdf:test-system :cnvrs/antlr-runtime` runs **2,741 checks** without Java:

- 256 Java-generated SLL/LL context-merge cases, including exact hashes,
  path sets, identity reuse and context-cache canonicalization.
- **1,620 Java prediction decisions** over identical ATNs: grammar ambiguity,
  caller-sensitive choices, optionals, recursive calls, predicates, left-recursive
  precedence, malformed inputs, and a 505-token Java source file.
- Every recorded DFA-state count, in LL, SLL and exact-ambiguity modes;
  Java's no-viable-alternative outcomes and offending positions; wildcard/not-set bounds (including invalid token type zero); shared-DFA/context interning from four
  threads; and clearDFA lifetime behavior.

The main `asdf:test-system :cnvrs` also runs 382 integration checks for native
Lisp grammar forms, composition, runtime/file compilation, `.g4` import, lexer
features, tree builders, channels, callbacks and recovery. Tests tied to the
removed eager tables and full-context trace caches were replaced with the new
runtime contracts, rather than preserved as alternative prediction paths.

The main suite also runs 3,222 frontend topology checks, including native
runtime/file compilation, imported empty alternatives, sets, labels, callbacks,
postfix/ternary recursion, the entire 2,843-state Java 8 parser and a full Java 8
source parse. They compare state kinds/numbers, ordered edges and token sets,
rule/decision indices, follows, precedence predicates and loop/block links.

These tests establish agreement for their corpus, not a proof of universal
ANTLR equivalence. Keep the reference decomposition and extend Java differential
coverage when correcting a mismatch. [Fixture provenance and regeneration](../../test/fixtures/antlr-runtime/README.md).
