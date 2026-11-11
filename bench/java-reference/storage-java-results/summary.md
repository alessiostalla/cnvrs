# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.006355 | 0.035310 | 5.56× |
| iri | parse-none | 0.021987 | 0.032010 | 1.46× |
| iri | parse-tree | 0.026945 | 0.069900 | 2.59× |
| iri | pipeline-tree | 0.032959 | 0.104410 | 3.17× |
| java8 | lexer | 0.023354 | 0.149000 | 6.38× |
| java8 | parse-none | 109.522021 | 93.150000 | 0.85× |
| java8 | parse-tree | 106.160667 | 94.839000 | 0.89× |
| java8 | pipeline-tree | 106.090188 | 93.791500 | 0.88× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.386125 | 0.194000 | 0.50× |
| iri | parse-none | 0.940750 | 0.257000 | 0.27× |
| iri | parse-tree | 0.711750 | 0.300000 | 0.42× |
| iri | pipeline-tree | 0.898625 | 0.447000 | 0.50× |
| java8 | lexer | 0.602667 | 1.162000 | 1.93× |
| java8 | parse-none | 760.270750 | 654.598000 | 0.86× |
| java8 | parse-tree | 753.571791 | 655.572000 | 0.87× |
| java8 | pipeline-tree | 748.871250 | 654.348000 | 0.87× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.014153 | 0.064829 | 4.58× |
| iri | parse-none | 0.023633 | 0.035797 | 1.51× |
| iri | parse-tree | 0.076217 | 0.085548 | 1.12× |
| iri | pipeline-tree | 0.090369 | 0.150346 | 1.66× |
| java8 | lexer | 0.040964 | 0.294776 | 7.20× |
| java8 | parse-none | 200.819972 | 98.639888 | 0.49× |
| java8 | parse-tree | 200.964356 | 98.832104 | 0.49× |
| java8 | pipeline-tree | 201.005292 | 99.131528 | 0.49× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| iri | lexer | 0.012082, 0.005828, 0.006355 | 0.035310, 0.034920, 0.035650 |
| iri | parse-none | 0.023225, 0.019658, 0.021987 | 0.031870, 0.032010, 0.032160 |
| iri | parse-tree | 0.024815, 0.026945, 0.029777 | 0.070510, 0.069430, 0.069900 |
| iri | pipeline-tree | 0.030382, 0.033257, 0.032959 | 0.104410, 0.102450, 0.106640 |
| java8 | lexer | 0.023354, 0.024563, 0.021375 | 0.149000, 0.147500, 0.149000 |
| java8 | parse-none | 106.144625, 109.967729, 109.522021 | 93.150000, 93.349500, 91.752000 |
| java8 | parse-tree | 106.160667, 105.449292, 109.309459 | 96.352500, 94.536500, 94.839000 |
| java8 | pipeline-tree | 106.090188, 105.752625, 108.745396 | 96.051000, 93.791500, 93.614000 |

## Trained pipeline caches

| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | --- | ---: | ---: | ---: | ---: |
| iri | java | 31 | 89 | 5 | 20 |
| iri | cnvrs | 31 | 89 | 5 | 20 |
| java8 | java | 111 | 367 | 1160 | 24764 |
| java8 | cnvrs | 111 | 367 | 1160 | 24764 |
