; disassembly for DIAGNOSTIC-CONTROL-MERGE-CACHE-GET
; Size: 564 bytes. Origin: #x70055B44A8                       ; DIAGNOSTIC-CONTROL-MERGE-CACHE-GET
; 4A8:       DF011DEB         CMP R4, NULL
; 4AC:       C1000054         BNE L1
; 4B0:       EA031DAA         MOV R0, NULL
; 4B4: L0:   FB031AAA         MOV CSP, CFP
; 4B8:       5A7B40A9         LDP CFP, LR, [CFP]
; 4BC:       BF0300F1         CMP NULL, #0
; 4C0:       C0035FD6         RET
; 4C4: L1:   4A0B40F9         LDR R0, [CFP, #16]
; 4C8:       5F011DEB         CMP R0, NULL
; 4CC:       20100054         BEQ L15
; 4D0:       4A0B40F9         LDR R0, [CFP, #16]
; 4D4:       410D4092         AND NL1, R0, #15
; 4D8:       3F0C00F1         CMP NL1, #3
; 4DC:       410F0054         BNE L14
; 4E0:       4D5140F8         LDR R3, [R0, #5]
; 4E4:       A25145B8         LDR WNL2, [R3, #85]
; 4E8:       81FCFF18         LDR WNL1, #x70055B4478
; 4EC:       5F00016B         CMP WNL2, WNL1
; 4F0:       A10E0054         BNE L14
; 4F4:       4A0B40F9         LDR R0, [CFP, #16]
; 4F8:       40D140F8         LDR NL0, [R0, #13]
; 4FC: L2:   4A0F40F9         LDR R0, [CFP, #24]
; 500:       5F011DEB         CMP R0, NULL
; 504:       C00D0054         BEQ L13
; 508:       4A0F40F9         LDR R0, [CFP, #24]
; 50C:       410D4092         AND NL1, R0, #15
; 510:       3F0C00F1         CMP NL1, #3
; 514:       E10C0054         BNE L12
; 518:       4D5140F8         LDR R3, [R0, #5]
; 51C:       A25145B8         LDR WNL2, [R3, #85]
; 520:       C1FAFF18         LDR WNL1, #x70055B4478
; 524:       5F00016B         CMP WNL2, WNL1
; 528:       410C0054         BNE L12
; 52C:       4A0F40F9         LDR R0, [CFP, #24]
; 530:       41D140F8         LDR NL1, [R0, #13]
; 534: L3:   0A0001CA         EOR R0, NL0, NL1
; 538:       7A0300F9         STR CFP, [CSP]
; 53C:       EB030EAA         MOV R1, R4
; 540:       EC031DAA         MOV R2, NULL
; 544:       76F8FF58         LDR LEXENV, #x70055B4450        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 548:       FA031BAA         MOV CFP, CSP
; 54C:       DE9240F8         LDR LR, [LEXENV, #9]
; 550:       C0033FD6         BLR LR
; 554:       FB0319AA         MOV CSP, OCFP
; 558:       EE030AAA         MOV R4, R0
; 55C: L4:   C10D4092         AND NL1, R4, #15
; 560:       3F1C00F1         CMP NL1, #7
; 564:       410A0054         BNE L11
; 568:       DF011DEB         CMP R4, NULL
; 56C:       C0090054         BEQ L10
; 570:       CA915FF8         LDR R0, [R4, #-7]
; 574:       410D4092         AND NL1, R0, #15
; 578:       3F1C00F1         CMP NL1, #7
; 57C:       21090054         BNE L9
; 580:       4C915FF8         LDR R2, [R0, #-7]
; 584:       4A1140F8         LDR R0, [R0, #1]
; 588:       410D4092         AND NL1, R0, #15
; 58C:       3F1C00F1         CMP NL1, #7
; 590:       61080054         BNE L8
; 594:       4B915FF8         LDR R1, [R0, #-7]
; 598:       4B1300F9         STR R1, [CFP, #32]
; 59C:       4A1140F8         LDR R0, [R0, #1]
; 5A0:       410D4092         AND NL1, R0, #15
; 5A4:       3F1C00F1         CMP NL1, #7
; 5A8:       81070054         BNE L7
; 5AC:       4C1F00F9         STR R2, [CFP, #56]
; 5B0:       4A915FF8         LDR R0, [R0, #-7]
; 5B4:       4A1700F9         STR R0, [CFP, #40]
; 5B8:       CA1140F8         LDR R0, [R4, #1]
; 5BC:       EE030AAA         MOV R4, R0
; 5C0:       4E1B00F9         STR R4, [CFP, #48]
; 5C4:       EA030CAA         MOV R0, R2
; 5C8:       7A0300F9         STR CFP, [CSP]
; 5CC:       4B0B40F9         LDR R1, [CFP, #16]
; 5D0:       56F4FF58         LDR LEXENV, #x70055B4458        ; #<SB-KERNEL:FDEFN CONTEXT-EQUAL>
; 5D4:       970080D2         MOVZ NARGS, #4
; 5D8:       FA031BAA         MOV CFP, CSP
; 5DC:       DE9240F8         LDR LR, [LEXENV, #9]
; 5E0:       C0033FD6         BLR LR
; 5E4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 5E8:       4E3343A9         LDP R4, R2, [CFP, #48]
; 5EC:       5F011DEB         CMP R0, NULL
; 5F0:       C0010054         BEQ L5
; 5F4:       4E3303A9         STP R4, R2, [CFP, #48]
; 5F8:       4A1340F9         LDR R0, [CFP, #32]
; 5FC:       7A0300F9         STR CFP, [CSP]
; 600:       4B0F40F9         LDR R1, [CFP, #24]
; 604:       B6F2FF58         LDR LEXENV, #x70055B4458        ; #<SB-KERNEL:FDEFN CONTEXT-EQUAL>
; 608:       970080D2         MOVZ NARGS, #4
; 60C:       FA031BAA         MOV CFP, CSP
; 610:       DE9240F8         LDR LR, [LEXENV, #9]
; 614:       C0033FD6         BLR LR
; 618:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 61C:       4E3343A9         LDP R4, R2, [CFP, #48]
; 620:       5F011DEB         CMP R0, NULL
; 624:       61030054         BNE L6
; 628: L5:   4E1B00F9         STR R4, [CFP, #48]
; 62C:       EA030CAA         MOV R0, R2
; 630:       7A0300F9         STR CFP, [CSP]
; 634:       4B0F40F9         LDR R1, [CFP, #24]
; 638:       16F1FF58         LDR LEXENV, #x70055B4458        ; #<SB-KERNEL:FDEFN CONTEXT-EQUAL>
; 63C:       970080D2         MOVZ NARGS, #4
; 640:       FA031BAA         MOV CFP, CSP
; 644:       DE9240F8         LDR LR, [LEXENV, #9]
; 648:       C0033FD6         BLR LR
; 64C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 650:       4E1B40F9         LDR R4, [CFP, #48]
; 654:       5F011DEB         CMP R0, NULL
; 658:       20F8FF54         BEQ L4
; 65C:       4E1B00F9         STR R4, [CFP, #48]
; 660:       4A1340F9         LDR R0, [CFP, #32]
; 664:       7A0300F9         STR CFP, [CSP]
; 668:       4B0B40F9         LDR R1, [CFP, #16]
; 66C:       76EFFF58         LDR LEXENV, #x70055B4458        ; #<SB-KERNEL:FDEFN CONTEXT-EQUAL>
; 670:       970080D2         MOVZ NARGS, #4
; 674:       FA031BAA         MOV CFP, CSP
; 678:       DE9240F8         LDR LR, [LEXENV, #9]
; 67C:       C0033FD6         BLR LR
; 680:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 684:       4E1B40F9         LDR R4, [CFP, #48]
; 688:       5F011DEB         CMP R0, NULL
; 68C:       80F6FF54         BEQ L4
; 690: L6:   4A1740F9         LDR R0, [CFP, #40]
; 694:       88FFFF17         B L0
; 698: L7:   E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 69C: L8:   E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 6A0: L9:   E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 6A4: L10:  EA031DAA         MOV R0, NULL
; 6A8:       83FFFF17         B L0
; 6AC: L11:  E0C921D4         BRK #3663                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R4
; 6B0: L12:  4A0F40F9         LDR R0, [CFP, #24]
; 6B4:       604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 6B8:       2B               BYTE #X2B                       ; #<SB-KERNEL:LAYOUT (ID=389) for PREDICTION-CONTEXT {700CD64503}>
; 6B9:       .ALIGN           4
; 6BC: L13:  010080D2         MOVZ NL1, #0
; 6C0:       9DFFFF17         B L3
; 6C4: L14:  4A0B40F9         LDR R0, [CFP, #16]
; 6C8:       604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 6CC:       2B               BYTE #X2B                       ; #<SB-KERNEL:LAYOUT (ID=389) for PREDICTION-CONTEXT {700CD64503}>
; 6CD:       .ALIGN           4
; 6D0: L15:  000080D2         MOVZ NL0, #0
; 6D4:       8AFFFF17         B L2
; 6D8:       E00120D4         BRK #15                         ; Invalid argument count trap
