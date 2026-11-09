; disassembly for CNVRS/ANTLR-RUNTIME::COMBINE-COMMON-PARENTS
; Size: 464 bytes. Origin: #x700D72FA80                       ; CNVRS/ANTLR-RUNTIME::COMBINE-COMMON-PARENTS
; A80:       4F1B00F9         STR R5, [CFP, #48]
; A84:       7A0300F9         STR CFP, [CSP]
; A88:       56FCFF58         LDR LEXENV, #x700D72FA10        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:MAKE-CONTEXT-CACHE>
; A8C:       170080D2         MOVZ NARGS, #0
; A90:       FA031BAA         MOV CFP, CSP
; A94:       DE9240F8         LDR LR, [LEXENV, #9]
; A98:       C0033FD6         BLR LR
; A9C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; AA0:       4F1B40F9         LDR R5, [CFP, #48]
; AA4:       410D4092         AND NL1, R0, #15
; AA8:       3F0C00F1         CMP NL1, #3
; AAC:       A10C0054         BNE L9
; AB0:       4C5140F8         LDR R2, [R0, #5]
; AB4:       825145B8         LDR WNL2, [R2, #85]
; AB8:       5FFC0131         CMN WNL2, #127
; ABC:       210C0054         BNE L9
; AC0:       4A0B00F9         STR R0, [CFP, #16]
; AC4:       010080D2         MOVZ NL1, #0
; AC8:       E2915FF8         LDR NL2, [R5, #-7]
; ACC: L0:   3F0002EB         CMP NL1, NL2
; AD0:       6A020054         BGE L1
; AD4:       E909018B         ADD TMP, R5, NL1, LSL #2
; AD8:       2B1140F8         LDR R1, [TMP, #1]
; ADC:       21080091         ADD NL1, NL1, #2
; AE0:       7F011DEB         CMP R1, NULL
; AE4:       40FFFF54         BEQ L0
; AE8:       428701A9         STP NL2, NL1, [CFP, #24]
; AEC:       4F1B00F9         STR R5, [CFP, #48]
; AF0:       7A0300F9         STR CFP, [CSP]
; AF4:       4A0B40F9         LDR R0, [CFP, #16]
; AF8:       16F9FF58         LDR LEXENV, #x700D72FA18        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::CONTEXT-CACHE-ADD>
; AFC:       970080D2         MOVZ NARGS, #4
; B00:       FA031BAA         MOV CFP, CSP
; B04:       DE9240F8         LDR LR, [LEXENV, #9]
; B08:       C0033FD6         BLR LR
; B0C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; B10:       4F1B40F9         LDR R5, [CFP, #48]
; B14:       428741A9         LDP NL2, NL1, [CFP, #24]
; B18:       EDFFFF17         B L0
; B1C: L1:   030080D2         MOVZ NL3, #0
; B20:       E0915FF8         LDR NL0, [R5, #-7]
; B24:       400F00F9         STR NL0, [CFP, #24]
; B28:       0E0080D2         MOVZ R4, #0
; B2C:       1F0000F1         CMP NL0, #0
; B30:       CC000054         BGT L3
; B34: L2:   EA030FAA         MOV R0, R5
; B38:       FB031AAA         MOV CSP, CFP
; B3C:       5A7B40A9         LDP CFP, LR, [CFP]
; B40:       BF0300F1         CMP NULL, #0
; B44:       C0035FD6         RET
; B48: L3:   E909038B         ADD TMP, R5, NL3, LSL #2
; B4C:       2D1140F8         LDR R3, [TMP, #1]
; B50:       430080D2         MOVZ NL3, #2
; B54:       36000014         B L7
; B58: L4:   4F3B03A9         STP R5, R4, [CFP, #48]
; B5C:       431700F9         STR NL3, [CFP, #40]
; B60:       7A0300F9         STR CFP, [CSP]
; B64:       4A0B40F9         LDR R0, [CFP, #16]
; B68:       EB030DAA         MOV R1, R3
; B6C:       B6F5FF58         LDR LEXENV, #x700D72FA20        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::CONTEXT-CACHE-GET>
; B70:       970080D2         MOVZ NARGS, #4
; B74:       FA031BAA         MOV CFP, CSP
; B78:       DE9240F8         LDR LR, [LEXENV, #9]
; B7C:       C0033FD6         BLR LR
; B80:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; B84:       431740F9         LDR NL3, [CFP, #40]
; B88:       4F3B43A9         LDP R5, R4, [CFP, #48]
; B8C:       5F011DEB         CMP R0, NULL
; B90:       20010054         BEQ L5
; B94:       410D4092         AND NL1, R0, #15
; B98:       3F0C00F1         CMP NL1, #3
; B9C:       E1040054         BNE L8
; BA0:       4C5140F8         LDR R2, [R0, #5]
; BA4:       825145B8         LDR WNL2, [R2, #85]
; BA8:       81F4FF18         LDR WNL1, #x700D72FA38
; BAC:       5F00016B         CMP WNL2, WNL1
; BB0:       41040054         BNE L8
; BB4: L5:   E0915FF8         LDR NL0, [R5, #-7]
; BB8:       8E040037         TBNZ WR4, #0, L10
; BBC:       1F000EEB         CMP NL0, R4
; BC0:       49040054         BLS L10
; BC4:       EB030EAA         MOV R1, R4
; BC8:       E1090B8B         ADD NL1, R5, R1, LSL #2
; BCC:       21040091         ADD NL1, NL1, #1
; BD0:       29784BD3         UBFM TMP, NL1, #11, #30
; BD4:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; BD8:       2A0000F9         STR R0, [NL1]
; BDC: L6:   400F40F9         LDR NL0, [CFP, #24]
; BE0:       7F0000EB         CMP NL3, NL0
; BE4:       8AFAFF54         BGE L2
; BE8:       4F1B00F9         STR R5, [CFP, #48]
; BEC:       E909038B         ADD TMP, R5, NL3, LSL #2
; BF0:       2D1140F8         LDR R3, [TMP, #1]
; BF4:       4D1300F9         STR R3, [CFP, #32]
; BF8:       60080091         ADD NL0, NL3, #2
; BFC:       E30300AA         MOV NL3, NL0
; C00:       431700F9         STR NL3, [CFP, #40]
; C04:       EA030EAA         MOV R0, R4
; C08:       7A0300F9         STR CFP, [CSP]
; C0C:       4B0080D2         MOVZ R1, #2
; C10:       FA031BAA         MOV CFP, CSP
; C14:       29AA80D2         MOVZ TMP, #1361
; C18:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:TWO-ARG-+
; C1C:       C0033FD6         BLR LR
; C20:       43BF42A9         LDP NL3, R5, [CFP, #40]
; C24:       4D1340F9         LDR R3, [CFP, #32]
; C28:       EE030AAA         MOV R4, R0
; C2C: L7:   BF011DEB         CMP R3, NULL
; C30:       60FDFF54         BEQ L6
; C34:       C9FFFF17         B L4
; C38: L8:   604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; C3C:       2F               BYTE #X2F                       ; '(OR NULL
                                                              ;      CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT)
; C3D:       .ALIGN           4
; C40: L9:   405321D4         BRK #2714                       ; OBJECT-NOT-HASH-TABLE-ERROR
                                                              ; R0
; C44:       E00120D4         BRK #15                         ; Invalid argument count trap
; C48: L10:  20E421D4         BRK #3873                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; C4C:       38               BYTE #X38                       ; R4
; C4D:       .ALIGN           4
