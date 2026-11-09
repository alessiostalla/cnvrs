; disassembly for CNVRS/ANTLR-RUNTIME::CLOSURE-WORK
; Size: 1932 bytes. Origin: #x700AB107D8                      ; CNVRS/ANTLR-RUNTIME::CLOSURE-WORK
; 7D8:       4A0F40F9         LDR R0, [CFP, #24]
; 7DC:       40D140F8         LDR NL0, [R0, #13]
; 7E0:       4BF5FF58         LDR R1, #x700AB10688            ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; 7E4:       61515FB8         LDR WNL1, [R1, #-11]
; 7E8:       AA6A61F8         LDR R0, [THREAD, NL1]
; 7EC:       5F0500B1         CMN R0, #1
; 7F0:       41000054         BNE L0
; 7F4:       6A1140F8         LDR R0, [R1, #1]
; 7F8: L0:   5F2500F1         CMP R0, #9
; 7FC:       40390054         BEQ L52
; 800:       5F011DEB         CMP R0, NULL
; 804:       A0380054         BEQ L51
; 808:       4AD140F8         LDR R0, [R0, #13]
; 80C:       4AD140F8         LDR R0, [R0, #13]
; 810:       41915FF8         LDR NL1, [R0, #-7]
; 814:       3F0000EB         CMP NL1, NL0
; 818:       89380054         BLS L53
; 81C:       4909008B         ADD TMP, R0, NL0, LSL #2
; 820:       2A1140F8         LDR R0, [TMP, #1]
; 824:       4A2700F9         STR R0, [CFP, #72]
; 828:       410D4092         AND NL1, R0, #15
; 82C:       3F0C00F1         CMP NL1, #3
; 830:       01370054         BNE L50
; 834:       4E5140F8         LDR R4, [R0, #5]
; 838:       C25145B8         LDR WNL2, [R4, #85]
; 83C:       61F6FF18         LDR WNL1, #x700AB10708
; 840:       5F00016B         CMP WNL2, WNL1
; 844:       61360054         BNE L50
; 848:       4B5142F8         LDR R1, [R0, #37]
; 84C:       7F011DEB         CMP R1, NULL
; 850:       21310054         BNE L43
; 854: L1:   7A0300F9         STR CFP, [CSP]
; 858:       4BAB41A9         LDP R1, R0, [CFP, #24]
; 85C:       B6EFFF58         LDR LEXENV, #x700AB10650        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:CONFIG-SET-ADD>
; 860:       970080D2         MOVZ NARGS, #4
; 864:       580B00F9         STR NFP, [CFP, #16]
; 868:       FA031BAA         MOV CFP, CSP
; 86C:       DE9240F8         LDR LR, [LEXENV, #9]
; 870:       C0033FD6         BLR LR
; 874:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 878:       580B40F9         LDR NFP, [CFP, #16]
; 87C: L2:   4A2740F9         LDR R0, [CFP, #72]
; 880:       4A5142F8         LDR R0, [R0, #37]
; 884:       4A7F05A9         STP R0, ZR, [CFP, #80]
; 888:       4A2B40F9         LDR R0, [CFP, #80]
; 88C:       5F011DEB         CMP R0, NULL
; 890:       E1000054         BNE L4
; 894: L3:   EA031DAA         MOV R0, NULL
; 898:       1F430091         ADD NSP, NFP, #16
; 89C:       FB031AAA         MOV CSP, CFP
; 8A0:       5A7B40A9         LDP CFP, LR, [CFP]
; 8A4:       BF0300F1         CMP NULL, #0
; 8A8:       C0035FD6         RET
; 8AC: L4:   4A2B40F9         LDR R0, [CFP, #80]
; 8B0:       4A915FF8         LDR R0, [R0, #-7]
; 8B4:       EF030AAA         MOV R5, R0
; 8B8:       4A2B40F9         LDR R0, [CFP, #80]
; 8BC:       4A1140F8         LDR R0, [R0, #1]
; 8C0:       4A2B00F9         STR R0, [CFP, #80]
; 8C4:       56000014         B L11
; 8C8: L5:   4A1B40F9         LDR R0, [CFP, #48]
; 8CC:       5F011DEB         CMP R0, NULL
; 8D0:       212B0054         BNE L41
; 8D4: L6:   EA031DAA         MOV R0, NULL
; 8D8: L7:   4F3B00F9         STR R5, [CFP, #112]
; 8DC:       4A3300F9         STR R0, [CFP, #96]
; 8E0:       EB030FAA         MOV R1, R5
; 8E4:       000340F9         LDR NL0, [NFP]
; 8E8:       1F0000F1         CMP NL0, #0
; 8EC:       AAE30091         ADD R0, NULL, #56               ; T
; 8F0:       4D019D9A         CSEL R3, R0, NULL, EQ
; 8F4:       E0031BAA         MOV NL0, CSP
; 8F8:       7A0703F8         STR CFP, [CSP], #48
; 8FC:       4A0F40F9         LDR R0, [CFP, #24]
; 900:       4C3340F9         LDR R2, [CFP, #96]
; 904:       4E1F40F9         LDR R4, [CFP, #56]
; 908:       0E1000F9         STR R4, [NL0, #32]
; 90C:       4E2340F9         LDR R4, [CFP, #64]
; 910:       0E1400F9         STR R4, [NL0, #40]
; 914:       36EAFF58         LDR LEXENV, #x700AB10658        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::GET-EPSILON-TARGET>
; 918:       970180D2         MOVZ NARGS, #12
; 91C:       580B00F9         STR NFP, [CFP, #16]
; 920:       FA0300AA         MOV CFP, NL0
; 924:       DE9240F8         LDR LR, [LEXENV, #9]
; 928:       C0033FD6         BLR LR
; 92C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 930:       580B40F9         LDR NFP, [CFP, #16]
; 934:       4F3B40F9         LDR R5, [CFP, #112]
; 938:       EC030AAA         MOV R2, R0
; 93C:       030340F9         LDR NL3, [NFP]
; 940:       9F011DEB         CMP R2, NULL
; 944:       A0030054         BEQ L10
; 948:       4A2740F9         LDR R0, [CFP, #72]
; 94C:       4A5141F8         LDR R0, [R0, #21]
; 950:       0BEAFF58         LDR R1, #x700AB10690            ; :RULE-STOP
; 954:       5F010BEB         CMP R0, R1
; 958:       A0110054         BEQ L21
; 95C:       E10D4092         AND NL1, R5, #15
; 960:       3F0C00F1         CMP NL1, #3
; 964:       01110054         BNE L20
; 968:       EE5140F8         LDR R4, [R5, #5]
; 96C:       C25145B8         LDR WNL2, [R4, #85]
; 970:       E1ECFF18         LDR WNL1, #x700AB1070C
; 974:       5F00016B         CMP WNL2, WNL1
; 978:       61100054         BNE L20
; 97C:       EAD140F8         LDR R0, [R5, #13]
; 980:       CBE8FF58         LDR R1, #x700AB10698            ; :EPSILON
; 984:       5F010BEB         CMP R0, R1
; 988:       80000054         BEQ L8
; 98C:       ABE8FF58         LDR R1, #x700AB106A0            ; :RULE
; 990:       5F010BEB         CMP R0, R1
; 994:       610B0054         BNE L17
; 998: L8:   EAD140F8         LDR R0, [R5, #13]
; 99C:       2BE8FF58         LDR R1, #x700AB106A0            ; :RULE
; 9A0:       5F010BEB         CMP R0, R1
; 9A4:       61000054         BNE L9
; 9A8:       000340F9         LDR NL0, [NFP]
; 9AC:       200AF8B6         TBZ NL0, #63, L16
; 9B0: L9:   9F011DEB         CMP R2, NULL
; 9B4:       A1050054         BNE L13
; 9B8: L10:  4A2B40F9         LDR R0, [CFP, #80]
; 9BC:       410D4092         AND NL1, R0, #15
; 9C0:       3F1C00F1         CMP NL1, #7
; 9C4:       E1040054         BNE L12
; 9C8:       4A2B40F9         LDR R0, [CFP, #80]
; 9CC:       5F011DEB         CMP R0, NULL
; 9D0:       20F6FF54         BEQ L3
; 9D4:       4A2B40F9         LDR R0, [CFP, #80]
; 9D8:       4A915FF8         LDR R0, [R0, #-7]
; 9DC:       EF030AAA         MOV R5, R0
; 9E0:       4F3B00F9         STR R5, [CFP, #112]
; 9E4:       4A2B40F9         LDR R0, [CFP, #80]
; 9E8:       4A1140F8         LDR R0, [R0, #1]
; 9EC:       4A2B00F9         STR R0, [CFP, #80]
; 9F0:       4A2F40F9         LDR R0, [CFP, #88]
; 9F4:       7A0300F9         STR CFP, [CSP]
; 9F8:       4B0080D2         MOVZ R1, #2
; 9FC:       580B00F9         STR NFP, [CFP, #16]
; A00:       FA031BAA         MOV CFP, CSP
; A04:       29AA80D2         MOVZ TMP, #1361
; A08:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:TWO-ARG-+
; A0C:       C0033FD6         BLR LR
; A10:       580B40F9         LDR NFP, [CFP, #16]
; A14:       4F3B40F9         LDR R5, [CFP, #112]
; A18:       4A2F00F9         STR R0, [CFP, #88]
; A1C: L11:  4A2F40F9         LDR R0, [CFP, #88]
; A20:       4AF5FFB5         CBNZ R0, L5
; A24:       4F3B00F9         STR R5, [CFP, #112]
; A28:       7A0300F9         STR CFP, [CSP]
; A2C:       4A0F40F9         LDR R0, [CFP, #24]
; A30:       96E1FF58         LDR LEXENV, #x700AB10660        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::CAN-DROP-LOOP-ENTRY-EDGE-IN-LEFT-RECURSIVE-RULE>
; A34:       570080D2         MOVZ NARGS, #2
; A38:       580B00F9         STR NFP, [CFP, #16]
; A3C:       FA031BAA         MOV CFP, CSP
; A40:       DE9240F8         LDR LR, [LEXENV, #9]
; A44:       C0033FD6         BLR LR
; A48:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; A4C:       580B40F9         LDR NFP, [CFP, #16]
; A50:       4F3B40F9         LDR R5, [CFP, #112]
; A54:       5F011DEB         CMP R0, NULL
; A58:       80F3FF54         BEQ L5
; A5C:       D7FFFF17         B L10
; A60: L12:  4A2B40F9         LDR R0, [CFP, #80]
; A64:       E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; A68: L13:  EA030CAA         MOV R0, R2
; A6C:       6E0003AB         ADDS R4, NL3, NL3
; A70:       E7010054         BVC L15
; A74:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; A78:       A97A47A9         LDP TMP, LR, [THREAD, #112]     ; mixed-tlab.{free-pointer, end-addr}
; A7C:       2E410091         ADD R4, TMP, #16
; A80:       DF011EEB         CMP R4, LR
; A84:       68250054         BHI L54
; A88:       AE3A00F9         STR R4, [THREAD, #112]          ; mixed-tlab
; A8C: L14:  2E3D0091         ADD R4, TMP, #15
; A90:       3E2280D2         MOVZ LR, #273
; A94:       3E0D00A9         STP LR, NL3, [TMP]
; A98:       BF3A03D5         DMB ISHST
; A9C:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; AA0:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; AA4:       5E0000B4         CBZ LR, L15
; AA8:       200120D4         BRK #9                          ; Pending interrupt trap
; AAC: L15:  E0031BAA         MOV NL0, CSP
; AB0:       7A8703F8         STR CFP, [CSP], #56
; AB4:       4B3342A9         LDP R1, R2, [CFP, #32]
; AB8:       4D3340F9         LDR R3, [CFP, #96]
; ABC:       4F1F40F9         LDR R5, [CFP, #56]
; AC0:       0F3802A9         STP R5, R4, [NL0, #32]
; AC4:       4E2340F9         LDR R4, [CFP, #64]
; AC8:       0E1800F9         STR R4, [NL0, #48]
; ACC:       F6DCFF58         LDR LEXENV, #x700AB10668        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::CLOSURE-CHECKING-STOP-STATE>
; AD0:       D70180D2         MOVZ NARGS, #14
; AD4:       580B00F9         STR NFP, [CFP, #16]
; AD8:       FA0300AA         MOV CFP, NL0
; ADC:       DE9240F8         LDR LR, [LEXENV, #9]
; AE0:       C0033FD6         BLR LR
; AE4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; AE8:       580B40F9         LDR NFP, [CFP, #16]
; AEC:       B3FFFF17         B L10
; AF0: L16:  000340F9         LDR NL0, [NFP]
; AF4:       00040091         ADD NL0, NL0, #1
; AF8:       E30300AA         MOV NL3, NL0
; AFC:       ADFFFF17         B L9
; B00: L17:  4BDDFF58         LDR R1, #x700AB106A8            ; :PREDICATE
; B04:       5F010BEB         CMP R0, R1
; B08:       80F4FF54         BEQ L8
; B0C:       2BDDFF58         LDR R1, #x700AB106B0            ; :ACTION
; B10:       5F010BEB         CMP R0, R1
; B14:       20F4FF54         BEQ L8
; B18:       0BDDFF58         LDR R1, #x700AB106B8            ; :PRECEDENCE
; B1C:       5F010BEB         CMP R0, R1
; B20:       C0F3FF54         BEQ L8
; B24:       4CBF06A9         STP R2, R5, [CFP, #104]
; B28:       030700F9         STR NL3, [NFP, #8]
; B2C:       EB030CAA         MOV R1, R2
; B30:       7A0300F9         STR CFP, [CSP]
; B34:       4A1740F9         LDR R0, [CFP, #40]
; B38:       D6D9FF58         LDR LEXENV, #x700AB10670        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::BUSY-ADD>
; B3C:       970080D2         MOVZ NARGS, #4
; B40:       580B00F9         STR NFP, [CFP, #16]
; B44:       FA031BAA         MOV CFP, CSP
; B48:       DE9240F8         LDR LR, [LEXENV, #9]
; B4C:       C0033FD6         BLR LR
; B50:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; B54:       580B40F9         LDR NFP, [CFP, #16]
; B58:       030740F9         LDR NL3, [NFP, #8]
; B5C:       4CBF46A9         LDP R2, R5, [CFP, #104]
; B60:       5F011DEB         CMP R0, NULL
; B64:       80000054         BEQ L18
; B68:       ABE30091         ADD R1, NULL, #56               ; T
; B6C:       5F010BEB         CMP R0, R1
; B70:       81000054         BNE L19
; B74: L18:  5F011DEB         CMP R0, NULL
; B78:       AC038C9A         CSEL R2, NULL, R2, EQ
; B7C:       87FFFF17         B L8
; B80: L19:  A05221D4         BRK #2709                       ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; B84: L20:  60E321D4         BRK #3867                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; B88:       5B               BYTE #X5B                       ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA2D0D3}>
; B89:       .ALIGN           4
; B8C: L21:  EBD9FF58         LDR R1, #x700AB106C8            ; 'CNVRS/ANTLR-RUNTIME::*CURRENT-DFA*
; B90:       61515FB8         LDR WNL1, [R1, #-11]
; B94:       AA6A61F8         LDR R0, [THREAD, NL1]
; B98:       5F0500B1         CMN R0, #1
; B9C:       41000054         BNE L22
; BA0:       6A1140F8         LDR R0, [R1, #1]
; BA4: L22:  5F2500F1         CMP R0, #9
; BA8:       C01C0054         BEQ L55
; BAC:       5F011DEB         CMP R0, NULL
; BB0:       E1050054         BNE L28
; BB4: L23:  810D4092         AND NL1, R2, #15
; BB8:       3F0C00F1         CMP NL1, #3
; BBC:       41050054         BNE L27
; BC0:       8E5140F8         LDR R4, [R2, #5]
; BC4:       C25145B8         LDR WNL2, [R4, #85]
; BC8:       C1D9FF18         LDR WNL1, #x700AB10700
; BCC:       5F00016B         CMP WNL2, WNL1
; BD0:       A1040054         BNE L27
; BD4:       80D142F8         LDR NL0, [R2, #45]
; BD8:       00FC4193         ASR NL0, NL0, #1
; BDC:       00040091         ADD NL0, NL0, #1
; BE0:       1F0000AB         CMN NL0, NL0
; BE4:       E6030054         BVS L26
; BE8:       4C3700F9         STR R2, [CFP, #104]
; BEC:       00F87FD3         LSL NL0, NL0, #1
; BF0:       80D102F8         STR NL0, [R2, #45]
; BF4:       EB030CAA         MOV R1, R2
; BF8:       7A0300F9         STR CFP, [CSP]
; BFC:       4A1740F9         LDR R0, [CFP, #40]
; C00:       96D3FF58         LDR LEXENV, #x700AB10670        ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::BUSY-ADD>
; C04:       970080D2         MOVZ NARGS, #4
; C08:       580B00F9         STR NFP, [CFP, #16]
; C0C:       FA031BAA         MOV CFP, CSP
; C10:       DE9240F8         LDR LR, [LEXENV, #9]
; C14:       C0033FD6         BLR LR
; C18:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; C1C:       580B40F9         LDR NFP, [CFP, #16]
; C20:       4C3740F9         LDR R2, [CFP, #104]
; C24:       5F011DEB         CMP R0, NULL
; C28:       80000054         BEQ L24
; C2C:       ABE30091         ADD R1, NULL, #56               ; T
; C30:       5F010BEB         CMP R0, R1
; C34:       41010054         BNE L25
; C38: L24:  5F011DEB         CMP R0, NULL
; C3C:       AC038C9A         CSEL R2, NULL, R2, EQ
; C40:       4A1340F9         LDR R0, [CFP, #32]
; C44:       ABE30091         ADD R1, NULL, #56               ; T
; C48:       4BD103F8         STR R1, [R0, #61]
; C4C:       000340F9         LDR NL0, [NFP]
; C50:       000400D1         SUB NL0, NL0, #1
; C54:       E30300AA         MOV NL3, NL0
; C58:       56FFFF17         B L9
; C5C: L25:  A05221D4         BRK #2709                       ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; C60: L26:  A00A28D4         BRK #16469                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; C64: L27:  608321D4         BRK #3099                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; C68:       3B               BYTE #X3B                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA36813}>
; C69:       .ALIGN           4
; C6C: L28:  EBD2FF58         LDR R1, #x700AB106C8            ; 'CNVRS/ANTLR-RUNTIME::*CURRENT-DFA*
; C70:       61515FB8         LDR WNL1, [R1, #-11]
; C74:       AA6A61F8         LDR R0, [THREAD, NL1]
; C78:       5F0500B1         CMN R0, #1
; C7C:       41000054         BNE L29
; C80:       6A1140F8         LDR R0, [R1, #1]
; C84: L29:  5F2500F1         CMP R0, #9
; C88:       E0150054         BEQ L56
; C8C:       5F011DEB         CMP R0, NULL
; C90:       E00C0054         BEQ L40
; C94:       405141F8         LDR NL0, [R0, #21]
; C98:       8BCFFF58         LDR R1, #x700AB10688            ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; C9C:       61515FB8         LDR WNL1, [R1, #-11]
; CA0:       AA6A61F8         LDR R0, [THREAD, NL1]
; CA4:       5F0500B1         CMN R0, #1
; CA8:       41000054         BNE L30
; CAC:       6A1140F8         LDR R0, [R1, #1]
; CB0: L30:  5F2500F1         CMP R0, #9
; CB4:       A0140054         BEQ L57
; CB8:       5F011DEB         CMP R0, NULL
; CBC:       400B0054         BEQ L39
; CC0:       4AD140F8         LDR R0, [R0, #13]
; CC4:       4AD140F8         LDR R0, [R0, #13]
; CC8:       41915FF8         LDR NL1, [R0, #-7]
; CCC:       3F0000EB         CMP NL1, NL0
; CD0:       E9130054         BLS L58
; CD4:       4909008B         ADD TMP, R0, NL0, LSL #2
; CD8:       2A1140F8         LDR R0, [TMP, #1]
; CDC:       410D4092         AND NL1, R0, #15
; CE0:       3F0C00F1         CMP NL1, #3
; CE4:       C1090054         BNE L38
; CE8:       4E5140F8         LDR R4, [R0, #5]
; CEC:       C25145B8         LDR WNL2, [R4, #85]
; CF0:       C1D0FF18         LDR WNL1, #x700AB10708
; CF4:       5F00016B         CMP WNL2, WNL1
; CF8:       21090054         BNE L38
; CFC:       4A5143F8         LDR R0, [R0, #53]
; D00:       5F011DEB         CMP R0, NULL
; D04:       80F5FF54         BEQ L23
; D08:       E10D4092         AND NL1, R5, #15
; D0C:       3F0C00F1         CMP NL1, #3
; D10:       21080054         BNE L37
; D14:       EE5140F8         LDR R4, [R5, #5]
; D18:       C25145B8         LDR WNL2, [R4, #85]
; D1C:       81CFFF18         LDR WNL1, #x700AB1070C
; D20:       5F00016B         CMP WNL2, WNL1
; D24:       81070054         BNE L37
; D28:       E3D142F8         LDR NL3, [R5, #45]
; D2C:       EBCCFF58         LDR R1, #x700AB106C8            ; 'CNVRS/ANTLR-RUNTIME::*CURRENT-DFA*
; D30:       61515FB8         LDR WNL1, [R1, #-11]
; D34:       AA6A61F8         LDR R0, [THREAD, NL1]
; D38:       5F0500B1         CMN R0, #1
; D3C:       41000054         BNE L31
; D40:       6A1140F8         LDR R0, [R1, #1]
; D44: L31:  5F2500F1         CMP R0, #9
; D48:       60100054         BEQ L59
; D4C:       5F011DEB         CMP R0, NULL
; D50:       E0050054         BEQ L36
; D54:       405141F8         LDR NL0, [R0, #21]
; D58:       8BC9FF58         LDR R1, #x700AB10688            ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; D5C:       61515FB8         LDR WNL1, [R1, #-11]
; D60:       AA6A61F8         LDR R0, [THREAD, NL1]
; D64:       5F0500B1         CMN R0, #1
; D68:       41000054         BNE L32
; D6C:       6A1140F8         LDR R0, [R1, #1]
; D70: L32:  5F2500F1         CMP R0, #9
; D74:       200F0054         BEQ L60
; D78:       5F011DEB         CMP R0, NULL
; D7C:       40040054         BEQ L35
; D80:       4AD140F8         LDR R0, [R0, #13]
; D84:       4AD140F8         LDR R0, [R0, #13]
; D88:       41915FF8         LDR NL1, [R0, #-7]
; D8C:       3F0000EB         CMP NL1, NL0
; D90:       690E0054         BLS L61
; D94:       4909008B         ADD TMP, R0, NL0, LSL #2
; D98:       2A1140F8         LDR R0, [TMP, #1]
; D9C:       410D4092         AND NL1, R0, #15
; DA0:       3F0C00F1         CMP NL1, #3
; DA4:       C1020054         BNE L34
; DA8:       4E5140F8         LDR R4, [R0, #5]
; DAC:       C25145B8         LDR WNL2, [R4, #85]
; DB0:       C1CAFF18         LDR WNL1, #x700AB10708
; DB4:       5F00016B         CMP WNL2, WNL1
; DB8:       21020054         BNE L34
; DBC:       40D141F8         LDR NL0, [R0, #29]
; DC0:       1F0003EB         CMP NL0, NL3
; DC4:       81EFFF54         BNE L23
; DC8:       810D4092         AND NL1, R2, #15
; DCC:       3F0C00F1         CMP NL1, #3
; DD0:       21010054         BNE L33
; DD4:       8E5140F8         LDR R4, [R2, #5]
; DD8:       C25145B8         LDR WNL2, [R4, #85]
; DDC:       21C9FF18         LDR WNL1, #x700AB10700
; DE0:       5F00016B         CMP WNL2, WNL1
; DE4:       81000054         BNE L33
; DE8:       AAE30091         ADD R0, NULL, #56               ; T
; DEC:       8A5103F8         STR R0, [R2, #53]
; DF0:       71FFFF17         B L23
; DF4: L33:  608321D4         BRK #3099                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; DF8:       3B               BYTE #X3B                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA36813}>
; DF9:       .ALIGN           4
; DFC: L34:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; E00:       63               BYTE #X63                       ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA20B83}>
; E01:       .ALIGN           4
; E04: L35:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; E08:       67               BYTE #X67                       ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AAD1EE3}>
; E09:       .ALIGN           4
; E0C: L36:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; E10:       6B               BYTE #X6B                       ; #<SB-KERNEL:LAYOUT (ID=398) for CNVRS/ANTLR-RUNTIME:DFA {700AAC94A3}>
; E11:       .ALIGN           4
; E14: L37:  60E321D4         BRK #3867                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; E18:       5B               BYTE #X5B                       ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA2D0D3}>
; E19:       .ALIGN           4
; E1C: L38:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; E20:       63               BYTE #X63                       ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA20B83}>
; E21:       .ALIGN           4
; E24: L39:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; E28:       67               BYTE #X67                       ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AAD1EE3}>
; E29:       .ALIGN           4
; E2C: L40:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; E30:       6B               BYTE #X6B                       ; #<SB-KERNEL:LAYOUT (ID=398) for CNVRS/ANTLR-RUNTIME:DFA {700AAC94A3}>
; E31:       .ALIGN           4
; E34: L41:  E10D4092         AND NL1, R5, #15
; E38:       3F0C00F1         CMP NL1, #3
; E3C:       81010054         BNE L42
; E40:       EE5140F8         LDR R4, [R5, #5]
; E44:       C25145B8         LDR WNL2, [R4, #85]
; E48:       21C6FF18         LDR WNL1, #x700AB1070C
; E4C:       5F00016B         CMP WNL2, WNL1
; E50:       E1000054         BNE L42
; E54:       EAD140F8         LDR R0, [R5, #13]
; E58:       CBC2FF58         LDR R1, #x700AB106B0            ; :ACTION
; E5C:       5F010BEB         CMP R0, R1
; E60:       A0D3FF54         BEQ L6
; E64:       AAE30091         ADD R0, NULL, #56               ; T
; E68:       9CFEFF17         B L7
; E6C: L42:  60E321D4         BRK #3867                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; E70:       5B               BYTE #X5B                       ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA2D0D3}>
; E71:       .ALIGN           4
; E74: L43:  4B5142F8         LDR R1, [R0, #37]
; E78:       16000014         B L46
; E7C: L44:  6A915FF8         LDR R0, [R1, #-7]
; E80:       410D4092         AND NL1, R0, #15
; E84:       3F0C00F1         CMP NL1, #3
; E88:       01040054         BNE L49
; E8C:       4E5140F8         LDR R4, [R0, #5]
; E90:       C25145B8         LDR WNL2, [R4, #85]
; E94:       C1C3FF18         LDR WNL1, #x700AB1070C
; E98:       5F00016B         CMP WNL2, WNL1
; E9C:       61030054         BNE L49
; EA0:       4AD140F8         LDR R0, [R0, #13]
; EA4:       ACBFFF58         LDR R2, #x700AB10698            ; :EPSILON
; EA8:       5F010CEB         CMP R0, R2
; EAC:       80000054         BEQ L45
; EB0:       8CBFFF58         LDR R2, #x700AB106A0            ; :RULE
; EB4:       5F010CEB         CMP R0, R2
; EB8:       41010054         BNE L48
; EBC: L45:  6A1140F8         LDR R0, [R1, #1]
; EC0:       410D4092         AND NL1, R0, #15
; EC4:       3F1C00F1         CMP NL1, #7
; EC8:       A1000054         BNE L47
; ECC:       EB030AAA         MOV R1, R0
; ED0: L46:  7F011DEB         CMP R1, NULL
; ED4:       40CDFF54         BEQ L2
; ED8:       E9FFFF17         B L44
; EDC: L47:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; EE0: L48:  4CBEFF58         LDR R2, #x700AB106A8            ; :PREDICATE
; EE4:       5F010CEB         CMP R0, R2
; EE8:       A0FEFF54         BEQ L45
; EEC:       2CBEFF58         LDR R2, #x700AB106B0            ; :ACTION
; EF0:       5F010CEB         CMP R0, R2
; EF4:       40FEFF54         BEQ L45
; EF8:       0CBEFF58         LDR R2, #x700AB106B8            ; :PRECEDENCE
; EFC:       5F010CEB         CMP R0, R2
; F00:       E0FDFF54         BEQ L45
; F04:       54FEFF17         B L1
; F08: L49:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; F0C:       5B               BYTE #X5B                       ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA2D0D3}>
; F0D:       .ALIGN           4
; F10: L50:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; F14:       63               BYTE #X63                       ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA20B83}>
; F15:       .ALIGN           4
; F18: L51:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; F1C:       67               BYTE #X67                       ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AAD1EE3}>
; F1D:       .ALIGN           4
; F20:       E00120D4         BRK #15                         ; Invalid argument count trap
; F24: L52:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; F28: L53:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; F2C:       01               BYTE #X01                       ; NL0
; F2D:       .ALIGN           4
; F30: L54:  090280D2         MOVZ TMP, #16
; F34:       2EBEFF58         LDR R4, #x700AB106F8            ; SB-VM::ALLOC-TRAMP
; F38:       C0013FD6         BLR R4
; F3C:       D4FEFF17         B L14
; F40: L55:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; F44: L56:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; F48: L57:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; F4C: L58:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; F50:       01               BYTE #X01                       ; NL0
; F51:       .ALIGN           4
; F54: L59:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; F58: L60:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; F5C: L61:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; F60:       01               BYTE #X01                       ; NL0
; F61:       .ALIGN           4
