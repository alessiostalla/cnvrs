; disassembly for CNVRS/RUNTIME::CONTEXT-PARENT
; Size: 188 bytes. Origin: #x700D8D0674                       ; CNVRS/RUNTIME::CONTEXT-PARENT
; 674:       4A0B40F9         LDR R0, [CFP, #16]
; 678:       490D4092         AND TMP, R0, #15
; 67C:       3F0D00F1         CMP TMP, #3
; 680:       C1040054         BNE L4
; 684:       4A5140F8         LDR R0, [R0, #5]
; 688:       429145B8         LDR WNL2, [R0, #89]
; 68C:       61FDFF18         LDR WNL1, #x700D8D0638
; 690:       5F00016B         CMP WNL2, WNL1
; 694:       A1020054         BNE L3
; 698:       0D000014         B L1
; 69C: L0:   4F0F00F9         STR R5, [CFP, #24]
; 6A0:       7A0300F9         STR CFP, [CSP]
; 6A4:       AAFBFF58         LDR R0, #x700D8D0618            ; '(ZEROP
                                                              ;   CNVRS/RUNTIME::INDEX)
; 6A8:       4B0080D2         MOVZ R1, #2
; 6AC:       ACFBFF58         LDR R2, #x700D8D0620            ; 'CNVRS/RUNTIME::INDEX
; 6B0:       ED030FAA         MOV R3, R5
; 6B4:       F6FAFF58         LDR LEXENV, #x700D8D0610        ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 6B8:       170180D2         MOVZ NARGS, #8
; 6BC:       FA031BAA         MOV CFP, CSP
; 6C0:       DE9240F8         LDR LR, [LEXENV, #9]
; 6C4:       C0033FD6         BLR LR
; 6C8:       4F0F40F9         LDR R5, [CFP, #24]
; 6CC: L1:   8FFEFFB5         CBNZ R5, L0
; 6D0:       4A0B40F9         LDR R0, [CFP, #16]
; 6D4:       4A5141F8         LDR R0, [R0, #21]
; 6D8: L2:   FB031AAA         MOV CSP, CFP
; 6DC:       5A7B40A9         LDP CFP, LR, [CFP]
; 6E0:       BF0300F1         CMP NULL, #0
; 6E4:       C0035FD6         RET
; 6E8: L3:   429145B8         LDR WNL2, [R0, #89]
; 6EC:       81FAFF18         LDR WNL1, #x700D8D063C
; 6F0:       5F00016B         CMP WNL2, WNL1
; 6F4:       21010054         BNE L4
; 6F8:       4A0B40F9         LDR R0, [CFP, #16]
; 6FC:       4AD141F8         LDR R0, [R0, #29]
; 700:       40915FF8         LDR NL0, [R0, #-7]
; 704:       1F000FEB         CMP NL0, R5
; 708:       09010054         BLS L5
; 70C:       49090F8B         ADD TMP, R0, R5, LSL #2
; 710:       2A1140F8         LDR R0, [TMP, #1]
; 714:       F1FFFF17         B L2
; 718: L4:   4A0B40F9         LDR R0, [CFP, #16]
; 71C:       A04321D4         BRK #2589                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; 720:       2F               BYTE #X2F                       ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 721:       .ALIGN           4
; 724:       E00120D4         BRK #15                         ; Invalid argument count trap
; 728: L5:   204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 72C:       3D               BYTE #X3D                       ; R5
; 72D:       .ALIGN           4
