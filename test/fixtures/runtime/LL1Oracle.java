import java.util.*;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.analysis.AnalysisPipeline;
/** Exact runtime LL1Analyzer output, plus generated parser adaptive-decision calls. */
public final class LL1Oracle {
 static String set(IntervalSet s){if(s==null)return "nil";StringBuilder b=new StringBuilder("(");for(int t:s.toArray())b.append(t).append(' ');return b.append(')').toString();}
 static String quoted(String s){return s==null?"nil":"\""+s.replace("\\","\\\\").replace("\"","\\\"")+"\"";}
 static void parseCase(Class<?> cls,String rule,int[] values)throws Exception{
  List<Token> tokens=new ArrayList<>();for(int value:values)tokens.add(new CommonToken(value));tokens.add(new CommonToken(Token.EOF));
  CommonTokenStream input=new CommonTokenStream(new ListTokenSource(tokens));
  Parser p=(Parser)cls.getConstructor(TokenStream.class).newInstance(input);
  p.removeErrorListeners();p.setErrorHandler(new BailErrorStrategy());List<Integer> calls=new ArrayList<>();
  p.setInterpreter(new ParserATNSimulator(p,p.getATN(),p.getInterpreter().decisionToDFA,new PredictionContextCache()){
   @Override public int adaptivePredict(TokenStream in,int d,ParserRuleContext ctx){calls.add(d);return super.adaptivePredict(in,d,ctx);}
  });
  boolean accepted=true;try{cls.getMethod(rule).invoke(p);accepted=input.LA(1)==Token.EOF;}catch(java.lang.reflect.InvocationTargetException e){if(e.getCause() instanceof org.antlr.v4.runtime.misc.ParseCancellationException)accepted=false;else throw e;}
  System.out.print("(:case "+quoted(rule)+" (");for(int v:values)System.out.print(v+" ");System.out.print(") "+(accepted?"t":"nil")+" (");for(int d:calls)System.out.print(d+" ");System.out.println("))");
 }
 public static void main(String[] args)throws Exception{
  System.setOut(new java.io.PrintStream(System.out,true,"UTF-8"));
  Parser p=(Parser)Class.forName(args[0]).getConstructor(TokenStream.class).newInstance((Object)null);
  ATN atn=p.getATN();
  System.out.print("(:vocabulary (");for(int i=1;i<=atn.maxTokenType;i++)System.out.print("("+i+" "+quoted(p.getVocabulary().getSymbolicName(i))+" "+quoted(p.getVocabulary().getLiteralName(i)==null?null:org.antlr.v4.misc.CharSupport.getStringFromGrammarStringLiteral(p.getVocabulary().getLiteralName(i)))+") ");System.out.println("))");
  for(DecisionState s:atn.decisionToState){
   IntervalSet[] look=new LL1Analyzer(atn).getDecisionLookahead(s);
   System.out.print("(:decision "+s.decision+" "+s.stateNumber+" "+(AnalysisPipeline.disjoint(look)?"t":"nil")+" (");
   for(IntervalSet set:look)System.out.print(set(set)+" ");System.out.println("))");
  }
  if(args[0].equals("LL1ParityParser")){
   String[] rules={"choice","choice","optional","optional","optional","star","star","plus","multiStar","multiPlus","nested","nested","nested","nullable","nullable","ambiguous","ambiguous","eofChoice","eofChoice","wild","wild","negated","negated","recursive","recursive","entry","choice","choice","optional","plus","multiPlus","ambiguous","negated"};
   int[][] values={{1,2},{3,4},{5},{1,2,5},{3,4,5},{5},{1,2,1,2,5},{1,2,5},{1,2,3,4,5},{1,2,3,4,5},{6},{8,6},{7},{1},{2},{1,2},{1,3},{},{1},{},{3,2},{3,2},{1,3},{1,1,2},{2},{7},{1},{2},{1,5},{5},{5},{1,4},{1,2}};
   for(int i=0;i<rules.length;i++)parseCase(p.getClass(),rules[i],values[i]);
  }
 }
}
