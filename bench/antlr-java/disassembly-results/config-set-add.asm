; disassembly for CNVRS/ANTLR-RUNTIME:CONFIG-SET-ADD
; Size: 1120 bytes. Origin: #x700AA62B28                      ; CNVRS/ANTLR-RUNTIME:CONFIG-SET-ADD
; B28:       4A0B40F9         LDR R0, [CFP, #16]
; B2C:       410D4092         AND NL1, R0, #15
; B30:       3F0C00F1         CMP NL1, #3
; B34:       61210054         BNE L16
; B38:       4E5140F8         LDR R4, [R0, #5]
; B3C:       C25145B8         LDR WNL2, [R4, #85]
; B40:       81FBFF18         LDR WNL1, #x700AA62AB0
; B44:       5F00016B         CMP WNL2, WNL1
; B48:       C1200054         BNE L16
; B4C:       4A0B40F9         LDR R0, [CFP, #16]
; B50:       4A5144F8         LDR R0, [R0, #69]
; B54:       5F011DEB         CMP R0, NULL
; B58:       811F0054         BNE L15
; B5C:       010E4092         AND NL1, R6, #15
; B60:       3F0C00F1         CMP NL1, #3
; B64:       E11E0054         BNE L14
; B68:       0E5240F8         LDR R4, [R6, #5]
; B6C:       C25145B8         LDR WNL2, [R4, #85]
; B70:       21FAFF18         LDR WNL1, #x700AA62AB4
; B74:       5F00016B         CMP WNL2, WNL1
; B78:       411E0054         BNE L14
; B7C:       0A5242F8         LDR R0, [R6, #37]
; B80:       ABE30091         ADD R1, NULL, #56               ; T
; B84:       5F010BEB         CMP R0, R1
; B88:       80000054         BEQ L0
; B8C:       4A0B40F9         LDR R0, [CFP, #16]
; B90:       ABE30091         ADD R1, NULL, #56               ; T
; B94:       4B5103F8         STR R1, [R0, #53]
; B98: L0:   00D242F8         LDR NL0, [R6, #45]
; B9C:       1F0000F1         CMP NL0, #0
; BA0:       8C1C0054         BGT L13
; BA4: L1:   00D240F8         LDR NL0, [R6, #13]
; BA8:       037C7F92         AND NL3, NL0, #8589934590
; BAC:       005241F8         LDR NL0, [R6, #21]
; BB0:       007C7F92         AND NL0, NL0, #8589934590
; BB4:       29AA85D2         MOVZ TMP, #11601
; BB8:       C993B9F2         MOVK TMP, #52382, LSL #16
; BBC:       007C099B         MUL NL0, NL0, TMP
; BC0:       007C7F92         AND NL0, NL0, #8589934590
; BC4:       02C071D3         LSL NL2, NL0, #15
; BC8:       01FC5193         ASR NL1, NL0, #17
; BCC:       20F87F92         AND NL0, NL1, #18446744073709551614
; BD0:       400000AA         ORR NL0, NL2, NL0
; BD4:       007C7F92         AND NL0, NL0, #8589934590
; BD8:       69B286D2         MOVZ TMP, #13715
; BDC:       E970A3F2         MOVK TMP, #7047, LSL #16
; BE0:       007C099B         MUL NL0, NL0, TMP
; BE4:       007C7F92         AND NL0, NL0, #8589934590
; BE8:       600000CA         EOR NL0, NL3, NL0
; BEC:       02C873D3         LSL NL2, NL0, #13
; BF0:       01FC5393         ASR NL1, NL0, #19
; BF4:       20F87F92         AND NL0, NL1, #18446744073709551614
; BF8:       400000AA         ORR NL0, NL2, NL0
; BFC:       007C7F92         AND NL0, NL0, #8589934590
; C00:       0008008B         ADD NL0, NL0, NL0, LSL #2
; C04:       01D99AD2         MOVZ NL1, #54984
; C08:       0195B9F2         MOVK NL1, #52392, LSL #16
; C0C:       2100C0F2         MOVK NL1, #1, LSL #32
; C10:       0000018B         ADD NL0, NL0, NL1
; C14:       037C7F92         AND NL3, NL0, #8589934590
; C18:       0A5242F8         LDR R0, [R6, #37]
; C1C:       ABE30091         ADD R1, NULL, #56               ; T
; C20:       5F010BEB         CMP R0, R1
; C24:       01170054         BNE L12
; C28:       000080D2         MOVZ NL0, #0
; C2C: L2:   29AA85D2         MOVZ TMP, #11601
; C30:       C993B9F2         MOVK TMP, #52382, LSL #16
; C34:       007C099B         MUL NL0, NL0, TMP
; C38:       007C7F92         AND NL0, NL0, #8589934590
; C3C:       02C071D3         LSL NL2, NL0, #15
; C40:       01FC5193         ASR NL1, NL0, #17
; C44:       20F87F92         AND NL0, NL1, #18446744073709551614
; C48:       400000AA         ORR NL0, NL2, NL0
; C4C:       007C7F92         AND NL0, NL0, #8589934590
; C50:       69B286D2         MOVZ TMP, #13715
; C54:       E970A3F2         MOVK TMP, #7047, LSL #16
; C58:       007C099B         MUL NL0, NL0, TMP
; C5C:       007C7F92         AND NL0, NL0, #8589934590
; C60:       600000CA         EOR NL0, NL3, NL0
; C64:       02C873D3         LSL NL2, NL0, #13
; C68:       01FC5393         ASR NL1, NL0, #19
; C6C:       20F87F92         AND NL0, NL1, #18446744073709551614
; C70:       400000AA         ORR NL0, NL2, NL0
; C74:       007C7F92         AND NL0, NL0, #8589934590
; C78:       0008008B         ADD NL0, NL0, NL0, LSL #2
; C7C:       01D99AD2         MOVZ NL1, #54984
; C80:       0195B9F2         MOVK NL1, #52392, LSL #16
; C84:       2100C0F2         MOVK NL1, #1, LSL #32
; C88:       0000018B         ADD NL0, NL0, NL1
; C8C:       007C7F92         AND NL0, NL0, #8589934590
; C90:       00047DD2         EOR NL0, NL0, #24
; C94:       01FC5093         ASR NL1, NL0, #16
; C98:       22F87F92         AND NL2, NL1, #18446744073709551614
; C9C:       000002CA         EOR NL0, NL0, NL2
; CA0:       694D99D2         MOVZ TMP, #51819
; CA4:       69BDB0F2         MOVK TMP, #34283, LSL #16
; CA8:       007C099B         MUL NL0, NL0, TMP
; CAC:       007C7F92         AND NL0, NL0, #8589934590
; CB0:       01FC4D93         ASR NL1, NL0, #13
; CB4:       22F87F92         AND NL2, NL1, #18446744073709551614
; CB8:       000002CA         EOR NL0, NL0, NL2
; CBC:       A9C695D2         MOVZ TMP, #44597
; CC0:       4956B8F2         MOVK TMP, #49842, LSL #16
; CC4:       007C099B         MUL NL0, NL0, TMP
; CC8:       007C7F92         AND NL0, NL0, #8589934590
; CCC:       01FC5093         ASR NL1, NL0, #16
; CD0:       22F87F92         AND NL2, NL1, #18446744073709551614
; CD4:       000002CA         EOR NL0, NL0, NL2
; CD8:       501700F9         STR R6, [CFP, #40]
; CDC:       401300F9         STR NL0, [CFP, #32]
; CE0:       4A0B40F9         LDR R0, [CFP, #16]
; CE4:       4B5141F8         LDR R1, [R0, #21]
; CE8:       7A0300F9         STR CFP, [CSP]
; CEC:       4A1340F9         LDR R0, [CFP, #32]
; CF0:       EC031DAA         MOV R2, NULL
; CF4:       F6E9FF58         LDR LEXENV, #x700AA62A30        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; CF8:       FA031BAA         MOV CFP, CSP
; CFC:       DE9240F8         LDR LR, [LEXENV, #9]
; D00:       C0033FD6         BLR LR
; D04:       FB0319AA         MOV CSP, OCFP
; D08:       501740F9         LDR R6, [CFP, #40]
; D0C:       EB030AAA         MOV R1, R0
; D10:       4AE9FF58         LDR R0, #x700AA62A38            ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::CONFIG-LOOKUP-EQUAL>
; D14:       4D1140F8         LDR R3, [R0, #1]
; D18:       BF011DEB         CMP R3, NULL
; D1C:       C0120054         BEQ L17
; D20:       7A0300F9         STR CFP, [CSP]
; D24:       EA0310AA         MOV R0, R6
; D28:       4CEAFF58         LDR R2, #x700AA62A70            ; :TEST
; D2C:       B6E8FF58         LDR LEXENV, #x700AA62A40        ; #<SB-KERNEL:FDEFN FIND>
; D30:       170180D2         MOVZ NARGS, #8
; D34:       FA031BAA         MOV CFP, CSP
; D38:       DE9240F8         LDR LR, [LEXENV, #9]
; D3C:       C0033FD6         BLR LR
; D40:       501740F9         LDR R6, [CFP, #40]
; D44:       EF030AAA         MOV R5, R0
; D48:       FF011DEB         CMP R5, NULL
; D4C:       00080054         BEQ L9
; D50:       E10D4092         AND NL1, R5, #15
; D54:       3F0C00F1         CMP NL1, #3
; D58:       61070054         BNE L8
; D5C:       EE5140F8         LDR R4, [R5, #5]
; D60:       C25145B8         LDR WNL2, [R4, #85]
; D64:       81EAFF18         LDR WNL1, #x700AA62AB4
; D68:       5F00016B         CMP WNL2, WNL1
; D6C:       C1060054         BNE L8
; D70:       EBD141F8         LDR R1, [R5, #29]
; D74:       0CD241F8         LDR R2, [R6, #29]
; D78:       4A0B40F9         LDR R0, [CFP, #16]
; D7C:       4AD141F8         LDR R0, [R0, #29]
; D80:       5F011DEB         CMP R0, NULL
; D84:       AAE30091         ADD R0, NULL, #56               ; T
; D88:       4D019D9A         CSEL R3, R0, NULL, EQ
; D8C:       50BF02A9         STP R6, R5, [CFP, #40]
; D90:       7A0300F9         STR CFP, [CSP]
; D94:       EA030BAA         MOV R0, R1
; D98:       EB030CAA         MOV R1, R2
; D9C:       EC030DAA         MOV R2, R3
; DA0:       4D0F40F9         LDR R3, [CFP, #24]
; DA4:       36E5FF58         LDR LEXENV, #x700AA62A48        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:MERGE-CONTEXTS>
; DA8:       170180D2         MOVZ NARGS, #8
; DAC:       FA031BAA         MOV CFP, CSP
; DB0:       DE9240F8         LDR LR, [LEXENV, #9]
; DB4:       C0033FD6         BLR LR
; DB8:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; DBC:       50BF42A9         LDP R6, R5, [CFP, #40]
; DC0:       5F011DEB         CMP R0, NULL
; DC4:       20010054         BEQ L3
; DC8:       410D4092         AND NL1, R0, #15
; DCC:       3F0C00F1         CMP NL1, #3
; DD0:       61030054         BNE L7
; DD4:       4E5140F8         LDR R4, [R0, #5]
; DD8:       C25145B8         LDR WNL2, [R4, #85]
; DDC:       E1E6FF18         LDR WNL1, #x700AA62AB8
; DE0:       5F00016B         CMP WNL2, WNL1
; DE4:       C1020054         BNE L7
; DE8: L3:   E9794BD3         UBFM TMP, R5, #11, #30
; DEC:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DF0:       EAD101F8         STR R0, [R5, #29]
; DF4:       E0D142F8         LDR NL0, [R5, #45]
; DF8:       01D242F8         LDR NL1, [R6, #45]
; DFC:       1F0001EB         CMP NL0, NL1
; E00:       20B0809A         CSEL NL0, NL1, NL0, LT
; E04:       E0D102F8         STR NL0, [R5, #45]
; E08:       EA5143F8         LDR R0, [R5, #53]
; E0C:       5F011DEB         CMP R0, NULL
; E10:       20010054         BEQ L6
; E14: L4:   E9794BD3         UBFM TMP, R5, #11, #30
; E18:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; E1C:       EA5103F8         STR R0, [R5, #53]
; E20: L5:   AAE30091         ADD R0, NULL, #56               ; T
; E24:       FB031AAA         MOV CSP, CFP
; E28:       5A7B40A9         LDP CFP, LR, [CFP]
; E2C:       BF0300F1         CMP NULL, #0
; E30:       C0035FD6         RET
; E34: L6:   0A5243F8         LDR R0, [R6, #53]
; E38:       F7FFFF17         B L4
; E3C: L7:   604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; E40:       47               BYTE #X47                       ; '(OR NULL
                                                              ;      CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT)
; E41:       .ALIGN           4
; E44: L8:   60E321D4         BRK #3867                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; E48:       4B               BYTE #X4B                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA36813}>
; E49:       .ALIGN           4
; E4C: L9:   501700F9         STR R6, [CFP, #40]
; E50:       4A0B40F9         LDR R0, [CFP, #16]
; E54:       4D5141F8         LDR R3, [R0, #21]
; E58:       4D0F00F9         STR R3, [CFP, #24]
; E5C:       7A0300F9         STR CFP, [CSP]
; E60:       4A1340F9         LDR R0, [CFP, #32]
; E64:       EB030DAA         MOV R1, R3
; E68:       EC031DAA         MOV R2, NULL
; E6C:       36DEFF58         LDR LEXENV, #x700AA62A30        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; E70:       FA031BAA         MOV CFP, CSP
; E74:       DE9240F8         LDR LR, [LEXENV, #9]
; E78:       C0033FD6         BLR LR
; E7C:       FB0319AA         MOV CSP, OCFP
; E80:       4D0F40F9         LDR R3, [CFP, #24]
; E84:       501740F9         LDR R6, [CFP, #40]
; E88:       EB0310AA         MOV R1, R6
; E8C:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; E90:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; E94:       2C410091         ADD R2, TMP, #16
; E98:       9F011EEB         CMP R2, LR
; E9C:       E8060054         BHI L18
; EA0:       AC2E00F9         STR R2, [THREAD, #88]           ; cons-tlab
; EA4: L10:  2C1D0091         ADD R2, TMP, #7
; EA8:       2B2900A9         STP R1, R0, [TMP]
; EAC:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; EB0:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; EB4:       5E0000B4         CBZ LR, L11
; EB8:       200120D4         BRK #9                          ; Pending interrupt trap
; EBC: L11:  7A0300F9         STR CFP, [CSP]
; EC0:       4A1340F9         LDR R0, [CFP, #32]
; EC4:       EB030DAA         MOV R1, R3
; EC8:       56DCFF58         LDR LEXENV, #x700AA62A50        ; #<SB-KERNEL:FDEFN SB-KERNEL:%PUTHASH>
; ECC:       FA031BAA         MOV CFP, CSP
; ED0:       DE9240F8         LDR LR, [LEXENV, #9]
; ED4:       C0033FD6         BLR LR
; ED8:       501740F9         LDR R6, [CFP, #40]
; EDC:       4A0B40F9         LDR R0, [CFP, #16]
; EE0:       4BD140F8         LDR R1, [R0, #13]
; EE4:       7A0300F9         STR CFP, [CSP]
; EE8:       EA0310AA         MOV R0, R6
; EEC:       76DBFF58         LDR LEXENV, #x700AA62A58        ; #<SB-KERNEL:FDEFN VECTOR-PUSH-EXTEND>
; EF0:       970080D2         MOVZ NARGS, #4
; EF4:       FA031BAA         MOV CFP, CSP
; EF8:       DE9240F8         LDR LR, [LEXENV, #9]
; EFC:       C0033FD6         BLR LR
; F00:       C8FFFF17         B L5
; F04: L12:  434302A9         STP NL3, R6, [CFP, #32]
; F08:       0A5242F8         LDR R0, [R6, #37]
; F0C:       7A0300F9         STR CFP, [CSP]
; F10:       96DAFF58         LDR LEXENV, #x700AA62A60        ; #<SB-KERNEL:FDEFN SXHASH>
; F14:       570080D2         MOVZ NARGS, #2
; F18:       FA031BAA         MOV CFP, CSP
; F1C:       DE9240F8         LDR LR, [LEXENV, #9]
; F20:       C0033FD6         BLR LR
; F24:       434342A9         LDP NL3, R6, [CFP, #32]
; F28:       407D7F92         AND NL0, R0, #8589934590
; F2C:       40FFFF17         B L2
; F30: L13:  4A0B40F9         LDR R0, [CFP, #16]
; F34:       ABE30091         ADD R1, NULL, #56               ; T
; F38:       4BD103F8         STR R1, [R0, #61]
; F3C:       1AFFFF17         B L1
; F40: L14:  600322D4         BRK #4123                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R6
; F44:       4B               BYTE #X4B                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA36813}>
; F45:       .ALIGN           4
; F48: L15:  0ADAFF58         LDR R0, #x700AA62A88            ; "ATNConfigSet is read-only"
; F4C:       570080D2         MOVZ NARGS, #2
; F50:       29D280D2         MOVZ TMP, #1681
; F54:       BE6B69F8         LDR LR, [NULL, TMP]             ; ERROR
; F58:       DE130091         ADD LR, LR, #4
; F5C:       C0031FD6         BR LR
; F60: L16:  4A0B40F9         LDR R0, [CFP, #16]
; F64:       604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; F68:       53               BYTE #X53                       ; #<SB-KERNEL:LAYOUT (ID=396) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG-SET {700AA3F173}>
; F69:       .ALIGN           4
; F6C:       E00120D4         BRK #15                         ; Invalid argument count trap
; F70:       E08221D4         BRK #3095                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; F74: L17:  204221D4         BRK #2577                       ; UNDEFINED-FUN-ERROR
                                                              ; R0
; F78: L18:  090280D2         MOVZ TMP, #16
; F7C:       6CD9FF58         LDR R2, #x700AA62AA8            ; SB-VM::LIST-ALLOC-TRAMP
; F80:       80013FD6         BLR R2
; F84:       C8FFFF17         B L10
