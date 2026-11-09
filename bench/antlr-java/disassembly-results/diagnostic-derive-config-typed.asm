; disassembly for DIAGNOSTIC-DERIVE-CONFIG-TYPED
; Size: 208 bytes. Origin: #x70055B1B98                       ; DIAGNOSTIC-DERIVE-CONFIG-TYPED
; B98:       AE0500B4         CBZ R4, L6
; B9C:       3F021DEB         CMP R7, NULL
; BA0:       20010054         BEQ L0
; BA4:       210E4092         AND NL1, R7, #15
; BA8:       3F0C00F1         CMP NL1, #3
; BAC:       C1040054         BNE L5
; BB0:       2C5240F8         LDR R2, [R7, #5]
; BB4:       825145B8         LDR WNL2, [R2, #85]
; BB8:       E1F4FF18         LDR WNL1, #x70055B1A54
; BBC:       5F00016B         CMP WNL2, WNL1
; BC0:       21040054         BNE L5
; BC4: L0:   EB0311AA         MOV R1, R7
; BC8: L1:   500000B5         CBNZ R6, L2
; BCC:       535142F8         LDR R9, [R0, #37]
; BD0: L2:   405141F8         LDR NL0, [R0, #21]
; BD4:       41D142F8         LDR NL1, [R0, #45]
; BD8:       4C5143F8         LDR R2, [R0, #53]
; BDC:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; BE0:       A97A47A9         LDP TMP, LR, [THREAD, #112]     ; mixed-tlab.{free-pointer, end-addr}
; BE4:       2A010191         ADD R0, TMP, #64
; BE8:       5F011EEB         CMP R0, LR
; BEC:       68030054         BHI L7
; BF0:       AA3A00F9         STR R0, [THREAD, #112]          ; mixed-tlab
; BF4: L3:   2A0D0091         ADD R0, TMP, #3
; BF8:       3E8783D2         MOVZ LR, #7225
; BFC:       5ED11FF8         STR LR, [R0, #-3]
; C00:       BF3A03D5         DMB ISHST
; C04:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; C08:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; C0C:       5E0000B4         CBZ LR, L4
; C10:       200120D4         BRK #9                          ; Pending interrupt trap
; C14: L4:   EEEFFF58         LDR R4, #x70055B1A10            ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; C18:       4E5100F8         STR R4, [R0, #5]
; C1C:       4DD100F8         STR R3, [R0, #13]
; C20:       405101F8         STR NL0, [R0, #21]
; C24:       4BD101F8         STR R1, [R0, #29]
; C28:       535102F8         STR R9, [R0, #37]
; C2C:       41D102F8         STR NL1, [R0, #45]
; C30:       4C5103F8         STR R2, [R0, #53]
; C34:       FB031AAA         MOV CSP, CFP
; C38:       5A7B40A9         LDP CFP, LR, [CFP]
; C3C:       BF0300F1         CMP NULL, #0
; C40:       C0035FD6         RET
; C44: L5:   602322D4         BRK #4379                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R7
; C48:       33               BYTE #X33                       ; '(OR NULL
                                                              ;      PREDICTION-CONTEXT)
; C49:       .ALIGN           4
; C4C: L6:   4BD141F8         LDR R1, [R0, #29]
; C50:       DEFFFF17         B L1
; C54:       E00120D4         BRK #15                         ; Invalid argument count trap
; C58: L7:   090880D2         MOVZ TMP, #64
; C5C:       6AEFFF58         LDR R0, #x70055B1A48            ; SB-VM::ALLOC-TRAMP
; C60:       40013FD6         BLR R0
; C64:       E4FFFF17         B L3
