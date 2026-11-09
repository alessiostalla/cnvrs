; disassembly for DIAGNOSTIC-CONTROL-MERGE-CACHE-PUT
; Size: 408 bytes. Origin: #x70055B479C                       ; DIAGNOSTIC-CONTROL-MERGE-CACHE-PUT
; 79C:       1F021DEB         CMP R6, NULL
; 7A0:       C1000054         BNE L1
; 7A4: L0:   4A1340F9         LDR R0, [CFP, #32]
; 7A8:       FB031AAA         MOV CSP, CFP
; 7AC:       5A7B40A9         LDP CFP, LR, [CFP]
; 7B0:       BF0300F1         CMP NULL, #0
; 7B4:       C0035FD6         RET
; 7B8: L1:   BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 7BC:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; 7C0:       2FC10091         ADD R5, TMP, #48
; 7C4:       FF011EEB         CMP R5, LR
; 7C8:       680A0054         BHI L12
; 7CC:       AF2E00F9         STR R5, [THREAD, #88]           ; cons-tlab
; 7D0: L2:   2F1D0091         ADD R5, TMP, #7
; 7D4:       ED030FAA         MOV R3, R5
; 7D8:       AB911FF8         STR R1, [R3, #-7]
; 7DC:       AD410091         ADD R3, R3, #16
; 7E0:       AD111FF8         STR R3, [R3, #-15]
; 7E4:       AC911FF8         STR R2, [R3, #-7]
; 7E8:       AD410091         ADD R3, R3, #16
; 7EC:       AD111FF8         STR R3, [R3, #-15]
; 7F0:       4E1340F9         LDR R4, [CFP, #32]
; 7F4:       AE911FF8         STR R4, [R3, #-7]
; 7F8:       BD1100F8         STR NULL, [R3, #1]
; 7FC:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 800:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 804:       5E0000B4         CBZ LR, L3
; 808:       200120D4         BRK #9                          ; Pending interrupt trap
; 80C: L3:   7F011DEB         CMP R1, NULL
; 810:       C0070054         BEQ L11
; 814:       610D4092         AND NL1, R1, #15
; 818:       3F0C00F1         CMP NL1, #3
; 81C:       21070054         BNE L10
; 820:       6D5140F8         LDR R3, [R1, #5]
; 824:       A25145B8         LDR WNL2, [R3, #85]
; 828:       C1F9FF18         LDR WNL1, #x70055B4760
; 82C:       5F00016B         CMP WNL2, WNL1
; 830:       81060054         BNE L10
; 834:       60D140F8         LDR NL0, [R1, #13]
; 838: L4:   9F011DEB         CMP R2, NULL
; 83C:       E0050054         BEQ L9
; 840:       810D4092         AND NL1, R2, #15
; 844:       3F0C00F1         CMP NL1, #3
; 848:       41050054         BNE L8
; 84C:       8D5140F8         LDR R3, [R2, #5]
; 850:       A25145B8         LDR WNL2, [R3, #85]
; 854:       61F8FF18         LDR WNL1, #x70055B4760
; 858:       5F00016B         CMP WNL2, WNL1
; 85C:       A1040054         BNE L8
; 860:       81D140F8         LDR NL1, [R2, #13]
; 864: L5:   4F0B00F9         STR R5, [CFP, #16]
; 868:       501700F9         STR R6, [CFP, #40]
; 86C:       010001CA         EOR NL1, NL0, NL1
; 870:       410F00F9         STR NL1, [CFP, #24]
; 874:       7A0300F9         STR CFP, [CSP]
; 878:       EA0301AA         MOV R0, NL1
; 87C:       EB0310AA         MOV R1, R6
; 880:       EC031DAA         MOV R2, NULL
; 884:       76F5FF58         LDR LEXENV, #x70055B4730        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 888:       FA031BAA         MOV CFP, CSP
; 88C:       DE9240F8         LDR LR, [LEXENV, #9]
; 890:       C0033FD6         BLR LR
; 894:       FB0319AA         MOV CSP, OCFP
; 898:       501740F9         LDR R6, [CFP, #40]
; 89C:       4F0741A9         LDP R5, NL1, [CFP, #16]
; 8A0:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 8A4:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; 8A8:       2C410091         ADD R2, TMP, #16
; 8AC:       9F011EEB         CMP R2, LR
; 8B0:       A8030054         BHI L13
; 8B4:       AC2E00F9         STR R2, [THREAD, #88]           ; cons-tlab
; 8B8: L6:   2C1D0091         ADD R2, TMP, #7
; 8BC:       2F2900A9         STP R5, R0, [TMP]
; 8C0:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 8C4:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 8C8:       5E0000B4         CBZ LR, L7
; 8CC:       200120D4         BRK #9                          ; Pending interrupt trap
; 8D0: L7:   7A0300F9         STR CFP, [CSP]
; 8D4:       EA0301AA         MOV R0, NL1
; 8D8:       EB0310AA         MOV R1, R6
; 8DC:       F6F2FF58         LDR LEXENV, #x70055B4738        ; #<SB-KERNEL:FDEFN SB-KERNEL:%PUTHASH>
; 8E0:       FA031BAA         MOV CFP, CSP
; 8E4:       DE9240F8         LDR LR, [LEXENV, #9]
; 8E8:       C0033FD6         BLR LR
; 8EC:       AEFFFF17         B L0
; 8F0: L8:   608321D4         BRK #3099                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 8F4:       2B               BYTE #X2B                       ; #<SB-KERNEL:LAYOUT (ID=389) for PREDICTION-CONTEXT {700CD64503}>
; 8F5:       .ALIGN           4
; 8F8: L9:   010080D2         MOVZ NL1, #0
; 8FC:       DAFFFF17         B L5
; 900: L10:  606321D4         BRK #2843                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R1
; 904:       2B               BYTE #X2B                       ; #<SB-KERNEL:LAYOUT (ID=389) for PREDICTION-CONTEXT {700CD64503}>
; 905:       .ALIGN           4
; 908: L11:  000080D2         MOVZ NL0, #0
; 90C:       CBFFFF17         B L4
; 910:       E00120D4         BRK #15                         ; Invalid argument count trap
; 914: L12:  090680D2         MOVZ TMP, #48
; 918:       0FF2FF58         LDR R5, #x70055B4758            ; SB-VM::LIST-ALLOC-TRAMP
; 91C:       E0013FD6         BLR R5
; 920:       ACFFFF17         B L2
; 924: L13:  090280D2         MOVZ TMP, #16
; 928:       8CF1FF58         LDR R2, #x70055B4758            ; SB-VM::LIST-ALLOC-TRAMP
; 92C:       80013FD6         BLR R2
; 930:       E2FFFF17         B L6
