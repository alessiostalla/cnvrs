; disassembly for CNVRS/RUNTIME::CONTEXT-RETURN-STATE
; Size: 196 bytes. Origin: #x700D8D0504                       ; CNVRS/RUNTIME::CONTEXT-RETURN-STATE
; 04:       4A0B40F9         LDR R0, [CFP, #16]
; 08:       490D4092         AND TMP, R0, #15
; 0C:       3F0D00F1         CMP TMP, #3
; 10:       01050054         BNE L4
; 14:       4A5140F8         LDR R0, [R0, #5]
; 18:       429145B8         LDR WNL2, [R0, #89]
; 1C:       61FDFF18         LDR WNL1, #x700D8D04C8
; 20:       5F00016B         CMP WNL2, WNL1
; 24:       A1020054         BNE L3
; 28:       0D000014         B L1
; 2C: L0:   4F0F00F9         STR R5, [CFP, #24]
; 30:       7A0300F9         STR CFP, [CSP]
; 34:       AAFBFF58         LDR R0, #x700D8D04A8             ; '(ZEROP
                                                              ;   CNVRS/RUNTIME::INDEX)
; 38:       4B0080D2         MOVZ R1, #2
; 3C:       ACFBFF58         LDR R2, #x700D8D04B0             ; 'CNVRS/RUNTIME::INDEX
; 40:       ED030FAA         MOV R3, R5
; 44:       F6FAFF58         LDR LEXENV, #x700D8D04A0         ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 48:       170180D2         MOVZ NARGS, #8
; 4C:       FA031BAA         MOV CFP, CSP
; 50:       DE9240F8         LDR LR, [LEXENV, #9]
; 54:       C0033FD6         BLR LR
; 58:       4F0F40F9         LDR R5, [CFP, #24]
; 5C: L1:   8FFEFFB5         CBNZ R5, L0
; 60:       4A0B40F9         LDR R0, [CFP, #16]
; 64:       4AD141F8         LDR R0, [R0, #29]
; 68: L2:   FB031AAA         MOV CSP, CFP
; 6C:       5A7B40A9         LDP CFP, LR, [CFP]
; 70:       BF0300F1         CMP NULL, #0
; 74:       C0035FD6         RET
; 78: L3:   429145B8         LDR WNL2, [R0, #89]
; 7C:       81FAFF18         LDR WNL1, #x700D8D04CC
; 80:       5F00016B         CMP WNL2, WNL1
; 84:       61010054         BNE L4
; 88:       4A0B40F9         LDR R0, [CFP, #16]
; 8C:       4A5141F8         LDR R0, [R0, #21]
; 90:       40915FF8         LDR NL0, [R0, #-7]
; 94:       1F000FEB         CMP NL0, R5
; 98:       49010054         BLS L5
; 9C:       49090F8B         ADD TMP, R0, R5, LSL #2
; A0:       2A1140F8         LDR R0, [TMP, #1]
; A4:       5F7D5FF2         TST R0, #18446744065119617025
; A8:       00FEFF54         BEQ L2
; AC:       604D21D4         BRK #2667                        ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; B0: L4:   4A0B40F9         LDR R0, [CFP, #16]
; B4:       A04321D4         BRK #2589                        ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; B8:       2F               BYTE #X2F                        ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; B9:       .ALIGN           4
; BC:       E00120D4         BRK #15                          ; Invalid argument count trap
; C0: L5:   204421D4         BRK #2593                        ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; C4:       3D               BYTE #X3D                        ; R5
; C5:       .ALIGN           4
