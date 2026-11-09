; disassembly for CNVRS/ANTLR-RUNTIME::DERIVE-CONFIG
; Size: 208 bytes. Origin: #x700AA36128                       ; CNVRS/ANTLR-RUNTIME::DERIVE-CONFIG
; 28:       AE0500B4         CBZ R4, L6
; 2C:       3F021DEB         CMP R7, NULL
; 30:       20010054         BEQ L0
; 34:       210E4092         AND NL1, R7, #15
; 38:       3F0C00F1         CMP NL1, #3
; 3C:       C1040054         BNE L5
; 40:       2C5240F8         LDR R2, [R7, #5]
; 44:       825145B8         LDR WNL2, [R2, #85]
; 48:       E1F4FF18         LDR WNL1, #x700AA35FE4
; 4C:       5F00016B         CMP WNL2, WNL1
; 50:       21040054         BNE L5
; 54: L0:   EB0311AA         MOV R1, R7
; 58: L1:   500000B5         CBNZ R6, L2
; 5C:       535142F8         LDR R9, [R0, #37]
; 60: L2:   405141F8         LDR NL0, [R0, #21]
; 64:       41D142F8         LDR NL1, [R0, #45]
; 68:       4C5143F8         LDR R2, [R0, #53]
; 6C:       BD2A00B9         STR WNULL, [THREAD, #40]         ; pseudo-atomic-bits
; 70:       A97A47A9         LDP TMP, LR, [THREAD, #112]      ; mixed-tlab.{free-pointer, end-addr}
; 74:       2A010191         ADD R0, TMP, #64
; 78:       5F011EEB         CMP R0, LR
; 7C:       68030054         BHI L7
; 80:       AA3A00F9         STR R0, [THREAD, #112]           ; mixed-tlab
; 84: L3:   2A0D0091         ADD R0, TMP, #3
; 88:       3E8783D2         MOVZ LR, #7225
; 8C:       5ED11FF8         STR LR, [R0, #-3]
; 90:       BF3A03D5         DMB ISHST
; 94:       BF2A00B9         STR WZR, [THREAD, #40]           ; pseudo-atomic-bits
; 98:       BE2E40B9         LDR WLR, [THREAD, #44]           ; pseudo-atomic-bits
; 9C:       5E0000B4         CBZ LR, L4
; A0:       200120D4         BRK #9                           ; Pending interrupt trap
; A4: L4:   EEEFFF58         LDR R4, #x700AA35FA0             ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA4E5D3}>
; A8:       4E5100F8         STR R4, [R0, #5]
; AC:       4DD100F8         STR R3, [R0, #13]
; B0:       405101F8         STR NL0, [R0, #21]
; B4:       4BD101F8         STR R1, [R0, #29]
; B8:       535102F8         STR R9, [R0, #37]
; BC:       41D102F8         STR NL1, [R0, #45]
; C0:       4C5103F8         STR R2, [R0, #53]
; C4:       FB031AAA         MOV CSP, CFP
; C8:       5A7B40A9         LDP CFP, LR, [CFP]
; CC:       BF0300F1         CMP NULL, #0
; D0:       C0035FD6         RET
; D4: L5:   602322D4         BRK #4379                        ; OBJECT-NOT-TYPE-ERROR
                                                              ; R7
; D8:       33               BYTE #X33                        ; '(OR NULL
                                                              ;      CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT)
; D9:       .ALIGN           4
; DC: L6:   4BD141F8         LDR R1, [R0, #29]
; E0:       DEFFFF17         B L1
; E4:       E00120D4         BRK #15                          ; Invalid argument count trap
; E8: L7:   090880D2         MOVZ TMP, #64
; EC:       6AEFFF58         LDR R0, #x700AA35FD8             ; SB-VM::ALLOC-TRAMP
; F0:       40013FD6         BLR R0
; F4:       E4FFFF17         B L3
