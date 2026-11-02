ANTLRv4Lexer.g4 and ANTLRv4Parser.g4 are copied from
https://github.com/antlr/grammars-v4/tree/master/antlr/antlr4
for offline integration tests. Their BSD license notices are preserved in
the files.

JSON.g4 is copied unchanged from
https://github.com/antlr/grammars-v4/blob/master/json/JSON.g4
for conversion and parser integration tests. It has no embedded actions or
predicates. Its negated character range exercises the lexer conversion path.

IRI.g4 is copied unchanged from
https://github.com/antlr/grammars-v4/blob/753536777d827ccc0c9b108531ea67375c2039ac/iri/IRI.g4
for parser prediction tests. The file's MIT license notice is preserved.
