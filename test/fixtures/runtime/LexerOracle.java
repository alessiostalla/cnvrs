import java.util.*;import java.lang.reflect.*;import org.antlr.v4.runtime.*;import org.antlr.v4.runtime.atn.*;import org.antlr.v4.runtime.dfa.*;import org.antlr.v4.runtime.misc.*;
public class LexerOracle {
 static String str(String s){return "\""+s.replace("\\","\\\\").replace("\"","\\\"")+"\"";}
 static int num(ATNState s){return s==null?-1:s.stateNumber;}
 static String kind(ATNState s){return new String[]{":invalid",":basic",":rule-start",":block-start",":plus-block-start",":star-block-start",":token-start",":rule-stop",":block-end",":star-loop-back",":star-loop-entry",":plus-loop-back",":loop-end"}[s.getStateType()];}
 static String intervals(IntervalSet s){String r="(";for(Interval i:s.getIntervals())r+="("+i.a+" "+i.b+") ";return r+")";}
 static String action(LexerAction a,Lexer l){
  if(a instanceof LexerCustomAction){LexerCustomAction x=(LexerCustomAction)a;return "(:custom "+x.getRuleIndex()+" "+x.getActionIndex()+")";}
  if(a instanceof LexerTypeAction)return "(:type "+str(l.getVocabulary().getSymbolicName(((LexerTypeAction)a).getType()))+")";
  if(a instanceof LexerChannelAction)return "(:channel "+str(l.getChannelNames()[((LexerChannelAction)a).getChannel()])+")";
  if(a instanceof LexerModeAction)return "(:mode "+str(l.getModeNames()[((LexerModeAction)a).getMode()])+")";
  if(a instanceof LexerPushModeAction)return "(:push-mode "+str(l.getModeNames()[((LexerPushModeAction)a).getMode()])+")";
  if(a instanceof LexerPopModeAction)return "(:pop-mode)";
  if(a instanceof LexerMoreAction)return "(:more)";
  return "(:skip)";
 }
 public static void main(String[] args)throws Exception {
  System.setOut(new java.io.PrintStream(System.out,true,"UTF-8"));
  Class<?> cls=Class.forName(args.length>0?args[0]:"LexerParity");Lexer l=(Lexer)cls.getConstructor(CharStream.class).newInstance(CharStreams.fromString(""));ATN a=l.getATN();
  System.out.print("(:vocabulary (");for(int i=1;i<=a.maxTokenType;i++)System.out.print("("+i+" "+str(l.getVocabulary().getSymbolicName(i))+") ");System.out.println("))");
  System.out.println("(:states (");for(ATNState s:a.states){
   int end=s instanceof BlockStartState?num(((BlockStartState)s).endState):-1,back=s instanceof StarLoopEntryState?num(((StarLoopEntryState)s).loopBackState):s instanceof PlusBlockStartState?num(((PlusBlockStartState)s).loopBackState):s instanceof LoopEndState?num(((LoopEndState)s).loopBackState):-1;
   System.out.print("("+kind(s)+" "+s.ruleIndex+" "+(s instanceof DecisionState&&((DecisionState)s).nonGreedy?"t":"nil")+" "+end+" "+back+" "+(s instanceof DecisionState?((DecisionState)s).decision:-1)+" (");
   for(Transition t:s.getTransitions()){
    String k,label="nil";int follow=-1;
    if(t instanceof RuleTransition){k=":rule";follow=num(((RuleTransition)t).followState);}
    else if(t instanceof EpsilonTransition)k=":epsilon";
    else if(t instanceof ActionTransition){k=":action";label=""+((ActionTransition)t).actionIndex;}
    else if(t instanceof PredicateTransition){k=":predicate";PredicateTransition p=(PredicateTransition)t;label="("+p.ruleIndex+" "+p.predIndex+" "+(p.isCtxDependent?"t":"nil")+")";}
    else if(t instanceof AtomTransition){k=":atom";label=""+((AtomTransition)t).label;}
    else if(t instanceof RangeTransition){k=":range";label="("+((RangeTransition)t).from+" "+((RangeTransition)t).to+")";}
    else if(t instanceof WildcardTransition)k=":wildcard";
    else {k=t instanceof NotSetTransition?":not-set":":set";label=intervals(t.label());}
    System.out.print("("+k+" "+num(t.target)+" "+follow+" "+label+") ");
   }System.out.println("))");
  }System.out.println("))");
  System.out.print("(:decisions (");for(DecisionState s:a.decisionToState)System.out.print(num(s)+" ");System.out.println("))");
  System.out.print("(:modes (");for(TokensStartState s:a.modeToStartState)System.out.print(num(s)+" ");System.out.println("))");
  System.out.print("(:actions (");for(LexerAction x:a.lexerActions)System.out.print(action(x,l)+" ");System.out.println("))");
  System.out.print("(:rule-types (");for(int t:a.ruleToTokenType)System.out.print(t+" ");System.out.println("))");
  String[] inputs={"if iffy 123", "<a>b> [a]b]", "{a{b}c}", "!x", "!x", "@abc %q", "\u03b1\u03b2 \ud83d\ude42 ^", "\"a\\\"b\" if", "// hi\nif\t123", "", "?if", "<unterminated", "\"unterminated", "!", "!\nif", ":y :z", ":y :z", ":\ny"};
  if(args.length>1)inputs=new String[]{java.nio.file.Files.readString(java.nio.file.Path.of(args[1]))};
  int caseNo=0;
  for(String input:inputs){boolean enabled=(caseNo++%2)==0;Lexer lexer=(Lexer)cls.getConstructor(CharStream.class).newInstance(CharStreams.fromString(input));List<String> errors=new ArrayList<>();
   try{cls.getField("enabled").setBoolean(lexer,enabled);}catch(NoSuchFieldException e){}
   lexer.removeErrorListeners();lexer.addErrorListener(new BaseErrorListener(){public void syntaxError(Recognizer<?,?> r,Object symbol,int line,int col,String msg,RecognitionException e){errors.add("("+lexer._tokenStartCharIndex+" "+lexer.getCharIndex()+" "+line+" "+col+")");}});
   System.out.println("(:input "+str(input)+" "+(enabled?"t":"nil")+")");
   for(;;){Token t=lexer.nextToken();String type=t.getType()==Token.EOF?"EOF":lexer.getVocabulary().getSymbolicName(t.getType());System.out.println("(:token "+str(type)+" "+str(t.getText())+" "+t.getStartIndex()+" "+(t.getStopIndex()+1)+" "+t.getLine()+" "+t.getCharPositionInLine()+" "+str(lexer.getChannelNames()[t.getChannel()])+")");if(t.getType()==Token.EOF)break;}
   System.out.print("(:errors (");for(String e:errors)System.out.print(e+" ");System.out.println("))");
   System.out.print("(:events (");try{for(String e:(List<String>)cls.getField("events").get(lexer))System.out.print(e+" ");}catch(NoSuchFieldException e){}System.out.println("))");
   System.out.print("(:dfa (");for(DFA d:lexer.getInterpreter().decisionToDFA){int edges=0;for(DFAState s:d.states.keySet())if(s.edges!=null)for(DFAState target:s.edges)if(target!=null)edges++;System.out.print("("+d.states.size()+" "+edges+") ");}System.out.println("))");
  }
 }
}
