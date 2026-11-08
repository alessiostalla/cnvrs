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
[src/antlr-runtime/LICENSE-ANTLR.txt](../../../src/antlr-runtime/LICENSE-ANTLR.txt).


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
