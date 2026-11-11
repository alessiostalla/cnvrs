# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| preprocessed | lexer | 0.284895 | 1.335280 | 4.69× |
| preprocessed | parse-none | 5.513688 | 7.344000 | 1.33× |
| preprocessed | parse-tree | 5.805000 | 8.628000 | 1.49× |
| preprocessed | pipeline-tree | 5.987896 | 10.058500 | 1.68× |
| pointers | lexer | 0.030125 | 0.081790 | 2.72× |
| pointers | parse-none | 1.167959 | 1.274000 | 1.09× |
| pointers | parse-tree | 1.077292 | 1.293500 | 1.20× |
| pointers | pipeline-tree | 1.135792 | 1.425000 | 1.25× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| preprocessed | lexer | 1.226125 | 2.751000 | 2.24× |
| preprocessed | parse-none | 10.591542 | 11.853000 | 1.12× |
| preprocessed | parse-tree | 9.617250 | 13.058000 | 1.36× |
| preprocessed | pipeline-tree | 9.427375 | 15.934000 | 1.69× |
| pointers | lexer | 0.902208 | 0.592000 | 0.66× |
| pointers | parse-none | 4.718916 | 4.056000 | 0.86× |
| pointers | parse-tree | 3.447792 | 4.293000 | 1.25× |
| pointers | pipeline-tree | 3.727791 | 4.804000 | 1.29× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| preprocessed | lexer | 0.510657 | 2.460720 | 4.82× |
| preprocessed | parse-none | 9.237796 | 6.061448 | 0.66× |
| preprocessed | parse-tree | 10.779044 | 7.581464 | 0.70× |
| preprocessed | pipeline-tree | 11.289700 | 10.036776 | 0.89× |
| pointers | lexer | 0.029321 | 0.155060 | 5.29× |
| pointers | parse-none | 2.297092 | 1.173512 | 0.51× |
| pointers | parse-tree | 2.367436 | 1.240352 | 0.52× |
| pointers | pipeline-tree | 2.396724 | 1.404744 | 0.59× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| preprocessed | lexer | 0.293284, 0.284895, 0.282349 | 1.335280, 1.325430, 1.339310 |
| preprocessed | parse-none | 5.513688, 5.597396, 5.411333 | 7.344000, 7.284500, 7.382000 |
| preprocessed | parse-tree | 5.858354, 5.805000, 5.615542 | 8.628000, 8.645500, 8.414000 |
| preprocessed | pipeline-tree | 5.883333, 5.987896, 6.129792 | 9.823000, 10.275500, 10.058500 |
| pointers | lexer | 0.015147, 0.030125, 0.031085 | 0.080660, 0.084900, 0.081790 |
| pointers | parse-none | 1.094084, 1.167959, 1.312292 | 1.294000, 1.274000, 1.152500 |
| pointers | parse-tree | 1.122167, 1.067042, 1.077292 | 1.322000, 1.232000, 1.293500 |
| pointers | pipeline-tree | 1.085729, 1.140750, 1.135792 | 1.397000, 1.425000, 1.447000 |

## Trained pipeline caches

| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | --- | ---: | ---: | ---: | ---: |
| preprocessed | java | 106 | 588 | 206 | 994 |
| preprocessed | cnvrs | 106 | 588 | 206 | 994 |
| pointers | java | 62 | 193 | 115 | 665 |
| pointers | cnvrs | 62 | 193 | 115 | 665 |
