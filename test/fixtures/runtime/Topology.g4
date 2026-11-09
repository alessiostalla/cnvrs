grammar Topology;
s : piece* EOF;
piece : ID (COMMA ID)+ SEMI | (A | B)? ID SEMI | (A B | A C)+ SEMI | expr SEMI | ~ (A|B) ID SEMI | . SEMI;
expr : left=expr STAR right=expr #multiply
     | <assoc=right> left=expr POWER right=expr #power
     | left=expr PLUS right=expr #add
     | MINUS expr #negative
     | OPEN expr CLOSE #group
     | value=ID #name;
empty : (A | ) B? EOF;
guards : {true}? A {System.nanoTime();} | B;
guard2 : {true}? B | C;
post : post A | post PLUS post | ID;
ternary : ternary QUESTION ternary COLON ternary | ternary STAR ternary | ID;
labels : pair=(A|B) (item+=ID)* (x=A | x=B);
A:'a'; B:'b'; C:'c'; COMMA:','; SEMI:';'; STAR:'*'; POWER:'^'; PLUS:'+'; MINUS:'-'; OPEN:'('; CLOSE:')';
QUESTION:'?'; COLON:':';
ID : [x-z]+;
WS : [ \r\n\t]+ -> skip;
