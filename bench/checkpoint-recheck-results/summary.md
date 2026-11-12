# Native Java 8 and C11 checkpoint regression recheck

Warm milliseconds per call; medians of three process medians of seven batch means.

| Workload | Phase | Before CNVRS | Current CNVRS | Change | ANTLR Java | Current / Java |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| java8 | lexer | 0.139600 | 0.141800 | +1.6% | 0.024500 | 5.79× |
| java8 | parse-none | 96.540000 | 98.695200 | +2.2% | 104.242875 | 0.95× |
| java8 | parse-tree | 97.907800 | 96.580800 | -1.4% | 105.152021 | 0.92× |
| java8 | pipeline-tree | 100.343600 | 97.903000 | -2.4% | 105.811250 | 0.93× |

java8: token signatures, normalized kinds (C11), and all trained cache counts agree across all nine processes.

| preprocessed | lexer | 1.335715 | 1.312330 | -1.8% | 0.276294 | 4.75× |
| preprocessed | parse-none | 6.941150 | 6.913950 | -0.4% | 5.404771 | 1.28× |
| preprocessed | parse-tree | 8.088050 | 8.205050 | +1.4% | 5.691709 | 1.44× |
| preprocessed | pipeline-tree | 9.760450 | 9.699850 | -0.6% | 5.827646 | 1.66× |

preprocessed: token signatures, normalized kinds (C11), and all trained cache counts agree across all nine processes.

| pointers | lexer | 0.081450 | 0.079985 | -1.8% | 0.016007 | 5.00× |
| pointers | parse-none | 1.233250 | 1.216800 | -1.3% | 1.182042 | 1.03× |
| pointers | parse-tree | 1.281200 | 1.282200 | +0.1% | 1.083792 | 1.18× |
| pointers | pipeline-tree | 1.397950 | 1.366500 | -2.2% | 1.108646 | 1.23× |

pointers: token signatures, normalized kinds (C11), and all trained cache counts agree across all nine processes.

