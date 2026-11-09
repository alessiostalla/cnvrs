; disassembly for CNVRS/RUNTIME::FIND-CONFIG-IN-BUCKET
; Size: 224 bytes. Origin: #x700AA3662C                       ; CNVRS/RUNTIME::FIND-CONFIG-IN-BUCKET
; 62C:       EE030BAA         MOV R4, R1
; 630: L0:   C10D4092         AND NL1, R4, #15
; 634:       3F1C00F1         CMP NL1, #7
; 638:       61060054         BNE L6
; 63C:       DF011DEB         CMP R4, NULL
; 640:       E0050054         BEQ L5
; 644:       CD915FF8         LDR R3, [R4, #-7]
; 648:       BF011DEB         CMP R3, NULL
; 64C:       20010054         BEQ L1
; 650:       A10D4092         AND NL1, R3, #15
; 654:       3F0C00F1         CMP NL1, #3
; 658:       E1040054         BNE L4
; 65C:       AC5140F8         LDR R2, [R3, #5]
; 660:       825145B8         LDR WNL2, [R2, #85]
; 664:       21FBFF18         LDR WNL1, #x700AA365C8
; 668:       5F00016B         CMP WNL2, WNL1
; 66C:       41040054         BNE L4
; 670: L1:   CA1140F8         LDR R0, [R4, #1]
; 674:       EE030AAA         MOV R4, R0
; 678:       BF011DEB         CMP R3, NULL
; 67C:       80030054         BEQ L3
; 680:       E1D140F8         LDR NL1, [R5, #13]
; 684:       A0D140F8         LDR NL0, [R3, #13]
; 688:       1F0001EB         CMP NL0, NL1
; 68C:       21FDFF54         BNE L0
; 690:       E15141F8         LDR NL1, [R5, #21]
; 694:       A05141F8         LDR NL0, [R3, #21]
; 698:       1F0001EB         CMP NL0, NL1
; 69C:       A1FCFF54         BNE L0
; 6A0:       4D3F01A9         STP R3, R5, [CFP, #16]
; 6A4:       4E1300F9         STR R4, [CFP, #32]
; 6A8:       EA5142F8         LDR R0, [R5, #37]
; 6AC:       AB5142F8         LDR R1, [R3, #37]
; 6B0:       7A0300F9         STR CFP, [CSP]
; 6B4:       76F7FF58         LDR LEXENV, #x700AA365A0        ; #<SB-KERNEL:FDEFN EQUAL>
; 6B8:       970080D2         MOVZ NARGS, #4
; 6BC:       FA031BAA         MOV CFP, CSP
; 6C0:       DE9240F8         LDR LR, [LEXENV, #9]
; 6C4:       C0033FD6         BLR LR
; 6C8:       4FBB41A9         LDP R5, R4, [CFP, #24]
; 6CC:       4D0B40F9         LDR R3, [CFP, #16]
; 6D0:       5F011DEB         CMP R0, NULL
; 6D4:       E0FAFF54         BEQ L0
; 6D8:       EA030DAA         MOV R0, R3
; 6DC: L2:   FB031AAA         MOV CSP, CFP
; 6E0:       5A7B40A9         LDP CFP, LR, [CFP]
; 6E4:       BF0300F1         CMP NULL, #0
; 6E8:       C0035FD6         RET
; 6EC: L3:   60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 6F0:       27               BYTE #X27                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-CONFIG {700AA4E5D3}>
; 6F1:       .ALIGN           4
; 6F4: L4:   60A321D4         BRK #3355                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R3
; 6F8:       2B               BYTE #X2B                       ; '(OR NULL
                                                              ;      CNVRS/RUNTIME:ATN-CONFIG)
; 6F9:       .ALIGN           4
; 6FC: L5:   EA031DAA         MOV R0, NULL
; 700:       F7FFFF17         B L2
; 704: L6:   E0C921D4         BRK #3663                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R4
; 708:       E00120D4         BRK #15                         ; Invalid argument count trap
