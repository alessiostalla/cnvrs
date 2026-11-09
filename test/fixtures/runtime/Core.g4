grammar Core;
s : piece* EOF;
piece : ID (COMMA ID)+ SEMI | (A | B)? ID SEMI | (A B | A C)+ SEMI | expr SEMI | ~ (A|B) ID SEMI | . SEMI;
expr : left=expr STAR right=expr #multiply
     | <assoc=right> left=expr POWER right=expr #power
     | left=expr PLUS right=expr #add
     | MINUS expr #negative
     | OPEN expr CLOSE #group
     | value=ID #name;
A:'a'; B:'b'; C:'c'; COMMA:','; SEMI:';'; STAR:'*'; POWER:'^'; PLUS:'+'; MINUS:'-'; OPEN:'('; CLOSE:')';
ID : [x-z]+;
WS : [ \r\n\t]+ -> skip;
