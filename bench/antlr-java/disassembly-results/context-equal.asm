; disassembly for CNVRS/ANTLR-RUNTIME:CONTEXT-EQUAL
; Size: 984 bytes. Origin: #x700CE00EF0                       ; CNVRS/ANTLR-RUNTIME:CONTEXT-EQUAL
; 0EF0:       1F0211EB         CMP R6, R7
; 0EF4:       C1000054         BNE L1
; 0EF8:       AAE30091         ADD R0, NULL, #56              ; T
; 0EFC: L0:   FB031AAA         MOV CSP, CFP
; 0F00:       5A7B40A9         LDP CFP, LR, [CFP]
; 0F04:       BF0300F1         CMP NULL, #0
; 0F08:       C0035FD6         RET
; 0F0C: L1:   1F021DEB         CMP R6, NULL
; 0F10:       61000054         BNE L3
; 0F14: L2:   EA031DAA         MOV R0, NULL
; 0F18:       F9FFFF17         B L0
; 0F1C: L3:   3F021DEB         CMP R7, NULL
; 0F20:       A0FFFF54         BEQ L2
; 0F24:       010E4092         AND NL1, R6, #15
; 0F28:       3F0C00F1         CMP NL1, #3
; 0F2C:       811B0054         BNE L31
; 0F30:       0E5240F8         LDR R4, [R6, #5]
; 0F34:       C25145B8         LDR WNL2, [R4, #85]
; 0F38:       81FBFF18         LDR WNL1, #x700CE00EA8
; 0F3C:       5F00016B         CMP WNL2, WNL1
; 0F40:       E11A0054         BNE L31
; 0F44:       03D240F8         LDR NL3, [R6, #13]
; 0F48:       210E4092         AND NL1, R7, #15
; 0F4C:       3F0C00F1         CMP NL1, #3
; 0F50:       211A0054         BNE L30
; 0F54:       2E5240F8         LDR R4, [R7, #5]
; 0F58:       C25145B8         LDR WNL2, [R4, #85]
; 0F5C:       61FAFF18         LDR WNL1, #x700CE00EA8
; 0F60:       5F00016B         CMP WNL2, WNL1
; 0F64:       81190054         BNE L30
; 0F68:       20D240F8         LDR NL0, [R7, #13]
; 0F6C:       1F0003EB         CMP NL0, NL3
; 0F70:       21FDFF54         BNE L2
; 0F74:       0A5240F8         LDR R0, [R6, #5]
; 0F78:       429145B8         LDR WNL2, [R0, #89]
; 0F7C:       81F9FF18         LDR WNL1, #x700CE00EAC
; 0F80:       5F00016B         CMP WNL2, WNL1
; 0F84:       40180054         BEQ L29
; 0F88:       429145B8         LDR WNL2, [R0, #89]
; 0F8C:       21F9FF18         LDR WNL1, #x700CE00EB0
; 0F90:       5F00016B         CMP WNL2, WNL1
; 0F94:       81170054         BNE L28
; 0F98:       0A5241F8         LDR R0, [R6, #21]
; 0F9C:       43915FF8         LDR NL3, [R0, #-7]
; 0FA0: L4:   2A5240F8         LDR R0, [R7, #5]
; 0FA4:       429145B8         LDR WNL2, [R0, #89]
; 0FA8:       21F8FF18         LDR WNL1, #x700CE00EAC
; 0FAC:       5F00016B         CMP WNL2, WNL1
; 0FB0:       81150054         BNE L26
; 0FB4:       400080D2         MOVZ NL0, #2
; 0FB8: L5:   1F0003EB         CMP NL0, NL3
; 0FBC:       C1FAFF54         BNE L2
; 0FC0:       0E5240F8         LDR R4, [R6, #5]
; 0FC4:       C29145B8         LDR WNL2, [R4, #89]
; 0FC8:       21F7FF18         LDR WNL1, #x700CE00EAC
; 0FCC:       5F00016B         CMP WNL2, WNL1
; 0FD0:       01140054         BNE L25
; 0FD4:       400080D2         MOVZ NL0, #2
; 0FD8:       400B00F9         STR NL0, [CFP, #16]
; 0FDC: L6:   050080D2         MOVZ NL5, #0
; 0FE0:       62000014         B L16
; 0FE4: L7:   E30305AA         MOV NL3, NL5
; 0FE8:       0E5240F8         LDR R4, [R6, #5]
; 0FEC:       C29145B8         LDR WNL2, [R4, #89]
; 0FF0:       E1F5FF18         LDR WNL1, #x700CE00EAC
; 0FF4:       5F00016B         CMP WNL2, WNL1
; 0FF8:       60120054         BEQ L24
; 0FFC:       0A5241F8         LDR R0, [R6, #21]
; 1000:       40915FF8         LDR NL0, [R0, #-7]
; 1004:       1F0005EB         CMP NL0, NL5
; 1008:       09150054         BLS L32
; 100C:       4909058B         ADD TMP, R0, NL5, LSL #2
; 1010:       2A1140F8         LDR R0, [TMP, #1]
; 1014:       5F7D5FF2         TST R0, #18446744065119617025
; 1018:       810F0054         BNE L22
; 101C:       E4030AAA         MOV NL4, R0
; 1020: L8:   E30305AA         MOV NL3, NL5
; 1024:       2E5240F8         LDR R4, [R7, #5]
; 1028:       C29145B8         LDR WNL2, [R4, #89]
; 102C:       01F4FF18         LDR WNL1, #x700CE00EAC
; 1030:       5F00016B         CMP WNL2, WNL1
; 1034:       810D0054         BNE L21
; 1038:       13000014         B L10
; 103C: L9:   430F00F9         STR NL3, [CFP, #24]
; 1040:       511B00F9         STR R7, [CFP, #48]
; 1044:       501702A9         STP R6, NL5, [CFP, #32]
; 1048:       441F00F9         STR NL4, [CFP, #56]
; 104C:       7A0300F9         STR CFP, [CSP]
; 1050:       4AF1FF58         LDR R0, #x700CE00E78           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 1054:       4B0080D2         MOVZ R1, #2
; 1058:       4CF1FF58         LDR R2, #x700CE00E80           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 105C:       ED0303AA         MOV R3, NL3
; 1060:       96F0FF58         LDR LEXENV, #x700CE00E70       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 1064:       170180D2         MOVZ NARGS, #8
; 1068:       FA031BAA         MOV CFP, CSP
; 106C:       DE9240F8         LDR LR, [LEXENV, #9]
; 1070:       C0033FD6         BLR LR
; 1074:       441F40F9         LDR NL4, [CFP, #56]
; 1078:       501742A9         LDP R6, NL5, [CFP, #32]
; 107C:       511B40F9         LDR R7, [CFP, #48]
; 1080:       430F40F9         LDR NL3, [CFP, #24]
; 1084: L10:  C3FDFFB5         CBNZ NL3, L9
; 1088:       2AD241F8         LDR R0, [R7, #29]
; 108C: L11:  5F0104EB         CMP R0, NL4
; 1090:       61070054         BNE L17
; 1094:       E30305AA         MOV NL3, NL5
; 1098:       0E5240F8         LDR R4, [R6, #5]
; 109C:       C29145B8         LDR WNL2, [R4, #89]
; 10A0:       61F0FF18         LDR WNL1, #x700CE00EAC
; 10A4:       5F00016B         CMP WNL2, WNL1
; 10A8:       80090054         BEQ L20
; 10AC:       0AD241F8         LDR R0, [R6, #29]
; 10B0:       40915FF8         LDR NL0, [R0, #-7]
; 10B4:       1F0005EB         CMP NL0, NL5
; 10B8:       C90F0054         BLS L33
; 10BC:       4909058B         ADD TMP, R0, NL5, LSL #2
; 10C0:       2F1140F8         LDR R5, [TMP, #1]
; 10C4: L12:  E30305AA         MOV NL3, NL5
; 10C8:       2E5240F8         LDR R4, [R7, #5]
; 10CC:       C29145B8         LDR WNL2, [R4, #89]
; 10D0:       E1EEFF18         LDR WNL1, #x700CE00EAC
; 10D4:       5F00016B         CMP WNL2, WNL1
; 10D8:       61050054         BNE L18
; 10DC:       13000014         B L14
; 10E0: L13:  430F00F9         STR NL3, [CFP, #24]
; 10E4:       45C702A9         STP NL5, R7, [CFP, #40]
; 10E8:       4F1F00F9         STR R5, [CFP, #56]
; 10EC:       501300F9         STR R6, [CFP, #32]
; 10F0:       7A0300F9         STR CFP, [CSP]
; 10F4:       2AECFF58         LDR R0, #x700CE00E78           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 10F8:       4B0080D2         MOVZ R1, #2
; 10FC:       2CECFF58         LDR R2, #x700CE00E80           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 1100:       ED0303AA         MOV R3, NL3
; 1104:       76EBFF58         LDR LEXENV, #x700CE00E70       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 1108:       170180D2         MOVZ NARGS, #8
; 110C:       FA031BAA         MOV CFP, CSP
; 1110:       DE9240F8         LDR LR, [LEXENV, #9]
; 1114:       C0033FD6         BLR LR
; 1118:       501340F9         LDR R6, [CFP, #32]
; 111C:       4F1F40F9         LDR R5, [CFP, #56]
; 1120:       45C742A9         LDP NL5, R7, [CFP, #40]
; 1124:       430F40F9         LDR NL3, [CFP, #24]
; 1128: L14:  C3FDFFB5         CBNZ NL3, L13
; 112C:       2A5241F8         LDR R0, [R7, #21]
; 1130: L15:  45C702A9         STP NL5, R7, [CFP, #40]
; 1134:       501300F9         STR R6, [CFP, #32]
; 1138:       E0031BAA         MOV NL0, CSP
; 113C:       7A0704F8         STR CFP, [CSP], #64
; 1140:       F0030FAA         MOV R6, R5
; 1144:       F1030AAA         MOV R7, R0
; 1148:       FA0300AA         MOV CFP, NL0
; 114C:       68FFFF97         BL #x700CE00EEC
; 1150:       501340F9         LDR R6, [CFP, #32]
; 1154:       45C742A9         LDP NL5, R7, [CFP, #40]
; 1158:       5F011DEB         CMP R0, NULL
; 115C:       00010054         BEQ L17
; 1160:       A0080091         ADD NL0, NL5, #2
; 1164:       E50300AA         MOV NL5, NL0
; 1168: L16:  400B40F9         LDR NL0, [CFP, #16]
; 116C:       BF0000EB         CMP NL5, NL0
; 1170:       ABF3FF54         BLT L7
; 1174:       AAE30091         ADD R0, NULL, #56              ; T
; 1178:       61FFFF17         B L0
; 117C: L17:  EA031DAA         MOV R0, NULL
; 1180:       5FFFFF17         B L0
; 1184: L18:  2AD241F8         LDR R0, [R7, #29]
; 1188:       40915FF8         LDR NL0, [R0, #-7]
; 118C:       1F0005EB         CMP NL0, NL5
; 1190:       49090054         BLS L34
; 1194:       4909058B         ADD TMP, R0, NL5, LSL #2
; 1198:       2A1140F8         LDR R0, [TMP, #1]
; 119C:       E5FFFF17         B L15
; 11A0: L19:  43C301A9         STP NL3, R6, [CFP, #24]
; 11A4:       45C702A9         STP NL5, R7, [CFP, #40]
; 11A8:       7A0300F9         STR CFP, [CSP]
; 11AC:       6AE6FF58         LDR R0, #x700CE00E78           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 11B0:       4B0080D2         MOVZ R1, #2
; 11B4:       6CE6FF58         LDR R2, #x700CE00E80           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 11B8:       ED0303AA         MOV R3, NL3
; 11BC:       B6E5FF58         LDR LEXENV, #x700CE00E70       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 11C0:       170180D2         MOVZ NARGS, #8
; 11C4:       FA031BAA         MOV CFP, CSP
; 11C8:       DE9240F8         LDR LR, [LEXENV, #9]
; 11CC:       C0033FD6         BLR LR
; 11D0:       45C742A9         LDP NL5, R7, [CFP, #40]
; 11D4:       43C341A9         LDP NL3, R6, [CFP, #24]
; 11D8: L20:  43FEFFB5         CBNZ NL3, L19
; 11DC:       0F5241F8         LDR R5, [R6, #21]
; 11E0:       B9FFFF17         B L12
; 11E4: L21:  2A5241F8         LDR R0, [R7, #21]
; 11E8:       40915FF8         LDR NL0, [R0, #-7]
; 11EC:       1F0005EB         CMP NL0, NL5
; 11F0:       89060054         BLS L35
; 11F4:       4909058B         ADD TMP, R0, NL5, LSL #2
; 11F8:       2A1140F8         LDR R0, [TMP, #1]
; 11FC:       5F7D5FF2         TST R0, #18446744065119617025
; 1200:       60F4FF54         BEQ L11
; 1204:       604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 1208: L22:  604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 120C: L23:  43C301A9         STP NL3, R6, [CFP, #24]
; 1210:       45C702A9         STP NL5, R7, [CFP, #40]
; 1214:       7A0300F9         STR CFP, [CSP]
; 1218:       0AE3FF58         LDR R0, #x700CE00E78           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 121C:       4B0080D2         MOVZ R1, #2
; 1220:       0CE3FF58         LDR R2, #x700CE00E80           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 1224:       ED0303AA         MOV R3, NL3
; 1228:       56E2FF58         LDR LEXENV, #x700CE00E70       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 122C:       170180D2         MOVZ NARGS, #8
; 1230:       FA031BAA         MOV CFP, CSP
; 1234:       DE9240F8         LDR LR, [LEXENV, #9]
; 1238:       C0033FD6         BLR LR
; 123C:       45C742A9         LDP NL5, R7, [CFP, #40]
; 1240:       43C341A9         LDP NL3, R6, [CFP, #24]
; 1244: L24:  43FEFFB5         CBNZ NL3, L23
; 1248:       04D241F8         LDR NL4, [R6, #29]
; 124C:       75FFFF17         B L8
; 1250: L25:  0A5241F8         LDR R0, [R6, #21]
; 1254:       40915FF8         LDR NL0, [R0, #-7]
; 1258:       400B00F9         STR NL0, [CFP, #16]
; 125C:       60FFFF17         B L6
; 1260: L26:  429145B8         LDR WNL2, [R0, #89]
; 1264:       61E2FF18         LDR WNL1, #x700CE00EB0
; 1268:       5F00016B         CMP WNL2, WNL1
; 126C:       81000054         BNE L27
; 1270:       2A5241F8         LDR R0, [R7, #21]
; 1274:       40915FF8         LDR NL0, [R0, #-7]
; 1278:       50FFFF17         B L5
; 127C: L27:  A02322D4         BRK #4381                      ; ETYPECASE-FAILURE-ERROR
                                                              ; R7
; 1280:       2F               BYTE #X2F                      ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 1281:       .ALIGN           4
; 1284: L28:  A00322D4         BRK #4125                      ; ETYPECASE-FAILURE-ERROR
                                                              ; R6
; 1288:       2F               BYTE #X2F                      ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 1289:       .ALIGN           4
; 128C: L29:  430080D2         MOVZ NL3, #2
; 1290:       44FFFF17         B L4
; 1294: L30:  602322D4         BRK #4379                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R7
; 1298:       33               BYTE #X33                      ; #<SB-KERNEL:LAYOUT (ID=389) for CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT {700CD54203}>
; 1299:       .ALIGN           4
; 129C: L31:  600322D4         BRK #4123                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R6
; 12A0:       33               BYTE #X33                      ; #<SB-KERNEL:LAYOUT (ID=389) for CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT {700CD54203}>
; 12A1:       .ALIGN           4
; 12A4:       E00120D4         BRK #15                        ; Invalid argument count trap
; 12A8: L32:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 12AC:       15               BYTE #X15                      ; NL5
; 12AD:       .ALIGN           4
; 12B0: L33:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 12B4:       15               BYTE #X15                      ; NL5
; 12B5:       .ALIGN           4
; 12B8: L34:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 12BC:       15               BYTE #X15                      ; NL5
; 12BD:       .ALIGN           4
; 12C0: L35:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 12C4:       15               BYTE #X15                      ; NL5
; 12C5:       .ALIGN           4
