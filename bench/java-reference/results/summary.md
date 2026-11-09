# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.006180 | 0.046940 | 7.60× |
| iri | parse-none | 0.021696 | 0.167610 | 7.73× |
| iri | parse-tree | 0.028100 | 0.221580 | 7.89× |
| iri | pipeline-tree | 0.033243 | 0.271280 | 8.16× |
| java8 | lexer | 0.023250 | 0.207000 | 8.90× |
| java8 | parse-none | 114.721688 | 522.953500 | 4.56× |
| java8 | parse-tree | 115.091646 | 522.222000 | 4.54× |
| java8 | pipeline-tree | 114.748208 | 521.289500 | 4.54× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.394334 | 0.273000 | 0.69× |
| iri | parse-none | 1.031917 | 0.984000 | 0.95× |
| iri | parse-tree | 0.733708 | 1.017000 | 1.39× |
| iri | pipeline-tree | 0.873417 | 1.283000 | 1.47× |
| java8 | lexer | 0.682375 | 1.725000 | 2.53× |
| java8 | parse-none | 800.189208 | 3697.064000 | 4.62× |
| java8 | parse-tree | 806.392375 | 3682.452000 | 4.57× |
| java8 | pipeline-tree | 822.641375 | 3704.932000 | 4.50× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.014153 | 0.064830 | 4.58× |
| iri | parse-none | 0.023633 | 0.094731 | 4.01× |
| iri | parse-tree | 0.076217 | 0.144541 | 1.90× |
| iri | pipeline-tree | 0.090369 | 0.208736 | 2.31× |
| java8 | lexer | 0.040964 | 0.294768 | 7.20× |
| java8 | parse-none | 200.822372 | 367.043808 | 1.83× |
| java8 | parse-tree | 200.964356 | 367.202680 | 1.83× |
| java8 | pipeline-tree | 201.005292 | 367.506160 | 1.83× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| iri | lexer | 0.006066, 0.007057, 0.006180 | 0.046710, 0.046940, 0.047850 |
| iri | parse-none | 0.020213, 0.024143, 0.021696 | 0.165140, 0.168000, 0.167610 |
| iri | parse-tree | 0.028100, 0.025545, 0.028705 | 0.220390, 0.221580, 0.223390 |
| iri | pipeline-tree | 0.033553, 0.030075, 0.033243 | 0.270070, 0.276720, 0.271280 |
| java8 | lexer | 0.023230, 0.023250, 0.026438 | 0.211000, 0.196500, 0.207000 |
| java8 | parse-none | 115.906771, 110.748313, 114.721688 | 527.435000, 522.953500, 521.378000 |
| java8 | parse-tree | 114.135354, 115.091646, 115.427792 | 521.257500, 522.222000, 526.071000 |
| java8 | pipeline-tree | 114.250979, 114.748208, 115.795208 | 521.289500, 520.320500, 522.145000 |

## Trained pipeline caches

| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | --- | ---: | ---: | ---: | ---: |
| iri | java | 31 | 89 | 5 | 20 |
| iri | cnvrs | 31 | 89 | 56 | 49 |
| java8 | java | 111 | 367 | 1160 | 24764 |
| java8 | cnvrs | 111 | 367 | 1350 | 25397 |
