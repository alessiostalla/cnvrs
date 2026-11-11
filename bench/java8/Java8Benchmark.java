import java.nio.file.*;
import java.lang.management.ManagementFactory;
import java.util.Locale;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;

/** Parse-only comparison: Java 8 grammar, ANTLR 4.13.2, parse trees enabled. */
public final class Java8Benchmark {
    static volatile Object sink;
    static CommonTokenStream tokens;
    static ATN atn;
    static final com.sun.management.ThreadMXBean allocation =
        (com.sun.management.ThreadMXBean) ManagementFactory.getThreadMXBean();
    static long bytes() { return allocation.getThreadAllocatedBytes(Thread.currentThread().threadId()); }
    static DFA[] freshDFA() {
        DFA[] dfas = new DFA[atn.getNumberOfDecisions()];
        for (int i=0; i<dfas.length; i++) dfas[i] = new DFA(atn.getDecisionState(i), i);
        return dfas;
    }
    static void parse(DFA[] dfas, PredictionContextCache contexts) {
        tokens.seek(0);
        Java8Parser parser = new Java8Parser(tokens);
        parser.setBuildParseTree(true);
        parser.setInterpreter(new ParserATNSimulator(parser, atn, dfas, contexts));
        Java8Parser.CompilationUnitContext tree = parser.compilationUnit();
        if (parser.getNumberOfSyntaxErrors()!=0 || tokens.LA(1)!=Token.EOF
                || tree.getStop().getTokenIndex()!=505)
            throw new AssertionError("Incomplete/invalid reference parse");
        sink = tree;
    }
    public static void main(String[] args) throws Exception {
        Locale.setDefault(Locale.ROOT);
        String source = Files.readString(Path.of(args[0]));
        Java8Lexer lexer = new Java8Lexer(CharStreams.fromString(source));
        tokens = new CommonTokenStream(lexer);
        tokens.fill();
        atn = new Java8Parser(tokens).getATN();
        int visible=0;
        for (Token t: tokens.getTokens())
            if (t.getType()!=Token.EOF && t.getChannel()==Token.DEFAULT_CHANNEL) visible++;
        System.out.printf("JAVA %s INPUT CHARACTERS %d TOKENS %d TREE true%n",
            System.getProperty("java.version"), source.length(), visible);
        DFA[] warm = freshDFA();
        PredictionContextCache contexts = new PredictionContextCache();
        long b=bytes(), start=System.nanoTime();
        parse(warm, contexts);
        System.out.printf("FIRST-PARSE MS %.6f BYTES %d END 505%n", (System.nanoTime()-start)/1e6, bytes()-b);
        // Warm HotSpot independently of the cold-DFA measurements.
        long warmupStart=System.nanoTime();
        int warmupIterations=0;
        do { parse(warm, contexts); warmupIterations++; }
        while (warmupIterations<2000 && System.nanoTime()-warmupStart<5_000_000_000L);
        System.out.printf("WARMUP ITERATIONS %d SECONDS %.3f%n",warmupIterations,(System.nanoTime()-warmupStart)/1e9);
        for (int trial=1; trial<=3; trial++) {
            DFA[] cold=freshDFA();
            PredictionContextCache cache=new PredictionContextCache();
            System.gc();
            b=bytes(); start=System.nanoTime();
            parse(cold,cache);
            System.out.printf("COLD-DFA TRIAL %d MS %.6f BYTES %d END 505%n", trial, (System.nanoTime()-start)/1e6, bytes()-b);
        }
        // Batched measurements reduce timer noise for the much faster Java run.
        for (int batch=1; batch<=20; batch++) {
            b=bytes(); start=System.nanoTime();
            for (int i=0; i<10; i++) parse(warm,contexts);
            System.out.printf("WARM BATCH %d MEAN-MS %.6f MEAN-BYTES %.1f%n", batch, (System.nanoTime()-start)/10e6, (bytes()-b)/10.0);
        }
        int roots=0, states=0;
        for (DFA d:warm) { if (!d.states.isEmpty()) roots++; states+=d.states.size(); }
        System.out.printf("DFA ROOTS %d STATES %d%n",roots,states);
    }
}
