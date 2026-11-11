; disassembly for CNVRS/RUNTIME::CONTEXT-RETURN-STATE
; Size: 192 bytes. Origin: #x700D72EAE4                       ; CNVRS/RUNTIME::CONTEXT-RETURN-STATE
; AE4:       4A0F40F9         LDR R0, [CFP, #24]
; AE8:       490D4092         AND TMP, R0, #15
; AEC:       3F0D00F1         CMP TMP, #3
; AF0:       E1040054         BNE L4
; AF4:       4A5140F8         LDR R0, [R0, #5]
; AF8:       429145B8         LDR WNL2, [R0, #89]
; AFC:       61FDFF18         LDR WNL1, #x700D72EAA8
; B00:       5F00016B         CMP WNL2, WNL1
; B04:       A1020054         BNE L3
; B08:       0D000014         B L1
; B0C: L0:   4F1300F9         STR R5, [CFP, #32]
; B10:       7A0300F9         STR CFP, [CSP]
; B14:       AAFBFF58         LDR R0, #x700D72EA88            ; '(ZEROP
                                                              ;   CNVRS/RUNTIME::INDEX)
; B18:       4B0080D2         MOVZ R1, #2
; B1C:       ACFBFF58         LDR R2, #x700D72EA90            ; 'CNVRS/RUNTIME::INDEX
; B20:       ED030FAA         MOV R3, R5
; B24:       F6FAFF58         LDR LEXENV, #x700D72EA80        ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; B28:       170180D2         MOVZ NARGS, #8
; B2C:       FA031BAA         MOV CFP, CSP
; B30:       DE9240F8         LDR LR, [LEXENV, #9]
; B34:       C0033FD6         BLR LR
; B38:       4F1340F9         LDR R5, [CFP, #32]
; B3C: L1:   8FFEFFB5         CBNZ R5, L0
; B40:       4A0F40F9         LDR R0, [CFP, #24]
; B44:       4AD141F8         LDR R0, [R0, #29]
; B48: L2:   FB031AAA         MOV CSP, CFP
; B4C:       5A7B40A9         LDP CFP, LR, [CFP]
; B50:       BF0300F1         CMP NULL, #0
; B54:       C0035FD6         RET
; B58: L3:   429145B8         LDR WNL2, [R0, #89]
; B5C:       81FAFF18         LDR WNL1, #x700D72EAAC
; B60:       5F00016B         CMP WNL2, WNL1
; B64:       41010054         BNE L4
; B68:       4A0F40F9         LDR R0, [CFP, #24]
; B6C:       4A5141F8         LDR R0, [R0, #21]
; B70:       40915FF8         LDR NL0, [R0, #-7]
; B74:       1F000FEB         CMP NL0, R5
; B78:       29010054         BLS L5
; B7C:       49050F8B         ADD TMP, R0, R5, LSL #1
; B80:       201140B8         LDR WNL0, [TMP, #1]
; B84:       0AF87FD3         LSL R0, NL0, #1
; B88:       F0FFFF17         B L2
; B8C: L4:   4A0F40F9         LDR R0, [CFP, #24]
; B90:       A04321D4         BRK #2589                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; B94:       2F               BYTE #X2F                       ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; B95:       .ALIGN           4
; B98:       E00120D4         BRK #15                         ; Invalid argument count trap
; B9C: L5:   204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; BA0:       3D               BYTE #X3D                       ; R5
; BA1:       .ALIGN           4
