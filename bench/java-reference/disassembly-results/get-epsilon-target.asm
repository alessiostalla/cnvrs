; disassembly for CNVRS/RUNTIME::GET-EPSILON-TARGET
; Size: 1068 bytes. Origin: #x700AA6EB90                      ; CNVRS/RUNTIME::GET-EPSILON-TARGET
; B90:       610D4092         AND NL1, R1, #15
; B94:       3F0C00F1         CMP NL1, #3
; B98:       01200054         BNE L31
; B9C:       6E5140F8         LDR R4, [R1, #5]
; BA0:       C25145B8         LDR WNL2, [R4, #85]
; BA4:       61FDFF18         LDR WNL1, #x700AA6EB50
; BA8:       5F00016B         CMP WNL2, WNL1
; BAC:       611F0054         BNE L31
; BB0:       605141F8         LDR NL0, [R1, #21]
; BB4:       400F00F9         STR NL0, [CFP, #24]
; BB8:       6AD140F8         LDR R0, [R1, #13]
; BBC:       6CF7FF58         LDR R2, #x700AA6EAA8            ; :RULE
; BC0:       5F010CEB         CMP R0, R2
; BC4:       E01A0054         BEQ L28
; BC8:       4CF7FF58         LDR R2, #x700AA6EAB0            ; :EPSILON
; BCC:       5F010CEB         CMP R0, R2
; BD0:       C0190054         BEQ L27
; BD4:       2CF7FF58         LDR R2, #x700AA6EAB8            ; :ACTION
; BD8:       5F010CEB         CMP R0, R2
; BDC:       60190054         BEQ L27
; BE0:       0CF7FF58         LDR R2, #x700AA6EAC0            ; :PREDICATE
; BE4:       5F010CEB         CMP R0, R2
; BE8:       610C0054         BNE L14
; BEC: L0:   6AD140F8         LDR R0, [R1, #13]
; BF0:       CCF6FF58         LDR R2, #x700AA6EAC8            ; :PRECEDENCE
; BF4:       5F010CEB         CMP R0, R2
; BF8:       AAE30091         ADD R0, NULL, #56               ; T
; BFC:       4D019D9A         CSEL R3, R0, NULL, EQ
; C00:       BF011DEB         CMP R3, NULL
; C04:       400B0054         BEQ L13
; C08:       6A5142F8         LDR R0, [R1, #37]
; C0C:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; C10:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; C14:       30810091         ADD R6, TMP, #32
; C18:       1F021EEB         CMP R6, LR
; C1C:       481C0054         BHI L32
; C20:       B02E00F9         STR R6, [THREAD, #88]           ; cons-tlab
; C24: L1:   301D0091         ADD R6, TMP, #7
; C28:       EE0310AA         MOV R4, R6
; C2C:       EFF4FF58         LDR R5, #x700AA6EAC8            ; :PRECEDENCE
; C30:       CF911FF8         STR R5, [R4, #-7]
; C34:       CE410091         ADD R4, R4, #16
; C38:       CE111FF8         STR R4, [R4, #-15]
; C3C:       CA911FF8         STR R0, [R4, #-7]
; C40:       DD1100F8         STR NULL, [R4, #1]
; C44:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; C48:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; C4C:       5E0000B4         CBZ LR, L2
; C50:       200120D4         BRK #9                          ; Pending interrupt trap
; C54: L2:   EC0310AA         MOV R2, R6
; C58: L3:   3F021DEB         CMP R7, NULL
; C5C:       40070054         BEQ L11
; C60:       BF011DEB         CMP R3, NULL
; C64:       C0070054         BEQ L12
; C68: L4:   7F021DEB         CMP R9, NULL
; C6C:       C0060054         BEQ L11
; C70: L5:   9F021DEB         CMP R8, NULL
; C74:       C0020054         BEQ L8
; C78:       7A0300F9         STR CFP, [CSP]
; C7C:       EA030CAA         MOV R0, R2
; C80:       16F0FF58         LDR LEXENV, #x700AA6EA80        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::SEMANTIC-EVAL>
; C84:       570080D2         MOVZ NARGS, #2
; C88:       FA031BAA         MOV CFP, CSP
; C8C:       DE9240F8         LDR LR, [LEXENV, #9]
; C90:       C0033FD6         BLR LR
; C94:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; C98:       5F011DEB         CMP R0, NULL
; C9C:       C1000054         BNE L7
; CA0: L6:   EA031DAA         MOV R0, NULL
; CA4:       FB031AAA         MOV CSP, CFP
; CA8:       5A7B40A9         LDP CFP, LR, [CFP]
; CAC:       BF0300F1         CMP NULL, #0
; CB0:       C0035FD6         RET
; CB4: L7:   4A2F41A9         LDP R0, R1, [CFP, #16]
; CB8:       96EEFF58         LDR LEXENV, #x700AA6EA88        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; CBC:       970080D2         MOVZ NARGS, #4
; CC0:       DE9240F8         LDR LR, [LEXENV, #9]
; CC4:       DE130091         ADD LR, LR, #4
; CC8:       C0031FD6         BR LR
; CCC: L8:   4A0B40F9         LDR R0, [CFP, #16]
; CD0:       410D4092         AND NL1, R0, #15
; CD4:       3F0C00F1         CMP NL1, #3
; CD8:       C1000054         BNE L9
; CDC:       4E5140F8         LDR R4, [R0, #5]
; CE0:       C25145B8         LDR WNL2, [R4, #85]
; CE4:       81F3FF18         LDR WNL1, #x700AA6EB54
; CE8:       5F00016B         CMP WNL2, WNL1
; CEC:       80000054         BEQ L10
; CF0: L9:   4A0B40F9         LDR R0, [CFP, #16]
; CF4:       604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; CF8:       4B               BYTE #X4B                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-CONFIG {700AA36813}>
; CF9:       .ALIGN           4
; CFC: L10:  4A0B40F9         LDR R0, [CFP, #16]
; D00:       4B5142F8         LDR R1, [R0, #37]
; D04:       7A0300F9         STR CFP, [CSP]
; D08:       8AEEFF58         LDR R0, #x700AA6EAD8            ; :AND
; D0C:       36ECFF58         LDR LEXENV, #x700AA6EA90        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::SEMANTIC-OPERATOR>
; D10:       D70080D2         MOVZ NARGS, #6
; D14:       FA031BAA         MOV CFP, CSP
; D18:       DE9240F8         LDR LR, [LEXENV, #9]
; D1C:       C0033FD6         BLR LR
; D20:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; D24:       ED030AAA         MOV R3, R0
; D28:       4A2F41A9         LDP R0, R1, [CFP, #16]
; D2C:       ACEDFF58         LDR R2, #x700AA6EAE0            ; :SEMANTIC
; D30:       D6EAFF58         LDR LEXENV, #x700AA6EA88        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; D34:       170180D2         MOVZ NARGS, #8
; D38:       DE9240F8         LDR LR, [LEXENV, #9]
; D3C:       DE130091         ADD LR, LR, #4
; D40:       C0031FD6         BR LR
; D44: L11:  4A2F41A9         LDP R0, R1, [CFP, #16]
; D48:       16EAFF58         LDR LEXENV, #x700AA6EA88        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; D4C:       970080D2         MOVZ NARGS, #4
; D50:       DE9240F8         LDR LR, [LEXENV, #9]
; D54:       DE130091         ADD LR, LR, #4
; D58:       C0031FD6         BR LR
; D5C: L12:  6A5143F8         LDR R0, [R1, #53]
; D60:       5F011DEB         CMP R0, NULL
; D64:       60F8FF54         BEQ L5
; D68:       C0FFFF17         B L4
; D6C: L13:  6C5142F8         LDR R2, [R1, #37]
; D70:       BAFFFF17         B L3
; D74: L14:  ACEAFF58         LDR R2, #x700AA6EAC8            ; :PRECEDENCE
; D78:       5F010CEB         CMP R0, R2
; D7C:       80F3FF54         BEQ L0
; D80:       4CEBFF58         LDR R2, #x700AA6EAE8            ; :ATOM
; D84:       5F010CEB         CMP R0, R2
; D88:       A1090054         BNE L26
; D8C: L15:  FF011DEB         CMP R5, NULL
; D90:       80F8FF54         BEQ L6
; D94:       6A5142F8         LDR R0, [R1, #37]
; D98:       EC030AAA         MOV R2, R0
; D9C:       6BD140F8         LDR R1, [R1, #13]
; DA0:       4DEAFF58         LDR R3, #x700AA6EAE8            ; :ATOM
; DA4:       7F010DEB         CMP R1, R3
; DA8:       21010054         BNE L17
; DAC:       5F0900B1         CMN R0, #2
; DB0:       81F7FF54         BNE L6
; DB4: L16:  4A2F41A9         LDP R0, R1, [CFP, #16]
; DB8:       96E6FF58         LDR LEXENV, #x700AA6EA88        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; DBC:       970080D2         MOVZ NARGS, #4
; DC0:       DE9240F8         LDR LR, [LEXENV, #9]
; DC4:       DE130091         ADD LR, LR, #4
; DC8:       C0031FD6         BR LR
; DCC: L17:  2DE9FF58         LDR R3, #x700AA6EAF0            ; :RANGE
; DD0:       7F010DEB         CMP R1, R3
; DD4:       80050054         BEQ L22
; DD8:       0AE9FF58         LDR R0, #x700AA6EAF8            ; :SET
; DDC:       7F010AEB         CMP R1, R0
; DE0:       E0030054         BEQ L21
; DE4:       EAE8FF58         LDR R0, #x700AA6EB00            ; :NOT-SET
; DE8:       7F010AEB         CMP R1, R0
; DEC:       00020054         BEQ L19
; DF0:       CAE8FF58         LDR R0, #x700AA6EB08            ; :WILDCARD
; DF4:       7F010AEB         CMP R1, R0
; DF8:       41F5FF54         BNE L6
; DFC:       ABE8FF58         LDR R1, #x700AA6EB10            ; 'CNVRS/RUNTIME::*SIMULATOR*
; E00:       61515FB8         LDR WNL1, [R1, #-11]
; E04:       AA6A61F8         LDR R0, [THREAD, NL1]
; E08:       5F0500B1         CMN R0, #1
; E0C:       41000054         BNE L18
; E10:       6A1140F8         LDR R0, [R1, #1]
; E14: L18:  5F2500F1         CMP R0, #9
; E18:       E00C0054         BEQ L33
; E1C:       5F011DEB         CMP R0, NULL
; E20:       01F4FF54         BNE L6
; E24:       60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; E28:       6F               BYTE #X6F                       ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {700AAD1EE3}>
; E29:       .ALIGN           4
; E2C: L19:  2BE7FF58         LDR R1, #x700AA6EB10            ; 'CNVRS/RUNTIME::*SIMULATOR*
; E30:       61515FB8         LDR WNL1, [R1, #-11]
; E34:       AA6A61F8         LDR R0, [THREAD, NL1]
; E38:       5F0500B1         CMN R0, #1
; E3C:       41000054         BNE L20
; E40:       6A1140F8         LDR R0, [R1, #1]
; E44: L20:  5F2500F1         CMP R0, #9
; E48:       800B0054         BEQ L34
; E4C:       5F011DEB         CMP R0, NULL
; E50:       81F2FF54         BNE L6
; E54:       60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; E58:       6F               BYTE #X6F                       ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {700AAD1EE3}>
; E59:       .ALIGN           4
; E5C: L21:  7A0300F9         STR CFP, [CSP]
; E60:       2A008092         MOVN R0, #1
; E64:       EB030CAA         MOV R1, R2
; E68:       96E1FF58         LDR LEXENV, #x700AA6EA98        ; #<SB-KERNEL:FDEFN SB-KERNEL:%MEMBER-EQ>
; E6C:       FA031BAA         MOV CFP, CSP
; E70:       DE9240F8         LDR LR, [LEXENV, #9]
; E74:       C0033FD6         BLR LR
; E78:       5F011DEB         CMP R0, NULL
; E7C:       20F1FF54         BEQ L6
; E80:       CDFFFF17         B L16
; E84: L22:  410D4092         AND NL1, R0, #15
; E88:       3F1C00F1         CMP NL1, #7
; E8C:       61010054         BNE L25
; E90:       4B915FF8         LDR R1, [R0, #-7]
; E94:       0B010037         TBNZ WR1, #0, L24
; E98:       4A1140F8         LDR R0, [R0, #1]
; E9C:       AA000037         TBNZ WR0, #0, L23
; EA0:       0BF0FFB6         TBZ R1, #63, L6
; EA4:       5F0900B1         CMN R0, #2
; EA8:       CBEFFF54         BLT L6
; EAC:       C2FFFF17         B L16
; EB0: L23:  A04A21D4         BRK #2645                       ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; R0
; EB4: L24:  A06A21D4         BRK #2901                       ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; R1
; EB8: L25:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; EBC: L26:  ACE1FF58         LDR R2, #x700AA6EAF0            ; :RANGE
; EC0:       5F010CEB         CMP R0, R2
; EC4:       40F6FF54         BEQ L15
; EC8:       8CE1FF58         LDR R2, #x700AA6EAF8            ; :SET
; ECC:       5F010CEB         CMP R0, R2
; ED0:       E0F5FF54         BEQ L15
; ED4:       6CE1FF58         LDR R2, #x700AA6EB00            ; :NOT-SET
; ED8:       5F010CEB         CMP R0, R2
; EDC:       20EEFF54         BEQ L6
; EE0:       4CE1FF58         LDR R2, #x700AA6EB08            ; :WILDCARD
; EE4:       5F010CEB         CMP R0, R2
; EE8:       C0EDFF54         BEQ L6
; EEC:       6BD140F8         LDR R1, [R1, #13]
; EF0:       8AE1FF58         LDR R0, #x700AA6EB20            ; "Unsupported ATN transition: ~S"
; EF4:       970080D2         MOVZ NARGS, #4
; EF8:       29D280D2         MOVZ TMP, #1681
; EFC:       BE6B69F8         LDR LR, [NULL, TMP]             ; ERROR
; F00:       DE130091         ADD LR, LR, #4
; F04:       C0031FD6         BR LR
; F08: L27:  4A2F41A9         LDP R0, R1, [CFP, #16]
; F0C:       F6DBFF58         LDR LEXENV, #x700AA6EA88        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; F10:       970080D2         MOVZ NARGS, #4
; F14:       DE9240F8         LDR LR, [LEXENV, #9]
; F18:       DE130091         ADD LR, LR, #4
; F1C:       C0031FD6         BR LR
; F20: L28:  4A0B40F9         LDR R0, [CFP, #16]
; F24:       410D4092         AND NL1, R0, #15
; F28:       3F0C00F1         CMP NL1, #3
; F2C:       C1000054         BNE L29
; F30:       4E5140F8         LDR R4, [R0, #5]
; F34:       C25145B8         LDR WNL2, [R4, #85]
; F38:       E1E0FF18         LDR WNL1, #x700AA6EB54
; F3C:       5F00016B         CMP WNL2, WNL1
; F40:       80000054         BEQ L30
; F44: L29:  4A0B40F9         LDR R0, [CFP, #16]
; F48:       604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; F4C:       4B               BYTE #X4B                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-CONFIG {700AA36813}>
; F4D:       .ALIGN           4
; F50: L30:  4A0B40F9         LDR R0, [CFP, #16]
; F54:       4AD141F8         LDR R0, [R0, #29]
; F58:       6BD141F8         LDR R1, [R1, #29]
; F5C:       7A0300F9         STR CFP, [CSP]
; F60:       16DAFF58         LDR LEXENV, #x700AA6EAA0        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:SINGLETON-CONTEXT>
; F64:       970080D2         MOVZ NARGS, #4
; F68:       FA031BAA         MOV CFP, CSP
; F6C:       DE9240F8         LDR LR, [LEXENV, #9]
; F70:       C0033FD6         BLR LR
; F74:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; F78:       ED030AAA         MOV R3, R0
; F7C:       4A2F41A9         LDP R0, R1, [CFP, #16]
; F80:       4CDDFF58         LDR R2, #x700AA6EB28            ; :CONTEXT
; F84:       36D8FF58         LDR LEXENV, #x700AA6EA88        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; F88:       170180D2         MOVZ NARGS, #8
; F8C:       DE9240F8         LDR LR, [LEXENV, #9]
; F90:       DE130091         ADD LR, LR, #4
; F94:       C0031FD6         BR LR
; F98: L31:  606321D4         BRK #2843                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R1
; F9C:       7B               BYTE #X7B                       ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/RUNTIME:ATN-TRANSITION {700AA2D0D3}>
; F9D:       .ALIGN           4
; FA0:       E00120D4         BRK #15                         ; Invalid argument count trap
; FA4: L32:  090480D2         MOVZ TMP, #32
; FA8:       10DDFF58         LDR R6, #x700AA6EB48            ; SB-VM::LIST-ALLOC-TRAMP
; FAC:       00023FD6         BLR R6
; FB0:       1DFFFF17         B L1
; FB4: L33:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; FB8: L34:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
