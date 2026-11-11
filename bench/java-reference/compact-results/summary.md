# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.015366 | 0.036310 | 2.36× |
| iri | parse-none | 0.028535 | 0.033510 | 1.17× |
| iri | parse-tree | 0.030803 | 0.070810 | 2.30× |
| iri | pipeline-tree | 0.040614 | 0.126310 | 3.11× |
| java8 | lexer | 0.023688 | 0.145500 | 6.14× |
| java8 | parse-none | 133.494313 | 117.213000 | 0.88× |
| java8 | parse-tree | 119.571667 | 99.085000 | 0.83× |
| java8 | pipeline-tree | 126.039229 | 102.098500 | 0.81× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.577334 | 0.220000 | 0.38× |
| iri | parse-none | 1.962917 | 0.314000 | 0.16× |
| iri | parse-tree | 0.863042 | 0.374000 | 0.43× |
| iri | pipeline-tree | 1.074542 | 0.517000 | 0.48× |
| java8 | lexer | 0.666084 | 1.201000 | 1.80× |
| java8 | parse-none | 851.519958 | 821.849000 | 0.97× |
| java8 | parse-tree | 820.590542 | 736.113000 | 0.90× |
| java8 | pipeline-tree | 894.598041 | 739.250000 | 0.83× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.014153 | 0.064829 | 4.58× |
| iri | parse-none | 0.023633 | 0.035796 | 1.51× |
| iri | parse-tree | 0.076217 | 0.085516 | 1.12× |
| iri | pipeline-tree | 0.090369 | 0.150365 | 1.66× |
| java8 | lexer | 0.040964 | 0.294776 | 7.20× |
| java8 | parse-none | 200.820532 | 100.618776 | 0.50× |
| java8 | parse-tree | 200.964356 | 100.787984 | 0.50× |
| java8 | pipeline-tree | 201.005292 | 101.057208 | 0.50× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| iri | lexer | 0.009292, 0.015366, 0.018064 | 0.036310, 0.036480, 0.036180 |
| iri | parse-none | 0.028535, 0.024397, 0.030678 | 0.034480, 0.033510, 0.032450 |
| iri | parse-tree | 0.063054, 0.024902, 0.030803 | 0.071390, 0.070810, 0.070550 |
| iri | pipeline-tree | 0.030866, 0.042150, 0.040614 | 0.144680, 0.126310, 0.106040 |
| java8 | lexer | 0.024042, 0.023688, 0.021688 | 0.147000, 0.145500, 0.145500 |
| java8 | parse-none | 133.494313, 135.539771, 106.305917 | 117.213000, 117.659500, 106.757500 |
| java8 | parse-tree | 122.513479, 107.752355, 119.571667 | 98.071000, 120.317500, 99.085000 |
| java8 | pipeline-tree | 126.039229, 168.727021, 114.036458 | 102.098500, 111.357500, 97.390500 |

## Trained pipeline caches

| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | --- | ---: | ---: | ---: | ---: |
| iri | java | 31 | 89 | 5 | 20 |
| iri | cnvrs | 31 | 89 | 5 | 20 |
| java8 | java | 111 | 367 | 1160 | 24764 |
| java8 | cnvrs | 111 | 367 | 1160 | 24764 |
