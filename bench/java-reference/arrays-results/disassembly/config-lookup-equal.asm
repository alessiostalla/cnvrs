; disassembly for CNVRS/RUNTIME::CONFIG-LOOKUP-EQUAL
; Size: 84 bytes. Origin: #x700D72CB00                        ; CNVRS/RUNTIME::CONFIG-LOOKUP-EQUAL
; 00:       41D140F8         LDR NL1, [R0, #13]
; 04:       60D140F8         LDR NL0, [R1, #13]
; 08:       1F0001EB         CMP NL0, NL1
; 0C:       C0000054         BEQ L1
; 10: L0:   EA031DAA         MOV R0, NULL
; 14:       FB031AAA         MOV CSP, CFP
; 18:       5A7B40A9         LDP CFP, LR, [CFP]
; 1C:       BF0300F1         CMP NULL, #0
; 20:       C0035FD6         RET
; 24: L1:   415141F8         LDR NL1, [R0, #21]
; 28:       605141F8         LDR NL0, [R1, #21]
; 2C:       1F0001EB         CMP NL0, NL1
; 30:       01FFFF54         BNE L0
; 34:       4A5142F8         LDR R0, [R0, #37]
; 38:       6B5142F8         LDR R1, [R1, #37]
; 3C:       B6F9FF58         LDR LEXENV, #x700D72CA70         ; #<SB-KERNEL:FDEFN EQUAL>
; 40:       970080D2         MOVZ NARGS, #4
; 44:       DE9240F8         LDR LR, [LEXENV, #9]
; 48:       DE130091         ADD LR, LR, #4
; 4C:       C0031FD6         BR LR
; 50:       E00120D4         BRK #15                          ; Invalid argument count trap
