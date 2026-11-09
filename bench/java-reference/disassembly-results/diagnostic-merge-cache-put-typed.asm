; disassembly for DIAGNOSTIC-MERGE-CACHE-PUT-TYPED
; Size: 336 bytes. Origin: #x70055B2B0C                       ; DIAGNOSTIC-MERGE-CACHE-PUT-TYPED
; B0C:       1F021DEB         CMP R6, NULL
; B10:       C1000054         BNE L1
; B14: L0:   4A1340F9         LDR R0, [CFP, #32]
; B18:       FB031AAA         MOV CSP, CFP
; B1C:       5A7B40A9         LDP CFP, LR, [CFP]
; B20:       BF0300F1         CMP NULL, #0
; B24:       C0035FD6         RET
; B28: L1:   BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; B2C:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; B30:       2FC10091         ADD R5, TMP, #48
; B34:       FF011EEB         CMP R5, LR
; B38:       28080054         BHI L10
; B3C:       AF2E00F9         STR R5, [THREAD, #88]           ; cons-tlab
; B40: L2:   2F1D0091         ADD R5, TMP, #7
; B44:       ED030FAA         MOV R3, R5
; B48:       AB911FF8         STR R1, [R3, #-7]
; B4C:       AD410091         ADD R3, R3, #16
; B50:       AD111FF8         STR R3, [R3, #-15]
; B54:       AC911FF8         STR R2, [R3, #-7]
; B58:       AD410091         ADD R3, R3, #16
; B5C:       AD111FF8         STR R3, [R3, #-15]
; B60:       4E1340F9         LDR R4, [CFP, #32]
; B64:       AE911FF8         STR R4, [R3, #-7]
; B68:       BD1100F8         STR NULL, [R3, #1]
; B6C:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; B70:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; B74:       5E0000B4         CBZ LR, L3
; B78:       200120D4         BRK #9                          ; Pending interrupt trap
; B7C: L3:   F1030FAA         MOV R7, R5
; B80:       7F011DEB         CMP R1, NULL
; B84:       60050054         BEQ L9
; B88:       60D140F8         LDR NL0, [R1, #13]
; B8C: L4:   9F011DEB         CMP R2, NULL
; B90:       C0040054         BEQ L8
; B94:       81D140F8         LDR NL1, [R2, #13]
; B98: L5:   514301A9         STP R7, R6, [CFP, #16]
; B9C:       010001CA         EOR NL1, NL0, NL1
; BA0:       411700F9         STR NL1, [CFP, #40]
; BA4:       7A0300F9         STR CFP, [CSP]
; BA8:       EF0310AA         MOV R5, R6
; BAC:       EA0301AA         MOV R0, NL1
; BB0:       EB030FAA         MOV R1, R5
; BB4:       EC031DAA         MOV R2, NULL
; BB8:       D6F0FF58         LDR LEXENV, #x70055B29D0        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; BBC:       FA031BAA         MOV CFP, CSP
; BC0:       DE9240F8         LDR LR, [LEXENV, #9]
; BC4:       C0033FD6         BLR LR
; BC8:       FB0319AA         MOV CSP, OCFP
; BCC:       411740F9         LDR NL1, [CFP, #40]
; BD0:       514341A9         LDP R7, R6, [CFP, #16]
; BD4:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; BD8:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; BDC:       2C410091         ADD R2, TMP, #16
; BE0:       9F011EEB         CMP R2, LR
; BE4:       48030054         BHI L11
; BE8:       AC2E00F9         STR R2, [THREAD, #88]           ; cons-tlab
; BEC: L6:   2C1D0091         ADD R2, TMP, #7
; BF0:       312900A9         STP R7, R0, [TMP]
; BF4:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; BF8:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; BFC:       5E0000B4         CBZ LR, L7
; C00:       200120D4         BRK #9                          ; Pending interrupt trap
; C04: L7:   7A0300F9         STR CFP, [CSP]
; C08:       EF0310AA         MOV R5, R6
; C0C:       EA0301AA         MOV R0, NL1
; C10:       EB030FAA         MOV R1, R5
; C14:       36EEFF58         LDR LEXENV, #x70055B29D8        ; #<SB-KERNEL:FDEFN SB-KERNEL:%PUTHASH>
; C18:       FA031BAA         MOV CFP, CSP
; C1C:       DE9240F8         LDR LR, [LEXENV, #9]
; C20:       C0033FD6         BLR LR
; C24:       BCFFFF17         B L0
; C28: L8:   010080D2         MOVZ NL1, #0
; C2C:       DBFFFF17         B L5
; C30: L9:   000080D2         MOVZ NL0, #0
; C34:       D6FFFF17         B L4
; C38:       E00120D4         BRK #15                         ; Invalid argument count trap
; C3C: L10:  090680D2         MOVZ TMP, #48
; C40:       4FEEFF58         LDR R5, #x70055B2A08            ; SB-VM::LIST-ALLOC-TRAMP
; C44:       E0013FD6         BLR R5
; C48:       BEFFFF17         B L2
; C4C: L11:  090280D2         MOVZ TMP, #16
; C50:       CCEDFF58         LDR R2, #x70055B2A08            ; SB-VM::LIST-ALLOC-TRAMP
; C54:       80013FD6         BLR R2
; C58:       E5FFFF17         B L6
