; disassembly for CNVRS/ANTLR-RUNTIME::CONFIG-LOOKUP-EQUAL
; Size: 164 bytes. Origin: #x700AA62940                       ; CNVRS/ANTLR-RUNTIME::CONFIG-LOOKUP-EQUAL
; 40:       410D4092         AND NL1, R0, #15
; 44:       3F0C00F1         CMP NL1, #3
; 48:       81040054         BNE L3
; 4C:       4C5140F8         LDR R2, [R0, #5]
; 50:       825145B8         LDR WNL2, [R2, #85]
; 54:       21FEFF18         LDR WNL1, #x700AA62918
; 58:       5F00016B         CMP WNL2, WNL1
; 5C:       E1030054         BNE L3
; 60:       43D140F8         LDR NL3, [R0, #13]
; 64:       610D4092         AND NL1, R1, #15
; 68:       3F0C00F1         CMP NL1, #3
; 6C:       21030054         BNE L2
; 70:       6C5140F8         LDR R2, [R1, #5]
; 74:       825145B8         LDR WNL2, [R2, #85]
; 78:       01FDFF18         LDR WNL1, #x700AA62918
; 7C:       5F00016B         CMP WNL2, WNL1
; 80:       81020054         BNE L2
; 84:       60D140F8         LDR NL0, [R1, #13]
; 88:       1F0003EB         CMP NL0, NL3
; 8C:       A1000054         BNE L0
; 90:       415141F8         LDR NL1, [R0, #21]
; 94:       605141F8         LDR NL0, [R1, #21]
; 98:       1F0001EB         CMP NL0, NL1
; 9C:       C0000054         BEQ L1
; A0: L0:   EA031DAA         MOV R0, NULL
; A4:       FB031AAA         MOV CSP, CFP
; A8:       5A7B40A9         LDP CFP, LR, [CFP]
; AC:       BF0300F1         CMP NULL, #0
; B0:       C0035FD6         RET
; B4: L1:   4A5142F8         LDR R0, [R0, #37]
; B8:       6B5142F8         LDR R1, [R1, #37]
; BC:       36FAFF58         LDR LEXENV, #x700AA62900         ; #<SB-KERNEL:FDEFN EQUAL>
; C0:       970080D2         MOVZ NARGS, #4
; C4:       DE9240F8         LDR LR, [LEXENV, #9]
; C8:       DE130091         ADD LR, LR, #4
; CC:       C0031FD6         BR LR
; D0: L2:   606321D4         BRK #2843                        ; OBJECT-NOT-TYPE-ERROR
                                                              ; R1
; D4:       27               BYTE #X27                        ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA36813}>
; D5:       .ALIGN           4
; D8: L3:   604321D4         BRK #2587                        ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; DC:       27               BYTE #X27                        ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA36813}>
; DD:       .ALIGN           4
; E0:       E00120D4         BRK #15                          ; Invalid argument count trap
