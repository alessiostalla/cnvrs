; disassembly for CNVRS/RUNTIME::MERGE-CACHE-PUT
; Size: 408 bytes. Origin: #x700CE0137C                       ; CNVRS/RUNTIME::MERGE-CACHE-PUT
; 37C:       1F021DEB         CMP R6, NULL
; 380:       C1000054         BNE L1
; 384: L0:   4A1340F9         LDR R0, [CFP, #32]
; 388:       FB031AAA         MOV CSP, CFP
; 38C:       5A7B40A9         LDP CFP, LR, [CFP]
; 390:       BF0300F1         CMP NULL, #0
; 394:       C0035FD6         RET
; 398: L1:   BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 39C:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; 3A0:       2FC10091         ADD R5, TMP, #48
; 3A4:       FF011EEB         CMP R5, LR
; 3A8:       680A0054         BHI L12
; 3AC:       AF2E00F9         STR R5, [THREAD, #88]           ; cons-tlab
; 3B0: L2:   2F1D0091         ADD R5, TMP, #7
; 3B4:       ED030FAA         MOV R3, R5
; 3B8:       AB911FF8         STR R1, [R3, #-7]
; 3BC:       AD410091         ADD R3, R3, #16
; 3C0:       AD111FF8         STR R3, [R3, #-15]
; 3C4:       AC911FF8         STR R2, [R3, #-7]
; 3C8:       AD410091         ADD R3, R3, #16
; 3CC:       AD111FF8         STR R3, [R3, #-15]
; 3D0:       4E1340F9         LDR R4, [CFP, #32]
; 3D4:       AE911FF8         STR R4, [R3, #-7]
; 3D8:       BD1100F8         STR NULL, [R3, #1]
; 3DC:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 3E0:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 3E4:       5E0000B4         CBZ LR, L3
; 3E8:       200120D4         BRK #9                          ; Pending interrupt trap
; 3EC: L3:   7F011DEB         CMP R1, NULL
; 3F0:       C0070054         BEQ L11
; 3F4:       610D4092         AND NL1, R1, #15
; 3F8:       3F0C00F1         CMP NL1, #3
; 3FC:       21070054         BNE L10
; 400:       6D5140F8         LDR R3, [R1, #5]
; 404:       A25145B8         LDR WNL2, [R3, #85]
; 408:       C1F9FF18         LDR WNL1, #x700CE01340
; 40C:       5F00016B         CMP WNL2, WNL1
; 410:       81060054         BNE L10
; 414:       60D140F8         LDR NL0, [R1, #13]
; 418: L4:   9F011DEB         CMP R2, NULL
; 41C:       E0050054         BEQ L9
; 420:       810D4092         AND NL1, R2, #15
; 424:       3F0C00F1         CMP NL1, #3
; 428:       41050054         BNE L8
; 42C:       8D5140F8         LDR R3, [R2, #5]
; 430:       A25145B8         LDR WNL2, [R3, #85]
; 434:       61F8FF18         LDR WNL1, #x700CE01340
; 438:       5F00016B         CMP WNL2, WNL1
; 43C:       A1040054         BNE L8
; 440:       81D140F8         LDR NL1, [R2, #13]
; 444: L5:   4F0B00F9         STR R5, [CFP, #16]
; 448:       501700F9         STR R6, [CFP, #40]
; 44C:       010001CA         EOR NL1, NL0, NL1
; 450:       410F00F9         STR NL1, [CFP, #24]
; 454:       7A0300F9         STR CFP, [CSP]
; 458:       EA0301AA         MOV R0, NL1
; 45C:       EB0310AA         MOV R1, R6
; 460:       EC031DAA         MOV R2, NULL
; 464:       76F5FF58         LDR LEXENV, #x700CE01310        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 468:       FA031BAA         MOV CFP, CSP
; 46C:       DE9240F8         LDR LR, [LEXENV, #9]
; 470:       C0033FD6         BLR LR
; 474:       FB0319AA         MOV CSP, OCFP
; 478:       501740F9         LDR R6, [CFP, #40]
; 47C:       4F0741A9         LDP R5, NL1, [CFP, #16]
; 480:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 484:       A9FA45A9         LDP TMP, LR, [THREAD, #88]      ; cons-tlab.{free-pointer, end-addr}
; 488:       2C410091         ADD R2, TMP, #16
; 48C:       9F011EEB         CMP R2, LR
; 490:       A8030054         BHI L13
; 494:       AC2E00F9         STR R2, [THREAD, #88]           ; cons-tlab
; 498: L6:   2C1D0091         ADD R2, TMP, #7
; 49C:       2F2900A9         STP R5, R0, [TMP]
; 4A0:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 4A4:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 4A8:       5E0000B4         CBZ LR, L7
; 4AC:       200120D4         BRK #9                          ; Pending interrupt trap
; 4B0: L7:   7A0300F9         STR CFP, [CSP]
; 4B4:       EA0301AA         MOV R0, NL1
; 4B8:       EB0310AA         MOV R1, R6
; 4BC:       F6F2FF58         LDR LEXENV, #x700CE01318        ; #<SB-KERNEL:FDEFN SB-KERNEL:%PUTHASH>
; 4C0:       FA031BAA         MOV CFP, CSP
; 4C4:       DE9240F8         LDR LR, [LEXENV, #9]
; 4C8:       C0033FD6         BLR LR
; 4CC:       AEFFFF17         B L0
; 4D0: L8:   608321D4         BRK #3099                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 4D4:       2B               BYTE #X2B                       ; #<SB-KERNEL:LAYOUT (ID=389) for CNVRS/RUNTIME:PREDICTION-CONTEXT {700CD54203}>
; 4D5:       .ALIGN           4
; 4D8: L9:   010080D2         MOVZ NL1, #0
; 4DC:       DAFFFF17         B L5
; 4E0: L10:  606321D4         BRK #2843                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R1
; 4E4:       2B               BYTE #X2B                       ; #<SB-KERNEL:LAYOUT (ID=389) for CNVRS/RUNTIME:PREDICTION-CONTEXT {700CD54203}>
; 4E5:       .ALIGN           4
; 4E8: L11:  000080D2         MOVZ NL0, #0
; 4EC:       CBFFFF17         B L4
; 4F0:       E00120D4         BRK #15                         ; Invalid argument count trap
; 4F4: L12:  090680D2         MOVZ TMP, #48
; 4F8:       0FF2FF58         LDR R5, #x700CE01338            ; SB-VM::LIST-ALLOC-TRAMP
; 4FC:       E0013FD6         BLR R5
; 500:       ACFFFF17         B L2
; 504: L13:  090280D2         MOVZ TMP, #16
; 508:       8CF1FF58         LDR R2, #x700CE01338            ; SB-VM::LIST-ALLOC-TRAMP
; 50C:       80013FD6         BLR R2
; 510:       E2FFFF17         B L6
