; disassembly for CNVRS/RUNTIME::CLOSURE-WORK
; Size: 3264 bytes. Origin: #x70086D786C                      ; CNVRS/RUNTIME::CLOSURE-WORK
; 786C:       20D240F8         LDR NL0, [R7, #13]
; 7870:       8BF2FF58         LDR R1, #x70086D76C0           ; 'CNVRS/RUNTIME::*SIMULATOR*
; 7874:       61515FB8         LDR WNL1, [R1, #-11]
; 7878:       AA6A61F8         LDR R0, [THREAD, NL1]
; 787C:       5F0500B1         CMN R0, #1
; 7880:       41000054         BNE L0
; 7884:       6A1140F8         LDR R0, [R1, #1]
; 7888: L0:   5F2500F1         CMP R0, #9
; 788C:       20620054         BEQ L84
; 7890:       5F011DEB         CMP R0, NULL
; 7894:       80610054         BEQ L83
; 7898:       4AD140F8         LDR R0, [R0, #13]
; 789C:       4AD140F8         LDR R0, [R0, #13]
; 78A0:       41915FF8         LDR NL1, [R0, #-7]
; 78A4:       3F0000EB         CMP NL1, NL0
; 78A8:       69610054         BLS L85
; 78AC:       4909008B         ADD TMP, R0, NL0, LSL #2
; 78B0:       2B1140F8         LDR R1, [TMP, #1]
; 78B4:       AAF0FF58         LDR R0, #x70086D76C8           ; 'CNVRS/RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; 78B8:       41515FB8         LDR WNL1, [R0, #-11]
; 78BC:       AC6A61F8         LDR R2, [THREAD, NL1]
; 78C0:       9F0500B1         CMN R2, #1
; 78C4:       41000054         BNE L1
; 78C8:       4C1140F8         LDR R2, [R0, #1]
; 78CC: L1:   9F2500F1         CMP R2, #9
; 78D0:       60600054         BEQ L86
; 78D4:       9F011DEB         CMP R2, NULL
; 78D8:       215E0054         BNE L81
; 78DC: L2:   693F0091         ADD TMP, CSP, #15
; 78E0:       29ED7C92         AND TMP, TMP, #18446744073709551600
; 78E4:       3B010191         ADD CSP, TMP, #64
; 78E8:       330D0091         ADD R9, TMP, #3
; 78EC:       3E8783D2         MOVZ LR, #7225
; 78F0:       7ED21FF8         STR LR, [R9, #-3]
; 78F4:       EAEEFF58         LDR R0, #x70086D76D0           ; #<SB-KERNEL:LAYOUT (ID=397) for CNVRS/RUNTIME::TRANSIENT-ATN-CONFIG {7008649F13}>
; 78F8:       6A5200F8         STR R0, [R9, #5]
; 78FC:       7FD200F8         STR ZR, [R9, #13]
; 7900:       400080D2         MOVZ NL0, #2
; 7904:       605201F8         STR NL0, [R9, #21]
; 7908:       6CD201F8         STR R2, [R9, #29]
; 790C:       AAE30091         ADD R0, NULL, #56              ; T
; 7910:       6A5202F8         STR R0, [R9, #37]
; 7914:       7FD202F8         STR ZR, [R9, #45]
; 7918:       7D5203F8         STR NULL, [R9, #53]
; 791C:       4B2300F9         STR R1, [CFP, #64]
; 7920:       610D4092         AND NL1, R1, #15
; 7924:       3F0C00F1         CMP NL1, #3
; 7928:       615B0054         BNE L80
; 792C:       6E5140F8         LDR R4, [R1, #5]
; 7930:       C25145B8         LDR WNL2, [R4, #85]
; 7934:       E1F2FF18         LDR WNL1, #x70086D7790
; 7938:       5F00016B         CMP WNL2, WNL1
; 793C:       C15A0054         BNE L80
; 7940:       6A5142F8         LDR R0, [R1, #37]
; 7944:       5F011DEB         CMP R0, NULL
; 7948:       81550054         BNE L73
; 794C: L3:   533F00F9         STR R9, [CFP, #120]
; 7950:       EB0311AA         MOV R1, R7
; 7954:       7A0300F9         STR CFP, [CSP]
; 7958:       4A0F40F9         LDR R0, [CFP, #24]
; 795C:       B6E8FF58         LDR LEXENV, #x70086D7670       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONFIG-SET-ADD>
; 7960:       970080D2         MOVZ NARGS, #4
; 7964:       580B00F9         STR NFP, [CFP, #16]
; 7968:       FA031BAA         MOV CFP, CSP
; 796C:       DE9240F8         LDR LR, [LEXENV, #9]
; 7970:       C0033FD6         BLR LR
; 7974:       AB138B9A         CSEL R1, NULL, R1, NE
; 7978:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 797C:       580B40F9         LDR NFP, [CFP, #16]
; 7980:       533F40F9         LDR R9, [CFP, #120]
; 7984:       610D4092         AND NL1, R1, #15
; 7988:       3F0C00F1         CMP NL1, #3
; 798C:       21530054         BNE L72
; 7990:       6E5140F8         LDR R4, [R1, #5]
; 7994:       C25145B8         LDR WNL2, [R4, #85]
; 7998:       81EFFF18         LDR WNL1, #x70086D7788
; 799C:       5F00016B         CMP WNL2, WNL1
; 79A0:       81520054         BNE L72
; 79A4:       F1030BAA         MOV R7, R1
; 79A8: L4:   4A2340F9         LDR R0, [CFP, #64]
; 79AC:       4A5142F8         LDR R0, [R0, #37]
; 79B0:       4AFF04A9         STP R0, ZR, [CFP, #72]
; 79B4:       4A2740F9         LDR R0, [CFP, #72]
; 79B8:       5F011DEB         CMP R0, NULL
; 79BC:       E1000054         BNE L6
; 79C0: L5:   EA031DAA         MOV R0, NULL
; 79C4:       1F430091         ADD NSP, NFP, #16
; 79C8:       FB031AAA         MOV CSP, CFP
; 79CC:       5A7B40A9         LDP CFP, LR, [CFP]
; 79D0:       BF0300F1         CMP NULL, #0
; 79D4:       C0035FD6         RET
; 79D8: L6:   4A2740F9         LDR R0, [CFP, #72]
; 79DC:       4A915FF8         LDR R0, [R0, #-7]
; 79E0:       ED030AAA         MOV R3, R0
; 79E4:       4A2740F9         LDR R0, [CFP, #72]
; 79E8:       4A1140F8         LDR R0, [R0, #1]
; 79EC:       4A2700F9         STR R0, [CFP, #72]
; 79F0:       56000014         B L14
; 79F4: L7:   513700F9         STR R7, [CFP, #104]
; 79F8:       533F00F9         STR R9, [CFP, #120]
; 79FC:       4D3300F9         STR R3, [CFP, #96]
; 7A00:       EA0311AA         MOV R0, R7
; 7A04:       7A0300F9         STR CFP, [CSP]
; 7A08:       96E3FF58         LDR LEXENV, #x70086D7678       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CAN-DROP-LOOP-ENTRY-EDGE-IN-LEFT-RECURSIVE-RULE>
; 7A0C:       570080D2         MOVZ NARGS, #2
; 7A10:       580B00F9         STR NFP, [CFP, #16]
; 7A14:       FA031BAA         MOV CFP, CSP
; 7A18:       DE9240F8         LDR LR, [LEXENV, #9]
; 7A1C:       C0033FD6         BLR LR
; 7A20:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 7A24:       580B40F9         LDR NFP, [CFP, #16]
; 7A28:       4D3340F9         LDR R3, [CFP, #96]
; 7A2C:       533F40F9         LDR R9, [CFP, #120]
; 7A30:       513740F9         LDR R7, [CFP, #104]
; 7A34:       5F011DEB         CMP R0, NULL
; 7A38:       C1050054         BNE L13
; 7A3C: L8:   4A1740F9         LDR R0, [CFP, #40]
; 7A40:       5F011DEB         CMP R0, NULL
; 7A44:       614B0054         BNE L70
; 7A48: L9:   EB031DAA         MOV R1, NULL
; 7A4C: L10:  4B2F00F9         STR R1, [CFP, #88]
; 7A50:       000340F9         LDR NL0, [NFP]
; 7A54:       1F0000F1         CMP NL0, #0
; 7A58:       AAE30091         ADD R0, NULL, #56              ; T
; 7A5C:       56019D9A         CSEL LEXENV, R0, NULL, EQ
; 7A60:       A10D4092         AND NL1, R3, #15
; 7A64:       3F0C00F1         CMP NL1, #3
; 7A68:       014A0054         BNE L69
; 7A6C:       AE5140F8         LDR R4, [R3, #5]
; 7A70:       C25145B8         LDR WNL2, [R4, #85]
; 7A74:       01E9FF18         LDR WNL1, #x70086D7794
; 7A78:       5F00016B         CMP WNL2, WNL1
; 7A7C:       61490054         BNE L69
; 7A80:       A35141F8         LDR NL3, [R3, #21]
; 7A84:       AAD140F8         LDR R0, [R3, #13]
; 7A88:       8CE2FF58         LDR R2, #x70086D76D8           ; :RULE
; 7A8C:       5F010CEB         CMP R0, R2
; 7A90:       60430054         BEQ L66
; 7A94:       6CE2FF58         LDR R2, #x70086D76E0           ; :EPSILON
; 7A98:       5F010CEB         CMP R0, R2
; 7A9C:       C1220054         BNE L39
; 7AA0: L11:  2AD241F8         LDR R0, [R7, #29]
; 7AA4:       2B5242F8         LDR R1, [R7, #37]
; 7AA8:       63D200F8         STR NL3, [R9, #13]
; 7AAC:       205241F8         LDR NL0, [R7, #21]
; 7AB0:       69764BD3         UBFM TMP, R9, #11, #29
; 7AB4:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 7AB8:       605201F8         STR NL0, [R9, #21]
; 7ABC:       6AD201F8         STR R0, [R9, #29]
; 7AC0:       6B5202F8         STR R1, [R9, #37]
; 7AC4:       20D242F8         LDR NL0, [R7, #45]
; 7AC8:       60D202F8         STR NL0, [R9, #45]
; 7ACC:       2A5243F8         LDR R0, [R7, #53]
; 7AD0:       69764BD3         UBFM TMP, R9, #11, #29
; 7AD4:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 7AD8:       6A5203F8         STR R0, [R9, #53]
; 7ADC:       EA0313AA         MOV R0, R9
; 7AE0: L12:  EB030AAA         MOV R1, R0
; 7AE4:       010340F9         LDR NL1, [NFP]
; 7AE8:       7F011DEB         CMP R1, NULL
; 7AEC:       A1030054         BNE L17
; 7AF0: L13:  4A2740F9         LDR R0, [CFP, #72]
; 7AF4:       410D4092         AND NL1, R0, #15
; 7AF8:       3F1C00F1         CMP NL1, #7
; 7AFC:       E1020054         BNE L16
; 7B00:       4A2740F9         LDR R0, [CFP, #72]
; 7B04:       5F011DEB         CMP R0, NULL
; 7B08:       C0F5FF54         BEQ L5
; 7B0C:       4A2740F9         LDR R0, [CFP, #72]
; 7B10:       4A915FF8         LDR R0, [R0, #-7]
; 7B14:       ED030AAA         MOV R3, R0
; 7B18:       4A2740F9         LDR R0, [CFP, #72]
; 7B1C:       4A1140F8         LDR R0, [R0, #1]
; 7B20:       4A2700F9         STR R0, [CFP, #72]
; 7B24:       402B40F9         LDR NL0, [CFP, #80]
; 7B28:       00FC4193         ASR NL0, NL0, #1
; 7B2C:       01040091         ADD NL1, NL0, #1
; 7B30:       E00301AA         MOV NL0, NL1
; 7B34:       E10300AA         MOV NL1, NL0
; 7B38:       3F0442F2         TST NL1, #13835058055282163712
; 7B3C:       C1000054         BNE L15
; 7B40:       00F87FD3         LSL NL0, NL0, #1
; 7B44:       402B00F9         STR NL0, [CFP, #80]
; 7B48: L14:  402B40F9         LDR NL0, [CFP, #80]
; 7B4C:       40F5FFB4         CBZ NL0, L7
; 7B50:       BBFFFF17         B L8
; 7B54: L15:  A00A28D4         BRK #16469                     ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 7B58: L16:  4A2740F9         LDR R0, [CFP, #72]
; 7B5C:       E04921D4         BRK #2639                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 7B60: L17:  4A2340F9         LDR R0, [CFP, #64]
; 7B64:       4A5141F8         LDR R0, [R0, #21]
; 7B68:       0CDCFF58         LDR R2, #x70086D76E8           ; :RULE-STOP
; 7B6C:       5F010CEB         CMP R0, R2
; 7B70:       000B0054         BEQ L24
; 7B74:       AAD140F8         LDR R0, [R3, #13]
; 7B78:       4CDBFF58         LDR R2, #x70086D76E0           ; :EPSILON
; 7B7C:       5F010CEB         CMP R0, R2
; 7B80:       61060054         BNE L23
; 7B84: L18:  AAD140F8         LDR R0, [R3, #13]
; 7B88:       8CDAFF58         LDR R2, #x70086D76D8           ; :RULE
; 7B8C:       5F010CEB         CMP R0, R2
; 7B90:       61000054         BNE L19
; 7B94:       000340F9         LDR NL0, [NFP]
; 7B98:       2005F8B6         TBZ NL0, #63, L22
; 7B9C: L19:  7F011DEB         CMP R1, NULL
; 7BA0:       80FAFF54         BEQ L13
; 7BA4:       533F00F9         STR R9, [CFP, #120]
; 7BA8:       513700F9         STR R7, [CFP, #104]
; 7BAC:       EA030BAA         MOV R0, R1
; 7BB0:       2E0001AB         ADDS R4, NL1, NL1
; 7BB4:       E7010054         BVC L21
; 7BB8:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 7BBC:       A97A47A9         LDP TMP, LR, [THREAD, #112]    ; mixed-tlab.{free-pointer, end-addr}
; 7BC0:       2E410091         ADD R4, TMP, #16
; 7BC4:       DF011EEB         CMP R4, LR
; 7BC8:       C8480054         BHI L87
; 7BCC:       AE3A00F9         STR R4, [THREAD, #112]         ; mixed-tlab
; 7BD0: L20:  2E3D0091         ADD R4, TMP, #15
; 7BD4:       3E2280D2         MOVZ LR, #273
; 7BD8:       3E0500A9         STP LR, NL1, [TMP]
; 7BDC:       BF3A03D5         DMB ISHST
; 7BE0:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 7BE4:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 7BE8:       5E0000B4         CBZ LR, L21
; 7BEC:       200120D4         BRK #9                         ; Pending interrupt trap
; 7BF0: L21:  E0031BAA         MOV NL0, CSP
; 7BF4:       7A8703F8         STR CFP, [CSP], #56
; 7BF8:       4BB341A9         LDP R1, R2, [CFP, #24]
; 7BFC:       4D2F40F9         LDR R3, [CFP, #88]
; 7C00:       4F1B40F9         LDR R5, [CFP, #48]
; 7C04:       0F3802A9         STP R5, R4, [NL0, #32]
; 7C08:       4E1F40F9         LDR R4, [CFP, #56]
; 7C0C:       0E1800F9         STR R4, [NL0, #48]
; 7C10:       96D3FF58         LDR LEXENV, #x70086D7680       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CLOSURE-CHECKING-STOP-STATE>
; 7C14:       D70180D2         MOVZ NARGS, #14
; 7C18:       580B00F9         STR NFP, [CFP, #16]
; 7C1C:       FA0300AA         MOV CFP, NL0
; 7C20:       DE9240F8         LDR LR, [LEXENV, #9]
; 7C24:       C0033FD6         BLR LR
; 7C28:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 7C2C:       580B40F9         LDR NFP, [CFP, #16]
; 7C30:       513740F9         LDR R7, [CFP, #104]
; 7C34:       533F40F9         LDR R9, [CFP, #120]
; 7C38:       AEFFFF17         B L13
; 7C3C: L22:  000340F9         LDR NL0, [NFP]
; 7C40:       00040091         ADD NL0, NL0, #1
; 7C44:       E10300AA         MOV NL1, NL0
; 7C48:       D5FFFF17         B L19
; 7C4C: L23:  6CD4FF58         LDR R2, #x70086D76D8           ; :RULE
; 7C50:       5F010CEB         CMP R0, R2
; 7C54:       80F9FF54         BEQ L18
; 7C58:       CCD4FF58         LDR R2, #x70086D76F0           ; :PREDICATE
; 7C5C:       5F010CEB         CMP R0, R2
; 7C60:       20F9FF54         BEQ L18
; 7C64:       ACD4FF58         LDR R2, #x70086D76F8           ; :ACTION
; 7C68:       5F010CEB         CMP R0, R2
; 7C6C:       C0F8FF54         BEQ L18
; 7C70:       8CD4FF58         LDR R2, #x70086D7700           ; :PRECEDENCE
; 7C74:       5F010CEB         CMP R0, R2
; 7C78:       60F8FF54         BEQ L18
; 7C7C:       010700F9         STR NL1, [NFP, #8]
; 7C80:       4D4706A9         STP R3, R7, [CFP, #96]
; 7C84:       533F00F9         STR R9, [CFP, #120]
; 7C88:       7A0300F9         STR CFP, [CSP]
; 7C8C:       4A1340F9         LDR R0, [CFP, #32]
; 7C90:       D6CFFF58         LDR LEXENV, #x70086D7688       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::BUSY-ADD>
; 7C94:       970080D2         MOVZ NARGS, #4
; 7C98:       580B00F9         STR NFP, [CFP, #16]
; 7C9C:       FA031BAA         MOV CFP, CSP
; 7CA0:       DE9240F8         LDR LR, [LEXENV, #9]
; 7CA4:       C0033FD6         BLR LR
; 7CA8:       AB138B9A         CSEL R1, NULL, R1, NE
; 7CAC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 7CB0:       580B40F9         LDR NFP, [CFP, #16]
; 7CB4:       533F40F9         LDR R9, [CFP, #120]
; 7CB8:       4D4746A9         LDP R3, R7, [CFP, #96]
; 7CBC:       010740F9         LDR NL1, [NFP, #8]
; 7CC0:       5F011DEB         CMP R0, NULL
; 7CC4:       AA038B9A         CSEL R0, NULL, R1, EQ
; 7CC8:       EB030AAA         MOV R1, R0
; 7CCC:       AEFFFF17         B L18
; 7CD0: L24:  CCD1FF58         LDR R2, #x70086D7708           ; 'CNVRS/RUNTIME::*CURRENT-DFA*
; 7CD4:       81515FB8         LDR WNL1, [R2, #-11]
; 7CD8:       AA6A61F8         LDR R0, [THREAD, NL1]
; 7CDC:       5F0500B1         CMN R0, #1
; 7CE0:       41000054         BNE L25
; 7CE4:       8A1140F8         LDR R0, [R2, #1]
; 7CE8: L25:  5F2500F1         CMP R0, #9
; 7CEC:       20400054         BEQ L88
; 7CF0:       5F011DEB         CMP R0, NULL
; 7CF4:       41040054         BNE L28
; 7CF8: L26:  60D142F8         LDR NL0, [R1, #45]
; 7CFC:       00FC4193         ASR NL0, NL0, #1
; 7D00:       00040091         ADD NL0, NL0, #1
; 7D04:       1F0000AB         CMN NL0, NL0
; 7D08:       86030054         BVS L27
; 7D0C:       533F00F9         STR R9, [CFP, #120]
; 7D10:       513700F9         STR R7, [CFP, #104]
; 7D14:       00F87FD3         LSL NL0, NL0, #1
; 7D18:       60D102F8         STR NL0, [R1, #45]
; 7D1C:       7A0300F9         STR CFP, [CSP]
; 7D20:       4A1340F9         LDR R0, [CFP, #32]
; 7D24:       36CBFF58         LDR LEXENV, #x70086D7688       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::BUSY-ADD>
; 7D28:       970080D2         MOVZ NARGS, #4
; 7D2C:       580B00F9         STR NFP, [CFP, #16]
; 7D30:       FA031BAA         MOV CFP, CSP
; 7D34:       DE9240F8         LDR LR, [LEXENV, #9]
; 7D38:       C0033FD6         BLR LR
; 7D3C:       AB138B9A         CSEL R1, NULL, R1, NE
; 7D40:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 7D44:       580B40F9         LDR NFP, [CFP, #16]
; 7D48:       513740F9         LDR R7, [CFP, #104]
; 7D4C:       533F40F9         LDR R9, [CFP, #120]
; 7D50:       5F011DEB         CMP R0, NULL
; 7D54:       AA038B9A         CSEL R0, NULL, R1, EQ
; 7D58:       EB030AAA         MOV R1, R0
; 7D5C:       4A0F40F9         LDR R0, [CFP, #24]
; 7D60:       ACE30091         ADD R2, NULL, #56              ; T
; 7D64:       4CD103F8         STR R2, [R0, #61]
; 7D68:       000340F9         LDR NL0, [NFP]
; 7D6C:       000400D1         SUB NL0, NL0, #1
; 7D70:       E10300AA         MOV NL1, NL0
; 7D74:       8AFFFF17         B L19
; 7D78: L27:  A00A28D4         BRK #16469                     ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 7D7C: L28:  6CCCFF58         LDR R2, #x70086D7708           ; 'CNVRS/RUNTIME::*CURRENT-DFA*
; 7D80:       81515FB8         LDR WNL1, [R2, #-11]
; 7D84:       AA6A61F8         LDR R0, [THREAD, NL1]
; 7D88:       5F0500B1         CMN R0, #1
; 7D8C:       41000054         BNE L29
; 7D90:       8A1140F8         LDR R0, [R2, #1]
; 7D94: L29:  5F2500F1         CMP R0, #9
; 7D98:       E03A0054         BEQ L89
; 7D9C:       5F011DEB         CMP R0, NULL
; 7DA0:       600A0054         BEQ L38
; 7DA4:       405141F8         LDR NL0, [R0, #21]
; 7DA8:       CCC8FF58         LDR R2, #x70086D76C0           ; 'CNVRS/RUNTIME::*SIMULATOR*
; 7DAC:       81515FB8         LDR WNL1, [R2, #-11]
; 7DB0:       AA6A61F8         LDR R0, [THREAD, NL1]
; 7DB4:       5F0500B1         CMN R0, #1
; 7DB8:       41000054         BNE L30
; 7DBC:       8A1140F8         LDR R0, [R2, #1]
; 7DC0: L30:  5F2500F1         CMP R0, #9
; 7DC4:       A0390054         BEQ L90
; 7DC8:       5F011DEB         CMP R0, NULL
; 7DCC:       C0080054         BEQ L37
; 7DD0:       4AD140F8         LDR R0, [R0, #13]
; 7DD4:       4AD140F8         LDR R0, [R0, #13]
; 7DD8:       41915FF8         LDR NL1, [R0, #-7]
; 7DDC:       3F0000EB         CMP NL1, NL0
; 7DE0:       E9380054         BLS L91
; 7DE4:       4909008B         ADD TMP, R0, NL0, LSL #2
; 7DE8:       2A1140F8         LDR R0, [TMP, #1]
; 7DEC:       410D4092         AND NL1, R0, #15
; 7DF0:       3F0C00F1         CMP NL1, #3
; 7DF4:       41070054         BNE L36
; 7DF8:       4E5140F8         LDR R4, [R0, #5]
; 7DFC:       C25145B8         LDR WNL2, [R4, #85]
; 7E00:       81CCFF18         LDR WNL1, #x70086D7790
; 7E04:       5F00016B         CMP WNL2, WNL1
; 7E08:       A1060054         BNE L36
; 7E0C:       4A5143F8         LDR R0, [R0, #53]
; 7E10:       5F011DEB         CMP R0, NULL
; 7E14:       20F7FF54         BEQ L26
; 7E18:       A3D142F8         LDR NL3, [R3, #45]
; 7E1C:       6CC7FF58         LDR R2, #x70086D7708           ; 'CNVRS/RUNTIME::*CURRENT-DFA*
; 7E20:       81515FB8         LDR WNL1, [R2, #-11]
; 7E24:       AA6A61F8         LDR R0, [THREAD, NL1]
; 7E28:       5F0500B1         CMN R0, #1
; 7E2C:       41000054         BNE L31
; 7E30:       8A1140F8         LDR R0, [R2, #1]
; 7E34: L31:  5F2500F1         CMP R0, #9
; 7E38:       60360054         BEQ L92
; 7E3C:       5F011DEB         CMP R0, NULL
; 7E40:       A0040054         BEQ L35
; 7E44:       405141F8         LDR NL0, [R0, #21]
; 7E48:       CCC3FF58         LDR R2, #x70086D76C0           ; 'CNVRS/RUNTIME::*SIMULATOR*
; 7E4C:       81515FB8         LDR WNL1, [R2, #-11]
; 7E50:       AA6A61F8         LDR R0, [THREAD, NL1]
; 7E54:       5F0500B1         CMN R0, #1
; 7E58:       41000054         BNE L32
; 7E5C:       8A1140F8         LDR R0, [R2, #1]
; 7E60: L32:  5F2500F1         CMP R0, #9
; 7E64:       20350054         BEQ L93
; 7E68:       5F011DEB         CMP R0, NULL
; 7E6C:       00030054         BEQ L34
; 7E70:       4AD140F8         LDR R0, [R0, #13]
; 7E74:       4AD140F8         LDR R0, [R0, #13]
; 7E78:       41915FF8         LDR NL1, [R0, #-7]
; 7E7C:       3F0000EB         CMP NL1, NL0
; 7E80:       69340054         BLS L94
; 7E84:       4909008B         ADD TMP, R0, NL0, LSL #2
; 7E88:       2A1140F8         LDR R0, [TMP, #1]
; 7E8C:       410D4092         AND NL1, R0, #15
; 7E90:       3F0C00F1         CMP NL1, #3
; 7E94:       81010054         BNE L33
; 7E98:       4E5140F8         LDR R4, [R0, #5]
; 7E9C:       C25145B8         LDR WNL2, [R4, #85]
; 7EA0:       81C7FF18         LDR WNL1, #x70086D7790
; 7EA4:       5F00016B         CMP WNL2, WNL1
; 7EA8:       E1000054         BNE L33
; 7EAC:       40D141F8         LDR NL0, [R0, #29]
; 7EB0:       1F0003EB         CMP NL0, NL3
; 7EB4:       21F2FF54         BNE L26
; 7EB8:       AAE30091         ADD R0, NULL, #56              ; T
; 7EBC:       6A5103F8         STR R0, [R1, #53]
; 7EC0:       8EFFFF17         B L26
; 7EC4: L33:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 7EC8:       73               BYTE #X73                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/RUNTIME:ATN-STATE {70085FA683}>
; 7EC9:       .ALIGN           4
; 7ECC: L34:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 7ED0:       77               BYTE #X77                      ; #<SB-KERNEL:LAYOUT (ID=401) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {70086C9883}>
; 7ED1:       .ALIGN           4
; 7ED4: L35:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 7ED8:       7B               BYTE #X7B                      ; #<SB-KERNEL:LAYOUT (ID=400) for CNVRS/RUNTIME:DFA {70086C10A3}>
; 7ED9:       .ALIGN           4
; 7EDC: L36:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 7EE0:       73               BYTE #X73                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/RUNTIME:ATN-STATE {70085FA683}>
; 7EE1:       .ALIGN           4
; 7EE4: L37:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 7EE8:       77               BYTE #X77                      ; #<SB-KERNEL:LAYOUT (ID=401) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {70086C9883}>
; 7EE9:       .ALIGN           4
; 7EEC: L38:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 7EF0:       7B               BYTE #X7B                      ; #<SB-KERNEL:LAYOUT (ID=400) for CNVRS/RUNTIME:DFA {70086C10A3}>
; 7EF1:       .ALIGN           4
; 7EF4: L39:  2CC0FF58         LDR R2, #x70086D76F8           ; :ACTION
; 7EF8:       5F010CEB         CMP R0, R2
; 7EFC:       20DDFF54         BEQ L11
; 7F00:       8CBFFF58         LDR R2, #x70086D76F0           ; :PREDICATE
; 7F04:       5F010CEB         CMP R0, R2
; 7F08:       21100054         BNE L53
; 7F0C: L40:  AAD140F8         LDR R0, [R3, #13]
; 7F10:       8CBFFF58         LDR R2, #x70086D7700           ; :PRECEDENCE
; 7F14:       5F010CEB         CMP R0, R2
; 7F18:       AAE30091         ADD R0, NULL, #56              ; T
; 7F1C:       54019D9A         CSEL R8, R0, NULL, EQ
; 7F20:       9F021DEB         CMP R8, NULL
; 7F24:       000F0054         BEQ L52
; 7F28:       AA5142F8         LDR R0, [R3, #37]
; 7F2C:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 7F30:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 7F34:       30810091         ADD R6, TMP, #32
; 7F38:       1F021EEB         CMP R6, LR
; 7F3C:       C82E0054         BHI L95
; 7F40:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 7F44: L41:  301D0091         ADD R6, TMP, #7
; 7F48:       EE0310AA         MOV R4, R6
; 7F4C:       AFBDFF58         LDR R5, #x70086D7700           ; :PRECEDENCE
; 7F50:       CF911FF8         STR R5, [R4, #-7]
; 7F54:       CE410091         ADD R4, R4, #16
; 7F58:       CE111FF8         STR R4, [R4, #-15]
; 7F5C:       CA911FF8         STR R0, [R4, #-7]
; 7F60:       DD1100F8         STR NULL, [R4, #1]
; 7F64:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 7F68:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 7F6C:       5E0000B4         CBZ LR, L42
; 7F70:       200120D4         BRK #9                         ; Pending interrupt trap
; 7F74: L42:  EC0310AA         MOV R2, R6
; 7F78: L43:  7F011DEB         CMP R1, NULL
; 7F7C:       41020054         BNE L45
; 7F80: L44:  2AD241F8         LDR R0, [R7, #29]
; 7F84:       2B5242F8         LDR R1, [R7, #37]
; 7F88:       63D200F8         STR NL3, [R9, #13]
; 7F8C:       205241F8         LDR NL0, [R7, #21]
; 7F90:       69764BD3         UBFM TMP, R9, #11, #29
; 7F94:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 7F98:       605201F8         STR NL0, [R9, #21]
; 7F9C:       6AD201F8         STR R0, [R9, #29]
; 7FA0:       6B5202F8         STR R1, [R9, #37]
; 7FA4:       20D242F8         LDR NL0, [R7, #45]
; 7FA8:       60D202F8         STR NL0, [R9, #45]
; 7FAC:       2A5243F8         LDR R0, [R7, #53]
; 7FB0:       69764BD3         UBFM TMP, R9, #11, #29
; 7FB4:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 7FB8:       6A5203F8         STR R0, [R9, #53]
; 7FBC:       EA0313AA         MOV R0, R9
; 7FC0:       C8FEFF17         B L12
; 7FC4: L45:  9F021DEB         CMP R8, NULL
; 7FC8:       60090054         BEQ L51
; 7FCC: L46:  DF021DEB         CMP LEXENV, NULL
; 7FD0:       80FDFF54         BEQ L44
; 7FD4: L47:  4A1B40F9         LDR R0, [CFP, #48]
; 7FD8:       5F011DEB         CMP R0, NULL
; 7FDC:       C0040054         BEQ L50
; 7FE0:       4D3300F9         STR R3, [CFP, #96]
; 7FE4:       434F07A9         STP NL3, R9, [CFP, #112]
; 7FE8:       513700F9         STR R7, [CFP, #104]
; 7FEC:       7A0300F9         STR CFP, [CSP]
; 7FF0:       EA030CAA         MOV R0, R2
; 7FF4:       F6B4FF58         LDR LEXENV, #x70086D7690       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::SEMANTIC-EVAL>
; 7FF8:       570080D2         MOVZ NARGS, #2
; 7FFC:       580B00F9         STR NFP, [CFP, #16]
; 8000:       FA031BAA         MOV CFP, CSP
; 8004:       DE9240F8         LDR LR, [LEXENV, #9]
; 8008:       C0033FD6         BLR LR
; 800C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 8010:       580B40F9         LDR NFP, [CFP, #16]
; 8014:       518F46A9         LDP R7, NL3, [CFP, #104]
; 8018:       533F40F9         LDR R9, [CFP, #120]
; 801C:       4D3340F9         LDR R3, [CFP, #96]
; 8020:       5F011DEB         CMP R0, NULL
; 8024:       61000054         BNE L49
; 8028: L48:  EA031DAA         MOV R0, NULL
; 802C:       ADFEFF17         B L12
; 8030: L49:  2AD241F8         LDR R0, [R7, #29]
; 8034:       2B5242F8         LDR R1, [R7, #37]
; 8038:       63D200F8         STR NL3, [R9, #13]
; 803C:       205241F8         LDR NL0, [R7, #21]
; 8040:       69764BD3         UBFM TMP, R9, #11, #29
; 8044:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 8048:       605201F8         STR NL0, [R9, #21]
; 804C:       6AD201F8         STR R0, [R9, #29]
; 8050:       6B5202F8         STR R1, [R9, #37]
; 8054:       20D242F8         LDR NL0, [R7, #45]
; 8058:       60D202F8         STR NL0, [R9, #45]
; 805C:       2A5243F8         LDR R0, [R7, #53]
; 8060:       69764BD3         UBFM TMP, R9, #11, #29
; 8064:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 8068:       6A5203F8         STR R0, [R9, #53]
; 806C:       EA0313AA         MOV R0, R9
; 8070:       9CFEFF17         B L12
; 8074: L50:  4D4706A9         STP R3, R7, [CFP, #96]
; 8078:       434F07A9         STP NL3, R9, [CFP, #112]
; 807C:       2B5242F8         LDR R1, [R7, #37]
; 8080:       7A0300F9         STR CFP, [CSP]
; 8084:       2AB5FF58         LDR R0, #x70086D7728           ; :AND
; 8088:       96B0FF58         LDR LEXENV, #x70086D7698       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::SEMANTIC-OPERATOR>
; 808C:       D70080D2         MOVZ NARGS, #6
; 8090:       580B00F9         STR NFP, [CFP, #16]
; 8094:       FA031BAA         MOV CFP, CSP
; 8098:       DE9240F8         LDR LR, [LEXENV, #9]
; 809C:       C0033FD6         BLR LR
; 80A0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 80A4:       580B40F9         LDR NFP, [CFP, #16]
; 80A8:       434F47A9         LDP NL3, R9, [CFP, #112]
; 80AC:       4D4746A9         LDP R3, R7, [CFP, #96]
; 80B0:       EB030AAA         MOV R1, R0
; 80B4:       2AD241F8         LDR R0, [R7, #29]
; 80B8:       63D200F8         STR NL3, [R9, #13]
; 80BC:       205241F8         LDR NL0, [R7, #21]
; 80C0:       69764BD3         UBFM TMP, R9, #11, #29
; 80C4:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 80C8:       605201F8         STR NL0, [R9, #21]
; 80CC:       6AD201F8         STR R0, [R9, #29]
; 80D0:       6B5202F8         STR R1, [R9, #37]
; 80D4:       20D242F8         LDR NL0, [R7, #45]
; 80D8:       60D202F8         STR NL0, [R9, #45]
; 80DC:       2A5243F8         LDR R0, [R7, #53]
; 80E0:       69764BD3         UBFM TMP, R9, #11, #29
; 80E4:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 80E8:       6A5203F8         STR R0, [R9, #53]
; 80EC:       EA0313AA         MOV R0, R9
; 80F0:       7CFEFF17         B L12
; 80F4: L51:  AA5143F8         LDR R0, [R3, #53]
; 80F8:       5F011DEB         CMP R0, NULL
; 80FC:       C0F6FF54         BEQ L47
; 8100:       B3FFFF17         B L46
; 8104: L52:  AC5142F8         LDR R2, [R3, #37]
; 8108:       9CFFFF17         B L43
; 810C: L53:  ACAFFF58         LDR R2, #x70086D7700           ; :PRECEDENCE
; 8110:       5F010CEB         CMP R0, R2
; 8114:       C0EFFF54         BEQ L40
; 8118:       CBB0FF58         LDR R1, #x70086D7730           ; :ATOM
; 811C:       5F010BEB         CMP R0, R1
; 8120:       210C0054         BNE L65
; 8124: L54:  4A1F40F9         LDR R0, [CFP, #56]
; 8128:       5F011DEB         CMP R0, NULL
; 812C:       E0F7FF54         BEQ L48
; 8130:       AA5142F8         LDR R0, [R3, #37]
; 8134:       EC030AAA         MOV R2, R0
; 8138:       ABD140F8         LDR R1, [R3, #13]
; 813C:       AEAFFF58         LDR R4, #x70086D7730           ; :ATOM
; 8140:       7F010EEB         CMP R1, R4
; 8144:       81020054         BNE L56
; 8148:       5F0900B1         CMN R0, #2
; 814C:       E1F6FF54         BNE L48
; 8150: L55:  2AD241F8         LDR R0, [R7, #29]
; 8154:       2B5242F8         LDR R1, [R7, #37]
; 8158:       63D200F8         STR NL3, [R9, #13]
; 815C:       205241F8         LDR NL0, [R7, #21]
; 8160:       69764BD3         UBFM TMP, R9, #11, #29
; 8164:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 8168:       605201F8         STR NL0, [R9, #21]
; 816C:       6AD201F8         STR R0, [R9, #29]
; 8170:       6B5202F8         STR R1, [R9, #37]
; 8174:       20D242F8         LDR NL0, [R7, #45]
; 8178:       60D202F8         STR NL0, [R9, #45]
; 817C:       2A5243F8         LDR R0, [R7, #53]
; 8180:       69764BD3         UBFM TMP, R9, #11, #29
; 8184:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 8188:       6A5203F8         STR R0, [R9, #53]
; 818C:       EA0313AA         MOV R0, R9
; 8190:       54FEFF17         B L12
; 8194: L56:  2EADFF58         LDR R4, #x70086D7738           ; :RANGE
; 8198:       7F010EEB         CMP R1, R4
; 819C:       80060054         BEQ L61
; 81A0:       0AADFF58         LDR R0, #x70086D7740           ; :SET
; 81A4:       7F010AEB         CMP R1, R0
; 81A8:       E0030054         BEQ L60
; 81AC:       EAACFF58         LDR R0, #x70086D7748           ; :NOT-SET
; 81B0:       7F010AEB         CMP R1, R0
; 81B4:       00020054         BEQ L58
; 81B8:       CAACFF58         LDR R0, #x70086D7750           ; :WILDCARD
; 81BC:       7F010AEB         CMP R1, R0
; 81C0:       41F3FF54         BNE L48
; 81C4:       EBA7FF58         LDR R1, #x70086D76C0           ; 'CNVRS/RUNTIME::*SIMULATOR*
; 81C8:       61515FB8         LDR WNL1, [R1, #-11]
; 81CC:       AA6A61F8         LDR R0, [THREAD, NL1]
; 81D0:       5F0500B1         CMN R0, #1
; 81D4:       41000054         BNE L57
; 81D8:       6A1140F8         LDR R0, [R1, #1]
; 81DC: L57:  5F2500F1         CMP R0, #9
; 81E0:       201A0054         BEQ L96
; 81E4:       5F011DEB         CMP R0, NULL
; 81E8:       01F2FF54         BNE L48
; 81EC:       60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 81F0:       77               BYTE #X77                      ; #<SB-KERNEL:LAYOUT (ID=401) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {70086C9883}>
; 81F1:       .ALIGN           4
; 81F4: L58:  6BA6FF58         LDR R1, #x70086D76C0           ; 'CNVRS/RUNTIME::*SIMULATOR*
; 81F8:       61515FB8         LDR WNL1, [R1, #-11]
; 81FC:       AA6A61F8         LDR R0, [THREAD, NL1]
; 8200:       5F0500B1         CMN R0, #1
; 8204:       41000054         BNE L59
; 8208:       6A1140F8         LDR R0, [R1, #1]
; 820C: L59:  5F2500F1         CMP R0, #9
; 8210:       C0180054         BEQ L97
; 8214:       5F011DEB         CMP R0, NULL
; 8218:       81F0FF54         BNE L48
; 821C:       60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 8220:       77               BYTE #X77                      ; #<SB-KERNEL:LAYOUT (ID=401) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {70086C9883}>
; 8221:       .ALIGN           4
; 8224: L60:  518F06A9         STP R7, NL3, [CFP, #104]
; 8228:       533F00F9         STR R9, [CFP, #120]
; 822C:       4D3300F9         STR R3, [CFP, #96]
; 8230:       7A0300F9         STR CFP, [CSP]
; 8234:       2A008092         MOVN R0, #1
; 8238:       EB030CAA         MOV R1, R2
; 823C:       36A3FF58         LDR LEXENV, #x70086D76A0       ; #<SB-KERNEL:FDEFN SB-KERNEL:%MEMBER-EQ>
; 8240:       580B00F9         STR NFP, [CFP, #16]
; 8244:       FA031BAA         MOV CFP, CSP
; 8248:       DE9240F8         LDR LR, [LEXENV, #9]
; 824C:       C0033FD6         BLR LR
; 8250:       580B40F9         LDR NFP, [CFP, #16]
; 8254:       4D3340F9         LDR R3, [CFP, #96]
; 8258:       434F47A9         LDP NL3, R9, [CFP, #112]
; 825C:       513740F9         LDR R7, [CFP, #104]
; 8260:       5F011DEB         CMP R0, NULL
; 8264:       20EEFF54         BEQ L48
; 8268:       BAFFFF17         B L55
; 826C: L61:  410D4092         AND NL1, R0, #15
; 8270:       3F1C00F1         CMP NL1, #7
; 8274:       61010054         BNE L64
; 8278:       4B915FF8         LDR R1, [R0, #-7]
; 827C:       0B010037         TBNZ WR1, #0, L63
; 8280:       4A1140F8         LDR R0, [R0, #1]
; 8284:       AA000037         TBNZ WR0, #0, L62
; 8288:       0BEDFFB6         TBZ R1, #63, L48
; 828C:       5F0900B1         CMN R0, #2
; 8290:       CBECFF54         BLT L48
; 8294:       AFFFFF17         B L55
; 8298: L62:  A04A21D4         BRK #2645                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; R0
; 829C: L63:  A06A21D4         BRK #2901                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; R1
; 82A0: L64:  E04921D4         BRK #2639                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 82A4: L65:  ABA4FF58         LDR R1, #x70086D7738           ; :RANGE
; 82A8:       5F010BEB         CMP R0, R1
; 82AC:       C0F3FF54         BEQ L54
; 82B0:       8BA4FF58         LDR R1, #x70086D7740           ; :SET
; 82B4:       5F010BEB         CMP R0, R1
; 82B8:       60F3FF54         BEQ L54
; 82BC:       6BA4FF58         LDR R1, #x70086D7748           ; :NOT-SET
; 82C0:       5F010BEB         CMP R0, R1
; 82C4:       20EBFF54         BEQ L48
; 82C8:       4BA4FF58         LDR R1, #x70086D7750           ; :WILDCARD
; 82CC:       5F010BEB         CMP R0, R1
; 82D0:       C0EAFF54         BEQ L48
; 82D4:       ABD140F8         LDR R1, [R3, #13]
; 82D8:       7A0300F9         STR CFP, [CSP]
; 82DC:       EAA3FF58         LDR R0, #x70086D7758           ; "Unsupported ATN transition: ~S"
; 82E0:       970080D2         MOVZ NARGS, #4
; 82E4:       580B00F9         STR NFP, [CFP, #16]
; 82E8:       FA031BAA         MOV CFP, CSP
; 82EC:       29D280D2         MOVZ TMP, #1681
; 82F0:       BE6B69F8         LDR LR, [NULL, TMP]            ; ERROR
; 82F4:       C0033FD6         BLR LR
; 82F8:       580B40F9         LDR NFP, [CFP, #16]
; 82FC: L66:  4D4706A9         STP R3, R7, [CFP, #96]
; 8300:       434F07A9         STP NL3, R9, [CFP, #112]
; 8304:       2AD241F8         LDR R0, [R7, #29]
; 8308:       ABD141F8         LDR R1, [R3, #29]
; 830C:       7A0300F9         STR CFP, [CSP]
; 8310:       D69CFF58         LDR LEXENV, #x70086D76A8       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:SINGLETON-CONTEXT>
; 8314:       970080D2         MOVZ NARGS, #4
; 8318:       580B00F9         STR NFP, [CFP, #16]
; 831C:       FA031BAA         MOV CFP, CSP
; 8320:       DE9240F8         LDR LR, [LEXENV, #9]
; 8324:       C0033FD6         BLR LR
; 8328:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 832C:       580B40F9         LDR NFP, [CFP, #16]
; 8330:       434F47A9         LDP NL3, R9, [CFP, #112]
; 8334:       4D4746A9         LDP R3, R7, [CFP, #96]
; 8338:       5F011DEB         CMP R0, NULL
; 833C:       20010054         BEQ L67
; 8340:       410D4092         AND NL1, R0, #15
; 8344:       3F0C00F1         CMP NL1, #3
; 8348:       C1020054         BNE L68
; 834C:       4E5140F8         LDR R4, [R0, #5]
; 8350:       C25145B8         LDR WNL2, [R4, #85]
; 8354:       21A2FF18         LDR WNL1, #x70086D7798
; 8358:       5F00016B         CMP WNL2, WNL1
; 835C:       21020054         BNE L68
; 8360: L67:  2B5242F8         LDR R1, [R7, #37]
; 8364:       63D200F8         STR NL3, [R9, #13]
; 8368:       205241F8         LDR NL0, [R7, #21]
; 836C:       69764BD3         UBFM TMP, R9, #11, #29
; 8370:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 8374:       605201F8         STR NL0, [R9, #21]
; 8378:       6AD201F8         STR R0, [R9, #29]
; 837C:       6B5202F8         STR R1, [R9, #37]
; 8380:       20D242F8         LDR NL0, [R7, #45]
; 8384:       60D202F8         STR NL0, [R9, #45]
; 8388:       2A5243F8         LDR R0, [R7, #53]
; 838C:       69764BD3         UBFM TMP, R9, #11, #29
; 8390:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 8394:       6A5203F8         STR R0, [R9, #53]
; 8398:       EA0313AA         MOV R0, R9
; 839C:       D1FDFF17         B L12
; 83A0: L68:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 83A4:       9B01             BYTE #X9B, #X01                ; '(OR NULL
                                                              ;      CNVRS/RUNTIME:PREDICTION-CONTEXT)
; 83A6:       .ALIGN           4
; 83A8: L69:  60A321D4         BRK #3355                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R3
; 83AC:       9F01             BYTE #X9F, #X01                ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-TRANSITION {7008626B13}>
; 83AE:       .ALIGN           4
; 83B0: L70:  A10D4092         AND NL1, R3, #15
; 83B4:       3F0C00F1         CMP NL1, #3
; 83B8:       81010054         BNE L71
; 83BC:       AE5140F8         LDR R4, [R3, #5]
; 83C0:       C25145B8         LDR WNL2, [R4, #85]
; 83C4:       819EFF18         LDR WNL1, #x70086D7794
; 83C8:       5F00016B         CMP WNL2, WNL1
; 83CC:       E1000054         BNE L71
; 83D0:       AAD140F8         LDR R0, [R3, #13]
; 83D4:       2B99FF58         LDR R1, #x70086D76F8           ; :ACTION
; 83D8:       5F010BEB         CMP R0, R1
; 83DC:       60B3FF54         BEQ L9
; 83E0:       ABE30091         ADD R1, NULL, #56              ; T
; 83E4:       9AFDFF17         B L10
; 83E8: L71:  60A321D4         BRK #3355                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R3
; 83EC:       9F01             BYTE #X9F, #X01                ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-TRANSITION {7008626B13}>
; 83EE:       .ALIGN           4
; 83F0: L72:  606321D4         BRK #2843                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R1
; 83F4:       47               BYTE #X47                      ; #<SB-KERNEL:LAYOUT (ID=396) for CNVRS/RUNTIME:ATN-CONFIG {7008641703}>
; 83F5:       .ALIGN           4
; 83F8: L73:  6B5142F8         LDR R1, [R1, #37]
; 83FC:       16000014         B L76
; 8400: L74:  6A915FF8         LDR R0, [R1, #-7]
; 8404:       410D4092         AND NL1, R0, #15
; 8408:       3F0C00F1         CMP NL1, #3
; 840C:       01040054         BNE L79
; 8410:       4E5140F8         LDR R4, [R0, #5]
; 8414:       C25145B8         LDR WNL2, [R4, #85]
; 8418:       E19BFF18         LDR WNL1, #x70086D7794
; 841C:       5F00016B         CMP WNL2, WNL1
; 8420:       61030054         BNE L79
; 8424:       4AD140F8         LDR R0, [R0, #13]
; 8428:       CC95FF58         LDR R2, #x70086D76E0           ; :EPSILON
; 842C:       5F010CEB         CMP R0, R2
; 8430:       80000054         BEQ L75
; 8434:       2C95FF58         LDR R2, #x70086D76D8           ; :RULE
; 8438:       5F010CEB         CMP R0, R2
; 843C:       41010054         BNE L78
; 8440: L75:  6A1140F8         LDR R0, [R1, #1]
; 8444:       410D4092         AND NL1, R0, #15
; 8448:       3F1C00F1         CMP NL1, #7
; 844C:       A1000054         BNE L77
; 8450:       EB030AAA         MOV R1, R0
; 8454: L76:  7F011DEB         CMP R1, NULL
; 8458:       80AAFF54         BEQ L4
; 845C:       E9FFFF17         B L74
; 8460: L77:  E04921D4         BRK #2639                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 8464: L78:  6C94FF58         LDR R2, #x70086D76F0           ; :PREDICATE
; 8468:       5F010CEB         CMP R0, R2
; 846C:       A0FEFF54         BEQ L75
; 8470:       4C94FF58         LDR R2, #x70086D76F8           ; :ACTION
; 8474:       5F010CEB         CMP R0, R2
; 8478:       40FEFF54         BEQ L75
; 847C:       2C94FF58         LDR R2, #x70086D7700           ; :PRECEDENCE
; 8480:       5F010CEB         CMP R0, R2
; 8484:       E0FDFF54         BEQ L75
; 8488:       31FDFF17         B L3
; 848C: L79:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 8490:       9F01             BYTE #X9F, #X01                ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-TRANSITION {7008626B13}>
; 8492:       .ALIGN           4
; 8494: L80:  606321D4         BRK #2843                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R1
; 8498:       73               BYTE #X73                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/RUNTIME:ATN-STATE {70085FA683}>
; 8499:       .ALIGN           4
; 849C: L81:  810D4092         AND NL1, R2, #15
; 84A0:       3F0C00F1         CMP NL1, #3
; 84A4:       C1000054         BNE L82
; 84A8:       8E5140F8         LDR R4, [R2, #5]
; 84AC:       C25145B8         LDR WNL2, [R4, #85]
; 84B0:       4197FF18         LDR WNL1, #x70086D7798
; 84B4:       5F00016B         CMP WNL2, WNL1
; 84B8:       20A1FF54         BEQ L2
; 84BC: L82:  608321D4         BRK #3099                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 84C0:       9B01             BYTE #X9B, #X01                ; '(OR NULL
                                                              ;      CNVRS/RUNTIME:PREDICTION-CONTEXT)
; 84C2:       .ALIGN           4
; 84C4: L83:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 84C8:       77               BYTE #X77                      ; #<SB-KERNEL:LAYOUT (ID=401) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {70086C9883}>
; 84C9:       .ALIGN           4
; 84CC:       E00120D4         BRK #15                        ; Invalid argument count trap
; 84D0: L84:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 84D4: L85:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 84D8:       01               BYTE #X01                      ; NL0
; 84D9:       .ALIGN           4
; 84DC: L86:  E04221D4         BRK #2583                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R0
; 84E0: L87:  090280D2         MOVZ TMP, #16
; 84E4:       AE94FF58         LDR R4, #x70086D7778           ; SB-VM::ALLOC-TRAMP
; 84E8:       C0013FD6         BLR R4
; 84EC:       B9FDFF17         B L20
; 84F0: L88:  E08221D4         BRK #3095                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; 84F4: L89:  E08221D4         BRK #3095                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; 84F8: L90:  E08221D4         BRK #3095                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; 84FC: L91:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 8500:       01               BYTE #X01                      ; NL0
; 8501:       .ALIGN           4
; 8504: L92:  E08221D4         BRK #3095                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; 8508: L93:  E08221D4         BRK #3095                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; 850C: L94:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 8510:       01               BYTE #X01                      ; NL0
; 8511:       .ALIGN           4
; 8514: L95:  090480D2         MOVZ TMP, #32
; 8518:       5093FF58         LDR R6, #x70086D7780           ; SB-VM::LIST-ALLOC-TRAMP
; 851C:       00023FD6         BLR R6
; 8520:       89FEFF17         B L41
; 8524: L96:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 8528: L97:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
