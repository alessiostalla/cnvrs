# ANTLR Java reference fixtures

Generated with ANTLR **4.13.2**, seed 4132 for `ContextOracle`. Normal tests
read the S-expression fixtures in pure Lisp; Java is only needed to regenerate.

- `contexts.sexp`: 256 graph-context merge inputs with expected paths and
  unsigned cached Java hash codes.
- `RuntimeParity.g4`, `runtime-{parity,sll,exact}.sexp`: complete typed ATN,
  token streams, caller stacks, precedence, predictions, errors and DFA sizes.
  Modes are LL, SLL and LL_EXACT_AMBIG_DETECTION. The generator deliberately
  changes tokens with text `zero` to Java token type zero to test wildcard and
  not-set bounds. Error records include the offending token index. Parse errors after a successful
  prediction are recorded but belong to parser execution rather than prediction.
- `java8.sexp`: the same export for `Java8Parser.compilationUnit` parsing the
  repository's `bench/antlr4-grammar/Bench.java` (505 tokens), 1,431 predictions.
- `RuntimeOracle.java` and `ContextOracle.java`: generators using the upstream
  runtime, not hand-authored expected results.

Get the tool from [ANTLR's 4.13.2 download](https://www.antlr.org/download/antlr-4.13.2-complete.jar).
Its SHA-256 is:

```text
eae2dfa119a64327444672aff63e9ec35a20180dc5b8090b7a6ab85125df4d76
```

In a scratch directory containing the generators and RuntimeParity.g4:

```sh
java -jar "$ANTLR_JAR" -no-listener RuntimeParity.g4
javac -cp "$ANTLR_JAR" RuntimeParityLexer.java RuntimeParityParser.java RuntimeOracle.java ContextOracle.java
java -cp ".:$ANTLR_JAR" ContextOracle > contexts.sexp
java -cp ".:$ANTLR_JAR" RuntimeOracle > runtime-parity.sexp
ORACLE_MODE=SLL java -cp ".:$ANTLR_JAR" RuntimeOracle > runtime-sll.sexp
ORACLE_MODE=LL_EXACT_AMBIG_DETECTION java -cp ".:$ANTLR_JAR" RuntimeOracle > runtime-exact.sexp
```

For Java 8, get the grammars from the [grammar repository](https://github.com/antlr/grammars-v4/tree/master/java/java8),
with these exact SHA-256 checksums (the grammar files are checked in for offline frontend tests):

```text
16331464b1e303b6d2d4e8813f54c82b5707a56efb11eac69c0fa174e678267d  Java8Lexer.g4
ed3ec7f0181bf6e258615ba3fae8ae4d2e8eee0ad4aab474c8a11ad16cdb1940  Java8Parser.g4
```

```sh
java -jar "$ANTLR_JAR" -no-listener Java8Lexer.g4 Java8Parser.g4
javac -cp "$ANTLR_JAR" Java8Lexer.java Java8Parser.java
java -cp ".:$ANTLR_JAR" RuntimeOracle Java8Parser Java8Lexer compilationUnit \
  /path/to/cnvrs/bench/antlr4-grammar/Bench.java > java8.sexp
```

The original Java 8 snapshot predates the generator's optional `:mode` and input
predicate-flag records; omitted values mean LL and true. Prediction and DFA
records are identical on regeneration. The Java 8 grammar's BSD notice is
retained in [NOTICE-Java8.txt](NOTICE-Java8.txt); the runtime's BSD notice is in
[src/runtime/LICENSE.txt](../../../src/runtime/LICENSE.txt).


## Native frontend topology

`Core.g4` exercises sequences, alternatives, optional/star/plus blocks, sets,
wildcard/not-set edges, labels and precedence recursion. `Topology.g4` adds empty
alternatives, predicates/actions, postfix recursion, ternary recursion and labeled
sets. `test/file-topology.lisp` is the native Lisp equivalent of `Core.g4`, with
native operator precedence written low to high. It is checked both after FASL
loading and after runtime compilation.

`TopologyOracle.java` records every Java state type, rule index, state number,
block-end/loop-back link, decision index and ordered transition (including rule
follow and call precedence). The tests normalize token IDs by symbolic vocabulary;
all state/decision numbers must match exactly. No Java installation is needed to
run the tests. Regenerate using the same pinned 4.13.2 jar:

```sh
java -jar "$ANTLR_JAR" -no-listener Core.g4 Topology.g4 Java8Lexer.g4 Java8Parser.g4
javac -cp "$ANTLR_JAR" CoreLexer.java CoreParser.java TopologyLexer.java TopologyParser.java Java8Lexer.java Java8Parser.java TopologyOracle.java
java -cp ".:$ANTLR_JAR" TopologyOracle CoreParser > core-topology.sexp
java -cp ".:$ANTLR_JAR" TopologyOracle TopologyParser > topology.sexp
java -cp ".:$ANTLR_JAR" TopologyOracle Java8Parser > java8-topology.sexp
```

## Lexer construction and simulation

`LexerParity.g4` exercises rule priority, maximal match, recursive references,
nongreedy loops, predicates at entry and after consumption, indexed/end actions,
suppressed fragment actions, modes, MORE, TYPE, SKIP, channels, EOF and recovery.
`LexerCaseParity.g4` exercises grammar/rule case options, scalar/range expansion,
Unicode properties, negation and supplementary characters. `LexerOracle.java`
records complete ATNs, actions, mode/rule mappings, token text/offsets/line/column/
channel (including EOF), failure positions, callback cursors and cumulative DFA
state/ASCII-edge counts. Symbol spelling is normalized to Lisp's uppercase
convention; token text remains exact.

`test/file-lexer-atn.lisp` is the native equivalent of LexerParity.g4. Both its
FASL-restored lexer and a runtime compilation of its Lisp rules are checked
against the Java fixture. The entire Java8Lexer ATN and its token stream for
Bench.java are checked too. All tests run offline without Java.

In a scratch directory with the checked-in grammars, generators and input file:

```sh
java -jar "$ANTLR_JAR" LexerParity.g4 LexerCaseParity.g4 Java8Lexer.g4
javac -cp "$ANTLR_JAR" LexerParity.java LexerCaseParity.java Java8Lexer.java LexerOracle.java UnicodeOracle.java
java -cp ".:$ANTLR_JAR" LexerOracle > lexer-parity.sexp
java -cp ".:$ANTLR_JAR" LexerOracle LexerCaseParity lexer-case-input.txt > lexer-case-parity.sexp
java -cp ".:$ANTLR_JAR" LexerOracle Java8Lexer /path/to/cnvrs/bench/antlr4-grammar/Bench.java > java8-lexer.sexp
java -cp ".:$ANTLR_JAR" UnicodeOracle > unicode-data.sexp
```

The fragment-action warning is intentional. LexerOracle writes UTF-8 explicitly;
use UTF-8 input/output when copying the fixtures. UnicodeOracle extracts 1,185
properties and 2,558 aliases from the fixed jar's UnicodeData class and records
2,933 nonidentity simple case mappings from JDK **24**. Use that JDK to reproduce
`src/unicode-data.sexp`; later JDKs can change Character case mappings.
These immutable generated tables are loaded as data, with reader evaluation
disabled. Expanded grammar sets are frozen into grammar FASLs. The upstream BSD
license applies to the tables and port; source hashes are listed in
[src/runtime/UPSTREAM-SHA256.txt](../../../src/runtime/UPSTREAM-SHA256.txt).

## LL(1) analysis and generated dispatch

`LL1Oracle.java` exports `LL1Analyzer.getDecisionLookahead` sets and
`AnalysisPipeline.disjoint` results for every parser decision. Its small
LL1Parity corpus also invokes generated Java rules with valid/malformed token
streams and records each adaptive-prediction call. This checks direct switches,
optional/multi-alt optional, star/plus/multi-alt loops, nullable references,
recursive calls, EOF, wildcard/not-set and overlapping alternatives.

`test/file-ll1.lisp` is the native Lisp equivalent. Runtime and FASL compilation,
recognition/tree builders, and generic/compiled execution are compared against
Java. RuntimeParity adds semantic and precedence predicates; Java8Parser checks
all decisions. Token IDs are normalized through symbolic/literal vocabulary;
lookahead comparisons use the shared concrete vocabulary, while Lisp's extra
token type is exercised separately. The existing `java8.sexp` trace additionally
checks all 1,431 native execution calls and every resulting decision DFA size.

Regenerate in a scratch directory containing the grammars and LL1Oracle.java:

```sh
java -jar "$ANTLR_JAR" -no-listener LL1Parity.g4 RuntimeParity.g4 Java8Lexer.g4 Java8Parser.g4
javac -cp "$ANTLR_JAR" LL1ParityLexer.java LL1ParityParser.java RuntimeParityLexer.java RuntimeParityParser.java Java8Lexer.java Java8Parser.java LL1Oracle.java
java -cp ".:$ANTLR_JAR" LL1Oracle LL1ParityParser > ll1-parity.sexp
java -cp ".:$ANTLR_JAR" LL1Oracle RuntimeParityParser > runtime-ll1.sexp
java -cp ".:$ANTLR_JAR" LL1Oracle Java8Parser > java8-ll1.sexp
```

## Typed hash arithmetic boundaries

`MurmurOracle.java` uses the pinned Java runtime's MurmurHash and
Integer.rotateLeft to generate 140 unsigned bit-pattern cases in `murmur.sexp`.
They cover zero, sign-bit and all-one boundaries; update/finalization overflow;
word-count mixing overflow; and rotations by 0, 1, 13, 15 and 31. The standalone
runtime suite checks these independently of grammar prediction.

```sh
javac -cp "$ANTLR_JAR" MurmurOracle.java
java -cp ".:$ANTLR_JAR" MurmurOracle > murmur.sexp
```
