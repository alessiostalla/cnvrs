; disassembly for CNVRS/ANTLR-RUNTIME:MERGE-CONTEXTS
; Size: 428 bytes. Origin: #x700CDE09D4                       ; CNVRS/ANTLR-RUNTIME:MERGE-CONTEXTS
; 9D4:       503F01A9         STP R6, R5, [CFP, #16]
; 9D8:       4D3302A9         STP R3, R2, [CFP, #32]
; 9DC:       7A0300F9         STR CFP, [CSP]
; 9E0:       EA030FAA         MOV R0, R5
; 9E4:       EB0310AA         MOV R1, R6
; 9E8:       D6F2FF58         LDR LEXENV, #x700CDE0840        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:CONTEXT-EQUAL>
; 9EC:       970080D2         MOVZ NARGS, #4
; 9F0:       FA031BAA         MOV CFP, CSP
; 9F4:       DE9240F8         LDR LR, [LEXENV, #9]
; 9F8:       C0033FD6         BLR LR
; 9FC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; A00:       4D3342A9         LDP R3, R2, [CFP, #32]
; A04:       503F41A9         LDP R6, R5, [CFP, #16]
; A08:       5F011DEB         CMP R0, NULL
; A0C:       80000054         BEQ L0
; A10:       ABE30091         ADD R1, NULL, #56               ; T
; A14:       5F010BEB         CMP R0, R1
; A18:       C10A0054         BNE L14
; A1C: L0:   5F011DEB         CMP R0, NULL
; A20:       61060054         BNE L7
; A24:       E90D4092         AND TMP, R5, #15
; A28:       3F0D00F1         CMP TMP, #3
; A2C:       A1090054         BNE L12
; A30:       EA5140F8         LDR R0, [R5, #5]
; A34:       429145B8         LDR WNL2, [R0, #89]
; A38:       A1F2FF18         LDR WNL1, #x700CDE088C
; A3C:       5F00016B         CMP WNL2, WNL1
; A40:       40090054         BEQ L13
; A44:       429145B8         LDR WNL2, [R0, #89]
; A48:       41F2FF18         LDR WNL1, #x700CDE0890
; A4C:       5F00016B         CMP WNL2, WNL1
; A50:       81080054         BNE L12
; A54:       EA5141F8         LDR R0, [R5, #21]
; A58:       40915FF8         LDR NL0, [R0, #-7]
; A5C: L1:   1F0800F1         CMP NL0, #2
; A60:       A0040054         BEQ L8
; A64: L2:   9F011DEB         CMP R2, NULL
; A68:       40030054         BEQ L6
; A6C:       EBEFFF58         LDR R1, #x700CDE0868            ; 'CNVRS/ANTLR-RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; A70:       61515FB8         LDR WNL1, [R1, #-11]
; A74:       AA6A61F8         LDR R0, [THREAD, NL1]
; A78:       5F0500B1         CMN R0, #1
; A7C:       41000054         BNE L3
; A80:       6A1140F8         LDR R0, [R1, #1]
; A84: L3:   5F2500F1         CMP R0, #9
; A88:       80070054         BEQ L15
; A8C:       FF010AEB         CMP R5, R0
; A90:       E0020054         BEQ L7
; A94:       ABEEFF58         LDR R1, #x700CDE0868            ; 'CNVRS/ANTLR-RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; A98:       61515FB8         LDR WNL1, [R1, #-11]
; A9C:       AA6A61F8         LDR R0, [THREAD, NL1]
; AA0:       5F0500B1         CMN R0, #1
; AA4:       41000054         BNE L4
; AA8:       6A1140F8         LDR R0, [R1, #1]
; AAC: L4:   5F2500F1         CMP R0, #9
; AB0:       60060054         BEQ L16
; AB4:       1F020AEB         CMP R6, R0
; AB8:       C1000054         BNE L6
; ABC:       EA0310AA         MOV R0, R6
; AC0: L5:   FB031AAA         MOV CSP, CFP
; AC4:       5A7B40A9         LDP CFP, LR, [CFP]
; AC8:       BF0300F1         CMP NULL, #0
; ACC:       C0035FD6         RET
; AD0: L6:   EA030FAA         MOV R0, R5
; AD4:       EB0310AA         MOV R1, R6
; AD8:       96EBFF58         LDR LEXENV, #x700CDE0848        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::MERGE-ARRAYS>
; ADC:       170180D2         MOVZ NARGS, #8
; AE0:       DE9240F8         LDR LR, [LEXENV, #9]
; AE4:       DE130091         ADD LR, LR, #4
; AE8:       C0031FD6         BR LR
; AEC: L7:   EA030FAA         MOV R0, R5
; AF0:       F4FFFF17         B L5
; AF4: L8:   090E4092         AND TMP, R6, #15
; AF8:       3F0D00F1         CMP TMP, #3
; AFC:       E1020054         BNE L11
; B00:       0A5240F8         LDR R0, [R6, #5]
; B04:       429145B8         LDR WNL2, [R0, #89]
; B08:       21ECFF18         LDR WNL1, #x700CDE088C
; B0C:       5F00016B         CMP WNL2, WNL1
; B10:       61010054         BNE L10
; B14:       400080D2         MOVZ NL0, #2
; B18: L9:   1F0800F1         CMP NL0, #2
; B1C:       41FAFF54         BNE L2
; B20:       EA030FAA         MOV R0, R5
; B24:       EB0310AA         MOV R1, R6
; B28:       56E9FF58         LDR LEXENV, #x700CDE0850        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::MERGE-SINGLETONS>
; B2C:       170180D2         MOVZ NARGS, #8
; B30:       DE9240F8         LDR LR, [LEXENV, #9]
; B34:       DE130091         ADD LR, LR, #4
; B38:       C0031FD6         BR LR
; B3C: L10:  429145B8         LDR WNL2, [R0, #89]
; B40:       81EAFF18         LDR WNL1, #x700CDE0890
; B44:       5F00016B         CMP WNL2, WNL1
; B48:       81000054         BNE L11
; B4C:       0A5241F8         LDR R0, [R6, #21]
; B50:       40915FF8         LDR NL0, [R0, #-7]
; B54:       F1FFFF17         B L9
; B58: L11:  A00322D4         BRK #4125                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R6
; B5C:       3B               BYTE #X3B                       ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; B5D:       .ALIGN           4
; B60: L12:  A0E321D4         BRK #3869                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R5
; B64:       3B               BYTE #X3B                       ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; B65:       .ALIGN           4
; B68: L13:  400080D2         MOVZ NL0, #2
; B6C:       BCFFFF17         B L1
; B70: L14:  A05221D4         BRK #2709                       ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; B74:       E00120D4         BRK #15                         ; Invalid argument count trap
; B78: L15:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; B7C: L16:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
