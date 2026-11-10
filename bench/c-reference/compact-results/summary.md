# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| preprocessed | lexer | 0.284515 | 1.344050 | 4.72× |
| preprocessed | parse-none | 5.654584 | 8.391500 | 1.48× |
| preprocessed | parse-tree | 5.775084 | 9.700500 | 1.68× |
| preprocessed | pipeline-tree | 6.014229 | 11.087500 | 1.84× |
| pointers | lexer | 0.032051 | 0.082380 | 2.57× |
| pointers | parse-none | 1.234334 | 1.577000 | 1.28× |
| pointers | parse-tree | 1.090521 | 1.628500 | 1.49× |
| pointers | pipeline-tree | 1.143292 | 1.635500 | 1.43× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| preprocessed | lexer | 1.355750 | 2.751000 | 2.03× |
| preprocessed | parse-none | 10.833542 | 13.596000 | 1.25× |
| preprocessed | parse-tree | 9.582750 | 14.424000 | 1.51× |
| preprocessed | pipeline-tree | 10.303459 | 17.411000 | 1.69× |
| pointers | lexer | 1.051958 | 0.575000 | 0.55× |
| pointers | parse-none | 5.838083 | 4.847000 | 0.83× |
| pointers | parse-tree | 3.945959 | 4.943000 | 1.25× |
| pointers | pipeline-tree | 3.775750 | 5.206000 | 1.38× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| preprocessed | lexer | 0.510657 | 2.460720 | 4.82× |
| preprocessed | parse-none | 9.237796 | 8.056936 | 0.87× |
| preprocessed | parse-tree | 10.779044 | 9.545432 | 0.89× |
| preprocessed | pipeline-tree | 11.289700 | 12.032352 | 1.07× |
| pointers | lexer | 0.029321 | 0.155060 | 5.29× |
| pointers | parse-none | 2.297092 | 1.701440 | 0.74× |
| pointers | parse-tree | 2.367436 | 1.765288 | 0.75× |
| pointers | pipeline-tree | 2.396724 | 1.928856 | 0.80× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| preprocessed | lexer | 0.284515, 0.281453, 0.295775 | 1.344050, 1.398080, 1.335800 |
| preprocessed | parse-none | 5.326104, 6.675417, 5.654584 | 8.326500, 9.389500, 8.391500 |
| preprocessed | parse-tree | 5.775084, 5.328667, 6.677813 | 9.467000, 10.859500, 9.700500 |
| preprocessed | pipeline-tree | 5.879167, 6.701917, 6.014229 | 10.948000, 11.087500, 11.125500 |
| pointers | lexer | 0.032051, 0.032074, 0.027645 | 0.082380, 0.094620, 0.081780 |
| pointers | parse-none | 1.396063, 1.234334, 1.168167 | 1.447500, 1.652000, 1.577000 |
| pointers | parse-tree | 1.076855, 1.090521, 1.137771 | 1.508000, 1.683000, 1.628500 |
| pointers | pipeline-tree | 1.144167, 1.062292, 1.143292 | 1.609500, 1.648500, 1.635500 |

## Trained pipeline caches

| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | --- | ---: | ---: | ---: | ---: |
| preprocessed | java | 106 | 588 | 206 | 994 |
| preprocessed | cnvrs | 106 | 588 | 206 | 994 |
| pointers | java | 62 | 193 | 115 | 665 |
| pointers | cnvrs | 62 | 193 | 115 | 665 |
