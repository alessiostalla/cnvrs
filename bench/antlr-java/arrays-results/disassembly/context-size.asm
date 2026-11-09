; disassembly for CNVRS/ANTLR-RUNTIME::CONTEXT-SIZE
; Size: 92 bytes. Origin: #x700D72E9D0                        ; CNVRS/ANTLR-RUNTIME::CONTEXT-SIZE
; 9D0:       490D4092         AND TMP, R0, #15
; 9D4:       3F0D00F1         CMP TMP, #3
; 9D8:       41020054         BNE L2
; 9DC:       4B5140F8         LDR R1, [R0, #5]
; 9E0:       629145B8         LDR WNL2, [R1, #89]
; 9E4:       21FEFF18         LDR WNL1, #x700D72E9A8
; 9E8:       5F00016B         CMP WNL2, WNL1
; 9EC:       C1000054         BNE L1
; 9F0:       4A0080D2         MOVZ R0, #2
; 9F4: L0:   FB031AAA         MOV CSP, CFP
; 9F8:       5A7B40A9         LDP CFP, LR, [CFP]
; 9FC:       BF0300F1         CMP NULL, #0
; A00:       C0035FD6         RET
; A04: L1:   629145B8         LDR WNL2, [R1, #89]
; A08:       21FDFF18         LDR WNL1, #x700D72E9AC
; A0C:       5F00016B         CMP WNL2, WNL1
; A10:       81000054         BNE L2
; A14:       4A5141F8         LDR R0, [R0, #21]
; A18:       4A915FF8         LDR R0, [R0, #-7]
; A1C:       F6FFFF17         B L0
; A20: L2:   A04321D4         BRK #2589                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; A24:       23               BYTE #X23                       ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; A25:       .ALIGN           4
; A28:       E00120D4         BRK #15                         ; Invalid argument count trap
