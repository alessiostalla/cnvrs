import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.misc.DoubleKeyMap;
import java.util.*;
public class ContextOracle {
 static PredictionContext stack(List<Integer> s){PredictionContext p=EmptyPredictionContext.Instance;for(int i=s.size()-1;i>=0;i--)p=SingletonPredictionContext.create(p,s.get(i));return p;}
 static String paths(PredictionContext c){StringBuilder b=new StringBuilder("(");for(List<Integer> p:enumerate(c)){b.append('(');for(int n:p)b.append(n).append(' ');b.append(") ");}return b.append(')').toString();}
 static List<List<Integer>> enumerate(PredictionContext c){List<List<Integer>> out=new ArrayList<>();if(c.isEmpty()){out.add(new ArrayList<>());return out;}for(int i=0;i<c.size();i++){if(c.getReturnState(i)==PredictionContext.EMPTY_RETURN_STATE){out.add(new ArrayList<>());continue;}for(List<Integer> tail:enumerate(c.getParent(i))){List<Integer> p=new ArrayList<>();p.add(c.getReturnState(i));p.addAll(tail);out.add(p);}}return out;}
 public static void main(String[] args){Random r=new Random(4132);for(boolean wildcard:new boolean[]{false,true})for(int n=0;n<128;n++){
  List<List<Integer>> inputs=new ArrayList<>();for(int k=0;k<2+r.nextInt(6);k++){List<Integer> p=new ArrayList<>();for(int j=0,depth=r.nextInt(7);j<depth;j++)p.add(1+r.nextInt(5));inputs.add(p);}
  DoubleKeyMap<PredictionContext,PredictionContext,PredictionContext> cache=new DoubleKeyMap<>();PredictionContext c=stack(inputs.get(0));for(int k=1;k<inputs.size();k++)c=PredictionContext.merge(c,stack(inputs.get(k)),wildcard,cache);
  System.out.print("("+(wildcard?"t":"nil")+" (");for(List<Integer> p:inputs){System.out.print('(');for(int x:p)System.out.print(x+" ");System.out.print(") ");}System.out.println(") "+Integer.toUnsignedString(c.hashCode())+" "+paths(c)+")");
 }}
}
