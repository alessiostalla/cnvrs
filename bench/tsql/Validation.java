import java.nio.file.*;
import java.util.*;
import org.antlr.v4.runtime.*;

/** Token-stream and strict EOF validation against ANTLR Java 4.13.2. */
public final class Validation {
    static final BaseErrorListener errors = new BaseErrorListener() {
        @Override public void syntaxError(Recognizer<?,?> r,Object s,int l,int c,String m,RecognitionException e) {
            throw new AssertionError(l+":"+c+" "+m);
        }
    };
    static long mix(long h,long n) {return (h^n)*0x100000001b3L;}
    static String signature(CommonTokenStream tokens,boolean kinds) {
        long h=0xcbf29ce484222325L;
        for(Token t:tokens.getTokens())if(t.getType()!=Token.EOF) {
            String text=kinds?TSqlLexer.VOCABULARY.getSymbolicName(t.getType()).toUpperCase(Locale.ROOT):t.getText();
            for(int c:text.codePoints().toArray())h=mix(h,c);
            h=mix(h,0xffffffffL);
            if(!kinds)for(long n:new long[]{t.getStartIndex(),t.getStopIndex()+1,t.getLine(),t.getCharPositionInLine(),t.getChannel()})h=mix(h,n);
        }
        return String.format("%016X",h);
    }
    public static void main(String[] args)throws Exception {
        for(String arg:args) {
            String text=Files.readString(Path.of(arg));
            var lexer=new TSqlLexer(CharStreams.fromString(text));
            lexer.removeErrorListeners();lexer.addErrorListener(errors);
            var tokens=new CommonTokenStream(lexer);tokens.fill();
            var parser=new TSqlParser(tokens);
            parser.removeErrorListeners();parser.addErrorListener(errors);
            parser.tsql_file();
            if(tokens.LA(1)!=Token.EOF)throw new AssertionError("Incomplete parse");
            long count=tokens.getTokens().stream().filter(t->t.getType()!=Token.EOF && t.getChannel()==0).count();
            System.out.printf("INPUT %s CHARACTERS %d TOKENS %d DEFAULT %d SIGNATURE %s KINDS %s%n",Path.of(arg).getFileName(),text.codePointCount(0,text.length()),tokens.size()-1,count,signature(tokens,false),signature(tokens,true));
        }
    }
}
