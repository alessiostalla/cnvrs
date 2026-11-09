# ANTLR Java 4.13.2 ATN runtimes

This is a Common Lisp port of the parser prediction and lexer simulation runtimes from the fixed
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
| `LL1Analyzer.getDecisionLookahead`, tool `AnalysisPipeline.disjoint`, `ParserFactory` and Java templates | [ll1-analyzer.lisp](ll1-analyzer.lisp): predicate-opaque one-token lookahead with recursion guards and exact rule returns; frontend emits direct switches/EBNF exits when sets are disjoint |
| `LexerATNSimulator`, `LexerATNConfig`, `OrderedATNConfigSet`, `LexerActionExecutor` | [lexer-atn-simulator.lisp](lexer-atn-simulator.lisp): ordered closure, return contexts, nongreedy priority, speculative predicates, maximal-match rewind, indexed actions and ASCII DFA caching |
| Tool: `LexerATNFactory`, `RangeBorderCharactersData`, `ATNOptimizer.optimizeSets` | [lexer-atn.lisp](../lexer-atn.lisp) and shared factory: mode starts, scalar/Unicode sets, case folding, lexer commands, lazy blocks/loops and sequential-alt set merging |
| `Lexer.nextToken` | [lexer-runtime.lisp](../lexer-runtime.lisp): MORE/SKIP, mode stack, token overrides, EOF, conditions/restarts and Java-style optional recovery |
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
Parser recovery remains outside the port. Parser actions run
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

## Lexer boundaries and fidelity

Lexer configurations retain complete prediction contexts, action executors and
nongreedy flags. Unlike parser `ATNConfigSet`, `OrderedATNConfigSet` does not merge
different return contexts. Lexer contexts are not interned in the parser's shared
context cache. DFA states preserve ordered configuration identity; the first
rule-stop configuration determines the accepted type/actions. DFAs have one
entry per ATN decision, with mode starts occupying the first entries, as in Java.
Only ASCII transition edges are cached. Predicate-dependent starts/edges are
suppressed; target states can still be interned. Predicates are evaluated during
closure with speculative cursor restoration. Actions execute after acceptance,
with custom offsets fixed before consuming the next character.

Lisp token types and mode/channel names remain symbols, with package identity;
rule indices, state numbers and action indices are ordinary integers. The lexer
uses immutable strings and invocation-local cursors rather than Java CharStream
mark/seek. Native offsets count Lisp characters (Unicode code points), corresponding
to Java's CodePointCharStream; lexeme ends are exclusive. Conditions and
SKIP-CHARACTER expose recovery; `:recover t` selects Java's consume-and-continue
behavior. Streaming emits EOF; bulk lexing omits it for compatibility.

The offline lexer suite checks mixed recursive/nongreedy rules, fragments,
predicates before and after consumption, indexed/end actions, modes, MORE,
SKIP, TYPE, channels, EOF rules, malformed inputs, Unicode properties, case
options and supplementary characters. Native runtime and FASL lexers are
checked against the same Java fixture. It also checks cloning, cache clearing,
reentrant predicates, token overrides, recovery restarts and shared-DFA interning.
The entire Java 8 lexer has an exact 1,117-state ATN match; its 505-token source
stream and mode DFA state/edge counts agree with Java.

UnicodeData properties and aliases come from the pinned 4.13.2 jar. Simple case
mappings come from JDK 24, since Java's tool uses its host JDK's Character tables.
Both are frozen in `antlr-unicode-data.sexp`; a different JDK can produce different
case mappings. Lisp grammar FASLs freeze expanded sets and require no Java tool.
The importer still requires explicit Lisp mappings for embedded Java callbacks,
uses symbolic command arguments, and does not load imported grammars or execute
prequel Java code. These frontend boundaries are separate from ATN simulation.

## Direct LL(1) parser dispatch

The frontend computes Java's SLL(1) lookahead at grammar compilation. Predicates
(including precedence predicates) before the next token make that alternative
opaque. Actions are traversed without execution. Nested calls retain exact
return contexts; outermost rule stops traverse global ATN follow edges, as Java's
`getDecisionLookahead` does with EmptyPredictionContext and addEOF=false.
Empty/opaque or intersecting alternative sets retain adaptive prediction.

Eligible choices compile to one-token switches. Optional/star/plus decisions
exit when no body alternative matches, following the Java templates; ordinary
alternative blocks fail. Java normalizes multi-alt loop bodies into an inner
choice, so loop entry/continuation and body alternatives are analyzed separately.
The generic parser uses the same immutable token-indexed maps. EOF and arbitrary
Lisp token values remain supported, with the adapter's extra token type for
wildcard/not-set matches outside the explicit vocabulary. FASLs preserve the
maps and compile direct rule functions; clear-cache clears runtime DFAs while
retaining this grammar analysis. Recompile existing grammar FASLs to enable it.

There are 2,282 additional differential/regression checks: exact lookahead and
eligibility for LL1Parity, RuntimeParity and the entire Java 8 parser; generated
Java adaptive-call sequences for valid rule inputs; malformed acceptance;
native runtime/FASL and generic/compiled execution; predicate/action boundaries;
arbitrary Lisp token values; and lexer-definition cache clearing. Full Java 8
execution now makes exactly Java's 1,431 adaptive calls in the same order and
matches its per-decision DFA counts (1,160 states), with 24,764 cached contexts.
