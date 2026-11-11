; disassembly for CNVRS/RUNTIME::COMBINE-COMMON-PARENTS
; Size: 528 bytes. Origin: #x700CE015B4                       ; CNVRS/RUNTIME::COMBINE-COMMON-PARENTS
; 5B4:       7A0300F9         STR CFP, [CSP]
; 5B8:       56FDFF58         LDR LEXENV, #x700CE01560        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:MAKE-CONTEXT-CACHE>
; 5BC:       170080D2         MOVZ NARGS, #0
; 5C0:       FA031BAA         MOV CFP, CSP
; 5C4:       DE9240F8         LDR LR, [LEXENV, #9]
; 5C8:       C0033FD6         BLR LR
; 5CC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 5D0:       410D4092         AND NL1, R0, #15
; 5D4:       3F0C00F1         CMP NL1, #3
; 5D8:       210F0054         BNE L8
; 5DC:       4D5140F8         LDR R3, [R0, #5]
; 5E0:       A25145B8         LDR WNL2, [R3, #85]
; 5E4:       5FFC0131         CMN WNL2, #127
; 5E8:       A10E0054         BNE L8
; 5EC:       4A0F00F9         STR R0, [CFP, #24]
; 5F0:       4A0B40F9         LDR R0, [CFP, #16]
; 5F4:       410D4092         AND NL1, R0, #15
; 5F8:       3F3C00F1         CMP NL1, #15
; 5FC:       C10D0054         BNE L7
; 600:       41115F38         LDRB WNL1, [R0, #-15]
; 604:       211402D1         SUB NL1, NL1, #133
; 608:       3FC001F1         CMP NL1, #112
; 60C:       480D0054         BHI L7
; 610:       4A0B40F9         LDR R0, [CFP, #16]
; 614:       4A1300F9         STR R0, [CFP, #32]
; 618:       010080D2         MOVZ NL1, #0
; 61C:       4A0B40F9         LDR R0, [CFP, #16]
; 620:       40915FF8         LDR NL0, [R0, #-7]
; 624:       401700F9         STR NL0, [CFP, #40]
; 628: L0:   401740F9         LDR NL0, [CFP, #40]
; 62C:       3F0000EB         CMP NL1, NL0
; 630:       4A030054         BGE L1
; 634:       411B00F9         STR NL1, [CFP, #48]
; 638:       EB0301AA         MOV R1, NL1
; 63C:       7A0300F9         STR CFP, [CSP]
; 640:       4A1340F9         LDR R0, [CFP, #32]
; 644:       FA031BAA         MOV CFP, CSP
; 648:       290681D2         MOVZ TMP, #2097
; 64C:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:HAIRY-DATA-VECTOR-REF/CHECK-BOUNDS
; 650:       C0033FD6         BLR LR
; 654:       411B40F9         LDR NL1, [CFP, #48]
; 658:       EB030AAA         MOV R1, R0
; 65C:       20080091         ADD NL0, NL1, #2
; 660:       E10300AA         MOV NL1, NL0
; 664:       7F011DEB         CMP R1, NULL
; 668:       00FEFF54         BEQ L0
; 66C:       411B00F9         STR NL1, [CFP, #48]
; 670:       7A0300F9         STR CFP, [CSP]
; 674:       4A0F40F9         LDR R0, [CFP, #24]
; 678:       96F7FF58         LDR LEXENV, #x700CE01568        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CONTEXT-CACHE-ADD>
; 67C:       970080D2         MOVZ NARGS, #4
; 680:       FA031BAA         MOV CFP, CSP
; 684:       DE9240F8         LDR LR, [LEXENV, #9]
; 688:       C0033FD6         BLR LR
; 68C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 690:       411B40F9         LDR NL1, [CFP, #48]
; 694:       E5FFFF17         B L0
; 698: L1:   4A0B40F9         LDR R0, [CFP, #16]
; 69C:       4A7F02A9         STP R0, ZR, [CFP, #32]
; 6A0:       4A0B40F9         LDR R0, [CFP, #16]
; 6A4:       40915FF8         LDR NL0, [R0, #-7]
; 6A8:       407F03A9         STP NL0, ZR, [CFP, #48]
; 6AC:       1F0000F1         CMP NL0, #0
; 6B0:       CC000054         BGT L3
; 6B4: L2:   4A0B40F9         LDR R0, [CFP, #16]
; 6B8:       FB031AAA         MOV CSP, CFP
; 6BC:       5A7B40A9         LDP CFP, LR, [CFP]
; 6C0:       BF0300F1         CMP NULL, #0
; 6C4:       C0035FD6         RET
; 6C8: L3:   4B1740F9         LDR R1, [CFP, #40]
; 6CC:       7A0300F9         STR CFP, [CSP]
; 6D0:       4A1340F9         LDR R0, [CFP, #32]
; 6D4:       FA031BAA         MOV CFP, CSP
; 6D8:       290681D2         MOVZ TMP, #2097
; 6DC:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:HAIRY-DATA-VECTOR-REF/CHECK-BOUNDS
; 6E0:       C0033FD6         BLR LR
; 6E4:       EC030AAA         MOV R2, R0
; 6E8:       400080D2         MOVZ NL0, #2
; 6EC:       401700F9         STR NL0, [CFP, #40]
; 6F0:       2E000014         B L6
; 6F4: L4:   4E1F40F9         LDR R4, [CFP, #56]
; 6F8:       4E2700F9         STR R4, [CFP, #72]
; 6FC:       7A0300F9         STR CFP, [CSP]
; 700:       4A0F40F9         LDR R0, [CFP, #24]
; 704:       EB030CAA         MOV R1, R2
; 708:       56F3FF58         LDR LEXENV, #x700CE01570        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CONTEXT-CACHE-GET>
; 70C:       970080D2         MOVZ NARGS, #4
; 710:       FA031BAA         MOV CFP, CSP
; 714:       DE9240F8         LDR LR, [LEXENV, #9]
; 718:       C0033FD6         BLR LR
; 71C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 720:       4E2740F9         LDR R4, [CFP, #72]
; 724:       EC030AAA         MOV R2, R0
; 728:       7A0300F9         STR CFP, [CSP]
; 72C:       4A1340F9         LDR R0, [CFP, #32]
; 730:       EB030EAA         MOV R1, R4
; 734:       FA031BAA         MOV CFP, CSP
; 738:       290281D2         MOVZ TMP, #2065
; 73C:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:HAIRY-DATA-VECTOR-SET/CHECK-BOUNDS
; 740:       C0033FD6         BLR LR
; 744: L5:   401740F9         LDR NL0, [CFP, #40]
; 748:       411B40F9         LDR NL1, [CFP, #48]
; 74C:       1F0001EB         CMP NL0, NL1
; 750:       2AFBFF54         BGE L2
; 754:       4B1740F9         LDR R1, [CFP, #40]
; 758:       7A0300F9         STR CFP, [CSP]
; 75C:       4A1340F9         LDR R0, [CFP, #32]
; 760:       FA031BAA         MOV CFP, CSP
; 764:       290681D2         MOVZ TMP, #2097
; 768:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:HAIRY-DATA-VECTOR-REF/CHECK-BOUNDS
; 76C:       C0033FD6         BLR LR
; 770:       EC030AAA         MOV R2, R0
; 774:       4C2300F9         STR R2, [CFP, #64]
; 778:       401740F9         LDR NL0, [CFP, #40]
; 77C:       00080091         ADD NL0, NL0, #2
; 780:       401700F9         STR NL0, [CFP, #40]
; 784:       4A1F40F9         LDR R0, [CFP, #56]
; 788:       7A0300F9         STR CFP, [CSP]
; 78C:       4B0080D2         MOVZ R1, #2
; 790:       FA031BAA         MOV CFP, CSP
; 794:       29AA80D2         MOVZ TMP, #1361
; 798:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:TWO-ARG-+
; 79C:       C0033FD6         BLR LR
; 7A0:       4C2340F9         LDR R2, [CFP, #64]
; 7A4:       4A1F00F9         STR R0, [CFP, #56]
; 7A8: L6:   9F011DEB         CMP R2, NULL
; 7AC:       C0FCFF54         BEQ L5
; 7B0:       D1FFFF17         B L4
; 7B4: L7:   4A0B40F9         LDR R0, [CFP, #16]
; 7B8:       C04A21D4         BRK #2646                       ; OBJECT-NOT-VECTOR-ERROR
                                                              ; R0
; 7BC: L8:   405321D4         BRK #2714                       ; OBJECT-NOT-HASH-TABLE-ERROR
                                                              ; R0
; 7C0:       E00120D4         BRK #15                         ; Invalid argument count trap
