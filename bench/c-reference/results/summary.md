# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| preprocessed | lexer | 0.287610 | 1.328850 | 4.62× |
| preprocessed | parse-none | 5.613292 | 9.882000 | 1.76× |
| preprocessed | parse-tree | 5.692896 | 11.077000 | 1.95× |
| preprocessed | pipeline-tree | 6.128729 | 12.746000 | 2.08× |
| pointers | lexer | 0.014668 | 0.083920 | 5.72× |
| pointers | parse-none | 1.132646 | 1.946500 | 1.72× |
| pointers | parse-tree | 1.176104 | 2.119500 | 1.80× |
| pointers | pipeline-tree | 1.153146 | 2.065500 | 1.79× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| preprocessed | lexer | 1.328459 | 2.694000 | 2.03× |
| preprocessed | parse-none | 9.987083 | 14.719000 | 1.47× |
| preprocessed | parse-tree | 10.081666 | 15.864000 | 1.57× |
| preprocessed | pipeline-tree | 9.440625 | 18.848000 | 2.00× |
| pointers | lexer | 0.826584 | 0.597000 | 0.72× |
| pointers | parse-none | 4.578209 | 5.151000 | 1.13× |
| pointers | parse-tree | 3.342084 | 5.265000 | 1.58× |
| pointers | pipeline-tree | 3.452667 | 5.758000 | 1.67× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| preprocessed | lexer | 0.510657 | 2.460720 | 4.82× |
| preprocessed | parse-none | 9.237796 | 10.960464 | 1.19× |
| preprocessed | parse-tree | 10.779044 | 12.481736 | 1.16× |
| preprocessed | pipeline-tree | 11.289700 | 14.935888 | 1.32× |
| pointers | lexer | 0.029289 | 0.155060 | 5.29× |
| pointers | parse-none | 2.292676 | 2.581136 | 1.13× |
| pointers | parse-tree | 2.367436 | 2.648680 | 1.12× |
| pointers | pipeline-tree | 2.396724 | 2.811584 | 1.17× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| preprocessed | lexer | 0.279889, 0.287610, 0.288010 | 1.331800, 1.328850, 1.320040 |
| preprocessed | parse-none | 5.613292, 5.403271, 5.670563 | 10.004500, 9.882000, 9.740500 |
| preprocessed | parse-tree | 5.692896, 5.516813, 5.752480 | 11.028000, 11.077000, 11.150000 |
| preprocessed | pipeline-tree | 6.156542, 5.996021, 6.128729 | 12.783500, 12.587500, 12.746000 |
| pointers | lexer | 0.014552, 0.014668, 0.023506 | 0.084230, 0.083130, 0.083920 |
| pointers | parse-none | 1.125104, 1.167292, 1.132646 | 2.002000, 1.946500, 1.940000 |
| pointers | parse-tree | 1.180167, 1.149667, 1.176104 | 2.066000, 2.119500, 2.121500 |
| pointers | pipeline-tree | 1.159709, 1.125875, 1.153146 | 1.981000, 2.139000, 2.065500 |

## Trained pipeline caches

| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | --- | ---: | ---: | ---: | ---: |
| preprocessed | java | 106 | 588 | 206 | 994 |
| preprocessed | cnvrs | 106 | 588 | 206 | 994 |
| pointers | java | 62 | 193 | 115 | 665 |
| pointers | cnvrs | 62 | 193 | 115 | 665 |
