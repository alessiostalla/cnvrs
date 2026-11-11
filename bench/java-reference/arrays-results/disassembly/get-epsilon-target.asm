; disassembly for CNVRS/RUNTIME::GET-EPSILON-TARGET
; Size: 932 bytes. Origin: #x700AB02D74                       ; CNVRS/RUNTIME::GET-EPSILON-TARGET
; 2D74:       605141F8         LDR NL0, [R1, #21]
; 2D78:       400F00F9         STR NL0, [CFP, #24]
; 2D7C:       6AD140F8         LDR R0, [R1, #13]
; 2D80:       4CF6FF58         LDR R2, #x700AB02C48           ; :RULE
; 2D84:       5F010CEB         CMP R0, R2
; 2D88:       60190054         BEQ L26
; 2D8C:       2CF6FF58         LDR R2, #x700AB02C50           ; :EPSILON
; 2D90:       5F010CEB         CMP R0, R2
; 2D94:       40180054         BEQ L25
; 2D98:       0CF6FF58         LDR R2, #x700AB02C58           ; :ACTION
; 2D9C:       5F010CEB         CMP R0, R2
; 2DA0:       E0170054         BEQ L25
; 2DA4:       ECF5FF58         LDR R2, #x700AB02C60           ; :PREDICATE
; 2DA8:       5F010CEB         CMP R0, R2
; 2DAC:       E10A0054         BNE L12
; 2DB0: L0:   6AD140F8         LDR R0, [R1, #13]
; 2DB4:       ACF5FF58         LDR R2, #x700AB02C68           ; :PRECEDENCE
; 2DB8:       5F010CEB         CMP R0, R2
; 2DBC:       AAE30091         ADD R0, NULL, #56              ; T
; 2DC0:       4D019D9A         CSEL R3, R0, NULL, EQ
; 2DC4:       BF011DEB         CMP R3, NULL
; 2DC8:       C0090054         BEQ L11
; 2DCC:       6A5142F8         LDR R0, [R1, #37]
; 2DD0:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 2DD4:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 2DD8:       30810091         ADD R6, TMP, #32
; 2DDC:       1F021EEB         CMP R6, LR
; 2DE0:       08190054         BHI L27
; 2DE4:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 2DE8: L1:   301D0091         ADD R6, TMP, #7
; 2DEC:       EE0310AA         MOV R4, R6
; 2DF0:       CFF3FF58         LDR R5, #x700AB02C68           ; :PRECEDENCE
; 2DF4:       CF911FF8         STR R5, [R4, #-7]
; 2DF8:       CE410091         ADD R4, R4, #16
; 2DFC:       CE111FF8         STR R4, [R4, #-15]
; 2E00:       CA911FF8         STR R0, [R4, #-7]
; 2E04:       DD1100F8         STR NULL, [R4, #1]
; 2E08:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 2E0C:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 2E10:       5E0000B4         CBZ LR, L2
; 2E14:       200120D4         BRK #9                         ; Pending interrupt trap
; 2E18: L2:   EC0310AA         MOV R2, R6
; 2E1C: L3:   3F021DEB         CMP R7, NULL
; 2E20:       C0050054         BEQ L9
; 2E24:       BF011DEB         CMP R3, NULL
; 2E28:       40060054         BEQ L10
; 2E2C: L4:   7F021DEB         CMP R9, NULL
; 2E30:       40050054         BEQ L9
; 2E34: L5:   9F021DEB         CMP R8, NULL
; 2E38:       C0020054         BEQ L8
; 2E3C:       7A0300F9         STR CFP, [CSP]
; 2E40:       EA030CAA         MOV R0, R2
; 2E44:       76EEFF58         LDR LEXENV, #x700AB02C10       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::SEMANTIC-EVAL>
; 2E48:       570080D2         MOVZ NARGS, #2
; 2E4C:       FA031BAA         MOV CFP, CSP
; 2E50:       DE9240F8         LDR LR, [LEXENV, #9]
; 2E54:       C0033FD6         BLR LR
; 2E58:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 2E5C:       5F011DEB         CMP R0, NULL
; 2E60:       C1000054         BNE L7
; 2E64: L6:   EA031DAA         MOV R0, NULL
; 2E68:       FB031AAA         MOV CSP, CFP
; 2E6C:       5A7B40A9         LDP CFP, LR, [CFP]
; 2E70:       BF0300F1         CMP NULL, #0
; 2E74:       C0035FD6         RET
; 2E78: L7:   4A2F41A9         LDP R0, R1, [CFP, #16]
; 2E7C:       F6ECFF58         LDR LEXENV, #x700AB02C18       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 2E80:       970080D2         MOVZ NARGS, #4
; 2E84:       DE9240F8         LDR LR, [LEXENV, #9]
; 2E88:       DE130091         ADD LR, LR, #4
; 2E8C:       C0031FD6         BR LR
; 2E90: L8:   4A0B40F9         LDR R0, [CFP, #16]
; 2E94:       4B5142F8         LDR R1, [R0, #37]
; 2E98:       7A0300F9         STR CFP, [CSP]
; 2E9C:       AAEEFF58         LDR R0, #x700AB02C70           ; :AND
; 2EA0:       16ECFF58         LDR LEXENV, #x700AB02C20       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::SEMANTIC-OPERATOR>
; 2EA4:       D70080D2         MOVZ NARGS, #6
; 2EA8:       FA031BAA         MOV CFP, CSP
; 2EAC:       DE9240F8         LDR LR, [LEXENV, #9]
; 2EB0:       C0033FD6         BLR LR
; 2EB4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 2EB8:       ED030AAA         MOV R3, R0
; 2EBC:       4A2F41A9         LDP R0, R1, [CFP, #16]
; 2EC0:       CCEDFF58         LDR R2, #x700AB02C78           ; :SEMANTIC
; 2EC4:       B6EAFF58         LDR LEXENV, #x700AB02C18       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 2EC8:       170180D2         MOVZ NARGS, #8
; 2ECC:       DE9240F8         LDR LR, [LEXENV, #9]
; 2ED0:       DE130091         ADD LR, LR, #4
; 2ED4:       C0031FD6         BR LR
; 2ED8: L9:   4A2F41A9         LDP R0, R1, [CFP, #16]
; 2EDC:       F6E9FF58         LDR LEXENV, #x700AB02C18       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 2EE0:       970080D2         MOVZ NARGS, #4
; 2EE4:       DE9240F8         LDR LR, [LEXENV, #9]
; 2EE8:       DE130091         ADD LR, LR, #4
; 2EEC:       C0031FD6         BR LR
; 2EF0: L10:  6A5143F8         LDR R0, [R1, #53]
; 2EF4:       5F011DEB         CMP R0, NULL
; 2EF8:       E0F9FF54         BEQ L5
; 2EFC:       CCFFFF17         B L4
; 2F00: L11:  6C5142F8         LDR R2, [R1, #37]
; 2F04:       C6FFFF17         B L3
; 2F08: L12:  0CEBFF58         LDR R2, #x700AB02C68           ; :PRECEDENCE
; 2F0C:       5F010CEB         CMP R0, R2
; 2F10:       00F5FF54         BEQ L0
; 2F14:       6CEBFF58         LDR R2, #x700AB02C80           ; :ATOM
; 2F18:       5F010CEB         CMP R0, R2
; 2F1C:       A1090054         BNE L24
; 2F20: L13:  1F021DEB         CMP R6, NULL
; 2F24:       00FAFF54         BEQ L6
; 2F28:       6A5142F8         LDR R0, [R1, #37]
; 2F2C:       EC030AAA         MOV R2, R0
; 2F30:       6BD140F8         LDR R1, [R1, #13]
; 2F34:       6DEAFF58         LDR R3, #x700AB02C80           ; :ATOM
; 2F38:       7F010DEB         CMP R1, R3
; 2F3C:       21010054         BNE L15
; 2F40:       5F0900B1         CMN R0, #2
; 2F44:       01F9FF54         BNE L6
; 2F48: L14:  4A2F41A9         LDP R0, R1, [CFP, #16]
; 2F4C:       76E6FF58         LDR LEXENV, #x700AB02C18       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 2F50:       970080D2         MOVZ NARGS, #4
; 2F54:       DE9240F8         LDR LR, [LEXENV, #9]
; 2F58:       DE130091         ADD LR, LR, #4
; 2F5C:       C0031FD6         BR LR
; 2F60: L15:  4DE9FF58         LDR R3, #x700AB02C88           ; :RANGE
; 2F64:       7F010DEB         CMP R1, R3
; 2F68:       80050054         BEQ L20
; 2F6C:       2AE9FF58         LDR R0, #x700AB02C90           ; :SET
; 2F70:       7F010AEB         CMP R1, R0
; 2F74:       E0030054         BEQ L19
; 2F78:       0AE9FF58         LDR R0, #x700AB02C98           ; :NOT-SET
; 2F7C:       7F010AEB         CMP R1, R0
; 2F80:       00020054         BEQ L17
; 2F84:       EAE8FF58         LDR R0, #x700AB02CA0           ; :WILDCARD
; 2F88:       7F010AEB         CMP R1, R0
; 2F8C:       C1F6FF54         BNE L6
; 2F90:       CBE8FF58         LDR R1, #x700AB02CA8           ; 'CNVRS/RUNTIME::*SIMULATOR*
; 2F94:       61515FB8         LDR WNL1, [R1, #-11]
; 2F98:       AA6A61F8         LDR R0, [THREAD, NL1]
; 2F9C:       5F0500B1         CMN R0, #1
; 2FA0:       41000054         BNE L16
; 2FA4:       6A1140F8         LDR R0, [R1, #1]
; 2FA8: L16:  5F2500F1         CMP R0, #9
; 2FAC:       200B0054         BEQ L28
; 2FB0:       5F011DEB         CMP R0, NULL
; 2FB4:       81F5FF54         BNE L6
; 2FB8:       60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 2FBC:       73               BYTE #X73                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 2FBD:       .ALIGN           4
; 2FC0: L17:  4BE7FF58         LDR R1, #x700AB02CA8           ; 'CNVRS/RUNTIME::*SIMULATOR*
; 2FC4:       61515FB8         LDR WNL1, [R1, #-11]
; 2FC8:       AA6A61F8         LDR R0, [THREAD, NL1]
; 2FCC:       5F0500B1         CMN R0, #1
; 2FD0:       41000054         BNE L18
; 2FD4:       6A1140F8         LDR R0, [R1, #1]
; 2FD8: L18:  5F2500F1         CMP R0, #9
; 2FDC:       C0090054         BEQ L29
; 2FE0:       5F011DEB         CMP R0, NULL
; 2FE4:       01F4FF54         BNE L6
; 2FE8:       60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 2FEC:       73               BYTE #X73                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 2FED:       .ALIGN           4
; 2FF0: L19:  7A0300F9         STR CFP, [CSP]
; 2FF4:       2A008092         MOVN R0, #1
; 2FF8:       EB030CAA         MOV R1, R2
; 2FFC:       76E1FF58         LDR LEXENV, #x700AB02C28       ; #<SB-KERNEL:FDEFN SB-KERNEL:%MEMBER-EQ>
; 3000:       FA031BAA         MOV CFP, CSP
; 3004:       DE9240F8         LDR LR, [LEXENV, #9]
; 3008:       C0033FD6         BLR LR
; 300C:       5F011DEB         CMP R0, NULL
; 3010:       A0F2FF54         BEQ L6
; 3014:       CDFFFF17         B L14
; 3018: L20:  410D4092         AND NL1, R0, #15
; 301C:       3F1C00F1         CMP NL1, #7
; 3020:       61010054         BNE L23
; 3024:       4B915FF8         LDR R1, [R0, #-7]
; 3028:       0B010037         TBNZ WR1, #0, L22
; 302C:       4A1140F8         LDR R0, [R0, #1]
; 3030:       AA000037         TBNZ WR0, #0, L21
; 3034:       8BF1FFB6         TBZ R1, #63, L6
; 3038:       5F0900B1         CMN R0, #2
; 303C:       4BF1FF54         BLT L6
; 3040:       C2FFFF17         B L14
; 3044: L21:  A04A21D4         BRK #2645                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; R0
; 3048: L22:  A06A21D4         BRK #2901                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; R1
; 304C: L23:  E04921D4         BRK #2639                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 3050: L24:  CCE1FF58         LDR R2, #x700AB02C88           ; :RANGE
; 3054:       5F010CEB         CMP R0, R2
; 3058:       40F6FF54         BEQ L13
; 305C:       ACE1FF58         LDR R2, #x700AB02C90           ; :SET
; 3060:       5F010CEB         CMP R0, R2
; 3064:       E0F5FF54         BEQ L13
; 3068:       8CE1FF58         LDR R2, #x700AB02C98           ; :NOT-SET
; 306C:       5F010CEB         CMP R0, R2
; 3070:       A0EFFF54         BEQ L6
; 3074:       6CE1FF58         LDR R2, #x700AB02CA0           ; :WILDCARD
; 3078:       5F010CEB         CMP R0, R2
; 307C:       40EFFF54         BEQ L6
; 3080:       6BD140F8         LDR R1, [R1, #13]
; 3084:       AAE1FF58         LDR R0, #x700AB02CB8           ; "Unsupported ATN transition: ~S"
; 3088:       970080D2         MOVZ NARGS, #4
; 308C:       29D280D2         MOVZ TMP, #1681
; 3090:       BE6B69F8         LDR LR, [NULL, TMP]            ; ERROR
; 3094:       DE130091         ADD LR, LR, #4
; 3098:       C0031FD6         BR LR
; 309C: L25:  4A2F41A9         LDP R0, R1, [CFP, #16]
; 30A0:       D6DBFF58         LDR LEXENV, #x700AB02C18       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 30A4:       970080D2         MOVZ NARGS, #4
; 30A8:       DE9240F8         LDR LR, [LEXENV, #9]
; 30AC:       DE130091         ADD LR, LR, #4
; 30B0:       C0031FD6         BR LR
; 30B4: L26:  4A0B40F9         LDR R0, [CFP, #16]
; 30B8:       4AD141F8         LDR R0, [R0, #29]
; 30BC:       6BD141F8         LDR R1, [R1, #29]
; 30C0:       7A0300F9         STR CFP, [CSP]
; 30C4:       76DBFF58         LDR LEXENV, #x700AB02C30       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:SINGLETON-CONTEXT>
; 30C8:       970080D2         MOVZ NARGS, #4
; 30CC:       FA031BAA         MOV CFP, CSP
; 30D0:       DE9240F8         LDR LR, [LEXENV, #9]
; 30D4:       C0033FD6         BLR LR
; 30D8:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 30DC:       ED030AAA         MOV R3, R0
; 30E0:       4A2F41A9         LDP R0, R1, [CFP, #16]
; 30E4:       ECDEFF58         LDR R2, #x700AB02CC0           ; :CONTEXT
; 30E8:       96D9FF58         LDR LEXENV, #x700AB02C18       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 30EC:       170180D2         MOVZ NARGS, #8
; 30F0:       DE9240F8         LDR LR, [LEXENV, #9]
; 30F4:       DE130091         ADD LR, LR, #4
; 30F8:       C0031FD6         BR LR
; 30FC:       E00120D4         BRK #15                        ; Invalid argument count trap
; 3100: L27:  090480D2         MOVZ TMP, #32
; 3104:       B0DEFF58         LDR R6, #x700AB02CD8           ; SB-VM::LIST-ALLOC-TRAMP
; 3108:       00023FD6         BLR R6
; 310C:       37FFFF17         B L1
; 3110: L28:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 3114: L29:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
