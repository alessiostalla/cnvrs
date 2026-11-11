# Benchmark summary

Times are milliseconds per call. Ratios are CNVRS / Java.

## Warm caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| select | lexer | 0.163118 | 0.999040 | 6.12× |
| select | parse-none | 204.442292 | 195.481500 | 0.96× |
| select | parse-tree | 203.936792 | 197.677500 | 0.97× |
| select | pipeline-tree | 205.334771 | 200.272000 | 0.98× |
| schema | lexer | 0.013435 | 0.095820 | 7.13× |
| schema | parse-none | 8.912479 | 8.749500 | 0.98× |
| schema | parse-tree | 8.869063 | 8.619000 | 0.97× |
| schema | pipeline-tree | 8.937729 | 8.798000 | 0.98× |
| json | lexer | 0.038808 | 0.249960 | 6.44× |
| json | parse-none | 75.352459 | 69.422500 | 0.92× |
| json | parse-tree | 75.776250 | 69.232500 | 0.91× |
| json | pipeline-tree | 76.336855 | 70.057000 | 0.92× |
| backup | lexer | 0.013469 | 0.086510 | 6.42× |
| backup | parse-none | 5.798855 | 6.487000 | 1.12× |
| backup | parse-tree | 5.873938 | 6.456500 | 1.10× |
| backup | pipeline-tree | 5.950604 | 6.696500 | 1.13× |

## Cold DFA/context caches

| Grammar | Phase | Java | CNVRS | Ratio |
| --- | --- | ---: | ---: | ---: |
| select | lexer | 3.872042 | 8.579000 | 2.22× |
| select | parse-none | 645.562125 | 719.323000 | 1.11× |
| select | parse-tree | 647.032125 | 720.613000 | 1.11× |
| select | pipeline-tree | 655.979875 | 731.493000 | 1.12× |
| schema | lexer | 2.615500 | 4.625000 | 1.77× |
| schema | parse-none | 58.762000 | 59.982000 | 1.02× |
| schema | parse-tree | 56.437834 | 59.907000 | 1.06× |
| schema | pipeline-tree | 57.567750 | 65.327000 | 1.13× |
| json | lexer | 2.680333 | 5.256000 | 1.96× |
| json | parse-none | 333.493625 | 364.355000 | 1.09× |
| json | parse-tree | 331.026417 | 363.159000 | 1.10× |
| json | pipeline-tree | 329.129250 | 367.736000 | 1.12× |
| backup | lexer | 1.502625 | 2.188000 | 1.46× |
| backup | parse-none | 32.668584 | 32.036000 | 0.98× |
| backup | parse-tree | 30.499791 | 33.168000 | 1.09× |
| backup | pipeline-tree | 29.974125 | 35.337000 | 1.18× |

## Warm allocation per call

Decimal MB; cumulative allocation, not live heap.

| Grammar | Phase | Java MB | CNVRS MB | Ratio |
| --- | --- | ---: | ---: | ---: |
| select | lexer | 0.248193 | 2.093346 | 8.43× |
| select | parse-none | 326.284452 | 148.538704 | 0.46× |
| select | parse-tree | 326.754908 | 149.346920 | 0.46× |
| select | pipeline-tree | 327.003100 | 151.433288 | 0.46× |
| schema | lexer | 0.021281 | 0.178830 | 8.40× |
| schema | parse-none | 13.031820 | 6.718752 | 0.52× |
| schema | parse-tree | 13.060180 | 6.773920 | 0.52× |
| schema | pipeline-tree | 13.081460 | 6.949264 | 0.53× |
| json | lexer | 0.066977 | 0.456670 | 6.82× |
| json | parse-none | 124.668836 | 60.674128 | 0.49× |
| json | parse-tree | 124.795916 | 60.882136 | 0.49× |
| json | pipeline-tree | 124.862892 | 61.331512 | 0.49× |
| backup | lexer | 0.019641 | 0.145392 | 7.40× |
| backup | parse-none | 9.483572 | 5.129720 | 0.54× |
| backup | parse-tree | 9.496124 | 5.168000 | 0.54× |
| backup | pipeline-tree | 9.515764 | 5.303736 | 0.56× |

## Per-process warm medians

Each value is the median of seven batch means.

| Grammar | Phase | Java runs (ms) | CNVRS runs (ms) |
| --- | --- | --- | --- |
| select | lexer | 0.167437, 0.158960, 0.163118 | 0.999040, 0.987200, 1.010100 |
| select | parse-none | 204.442292, 201.851917, 207.419250 | 196.795500, 195.481500, 195.471000 |
| select | parse-tree | 203.936792, 202.705375, 210.610605 | 195.833000, 204.461500, 197.677500 |
| select | pipeline-tree | 203.891354, 205.334771, 206.677500 | 200.434000, 196.918500, 200.272000 |
| schema | lexer | 0.013435, 0.012684, 0.013646 | 0.093790, 0.095820, 0.102960 |
| schema | parse-none | 8.912479, 8.947854, 8.807708 | 8.749500, 9.692500, 8.541500 |
| schema | parse-tree | 8.708146, 8.869063, 8.955354 | 8.378000, 8.699000, 8.619000 |
| schema | pipeline-tree | 8.912813, 8.937729, 9.092188 | 9.390500, 8.782500, 8.798000 |
| json | lexer | 0.038226, 0.039105, 0.038808 | 0.255300, 0.249960, 0.242380 |
| json | parse-none | 75.111917, 75.352459, 75.850083 | 69.156500, 69.422500, 70.236500 |
| json | parse-tree | 73.957229, 75.776250, 76.364083 | 69.772500, 68.638000, 69.232500 |
| json | pipeline-tree | 74.895979, 76.403396, 76.336855 | 70.057000, 70.295000, 69.062000 |
| backup | lexer | 0.013469, 0.014450, 0.013352 | 0.086850, 0.085080, 0.086510 |
| backup | parse-none | 5.656792, 5.798855, 6.067354 | 6.537000, 6.209000, 6.487000 |
| backup | parse-tree | 5.873938, 5.833979, 6.116000 | 6.456500, 6.348000, 6.505000 |
| backup | pipeline-tree | 5.796521, 6.158167, 5.950604 | 6.696500, 6.805500, 6.677000 |

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
