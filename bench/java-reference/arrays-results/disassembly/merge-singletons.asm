; disassembly for CNVRS/RUNTIME::MERGE-SINGLETONS
; Size: 1092 bytes. Origin: #x700D72CCB8                      ; CNVRS/RUNTIME::MERGE-SINGLETONS
; CCB8:       7A0300F9         STR CFP, [CSP]
; CCBC:       4A1B40F9         LDR R0, [CFP, #48]
; CCC0:       4BB341A9         LDP R1, R2, [CFP, #24]
; CCC4:       4D1740F9         LDR R3, [CFP, #40]
; CCC8:       D6F6FF58         LDR LEXENV, #x700D72CBA0       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-GET>
; CCCC:       170180D2         MOVZ NARGS, #8
; CCD0:       FA031BAA         MOV CFP, CSP
; CCD4:       DE9240F8         LDR LR, [LEXENV, #9]
; CCD8:       C0033FD6         BLR LR
; CCDC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; CCE0:       5F011DEB         CMP R0, NULL
; CCE4:       41170054         BNE L12
; CCE8:       7A0300F9         STR CFP, [CSP]
; CCEC:       4AAF41A9         LDP R0, R1, [CFP, #24]
; CCF0:       4C1740F9         LDR R2, [CFP, #40]
; CCF4:       B6F5FF58         LDR LEXENV, #x700D72CBA8       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-ROOT>
; CCF8:       D70080D2         MOVZ NARGS, #6
; CCFC:       FA031BAA         MOV CFP, CSP
; CD00:       DE9240F8         LDR LR, [LEXENV, #9]
; CD04:       C0033FD6         BLR LR
; CD08:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; CD0C:       EE030AAA         MOV R4, R0
; CD10:       DF011DEB         CMP R4, NULL
; CD14:       011D0054         BNE L19
; CD18:       4A0F40F9         LDR R0, [CFP, #24]
; CD1C:       4A5140F8         LDR R0, [R0, #5]
; CD20:       449145B8         LDR WNL4, [R0, #89]
; CD24:       01F7FF18         LDR WNL1, #x700D72CC04
; CD28:       9F00016B         CMP WNL4, WNL1
; CD2C:       A1190054         BNE L17
; CD30:       4A0F40F9         LDR R0, [CFP, #24]
; CD34:       40D141F8         LDR NL0, [R0, #29]
; CD38:       4A0F40F9         LDR R0, [CFP, #24]
; CD3C:       4A5141F8         LDR R0, [R0, #21]
; CD40:       E60300AA         MOV NL6, NL0
; CD44:       EF030AAA         MOV R5, R0
; CD48: L0:   E20306AA         MOV NL2, NL6
; CD4C:       EC030FAA         MOV R2, R5
; CD50:       4A1340F9         LDR R0, [CFP, #32]
; CD54:       4A5140F8         LDR R0, [R0, #5]
; CD58:       449145B8         LDR WNL4, [R0, #89]
; CD5C:       41F5FF18         LDR WNL1, #x700D72CC04
; CD60:       9F00016B         CMP WNL4, WNL1
; CD64:       00170054         BEQ L16
; CD68:       449145B8         LDR WNL4, [R0, #89]
; CD6C:       E1F4FF18         LDR WNL1, #x700D72CC08
; CD70:       9F00016B         CMP WNL4, WNL1
; CD74:       21160054         BNE L15
; CD78:       4A1340F9         LDR R0, [CFP, #32]
; CD7C:       4A5141F8         LDR R0, [R0, #21]
; CD80:       40915FF8         LDR NL0, [R0, #-7]
; CD84:       C01A00B4         CBZ NL0, L20
; CD88:       401140B8         LDR WNL0, [R0, #1]
; CD8C:       01F87FD3         LSL NL1, NL0, #1
; CD90:       4A1340F9         LDR R0, [CFP, #32]
; CD94:       4AD141F8         LDR R0, [R0, #29]
; CD98:       40915FF8         LDR NL0, [R0, #-7]
; CD9C:       401A00B4         CBZ NL0, L21
; CDA0:       4A1140F8         LDR R0, [R0, #1]
; CDA4:       F0030AAA         MOV R6, R0
; CDA8: L1:   EB0310AA         MOV R1, R6
; CDAC:       3F0006EB         CMP NL1, NL6
; CDB0:       C00E0054         BEQ L11
; CDB4:       FF011DEB         CMP R5, NULL
; CDB8:       410C0054         BNE L10
; CDBC: L2:   ED031DAA         MOV R3, NULL
; CDC0: L3:   DF0001EB         CMP NL6, NL1
; CDC4:       8A060054         BGE L7
; CDC8:       4C2B80D2         MOVZ R2, #346
; CDCC:       8B0080D2         MOVZ R1, #4
; CDD0:       4A0080D2         MOVZ R0, #2
; CDD4:       3EF1FF58         LDR LR, #x700D72CBF8           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; CDD8:       C0033FD6         BLR LR
; CDDC:       EE030AAA         MOV R4, R0
; CDE0:       C0FC4193         ASR NL0, NL6, #1
; CDE4:       401100B8         STR WNL0, [R0, #1]
; CDE8:       20FC4193         ASR NL0, NL1, #1
; CDEC:       405100B8         STR WNL0, [R0, #5]
; CDF0:       BF011DEB         CMP R3, NULL
; CDF4:       A1030054         BNE L6
; CDF8:       4C2280D2         MOVZ R2, #274
; CDFC:       8B0080D2         MOVZ R1, #4
; CE00:       8A0080D2         MOVZ R0, #4
; CE04:       BEEFFF58         LDR LR, #x700D72CBF8           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; CE08:       C0033FD6         BLR LR
; CE0C:       EB030AAA         MOV R1, R0
; CE10:       EA030FAA         MOV R0, R5
; CE14:       6A1100F8         STR R0, [R1, #1]
; CE18:       EA0310AA         MOV R0, R6
; CE1C:       6A9100F8         STR R0, [R1, #9]
; CE20: L4:   7A0300F9         STR CFP, [CSP]
; CE24:       EA030EAA         MOV R0, R4
; CE28:       56ECFF58         LDR LEXENV, #x700D72CBB0       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CONTEXT-NODE>
; CE2C:       970080D2         MOVZ NARGS, #4
; CE30:       FA031BAA         MOV CFP, CSP
; CE34:       DE9240F8         LDR LR, [LEXENV, #9]
; CE38:       C0033FD6         BLR LR
; CE3C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; CE40:       EE030AAA         MOV R4, R0
; CE44: L5:   4A1B40F9         LDR R0, [CFP, #48]
; CE48:       4BB341A9         LDP R1, R2, [CFP, #24]
; CE4C:       4D1740F9         LDR R3, [CFP, #40]
; CE50:       4E1300F9         STR R4, [CFP, #32]
; CE54:       36EBFF58         LDR LEXENV, #x700D72CBB8       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-PUT>
; CE58:       570180D2         MOVZ NARGS, #10
; CE5C:       DE9240F8         LDR LR, [LEXENV, #9]
; CE60:       DE130091         ADD LR, LR, #4
; CE64:       C0031FD6         BR LR
; CE68: L6:   4C2280D2         MOVZ R2, #274
; CE6C:       8B0080D2         MOVZ R1, #4
; CE70:       8A0080D2         MOVZ R0, #4
; CE74:       3EECFF58         LDR LR, #x700D72CBF8           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; CE78:       C0033FD6         BLR LR
; CE7C:       EB030AAA         MOV R1, R0
; CE80:       EA030DAA         MOV R0, R3
; CE84:       6A1100F8         STR R0, [R1, #1]
; CE88:       EA030DAA         MOV R0, R3
; CE8C:       6A9100F8         STR R0, [R1, #9]
; CE90:       E4FFFF17         B L4
; CE94: L7:   4C2B80D2         MOVZ R2, #346
; CE98:       8B0080D2         MOVZ R1, #4
; CE9C:       4A0080D2         MOVZ R0, #2
; CEA0:       DEEAFF58         LDR LR, #x700D72CBF8           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; CEA4:       C0033FD6         BLR LR
; CEA8:       EE030AAA         MOV R4, R0
; CEAC:       20FC4193         ASR NL0, NL1, #1
; CEB0:       401100B8         STR WNL0, [R0, #1]
; CEB4:       C0FC4193         ASR NL0, NL6, #1
; CEB8:       405100B8         STR WNL0, [R0, #5]
; CEBC:       BF011DEB         CMP R3, NULL
; CEC0:       A1020054         BNE L9
; CEC4:       4C2280D2         MOVZ R2, #274
; CEC8:       8B0080D2         MOVZ R1, #4
; CECC:       8A0080D2         MOVZ R0, #4
; CED0:       5EE9FF58         LDR LR, #x700D72CBF8           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; CED4:       C0033FD6         BLR LR
; CED8:       EB030AAA         MOV R1, R0
; CEDC:       EA0310AA         MOV R0, R6
; CEE0:       6A1100F8         STR R0, [R1, #1]
; CEE4:       EA030FAA         MOV R0, R5
; CEE8:       6A9100F8         STR R0, [R1, #9]
; CEEC: L8:   7A0300F9         STR CFP, [CSP]
; CEF0:       EA030EAA         MOV R0, R4
; CEF4:       F6E5FF58         LDR LEXENV, #x700D72CBB0       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CONTEXT-NODE>
; CEF8:       970080D2         MOVZ NARGS, #4
; CEFC:       FA031BAA         MOV CFP, CSP
; CF00:       DE9240F8         LDR LR, [LEXENV, #9]
; CF04:       C0033FD6         BLR LR
; CF08:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; CF0C:       EE030AAA         MOV R4, R0
; CF10:       CDFFFF17         B L5
; CF14: L9:   4C2280D2         MOVZ R2, #274
; CF18:       8B0080D2         MOVZ R1, #4
; CF1C:       8A0080D2         MOVZ R0, #4
; CF20:       DEE6FF58         LDR LR, #x700D72CBF8           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; CF24:       C0033FD6         BLR LR
; CF28:       EB030AAA         MOV R1, R0
; CF2C:       EA030DAA         MOV R0, R3
; CF30:       6A1100F8         STR R0, [R1, #1]
; CF34:       EA030DAA         MOV R0, R3
; CF38:       6A9100F8         STR R0, [R1, #9]
; CF3C:       ECFFFF17         B L8
; CF40: L10:  411B05A9         STP NL1, NL6, [CFP, #80]
; CF44:       502700F9         STR R6, [CFP, #72]
; CF48:       4F1F00F9         STR R5, [CFP, #56]
; CF4C:       7A0300F9         STR CFP, [CSP]
; CF50:       EA030CAA         MOV R0, R2
; CF54:       76E3FF58         LDR LEXENV, #x700D72CBC0       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; CF58:       970080D2         MOVZ NARGS, #4
; CF5C:       FA031BAA         MOV CFP, CSP
; CF60:       DE9240F8         LDR LR, [LEXENV, #9]
; CF64:       C0033FD6         BLR LR
; CF68:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; CF6C:       4F1F40F9         LDR R5, [CFP, #56]
; CF70:       502740F9         LDR R6, [CFP, #72]
; CF74:       411B45A9         LDP NL1, NL6, [CFP, #80]
; CF78:       5F011DEB         CMP R0, NULL
; CF7C:       00F2FF54         BEQ L2
; CF80:       ED030FAA         MOV R3, R5
; CF84:       8FFFFF17         B L3
; CF88: L11:  4F8B03A9         STP R5, NL2, [CFP, #56]
; CF8C:       502700F9         STR R6, [CFP, #72]
; CF90:       7A0300F9         STR CFP, [CSP]
; CF94:       EA030CAA         MOV R0, R2
; CF98:       4CB742A9         LDP R2, R3, [CFP, #40]
; CF9C:       76E1FF58         LDR LEXENV, #x700D72CBC8       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:MERGE-CONTEXTS>
; CFA0:       170180D2         MOVZ NARGS, #8
; CFA4:       FA031BAA         MOV CFP, CSP
; CFA8:       DE9240F8         LDR LR, [LEXENV, #9]
; CFAC:       C0033FD6         BLR LR
; CFB0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; CFB4:       424344A9         LDP NL2, R6, [CFP, #64]
; CFB8:       4F1F40F9         LDR R5, [CFP, #56]
; CFBC:       EB030AAA         MOV R1, R0
; CFC0:       5F010FEB         CMP R0, R5
; CFC4:       C1000054         BNE L13
; CFC8:       4A0F40F9         LDR R0, [CFP, #24]
; CFCC: L12:  FB031AAA         MOV CSP, CFP
; CFD0:       5A7B40A9         LDP CFP, LR, [CFP]
; CFD4:       BF0300F1         CMP NULL, #0
; CFD8:       C0035FD6         RET
; CFDC: L13:  5F0110EB         CMP R0, R6
; CFE0:       61000054         BNE L14
; CFE4:       4A1340F9         LDR R0, [CFP, #32]
; CFE8:       F9FFFF17         B L12
; CFEC: L14:  7A0300F9         STR CFP, [CSP]
; CFF0:       EA030BAA         MOV R0, R1
; CFF4:       EB0302AA         MOV R1, NL2
; CFF8:       D6DEFF58         LDR LEXENV, #x700D72CBD0       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:SINGLETON-CONTEXT>
; CFFC:       970080D2         MOVZ NARGS, #4
; D000:       FA031BAA         MOV CFP, CSP
; D004:       DE9240F8         LDR LR, [LEXENV, #9]
; D008:       C0033FD6         BLR LR
; D00C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; D010:       EE030AAA         MOV R4, R0
; D014:       4A1B40F9         LDR R0, [CFP, #48]
; D018:       4BB341A9         LDP R1, R2, [CFP, #24]
; D01C:       4D1740F9         LDR R3, [CFP, #40]
; D020:       4E1300F9         STR R4, [CFP, #32]
; D024:       B6DCFF58         LDR LEXENV, #x700D72CBB8       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-PUT>
; D028:       570180D2         MOVZ NARGS, #10
; D02C:       DE9240F8         LDR LR, [LEXENV, #9]
; D030:       DE130091         ADD LR, LR, #4
; D034:       C0031FD6         BR LR
; D038: L15:  4A1340F9         LDR R0, [CFP, #32]
; D03C:       A04321D4         BRK #2589                      ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; D040:       47               BYTE #X47                      ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; D041:       .ALIGN           4
; D044: L16:  4A1340F9         LDR R0, [CFP, #32]
; D048:       40D141F8         LDR NL0, [R0, #29]
; D04C:       4A1340F9         LDR R0, [CFP, #32]
; D050:       4A5141F8         LDR R0, [R0, #21]
; D054:       E10300AA         MOV NL1, NL0
; D058:       F0030AAA         MOV R6, R0
; D05C:       53FFFF17         B L1
; D060: L17:  449145B8         LDR WNL4, [R0, #89]
; D064:       21DDFF18         LDR WNL1, #x700D72CC08
; D068:       9F00016B         CMP WNL4, WNL1
; D06C:       E1010054         BNE L18
; D070:       4A0F40F9         LDR R0, [CFP, #24]
; D074:       4A5141F8         LDR R0, [R0, #21]
; D078:       40915FF8         LDR NL0, [R0, #-7]
; D07C:       800300B4         CBZ NL0, L22
; D080:       401140B8         LDR WNL0, [R0, #1]
; D084:       01F87FD3         LSL NL1, NL0, #1
; D088:       4A0F40F9         LDR R0, [CFP, #24]
; D08C:       4AD141F8         LDR R0, [R0, #29]
; D090:       40915FF8         LDR NL0, [R0, #-7]
; D094:       000300B4         CBZ NL0, L23
; D098:       4A1140F8         LDR R0, [R0, #1]
; D09C:       E60301AA         MOV NL6, NL1
; D0A0:       EF030AAA         MOV R5, R0
; D0A4:       29FFFF17         B L0
; D0A8: L18:  4A0F40F9         LDR R0, [CFP, #24]
; D0AC:       A04321D4         BRK #2589                      ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; D0B0:       47               BYTE #X47                      ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; D0B1:       .ALIGN           4
; D0B4: L19:  4A1B40F9         LDR R0, [CFP, #48]
; D0B8:       4BB341A9         LDP R1, R2, [CFP, #24]
; D0BC:       4D1740F9         LDR R3, [CFP, #40]
; D0C0:       4E1300F9         STR R4, [CFP, #32]
; D0C4:       B6D7FF58         LDR LEXENV, #x700D72CBB8       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-PUT>
; D0C8:       570180D2         MOVZ NARGS, #10
; D0CC:       DE9240F8         LDR LR, [LEXENV, #9]
; D0D0:       DE130091         ADD LR, LR, #4
; D0D4:       C0031FD6         BR LR
; D0D8:       E00120D4         BRK #15                        ; Invalid argument count trap
; D0DC: L20:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; D0E0:       80808004         BYTE #X80, #X80, #X80, #X04    ; 0
; D0E4: L21:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; D0E8:       80808004         BYTE #X80, #X80, #X80, #X04    ; 0
; D0EC: L22:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; D0F0:       80808004         BYTE #X80, #X80, #X80, #X04    ; 0
; D0F4: L23:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; D0F8:       80808004         BYTE #X80, #X80, #X80, #X04    ; 0
