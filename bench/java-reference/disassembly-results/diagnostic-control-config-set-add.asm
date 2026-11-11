; disassembly for DIAGNOSTIC-CONTROL-CONFIG-SET-ADD
; Size: 1120 bytes. Origin: #x70055B3408                      ; DIAGNOSTIC-CONTROL-CONFIG-SET-ADD
; 408:       4A0B40F9         LDR R0, [CFP, #16]
; 40C:       410D4092         AND NL1, R0, #15
; 410:       3F0C00F1         CMP NL1, #3
; 414:       61210054         BNE L16
; 418:       4E5140F8         LDR R4, [R0, #5]
; 41C:       C25145B8         LDR WNL2, [R4, #85]
; 420:       81FBFF18         LDR WNL1, #x70055B3390
; 424:       5F00016B         CMP WNL2, WNL1
; 428:       C1200054         BNE L16
; 42C:       4A0B40F9         LDR R0, [CFP, #16]
; 430:       4A5144F8         LDR R0, [R0, #69]
; 434:       5F011DEB         CMP R0, NULL
; 438:       811F0054         BNE L15
; 43C:       010E4092         AND NL1, R6, #15
; 440:       3F0C00F1         CMP NL1, #3
; 444:       E11E0054         BNE L14
; 448:       0E5240F8         LDR R4, [R6, #5]
; 44C:       C25145B8         LDR WNL2, [R4, #85]
; 450:       21FAFF18         LDR WNL1, #x70055B3394
; 454:       5F00016B         CMP WNL2, WNL1
; 458:       411E0054         BNE L14
; 45C:       0A5242F8         LDR R0, [R6, #37]
; 460:       ABE30091         ADD R1, NULL, #56               ; T
; 464:       5F010BEB         CMP R0, R1
; 468:       80000054         BEQ L0
; 46C:       4A0B40F9         LDR R0, [CFP, #16]
; 470:       ABE30091         ADD R1, NULL, #56               ; T
; 474:       4B5103F8         STR R1, [R0, #53]
; 478: L0:   00D242F8         LDR NL0, [R6, #45]
; 47C:       1F0000F1         CMP NL0, #0
; 480:       8C1C0054         BGT L13
; 484: L1:   00D240F8         LDR NL0, [R6, #13]
; 488:       037C7F92         AND NL3, NL0, #8589934590
; 48C:       005241F8         LDR NL0, [R6, #21]
; 490:       007C7F92         AND NL0, NL0, #8589934590
; 494:       29AA85D2         MOVZ TMP, #11601
; 498:       C993B9F2         MOVK TMP, #52382, LSL #16
; 49C:       007C099B         MUL NL0, NL0, TMP
; 4A0:       007C7F92         AND NL0, NL0, #8589934590
; 4A4:       02C071D3         LSL NL2, NL0, #15
; 4A8:       01FC5193         ASR NL1, NL0, #17
; 4AC:       20F87F92         AND NL0, NL1, #18446744073709551614
; 4B0:       400000AA         ORR NL0, NL2, NL0
; 4B4:       007C7F92         AND NL0, NL0, #8589934590
; 4B8:       69B286D2         MOVZ TMP, #13715
; 4BC:       E970A3F2         MOVK TMP, #7047, LSL #16
; 4C0:       007C099B         MUL NL0, NL0, TMP
; 4C4:       007C7F92         AND NL0, NL0, #8589934590
; 4C8:       600000CA         EOR NL0, NL3, NL0
; 4CC:       02C873D3         LSL NL2, NL0, #13
; 4D0:       01FC5393         ASR NL1, NL0, #19
; 4D4:       20F87F92         AND NL0, NL1, #18446744073709551614
; 4D8:       400000AA         ORR NL0, NL2, NL0
; 4DC:       007C7F92         AND NL0, NL0, #8589934590
; 4E0:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 4E4:       01D99AD2         MOVZ NL1, #54984
; 4E8:       0195B9F2         MOVK NL1, #52392, LSL #16
; 4EC:       2100C0F2         MOVK NL1, #1, LSL #32
; 4F0:       0000018B         ADD NL0, NL0, NL1
; 4F4:       037C7F92         AND NL3, NL0, #8589934590
; 4F8:       0A5242F8         LDR R0, [R6, #37]
; 4FC:       ABE30091         ADD R1, NULL, #56               ; T
; 500:       5F010BEB         CMP R0, R1
; 504:       01170054         BNE L12
; 508:       000080D2         MOVZ NL0, #0
; 50C: L2:   29AA85D2         MOVZ TMP, #11601
; 510:       C993B9F2         MOVK TMP, #52382, LSL #16
; 514:       007C099B         MUL NL0, NL0, TMP
; 518:       007C7F92         AND NL0, NL0, #8589934590
; 51C:       02C071D3         LSL NL2, NL0, #15
; 520:       01FC5193         ASR NL1, NL0, #17
; 524:       20F87F92         AND NL0, NL1, #18446744073709551614
; 528:       400000AA         ORR NL0, NL2, NL0
; 52C:       007C7F92         AND NL0, NL0, #8589934590
; 530:       69B286D2         MOVZ TMP, #13715
; 534:       E970A3F2         MOVK TMP, #7047, LSL #16
; 538:       007C099B         MUL NL0, NL0, TMP
; 53C:       007C7F92         AND NL0, NL0, #8589934590
; 540:       600000CA         EOR NL0, NL3, NL0
; 544:       02C873D3         LSL NL2, NL0, #13
; 548:       01FC5393         ASR NL1, NL0, #19
; 54C:       20F87F92         AND NL0, NL1, #18446744073709551614
; 550:       400000AA         ORR NL0, NL2, NL0
; 554:       007C7F92         AND NL0, NL0, #8589934590
; 558:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 55C:       01D99AD2         MOVZ NL1, #54984
; 560:       0195B9F2         MOVK NL1, #52392, LSL #16
; 564:       2100C0F2         MOVK NL1, #1, LSL #32
; 568:       0000018B         ADD NL0, NL0, NL1
; 56C:       007C7F92         AND NL0, NL0, #8589934590
; 570:       00047DD2         EOR NL0, NL0, #24
; 574:       01FC5093         ASR NL1, NL0, #16
; 578:       22F87F92         AND NL2, NL1, #18446744073709551614
; 57C:       000002CA         EOR NL0, NL0, NL2
; 580:       694D99D2         MOVZ TMP, #51819
; 584:       69BDB0F2         MOVK TMP, #34283, LSL #16
; 588:       007C099B         MUL NL0, NL0, TMP
; 58C:       007C7F92         AND NL0, NL0, #8589934590
; 590:       01FC4D93         ASR NL1, NL0, #13
; 594:       22F87F92         AND NL2, NL1, #18446744073709551614
; 598:       000002CA         EOR NL0, NL0, NL2
; 59C:       A9C695D2         MOVZ TMP, #44597
; 5A0:       4956B8F2         MOVK TMP, #49842, LSL #16
; 5A4:       007C099B         MUL NL0, NL0, TMP
; 5A8:       007C7F92         AND NL0, NL0, #8589934590
; 5AC:       01FC5093         ASR NL1, NL0, #16
; 5B0:       22F87F92         AND NL2, NL1, #18446744073709551614
; 5B4:       000002CA         EOR NL0, NL0, NL2
; 5B8:       501700F9         STR R6, [CFP, #40]
; 5BC:       401300F9         STR NL0, [CFP, #32]
; 5C0:       4A0B40F9         LDR R0, [CFP, #16]
; 5C4:       4B5141F8         LDR R1, [R0, #21]
; 5C8:       7A0300F9         STR CFP, [CSP]
; 5CC:       4A1340F9         LDR R0, [CFP, #32]
; 5D0:       EC031DAA         MOV R2, NULL
; 5D4:       F6E9FF58         LDR LEXENV, #x70055B3310        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 5D8:       FA031BAA         MOV CFP, CSP
; 5DC:       DE9240F8         LDR LR, [LEXENV, #9]
; 5E0:       C0033FD6         BLR LR
; 5E4:       FB0319AA         MOV CSP, OCFP
; 5E8:       501740F9         LDR R6, [CFP, #40]
; 5EC:       EB030AAA         MOV R1, R0
; 5F0:       4AE9FF58         LDR R0, #x70055B3318            ; #<SB-KERNEL:FDEFN CONFIG-LOOKUP-EQUAL>
; 5F4:       4D1140F8         LDR R3, [R0, #1]
; 5F8:       BF011DEB         CMP R3, NULL
; 5FC:       C0120054         BEQ L17
; 600:       7A0300F9         STR CFP, [CSP]
; 604:       EA0310AA         MOV R0, R6
; 608:       4CEAFF58         LDR R2, #x70055B3350            ; :TEST
; 60C:       B6E8FF58         LDR LEXENV, #x70055B3320        ; #<SB-KERNEL:FDEFN FIND>
; 610:       170180D2         MOVZ NARGS, #8
; 614:       FA031BAA         MOV CFP, CSP
; 618:       DE9240F8         LDR LR, [LEXENV, #9]
; 61C:       C0033FD6         BLR LR
; 620:       501740F9         LDR R6, [CFP, #40]
; 624:       EF030AAA         MOV R5, R0
; 628:       FF011DEB         CMP R5, NULL
; 62C:       00080054         BEQ L9
; 630:       E10D4092         AND NL1, R5, #15
; 634:       3F0C00F1         CMP NL1, #3
; 638:       61070054         BNE L8
; 63C:       EE5140F8         LDR R4, [R5, #5]
; 640:       C25145B8         LDR WNL2, [R4, #85]
; 644:       81EAFF18         LDR WNL1, #x70055B3394
; 648:       5F00016B         CMP WNL2, WNL1
; 64C:       C1060054         BNE L8
; 650:       EBD141F8         LDR R1, [R5, #29]
; 654:       0CD241F8         LDR R2, [R6, #29]
; 658:       4A0B40F9         LDR R0, [CFP, #16]
; 65C:       4AD141F8         LDR R0, [R0, #29]
; 660:       5F011DEB         CMP R0, NULL
; 664:       AAE30091         ADD R0, NULL, #56               ; T
; 668:       4D019D9A         CSEL R3, R0, NULL, EQ
; 66C:       50BF02A9         STP R6, R5, [CFP, #40]
; 670:       7A0300F9         STR CFP, [CSP]
; 674:       EA030BAA         MOV R0, R1
; 678:       EB030CAA         MOV R1, R2
; 67C:       EC030DAA         MOV R2, R3
; 680:       4D0F40F9         LDR R3, [CFP, #24]
; 684:       36E5FF58         LDR LEXENV, #x70055B3328        ; #<SB-KERNEL:FDEFN MERGE-CONTEXTS>
; 688:       170180D2         MOVZ NARGS, #8
; 68C:       FA031BAA         MOV CFP, CSP
; 690:       DE9240F8         LDR LR, [LEXENV, #9]
; 694:       C0033FD6         BLR LR
; 698:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 69C:       50BF42A9         LDP R6, R5, [CFP, #40]
; 6A0:       5F011DEB         CMP R0, NULL
; 6A4:       20010054         BEQ L3
; 6A8:       410D4092         AND NL1, R0, #15
; 6AC:       3F0C00F1         CMP NL1, #3
; 6B0:       61030054         BNE L7
; 6B4:       4E5140F8         LDR R4, [R0, #5]
; 6B8:       C25145B8         LDR WNL2, [R4, #85]
; 6BC:       E1E6FF18         LDR WNL1, #x70055B3398
; 6C0:       5F00016B         CMP WNL2, WNL1
; 6C4:       C1020054         BNE L7
; 6C8: L3:   E9794BD3         UBFM TMP, R5, #11, #30
; 6CC:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 6D0:       EAD101F8         STR R0, [R5, #29]
; 6D4:       E0D142F8         LDR NL0, [R5, #45]
; 6D8:       01D242F8         LDR NL1, [R6, #45]
; 6DC:       1F0001EB         CMP NL0, NL1
; 6E0:       20B0809A         CSEL NL0, NL1, NL0, LT
; 6E4:       E0D102F8         STR NL0, [R5, #45]
; 6E8:       EA5143F8         LDR R0, [R5, #53]
; 6EC:       5F011DEB         CMP R0, NULL
; 6F0:       20010054         BEQ L6
; 6F4: L4:   E9794BD3         UBFM TMP, R5, #11, #30
; 6F8:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 6FC:       EA5103F8         STR R0, [R5, #53]
; 700: L5:   AAE30091         ADD R0, NULL, #56               ; T
; 704:       FB031AAA         MOV CSP, CFP
; 708:       5A7B40A9         LDP CFP, LR, [CFP]
; 70C:       BF0300F1         CMP NULL, #0
; 710:       C0035FD6         RET
; 714: L6:   0A5243F8         LDR R0, [R6, #53]
; 718:       F7FFFF17         B L4
; 71C: L7:   604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 720:       47               BYTE #X47                       ; '(OR NULL
                                                              ;      PREDICTION-CONTEXT)
; 721:       .ALIGN           4
; 724: L8:   60E321D4         BRK #3867                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; 728:       4B               BYTE #X4B                       ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 729:       .ALIGN           4
; 72C: L9:   501700F9         STR R6, [CFP, #40]
; 730:       4A0B40F9         LDR R0, [CFP, #16]
; 734:       4D5141F8         LDR R3, [R0, #21]
; 738:       4D0F00F9         STR R3, [CFP, #24]
; 73C:       7A0300F9         STR CFP, [CSP]
; 740:       4A1340F9         LDR R0, [CFP, #32]
; 744:       EB030DAA         MOV R1, R3
; 748:       EC031DAA         MOV R2, NULL
; 74C:       36DEFF58         LDR LEXENV, #x70055B3310        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 750:       FA031BAA         MOV CFP, CSP
; 754:       DE9240F8         LDR LR, [LEXENV, #9]
; 758:       C0033FD6         BLR LR
; 75C:       FB0319AA         MOV CSP, OCFP
; 760:       4D0F40F9         LDR R3, [CFP, #24]
; 764:       501740F9         LDR R6, [CFP, #40]
; 768:       EB0310AA         MOV R1, R6
; 76C:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 770:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; 774:       2C410091         ADD R2, TMP, #16
; 778:       9F011EEB         CMP R2, LR
; 77C:       E8060054         BHI L18
; 780:       AC2E00F9         STR R2, [THREAD, #88]           ; cons-tlab
; 784: L10:  2C1D0091         ADD R2, TMP, #7
; 788:       2B2900A9         STP R1, R0, [TMP]
; 78C:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 790:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 794:       5E0000B4         CBZ LR, L11
; 798:       200120D4         BRK #9                          ; Pending interrupt trap
; 79C: L11:  7A0300F9         STR CFP, [CSP]
; 7A0:       4A1340F9         LDR R0, [CFP, #32]
; 7A4:       EB030DAA         MOV R1, R3
; 7A8:       56DCFF58         LDR LEXENV, #x70055B3330        ; #<SB-KERNEL:FDEFN SB-KERNEL:%PUTHASH>
; 7AC:       FA031BAA         MOV CFP, CSP
; 7B0:       DE9240F8         LDR LR, [LEXENV, #9]
; 7B4:       C0033FD6         BLR LR
; 7B8:       501740F9         LDR R6, [CFP, #40]
; 7BC:       4A0B40F9         LDR R0, [CFP, #16]
; 7C0:       4BD140F8         LDR R1, [R0, #13]
; 7C4:       7A0300F9         STR CFP, [CSP]
; 7C8:       EA0310AA         MOV R0, R6
; 7CC:       76DBFF58         LDR LEXENV, #x70055B3338        ; #<SB-KERNEL:FDEFN VECTOR-PUSH-EXTEND>
; 7D0:       970080D2         MOVZ NARGS, #4
; 7D4:       FA031BAA         MOV CFP, CSP
; 7D8:       DE9240F8         LDR LR, [LEXENV, #9]
; 7DC:       C0033FD6         BLR LR
; 7E0:       C8FFFF17         B L5
; 7E4: L12:  434302A9         STP NL3, R6, [CFP, #32]
; 7E8:       0A5242F8         LDR R0, [R6, #37]
; 7EC:       7A0300F9         STR CFP, [CSP]
; 7F0:       96DAFF58         LDR LEXENV, #x70055B3340        ; #<SB-KERNEL:FDEFN SXHASH>
; 7F4:       570080D2         MOVZ NARGS, #2
; 7F8:       FA031BAA         MOV CFP, CSP
; 7FC:       DE9240F8         LDR LR, [LEXENV, #9]
; 800:       C0033FD6         BLR LR
; 804:       434342A9         LDP NL3, R6, [CFP, #32]
; 808:       407D7F92         AND NL0, R0, #8589934590
; 80C:       40FFFF17         B L2
; 810: L13:  4A0B40F9         LDR R0, [CFP, #16]
; 814:       ABE30091         ADD R1, NULL, #56               ; T
; 818:       4BD103F8         STR R1, [R0, #61]
; 81C:       1AFFFF17         B L1
; 820: L14:  600322D4         BRK #4123                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R6
; 824:       4B               BYTE #X4B                       ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 825:       .ALIGN           4
; 828: L15:  0ADAFF58         LDR R0, #x70055B3368            ; "ATNConfigSet is read-only"
; 82C:       570080D2         MOVZ NARGS, #2
; 830:       29D280D2         MOVZ TMP, #1681
; 834:       BE6B69F8         LDR LR, [NULL, TMP]             ; ERROR
; 838:       DE130091         ADD LR, LR, #4
; 83C:       C0031FD6         BR LR
; 840: L16:  4A0B40F9         LDR R0, [CFP, #16]
; 844:       604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 848:       53               BYTE #X53                       ; #<SB-KERNEL:LAYOUT (ID=396) for ATN-CONFIG-SET {700CD64883}>
; 849:       .ALIGN           4
; 84C:       E00120D4         BRK #15                         ; Invalid argument count trap
; 850:       E08221D4         BRK #3095                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; 854: L17:  204221D4         BRK #2577                       ; UNDEFINED-FUN-ERROR
                                                              ; R0
; 858: L18:  090280D2         MOVZ TMP, #16
; 85C:       6CD9FF58         LDR R2, #x70055B3388            ; SB-VM::LIST-ALLOC-TRAMP
; 860:       80013FD6         BLR R2
; 864:       C8FFFF17         B L10
