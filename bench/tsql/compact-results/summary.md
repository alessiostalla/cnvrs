# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| select | lexer | 0.163774 | 0.970230 | 5.92× |
| select | parse-none | 207.031313 | 213.674000 | 1.03× |
| select | parse-tree | 208.450542 | 214.513000 | 1.03× |
| select | pipeline-tree | 207.164021 | 217.566500 | 1.05× |
| schema | lexer | 0.013405 | 0.089460 | 6.67× |
| schema | parse-none | 8.572479 | 9.240000 | 1.08× |
| schema | parse-tree | 8.598792 | 9.313500 | 1.08× |
| schema | pipeline-tree | 8.554750 | 9.378000 | 1.10× |
| json | lexer | 0.037658 | 0.241820 | 6.42× |
| json | parse-none | 75.193583 | 76.007000 | 1.01× |
| json | parse-tree | 74.223500 | 75.082000 | 1.01× |
| json | pipeline-tree | 75.726083 | 75.070000 | 0.99× |
| backup | lexer | 0.013723 | 0.086510 | 6.30× |
| backup | parse-none | 5.936833 | 6.920500 | 1.17× |
| backup | parse-tree | 5.660021 | 6.692500 | 1.18× |
| backup | pipeline-tree | 5.673854 | 7.221500 | 1.27× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| select | lexer | 3.673333 | 8.903000 | 2.42× |
| select | parse-none | 650.251000 | 754.814000 | 1.16× |
| select | parse-tree | 648.311208 | 756.401000 | 1.17× |
| select | pipeline-tree | 666.878083 | 764.030000 | 1.15× |
| schema | lexer | 2.723000 | 4.291000 | 1.58× |
| schema | parse-none | 58.791417 | 63.018000 | 1.07× |
| schema | parse-tree | 55.622459 | 63.087000 | 1.13× |
| schema | pipeline-tree | 56.262875 | 67.916000 | 1.21× |
| json | lexer | 2.818250 | 5.242000 | 1.86× |
| json | parse-none | 327.760792 | 386.062000 | 1.18× |
| json | parse-tree | 327.688333 | 383.055000 | 1.17× |
| json | pipeline-tree | 326.716791 | 387.710000 | 1.19× |
| backup | lexer | 1.433500 | 2.216000 | 1.55× |
| backup | parse-none | 32.230916 | 34.751000 | 1.08× |
| backup | parse-tree | 28.962292 | 35.415000 | 1.22× |
| backup | pipeline-tree | 29.656750 | 36.080000 | 1.22× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| select | lexer | 0.248193 | 2.093346 | 8.43× |
| select | parse-none | 326.284452 | 182.225952 | 0.56× |
| select | parse-tree | 326.754908 | 183.030648 | 0.56× |
| select | pipeline-tree | 327.003100 | 185.120488 | 0.57× |
| schema | lexer | 0.021281 | 0.178830 | 8.40× |
| schema | parse-none | 13.031820 | 8.372784 | 0.64× |
| schema | parse-tree | 13.060180 | 8.427904 | 0.65× |
| schema | pipeline-tree | 13.081460 | 8.600616 | 0.66× |
| json | lexer | 0.066977 | 0.456670 | 6.82× |
| json | parse-none | 124.668836 | 74.797032 | 0.60× |
| json | parse-tree | 124.795916 | 74.973936 | 0.60× |
| json | pipeline-tree | 124.862892 | 75.423416 | 0.60× |
| backup | lexer | 0.019641 | 0.145392 | 7.40× |
| backup | parse-none | 9.483572 | 6.359008 | 0.67× |
| backup | parse-tree | 9.496124 | 6.364656 | 0.67× |
| backup | pipeline-tree | 9.515764 | 6.533080 | 0.69× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| select | lexer | 0.163774, 0.162344, 0.164253 | 0.970230, 0.966490, 0.971570 |
| select | parse-none | 201.554167, 207.031313, 219.639709 | 211.819500, 213.674000, 214.837500 |
| select | parse-tree | 208.450542, 205.838563, 220.665813 | 212.894000, 215.329500, 214.513000 |
| select | pipeline-tree | 204.082959, 207.164021, 220.709729 | 214.047000, 217.566500, 217.796000 |
| schema | lexer | 0.013405, 0.014590, 0.013050 | 0.089460, 0.087790, 0.093080 |
| schema | parse-none | 8.514646, 8.718563, 8.572479 | 9.095500, 9.240000, 9.323500 |
| schema | parse-tree | 8.598792, 8.257292, 8.734167 | 9.217500, 9.313500, 9.513000 |
| schema | pipeline-tree | 8.554750, 8.508584, 9.392084 | 9.378000, 9.178000, 9.487000 |
| json | lexer | 0.041510, 0.037000, 0.037658 | 0.235090, 0.255390, 0.241820 |
| json | parse-none | 87.867459, 74.929625, 75.193583 | 77.568500, 74.839500, 76.007000 |
| json | parse-tree | 73.298334, 74.223500, 75.456813 | 73.961000, 76.051500, 75.082000 |
| json | pipeline-tree | 72.386354, 75.726083, 75.897875 | 75.070000, 74.637000, 77.466000 |
| backup | lexer | 0.012608, 0.014357, 0.013723 | 0.085820, 0.086510, 0.087170 |
| backup | parse-none | 5.659459, 5.944750, 5.936833 | 6.831000, 6.920500, 7.503000 |
| backup | parse-tree | 5.660021, 5.835458, 5.578771 | 6.625000, 6.692500, 7.375000 |
| backup | pipeline-tree | 5.673854, 5.815104, 5.558667 | 6.896000, 7.221500, 8.220000 |

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
