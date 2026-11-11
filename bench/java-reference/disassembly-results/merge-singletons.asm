; disassembly for CNVRS/RUNTIME::MERGE-SINGLETONS
; Size: 1168 bytes. Origin: #x700A997B38                      ; CNVRS/RUNTIME::MERGE-SINGLETONS
; B38:       7A0300F9         STR CFP, [CSP]
; B3C:       4A1740F9         LDR R0, [CFP, #40]
; B40:       4B3341A9         LDP R1, R2, [CFP, #16]
; B44:       4D1340F9         LDR R3, [CFP, #32]
; B48:       56FBFF58         LDR LEXENV, #x700A997AB0        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-GET>
; B4C:       170180D2         MOVZ NARGS, #8
; B50:       FA031BAA         MOV CFP, CSP
; B54:       DE9240F8         LDR LR, [LEXENV, #9]
; B58:       C0033FD6         BLR LR
; B5C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; B60:       5F011DEB         CMP R0, NULL
; B64:       01190054         BNE L14
; B68:       7A0300F9         STR CFP, [CSP]
; B6C:       4A2F41A9         LDP R0, R1, [CFP, #16]
; B70:       4C1340F9         LDR R2, [CFP, #32]
; B74:       36FAFF58         LDR LEXENV, #x700A997AB8        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-ROOT>
; B78:       D70080D2         MOVZ NARGS, #6
; B7C:       FA031BAA         MOV CFP, CSP
; B80:       DE9240F8         LDR LR, [LEXENV, #9]
; B84:       C0033FD6         BLR LR
; B88:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; B8C:       EE030AAA         MOV R4, R0
; B90:       DF011DEB         CMP R4, NULL
; B94:       611F0054         BNE L25
; B98:       4A0B40F9         LDR R0, [CFP, #16]
; B9C:       490D4092         AND TMP, R0, #15
; BA0:       3F0D00F1         CMP TMP, #3
; BA4:       211E0054         BNE L23
; BA8:       4A5140F8         LDR R0, [R0, #5]
; BAC:       449145B8         LDR WNL4, [R0, #89]
; BB0:       81FAFF18         LDR WNL1, #x700A997B00
; BB4:       9F00016B         CMP WNL4, WNL1
; BB8:       E01D0054         BEQ L24
; BBC:       449145B8         LDR WNL4, [R0, #89]
; BC0:       21FAFF18         LDR WNL1, #x700A997B04
; BC4:       9F00016B         CMP WNL4, WNL1
; BC8:       011D0054         BNE L23
; BCC:       4A0B40F9         LDR R0, [CFP, #16]
; BD0:       4A5141F8         LDR R0, [R0, #21]
; BD4:       40915FF8         LDR NL0, [R0, #-7]
; BD8:       801E00B4         CBZ NL0, L26
; BDC:       4A1140F8         LDR R0, [R0, #1]
; BE0:       5F7D5FF2         TST R0, #18446744065119617025
; BE4:       011C0054         BNE L22
; BE8:       E6030AAA         MOV NL6, R0
; BEC: L0:   4A0F40F9         LDR R0, [CFP, #24]
; BF0:       490D4092         AND TMP, R0, #15
; BF4:       3F0D00F1         CMP TMP, #3
; BF8:       011B0054         BNE L21
; BFC:       4A5140F8         LDR R0, [R0, #5]
; C00:       449145B8         LDR WNL4, [R0, #89]
; C04:       E1F7FF18         LDR WNL1, #x700A997B00
; C08:       9F00016B         CMP WNL4, WNL1
; C0C:       A1180054         BNE L19
; C10:       4A0F40F9         LDR R0, [CFP, #24]
; C14:       47D141F8         LDR NL7, [R0, #29]
; C18: L1:   4A0B40F9         LDR R0, [CFP, #16]
; C1C:       4E5140F8         LDR R4, [R0, #5]
; C20:       C49145B8         LDR WNL4, [R4, #89]
; C24:       E1F6FF18         LDR WNL1, #x700A997B00
; C28:       9F00016B         CMP WNL4, WNL1
; C2C:       E1160054         BNE L18
; C30:       4A0B40F9         LDR R0, [CFP, #16]
; C34:       4F5141F8         LDR R5, [R0, #21]
; C38: L2:   4A0F40F9         LDR R0, [CFP, #24]
; C3C:       4E5140F8         LDR R4, [R0, #5]
; C40:       C49145B8         LDR WNL4, [R4, #89]
; C44:       E1F5FF18         LDR WNL1, #x700A997B00
; C48:       9F00016B         CMP WNL4, WNL1
; C4C:       21150054         BNE L17
; C50:       4A0F40F9         LDR R0, [CFP, #24]
; C54:       505141F8         LDR R6, [R0, #21]
; C58: L3:   E10306AA         MOV NL1, NL6
; C5C:       EA030FAA         MOV R0, R5
; C60:       EB0310AA         MOV R1, R6
; C64:       FF0006EB         CMP NL7, NL6
; C68:       E00E0054         BEQ L13
; C6C:       FF011DEB         CMP R5, NULL
; C70:       810C0054         BNE L12
; C74: L4:   ED031DAA         MOV R3, NULL
; C78: L5:   DF0007EB         CMP NL6, NL7
; C7C:       AA060054         BGE L9
; C80:       4C2280D2         MOVZ R2, #274
; C84:       8B0080D2         MOVZ R1, #4
; C88:       8A0080D2         MOVZ R0, #4
; C8C:       7EF3FF58         LDR LR, #x700A997AF8            ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; C90:       C0033FD6         BLR LR
; C94:       EB030AAA         MOV R1, R0
; C98:       EE030BAA         MOV R4, R1
; C9C:       EA0306AA         MOV R0, NL6
; CA0:       6A1100F8         STR R0, [R1, #1]
; CA4:       EA0307AA         MOV R0, NL7
; CA8:       6A9100F8         STR R0, [R1, #9]
; CAC:       BF011DEB         CMP R3, NULL
; CB0:       A0030054         BEQ L8
; CB4:       4C2280D2         MOVZ R2, #274
; CB8:       8B0080D2         MOVZ R1, #4
; CBC:       8A0080D2         MOVZ R0, #4
; CC0:       DEF1FF58         LDR LR, #x700A997AF8            ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; CC4:       C0033FD6         BLR LR
; CC8:       EB030AAA         MOV R1, R0
; CCC:       EA030DAA         MOV R0, R3
; CD0:       6A1100F8         STR R0, [R1, #1]
; CD4:       EA030DAA         MOV R0, R3
; CD8:       6A9100F8         STR R0, [R1, #9]
; CDC: L6:   7A0300F9         STR CFP, [CSP]
; CE0:       EA030EAA         MOV R0, R4
; CE4:       F6EEFF58         LDR LEXENV, #x700A997AC0        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CONTEXT-NODE>
; CE8:       970080D2         MOVZ NARGS, #4
; CEC:       FA031BAA         MOV CFP, CSP
; CF0:       DE9240F8         LDR LR, [LEXENV, #9]
; CF4:       C0033FD6         BLR LR
; CF8:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; CFC:       EE030AAA         MOV R4, R0
; D00: L7:   4A1740F9         LDR R0, [CFP, #40]
; D04:       4B3341A9         LDP R1, R2, [CFP, #16]
; D08:       4D1340F9         LDR R3, [CFP, #32]
; D0C:       4E1300F9         STR R4, [CFP, #32]
; D10:       D6EDFF58         LDR LEXENV, #x700A997AC8        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-PUT>
; D14:       570180D2         MOVZ NARGS, #10
; D18:       DE9240F8         LDR LR, [LEXENV, #9]
; D1C:       DE130091         ADD LR, LR, #4
; D20:       C0031FD6         BR LR
; D24: L8:   4C2280D2         MOVZ R2, #274
; D28:       8B0080D2         MOVZ R1, #4
; D2C:       8A0080D2         MOVZ R0, #4
; D30:       5EEEFF58         LDR LR, #x700A997AF8            ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; D34:       C0033FD6         BLR LR
; D38:       EB030AAA         MOV R1, R0
; D3C:       EA030FAA         MOV R0, R5
; D40:       6A1100F8         STR R0, [R1, #1]
; D44:       EA0310AA         MOV R0, R6
; D48:       6A9100F8         STR R0, [R1, #9]
; D4C:       E4FFFF17         B L6
; D50: L9:   4C2280D2         MOVZ R2, #274
; D54:       8B0080D2         MOVZ R1, #4
; D58:       8A0080D2         MOVZ R0, #4
; D5C:       FEECFF58         LDR LR, #x700A997AF8            ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; D60:       C0033FD6         BLR LR
; D64:       EB030AAA         MOV R1, R0
; D68:       EE030BAA         MOV R4, R1
; D6C:       EA0307AA         MOV R0, NL7
; D70:       6A1100F8         STR R0, [R1, #1]
; D74:       EA0306AA         MOV R0, NL6
; D78:       6A9100F8         STR R0, [R1, #9]
; D7C:       BF011DEB         CMP R3, NULL
; D80:       A0020054         BEQ L11
; D84:       4C2280D2         MOVZ R2, #274
; D88:       8B0080D2         MOVZ R1, #4
; D8C:       8A0080D2         MOVZ R0, #4
; D90:       5EEBFF58         LDR LR, #x700A997AF8            ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; D94:       C0033FD6         BLR LR
; D98:       EB030AAA         MOV R1, R0
; D9C:       EA030DAA         MOV R0, R3
; DA0:       6A1100F8         STR R0, [R1, #1]
; DA4:       EA030DAA         MOV R0, R3
; DA8:       6A9100F8         STR R0, [R1, #9]
; DAC: L10:  7A0300F9         STR CFP, [CSP]
; DB0:       EA030EAA         MOV R0, R4
; DB4:       76E8FF58         LDR LEXENV, #x700A997AC0        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CONTEXT-NODE>
; DB8:       970080D2         MOVZ NARGS, #4
; DBC:       FA031BAA         MOV CFP, CSP
; DC0:       DE9240F8         LDR LR, [LEXENV, #9]
; DC4:       C0033FD6         BLR LR
; DC8:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; DCC:       EE030AAA         MOV R4, R0
; DD0:       CCFFFF17         B L7
; DD4: L11:  4C2280D2         MOVZ R2, #274
; DD8:       8B0080D2         MOVZ R1, #4
; DDC:       8A0080D2         MOVZ R0, #4
; DE0:       DEE8FF58         LDR LR, #x700A997AF8            ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; DE4:       C0033FD6         BLR LR
; DE8:       EB030AAA         MOV R1, R0
; DEC:       EA0310AA         MOV R0, R6
; DF0:       6A1100F8         STR R0, [R1, #1]
; DF4:       EA030FAA         MOV R0, R5
; DF8:       6A9100F8         STR R0, [R1, #9]
; DFC:       ECFFFF17         B L10
; E00: L12:  479B04A9         STP NL7, NL6, [CFP, #72]
; E04:       502300F9         STR R6, [CFP, #64]
; E08:       4F1B00F9         STR R5, [CFP, #48]
; E0C:       7A0300F9         STR CFP, [CSP]
; E10:       16E6FF58         LDR LEXENV, #x700A997AD0        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; E14:       970080D2         MOVZ NARGS, #4
; E18:       FA031BAA         MOV CFP, CSP
; E1C:       DE9240F8         LDR LR, [LEXENV, #9]
; E20:       C0033FD6         BLR LR
; E24:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; E28:       4F1B40F9         LDR R5, [CFP, #48]
; E2C:       502340F9         LDR R6, [CFP, #64]
; E30:       479B44A9         LDP NL7, NL6, [CFP, #72]
; E34:       5F011DEB         CMP R0, NULL
; E38:       E0F1FF54         BEQ L4
; E3C:       ED030FAA         MOV R3, R5
; E40:       8EFFFF17         B L5
; E44: L13:  4F0703A9         STP R5, NL1, [CFP, #48]
; E48:       502300F9         STR R6, [CFP, #64]
; E4C:       7A0300F9         STR CFP, [CSP]
; E50:       4C3742A9         LDP R2, R3, [CFP, #32]
; E54:       36E4FF58         LDR LEXENV, #x700A997AD8        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:MERGE-CONTEXTS>
; E58:       170180D2         MOVZ NARGS, #8
; E5C:       FA031BAA         MOV CFP, CSP
; E60:       DE9240F8         LDR LR, [LEXENV, #9]
; E64:       C0033FD6         BLR LR
; E68:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; E6C:       41C343A9         LDP NL1, R6, [CFP, #56]
; E70:       4F1B40F9         LDR R5, [CFP, #48]
; E74:       EB030AAA         MOV R1, R0
; E78:       5F010FEB         CMP R0, R5
; E7C:       C1000054         BNE L15
; E80:       4A0B40F9         LDR R0, [CFP, #16]
; E84: L14:  FB031AAA         MOV CSP, CFP
; E88:       5A7B40A9         LDP CFP, LR, [CFP]
; E8C:       BF0300F1         CMP NULL, #0
; E90:       C0035FD6         RET
; E94: L15:  5F0110EB         CMP R0, R6
; E98:       61000054         BNE L16
; E9C:       4A0F40F9         LDR R0, [CFP, #24]
; EA0:       F9FFFF17         B L14
; EA4: L16:  7A0300F9         STR CFP, [CSP]
; EA8:       EA030BAA         MOV R0, R1
; EAC:       EB0301AA         MOV R1, NL1
; EB0:       96E1FF58         LDR LEXENV, #x700A997AE0        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:SINGLETON-CONTEXT>
; EB4:       970080D2         MOVZ NARGS, #4
; EB8:       FA031BAA         MOV CFP, CSP
; EBC:       DE9240F8         LDR LR, [LEXENV, #9]
; EC0:       C0033FD6         BLR LR
; EC4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; EC8:       EE030AAA         MOV R4, R0
; ECC:       4A1740F9         LDR R0, [CFP, #40]
; ED0:       4B3341A9         LDP R1, R2, [CFP, #16]
; ED4:       4D1340F9         LDR R3, [CFP, #32]
; ED8:       4E1300F9         STR R4, [CFP, #32]
; EDC:       76DFFF58         LDR LEXENV, #x700A997AC8        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-PUT>
; EE0:       570180D2         MOVZ NARGS, #10
; EE4:       DE9240F8         LDR LR, [LEXENV, #9]
; EE8:       DE130091         ADD LR, LR, #4
; EEC:       C0031FD6         BR LR
; EF0: L17:  4A0F40F9         LDR R0, [CFP, #24]
; EF4:       4AD141F8         LDR R0, [R0, #29]
; EF8:       40915FF8         LDR NL0, [R0, #-7]
; EFC:       A00500B4         CBZ NL0, L27
; F00:       501140F8         LDR R6, [R0, #1]
; F04:       55FFFF17         B L3
; F08: L18:  4A0B40F9         LDR R0, [CFP, #16]
; F0C:       4AD141F8         LDR R0, [R0, #29]
; F10:       40915FF8         LDR NL0, [R0, #-7]
; F14:       200500B4         CBZ NL0, L28
; F18:       4F1140F8         LDR R5, [R0, #1]
; F1C:       47FFFF17         B L2
; F20: L19:  449145B8         LDR WNL4, [R0, #89]
; F24:       01DFFF18         LDR WNL1, #x700A997B04
; F28:       9F00016B         CMP WNL4, WNL1
; F2C:       61010054         BNE L21
; F30:       4A0F40F9         LDR R0, [CFP, #24]
; F34:       4A5141F8         LDR R0, [R0, #21]
; F38:       40915FF8         LDR NL0, [R0, #-7]
; F3C:       200400B4         CBZ NL0, L29
; F40:       4A1140F8         LDR R0, [R0, #1]
; F44:       5F7D5FF2         TST R0, #18446744065119617025
; F48:       61000054         BNE L20
; F4C:       E7030AAA         MOV NL7, R0
; F50:       32FFFF17         B L1
; F54: L20:  604D21D4         BRK #2667                       ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; F58: L21:  4A0F40F9         LDR R0, [CFP, #24]
; F5C:       A04321D4         BRK #2589                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; F60:       3F               BYTE #X3F                       ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; F61:       .ALIGN           4
; F64: L22:  604D21D4         BRK #2667                       ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; F68: L23:  4A0B40F9         LDR R0, [CFP, #16]
; F6C:       A04321D4         BRK #2589                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; F70:       3F               BYTE #X3F                       ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; F71:       .ALIGN           4
; F74: L24:  4A0B40F9         LDR R0, [CFP, #16]
; F78:       46D141F8         LDR NL6, [R0, #29]
; F7C:       1CFFFF17         B L0
; F80: L25:  4A1740F9         LDR R0, [CFP, #40]
; F84:       4B3341A9         LDP R1, R2, [CFP, #16]
; F88:       4D1340F9         LDR R3, [CFP, #32]
; F8C:       4E1300F9         STR R4, [CFP, #32]
; F90:       D6D9FF58         LDR LEXENV, #x700A997AC8        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-PUT>
; F94:       570180D2         MOVZ NARGS, #10
; F98:       DE9240F8         LDR LR, [LEXENV, #9]
; F9C:       DE130091         ADD LR, LR, #4
; FA0:       C0031FD6         BR LR
; FA4:       E00120D4         BRK #15                         ; Invalid argument count trap
; FA8: L26:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; FAC:       80808004         BYTE #X80, #X80, #X80, #X04     ; 0
; FB0: L27:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; FB4:       80808004         BYTE #X80, #X80, #X80, #X04     ; 0
; FB8: L28:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; FBC:       80808004         BYTE #X80, #X80, #X80, #X04     ; 0
; FC0: L29:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; FC4:       80808004         BYTE #X80, #X80, #X80, #X04     ; 0
