grammar RuntimeParity;
@members { public boolean enabled = true; }
s : statement* EOF;
statement : 'type' typename ID ';' | 'expr' expr ';' | 'ctx' a 'b' ';' | 'opt' ID? ID ';' | 'nest' block | 'guard' guarded ';' | 'wild' wild ';' | 'except' excluding ';';
wild : . 'q' | ID 'r';
excluding : ~('a'|'b') 'q' | ID 'r';
guarded : {enabled}? ID | ID;
typename : ID | ID | ID '[' ']';
a : 'a' | 'a' 'b';
expr : expr '*' expr | expr '+' expr | '(' expr ')' | ID ('(' args? ')')?;
args : expr (',' expr)*;
block : '{' statement* '}';
ID : [a-zA-Z_][a-zA-Z_0-9]*;
WS : [ \r\n\t]+ -> skip;
