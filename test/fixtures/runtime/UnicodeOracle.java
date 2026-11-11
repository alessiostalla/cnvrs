import java.lang.reflect.*;
import java.util.*;
import org.antlr.v4.unicode.UnicodeData;
import org.antlr.v4.runtime.misc.*;
/** Regenerate src/unicode-data.sexp using ANTLR 4.13.2 and JDK 24. */
public final class UnicodeOracle {
 public static void main(String[] args) throws Exception {
  Field properties=UnicodeData.class.getDeclaredField("propertyCodePointRanges");
  Field aliases=UnicodeData.class.getDeclaredField("propertyAliases");
  properties.setAccessible(true); aliases.setAccessible(true);
  Map<String,IntervalSet> p=(Map<String,IntervalSet>)properties.get(null);
  Map<String,String> a=(Map<String,String>)aliases.get(null);
  System.out.println(";; ANTLR 4.13.2 UnicodeData; Java "+System.getProperty("java.version")+" simple case mappings.\n;; Copyright (c) The ANTLR Project. See runtime/LICENSE.txt.\n(:properties (");
  for(String key:new TreeSet<>(p.keySet())) {
   System.out.print("(\""+key+"\" (");
   for(Interval i:p.get(key).getIntervals())System.out.print("("+i.a+" "+i.b+") ");
   System.out.println("))");
  }
  System.out.println(") :aliases (");
  for(String key:new TreeSet<>(a.keySet()))System.out.println("(\""+key+"\" \""+a.get(key)+"\")");
  System.out.println(") :cases (");
  for(int c=0;c<=0x10ffff;c++) {
   int lower=Character.toLowerCase(c),upper=Character.toUpperCase(c);
   if(lower!=c||upper!=c)System.out.println("("+c+" ("+lower+" "+upper+"))");
  }
  System.out.println("))");
 }
}
