import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
public class TopologyOracle {
 static String kind(ATNState s) {return new String[]{":invalid",":basic",":rule-start",":block-start",":plus-block-start",":star-block-start",":token-start",":rule-stop",":block-end",":star-loop-back",":star-loop-entry",":plus-loop-back",":loop-end"}[s.getStateType()];}
 static int number(ATNState s){return s==null?-1:s.stateNumber;}
 public static void main(String[] args)throws Exception{
  Parser p=(Parser)Class.forName(args[0]).getConstructor(TokenStream.class).newInstance((Object)null);ATN a=p.getATN();
  System.out.print("(:vocabulary (");for(int i=1;i<=a.maxTokenType;i++){String name=p.getVocabulary().getSymbolicName(i); if(name!=null)System.out.print("("+i+" \""+name+"\") ");}System.out.println("))");
  System.out.println("(:states (");
  for(ATNState s:a.states){
   int end=s instanceof BlockStartState?number(((BlockStartState)s).endState):-1;
   int back=s instanceof StarLoopEntryState?number(((StarLoopEntryState)s).loopBackState):s instanceof PlusBlockStartState?number(((PlusBlockStartState)s).loopBackState):s instanceof LoopEndState?number(((LoopEndState)s).loopBackState):-1;
   System.out.print("("+kind(s)+" "+s.ruleIndex+" "+(s instanceof RuleStartState&&((RuleStartState)s).isLeftRecursiveRule?"t":"nil")+" "+(s instanceof StarLoopEntryState&&((StarLoopEntryState)s).isPrecedenceDecision?"t":"nil")+" "+end+" "+back+" "+(s instanceof DecisionState?((DecisionState)s).decision:-1)+" (");
   for(Transition t:s.getTransitions()){
    String type,label="nil";int follow=-1,outer=-1,prec=0;
    if(t instanceof RuleTransition){type=":rule";follow=number(((RuleTransition)t).followState);prec=((RuleTransition)t).precedence;}
    else if(t instanceof EpsilonTransition){type=":epsilon";outer=((EpsilonTransition)t).outermostPrecedenceReturn();}
    else if(t instanceof PrecedencePredicateTransition){type=":precedence";label=""+((PrecedencePredicateTransition)t).precedence;}
    else if(t instanceof PredicateTransition){type=":predicate";PredicateTransition q=(PredicateTransition)t;label="("+q.ruleIndex+" "+q.predIndex+" "+(q.isCtxDependent?"t":"nil")+")";}
    else if(t instanceof ActionTransition){type=":action";}
    else if(t instanceof AtomTransition){type=":atom";label=""+((AtomTransition)t).label;}
    else if(t instanceof WildcardTransition){type=":wildcard";}
    else {type=t instanceof NotSetTransition?":not-set":":set";label="(";for(int n:t.label().toArray())label+=n+" ";label+=")";}
    System.out.print("("+type+" "+number(t.target)+" "+follow+" "+label+" "+outer+" "+prec+") ");
   }System.out.println("))");
  }System.out.println("))");
  System.out.print("(:decisions (");for(DecisionState s:a.decisionToState)System.out.print(s.stateNumber+" ");System.out.println("))");
 }
}
