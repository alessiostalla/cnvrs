# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.007275 | 0.035120 | 4.83× |
| iri | parse-none | 0.020298 | 0.034260 | 1.69× |
| iri | parse-tree | 0.026263 | 0.072970 | 2.78× |
| iri | pipeline-tree | 0.030308 | 0.109230 | 3.60× |
| java8 | lexer | 0.024084 | 0.150000 | 6.23× |
| java8 | parse-none | 103.839042 | 240.916000 | 2.32× |
| java8 | parse-tree | 104.917042 | 241.832500 | 2.30× |
| java8 | pipeline-tree | 106.650292 | 243.056000 | 2.28× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.372083 | 0.195000 | 0.52× |
| iri | parse-none | 1.058875 | 0.340000 | 0.32× |
| iri | parse-tree | 0.732500 | 0.396000 | 0.54× |
| iri | pipeline-tree | 0.912500 | 0.570000 | 0.62× |
| java8 | lexer | 0.585542 | 1.191000 | 2.03× |
| java8 | parse-none | 734.778000 | 1658.263000 | 2.26× |
| java8 | parse-tree | 740.638167 | 1655.595000 | 2.24× |
| java8 | pipeline-tree | 726.848875 | 1664.960000 | 2.29× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| iri | lexer | 0.014153 | 0.064829 | 4.58× |
| iri | parse-none | 0.023633 | 0.063322 | 2.68× |
| iri | parse-tree | 0.076217 | 0.113660 | 1.49× |
| iri | pipeline-tree | 0.090369 | 0.177947 | 1.97× |
| java8 | lexer | 0.040964 | 0.294768 | 7.20× |
| java8 | parse-none | 200.819972 | 318.289448 | 1.58× |
| java8 | parse-tree | 200.964356 | 318.438856 | 1.58× |
| java8 | pipeline-tree | 201.005292 | 318.723416 | 1.59× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| iri | lexer | 0.007275, 0.005919, 0.012097 | 0.034970, 0.035120, 0.038200 |
| iri | parse-none | 0.033584, 0.019616, 0.020298 | 0.034260, 0.033910, 0.034360 |
| iri | parse-tree | 0.025572, 0.027148, 0.026263 | 0.074930, 0.072970, 0.072560 |
| iri | pipeline-tree | 0.030111, 0.032734, 0.030308 | 0.109230, 0.111290, 0.106790 |
| java8 | lexer | 0.024375, 0.024084, 0.022729 | 0.150000, 0.149000, 0.150500 |
| java8 | parse-none | 112.242292, 103.376292, 103.839042 | 240.916000, 242.261500, 237.825500 |
| java8 | parse-tree | 108.645438, 104.917042, 104.894875 | 240.616000, 241.832500, 243.595500 |
| java8 | pipeline-tree | 106.650292, 107.220792, 101.942688 | 243.056000, 242.795000, 245.043500 |

## Trained pipeline caches

| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | --- | ---: | ---: | ---: | ---: |
| iri | java | 31 | 89 | 5 | 20 |
| iri | cnvrs | 31 | 89 | 5 | 20 |
| java8 | java | 111 | 367 | 1160 | 24764 |
| java8 | cnvrs | 111 | 367 | 1160 | 24764 |
