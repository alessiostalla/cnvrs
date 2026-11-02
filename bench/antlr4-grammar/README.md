# Parsing ANTLR4 grammar files: CNVRS versus ANTLR4/Java

This benchmark parses `.g4` source files as data. CNVRS uses its built-in
`cnvrs/antlr4` grammar; Java uses `ANTLRv4Lexer.g4`, `ANTLRv4Parser.g4`, and
`LexerAdaptor.java` generated/compiled with ANTLR 4.13.2. CNVRS does not yet
compile arbitrary `.g4` files into parsers, so this is a comparison of the two
ANTLR4-language parsers, **not** of parsers generated from the sampled files.

Corpus: [antlr/grammars-v4](https://github.com/antlr/grammars-v4/) at commit
[`b96e04db9d54bb313e542cc3e6ee913900a21520`](https://github.com/antlr/grammars-v4/commit/b96e04db9d54bb313e542cc3e6ee913900a21520):

| File | Bytes |
| --- | ---: |
| `antlr/antlr4/ANTLRv4Lexer.g4` | 9,235 |
| `antlr/antlr4/ANTLRv4Parser.g4` | 8,206 |
| `java/java/JavaLexer.g4` | 6,305 |
| `java/java/JavaParser.g4` | 19,951 |
| `json/JSON.g4` | 1,221 |
| `python/python3/Python3Lexer.g4` | 10,139 |
| `python/python3/Python3Parser.g4` | 12,649 |

## Results

Measured 2026-10-31 on one macOS 14.6 ARM64 machine, native ARM64 SBCL 2.4.0,
native ARM64 Java 24, and ANTLR 4.13.2. All seven files parsed successfully
in both implementations.

Numbers are median elapsed milliseconds per parse across seven timed batches.
Tree construction was disabled for this table.

| Input | CNVRS ms | ANTLR4/Java ms | CNVRS / Java |
| --- | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 12.41 | 0.154 | 81× |
| ANTLRv4Parser.g4 | 12.77 | 0.147 | 87× |
| JavaLexer.g4 | 11.47 | 0.173 | 66× |
| JavaParser.g4 | 37.02 | 0.492 | 75× |
| JSON.g4 | 2.36 | 0.028 | 84× |
| Python3Lexer.g4 | 14.95 | 0.184 | 81× |
| Python3Parser.g4 | 27.25 | 0.320 | 85× |

The sum of these per-file medians is 118.21 ms for CNVRS and 1.498 ms for
Java, a 79× ratio. With tree construction enabled, the corresponding sums
were 120.65 ms and 1.568 ms, a 77× ratio. An earlier x86-64 SBCL 2.0.2
run under Rosetta, before the custom comparator, took 224.65 ms summed over
the same files, giving a 150× ratio against Java at that time. The runtime
architecture, SBCL version, and comparator all changed, so the two CNVRS runs
do not isolate any one of those effects.

## SBCL profile

Before the custom FSET comparator, a warm single-threaded run on
`JavaParser.g4` using the default `(:locked :fset)` caches took about 53 ms
per full parse. Profiling 200 full parses with SBCL's `sb-sprof` in CPU mode
collected 4,680 samples. Its largest
self-sample groups were generic method dispatch (26.6%), FSET list and number
comparisons (14.4% combined), and lexer NFA closure (4.6%). Samples are an
approximation; generic dispatch includes calls from more than one subsystem.

Separately timing phases on the same file gave 46.5 ms for lexing and 9.1 ms
for parsing an already tokenized vector. Lexing therefore accounts for about
84% of the sum of those phase timings. The profiler points first to lexer
transition-cache key comparisons and repeated closure work, then to parser
prediction-cache lookups.

An experiment replacing CNVRS's per-lookup generic cache method calls with
bound functions changed the seven-file no-tree sum from 170.24 to 169.07 ms
(0.7%), a difference that may be measurement noise. That change was reverted.
FSET supports a named key comparator for WB maps, so the current FSET backend
uses a function specialized for common cache keys. In a subsequent 100-parse
CPU profile of `JavaParser.g4`, the generic dispatch frame fell from 26.6% to
2.2% of samples; the new comparator accounted for 28.6%. Those percentages
come from separate sampling runs and are directional, while the elapsed-time
measurements below show the overall effect.

## Cache backend comparison

Using native ARM64 SBCL 2.4.0 and the same seven files, each configuration ran
in a fresh process. The two current-code runs cloned both the ANTLR4 lexer and
parser to the named backend; the old FSET run used the default compiled objects
before the comparator change. Each run used 10 warmup parses per file, then
seven batches of 20 parses;
the table gives the median milliseconds per parse with tree construction
disabled. The old default-FSET column predates the custom comparator; the
other two columns use the current code.

| Input | Old locked FSET | Custom-compare locked FSET | Locked hash table |
| --- | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 18.21 | 12.41 | 6.90 |
| ANTLRv4Parser.g4 | 18.67 | 12.77 | 6.95 |
| JavaLexer.g4 | 16.27 | 11.47 | 6.74 |
| JavaParser.g4 | 53.14 | 37.02 | 20.96 |
| JSON.g4 | 3.33 | 2.36 | 1.36 |
| Python3Lexer.g4 | 21.71 | 14.95 | 8.18 |
| Python3Parser.g4 | 38.91 | 27.25 | 16.91 |
| Sum of per-file medians | 170.24 | 118.21 | 68.00 |

The custom comparator made locked FSET 1.44× faster by this aggregate. Locked
hash tables remain 1.74× faster than custom-compare locked FSET. These are
single runs per configuration, and the sums weight larger files more heavily.

## Flat array cache keys

The lexer transition cache now uses a flat array containing a character code
and active state IDs. The full-context parser decision cache uses a flat array
containing a decision state ID and return stack IDs. The hash-table backend
looks up these keys structurally in a separate `equalp` table; other keys keep
their original `equal` behavior.

Rerunning the seven-file benchmark on the same ARM64 SBCL and Java runtimes,
with 10 warmups and seven batches of 20 Lisp parses (200 warmups and seven
batches of 200 Java parses), gave these median milliseconds per parse:

| Input | Flat locked FSET | Flat locked hash table | ANTLR4/Java |
| --- | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 11.326 | 7.109 | 0.148 |
| ANTLRv4Parser.g4 | 11.573 | 7.211 | 0.150 |
| JavaLexer.g4 | 10.414 | 6.866 | 0.172 |
| JavaParser.g4 | 34.124 | 21.410 | 0.503 |
| JSON.g4 | 2.171 | 1.416 | 0.029 |
| Python3Lexer.g4 | 13.811 | 8.365 | 0.189 |
| Python3Parser.g4 | 25.389 | 16.178 | 0.323 |
| Sum of per-file medians | 108.809 | 68.556 | 1.515 |

Against the earlier list-key runs above, flat keys improved locked FSET's sum
by about 8%; the locked hash-table sum was essentially unchanged. Java's sum
was also close to its previous result. The new locked FSET and locked hash
table sums are about 72× and 45× Java's sum, respectively.

For `JavaParser.g4`, separate 100-iteration phase timings with locked FSET
measured 26.6 ms for lexing and 7.1 ms for parsing pretokenized input. With
locked hash tables, lexing took 17.7 ms. The SBCL CPU profile for the latter
showed lexer epsilon closure and its newly allocated hash table among the
largest self-time groups; array allocation and structural hashing also
appeared. With FSET, key comparison remained a prominent cost. This suggests
that repeated lexer state-set work and cache lookup are the main opportunities
for narrowing the gap. The phase timings and sampled profiles do not by
themselves assign the entire Lisp/Java difference to any one operation.

## Cached lexer DFA start states

The lexer now caches an initial DFA state for each mode in its pluggable
cache. Each DFA state stores its epsilon-closed active states and best
accepting rule. A transition-cache miss creates the next DFA state; a hit
reuses it. Clearing or cloning the lexer gives it an empty cache, including
the mode start states.

With the same benchmark settings and corpus, the new results were:

| Input | Locked FSET | Locked hash table | ANTLR4/Java |
| --- | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 7.206 | 2.925 | 0.146 |
| ANTLRv4Parser.g4 | 7.759 | 3.167 | 0.151 |
| JavaLexer.g4 | 6.601 | 2.778 | 0.169 |
| JavaParser.g4 | 22.458 | 9.193 | 0.499 |
| JSON.g4 | 1.331 | 0.556 | 0.030 |
| Python3Lexer.g4 | 8.973 | 3.547 | 0.188 |
| Python3Parser.g4 | 16.605 | 6.796 | 0.325 |
| Sum of per-file medians | 70.933 | 28.962 | 1.508 |

Relative to the flat-key run, this cut the locked FSET sum by 35% and the
locked hash-table sum by 58%. The remaining gaps are about 47× and 19× Java,
respectively. In a separate warmed 100-iteration lexer-only timing on
`JavaParser.g4`, locked hash-table lexing fell from 17.7 ms to 5.6 ms per
iteration. Its new CPU profile no longer showed epsilon closure among the
sampled hot spots; flat-key construction and structural hashing were prominent.

## Direct lexer DFA edges

Lexer DFA states now hold a lazily allocated 128-entry array of ASCII edges.
Once an edge is populated, matching that character reads the array slot
without constructing or hashing a flat key. A missing edge still uses the
selected cache backend and builds the next DFA state as needed. Each state
locks access to its edge array; the selected backend still determines the
safety of the other cache operations. Non-ASCII characters continue through
the cache backend.

With the same seven inputs and benchmark settings, the medians were:

| Input | Locked FSET | Locked hash table | ANTLR4/Java |
| --- | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 2.202 | 1.414 | 0.146 |
| ANTLRv4Parser.g4 | 2.944 | 1.790 | 0.151 |
| JavaLexer.g4 | 2.711 | 1.581 | 0.169 |
| JavaParser.g4 | 9.526 | 5.342 | 0.499 |
| JSON.g4 | 0.571 | 0.321 | 0.030 |
| Python3Lexer.g4 | 3.272 | 1.872 | 0.188 |
| Python3Parser.g4 | 8.016 | 4.160 | 0.325 |
| Sum of per-file medians | 29.242 | 16.481 | 1.508 |

Compared with the cached-start-state run, this reduced the locked FSET sum
by 59% and the locked hash-table sum by 43%. The remaining gaps against Java
are about 19× and 11×. Java's parser uses context-independent SLL DFAs and
reruns full-context ATN simulation after a conflict; CNVRS instead caches
full-context start DFA states under flat keys of the decision state and return
stack. Changing that policy would be a separate parser design experiment.
Separate warmed timings for `JavaParser.g4` with locked hash tables now gave
1.69 ms for lexing and 3.78 ms for parsing pretokenized input. The parser is
the larger phase on that file after direct lexer edges were added.

## Full-context prediction strategies

The default `:cached` strategy retains a full-context start DFA under each
`(decision-state-id, return-stack)` key. The `:recompute` strategy constructs
a fresh full-context start DFA for every SLL fallback and does not retain
full-context DFA transitions between fallbacks. Both still use the same SLL
cache and lexer. The strategy can also be supplied as a function to
`compile-grammar`, `define-parser`, or `clone-compiled`.

Using the same ARM64 SBCL, corpus, and 10 warmups plus seven batches of 20
parses per file, median milliseconds per parse were:

| Input | Cached, locked hash | Recompute, locked hash | Cached, locked FSET | Recompute, locked FSET |
| --- | ---: | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 1.454 | 12.558 | 2.226 | 13.018 |
| ANTLRv4Parser.g4 | 1.833 | 26.301 | 2.921 | 26.823 |
| JavaLexer.g4 | 1.600 | 17.935 | 2.751 | 18.454 |
| JavaParser.g4 | 5.392 | 80.345 | 9.516 | 81.390 |
| JSON.g4 | 0.328 | 4.212 | 0.569 | 4.313 |
| Python3Lexer.g4 | 1.871 | 20.675 | 3.280 | 20.985 |
| Python3Parser.g4 | 4.319 | 61.326 | 7.855 | 61.512 |

| Sum of per-file medians | 16.797 | 223.352 | 29.117 | 226.495 |

On this corpus, recomputing cost 13.3× as much as caching with locked hash
tables, and 7.8× as much with locked FSET. For one warmed parse of
`JavaParser.g4`, a counting strategy observed 5,493 full-context start
requests but only 271 distinct `(decision, stack)` pairs. CNVRS therefore
reuses those starts heavily. This experiment changes only full-context
storage; it does not reproduce ANTLR4/Java's conflict detection or fallback
algorithm. Keep `:cached` as the default for now.

To compare the policies, set `BENCH_FULL_CONTEXT_STRATEGY` to `cached` or
`recompute` when running `bench.lisp`, alongside an optional
`BENCH_CACHE_BACKEND` value.

## Direct parser lookahead

Compilation now builds a one-token choice table when an alternative's first
tokens are disjoint from every other alternative and no alternative can end
without consuming a token. For choices that may end at a rule boundary, the
parser builds the table for the current return stack on first use and caches
it. Choices that still overlap or can end without consuming a token in the
current context use the existing SLL and full-context predictors. Clones get independent contextual tables, and
`clear-cache` clears them.

Using the same seven files and settings, the median milliseconds per parse
were:

| Input | Before, locked hash | Direct lookahead, locked hash | Direct lookahead, locked FSET | ANTLR4/Java |
| --- | ---: | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 1.454 | 1.256 | 1.831 | 0.149 |
| ANTLRv4Parser.g4 | 1.833 | 1.417 | 2.259 | 0.152 |
| JavaLexer.g4 | 1.600 | 1.297 | 2.181 | 0.169 |
| JavaParser.g4 | 5.392 | 4.134 | 7.149 | 0.491 |
| JSON.g4 | 0.328 | 0.257 | 0.441 | 0.029 |
| Python3Lexer.g4 | 1.871 | 1.593 | 2.649 | 0.187 |
| Python3Parser.g4 | 4.319 | 3.233 | 5.920 | 0.323 |
| Sum of per-file medians | 16.797 | 13.188 | 22.431 | 1.501 |

On a warmed `JavaParser.g4` parse, CNVRS prediction calls fell from 8,774 to
1,445, and full-context fallback calls fell from 5,493 to 996. A separate
200-iteration allocation run with locked hash caches measured 2.67 MB before
and 2.13 MB after per full parse, with tree construction disabled. The parser
phase fell from 2.01 MB to 1.46 MB. The remaining parser CPU profile shows
structural hashing of contextual keys, cache locking, and parse-loop work
among the largest costs. Java's generated parser made 1,054 adaptive
prediction calls and no full-context fallback calls on the same input; many
other choices use direct token lookahead in generated code.

## Unlocked caches and parser hot path

The default cache backend is now the unlocked `:hash-table`; `:fset` remains
available, and `(:locked backend)` opts into synchronization. The lexer's
direct ASCII DFA edges skip their per-state lock when the backend is unlocked.

For contextual direct lookahead, the parse loop maintains a 32-bit rolling
hash of the return stack. The cache uses a pair of decision ID and hash as its
common key, then checks the complete stack before reusing a table. A hash
collision falls back to an exact flat-array key. Full-context keys use a
small pair for stacks of at most one return site and retain flat arrays for
deeper stacks. Parse frames now hold the previous hash, and `:none` skips
tree-builder callbacks. Choices with one edge avoid traversing the edge list
to count it.

With tree construction disabled and the same warmup and batch settings,
the seven-file medians sum to:

| Configuration | Before this change | After |
| --- | ---: | ---: |
| Unlocked hash table | 11.017 ms | 7.048 ms |
| Locked hash table | 13.188 ms | 11.968 ms |
| Unlocked FSET | — | 13.293 ms |
| ANTLR4/Java | 1.501 ms | 1.501 ms |

On `JavaParser.g4`, an unlocked-hash phase measurement fell from 1.98 to
1.53 ms for parsing and from 1.44 to 0.73 ms for lexing. Parser allocation
fell from 1.46 to 1.02 MB per parse. The current unlocked-hash sum remains
4.7 times Java's sum; these measurements use valid `.g4` inputs and do not
isolate every semantic difference between the implementations.

Both harnesses load file contents before timing. Each timed iteration includes
lexing and parsing. CNVRS reuses its compiled objects and selected cache
backend, warmed across iterations; Java creates fresh
lexer/parser objects per iteration and the JVM is warmed before timing. CNVRS
uses `:tree-builder :none` for recognition mode and `:node` for tree mode;
Java uses `setBuildParseTree(false/true)`. These APIs do not guarantee identical
allocation or tree shapes. This is a single-threaded runtime comparison on a
small set of valid grammar files, not an isolated algorithm benchmark or a
measurement of memory use, concurrency, or grammar compilation.

## Contextual choices with one or two tokens

The contextual lookahead cache now keeps a unique nullable exit when its
token choices do not overlap. For overlapping first tokens, it also caches
choices that a full-context DFA proves unique after at most two tokens.
Unresolved token pairs still use the existing predictor. These tables are
created on first use for each caller context and then reused.

On a warmed `JavaParser.g4` parse, full-context fallback calls fell from 996
to zero. With tree construction disabled, the ARM64 SBCL parser phase fell
from about 1.38 to 1.17 ms per run; lexing stayed near 0.66 ms. Parser
allocation fell from about 1.02 MB to 0.78 MB per run. The seven-file sum
of medians fell from 6.382 to 5.919 ms with the same 10 warmups and seven
batches of 20 parses; the Java sum was 1.501 ms. This leaves CNVRS about
3.9 times slower on that corpus. The next parser profile is dominated by
the general parse loop and return-stack verification for contextual cache
hits, rather than full-context DFA simulation.

## Generated rule functions

Parser compilation now produces two runners with named local functions for
each rule: one for recognition without a tree and one for the default node
builder. Each function runs its rule's states directly and calls the local
function for a referenced rule. Custom builders and recovery still use the
general parser loop. The lexer already compiles a DFA matcher with a named
local `match-one` function, so this change does not alter its runtime path.

With the same seven-file no-tree benchmark, the sum of medians fell from
5.919 to 5.004 ms. With tree construction enabled, the current sum is
5.134 ms. The Java no-tree sum remains 1.501 ms, leaving a roughly 3.3×
gap on this corpus. On `JavaParser.g4`, recognition-only parser time fell
from about 1.17 to 0.85 ms per run. These are warm, single-threaded runs;
compilation time is outside the timed region. The generated and general
parsers produced equal trees on all seven files and agreed on 350 inputs
with one mutated token each.

## Canonical return contexts

The parser now interns each `(return state, parent context)` into a numeric
context ID. Contextual direct choices use a packed `(context ID, state ID)`
cache key, so a warm lookup no longer compares the return stack or hashes a
list. The context interner uses the configured cache backend and is cleared
and cloned with the parser's other caches.

On `JavaParser.g4`, the warmed recognition-only parser phase measured about
0.77 ms per run, compared with about 0.94 ms before context IDs. The
seven-file no-tree sum was 4.629 ms versus 5.004 ms in the preceding run;
Java remained at 1.501 ms, leaving about a 3.1× gap. With tree building,
the current CNVRS sum was 4.916 ms versus Java's earlier 1.568 ms. These short runs are
subject to timing variance. All seven files still produced the same trees
through the generated and general parsers, and 350 single-token mutations
agreed on acceptance or rejection.

## Generated direct choices

For a caller-independent one-token decision, parser compilation now emits
token dispatch directly into the rule function. Symbol tokens use `case`;
other token values use `equal` checks. Context-dependent and unresolved
choices still use the cached predictor, and a token absent from the direct
table falls back to prediction so error behavior is preserved.

The seven-file no-tree sum fell from 4.629 to 4.428 ms with the same warmup
and batch settings. The current tree-building sum was 4.801 ms; the earlier
Java sums were 1.501 ms without trees and 1.568 ms with trees. The generated
and general parsers again produced equal trees for all seven files and
agreed on 350 single-token mutations. The parser-only `JavaParser.g4` phase
measured about 0.75 ms per run, versus 0.77 ms before this change. These
small differences should be read as directional until repeated under
controlled load.

## Deferred token text

The compiled lexer and ANTLR4 adapter now retain each token's source and
character offsets, extracting text only when `lexeme-text` is called. On
`JavaParser.g4`, the lexer phase fell from about 0.65 to 0.57 ms per run,
and lexer allocation fell from about 662 to 489 KB per run. Parser time on
pretokenized input stayed near 0.68 ms. The seven-file no-tree sum was
4.114 ms, versus 4.428 ms before this change. Java's earlier sum was
1.501 ms, leaving about a 2.7× gap. Text access now allocates a substring
when requested; tokens retain their source string while they remain live.

## Rerun after compiled FOLLOW choices

Measured 2026-11-02 on the same seven source files, with the current CNVRS
parser (including compiled repetition and optional choices), native ARM64 SBCL
2.4.0, Java 24, and ANTLR 4.13.2. Tree construction was disabled. Four
separate processes per runtime each warmed every file, then took the median
of seven timed batches (100 parses per batch for CNVRS, 300 for Java). The
table gives the median of those four process results for each file.

| Input | CNVRS ms | ANTLR4/Java ms | CNVRS / Java |
| --- | ---: | ---: | ---: |
| ANTLRv4Lexer.g4 | 0.363 | 0.143 | 2.54× |
| ANTLRv4Parser.g4 | 0.381 | 0.143 | 2.66× |
| JavaLexer.g4 | 0.357 | 0.140 | 2.56× |
| JavaParser.g4 | 1.091 | 0.416 | 2.62× |
| JSON.g4 | 0.067 | 0.026 | 2.60× |
| Python3Lexer.g4 | 0.447 | 0.168 | 2.65× |
| Python3Parser.g4 | 0.800 | 0.295 | 2.71× |

The median sum of per-file timings within a process was **3.507 ms for CNVRS**
and **1.347 ms for Java**, a **2.60×** ratio. CNVRS's four sums ranged from
3.489 to 3.535 ms; Java's ranged from 1.208 to 1.487 ms. Java varied
substantially between processes, so the ratio should be read with that range
in mind.

Two additional runs measured lexer and parser phases separately. Summing the
seven per-file medians, CNVRS took 1.863–1.881 ms for lexing and 1.463–1.467
ms for parsing pretokenized input. Java took 0.881–0.896 ms and 0.623–0.672
ms, respectively. These phase harnesses prepare tokens outside parser timing;
their separate phase sums need not equal the full-parse sum. As with earlier
results, the benchmark compares parsers for the ANTLR4 grammar language, not
compilation or parsing with the sampled grammars themselves.

### SBCL optimization policy

The earlier normal build used SBCL's default `(speed 1) (safety 1) (debug 1)`
policy. Fresh builds under `(speed 3) (safety 1) (debug 0) (space 0)` and the more
aggressive `(speed 3) (safety 0) (debug 0) (space 0)` policy were benchmarked
with the same 4 GB SBCL heap. Three paired default/safe-speed-3 runs summed to
3.353/3.036, 3.328/3.037, and 3.321/3.003 ms over the seven files: a
consistent improvement of about 9%. Three paired default/safety-0 runs summed
to 3.429/3.049, 3.333/3.123, and 3.340/2.933 ms. Both optimized builds
passed all 256 repository checks. Safety 0 did not show a clear additional
gain over the safe speed-3 build. The first safe speed-3 compilation exhausted
SBCL's default 1 GB heap; a 4 GB heap completed it. These measurements do not
isolate inlining from other compiler optimizations.

The safe speed-3 policy is now the SBCL default for CNVRS source files and
generated rule functions. Three runs with that project setting summed to
3.072, 3.024, and 3.044 ms. A fresh project build also passed all 256 checks
with SBCL's default 1 GB heap. Loading CNVRS leaves the caller's global SBCL
compiler policy unchanged.

## Lexer, parser-choice, and cache-key type work

Measured 2026-11-02 with native ARM64 SBCL 2.4.0, Java 24, ANTLR 4.13.2,
and the seven grammars-v4 files at the revision below. Tree construction was
disabled. Each Lisp stage used six separate processes, 20 warmups per file,
and the median of seven batches of 100 parses. The table gives the median and
range of the six sums of per-file medians. Java used three processes, 200
warmups, and seven batches of 300 parses. Both runtimes reused their compiled
grammar objects and runtime caches within a process.

| Stage | CNVRS sum, ms | Range, ms | Ratio to Java median |
| --- | ---: | ---: | ---: |
| Before these changes | 3.039 | 2.989–3.434 | 2.11× |
| Typed lexer rule arrays and ASCII DFA edges | 2.813 | 2.756–2.949 | 1.96× |
| Typed choice positions and context IDs | 2.932 | 2.766–3.155 | 2.04× |
| Flat-key predicate and comparator specialization | 2.756 | 2.737–3.105 | 1.92× |
| ANTLR4/Java | 1.438 | 1.208–1.498 | 1.00× |

The parser stage has an unusually wide full-parse range. In a separate
lexer/parser phase harness, the sum of seven parser-only medians fell from
1.420–1.425 ms after the lexer stage to 1.367–1.386 ms after the parser stage.
The baseline lexer-only sum was 1.587 ms; after the lexer change it was
1.336–1.364 ms. These phase runs support the local improvements, while the
full-parse results should not be read as precise per-stage speedups.

On fresh SBCL 2.4.0 builds, the notes in `src/cnvrs.lisp` and `src/lexer.lisp`
fell from 305 to 247. The lexer's matcher and DFA-edge functions went from
13 to 3 notes; the compiled parser choice and context functions went from
43 to 5; flat cache-key creation, recognition, and comparison went from 41
to 31. Remaining notes include generic string access for the public lexer
input, parser-state and token-vector access, and generic comparisons for
non-flat FSET keys. A specialized simple-base-string branch was measured and
removed because it increased lexer phase time on this corpus.

## Reproduce

From the repository root, set `ANTLR_JAR` to an ANTLR 4.13.2 complete JAR and
`SBCL_BIN` to a native ARM64 SBCL binary.
The commands below require `curl`, Java, `javac`, SBCL, and CNVRS dependencies
available through Quicklisp or ASDF.

```sh
export ANTLR_JAR=/path/to/antlr4-4.13.2-complete.jar
export SBCL_BIN=/path/to/arm64/sbcl
export BENCH_DIR=/tmp/cnvrs-antlr4-grammar-bench
export GRAMMARS_REV=b96e04db9d54bb313e542cc3e6ee913900a21520
mkdir -p "$BENCH_DIR/corpus" "$BENCH_DIR/java"
for path in \
  antlr/antlr4/ANTLRv4Lexer.g4 \
  antlr/antlr4/ANTLRv4Parser.g4 \
  java/java/JavaLexer.g4 \
  java/java/JavaParser.g4 \
  json/JSON.g4 \
  python/python3/Python3Lexer.g4 \
  python/python3/Python3Parser.g4; do
  name=$(printf '%s' "$path" | tr / _)
  curl -fLsS "https://raw.githubusercontent.com/antlr/grammars-v4/$GRAMMARS_REV/$path" \
    -o "$BENCH_DIR/corpus/$name"
done
for name in ANTLRv4Lexer.g4 ANTLRv4Parser.g4 LexerAdaptor.java; do
  curl -fLsS "https://raw.githubusercontent.com/antlr/grammars-v4/$GRAMMARS_REV/antlr/antlr4/$name" \
    -o "$BENCH_DIR/java/$name"
done
cp bench/antlr4-grammar/Bench.java "$BENCH_DIR/java/"
(cd "$BENCH_DIR/java" && \
  java -jar "$ANTLR_JAR" -Dlanguage=Java -no-listener -no-visitor \
    ANTLRv4Lexer.g4 ANTLRv4Parser.g4 && \
  javac -cp "$ANTLR_JAR" *.java)
"$SBCL_BIN" --script bench/antlr4-grammar/bench.lisp 10 7 20 "$BENCH_DIR"/corpus/*.g4
java -cp "$ANTLR_JAR:$BENCH_DIR/java" Bench 200 7 200 "$BENCH_DIR"/corpus/*.g4
BENCH_TREE=1 "$SBCL_BIN" --script bench/antlr4-grammar/bench.lisp 10 7 20 "$BENCH_DIR"/corpus/*.g4
BENCH_TREE=1 java -cp "$ANTLR_JAR:$BENCH_DIR/java" Bench 200 7 200 "$BENCH_DIR"/corpus/*.g4
```

The harnesses print tab-separated rows of `OK`, file name, source character
count, and median nanoseconds per parse; failures print `FAIL`. Warmup and
batch sizes are command-line arguments. Run the two programs separately and
avoid other heavy work during measurement.

To reproduce the profile and phase timings with ARM64 SBCL, run:

```sh
"$SBCL_BIN" --script bench/antlr4-grammar/profile.lisp "$BENCH_DIR/corpus/java_java_JavaParser.g4" 200
PROFILE_PHASE=lexer "$SBCL_BIN" --script bench/antlr4-grammar/profile.lisp "$BENCH_DIR/corpus/java_java_JavaParser.g4" 100
PROFILE_PHASE=parser "$SBCL_BIN" --script bench/antlr4-grammar/profile.lisp "$BENCH_DIR/corpus/java_java_JavaParser.g4" 100
PROFILE_CACHE_BACKEND=locked-hash-table "$SBCL_BIN" --script bench/antlr4-grammar/profile.lisp "$BENCH_DIR/corpus/java_java_JavaParser.g4" 100
```

`PROFILE_CACHE_BACKEND` also accepts `hash-table`, `fset`, and `locked-fset`.
On macOS, `sb-sprof`'s CPU mode can under-sample some threads; these runs
profile the main parsing thread, and the sample counts should be read as
directional evidence.

To repeat a current-code cache comparison, run the Lisp benchmark command above four
times with `BENCH_CACHE_BACKEND` set to `locked-fset`, `locked-hash-table`,
`fset`, and `hash-table`. Each process clones both CNVRS's ANTLR4 lexer and
parser so the selected backend applies to both. The old FSET column above
requires the version before `cache-key-compare` was added.
