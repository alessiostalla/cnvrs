import java.nio.file.*;
import java.util.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.*;

/** Instrumentation only: never use these classes for timing. ANTLR 4.13.2. */
public final class Operations extends ParserATNSimulator {
    static boolean enabled;
    static int[] logicalPositions;
    static final Map<String,Long> counts=new TreeMap<>();
    static final List<String> sequence=new ArrayList<>();
    static void bump(String key,long n){if(enabled)counts.merge(key,n,Long::sum);}
    Operations(Parser parser, ATN atn, DFA[] dfas, PredictionContextCache cache){super(parser,atn,dfas,cache);}
    @Override public int adaptivePredict(TokenStream input,int decision,ParserRuleContext outer){
        bump("ADAPTIVE",1); if(enabled)sequence.add("PREDICT "+decision+" "+logicalPositions[input.index()]);
        return super.adaptivePredict(input,decision,outer);
    }
    @Override protected ATNConfigSet computeStartState(ATNState state,RuleContext context,boolean full){
        bump("START",1);if(full)bump("FULL-START",1);return super.computeStartState(state,context,full);
    }
    @Override protected ATNConfigSet computeReachSet(ATNConfigSet closure,int token,boolean full){
        bump("REACH",1);bump("REACH-INPUT",closure.size());if(full)bump("FULL-REACH",1);
        ATNConfigSet reach=super.computeReachSet(closure,token,full);
        if(reach!=null)bump("REACH-OUTPUT",reach.size());return reach;
    }
    @Override protected void closureCheckingStopState(ATNConfig c,ATNConfigSet set,Set<ATNConfig> busy,boolean collect,boolean full,int depth,boolean eof){
        bump("CLOSURE-CHECK",1);super.closureCheckingStopState(c,set,busy,collect,full,depth,eof);
    }
    @Override protected void closure_(ATNConfig c,ATNConfigSet set,Set<ATNConfig> busy,boolean collect,boolean full,int depth,boolean eof){
        bump("CLOSURE-WORK",1);super.closure_(c,set,busy,collect,full,depth,eof);
    }
    @Override protected ATNConfig getEpsilonTarget(ATNConfig c,Transition t,boolean collect,boolean inContext,boolean full,boolean eof){
        bump("EPSILON",1);return super.getEpsilonTarget(c,t,collect,inContext,full,eof);
    }
    @Override protected int execATNWithFullContext(DFA d,DFAState s,ATNConfigSet start,TokenStream input,int index,ParserRuleContext outer){
        bump("FALLBACK",1);return super.execATNWithFullContext(d,s,start,input,index,outer);
    }
    public static void main(String[] args)throws Exception{
        String source=Files.readString(Path.of(args[0]));
        CLexer lexer=new CLexer(CharStreams.fromString(source));
        CommonTokenStream tokens=new CommonTokenStream(lexer);tokens.fill();
        logicalPositions=new int[tokens.size()];
        int logical=0;
        for(int i=0;i<tokens.size();i++) {
            logicalPositions[i]=logical;
            if(tokens.get(i).getType()!=Token.EOF && tokens.get(i).getChannel()==Token.DEFAULT_CHANNEL) logical++;
        }
        CParser parser=new CParser(tokens);parser.setBuildParseTree(false);
        parser.removeErrorListeners();parser.addErrorListener(new BaseErrorListener(){
            @Override public void syntaxError(Recognizer<?,?> r,Object s,int l,int c,String m,RecognitionException e){throw new AssertionError(m);}
        });
        ATN atn=parser.getATN();DFA[] dfas=new DFA[atn.getNumberOfDecisions()];
        for(int i=0;i<dfas.length;i++)dfas[i]=new DFA(atn.getDecisionState(i),i);
        Operations sim=new Operations(parser,atn,dfas,new PredictionContextCache());parser.setInterpreter(sim);
        for(int i=0;i<20;i++){tokens.seek(0);parser.reset();parser.compilationUnit();}
        tokens.seek(0);parser.reset();enabled=true;
        parser.compilationUnit();enabled=false;
        if(tokens.LA(1)!=Token.EOF||parser.getNumberOfSyntaxErrors()!=0)throw new AssertionError("Incomplete parse");
        for(var e:counts.entrySet())System.out.println("COUNT "+e.getKey()+" "+e.getValue());
        for(String call:sequence)System.out.println(call);
        int states=0;for(DFA d:dfas)states+=d.states.size();
        System.out.println("DFA STATES "+states);
        System.out.println("CONTEXTS "+sim.getSharedContextCache().size());
    }
}
