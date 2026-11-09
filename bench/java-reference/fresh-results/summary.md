# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.006786 | 0.033840 | 4.99× |
| iri | parse-none | 0.020803 | 0.031230 | 1.50× |
| iri | parse-tree | 0.026996 | 0.069470 | 2.57× |
| iri | pipeline-tree | 0.031430 | 0.103560 | 3.29× |
| java8 | lexer | 0.024146 | 0.147000 | 6.09× |
| java8 | parse-none | 107.116709 | 177.835500 | 1.66× |
| java8 | parse-tree | 106.137271 | 183.641000 | 1.73× |
| java8 | pipeline-tree | 107.227021 | 186.633500 | 1.74× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.394583 | 0.183000 | 0.46× |
| iri | parse-none | 0.998084 | 0.283000 | 0.28× |
| iri | parse-tree | 0.695208 | 0.349000 | 0.50× |
| iri | pipeline-tree | 1.080000 | 0.491000 | 0.45× |
| java8 | lexer | 0.610041 | 1.179000 | 1.93× |
| java8 | parse-none | 748.016333 | 1264.634000 | 1.69× |
| java8 | parse-tree | 755.544750 | 1272.454000 | 1.68× |
| java8 | pipeline-tree | 754.062125 | 1283.583000 | 1.70× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.014153 | 0.064829 | 4.58× |
| iri | parse-none | 0.023633 | 0.035717 | 1.51× |
| iri | parse-tree | 0.076217 | 0.085623 | 1.12× |
| iri | pipeline-tree | 0.090337 | 0.150458 | 1.67× |
| java8 | lexer | 0.040964 | 0.294760 | 7.20× |
| java8 | parse-none | 200.819972 | 263.220176 | 1.31× |
| java8 | parse-tree | 200.964356 | 263.315856 | 1.31× |
| java8 | pipeline-tree | 201.005292 | 263.583552 | 1.31× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| iri | lexer | 0.013015, 0.005997, 0.006786 | 0.033840, 0.033950, 0.033790 |
| iri | parse-none | 0.020803, 0.019528, 0.021050 | 0.029940, 0.031260, 0.031230 |
| iri | parse-tree | 0.027377, 0.026996, 0.026454 | 0.068740, 0.070010, 0.069470 |
| iri | pipeline-tree | 0.031234, 0.031674, 0.031430 | 0.104520, 0.103560, 0.102800 |
| java8 | lexer | 0.023563, 0.024146, 0.026854 | 0.139500, 0.151500, 0.147000 |
| java8 | parse-none | 113.248750, 107.116709, 105.523834 | 177.835500, 177.220000, 182.705500 |
| java8 | parse-tree | 107.686792, 106.137271, 104.895875 | 185.379000, 179.860000, 183.641000 |
| java8 | pipeline-tree | 108.182688, 107.227021, 106.774000 | 187.981000, 184.252500, 186.633500 |

## Trained pipeline caches

| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | --- | ---: | ---: | ---: | ---: |
| iri | java | 31 | 89 | 5 | 20 |
| iri | cnvrs | 31 | 89 | 5 | 20 |
| java8 | java | 111 | 367 | 1160 | 24764 |
| java8 | cnvrs | 111 | 367 | 1160 | 24764 |
