; disassembly for DIAGNOSTIC-CONTROL-DERIVE-CONFIG
; Size: 340 bytes. Origin: #x70055B3168                       ; DIAGNOSTIC-CONTROL-DERIVE-CONFIG
; 168:       8D0800B4         CBZ R3, L9
; 16C:       EB0310AA         MOV R1, R6
; 170: L0:   4E0100B5         CBNZ R4, L1
; 174:       C10E4092         AND NL1, LEXENV, #15
; 178:       3F0C00F1         CMP NL1, #3
; 17C:       A1070054         BNE L8
; 180:       CC5240F8         LDR R2, [LEXENV, #5]
; 184:       825145B8         LDR WNL2, [R2, #85]
; 188:       41F6FF18         LDR WNL1, #x70055B3050
; 18C:       5F00016B         CMP WNL2, WNL1
; 190:       01070054         BNE L8
; 194:       D15242F8         LDR R7, [LEXENV, #37]
; 198: L1:   C10E4092         AND NL1, LEXENV, #15
; 19C:       3F0C00F1         CMP NL1, #3
; 1A0:       41060054         BNE L7
; 1A4:       CC5240F8         LDR R2, [LEXENV, #5]
; 1A8:       825145B8         LDR WNL2, [R2, #85]
; 1AC:       21F5FF18         LDR WNL1, #x70055B3050
; 1B0:       5F00016B         CMP WNL2, WNL1
; 1B4:       A1050054         BNE L7
; 1B8:       C05241F8         LDR NL0, [LEXENV, #21]
; 1BC:       C3D242F8         LDR NL3, [LEXENV, #45]
; 1C0:       CE5243F8         LDR R4, [LEXENV, #53]
; 1C4:       0A050037         TBNZ WR0, #0, L6
; 1C8:       ED030AAA         MOV R3, R0
; 1CC:       7F011DEB         CMP R1, NULL
; 1D0:       60010054         BEQ L3
; 1D4:       610D4092         AND NL1, R1, #15
; 1D8:       3F0C00F1         CMP NL1, #3
; 1DC:       C1000054         BNE L2
; 1E0:       6C5140F8         LDR R2, [R1, #5]
; 1E4:       825145B8         LDR WNL2, [R2, #85]
; 1E8:       61F3FF18         LDR WNL1, #x70055B3054
; 1EC:       5F00016B         CMP WNL2, WNL1
; 1F0:       60000054         BEQ L3
; 1F4: L2:   606321D4         BRK #2843                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R1
; 1F8:       2F               BYTE #X2F                       ; '(OR NULL
                                                              ;      PREDICTION-CONTEXT)
; 1F9:       .ALIGN           4
; 1FC: L3:   BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 200:       A97A47A9         LDP TMP, LR, [THREAD, #112]     ; mixed-tlab.{free-pointer, end-addr}
; 204:       2A010191         ADD R0, TMP, #64
; 208:       5F011EEB         CMP R0, LR
; 20C:       08050054         BHI L11
; 210:       AA3A00F9         STR R0, [THREAD, #112]          ; mixed-tlab
; 214: L4:   2A0D0091         ADD R0, TMP, #3
; 218:       3E8783D2         MOVZ LR, #7225
; 21C:       5ED11FF8         STR LR, [R0, #-3]
; 220:       BF3A03D5         DMB ISHST
; 224:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 228:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 22C:       5E0000B4         CBZ LR, L5
; 230:       200120D4         BRK #9                          ; Pending interrupt trap
; 234: L5:   ECEFFF58         LDR R2, #x70055B3030            ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 238:       4C5100F8         STR R2, [R0, #5]
; 23C:       4DD100F8         STR R3, [R0, #13]
; 240:       405101F8         STR NL0, [R0, #21]
; 244:       4BD101F8         STR R1, [R0, #29]
; 248:       515102F8         STR R7, [R0, #37]
; 24C:       43D102F8         STR NL3, [R0, #45]
; 250:       4E5103F8         STR R4, [R0, #53]
; 254:       FB031AAA         MOV CSP, CFP
; 258:       5A7B40A9         LDP CFP, LR, [CFP]
; 25C:       BF0300F1         CMP NULL, #0
; 260:       C0035FD6         RET
; 264: L6:   A04A21D4         BRK #2645                       ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; R0
; 268: L7:   60C322D4         BRK #5659                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; LEXENV
; 26C:       33               BYTE #X33                       ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 26D:       .ALIGN           4
; 270: L8:   60C322D4         BRK #5659                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; LEXENV
; 274:       33               BYTE #X33                       ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 275:       .ALIGN           4
; 278: L9:   C10E4092         AND NL1, LEXENV, #15
; 27C:       3F0C00F1         CMP NL1, #3
; 280:       01010054         BNE L10
; 284:       CC5240F8         LDR R2, [LEXENV, #5]
; 288:       825145B8         LDR WNL2, [R2, #85]
; 28C:       21EEFF18         LDR WNL1, #x70055B3050
; 290:       5F00016B         CMP WNL2, WNL1
; 294:       61000054         BNE L10
; 298:       CBD241F8         LDR R1, [LEXENV, #29]
; 29C:       B5FFFF17         B L0
; 2A0: L10:  60C322D4         BRK #5659                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; LEXENV
; 2A4:       33               BYTE #X33                       ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 2A5:       .ALIGN           4
; 2A8:       E00120D4         BRK #15                         ; Invalid argument count trap
; 2AC: L11:  090880D2         MOVZ TMP, #64
; 2B0:       CAECFF58         LDR R0, #x70055B3048            ; SB-VM::ALLOC-TRAMP
; 2B4:       40013FD6         BLR R0
; 2B8:       D7FFFF17         B L4
