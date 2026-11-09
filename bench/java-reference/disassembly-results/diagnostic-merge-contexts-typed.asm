; disassembly for DIAGNOSTIC-MERGE-CONTEXTS-TYPED
; Size: 404 bytes. Origin: #x70055B24D4                       ; DIAGNOSTIC-MERGE-CONTEXTS-TYPED
; 4D4:       503F01A9         STP R6, R5, [CFP, #16]
; 4D8:       4D3302A9         STP R3, R2, [CFP, #32]
; 4DC:       7A0300F9         STR CFP, [CSP]
; 4E0:       EA030FAA         MOV R0, R5
; 4E4:       EB0310AA         MOV R1, R6
; 4E8:       D6F1FF58         LDR LEXENV, #x70055B2320        ; #<SB-KERNEL:FDEFN CONTEXT-EQUAL>
; 4EC:       970080D2         MOVZ NARGS, #4
; 4F0:       FA031BAA         MOV CFP, CSP
; 4F4:       DE9240F8         LDR LR, [LEXENV, #9]
; 4F8:       C0033FD6         BLR LR
; 4FC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 500:       4D3342A9         LDP R3, R2, [CFP, #32]
; 504:       503F41A9         LDP R6, R5, [CFP, #16]
; 508:       5F011DEB         CMP R0, NULL
; 50C:       C0000054         BEQ L2
; 510: L0:   EA030FAA         MOV R0, R5
; 514: L1:   FB031AAA         MOV CSP, CFP
; 518:       5A7B40A9         LDP CFP, LR, [CFP]
; 51C:       BF0300F1         CMP NULL, #0
; 520:       C0035FD6         RET
; 524: L2:   E90D4092         AND TMP, R5, #15
; 528:       3F0D00F1         CMP TMP, #3
; 52C:       01090054         BNE L12
; 530:       EA5140F8         LDR R0, [R5, #5]
; 534:       429145B8         LDR WNL2, [R0, #89]
; 538:       A1F2FF18         LDR WNL1, #x70055B238C
; 53C:       5F00016B         CMP WNL2, WNL1
; 540:       A0080054         BEQ L13
; 544:       429145B8         LDR WNL2, [R0, #89]
; 548:       41F2FF18         LDR WNL1, #x70055B2390
; 54C:       5F00016B         CMP WNL2, WNL1
; 550:       E1070054         BNE L12
; 554:       EA5141F8         LDR R0, [R5, #21]
; 558:       40915FF8         LDR NL0, [R0, #-7]
; 55C: L3:   1F0800F1         CMP NL0, #2
; 560:       00040054         BEQ L8
; 564: L4:   9F011DEB         CMP R2, NULL
; 568:       E0020054         BEQ L7
; 56C:       ABEFFF58         LDR R1, #x70055B2360            ; '*EMPTY-PREDICTION-CONTEXT*
; 570:       61515FB8         LDR WNL1, [R1, #-11]
; 574:       AA6A61F8         LDR R0, [THREAD, NL1]
; 578:       5F0500B1         CMN R0, #1
; 57C:       41000054         BNE L5
; 580:       6A1140F8         LDR R0, [R1, #1]
; 584: L5:   5F2500F1         CMP R0, #9
; 588:       C0060054         BEQ L14
; 58C:       FF010AEB         CMP R5, R0
; 590:       00FCFF54         BEQ L0
; 594:       6BEEFF58         LDR R1, #x70055B2360            ; '*EMPTY-PREDICTION-CONTEXT*
; 598:       61515FB8         LDR WNL1, [R1, #-11]
; 59C:       AA6A61F8         LDR R0, [THREAD, NL1]
; 5A0:       5F0500B1         CMN R0, #1
; 5A4:       41000054         BNE L6
; 5A8:       6A1140F8         LDR R0, [R1, #1]
; 5AC: L6:   5F2500F1         CMP R0, #9
; 5B0:       A0050054         BEQ L15
; 5B4:       1F020AEB         CMP R6, R0
; 5B8:       61000054         BNE L7
; 5BC:       EA0310AA         MOV R0, R6
; 5C0:       D5FFFF17         B L1
; 5C4: L7:   EA030FAA         MOV R0, R5
; 5C8:       EB0310AA         MOV R1, R6
; 5CC:       F6EAFF58         LDR LEXENV, #x70055B2328        ; #<SB-KERNEL:FDEFN MERGE-ARRAYS>
; 5D0:       170180D2         MOVZ NARGS, #8
; 5D4:       DE9240F8         LDR LR, [LEXENV, #9]
; 5D8:       DE130091         ADD LR, LR, #4
; 5DC:       C0031FD6         BR LR
; 5E0: L8:   090E4092         AND TMP, R6, #15
; 5E4:       3F0D00F1         CMP TMP, #3
; 5E8:       E1020054         BNE L11
; 5EC:       0A5240F8         LDR R0, [R6, #5]
; 5F0:       429145B8         LDR WNL2, [R0, #89]
; 5F4:       C1ECFF18         LDR WNL1, #x70055B238C
; 5F8:       5F00016B         CMP WNL2, WNL1
; 5FC:       61010054         BNE L10
; 600:       400080D2         MOVZ NL0, #2
; 604: L9:   1F0800F1         CMP NL0, #2
; 608:       E1FAFF54         BNE L4
; 60C:       EA030FAA         MOV R0, R5
; 610:       EB0310AA         MOV R1, R6
; 614:       F6E8FF58         LDR LEXENV, #x70055B2330        ; #<SB-KERNEL:FDEFN MERGE-SINGLETONS>
; 618:       170180D2         MOVZ NARGS, #8
; 61C:       DE9240F8         LDR LR, [LEXENV, #9]
; 620:       DE130091         ADD LR, LR, #4
; 624:       C0031FD6         BR LR
; 628: L10:  429145B8         LDR WNL2, [R0, #89]
; 62C:       21EBFF18         LDR WNL1, #x70055B2390
; 630:       5F00016B         CMP WNL2, WNL1
; 634:       81000054         BNE L11
; 638:       0A5241F8         LDR R0, [R6, #21]
; 63C:       40915FF8         LDR NL0, [R0, #-7]
; 640:       F1FFFF17         B L9
; 644: L11:  A00322D4         BRK #4125                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R6
; 648:       47               BYTE #X47                       ; '(SINGLETON-PREDICTION-CONTEXT
                                                              ;   ARRAY-PREDICTION-CONTEXT)
; 649:       .ALIGN           4
; 64C: L12:  A0E321D4         BRK #3869                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R5
; 650:       4B               BYTE #X4B                       ; '(SINGLETON-PREDICTION-CONTEXT
                                                              ;   ARRAY-PREDICTION-CONTEXT)
; 651:       .ALIGN           4
; 654: L13:  400080D2         MOVZ NL0, #2
; 658:       C1FFFF17         B L3
; 65C:       E00120D4         BRK #15                         ; Invalid argument count trap
; 660: L14:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 664: L15:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
