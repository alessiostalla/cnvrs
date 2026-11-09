import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.*;
public class RuntimeOracle {
 static String kind(ATNState s) {
  if(s instanceof RuleStopState)return ":rule-stop";
  if(s instanceof RuleStartState)return ":rule-start";
  if(s instanceof StarLoopEntryState)return ":star-loop-entry";
  if(s instanceof BlockEndState)return ":block-end";
  if(s instanceof BlockStartState)return ":block-start";
  if(s instanceof LoopEndState)return ":loop-end";
  return ":basic";
 }
 static String edges(ATNState s) {
  StringBuilder b=new StringBuilder("(");
  for(Transition t:s.getTransitions()) {
   String k,label="nil",follow="nil",outer="-1",dependent="nil";
   if(t instanceof RuleTransition){k=":rule";follow=""+((RuleTransition)t).followState.stateNumber;}
   else if(t instanceof EpsilonTransition){k=":epsilon";outer=""+((EpsilonTransition)t).outermostPrecedenceReturn();}
   else if(t instanceof PrecedencePredicateTransition){k=":precedence";label=""+((PrecedencePredicateTransition)t).precedence;}
   else if(t instanceof PredicateTransition){k=":predicate";PredicateTransition p=(PredicateTransition)t;label="(:predicate "+p.ruleIndex+" "+p.predIndex+" "+(p.isCtxDependent?"t":"nil")+")";dependent=p.isCtxDependent?"t":"nil";}
   else if(t instanceof ActionTransition){k=":action";}
   else if(t instanceof AtomTransition){k=":atom";label=""+((AtomTransition)t).label;}
   else if(t instanceof WildcardTransition){k=":wildcard";}
   else {k=t instanceof NotSetTransition?":not-set":":set";StringBuilder l=new StringBuilder("(");for(int n:t.label().toArray())l.append(n).append(' ');label=l.append(')').toString();}
   b.append('(').append(k).append(' ').append(t.target.stateNumber).append(' ').append(follow).append(' ').append(label).append(' ').append(outer).append(' ').append(dependent).append(") ");
  }return b.append(')').toString();
 }
 static class Trace extends ParserATNSimulator {
  Trace(Parser p,ATN a){super(p,a,new DFA[a.getNumberOfDecisions()],new PredictionContextCache());for(int i=0;i<decisionToDFA.length;i++)decisionToDFA[i]=new DFA(a.getDecisionState(i),i);String mode=System.getenv("ORACLE_MODE");if(mode!=null)setPredictionMode(PredictionMode.valueOf(mode));}
  @Override public int adaptivePredict(TokenStream in,int decision,ParserRuleContext outer){
   int start=in.index(),prec=parser.getPrecedence();StringBuilder stack=new StringBuilder("(");
   for(RuleContext c=outer;c!=null&&c.parent!=null;c=c.parent){RuleTransition t=(RuleTransition)atn.states.get(c.invokingState).transition(0);stack.append(t.followState.stateNumber).append(' ');}
   stack.append(')');int alt;try{alt=super.adaptivePredict(in,decision,outer);}catch(NoViableAltException e){System.out.println("(:no-viable "+decision+" "+start+" "+prec+" "+stack+" "+e.getOffendingToken().getTokenIndex()+")");throw e;}System.out.println("(:predict "+decision+" "+start+" "+prec+" "+stack+" "+alt+")");return alt;
  }
 }
 public static void main(String[] args)throws Exception{
  Class<?> pc=Class.forName(args.length>0?args[0]:"RuntimeParityParser"),lc=Class.forName(args.length>1?args[1]:"RuntimeParityLexer");ATN a=((Parser)pc.getConstructor(TokenStream.class).newInstance((Object)null)).getATN();System.out.println("(:atn "+a.maxTokenType+" (");
  for(ATNState s:a.states){if(s==null){System.out.println("nil");continue;}
   boolean lr=s instanceof RuleStartState&&((RuleStartState)s).isLeftRecursiveRule,pd=s instanceof StarLoopEntryState&&((StarLoopEntryState)s).isPrecedenceDecision;
   int end=s instanceof BlockStartState?((BlockStartState)s).endState.stateNumber:-1;
   System.out.println("("+kind(s)+" "+s.ruleIndex+" "+(lr?"t":"nil")+" "+(pd?"t":"nil")+" "+end+" "+edges(s)+")");}
  System.out.print(") (");for(RuleStopState s:a.ruleToStopState)System.out.print(s.stateNumber+" ");System.out.print(") (");for(DecisionState s:a.decisionToState)System.out.print(s.stateNumber+" ");System.out.println("))");
  String[] sources={"type Foo x;","type Foo[] x;","ctx a b;","ctx a b b;","opt x;","opt x y;","expr x+y*z;","expr (x+y)*z;","expr f(x,y+z);","nest {type Foo x; expr f(g(x),y+z*w); ctx a b;}","guard x;","guard x;","expr ;","opt ;","ctx a;","type Foo;","wild x q;","except x q;","wild zero q;","except zero q;","wild","except"};
  if(args.length>3)sources=new String[]{java.nio.file.Files.readString(java.nio.file.Path.of(args[3]))};
  System.out.println("(:mode :"+(System.getenv("ORACLE_MODE")==null?"ll":System.getenv("ORACLE_MODE").toLowerCase().replace('_','-'))+")");int caseNumber=0;for(String source:sources){boolean enabled=(caseNumber++%2)==0;Lexer l=(Lexer)lc.getConstructor(CharStream.class).newInstance(CharStreams.fromString(source));CommonTokenStream tokens=new CommonTokenStream(l);tokens.fill();for(Token token:tokens.getTokens())if(token.getText().equals("zero"))((WritableToken)token).setType(0);System.out.print("(:input (");for(Token t:tokens.getTokens())System.out.print(t.getType()+" ");System.out.println(") "+(enabled?"t":"nil")+")");
   Parser p=(Parser)pc.getConstructor(TokenStream.class).newInstance(tokens);try{pc.getField("enabled").setBoolean(p,enabled);}catch(NoSuchFieldException e){}p.setErrorHandler(new BailErrorStrategy());Trace sim=new Trace(p,a);p.setInterpreter(sim);try{pc.getMethod(args.length>2?args[2]:"s").invoke(p);}catch(java.lang.reflect.InvocationTargetException e){if(!(e.getCause() instanceof org.antlr.v4.runtime.misc.ParseCancellationException))throw e;System.out.println("(:parse-error)");}System.out.print("(:dfa-counts (");for(DFA d:sim.decisionToDFA)System.out.print(d.states.size()+" ");System.out.println("))");}
 }
}
