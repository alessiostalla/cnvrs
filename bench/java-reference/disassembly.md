# Native-code audit of prediction hot paths

SBCL 2.4.0, native ARM64 on Apple M1 Max; production policy is speed 3 / safety 1,
debug 0, space 0, compilation-speed 1. This examines the current uncommitted
compact-context/hash-bucket runtime based on a640f58. Production source was not
changed during this audit. [Source hashes and environment](disassembly-results/environment.json)
identify the inspected code. [disassemble.lisp](disassemble.lisp) captures the
three operations and their helpers; every `.asm` file is saved in
[disassembly-results](disassembly-results/).

## Findings by operation

### Closure checking and traversal

`closure-checking-stop-state` is 1120 bytes; its companion `closure-work` is
1932 bytes. The configuration/set/depth arguments are already typed. State IDs,
depth comparisons and most slot reads compile to direct loads and integer
instructions. This is not an entirely untyped/generic traversal.

However, `closure-work`'s `LOOP ... for index from 0` leaves INDEX as an unbounded
integer. Its increment calls **SB-KERNEL:TWO-ARG-+**, saving/restoring registers
around a full generic arithmetic call. A diagnostic copy using `for index fixnum
from 0` removes that call at the same safety level. The unchanged-body control
still contains it. This is a clear missing declaration, although the call is not
necessarily executed once for every closure visit: many states have few edges.

At entry, stop-state checking loads the dynamically bound `*simulator*`, handles
the thread/global binding path, tests for an unbound value, tests for NIL, loads
ATN/states, bounds-checks the index, then checks the object loaded from the
general vector is an ATN state. Similar sequences occur at other inlined state
lookups. The ATN vector type says `simple-vector`; it cannot tell the compiler
that every element is an ATN state. Simply repeating that vector declaration
will not remove this work. Keeping validated local references and propagating
result types across helpers are candidates; removing checks requires establishing
the corresponding invariants, rather than globally reducing safety.

Context iteration repeatedly dispatches on singleton versus array representation.
The two indexed accessors each also verify a singleton's index is zero. There
are two ASSERT-ERROR reference sites in the closure body. Their error calls are
cold, but the guarding branches remain on valid paths. Dispatching once on the
context representation, then traversing concrete fields, would make the singleton
index invariant explicit and avoid repeated generic accessors.

### Configuration insertion: checks, lookup, and object creation

The previous **316043 insertions** should more precisely be called
**316043 `config-set-add` attempts**. A separately instrumented trained parse
appends only **22970 new configurations**; **293073 calls (92.7%)** merge into
an existing entry. These are not additional Java/Lisp work differences.

`config-set-add` is 1120 bytes. Its hash calculation is already inline integer
arithmetic with masks/shifts/multiplies; it does not call generic numeric helpers
or allocate temporary list keys. The nonempty semantic-form SXHASH path is
conditional; the common `semantic = T` path skips it.

It does still call **GETHASH3**, generic **FIND** with a function-valued equality
test, and MERGE-CONTEXTS. After FIND, it validates the returned object's structure
before accessing it. The insertion branch performs another GETHASH3, allocates
one 16-byte bucket-link cons, calls %PUTHASH, and calls VECTOR-PUSH-EXTEND. The
second lookup is on the 22970 new-entry calls, not on every attempt. Hash-table
test dispatch, generic sequence search and adjustable-vector insertion are
remaining abstraction costs; argument declarations alone do not eliminate them.

Adding set/config/cache declarations and an explicit hash-table assertion reduces
this body from **1120 to 1060 bytes** in a controlled compile. GETHASH3 and FIND
remain. Thus a typed bucket loop or a collection with a more precise interface
would be a separate change, not something already achieved by declarations.

The more important helper is **DERIVE-CONFIG**:

- The common default-argument path repeats the same ATN-CONFIG structure check
  for the default context, default semantic value, and later slot reads.
- Explicit parameter declarations reduce the body from **340 to 208 bytes**,
  removing the repeated structure checks and the state-value fixnum check.
- Each valid call still allocates a **64-byte configuration**, initializes its
  header/layout and six payload fields, and executes SBCL's normal allocation /
  publication sequence. The size is directly visible in `ADD ..., TMP, #64`.
- A trained parse invokes it **1436961 times**, accounting for approximately
  **91.97 MB** of allocation, about 34% of the measured 271.33 MB total. This
  estimate is for DERIVE-CONFIG alone; initial configurations have other sites.

This is strong evidence for missing constructor/copy-helper type information
and for the importance of configuration storage. The allocation itself is not
proved unnecessary: Java also constructs configurations along these paths.
Reusing or eliminating configurations would need separate correctness evidence.

### Context merging: data construction dominates the avoidable work

`merge-contexts` is a small dispatcher (428 bytes in the ASDF build), forwarding
to singleton merging (1168 bytes) or array merging (**4236 bytes**). Its branch
arithmetic is already specialized. Adding argument declarations to an unchanged
same-process control does **not** shrink the dispatcher (404 → 404 bytes).
The ASDF/control difference comes from compilation context, not the added hints.

The array merge has much more concrete overhead:

1. Repeated singleton/array type dispatch for size, return-state and parent reads.
2. Repeated singleton-index assertions. There are **15 ASSERT-ERROR reference
   sites** in this body, plus cold bounds/type-error traps. These are static
   sites, not measurements of executed error handlers.
