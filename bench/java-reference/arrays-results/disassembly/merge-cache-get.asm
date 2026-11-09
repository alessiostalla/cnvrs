; disassembly for CNVRS/RUNTIME::MERGE-CACHE-GET
; Size: 520 bytes. Origin: #x700D72F4E8                       ; CNVRS/RUNTIME::MERGE-CACHE-GET
; 4E8:       DF011DEB         CMP R4, NULL
; 4EC:       C1000054         BNE L1
; 4F0:       EA031DAA         MOV R0, NULL
; 4F4: L0:   FB031AAA         MOV CSP, CFP
; 4F8:       5A7B40A9         LDP CFP, LR, [CFP]
; 4FC:       BF0300F1         CMP NULL, #0
; 500:       C0035FD6         RET
; 504: L1:   4A0B40F9         LDR R0, [CFP, #16]
; 508:       5F011DEB         CMP R0, NULL
; 50C:       C00E0054         BEQ L17
; 510:       4A0B40F9         LDR R0, [CFP, #16]
; 514:       40D140F8         LDR NL0, [R0, #13]
; 518: L2:   4A0F40F9         LDR R0, [CFP, #24]
; 51C:       5F011DEB         CMP R0, NULL
; 520:       E00D0054         BEQ L16
; 524:       4A0F40F9         LDR R0, [CFP, #24]
; 528:       41D140F8         LDR NL1, [R0, #13]
; 52C: L3:   010001CA         EOR NL1, NL0, NL1
; 530:       7A0300F9         STR CFP, [CSP]
; 534:       EA0301AA         MOV R0, NL1
; 538:       EB030EAA         MOV R1, R4
; 53C:       EC031DAA         MOV R2, NULL
; 540:       16F6FF58         LDR LEXENV, #x700D72F400        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 544:       FA031BAA         MOV CFP, CSP
; 548:       DE9240F8         LDR LR, [LEXENV, #9]
; 54C:       C0033FD6         BLR LR
; 550:       FB0319AA         MOV CSP, OCFP
; 554:       EE030AAA         MOV R4, R0
; 558: L4:   C10D4092         AND NL1, R4, #15
; 55C:       3F1C00F1         CMP NL1, #7
; 560:       C10B0054         BNE L15
; 564:       DF011DEB         CMP R4, NULL
; 568:       400B0054         BEQ L14
; 56C:       CA915FF8         LDR R0, [R4, #-7]
; 570:       410D4092         AND NL1, R0, #15
; 574:       3F1C00F1         CMP NL1, #7
; 578:       A10A0054         BNE L13
; 57C:       4C915FF8         LDR R2, [R0, #-7]
; 580:       4A1140F8         LDR R0, [R0, #1]
; 584:       410D4092         AND NL1, R0, #15
; 588:       3F1C00F1         CMP NL1, #7
; 58C:       E1090054         BNE L12
; 590:       4B915FF8         LDR R1, [R0, #-7]
; 594:       4B1300F9         STR R1, [CFP, #32]
; 598:       4A1140F8         LDR R0, [R0, #1]
; 59C:       410D4092         AND NL1, R0, #15
; 5A0:       3F1C00F1         CMP NL1, #7
; 5A4:       01090054         BNE L11
; 5A8:       4C1F00F9         STR R2, [CFP, #56]
; 5AC:       4A915FF8         LDR R0, [R0, #-7]
; 5B0:       4A1700F9         STR R0, [CFP, #40]
; 5B4:       CA1140F8         LDR R0, [R4, #1]
; 5B8:       EE030AAA         MOV R4, R0
; 5BC:       4E1B00F9         STR R4, [CFP, #48]
; 5C0:       EA030CAA         MOV R0, R2
; 5C4:       7A0300F9         STR CFP, [CSP]
; 5C8:       4B0B40F9         LDR R1, [CFP, #16]
; 5CC:       F6F1FF58         LDR LEXENV, #x700D72F408        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; 5D0:       970080D2         MOVZ NARGS, #4
; 5D4:       FA031BAA         MOV CFP, CSP
; 5D8:       DE9240F8         LDR LR, [LEXENV, #9]
; 5DC:       C0033FD6         BLR LR
; 5E0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 5E4:       4E3343A9         LDP R4, R2, [CFP, #48]
; 5E8:       5F011DEB         CMP R0, NULL
; 5EC:       80000054         BEQ L5
; 5F0:       ABE30091         ADD R1, NULL, #56               ; T
; 5F4:       5F010BEB         CMP R0, R1
; 5F8:       41060054         BNE L10
; 5FC: L5:   5F011DEB         CMP R0, NULL
; 600:       C0010054         BEQ L6
; 604:       4E3303A9         STP R4, R2, [CFP, #48]
; 608:       4A1340F9         LDR R0, [CFP, #32]
; 60C:       7A0300F9         STR CFP, [CSP]
; 610:       4B0F40F9         LDR R1, [CFP, #24]
; 614:       B6EFFF58         LDR LEXENV, #x700D72F408        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; 618:       970080D2         MOVZ NARGS, #4
; 61C:       FA031BAA         MOV CFP, CSP
; 620:       DE9240F8         LDR LR, [LEXENV, #9]
; 624:       C0033FD6         BLR LR
; 628:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 62C:       4E3343A9         LDP R4, R2, [CFP, #48]
; 630:       5F011DEB         CMP R0, NULL
; 634:       01040054         BNE L8
; 638: L6:   4E1B00F9         STR R4, [CFP, #48]
; 63C:       EA030CAA         MOV R0, R2
; 640:       7A0300F9         STR CFP, [CSP]
; 644:       4B0F40F9         LDR R1, [CFP, #24]
; 648:       16EEFF58         LDR LEXENV, #x700D72F408        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; 64C:       970080D2         MOVZ NARGS, #4
; 650:       FA031BAA         MOV CFP, CSP
; 654:       DE9240F8         LDR LR, [LEXENV, #9]
; 658:       C0033FD6         BLR LR
; 65C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 660:       4E1B40F9         LDR R4, [CFP, #48]
; 664:       5F011DEB         CMP R0, NULL
; 668:       80000054         BEQ L7
; 66C:       ABE30091         ADD R1, NULL, #56               ; T
; 670:       5F010BEB         CMP R0, R1
; 674:       41020054         BNE L9
; 678: L7:   5F011DEB         CMP R0, NULL
; 67C:       E0F6FF54         BEQ L4
; 680:       4E1B00F9         STR R4, [CFP, #48]
; 684:       4A1340F9         LDR R0, [CFP, #32]
; 688:       7A0300F9         STR CFP, [CSP]
; 68C:       4B0B40F9         LDR R1, [CFP, #16]
; 690:       D6EBFF58         LDR LEXENV, #x700D72F408        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; 694:       970080D2         MOVZ NARGS, #4
; 698:       FA031BAA         MOV CFP, CSP
; 69C:       DE9240F8         LDR LR, [LEXENV, #9]
; 6A0:       C0033FD6         BLR LR
; 6A4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 6A8:       4E1B40F9         LDR R4, [CFP, #48]
; 6AC:       5F011DEB         CMP R0, NULL
; 6B0:       40F5FF54         BEQ L4
; 6B4: L8:   4A1740F9         LDR R0, [CFP, #40]
; 6B8:       8FFFFF17         B L0
; 6BC: L9:   A05221D4         BRK #2709                       ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; 6C0: L10:  A05221D4         BRK #2709                       ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; 6C4: L11:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 6C8: L12:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 6CC: L13:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 6D0: L14:  EA031DAA         MOV R0, NULL
; 6D4:       88FFFF17         B L0
; 6D8: L15:  E0C921D4         BRK #3663                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R4
; 6DC: L16:  010080D2         MOVZ NL1, #0
; 6E0:       93FFFF17         B L3
; 6E4: L17:  000080D2         MOVZ NL0, #0
; 6E8:       8CFFFF17         B L2
; 6EC:       E00120D4         BRK #15                         ; Invalid argument count trap
