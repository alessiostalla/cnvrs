; disassembly for CNVRS/RUNTIME:MERGE-CONTEXTS
; Size: 428 bytes. Origin: #x700A9994E4                       ; CNVRS/RUNTIME:MERGE-CONTEXTS
; 4E4:       503F01A9         STP R6, R5, [CFP, #16]
; 4E8:       4D3302A9         STP R3, R2, [CFP, #32]
; 4EC:       7A0300F9         STR CFP, [CSP]
; 4F0:       EA030FAA         MOV R0, R5
; 4F4:       EB0310AA         MOV R1, R6
; 4F8:       56FBFF58         LDR LEXENV, #x700A999460        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; 4FC:       970080D2         MOVZ NARGS, #4
; 500:       FA031BAA         MOV CFP, CSP
; 504:       DE9240F8         LDR LR, [LEXENV, #9]
; 508:       C0033FD6         BLR LR
; 50C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 510:       4D3342A9         LDP R3, R2, [CFP, #32]
; 514:       503F41A9         LDP R6, R5, [CFP, #16]
; 518:       5F011DEB         CMP R0, NULL
; 51C:       80000054         BEQ L0
; 520:       ABE30091         ADD R1, NULL, #56               ; T
; 524:       5F010BEB         CMP R0, R1
; 528:       C10A0054         BNE L14
; 52C: L0:   5F011DEB         CMP R0, NULL
; 530:       61060054         BNE L7
; 534:       E90D4092         AND TMP, R5, #15
; 538:       3F0D00F1         CMP TMP, #3
; 53C:       A1090054         BNE L12
; 540:       EA5140F8         LDR R0, [R5, #5]
; 544:       429145B8         LDR WNL2, [R0, #89]
; 548:       81FAFF18         LDR WNL1, #x700A999498
; 54C:       5F00016B         CMP WNL2, WNL1
; 550:       40090054         BEQ L13
; 554:       429145B8         LDR WNL2, [R0, #89]
; 558:       21FAFF18         LDR WNL1, #x700A99949C
; 55C:       5F00016B         CMP WNL2, WNL1
; 560:       81080054         BNE L12
; 564:       EA5141F8         LDR R0, [R5, #21]
; 568:       40915FF8         LDR NL0, [R0, #-7]
; 56C: L1:   1F0800F1         CMP NL0, #2
; 570:       A0040054         BEQ L8
; 574: L2:   9F011DEB         CMP R2, NULL
; 578:       40030054         BEQ L6
; 57C:       EBF7FF58         LDR R1, #x700A999478            ; 'CNVRS/RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; 580:       61515FB8         LDR WNL1, [R1, #-11]
; 584:       AA6A61F8         LDR R0, [THREAD, NL1]
; 588:       5F0500B1         CMN R0, #1
; 58C:       41000054         BNE L3
; 590:       6A1140F8         LDR R0, [R1, #1]
; 594: L3:   5F2500F1         CMP R0, #9
; 598:       80070054         BEQ L15
; 59C:       FF010AEB         CMP R5, R0
; 5A0:       E0020054         BEQ L7
; 5A4:       ABF6FF58         LDR R1, #x700A999478            ; 'CNVRS/RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; 5A8:       61515FB8         LDR WNL1, [R1, #-11]
; 5AC:       AA6A61F8         LDR R0, [THREAD, NL1]
; 5B0:       5F0500B1         CMN R0, #1
; 5B4:       41000054         BNE L4
; 5B8:       6A1140F8         LDR R0, [R1, #1]
; 5BC: L4:   5F2500F1         CMP R0, #9
; 5C0:       60060054         BEQ L16
; 5C4:       1F020AEB         CMP R6, R0
; 5C8:       C1000054         BNE L6
; 5CC:       EA0310AA         MOV R0, R6
; 5D0: L5:   FB031AAA         MOV CSP, CFP
; 5D4:       5A7B40A9         LDP CFP, LR, [CFP]
; 5D8:       BF0300F1         CMP NULL, #0
; 5DC:       C0035FD6         RET
; 5E0: L6:   EA030FAA         MOV R0, R5
; 5E4:       EB0310AA         MOV R1, R6
; 5E8:       16F4FF58         LDR LEXENV, #x700A999468        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-ARRAYS>
; 5EC:       170180D2         MOVZ NARGS, #8
; 5F0:       DE9240F8         LDR LR, [LEXENV, #9]
; 5F4:       DE130091         ADD LR, LR, #4
; 5F8:       C0031FD6         BR LR
; 5FC: L7:   EA030FAA         MOV R0, R5
; 600:       F4FFFF17         B L5
; 604: L8:   090E4092         AND TMP, R6, #15
; 608:       3F0D00F1         CMP TMP, #3
; 60C:       E1020054         BNE L11
; 610:       0A5240F8         LDR R0, [R6, #5]
; 614:       429145B8         LDR WNL2, [R0, #89]
; 618:       01F4FF18         LDR WNL1, #x700A999498
; 61C:       5F00016B         CMP WNL2, WNL1
; 620:       61010054         BNE L10
; 624:       400080D2         MOVZ NL0, #2
; 628: L9:   1F0800F1         CMP NL0, #2
; 62C:       41FAFF54         BNE L2
; 630:       EA030FAA         MOV R0, R5
; 634:       EB0310AA         MOV R1, R6
; 638:       D6F1FF58         LDR LEXENV, #x700A999470        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-SINGLETONS>
; 63C:       170180D2         MOVZ NARGS, #8
; 640:       DE9240F8         LDR LR, [LEXENV, #9]
; 644:       DE130091         ADD LR, LR, #4
; 648:       C0031FD6         BR LR
; 64C: L10:  429145B8         LDR WNL2, [R0, #89]
; 650:       61F2FF18         LDR WNL1, #x700A99949C
; 654:       5F00016B         CMP WNL2, WNL1
; 658:       81000054         BNE L11
; 65C:       0A5241F8         LDR R0, [R6, #21]
; 660:       40915FF8         LDR NL0, [R0, #-7]
; 664:       F1FFFF17         B L9
; 668: L11:  A00322D4         BRK #4125                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R6
; 66C:       33               BYTE #X33                       ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 66D:       .ALIGN           4
; 670: L12:  A0E321D4         BRK #3869                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R5
; 674:       33               BYTE #X33                       ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 675:       .ALIGN           4
; 678: L13:  400080D2         MOVZ NL0, #2
; 67C:       BCFFFF17         B L1
; 680: L14:  A05221D4         BRK #2709                       ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; 684:       E00120D4         BRK #15                         ; Invalid argument count trap
; 688: L15:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 68C: L16:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
