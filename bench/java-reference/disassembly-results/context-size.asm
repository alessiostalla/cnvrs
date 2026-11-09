; disassembly for CNVRS/RUNTIME::CONTEXT-SIZE
; Size: 92 bytes. Origin: #x700D8D03F0                        ; CNVRS/RUNTIME::CONTEXT-SIZE
; 3F0:       490D4092         AND TMP, R0, #15
; 3F4:       3F0D00F1         CMP TMP, #3
; 3F8:       41020054         BNE L2
; 3FC:       4B5140F8         LDR R1, [R0, #5]
; 400:       629145B8         LDR WNL2, [R1, #89]
; 404:       21FEFF18         LDR WNL1, #x700D8D03C8
; 408:       5F00016B         CMP WNL2, WNL1
; 40C:       C1000054         BNE L1
; 410:       4A0080D2         MOVZ R0, #2
; 414: L0:   FB031AAA         MOV CSP, CFP
; 418:       5A7B40A9         LDP CFP, LR, [CFP]
; 41C:       BF0300F1         CMP NULL, #0
; 420:       C0035FD6         RET
; 424: L1:   629145B8         LDR WNL2, [R1, #89]
; 428:       21FDFF18         LDR WNL1, #x700D8D03CC
; 42C:       5F00016B         CMP WNL2, WNL1
; 430:       81000054         BNE L2
; 434:       4A5141F8         LDR R0, [R0, #21]
; 438:       4A915FF8         LDR R0, [R0, #-7]
; 43C:       F6FFFF17         B L0
; 440: L2:   A04321D4         BRK #2589                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; 444:       23               BYTE #X23                       ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 445:       .ALIGN           4
; 448:       E00120D4         BRK #15                         ; Invalid argument count trap
