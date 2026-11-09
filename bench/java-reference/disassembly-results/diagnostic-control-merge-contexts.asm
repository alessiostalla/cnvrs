; disassembly for DIAGNOSTIC-CONTROL-MERGE-CONTEXTS
; Size: 404 bytes. Origin: #x70055B4274                       ; DIAGNOSTIC-CONTROL-MERGE-CONTEXTS
; 274:       503F01A9         STP R6, R5, [CFP, #16]
; 278:       4D3302A9         STP R3, R2, [CFP, #32]
; 27C:       7A0300F9         STR CFP, [CSP]
; 280:       EA030FAA         MOV R0, R5
; 284:       EB0310AA         MOV R1, R6
; 288:       56FBFF58         LDR LEXENV, #x70055B41F0        ; #<SB-KERNEL:FDEFN CONTEXT-EQUAL>
; 28C:       970080D2         MOVZ NARGS, #4
; 290:       FA031BAA         MOV CFP, CSP
; 294:       DE9240F8         LDR LR, [LEXENV, #9]
; 298:       C0033FD6         BLR LR
; 29C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 2A0:       4D3342A9         LDP R3, R2, [CFP, #32]
; 2A4:       503F41A9         LDP R6, R5, [CFP, #16]
; 2A8:       5F011DEB         CMP R0, NULL
; 2AC:       C0000054         BEQ L2
; 2B0: L0:   EA030FAA         MOV R0, R5
; 2B4: L1:   FB031AAA         MOV CSP, CFP
; 2B8:       5A7B40A9         LDP CFP, LR, [CFP]
; 2BC:       BF0300F1         CMP NULL, #0
; 2C0:       C0035FD6         RET
; 2C4: L2:   E90D4092         AND TMP, R5, #15
; 2C8:       3F0D00F1         CMP TMP, #3
; 2CC:       01090054         BNE L12
; 2D0:       EA5140F8         LDR R0, [R5, #5]
; 2D4:       429145B8         LDR WNL2, [R0, #89]
; 2D8:       81FAFF18         LDR WNL1, #x70055B4228
; 2DC:       5F00016B         CMP WNL2, WNL1
; 2E0:       A0080054         BEQ L13
; 2E4:       429145B8         LDR WNL2, [R0, #89]
; 2E8:       21FAFF18         LDR WNL1, #x70055B422C
; 2EC:       5F00016B         CMP WNL2, WNL1
; 2F0:       E1070054         BNE L12
; 2F4:       EA5141F8         LDR R0, [R5, #21]
; 2F8:       40915FF8         LDR NL0, [R0, #-7]
; 2FC: L3:   1F0800F1         CMP NL0, #2
; 300:       00040054         BEQ L8
; 304: L4:   9F011DEB         CMP R2, NULL
; 308:       E0020054         BEQ L7
; 30C:       EBF7FF58         LDR R1, #x70055B4208            ; '*EMPTY-PREDICTION-CONTEXT*
; 310:       61515FB8         LDR WNL1, [R1, #-11]
; 314:       AA6A61F8         LDR R0, [THREAD, NL1]
; 318:       5F0500B1         CMN R0, #1
; 31C:       41000054         BNE L5
; 320:       6A1140F8         LDR R0, [R1, #1]
; 324: L5:   5F2500F1         CMP R0, #9
; 328:       C0060054         BEQ L14
; 32C:       FF010AEB         CMP R5, R0
; 330:       00FCFF54         BEQ L0
; 334:       ABF6FF58         LDR R1, #x70055B4208            ; '*EMPTY-PREDICTION-CONTEXT*
; 338:       61515FB8         LDR WNL1, [R1, #-11]
; 33C:       AA6A61F8         LDR R0, [THREAD, NL1]
; 340:       5F0500B1         CMN R0, #1
; 344:       41000054         BNE L6
; 348:       6A1140F8         LDR R0, [R1, #1]
; 34C: L6:   5F2500F1         CMP R0, #9
; 350:       A0050054         BEQ L15
; 354:       1F020AEB         CMP R6, R0
; 358:       61000054         BNE L7
; 35C:       EA0310AA         MOV R0, R6
; 360:       D5FFFF17         B L1
; 364: L7:   EA030FAA         MOV R0, R5
; 368:       EB0310AA         MOV R1, R6
; 36C:       76F4FF58         LDR LEXENV, #x70055B41F8        ; #<SB-KERNEL:FDEFN MERGE-ARRAYS>
; 370:       170180D2         MOVZ NARGS, #8
; 374:       DE9240F8         LDR LR, [LEXENV, #9]
; 378:       DE130091         ADD LR, LR, #4
; 37C:       C0031FD6         BR LR
; 380: L8:   090E4092         AND TMP, R6, #15
; 384:       3F0D00F1         CMP TMP, #3
; 388:       E1020054         BNE L11
; 38C:       0A5240F8         LDR R0, [R6, #5]
; 390:       429145B8         LDR WNL2, [R0, #89]
; 394:       A1F4FF18         LDR WNL1, #x70055B4228
; 398:       5F00016B         CMP WNL2, WNL1
; 39C:       61010054         BNE L10
; 3A0:       400080D2         MOVZ NL0, #2
; 3A4: L9:   1F0800F1         CMP NL0, #2
; 3A8:       E1FAFF54         BNE L4
; 3AC:       EA030FAA         MOV R0, R5
; 3B0:       EB0310AA         MOV R1, R6
; 3B4:       76F2FF58         LDR LEXENV, #x70055B4200        ; #<SB-KERNEL:FDEFN MERGE-SINGLETONS>
; 3B8:       170180D2         MOVZ NARGS, #8
; 3BC:       DE9240F8         LDR LR, [LEXENV, #9]
; 3C0:       DE130091         ADD LR, LR, #4
; 3C4:       C0031FD6         BR LR
; 3C8: L10:  429145B8         LDR WNL2, [R0, #89]
; 3CC:       01F3FF18         LDR WNL1, #x70055B422C
; 3D0:       5F00016B         CMP WNL2, WNL1
; 3D4:       81000054         BNE L11
; 3D8:       0A5241F8         LDR R0, [R6, #21]
; 3DC:       40915FF8         LDR NL0, [R0, #-7]
; 3E0:       F1FFFF17         B L9
; 3E4: L11:  A00322D4         BRK #4125                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R6
; 3E8:       33               BYTE #X33                       ; '(SINGLETON-PREDICTION-CONTEXT
                                                              ;   ARRAY-PREDICTION-CONTEXT)
; 3E9:       .ALIGN           4
; 3EC: L12:  A0E321D4         BRK #3869                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R5
; 3F0:       37               BYTE #X37                       ; '(SINGLETON-PREDICTION-CONTEXT
                                                              ;   ARRAY-PREDICTION-CONTEXT)
; 3F1:       .ALIGN           4
; 3F4: L13:  400080D2         MOVZ NL0, #2
; 3F8:       C1FFFF17         B L3
; 3FC:       E00120D4         BRK #15                         ; Invalid argument count trap
; 400: L14:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 404: L15:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
