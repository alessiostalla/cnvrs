import java.nio.file.*;
import java.lang.management.ManagementFactory;
import java.util.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;

/** Matched lexer, parser and pipeline measurements; ANTLR Java 4.13.2. */
public final class Benchmark {
    static volatile Object sink;
    static String source;
    static CommonTokenStream prepared;
    static ATN lexerATN, parserATN;
    static DFA[] lexerDFA, parserDFA;
    static PredictionContextCache contexts;
    static int expected;
    static final com.sun.management.ThreadMXBean allocation =
        (com.sun.management.ThreadMXBean) ManagementFactory.getThreadMXBean();
    static final BaseErrorListener errors = new BaseErrorListener() {
        @Override public void syntaxError(Recognizer<?,?> r,Object s,int l,int c,String m,RecognitionException e) {
            throw new AssertionError(l+":"+c+" "+m);
        }
    };
    static long bytes() { return allocation.getThreadAllocatedBytes(Thread.currentThread().threadId()); }
    static DFA[] dfas(ATN atn) {
        DFA[] result = new DFA[atn.getNumberOfDecisions()];
        for(int i=0;i<result.length;i++) result[i]=new DFA(atn.getDecisionState(i),i);
        return result;
    }
    static void clear() {lexerDFA=dfas(lexerATN);parserDFA=dfas(parserATN);contexts=new PredictionContextCache();}
    static CommonTokenStream lex() {
        Lexer lexer=new TSqlLexer(CharStreams.fromString(source));
        lexer.removeErrorListeners();lexer.addErrorListener(errors);
        lexer.setInterpreter(new LexerATNSimulator(lexer,lexerATN,lexerDFA,new PredictionContextCache()));
        CommonTokenStream stream=new CommonTokenStream(lexer);stream.fill();
        if(expected>=0 && stream.size()-1!=expected)throw new AssertionError("Token count "+stream.size());
        sink=stream;return stream;
    }
    static void parse(CommonTokenStream stream,boolean tree) {
        stream.seek(0);
        Parser parser=new TSqlParser(stream);
        parser.removeErrorListeners();parser.addErrorListener(errors);
        parser.setBuildParseTree(tree);
        parser.setInterpreter(new ParserATNSimulator(parser,parserATN,parserDFA,contexts));
        ParserRuleContext result=((TSqlParser)parser).tsql_file();
        if(parser.getNumberOfSyntaxErrors()!=0 || stream.LA(1)!=Token.EOF)throw new AssertionError("Incomplete parse");
        sink=result;
    }
    static void run(String phase) {
        switch(phase) {
        case "lexer":lex();break;
        case "parse-none":parse(prepared,false);break;
        case "parse-tree":parse(prepared,true);break;
        case "pipeline-tree":parse(lex(),true);break;
        default:throw new AssertionError(phase);
        }
    }
    static long mix(long hash,long n){return (hash^n)*0x100000001b3L;}
    static String signature(CommonTokenStream stream){
        long hash=0xcbf29ce484222325L;
        for(Token t:stream.getTokens())if(t.getType()!=Token.EOF){
            for(int c:t.getText().codePoints().toArray())hash=mix(hash,c);
            for(long n:new long[]{0xffffffffL,t.getStartIndex(),t.getStopIndex()+1,t.getLine(),t.getCharPositionInLine(),t.getChannel()})hash=mix(hash,n);
        }
        return String.format("%016X",hash);
    }
    static String kindSignature(CommonTokenStream stream) {
        long hash=0xcbf29ce484222325L;
        for(Token t:stream.getTokens())if(t.getType()!=Token.EOF) {
            for(int c:(TSqlLexer.VOCABULARY.getSymbolicName(t.getType()).toUpperCase(Locale.ROOT)).codePoints().toArray())hash=mix(hash,c);
            hash=mix(hash,0xffffffffL);
        }
        return String.format("%016X",hash);
    }
    static void caches(String phase) {
        int ls=0,ps=0,le=0;
        for(DFA d:lexerDFA)for(var s:d.states.keySet()){ls++;if(s.edges!=null)for(var e:s.edges)if(e!=null)le++;}
        for(DFA d:parserDFA)ps+=d.states.size();
        System.out.printf("CACHE %s LEXER-STATES %d LEXER-EDGES %d PARSER-STATES %d CONTEXTS %d%n",phase,ls,le,ps,contexts.size());
    }
    public static void main(String[] args)throws Exception {
        Locale.setDefault(Locale.ROOT);source=Files.readString(Path.of(args[1]));
        lexerATN=(new TSqlLexer(CharStreams.fromString(""))).getATN();
        parserATN=(new TSqlParser(null)).getATN();
        expected=-1;clear();prepared=lex();expected=prepared.size()-1;
        System.out.printf("TOPOLOGY LEXER-RULES %d LEXER-STATES %d PARSER-RULES %d PARSER-STATES %d DECISIONS %d%n",lexerATN.ruleToStartState.length,lexerATN.states.size(),parserATN.ruleToStartState.length,parserATN.states.size(),parserATN.getNumberOfDecisions());
        System.out.printf("RUNTIME JAVA %s GRAMMAR %s CHARACTERS %d TOKENS %d%n",System.getProperty("java.version"),args[0],source.codePointCount(0,source.length()),expected);
        System.out.printf("DEFAULT-TOKENS %d%n", prepared.getTokens().stream().filter(t -> t.getType()!=Token.EOF && t.getChannel()==0).count());
        System.out.println("SIGNATURE "+signature(prepared));
        System.out.println("KIND-SIGNATURE "+kindSignature(prepared));
        for(String phase:new String[]{"lexer","parse-none","parse-tree","pipeline-tree"}) {
            clear();long b=bytes(),start=System.nanoTime();run(phase);
            System.out.printf("FIRST %s MS %.6f BYTES %d%n",phase,(System.nanoTime()-start)/1e6,bytes()-b);
            long warmup=System.nanoTime();int n=0;
            do{run(phase);n++;}while(n<2000 && System.nanoTime()-warmup<5_000_000_000L);
            System.out.printf("WARMUP %s ITERATIONS %d MS %.3f%n",phase,n,(System.nanoTime()-warmup)/1e6);
            for(int trial=1;trial<=3;trial++) {
                clear();System.gc();b=bytes();start=System.nanoTime();run(phase);
                System.out.printf("COLD %s TRIAL %d MS %.6f BYTES %d%n",phase,trial,(System.nanoTime()-start)/1e6,bytes()-b);
            }
            // Train once after the final cold measurement, then use matching batch sizes in Lisp.
            run(phase);int iterations=phase.equals("lexer")?100:2;
            for(int batch=1;batch<=7;batch++) {
                b=bytes();start=System.nanoTime();for(int i=0;i<iterations;i++)run(phase);
                System.out.printf("WARM %s BATCH %d MS %.6f BYTES %.1f%n",phase,batch,(System.nanoTime()-start)/1e6/iterations,(bytes()-b)/(double)iterations);
            }
            caches(phase);
        }
    }
}