3. Return states are tagged objects in a general vector. Loads are followed by
   checks that the values are unsigned 32-bit integers. Declaration of a general
   vector does not establish its element type.
4. It builds **two linked lists** with PUSH, reverses both, walks each again to
   determine its length, allocates vectors and calls REPLACE to copy the entries.
   These operations are visible as cons allocations, LIST-NREVERSE, length loops,
   ALLOCATE-VECTOR-ON-HEAP and REPLACE in the disassembly.

The matching Java 4.13.2 source allocates result arrays up front, merges into them
with an output index, and trims when necessary. Our linked-list staging is a
representation deviation with no change to the mathematical merge algorithm.
A trained Lisp parse has **250613 array-merge calls**, including cache hits.
The array results constructed on that path contain **628517 entries** in total.
Their two staging lists alone allocate at least **20.11 MB** (32 bytes per result
entry), followed by the reversals, length scans and copies. This is a lower bound:
it excludes staging lists on paths collapsing to a singleton.

Packed return-state arrays are another concrete opportunity. Java stores an
`int[]`; ours stores eight-byte tagged values. A diagnostic accessor for
`(simple-array (unsigned-byte 32) (*))` compiles to a bounds check, a **32-bit LDR**,
and tagging the return value; it has no per-element numeric type check. It
occupies 52 bytes as an isolated function. This demonstrates the representation
benefit; it is not a fair standalone speed comparison to the current accessor,
which also handles context class dispatch. Using packed arrays internally would
need to preserve the existing exported vector-view interface.

The merge cache also has a measurable storage cost. Each active write creates a
three-cons `(a b result)` list (48 bytes) and a bucket-link cons (16 bytes):
**64 bytes per cache write**. There are **231731 active writes**, or **14.83 MB**.
Cache reads destructure those lists and perform list/type checks and structural
context equality. Explicit helper argument types shrink GET from **564 to 472
bytes** and PUT from **408 to 336 bytes** in same-process controls, but do not
remove generic hash dispatch or the list representation. A compact typed entry
could reduce pointer chasing without changing the cache lifetime or equality.

## Controlled compiler experiments

[disassembly-experiments.lisp](disassembly-experiments.lisp) compiles new diagnostic
function names; it does not replace production definitions. All controls and
variants use speed 3 / safety 1. Body sizes exclude some entry/argument-dispatch
machinery and are not runtime speedup estimates.

| Function / change | Same-process control | Diagnostic variant | Evidence |
| --- | ---: | ---: | --- |
| DERIVE-CONFIG: typed parameters | 340 B | 208 B | repeated structure checks removed |
| CONFIG-SET-ADD: typed parameters/table | 1120 B | 1060 B | smaller checks; generic lookup/search remain |
| CLOSURE-WORK: fixnum loop index | 1892 B | 1884 B | generic TWO-ARG-+ call removed |
| MERGE-CONTEXTS: typed parameters | 404 B | 404 B | no improvement from these declarations |
| MERGE-CACHE-GET: typed parameters | 564 B | 472 B | fewer argument/slot checks |
| MERGE-CACHE-PUT: typed parameters | 408 B | 336 B | fewer argument/slot checks; same allocation |

The diagnostic declaration variants, temporarily substituted **only in a separate
test process**, pass all **2898 runtime reference checks**. They have not been
integrated into production or benchmarked for a speedup. The overall production
runtime remains the previously validated version.

## Interpretation and priorities

The disassembly confirms both remaining missing declarations and unnecessary
intermediate storage. The strongest next targets are:

1. Finish the declarations on copy/merge helpers and the closure loop index.
2. Port Java's direct output-array construction for array-context merging,
   using packed return-state storage and concrete traversal where possible.
3. Remove generic FIND from the membership hot path and compact merge-cache
   entries, while keeping collision-safe equality and existing cache lifetimes.

Do not count cold error stubs or allocation slow-path trampolines as operations
executed on every call. For example, closure-work's 16-byte bignum allocation
stub is guarded by an overflow branch; ordinary parser depths do not execute it.
Likewise, existing tagged integer arithmetic does not imply per-operation heap
boxing. Static disassembly identifies mechanisms; timing and profiles must still
establish which changes improve real workloads.

## Reproduction

```sh
XDG_CACHE_HOME=/tmp/cnvrs-disassembly-cache /path/to/sbcl --script bench/java-reference/disassemble.lisp
XDG_CACHE_HOME=/tmp/cnvrs-disassembly-cache /path/to/sbcl --script bench/java-reference/disassembly-experiments.lisp
XDG_CACHE_HOME=/tmp/cnvrs-disassembly-cache /path/to/sbcl --script bench/java-reference/disassembly-checks.lisp
PROFILE_MODE=operations XDG_CACHE_HOME=/tmp/cnvrs-disassembly-cache \
  /path/to/sbcl --dynamic-space-size 2048 --script bench/java-reference/disassembly-counts.lisp \
  test/fixtures/runtime/Java8Lexer.g4 test/fixtures/runtime/Java8Parser.g4
```

[Static summary](disassembly-results/summary.json),
[storage-operation counts](disassembly-results/storage-summary.json),
[raw count run](disassembly-results/storage-counts.txt), and
[diagnostic test result](disassembly-results/diagnostic-checks.txt) are saved.
