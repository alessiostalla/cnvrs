; disassembly for CNVRS/RUNTIME::CONTEXT-FIRST-ENTRY
; Size: 152 bytes. Origin: #x700A995D78                       ; CNVRS/RUNTIME::CONTEXT-FIRST-ENTRY
; D78:       4B5140F8         LDR R1, [R0, #5]
; D7C:       629145B8         LDR WNL2, [R1, #89]
; D80:       E1FCFF18         LDR WNL1, #x700A995D1C
; D84:       5F00016B         CMP WNL2, WNL1
; D88:       81010054         BNE L1
; D8C:       40D141F8         LDR NL0, [R0, #29]
; D90:       4B5141F8         LDR R1, [R0, #21]
; D94: L0:   EA0300AA         MOV R0, NL0
; D98:       F9031AAA         MOV OCFP, CFP
; D9C:       5A7B40A9         LDP CFP, LR, [CFP]
; DA0:       3B430091         ADD CSP, OCFP, #16
; DA4:       970080D2         MOVZ NARGS, #4
; DA8:       EC031DAA         MOV R2, NULL
; DAC:       ED031DAA         MOV R3, NULL
; DB0:       FF031FEB         CMP ZR, ZR
; DB4:       C0035FD6         RET
; DB8: L1:   629145B8         LDR WNL2, [R1, #89]
; DBC:       21FBFF18         LDR WNL1, #x700A995D20
; DC0:       5F00016B         CMP WNL2, WNL1
; DC4:       81010054         BNE L2
; DC8:       4B5141F8         LDR R1, [R0, #21]
; DCC:       60915FF8         LDR NL0, [R1, #-7]
; DD0:       800100B4         CBZ NL0, L3
; DD4:       601140B8         LDR WNL0, [R1, #1]
; DD8:       01F87FD3         LSL NL1, NL0, #1
; DDC:       4AD141F8         LDR R0, [R0, #29]
; DE0:       40915FF8         LDR NL0, [R0, #-7]
; DE4:       200100B4         CBZ NL0, L4
; DE8:       4B1140F8         LDR R1, [R0, #1]
; DEC:       E00301AA         MOV NL0, NL1
; DF0:       E9FFFF17         B L0
; DF4: L2:   A04321D4         BRK #2589                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; DF8:       27               BYTE #X27                       ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; DF9:       .ALIGN           4
; DFC:       E00120D4         BRK #15                         ; Invalid argument count trap
; E00: L3:   206421D4         BRK #2849                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R1
; E04:       80808004         BYTE #X80, #X80, #X80, #X04     ; 0
; E08: L4:   204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; E0C:       80808004         BYTE #X80, #X80, #X80, #X04     ; 0
