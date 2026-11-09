lexer grammar LexerCaseParity;
options { caseInsensitive = true; }
EXACT options { caseInsensitive = false; } : 'Exact';
WORD : 'ab';
RANGE : 'c'..'f'+;
SET : [X-Z]+;
CARET : [^a];
PROPERTY : [\p{Lu}]+;
NEGATED : ~('a' | 'b' | 'c'..'f' | [\p{Ll}X-Z])+;
EMOJI : [\u{1F642}-\u{1F644}];
WS : [ \r\n\t]+ -> skip;
OTHER : .;
