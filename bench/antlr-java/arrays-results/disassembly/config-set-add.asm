; disassembly for CNVRS/ANTLR-RUNTIME:CONFIG-SET-ADD
; Size: 1100 bytes. Origin: #x700AA36958                      ; CNVRS/ANTLR-RUNTIME:CONFIG-SET-ADD
; 958:       4A0B40F9         LDR R0, [CFP, #16]
; 95C:       4A5144F8         LDR R0, [R0, #69]
; 960:       5F011DEB         CMP R0, NULL
; 964:       81200054         BNE L21
; 968:       0A5242F8         LDR R0, [R6, #37]
; 96C:       ABE30091         ADD R1, NULL, #56               ; T
; 970:       5F010BEB         CMP R0, R1
; 974:       811F0054         BNE L20
; 978: L0:   00D242F8         LDR NL0, [R6, #45]
; 97C:       1F0000F1         CMP NL0, #0
; 980:       AC1E0054         BGT L19
; 984: L1:   4A0B40F9         LDR R0, [CFP, #16]
; 988:       4A5141F8         LDR R0, [R0, #21]
; 98C:       5F011DEB         CMP R0, NULL
; 990:       001E0054         BEQ L18
; 994:       4A1300F9         STR R0, [CFP, #32]
; 998:       00D240F8         LDR NL0, [R6, #13]
; 99C:       037C7F92         AND NL3, NL0, #8589934590
; 9A0:       005241F8         LDR NL0, [R6, #21]
; 9A4:       007C7F92         AND NL0, NL0, #8589934590
; 9A8:       29AA85D2         MOVZ TMP, #11601
; 9AC:       C993B9F2         MOVK TMP, #52382, LSL #16
; 9B0:       007C099B         MUL NL0, NL0, TMP
; 9B4:       007C7F92         AND NL0, NL0, #8589934590
; 9B8:       02C071D3         LSL NL2, NL0, #15
; 9BC:       01FC5193         ASR NL1, NL0, #17
; 9C0:       20F87F92         AND NL0, NL1, #18446744073709551614
; 9C4:       400000AA         ORR NL0, NL2, NL0
; 9C8:       007C7F92         AND NL0, NL0, #8589934590
; 9CC:       69B286D2         MOVZ TMP, #13715
; 9D0:       E970A3F2         MOVK TMP, #7047, LSL #16
; 9D4:       007C099B         MUL NL0, NL0, TMP
; 9D8:       007C7F92         AND NL0, NL0, #8589934590
; 9DC:       600000CA         EOR NL0, NL3, NL0
; 9E0:       02C873D3         LSL NL2, NL0, #13
; 9E4:       01FC5393         ASR NL1, NL0, #19
; 9E8:       20F87F92         AND NL0, NL1, #18446744073709551614
; 9EC:       400000AA         ORR NL0, NL2, NL0
; 9F0:       007C7F92         AND NL0, NL0, #8589934590
; 9F4:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 9F8:       01D99AD2         MOVZ NL1, #54984
; 9FC:       0195B9F2         MOVK NL1, #52392, LSL #16
; A00:       2100C0F2         MOVK NL1, #1, LSL #32
; A04:       0000018B         ADD NL0, NL0, NL1
; A08:       037C7F92         AND NL3, NL0, #8589934590
; A0C:       0A5242F8         LDR R0, [R6, #37]
; A10:       ABE30091         ADD R1, NULL, #56               ; T
; A14:       5F010BEB         CMP R0, R1
; A18:       21180054         BNE L17
; A1C:       000080D2         MOVZ NL0, #0
; A20: L2:   29AA85D2         MOVZ TMP, #11601
; A24:       C993B9F2         MOVK TMP, #52382, LSL #16
; A28:       007C099B         MUL NL0, NL0, TMP
; A2C:       007C7F92         AND NL0, NL0, #8589934590
; A30:       02C071D3         LSL NL2, NL0, #15
; A34:       01FC5193         ASR NL1, NL0, #17
; A38:       20F87F92         AND NL0, NL1, #18446744073709551614
; A3C:       400000AA         ORR NL0, NL2, NL0
; A40:       007C7F92         AND NL0, NL0, #8589934590
; A44:       69B286D2         MOVZ TMP, #13715
; A48:       E970A3F2         MOVK TMP, #7047, LSL #16
; A4C:       007C099B         MUL NL0, NL0, TMP
; A50:       007C7F92         AND NL0, NL0, #8589934590
; A54:       600000CA         EOR NL0, NL3, NL0
; A58:       02C873D3         LSL NL2, NL0, #13
; A5C:       01FC5393         ASR NL1, NL0, #19
; A60:       20F87F92         AND NL0, NL1, #18446744073709551614
; A64:       400000AA         ORR NL0, NL2, NL0
; A68:       007C7F92         AND NL0, NL0, #8589934590
; A6C:       0008008B         ADD NL0, NL0, NL0, LSL #2
; A70:       01D99AD2         MOVZ NL1, #54984
; A74:       0195B9F2         MOVK NL1, #52392, LSL #16
; A78:       2100C0F2         MOVK NL1, #1, LSL #32
; A7C:       0000018B         ADD NL0, NL0, NL1
; A80:       007C7F92         AND NL0, NL0, #8589934590
; A84:       00047DD2         EOR NL0, NL0, #24
; A88:       01FC5093         ASR NL1, NL0, #16
; A8C:       22F87F92         AND NL2, NL1, #18446744073709551614
; A90:       000002CA         EOR NL0, NL0, NL2
; A94:       694D99D2         MOVZ TMP, #51819
; A98:       69BDB0F2         MOVK TMP, #34283, LSL #16
; A9C:       007C099B         MUL NL0, NL0, TMP
; AA0:       007C7F92         AND NL0, NL0, #8589934590
; AA4:       01FC4D93         ASR NL1, NL0, #13
; AA8:       22F87F92         AND NL2, NL1, #18446744073709551614
; AAC:       000002CA         EOR NL0, NL0, NL2
; AB0:       A9C695D2         MOVZ TMP, #44597
; AB4:       4956B8F2         MOVK TMP, #49842, LSL #16
; AB8:       007C099B         MUL NL0, NL0, TMP
; ABC:       007C7F92         AND NL0, NL0, #8589934590
; AC0:       01FC5093         ASR NL1, NL0, #16
; AC4:       22F87F92         AND NL2, NL1, #18446744073709551614
; AC8:       000002CA         EOR NL0, NL0, NL2
; ACC:       501F00F9         STR R6, [CFP, #56]
; AD0:       401700F9         STR NL0, [CFP, #40]
; AD4:       7A0300F9         STR CFP, [CSP]
; AD8:       4B2B42A9         LDP R1, R0, [CFP, #32]
; ADC:       EC031DAA         MOV R2, NULL
; AE0:       16E4FF58         LDR LEXENV, #x700AA36760        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; AE4:       FA031BAA         MOV CFP, CSP
; AE8:       DE9240F8         LDR LR, [LEXENV, #9]
; AEC:       C0033FD6         BLR LR
; AF0:       FB0319AA         MOV CSP, OCFP
; AF4:       501F40F9         LDR R6, [CFP, #56]
; AF8:       4A1B00F9         STR R0, [CFP, #48]
; AFC:       410D4092         AND NL1, R0, #15
; B00:       3F1C00F1         CMP NL1, #7
; B04:       A1100054         BNE L16
; B08:       EC030AAA         MOV R2, R0
; B0C: L3:   810D4092         AND NL1, R2, #15
; B10:       3F1C00F1         CMP NL1, #7
; B14:       01100054         BNE L15
; B18:       9F011DEB         CMP R2, NULL
; B1C:       E00B0054         BEQ L12
; B20:       8F915FF8         LDR R5, [R2, #-7]
; B24:       FF011DEB         CMP R5, NULL
; B28:       20010054         BEQ L4
; B2C:       E10D4092         AND NL1, R5, #15
; B30:       3F0C00F1         CMP NL1, #3
; B34:       E10A0054         BNE L11
; B38:       EE5140F8         LDR R4, [R5, #5]
; B3C:       C25145B8         LDR WNL2, [R4, #85]
; B40:       21E5FF18         LDR WNL1, #x700AA367E4
; B44:       5F00016B         CMP WNL2, WNL1
; B48:       410A0054         BNE L11
; B4C: L4:   8A1140F8         LDR R0, [R2, #1]
; B50:       EC030AAA         MOV R2, R0
; B54:       FF011DEB         CMP R5, NULL
; B58:       80090054         BEQ L10
; B5C:       01D240F8         LDR NL1, [R6, #13]
; B60:       E0D140F8         LDR NL0, [R5, #13]
; B64:       1F0001EB         CMP NL0, NL1
; B68:       21FDFF54         BNE L3
; B6C:       015241F8         LDR NL1, [R6, #21]
; B70:       E05141F8         LDR NL0, [R5, #21]
; B74:       1F0001EB         CMP NL0, NL1
; B78:       A1FCFF54         BNE L3
; B7C:       50BF03A9         STP R6, R5, [CFP, #56]
; B80:       4C2700F9         STR R2, [CFP, #72]
; B84:       0A5242F8         LDR R0, [R6, #37]
; B88:       EB5142F8         LDR R1, [R5, #37]
; B8C:       7A0300F9         STR CFP, [CSP]
; B90:       D6DEFF58         LDR LEXENV, #x700AA36768        ; #<SB-KERNEL:FDEFN EQUAL>
; B94:       970080D2         MOVZ NARGS, #4
; B98:       FA031BAA         MOV CFP, CSP
; B9C:       DE9240F8         LDR LR, [LEXENV, #9]
; BA0:       C0033FD6         BLR LR
; BA4:       4C2740F9         LDR R2, [CFP, #72]
; BA8:       50BF43A9         LDP R6, R5, [CFP, #56]
; BAC:       5F011DEB         CMP R0, NULL
; BB0:       E0FAFF54         BEQ L3
; BB4:       EBD141F8         LDR R1, [R5, #29]
; BB8:       0CD241F8         LDR R2, [R6, #29]
; BBC:       4A0B40F9         LDR R0, [CFP, #16]
; BC0:       4AD141F8         LDR R0, [R0, #29]
; BC4:       5F011DEB         CMP R0, NULL
; BC8:       AAE30091         ADD R0, NULL, #56               ; T
; BCC:       4D019D9A         CSEL R3, R0, NULL, EQ
; BD0:       50BF03A9         STP R6, R5, [CFP, #56]
; BD4:       7A0300F9         STR CFP, [CSP]
; BD8:       EA030BAA         MOV R0, R1
; BDC:       EB030CAA         MOV R1, R2
; BE0:       EC030DAA         MOV R2, R3
; BE4:       4D0F40F9         LDR R3, [CFP, #24]
; BE8:       56DCFF58         LDR LEXENV, #x700AA36770        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:MERGE-CONTEXTS>
; BEC:       170180D2         MOVZ NARGS, #8
; BF0:       FA031BAA         MOV CFP, CSP
; BF4:       DE9240F8         LDR LR, [LEXENV, #9]
; BF8:       C0033FD6         BLR LR
; BFC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; C00:       50BF43A9         LDP R6, R5, [CFP, #56]
; C04:       5F011DEB         CMP R0, NULL
; C08:       20010054         BEQ L5
; C0C:       410D4092         AND NL1, R0, #15
; C10:       3F0C00F1         CMP NL1, #3
; C14:       61030054         BNE L9
; C18:       4E5140F8         LDR R4, [R0, #5]
; C1C:       C25145B8         LDR WNL2, [R4, #85]
; C20:       41DEFF18         LDR WNL1, #x700AA367E8
; C24:       5F00016B         CMP WNL2, WNL1
; C28:       C1020054         BNE L9
; C2C: L5:   E9794BD3         UBFM TMP, R5, #11, #30
; C30:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; C34:       EAD101F8         STR R0, [R5, #29]
; C38:       E0D142F8         LDR NL0, [R5, #45]
; C3C:       01D242F8         LDR NL1, [R6, #45]
; C40:       1F0001EB         CMP NL0, NL1
; C44:       20B0809A         CSEL NL0, NL1, NL0, LT
; C48:       E0D102F8         STR NL0, [R5, #45]
; C4C:       EA5143F8         LDR R0, [R5, #53]
; C50:       5F011DEB         CMP R0, NULL
; C54:       20010054         BEQ L8
; C58: L6:   E9794BD3         UBFM TMP, R5, #11, #30
; C5C:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; C60:       EA5103F8         STR R0, [R5, #53]
; C64: L7:   AAE30091         ADD R0, NULL, #56               ; T
; C68:       FB031AAA         MOV CSP, CFP
; C6C:       5A7B40A9         LDP CFP, LR, [CFP]
; C70:       BF0300F1         CMP NULL, #0
; C74:       C0035FD6         RET
; C78: L8:   0A5243F8         LDR R0, [R6, #53]
; C7C:       F7FFFF17         B L6
; C80: L9:   604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; C84:       4B               BYTE #X4B                       ; '(OR NULL
                                                              ;      CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT)
; C85:       .ALIGN           4
; C88: L10:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; C8C:       3F               BYTE #X3F                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA4E5D3}>
; C8D:       .ALIGN           4
; C90: L11:  60E321D4         BRK #3867                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; C94:       4F               BYTE #X4F                       ; '(OR NULL
                                                              ;      CNVRS/ANTLR-RUNTIME:ATN-CONFIG)
; C95:       .ALIGN           4
; C98: L12:  501F00F9         STR R6, [CFP, #56]
; C9C:       4A1B40F9         LDR R0, [CFP, #48]
; CA0:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; CA4:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; CA8:       2C410091         ADD R2, TMP, #16
; CAC:       9F011EEB         CMP R2, LR
; CB0:       28070054         BHI L22
; CB4:       AC2E00F9         STR R2, [THREAD, #88]           ; cons-tlab
; CB8: L13:  2C1D0091         ADD R2, TMP, #7
; CBC:       302900A9         STP R6, R0, [TMP]
; CC0:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; CC4:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; CC8:       5E0000B4         CBZ LR, L14
; CCC:       200120D4         BRK #9                          ; Pending interrupt trap
; CD0: L14:  7A0300F9         STR CFP, [CSP]
; CD4:       4B2B42A9         LDP R1, R0, [CFP, #32]
; CD8:       16D5FF58         LDR LEXENV, #x700AA36778        ; #<SB-KERNEL:FDEFN SB-KERNEL:%PUTHASH>
; CDC:       FA031BAA         MOV CFP, CSP
; CE0:       DE9240F8         LDR LR, [LEXENV, #9]
; CE4:       C0033FD6         BLR LR
; CE8:       501F40F9         LDR R6, [CFP, #56]
; CEC:       4A0B40F9         LDR R0, [CFP, #16]
; CF0:       4BD140F8         LDR R1, [R0, #13]
; CF4:       7A0300F9         STR CFP, [CSP]
; CF8:       EA0310AA         MOV R0, R6
; CFC:       36D4FF58         LDR LEXENV, #x700AA36780        ; #<SB-KERNEL:FDEFN VECTOR-PUSH-EXTEND>
; D00:       970080D2         MOVZ NARGS, #4
; D04:       FA031BAA         MOV CFP, CSP
; D08:       DE9240F8         LDR LR, [LEXENV, #9]
; D0C:       C0033FD6         BLR LR
; D10:       D5FFFF17         B L7
; D14: L15:  E08921D4         BRK #3151                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R2
; D18: L16:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; D1C: L17:  501F00F9         STR R6, [CFP, #56]
; D20:       431700F9         STR NL3, [CFP, #40]
; D24:       0A5242F8         LDR R0, [R6, #37]
; D28:       7A0300F9         STR CFP, [CSP]
; D2C:       F6D2FF58         LDR LEXENV, #x700AA36788        ; #<SB-KERNEL:FDEFN SXHASH>
; D30:       570080D2         MOVZ NARGS, #2
; D34:       FA031BAA         MOV CFP, CSP
; D38:       DE9240F8         LDR LR, [LEXENV, #9]
; D3C:       C0033FD6         BLR LR
; D40:       431740F9         LDR NL3, [CFP, #40]
; D44:       501F40F9         LDR R6, [CFP, #56]
; D48:       407D7F92         AND NL0, R0, #8589934590
; D4C:       35FFFF17         B L2
; D50: L18:  40B323D4         BRK #7578                       ; OBJECT-NOT-HASH-TABLE-ERROR
                                                              ; NULL
; D54: L19:  4A0B40F9         LDR R0, [CFP, #16]
; D58:       ABE30091         ADD R1, NULL, #56               ; T
; D5C:       4BD103F8         STR R1, [R0, #61]
; D60:       09FFFF17         B L1
; D64: L20:  4A0B40F9         LDR R0, [CFP, #16]
; D68:       ABE30091         ADD R1, NULL, #56               ; T
; D6C:       4B5103F8         STR R1, [R0, #53]
; D70:       02FFFF17         B L0
; D74: L21:  6AD2FF58         LDR R0, #x700AA367C0            ; "ATNConfigSet is read-only"
; D78:       570080D2         MOVZ NARGS, #2
; D7C:       29D280D2         MOVZ TMP, #1681
; D80:       BE6B69F8         LDR LR, [NULL, TMP]             ; ERROR
; D84:       DE130091         ADD LR, LR, #4
; D88:       C0031FD6         BR LR
; D8C:       E00120D4         BRK #15                         ; Invalid argument count trap
; D90:       E08221D4         BRK #3095                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; D94: L22:  090280D2         MOVZ TMP, #16
; D98:       0CD2FF58         LDR R2, #x700AA367D8            ; SB-VM::LIST-ALLOC-TRAMP
; D9C:       80013FD6         BLR R2
; DA0:       C6FFFF17         B L13
