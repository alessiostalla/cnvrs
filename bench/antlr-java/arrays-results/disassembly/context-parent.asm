; disassembly for CNVRS/ANTLR-RUNTIME::CONTEXT-PARENT
; Size: 188 bytes. Origin: #x700D72EC54                       ; CNVRS/ANTLR-RUNTIME::CONTEXT-PARENT
; C54:       4A0B40F9         LDR R0, [CFP, #16]
; C58:       490D4092         AND TMP, R0, #15
; C5C:       3F0D00F1         CMP TMP, #3
; C60:       C1040054         BNE L4
; C64:       4A5140F8         LDR R0, [R0, #5]
; C68:       429145B8         LDR WNL2, [R0, #89]
; C6C:       61FDFF18         LDR WNL1, #x700D72EC18
; C70:       5F00016B         CMP WNL2, WNL1
; C74:       A1020054         BNE L3
; C78:       0D000014         B L1
; C7C: L0:   4F0F00F9         STR R5, [CFP, #24]
; C80:       7A0300F9         STR CFP, [CSP]
; C84:       AAFBFF58         LDR R0, #x700D72EBF8            ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; C88:       4B0080D2         MOVZ R1, #2
; C8C:       ACFBFF58         LDR R2, #x700D72EC00            ; 'CNVRS/ANTLR-RUNTIME::INDEX
; C90:       ED030FAA         MOV R3, R5
; C94:       F6FAFF58         LDR LEXENV, #x700D72EBF0        ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; C98:       170180D2         MOVZ NARGS, #8
; C9C:       FA031BAA         MOV CFP, CSP
; CA0:       DE9240F8         LDR LR, [LEXENV, #9]
; CA4:       C0033FD6         BLR LR
; CA8:       4F0F40F9         LDR R5, [CFP, #24]
; CAC: L1:   8FFEFFB5         CBNZ R5, L0
; CB0:       4A0B40F9         LDR R0, [CFP, #16]
; CB4:       4A5141F8         LDR R0, [R0, #21]
; CB8: L2:   FB031AAA         MOV CSP, CFP
; CBC:       5A7B40A9         LDP CFP, LR, [CFP]
; CC0:       BF0300F1         CMP NULL, #0
; CC4:       C0035FD6         RET
; CC8: L3:   429145B8         LDR WNL2, [R0, #89]
; CCC:       81FAFF18         LDR WNL1, #x700D72EC1C
; CD0:       5F00016B         CMP WNL2, WNL1
; CD4:       21010054         BNE L4
; CD8:       4A0B40F9         LDR R0, [CFP, #16]
; CDC:       4AD141F8         LDR R0, [R0, #29]
; CE0:       40915FF8         LDR NL0, [R0, #-7]
; CE4:       1F000FEB         CMP NL0, R5
; CE8:       09010054         BLS L5
; CEC:       49090F8B         ADD TMP, R0, R5, LSL #2
; CF0:       2A1140F8         LDR R0, [TMP, #1]
; CF4:       F1FFFF17         B L2
; CF8: L4:   4A0B40F9         LDR R0, [CFP, #16]
; CFC:       A04321D4         BRK #2589                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; D00:       2F               BYTE #X2F                       ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; D01:       .ALIGN           4
; D04:       E00120D4         BRK #15                         ; Invalid argument count trap
; D08: L5:   204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; D0C:       3D               BYTE #X3D                       ; R5
; D0D:       .ALIGN           4
