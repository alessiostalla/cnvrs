; disassembly for CNVRS/RUNTIME::MERGE-CACHE-GET
; Size: 612 bytes. Origin: #x700CE00898                       ; CNVRS/RUNTIME::MERGE-CACHE-GET
; 898:       DF011DEB         CMP R4, NULL
; 89C:       C1000054         BNE L1
; 8A0:       EA031DAA         MOV R0, NULL
; 8A4: L0:   FB031AAA         MOV CSP, CFP
; 8A8:       5A7B40A9         LDP CFP, LR, [CFP]
; 8AC:       BF0300F1         CMP NULL, #0
; 8B0:       C0035FD6         RET
; 8B4: L1:   4A0B40F9         LDR R0, [CFP, #16]
; 8B8:       5F011DEB         CMP R0, NULL
; 8BC:       A0110054         BEQ L19
; 8C0:       4A0B40F9         LDR R0, [CFP, #16]
; 8C4:       410D4092         AND NL1, R0, #15
; 8C8:       3F0C00F1         CMP NL1, #3
; 8CC:       C1100054         BNE L18
; 8D0:       4D5140F8         LDR R3, [R0, #5]
; 8D4:       A25145B8         LDR WNL2, [R3, #85]
; 8D8:       81FCFF18         LDR WNL1, #x700CE00868
; 8DC:       5F00016B         CMP WNL2, WNL1
; 8E0:       21100054         BNE L18
; 8E4:       4A0B40F9         LDR R0, [CFP, #16]
; 8E8:       40D140F8         LDR NL0, [R0, #13]
; 8EC: L2:   4A0F40F9         LDR R0, [CFP, #24]
; 8F0:       5F011DEB         CMP R0, NULL
; 8F4:       400F0054         BEQ L17
; 8F8:       4A0F40F9         LDR R0, [CFP, #24]
; 8FC:       410D4092         AND NL1, R0, #15
; 900:       3F0C00F1         CMP NL1, #3
; 904:       610E0054         BNE L16
; 908:       4D5140F8         LDR R3, [R0, #5]
; 90C:       A25145B8         LDR WNL2, [R3, #85]
; 910:       C1FAFF18         LDR WNL1, #x700CE00868
; 914:       5F00016B         CMP WNL2, WNL1
; 918:       C10D0054         BNE L16
; 91C:       4A0F40F9         LDR R0, [CFP, #24]
; 920:       41D140F8         LDR NL1, [R0, #13]
; 924: L3:   0A0001CA         EOR R0, NL0, NL1
; 928:       7A0300F9         STR CFP, [CSP]
; 92C:       EB030EAA         MOV R1, R4
; 930:       EC031DAA         MOV R2, NULL
; 934:       76F8FF58         LDR LEXENV, #x700CE00840        ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 938:       FA031BAA         MOV CFP, CSP
; 93C:       DE9240F8         LDR LR, [LEXENV, #9]
; 940:       C0033FD6         BLR LR
; 944:       FB0319AA         MOV CSP, OCFP
; 948:       EE030AAA         MOV R4, R0
; 94C: L4:   C10D4092         AND NL1, R4, #15
; 950:       3F1C00F1         CMP NL1, #7
; 954:       C10B0054         BNE L15
; 958:       DF011DEB         CMP R4, NULL
; 95C:       400B0054         BEQ L14
; 960:       CA915FF8         LDR R0, [R4, #-7]
; 964:       410D4092         AND NL1, R0, #15
; 968:       3F1C00F1         CMP NL1, #7
; 96C:       A10A0054         BNE L13
; 970:       4C915FF8         LDR R2, [R0, #-7]
; 974:       4A1140F8         LDR R0, [R0, #1]
; 978:       410D4092         AND NL1, R0, #15
; 97C:       3F1C00F1         CMP NL1, #7
; 980:       E1090054         BNE L12
; 984:       4B915FF8         LDR R1, [R0, #-7]
; 988:       4B1300F9         STR R1, [CFP, #32]
; 98C:       4A1140F8         LDR R0, [R0, #1]
; 990:       410D4092         AND NL1, R0, #15
; 994:       3F1C00F1         CMP NL1, #7
; 998:       01090054         BNE L11
; 99C:       4C1F00F9         STR R2, [CFP, #56]
; 9A0:       4A915FF8         LDR R0, [R0, #-7]
; 9A4:       4A1700F9         STR R0, [CFP, #40]
; 9A8:       CA1140F8         LDR R0, [R4, #1]
; 9AC:       EE030AAA         MOV R4, R0
; 9B0:       4E1B00F9         STR R4, [CFP, #48]
; 9B4:       EA030CAA         MOV R0, R2
; 9B8:       7A0300F9         STR CFP, [CSP]
; 9BC:       4B0B40F9         LDR R1, [CFP, #16]
; 9C0:       56F4FF58         LDR LEXENV, #x700CE00848        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; 9C4:       970080D2         MOVZ NARGS, #4
; 9C8:       FA031BAA         MOV CFP, CSP
; 9CC:       DE9240F8         LDR LR, [LEXENV, #9]
; 9D0:       C0033FD6         BLR LR
; 9D4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 9D8:       4E3343A9         LDP R4, R2, [CFP, #48]
; 9DC:       5F011DEB         CMP R0, NULL
; 9E0:       80000054         BEQ L5
; 9E4:       ABE30091         ADD R1, NULL, #56               ; T
; 9E8:       5F010BEB         CMP R0, R1
; 9EC:       41060054         BNE L10
; 9F0: L5:   5F011DEB         CMP R0, NULL
; 9F4:       C0010054         BEQ L6
; 9F8:       4E3303A9         STP R4, R2, [CFP, #48]
; 9FC:       4A1340F9         LDR R0, [CFP, #32]
; A00:       7A0300F9         STR CFP, [CSP]
; A04:       4B0F40F9         LDR R1, [CFP, #24]
; A08:       16F2FF58         LDR LEXENV, #x700CE00848        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; A0C:       970080D2         MOVZ NARGS, #4
; A10:       FA031BAA         MOV CFP, CSP
; A14:       DE9240F8         LDR LR, [LEXENV, #9]
; A18:       C0033FD6         BLR LR
; A1C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; A20:       4E3343A9         LDP R4, R2, [CFP, #48]
; A24:       5F011DEB         CMP R0, NULL
; A28:       01040054         BNE L8
; A2C: L6:   4E1B00F9         STR R4, [CFP, #48]
; A30:       EA030CAA         MOV R0, R2
; A34:       7A0300F9         STR CFP, [CSP]
; A38:       4B0F40F9         LDR R1, [CFP, #24]
; A3C:       76F0FF58         LDR LEXENV, #x700CE00848        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; A40:       970080D2         MOVZ NARGS, #4
; A44:       FA031BAA         MOV CFP, CSP
; A48:       DE9240F8         LDR LR, [LEXENV, #9]
; A4C:       C0033FD6         BLR LR
; A50:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; A54:       4E1B40F9         LDR R4, [CFP, #48]
; A58:       5F011DEB         CMP R0, NULL
; A5C:       80000054         BEQ L7
; A60:       ABE30091         ADD R1, NULL, #56               ; T
; A64:       5F010BEB         CMP R0, R1
; A68:       41020054         BNE L9
; A6C: L7:   5F011DEB         CMP R0, NULL
; A70:       E0F6FF54         BEQ L4
; A74:       4E1B00F9         STR R4, [CFP, #48]
; A78:       4A1340F9         LDR R0, [CFP, #32]
; A7C:       7A0300F9         STR CFP, [CSP]
; A80:       4B0B40F9         LDR R1, [CFP, #16]
; A84:       36EEFF58         LDR LEXENV, #x700CE00848        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; A88:       970080D2         MOVZ NARGS, #4
; A8C:       FA031BAA         MOV CFP, CSP
; A90:       DE9240F8         LDR LR, [LEXENV, #9]
; A94:       C0033FD6         BLR LR
; A98:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; A9C:       4E1B40F9         LDR R4, [CFP, #48]
; AA0:       5F011DEB         CMP R0, NULL
; AA4:       40F5FF54         BEQ L4
; AA8: L8:   4A1740F9         LDR R0, [CFP, #40]
; AAC:       7EFFFF17         B L0
; AB0: L9:   A05221D4         BRK #2709                       ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; AB4: L10:  A05221D4         BRK #2709                       ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; AB8: L11:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; ABC: L12:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; AC0: L13:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; AC4: L14:  EA031DAA         MOV R0, NULL
; AC8:       77FFFF17         B L0
; ACC: L15:  E0C921D4         BRK #3663                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R4
; AD0: L16:  4A0F40F9         LDR R0, [CFP, #24]
; AD4:       604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; AD8:       2B               BYTE #X2B                       ; #<SB-KERNEL:LAYOUT (ID=389) for CNVRS/RUNTIME:PREDICTION-CONTEXT {700CD54203}>
; AD9:       .ALIGN           4
; ADC: L17:  010080D2         MOVZ NL1, #0
; AE0:       91FFFF17         B L3
; AE4: L18:  4A0B40F9         LDR R0, [CFP, #16]
; AE8:       604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; AEC:       2B               BYTE #X2B                       ; #<SB-KERNEL:LAYOUT (ID=389) for CNVRS/RUNTIME:PREDICTION-CONTEXT {700CD54203}>
; AED:       .ALIGN           4
; AF0: L19:  000080D2         MOVZ NL0, #0
; AF4:       7EFFFF17         B L2
; AF8:       E00120D4         BRK #15                         ; Invalid argument count trap
