# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.011885 | 0.034330 | 2.89× |
| iri | parse-none | 0.020654 | 0.031420 | 1.52× |
| iri | parse-tree | 0.027186 | 0.069980 | 2.57× |
| iri | pipeline-tree | 0.031781 | 0.103910 | 3.27× |
| java8 | lexer | 0.023896 | 0.145000 | 6.07× |
| java8 | parse-none | 108.912688 | 98.663500 | 0.91× |
| java8 | parse-tree | 107.323063 | 97.674500 | 0.91× |
| java8 | pipeline-tree | 107.438563 | 98.381000 | 0.92× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.425167 | 0.192000 | 0.45× |
| iri | parse-none | 1.125542 | 0.271000 | 0.24× |
| iri | parse-tree | 0.758792 | 0.297000 | 0.39× |
| iri | pipeline-tree | 0.912542 | 0.481000 | 0.53× |
| java8 | lexer | 0.603875 | 1.149000 | 1.90× |
| java8 | parse-none | 768.055375 | 695.909000 | 0.91× |
| java8 | parse-tree | 761.083500 | 693.717000 | 0.91× |
| java8 | pipeline-tree | 765.554166 | 698.733000 | 0.91× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.014153 | 0.064829 | 4.58× |
| iri | parse-none | 0.023633 | 0.035717 | 1.51× |
| iri | parse-tree | 0.076217 | 0.085641 | 1.12× |
| iri | pipeline-tree | 0.090369 | 0.150471 | 1.67× |
| java8 | lexer | 0.040964 | 0.294776 | 7.20× |
| java8 | parse-none | 200.819972 | 104.512176 | 0.52× |
| java8 | parse-tree | 200.964356 | 104.641736 | 0.52× |
| java8 | pipeline-tree | 201.005292 | 104.950720 | 0.52× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| iri | lexer | 0.018552, 0.006088, 0.011885 | 0.034720, 0.034330, 0.033950 |
| iri | parse-none | 0.020660, 0.020600, 0.020654 | 0.031420, 0.030980, 0.031880 |
| iri | parse-tree | 0.024006, 0.027186, 0.027765 | 0.070430, 0.069110, 0.069980 |
| iri | pipeline-tree | 0.028750, 0.034816, 0.031781 | 0.103910, 0.103300, 0.106970 |
| java8 | lexer | 0.023959, 0.022479, 0.023896 | 0.144000, 0.146000, 0.145000 |
| java8 | parse-none | 107.826188, 109.789063, 108.912688 | 98.663500, 98.534000, 98.942000 |
| java8 | parse-tree | 107.323063, 107.493875, 107.271625 | 97.487500, 97.674500, 98.858000 |
| java8 | pipeline-tree | 105.867959, 107.438563, 110.156792 | 98.381000, 98.214500, 99.017000 |

## Trained pipeline caches

| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | --- | ---: | ---: | ---: | ---: |
| iri | java | 31 | 89 | 5 | 20 |
| iri | cnvrs | 31 | 89 | 5 | 20 |
| java8 | java | 111 | 367 | 1160 | 24764 |
| java8 | cnvrs | 111 | 367 | 1160 | 24764 |
