; disassembly for DIAGNOSTIC-MERGE-CACHE-GET-TYPED
; Size: 472 bytes. Origin: #x70055B27A8                       ; DIAGNOSTIC-MERGE-CACHE-GET-TYPED
; 7A8:       DF011DEB         CMP R4, NULL
; 7AC:       C1000054         BNE L1
; 7B0:       EA031DAA         MOV R0, NULL
; 7B4: L0:   FB031AAA         MOV CSP, CFP
; 7B8:       5A7B40A9         LDP CFP, LR, [CFP]
; 7BC:       BF0300F1         CMP NULL, #0
; 7C0:       C0035FD6         RET
; 7C4: L1:   4A0B40F9         LDR R0, [CFP, #16]
; 7C8:       5F011DEB         CMP R0, NULL
; 7CC:       400D0054         BEQ L13
; 7D0:       4A0B40F9         LDR R0, [CFP, #16]
; 7D4:       40D140F8         LDR NL0, [R0, #13]
; 7D8: L2:   4A0F40F9         LDR R0, [CFP, #24]
; 7DC:       5F011DEB         CMP R0, NULL
; 7E0:       600C0054         BEQ L12
; 7E4:       4A0F40F9         LDR R0, [CFP, #24]
; 7E8:       41D140F8         LDR NL1, [R0, #13]
; 7EC: L3:   010001CA         EOR NL1, NL0, NL1
; 7F0:       7A0300F9         STR CFP, [CSP]
; 7F4:       EA0301AA         MOV R0, NL1
; 7F8:       EB030EAA         MOV R1, R4
; 7FC:       EC031DAA         MOV R2, NULL
; 800:       96F5FF58         LDR LEXENV, #x70055B26B0        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 804:       FA031BAA         MOV CFP, CSP
; 808:       DE9240F8         LDR LR, [LEXENV, #9]
; 80C:       C0033FD6         BLR LR
; 810:       FB0319AA         MOV CSP, OCFP
; 814:       EE030AAA         MOV R4, R0
; 818: L4:   C10D4092         AND NL1, R4, #15
; 81C:       3F1C00F1         CMP NL1, #7
; 820:       410A0054         BNE L11
; 824:       DF011DEB         CMP R4, NULL
; 828:       C0090054         BEQ L10
; 82C:       CA915FF8         LDR R0, [R4, #-7]
; 830:       410D4092         AND NL1, R0, #15
; 834:       3F1C00F1         CMP NL1, #7
; 838:       21090054         BNE L9
; 83C:       4C915FF8         LDR R2, [R0, #-7]
; 840:       4A1140F8         LDR R0, [R0, #1]
; 844:       410D4092         AND NL1, R0, #15
; 848:       3F1C00F1         CMP NL1, #7
; 84C:       61080054         BNE L8
; 850:       4B915FF8         LDR R1, [R0, #-7]
; 854:       4B1300F9         STR R1, [CFP, #32]
; 858:       4A1140F8         LDR R0, [R0, #1]
; 85C:       410D4092         AND NL1, R0, #15
; 860:       3F1C00F1         CMP NL1, #7
; 864:       81070054         BNE L7
; 868:       4C1F00F9         STR R2, [CFP, #56]
; 86C:       4A915FF8         LDR R0, [R0, #-7]
; 870:       4A1700F9         STR R0, [CFP, #40]
; 874:       CA1140F8         LDR R0, [R4, #1]
; 878:       EE030AAA         MOV R4, R0
; 87C:       4E1B00F9         STR R4, [CFP, #48]
; 880:       EA030CAA         MOV R0, R2
; 884:       7A0300F9         STR CFP, [CSP]
; 888:       4B0B40F9         LDR R1, [CFP, #16]
; 88C:       76F1FF58         LDR LEXENV, #x70055B26B8        ; #<SB-KERNEL:FDEFN CONTEXT-EQUAL>
; 890:       970080D2         MOVZ NARGS, #4
; 894:       FA031BAA         MOV CFP, CSP
; 898:       DE9240F8         LDR LR, [LEXENV, #9]
; 89C:       C0033FD6         BLR LR
; 8A0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 8A4:       4E3343A9         LDP R4, R2, [CFP, #48]
; 8A8:       5F011DEB         CMP R0, NULL
; 8AC:       C0010054         BEQ L5
; 8B0:       4E3303A9         STP R4, R2, [CFP, #48]
; 8B4:       4A1340F9         LDR R0, [CFP, #32]
; 8B8:       7A0300F9         STR CFP, [CSP]
; 8BC:       4B0F40F9         LDR R1, [CFP, #24]
; 8C0:       D6EFFF58         LDR LEXENV, #x70055B26B8        ; #<SB-KERNEL:FDEFN CONTEXT-EQUAL>
; 8C4:       970080D2         MOVZ NARGS, #4
; 8C8:       FA031BAA         MOV CFP, CSP
; 8CC:       DE9240F8         LDR LR, [LEXENV, #9]
; 8D0:       C0033FD6         BLR LR
; 8D4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 8D8:       4E3343A9         LDP R4, R2, [CFP, #48]
; 8DC:       5F011DEB         CMP R0, NULL
; 8E0:       61030054         BNE L6
; 8E4: L5:   4E1B00F9         STR R4, [CFP, #48]
; 8E8:       EA030CAA         MOV R0, R2
; 8EC:       7A0300F9         STR CFP, [CSP]
; 8F0:       4B0F40F9         LDR R1, [CFP, #24]
; 8F4:       36EEFF58         LDR LEXENV, #x70055B26B8        ; #<SB-KERNEL:FDEFN CONTEXT-EQUAL>
; 8F8:       970080D2         MOVZ NARGS, #4
; 8FC:       FA031BAA         MOV CFP, CSP
; 900:       DE9240F8         LDR LR, [LEXENV, #9]
; 904:       C0033FD6         BLR LR
; 908:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 90C:       4E1B40F9         LDR R4, [CFP, #48]
; 910:       5F011DEB         CMP R0, NULL
; 914:       20F8FF54         BEQ L4
; 918:       4E1B00F9         STR R4, [CFP, #48]
; 91C:       4A1340F9         LDR R0, [CFP, #32]
; 920:       7A0300F9         STR CFP, [CSP]
; 924:       4B0B40F9         LDR R1, [CFP, #16]
; 928:       96ECFF58         LDR LEXENV, #x70055B26B8        ; #<SB-KERNEL:FDEFN CONTEXT-EQUAL>
; 92C:       970080D2         MOVZ NARGS, #4
; 930:       FA031BAA         MOV CFP, CSP
; 934:       DE9240F8         LDR LR, [LEXENV, #9]
; 938:       C0033FD6         BLR LR
; 93C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 940:       4E1B40F9         LDR R4, [CFP, #48]
; 944:       5F011DEB         CMP R0, NULL
; 948:       80F6FF54         BEQ L4
; 94C: L6:   4A1740F9         LDR R0, [CFP, #40]
; 950:       99FFFF17         B L0
; 954: L7:   E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 958: L8:   E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 95C: L9:   E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 960: L10:  EA031DAA         MOV R0, NULL
; 964:       94FFFF17         B L0
; 968: L11:  E0C921D4         BRK #3663                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R4
; 96C: L12:  010080D2         MOVZ NL1, #0
; 970:       9FFFFF17         B L3
; 974: L13:  000080D2         MOVZ NL0, #0
; 978:       98FFFF17         B L2
; 97C:       E00120D4         BRK #15                         ; Invalid argument count trap
