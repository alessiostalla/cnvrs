; disassembly for CNVRS/RUNTIME::DERIVE-CONFIG
; Size: 340 bytes. Origin: #x700AA62528                       ; CNVRS/RUNTIME::DERIVE-CONFIG
; 528:       8D0800B4         CBZ R3, L9
; 52C:       EB0310AA         MOV R1, R6
; 530: L0:   4E0100B5         CBNZ R4, L1
; 534:       C10E4092         AND NL1, LEXENV, #15
; 538:       3F0C00F1         CMP NL1, #3
; 53C:       A1070054         BNE L8
; 540:       CC5240F8         LDR R2, [LEXENV, #5]
; 544:       825145B8         LDR WNL2, [R2, #85]
; 548:       41F6FF18         LDR WNL1, #x700AA62410
; 54C:       5F00016B         CMP WNL2, WNL1
; 550:       01070054         BNE L8
; 554:       D15242F8         LDR R7, [LEXENV, #37]
; 558: L1:   C10E4092         AND NL1, LEXENV, #15
; 55C:       3F0C00F1         CMP NL1, #3
; 560:       41060054         BNE L7
; 564:       CC5240F8         LDR R2, [LEXENV, #5]
; 568:       825145B8         LDR WNL2, [R2, #85]
; 56C:       21F5FF18         LDR WNL1, #x700AA62410
; 570:       5F00016B         CMP WNL2, WNL1
; 574:       A1050054         BNE L7
; 578:       C05241F8         LDR NL0, [LEXENV, #21]
; 57C:       C3D242F8         LDR NL3, [LEXENV, #45]
; 580:       CE5243F8         LDR R4, [LEXENV, #53]
; 584:       0A050037         TBNZ WR0, #0, L6
; 588:       ED030AAA         MOV R3, R0
; 58C:       7F011DEB         CMP R1, NULL
; 590:       60010054         BEQ L3
; 594:       610D4092         AND NL1, R1, #15
; 598:       3F0C00F1         CMP NL1, #3
; 59C:       C1000054         BNE L2
; 5A0:       6C5140F8         LDR R2, [R1, #5]
; 5A4:       825145B8         LDR WNL2, [R2, #85]
; 5A8:       61F3FF18         LDR WNL1, #x700AA62414
; 5AC:       5F00016B         CMP WNL2, WNL1
; 5B0:       60000054         BEQ L3
; 5B4: L2:   606321D4         BRK #2843                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R1
; 5B8:       2F               BYTE #X2F                       ; '(OR NULL
                                                              ;      CNVRS/RUNTIME:PREDICTION-CONTEXT)
; 5B9:       .ALIGN           4
; 5BC: L3:   BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 5C0:       A97A47A9         LDP TMP, LR, [THREAD, #112]     ; mixed-tlab.{free-pointer, end-addr}
; 5C4:       2A010191         ADD R0, TMP, #64
; 5C8:       5F011EEB         CMP R0, LR
; 5CC:       08050054         BHI L11
; 5D0:       AA3A00F9         STR R0, [THREAD, #112]          ; mixed-tlab
; 5D4: L4:   2A0D0091         ADD R0, TMP, #3
; 5D8:       3E8783D2         MOVZ LR, #7225
; 5DC:       5ED11FF8         STR LR, [R0, #-3]
; 5E0:       BF3A03D5         DMB ISHST
; 5E4:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 5E8:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 5EC:       5E0000B4         CBZ LR, L5
; 5F0:       200120D4         BRK #9                          ; Pending interrupt trap
; 5F4: L5:   ECEFFF58         LDR R2, #x700AA623F0            ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-CONFIG {700AA36813}>
; 5F8:       4C5100F8         STR R2, [R0, #5]
; 5FC:       4DD100F8         STR R3, [R0, #13]
; 600:       405101F8         STR NL0, [R0, #21]
; 604:       4BD101F8         STR R1, [R0, #29]
; 608:       515102F8         STR R7, [R0, #37]
; 60C:       43D102F8         STR NL3, [R0, #45]
; 610:       4E5103F8         STR R4, [R0, #53]
; 614:       FB031AAA         MOV CSP, CFP
; 618:       5A7B40A9         LDP CFP, LR, [CFP]
; 61C:       BF0300F1         CMP NULL, #0
; 620:       C0035FD6         RET
; 624: L6:   A04A21D4         BRK #2645                       ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; R0
; 628: L7:   60C322D4         BRK #5659                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; LEXENV
; 62C:       33               BYTE #X33                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-CONFIG {700AA36813}>
; 62D:       .ALIGN           4
; 630: L8:   60C322D4         BRK #5659                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; LEXENV
; 634:       33               BYTE #X33                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-CONFIG {700AA36813}>
; 635:       .ALIGN           4
; 638: L9:   C10E4092         AND NL1, LEXENV, #15
; 63C:       3F0C00F1         CMP NL1, #3
; 640:       01010054         BNE L10
; 644:       CC5240F8         LDR R2, [LEXENV, #5]
; 648:       825145B8         LDR WNL2, [R2, #85]
; 64C:       21EEFF18         LDR WNL1, #x700AA62410
; 650:       5F00016B         CMP WNL2, WNL1
; 654:       61000054         BNE L10
; 658:       CBD241F8         LDR R1, [LEXENV, #29]
; 65C:       B5FFFF17         B L0
; 660: L10:  60C322D4         BRK #5659                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; LEXENV
; 664:       33               BYTE #X33                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-CONFIG {700AA36813}>
; 665:       .ALIGN           4
; 668:       E00120D4         BRK #15                         ; Invalid argument count trap
; 66C: L11:  090880D2         MOVZ TMP, #64
; 670:       CAECFF58         LDR R0, #x700AA62408            ; SB-VM::ALLOC-TRAMP
; 674:       40013FD6         BLR R0
; 678:       D7FFFF17         B L4
