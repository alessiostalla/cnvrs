; disassembly for CNVRS/ANTLR-RUNTIME::MERGE-CACHE-PUT
; Size: 336 bytes. Origin: #x700D72F86C                       ; CNVRS/ANTLR-RUNTIME::MERGE-CACHE-PUT
; 86C:       1F021DEB         CMP R6, NULL
; 870:       C1000054         BNE L1
; 874: L0:   4A1340F9         LDR R0, [CFP, #32]
; 878:       FB031AAA         MOV CSP, CFP
; 87C:       5A7B40A9         LDP CFP, LR, [CFP]
; 880:       BF0300F1         CMP NULL, #0
; 884:       C0035FD6         RET
; 888: L1:   BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 88C:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; 890:       2FC10091         ADD R5, TMP, #48
; 894:       FF011EEB         CMP R5, LR
; 898:       28080054         BHI L10
; 89C:       AF2E00F9         STR R5, [THREAD, #88]           ; cons-tlab
; 8A0: L2:   2F1D0091         ADD R5, TMP, #7
; 8A4:       ED030FAA         MOV R3, R5
; 8A8:       AB911FF8         STR R1, [R3, #-7]
; 8AC:       AD410091         ADD R3, R3, #16
; 8B0:       AD111FF8         STR R3, [R3, #-15]
; 8B4:       AC911FF8         STR R2, [R3, #-7]
; 8B8:       AD410091         ADD R3, R3, #16
; 8BC:       AD111FF8         STR R3, [R3, #-15]
; 8C0:       4E1340F9         LDR R4, [CFP, #32]
; 8C4:       AE911FF8         STR R4, [R3, #-7]
; 8C8:       BD1100F8         STR NULL, [R3, #1]
; 8CC:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 8D0:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 8D4:       5E0000B4         CBZ LR, L3
; 8D8:       200120D4         BRK #9                          ; Pending interrupt trap
; 8DC: L3:   F1030FAA         MOV R7, R5
; 8E0:       7F011DEB         CMP R1, NULL
; 8E4:       60050054         BEQ L9
; 8E8:       60D140F8         LDR NL0, [R1, #13]
; 8EC: L4:   9F011DEB         CMP R2, NULL
; 8F0:       C0040054         BEQ L8
; 8F4:       81D140F8         LDR NL1, [R2, #13]
; 8F8: L5:   514301A9         STP R7, R6, [CFP, #16]
; 8FC:       010001CA         EOR NL1, NL0, NL1
; 900:       411700F9         STR NL1, [CFP, #40]
; 904:       7A0300F9         STR CFP, [CSP]
; 908:       EF0310AA         MOV R5, R6
; 90C:       EA0301AA         MOV R0, NL1
; 910:       EB030FAA         MOV R1, R5
; 914:       EC031DAA         MOV R2, NULL
; 918:       56F1FF58         LDR LEXENV, #x700D72F740        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 91C:       FA031BAA         MOV CFP, CSP
; 920:       DE9240F8         LDR LR, [LEXENV, #9]
; 924:       C0033FD6         BLR LR
; 928:       FB0319AA         MOV CSP, OCFP
; 92C:       411740F9         LDR NL1, [CFP, #40]
; 930:       514341A9         LDP R7, R6, [CFP, #16]
; 934:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 938:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; 93C:       2C410091         ADD R2, TMP, #16
; 940:       9F011EEB         CMP R2, LR
; 944:       48030054         BHI L11
; 948:       AC2E00F9         STR R2, [THREAD, #88]           ; cons-tlab
; 94C: L6:   2C1D0091         ADD R2, TMP, #7
; 950:       312900A9         STP R7, R0, [TMP]
; 954:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 958:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 95C:       5E0000B4         CBZ LR, L7
; 960:       200120D4         BRK #9                          ; Pending interrupt trap
; 964: L7:   7A0300F9         STR CFP, [CSP]
; 968:       EF0310AA         MOV R5, R6
; 96C:       EA0301AA         MOV R0, NL1
; 970:       EB030FAA         MOV R1, R5
; 974:       B6EEFF58         LDR LEXENV, #x700D72F748        ; #<SB-KERNEL:FDEFN SB-KERNEL:%PUTHASH>
; 978:       FA031BAA         MOV CFP, CSP
; 97C:       DE9240F8         LDR LR, [LEXENV, #9]
; 980:       C0033FD6         BLR LR
; 984:       BCFFFF17         B L0
; 988: L8:   010080D2         MOVZ NL1, #0
; 98C:       DBFFFF17         B L5
; 990: L9:   000080D2         MOVZ NL0, #0
; 994:       D6FFFF17         B L4
; 998:       E00120D4         BRK #15                         ; Invalid argument count trap
; 99C: L10:  090680D2         MOVZ TMP, #48
; 9A0:       4FEEFF58         LDR R5, #x700D72F768            ; SB-VM::LIST-ALLOC-TRAMP
; 9A4:       E0013FD6         BLR R5
; 9A8:       BEFFFF17         B L2
; 9AC: L11:  090280D2         MOVZ TMP, #16
; 9B0:       CCEDFF58         LDR R2, #x700D72F768            ; SB-VM::LIST-ALLOC-TRAMP
; 9B4:       80013FD6         BLR R2
; 9B8:       E5FFFF17         B L6
