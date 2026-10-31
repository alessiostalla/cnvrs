import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import org.antlr.v4.runtime.*;

public final class Bench {
    static final BaseErrorListener ERRORS = new BaseErrorListener() {
        @Override public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol,
                                          int line, int charPositionInLine, String msg,
                                          org.antlr.v4.runtime.RecognitionException e) {
            throw new IllegalArgumentException(line + ":" + charPositionInLine + " " + msg, e);
        }
    };

    static void parse(String source) {
        ANTLRv4Lexer lexer = new ANTLRv4Lexer(CharStreams.fromString(source));
        lexer.removeErrorListeners();
        lexer.addErrorListener(ERRORS);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        ANTLRv4Parser parser = new ANTLRv4Parser(tokens);
        parser.removeErrorListeners();
        parser.addErrorListener(ERRORS);
        parser.setErrorHandler(new BailErrorStrategy());
        parser.setBuildParseTree("1".equals(System.getenv("BENCH_TREE")));
        parser.grammarSpec();
    }

    static long median(List<Long> samples) {
        samples.sort(Long::compare);
        return samples.get(samples.size() / 2);
    }

    public static void main(String[] args) throws Exception {
        int warmup = Integer.parseInt(args[0]);
        int batches = Integer.parseInt(args[1]);
        int iterations = Integer.parseInt(args[2]);
        for (int i = 3; i < args.length; i++) {
            Path path = Path.of(args[i]);
            String source = Files.readString(path);
            try {
                parse(source);
            } catch (Throwable e) {
                System.out.println("FAIL\t" + path.getFileName() + "\t" + e);
                continue;
            }
            for (int j = 0; j < warmup; j++) parse(source);
            List<Long> samples = new ArrayList<>();
            for (int batch = 0; batch < batches; batch++) {
                long start = System.nanoTime();
                for (int j = 0; j < iterations; j++) parse(source);
                samples.add((System.nanoTime() - start) / iterations);
            }
            System.out.println("OK\t" + path.getFileName() + "\t" + source.length() + "\t" + median(samples));
        }
    }
}
