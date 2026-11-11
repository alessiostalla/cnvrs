# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| select | lexer | 0.176233 | 0.973850 | 5.53× |
| select | parse-none | 205.000855 | 245.073000 | 1.20× |
| select | parse-tree | 208.161250 | 245.357500 | 1.18× |
| select | pipeline-tree | 203.364500 | 245.460500 | 1.21× |
| schema | lexer | 0.014303 | 0.092450 | 6.46× |
| schema | parse-none | 8.660625 | 10.983000 | 1.27× |
| schema | parse-tree | 8.505688 | 10.991000 | 1.29× |
| schema | pipeline-tree | 8.936896 | 10.749500 | 1.20× |
| json | lexer | 0.038708 | 0.241000 | 6.23× |
| json | parse-none | 75.829730 | 88.421500 | 1.17× |
| json | parse-tree | 78.111604 | 88.288500 | 1.13× |
| json | pipeline-tree | 75.598208 | 89.152500 | 1.18× |
| backup | lexer | 0.013623 | 0.086210 | 6.33× |
| backup | parse-none | 5.860021 | 7.877500 | 1.34× |
| backup | parse-tree | 5.928813 | 7.815000 | 1.32× |
| backup | pipeline-tree | 5.939896 | 7.880000 | 1.33× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| select | lexer | 4.086542 | 8.415000 | 2.06× |
| select | parse-none | 653.183167 | 812.594000 | 1.24× |
| select | parse-tree | 651.944209 | 812.948000 | 1.25× |
| select | pipeline-tree | 645.103250 | 820.857000 | 1.27× |
| schema | lexer | 2.689500 | 4.601000 | 1.71× |
| schema | parse-none | 60.108500 | 64.600000 | 1.07× |
| schema | parse-tree | 55.864500 | 65.282000 | 1.17× |
| schema | pipeline-tree | 57.184458 | 70.071000 | 1.23× |
| json | lexer | 2.349625 | 5.684000 | 2.42× |
| json | parse-none | 339.943959 | 398.583000 | 1.17× |
| json | parse-tree | 337.805208 | 395.124000 | 1.17× |
| json | pipeline-tree | 335.150291 | 402.531000 | 1.20× |
| backup | lexer | 1.489291 | 2.258000 | 1.52× |
| backup | parse-none | 33.440042 | 36.006000 | 1.08× |
| backup | parse-tree | 30.031042 | 35.510000 | 1.18× |
| backup | pipeline-tree | 30.016792 | 37.847000 | 1.26× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| select | lexer | 0.248193 | 2.093347 | 8.43× |
| select | parse-none | 326.284452 | 243.491472 | 0.75× |
| select | parse-tree | 326.754908 | 244.318960 | 0.75× |
| select | pipeline-tree | 327.003100 | 246.409776 | 0.75× |
| schema | lexer | 0.021281 | 0.178828 | 8.40× |
| schema | parse-none | 13.031820 | 10.977160 | 0.84× |
| schema | parse-tree | 13.060180 | 11.032264 | 0.84× |
| schema | pipeline-tree | 13.081460 | 11.207656 | 0.86× |
| json | lexer | 0.066977 | 0.456670 | 6.82× |
| json | parse-none | 124.668836 | 102.737168 | 0.82× |
| json | parse-tree | 124.795916 | 102.916496 | 0.82× |
| json | pipeline-tree | 124.862892 | 103.368744 | 0.83× |
| backup | lexer | 0.019641 | 0.145392 | 7.40× |
| backup | parse-none | 9.483572 | 7.846664 | 0.83× |
| backup | parse-tree | 9.496124 | 7.853400 | 0.83× |
| backup | pipeline-tree | 9.515764 | 7.989184 | 0.84× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| select | lexer | 0.176233, 0.170965, 0.178116 | 0.973850, 0.968810, 0.992510 |
| select | parse-none | 202.997000, 205.000855, 211.083792 | 244.560500, 245.073000, 258.189000 |
| select | parse-tree | 208.161250, 204.313208, 211.803167 | 245.118500, 245.357500, 258.319500 |
| select | pipeline-tree | 203.364500, 202.807563, 215.183792 | 245.460500, 245.060000, 253.970000 |
| schema | lexer | 0.013247, 0.020016, 0.014303 | 0.101220, 0.091080, 0.092450 |
| schema | parse-none | 8.642271, 8.695063, 8.660625 | 11.233500, 10.621500, 10.983000 |
| schema | parse-tree | 10.055000, 8.505688, 8.486459 | 12.227500, 10.482500, 10.991000 |
| schema | pipeline-tree | 8.501708, 8.936896, 8.996125 | 10.801000, 10.725000, 10.749500 |
| json | lexer | 0.038708, 0.040040, 0.038007 | 0.237250, 0.247810, 0.241000 |
| json | parse-none | 74.616333, 77.406375, 75.829730 | 87.402000, 88.939000, 88.421500 |
| json | parse-tree | 75.306458, 80.083604, 78.111604 | 86.750500, 89.024500, 88.288500 |
| json | pipeline-tree | 75.598208, 76.979688, 75.435458 | 92.822000, 88.888500, 89.152500 |
| backup | lexer | 0.013623, 0.014392, 0.013030 | 0.090130, 0.084540, 0.086210 |
| backup | parse-none | 5.797917, 5.860021, 6.091709 | 7.877500, 7.981000, 7.630000 |
| backup | parse-tree | 5.725105, 5.928813, 5.979417 | 7.732000, 8.076000, 7.815000 |
| backup | pipeline-tree | 5.826084, 5.939896, 6.095896 | 7.880000, 8.041500, 7.750000 |

## Trained pipeline caches

| Grammar | Runtime | Lexer states | Lexer edges | Parser states | Parser contexts |
| --- | --- | ---: | ---: | ---: | ---: |
| select | java | 418 | 1189 | 1475 | 8923 |
| select | cnvrs | 418 | 1189 | 1475 | 8923 |
| schema | java | 211 | 469 | 292 | 1195 |
| schema | cnvrs | 211 | 469 | 292 | 1195 |
| json | java | 291 | 707 | 825 | 5323 |
| json | cnvrs | 291 | 707 | 825 | 5323 |
| backup | java | 118 | 237 | 130 | 206 |
| backup | cnvrs | 118 | 237 | 130 | 206 |
