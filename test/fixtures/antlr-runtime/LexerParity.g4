lexer grammar LexerParity;
tokens { STRING }
channels { COMMENTS }
@members {
 public boolean enabled = true;
 public java.util.List<String> events = new java.util.ArrayList<>();
 boolean after() { event(6); return enabled; }
 void event(int n) { events.add("("+n+" "+getCharIndex()+" "+getLine()+" "+getCharPositionInLine()+")"); }
}
KW : 'if';
ID : [a-z]+;
NUMBER : [0-9]+;
SHORT : '<' .*? '>';
LONG : '[' .+? ']';
NEST : '{' (NEST | ~[{}])* '}';
GUARD : {enabled}? '!' 'x' {event(1);};
FALL : '!' .;
MID : '@' {event(2);} [a-z]+ {event(3);};
fragment PART : 'q' {event(4);};
REF : '%' PART {event(5);};
CARET : [^a];
UNICODE : [\p{L}]+;
EMOJI : '\u{1F642}';
QUOTE : '"' -> more, pushMode(STR);
SPACE : [ \t\r\n]+ -> skip;
COMMENT : '//' ~[\r\n]* -> channel(COMMENTS);
EOF_TOKEN : EOF;
AFTER : ':' {after()}? 'y';
AFTER_FALL : ':' .;
mode STR;
END : '"' -> type(STRING), popMode;
TEXT : ~["\\]+ -> more;
ESC : '\\' . -> more;
