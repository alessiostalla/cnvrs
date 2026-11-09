; disassembly for CNVRS/ANTLR-RUNTIME::CAN-DROP-LOOP-ENTRY-EDGE-IN-LEFT-RECURSIVE-RULE
; Size: 2180 bytes. Origin: #x700AB0381C                      ; CNVRS/ANTLR-RUNTIME::CAN-DROP-LOOP-ENTRY-EDGE-IN-LEFT-RECURSIVE-RULE
; 381C:       80D140F8         LDR NL0, [R2, #13]
; 3820:       8BF9FF58         LDR R1, #x700AB03750           ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; 3824:       61515FB8         LDR WNL1, [R1, #-11]
; 3828:       AA6A61F8         LDR R0, [THREAD, NL1]
; 382C:       5F0500B1         CMN R0, #1
; 3830:       41000054         BNE L0
; 3834:       6A1140F8         LDR R0, [R1, #1]
; 3838: L0:   5F2500F1         CMP R0, #9
; 383C:       A0400054         BEQ L65
; 3840:       5F011DEB         CMP R0, NULL
; 3844:       00400054         BEQ L64
; 3848:       4AD140F8         LDR R0, [R0, #13]
; 384C:       4AD140F8         LDR R0, [R0, #13]
; 3850:       41915FF8         LDR NL1, [R0, #-7]
; 3854:       3F0000EB         CMP NL1, NL0
; 3858:       E93F0054         BLS L66
; 385C:       4909008B         ADD TMP, R0, NL0, LSL #2
; 3860:       2D1140F8         LDR R3, [TMP, #1]
; 3864:       EF030DAA         MOV R5, R3
; 3868:       8CD141F8         LDR R2, [R2, #29]
; 386C:       EA030CAA         MOV R0, R2
; 3870:       A10D4092         AND NL1, R3, #15
; 3874:       3F0C00F1         CMP NL1, #3
; 3878:       213E0054         BNE L63
; 387C:       AB5140F8         LDR R1, [R3, #5]
; 3880:       625145B8         LDR WNL2, [R1, #85]
; 3884:       C1F9FF18         LDR WNL1, #x700AB037BC
; 3888:       5F00016B         CMP WNL2, WNL1
; 388C:       813D0054         BNE L63
; 3890:       AB5141F8         LDR R1, [R3, #21]
; 3894:       2EF6FF58         LDR R4, #x700AB03758           ; :STAR-LOOP-ENTRY
; 3898:       7F010EEB         CMP R1, R4
; 389C:       21020054         BNE L1
; 38A0:       AB5143F8         LDR R1, [R3, #53]
; 38A4:       7F011DEB         CMP R1, NULL
; 38A8:       C0010054         BEQ L1
; 38AC:       4CBF01A9         STP R2, R5, [CFP, #24]
; 38B0:       4D1700F9         STR R3, [CFP, #40]
; 38B4:       7A0300F9         STR CFP, [CSP]
; 38B8:       56F4FF58         LDR LEXENV, #x700AB03740       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::CONTEXT-HAS-EMPTY-PATH-P>
; 38BC:       570080D2         MOVZ NARGS, #2
; 38C0:       FA031BAA         MOV CFP, CSP
; 38C4:       DE9240F8         LDR LR, [LEXENV, #9]
; 38C8:       C0033FD6         BLR LR
; 38CC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 38D0:       4F3742A9         LDP R5, R3, [CFP, #32]
; 38D4:       4C0F40F9         LDR R2, [CFP, #24]
; 38D8:       5F011DEB         CMP R0, NULL
; 38DC:       C0000054         BEQ L3
; 38E0: L1:   EA031DAA         MOV R0, NULL
; 38E4: L2:   FB031AAA         MOV CSP, CFP
; 38E8:       5A7B40A9         LDP CFP, LR, [CFP]
; 38EC:       BF0300F1         CMP NULL, #0
; 38F0:       C0035FD6         RET
; 38F4: L3:   AA5142F8         LDR R0, [R3, #37]
; 38F8:       4A915FF8         LDR R0, [R0, #-7]
; 38FC:       410D4092         AND NL1, R0, #15
; 3900:       3F0C00F1         CMP NL1, #3
; 3904:       81390054         BNE L62
; 3908:       4B5140F8         LDR R1, [R0, #5]
; 390C:       625145B8         LDR WNL2, [R1, #85]
; 3910:       81F5FF18         LDR WNL1, #x700AB037C0
; 3914:       5F00016B         CMP WNL2, WNL1
; 3918:       E1380054         BNE L62
; 391C:       405141F8         LDR NL0, [R0, #21]
; 3920:       8BF1FF58         LDR R1, #x700AB03750           ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; 3924:       61515FB8         LDR WNL1, [R1, #-11]
; 3928:       AA6A61F8         LDR R0, [THREAD, NL1]
; 392C:       5F0500B1         CMN R0, #1
; 3930:       41000054         BNE L4
; 3934:       6A1140F8         LDR R0, [R1, #1]
; 3938: L4:   5F2500F1         CMP R0, #9
; 393C:       00390054         BEQ L67
; 3940:       5F011DEB         CMP R0, NULL
; 3944:       40370054         BEQ L61
; 3948:       4AD140F8         LDR R0, [R0, #13]
; 394C:       4AD140F8         LDR R0, [R0, #13]
; 3950:       41915FF8         LDR NL1, [R0, #-7]
; 3954:       3F0000EB         CMP NL1, NL0
; 3958:       49380054         BLS L68
; 395C:       4909008B         ADD TMP, R0, NL0, LSL #2
; 3960:       2A1140F8         LDR R0, [TMP, #1]
; 3964:       410D4092         AND NL1, R0, #15
; 3968:       3F0C00F1         CMP NL1, #3
; 396C:       C1350054         BNE L60
; 3970:       4B5140F8         LDR R1, [R0, #5]
; 3974:       625145B8         LDR WNL2, [R1, #85]
; 3978:       21F2FF18         LDR WNL1, #x700AB037BC
; 397C:       5F00016B         CMP WNL2, WNL1
; 3980:       21350054         BNE L60
; 3984:       515144F8         LDR R7, [R0, #69]
; 3988:       D1340037         TBNZ WR7, #0, L59
; 398C:       F00311AA         MOV R6, R7
; 3990:       890D4092         AND TMP, R2, #15
; 3994:       3F0D00F1         CMP TMP, #3
; 3998:       A11B0054         BNE L33
; 399C:       8A5140F8         LDR R0, [R2, #5]
; 39A0:       429145B8         LDR WNL2, [R0, #89]
; 39A4:       01F1FF18         LDR WNL1, #x700AB037C4
; 39A8:       5F00016B         CMP WNL2, WNL1
; 39AC:       401B0054         BEQ L34
; 39B0:       429145B8         LDR WNL2, [R0, #89]
; 39B4:       A1F0FF18         LDR WNL1, #x700AB037C8
; 39B8:       5F00016B         CMP WNL2, WNL1
; 39BC:       811A0054         BNE L33
; 39C0:       8A5141F8         LDR R0, [R2, #21]
; 39C4:       91D141F8         LDR R7, [R2, #29]
; 39C8:       F3030AAA         MOV R9, R0
; 39CC:       45915FF8         LDR NL5, [R0, #-7]
; 39D0:       030080D2         MOVZ NL3, #0
; 39D4:       6E000014         B L13
; 39D8: L5:   6906038B         ADD TMP, R9, NL3, LSL #1
; 39DC:       201140B8         LDR WNL0, [TMP, #1]
; 39E0:       04F87FD3         LSL NL4, NL0, #1
; 39E4:       20925FF8         LDR NL0, [R7, #-7]
; 39E8:       1F0003EB         CMP NL0, NL3
; 39EC:       E9330054         BLS L69
; 39F0:       0BEBFF58         LDR R1, #x700AB03750           ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; 39F4:       61515FB8         LDR WNL1, [R1, #-11]
; 39F8:       AA6A61F8         LDR R0, [THREAD, NL1]
; 39FC:       5F0500B1         CMN R0, #1
; 3A00:       41000054         BNE L6
; 3A04:       6A1140F8         LDR R0, [R1, #1]
; 3A08: L6:   5F2500F1         CMP R0, #9
; 3A0C:       20330054         BEQ L70
; 3A10:       5F011DEB         CMP R0, NULL
; 3A14:       80170054         BEQ L32
; 3A18:       4AD140F8         LDR R0, [R0, #13]
; 3A1C:       4AD140F8         LDR R0, [R0, #13]
; 3A20:       40915FF8         LDR NL0, [R0, #-7]
; 3A24:       1F0004EB         CMP NL0, NL4
; 3A28:       69320054         BLS L71
; 3A2C:       4909048B         ADD TMP, R0, NL4, LSL #2
; 3A30:       2C1140F8         LDR R2, [TMP, #1]
; 3A34:       810D4092         AND NL1, R2, #15
; 3A38:       3F0C00F1         CMP NL1, #3
; 3A3C:       01160054         BNE L31
; 3A40:       8B5140F8         LDR R1, [R2, #5]
; 3A44:       625145B8         LDR WNL2, [R1, #85]
; 3A48:       A1EBFF18         LDR WNL1, #x700AB037BC
; 3A4C:       5F00016B         CMP WNL2, WNL1
; 3A50:       61150054         BNE L31
; 3A54:       8D5142F8         LDR R3, [R2, #37]
; 3A58:       81D141F8         LDR NL1, [R2, #29]
; 3A5C:       E0D141F8         LDR NL0, [R5, #29]
; 3A60:       1F0001EB         CMP NL0, NL1
; 3A64:       01100054         BNE L21
; 3A68:       EB030DAA         MOV R1, R3
; 3A6C:       020080D2         MOVZ NL2, #0
; 3A70: L7:   7F011DEB         CMP R1, NULL
; 3A74:       00010054         BEQ L9
; 3A78:       610D4092         AND NL1, R1, #15
; 3A7C:       3F1C00F1         CMP NL1, #7
; 3A80:       81000054         BNE L8
; 3A84:       6B1140F8         LDR R1, [R1, #1]
; 3A88:       42080091         ADD NL2, NL2, #2
; 3A8C:       F9FFFF17         B L7
; 3A90: L8:   E06921D4         BRK #2895                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R1
; 3A94: L9:   5F0800F1         CMP NL2, #2
; 3A98:       610E0054         BNE L21
; 3A9C:       AA915FF8         LDR R0, [R3, #-7]
; 3AA0:       410D4092         AND NL1, R0, #15
; 3AA4:       3F0C00F1         CMP NL1, #3
; 3AA8:       61120054         BNE L30
; 3AAC:       4B5140F8         LDR R1, [R0, #5]
; 3AB0:       625145B8         LDR WNL2, [R1, #85]
; 3AB4:       61E8FF18         LDR WNL1, #x700AB037C0
; 3AB8:       5F00016B         CMP WNL2, WNL1
; 3ABC:       C1110054         BNE L30
; 3AC0:       4AD140F8         LDR R0, [R0, #13]
; 3AC4:       EBE4FF58         LDR R1, #x700AB03760           ; :EPSILON
; 3AC8:       5F010BEB         CMP R0, R1
; 3ACC:       80000054         BEQ L10
; 3AD0:       CBE4FF58         LDR R1, #x700AB03768           ; :RULE
; 3AD4:       5F010BEB         CMP R0, R1
; 3AD8:       A10F0054         BNE L29
; 3ADC: L10:  AA915FF8         LDR R0, [R3, #-7]
; 3AE0:       410D4092         AND NL1, R0, #15
; 3AE4:       3F0C00F1         CMP NL1, #3
; 3AE8:       E10E0054         BNE L28
; 3AEC:       4B5140F8         LDR R1, [R0, #5]
; 3AF0:       625145B8         LDR WNL2, [R1, #85]
; 3AF4:       61E6FF18         LDR WNL1, #x700AB037C0
; 3AF8:       5F00016B         CMP WNL2, WNL1
; 3AFC:       410E0054         BNE L28
; 3B00:       405141F8         LDR NL0, [R0, #21]
; 3B04:       6BE2FF58         LDR R1, #x700AB03750           ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; 3B08:       61515FB8         LDR WNL1, [R1, #-11]
; 3B0C:       AA6A61F8         LDR R0, [THREAD, NL1]
; 3B10:       5F0500B1         CMN R0, #1
; 3B14:       41000054         BNE L11
; 3B18:       6A1140F8         LDR R0, [R1, #1]
; 3B1C: L11:  5F2500F1         CMP R0, #9
; 3B20:       E02A0054         BEQ L72
; 3B24:       5F011DEB         CMP R0, NULL
; 3B28:       A00C0054         BEQ L27
; 3B2C:       4AD140F8         LDR R0, [R0, #13]
; 3B30:       4AD140F8         LDR R0, [R0, #13]
; 3B34:       41915FF8         LDR NL1, [R0, #-7]
; 3B38:       3F0000EB         CMP NL1, NL0
; 3B3C:       292A0054         BLS L73
; 3B40:       E10300AA         MOV NL1, NL0
; 3B44:       4909018B         ADD TMP, R0, NL1, LSL #2
; 3B48:       2D1140F8         LDR R3, [TMP, #1]
; 3B4C:       A10D4092         AND NL1, R3, #15
; 3B50:       3F0C00F1         CMP NL1, #3
; 3B54:       010B0054         BNE L26
; 3B58:       AB5140F8         LDR R1, [R3, #5]
; 3B5C:       625145B8         LDR WNL2, [R1, #85]
; 3B60:       E1E2FF18         LDR WNL1, #x700AB037BC
; 3B64:       5F00016B         CMP WNL2, WNL1
; 3B68:       610A0054         BNE L26
; 3B6C:       AE5142F8         LDR R4, [R3, #37]
; 3B70:       1F0204EB         CMP R6, NL4
; 3B74:       80000054         BEQ L12
; 3B78:       E10300AA         MOV NL1, NL0
; 3B7C:       1F0201EB         CMP R6, NL1
; 3B80:       E1000054         BNE L15
; 3B84: L12:  60080091         ADD NL0, NL3, #2
; 3B88:       E30300AA         MOV NL3, NL0
; 3B8C: L13:  7F0005EB         CMP NL3, NL5
; 3B90:       4BF2FF54         BLT L5
; 3B94: L14:  AAE30091         ADD R0, NULL, #56              ; T
; 3B98:       53FFFF17         B L2
; 3B9C: L15:  8A5141F8         LDR R0, [R2, #21]
; 3BA0:       8BDEFF58         LDR R1, #x700AB03770           ; :BLOCK-END
; 3BA4:       5F010BEB         CMP R0, R1
; 3BA8:       E0070054         BEQ L25
; 3BAC: L16:  AA5141F8         LDR R0, [R3, #21]
; 3BB0:       0BDEFF58         LDR R1, #x700AB03770           ; :BLOCK-END
; 3BB4:       5F010BEB         CMP R0, R1
; 3BB8:       61050054         BNE L21
; 3BBC:       EB030EAA         MOV R1, R4
; 3BC0:       020080D2         MOVZ NL2, #0
; 3BC4: L17:  7F011DEB         CMP R1, NULL
; 3BC8:       00010054         BEQ L19
; 3BCC:       610D4092         AND NL1, R1, #15
; 3BD0:       3F1C00F1         CMP NL1, #7
; 3BD4:       81000054         BNE L18
; 3BD8:       6B1140F8         LDR R1, [R1, #1]
; 3BDC:       42080091         ADD NL2, NL2, #2
; 3BE0:       F9FFFF17         B L17
; 3BE4: L18:  E06921D4         BRK #2895                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R1
; 3BE8: L19:  5F0800F1         CMP NL2, #2
; 3BEC:       C1030054         BNE L21
; 3BF0:       CA915FF8         LDR R0, [R4, #-7]
; 3BF4:       410D4092         AND NL1, R0, #15
; 3BF8:       3F0C00F1         CMP NL1, #3
; 3BFC:       01050054         BNE L24
; 3C00:       4B5140F8         LDR R1, [R0, #5]
; 3C04:       625145B8         LDR WNL2, [R1, #85]
; 3C08:       C1DDFF18         LDR WNL1, #x700AB037C0
; 3C0C:       5F00016B         CMP WNL2, WNL1
; 3C10:       61040054         BNE L24
; 3C14:       4AD140F8         LDR R0, [R0, #13]
; 3C18:       4BDAFF58         LDR R1, #x700AB03760           ; :EPSILON
; 3C1C:       5F010BEB         CMP R0, R1
; 3C20:       80000054         BEQ L20
; 3C24:       2BDAFF58         LDR R1, #x700AB03768           ; :RULE
; 3C28:       5F010BEB         CMP R0, R1
; 3C2C:       41020054         BNE L23
; 3C30: L20:  CA915FF8         LDR R0, [R4, #-7]
; 3C34:       410D4092         AND NL1, R0, #15
; 3C38:       3F0C00F1         CMP NL1, #3
; 3C3C:       81010054         BNE L22
; 3C40:       4B5140F8         LDR R1, [R0, #5]
; 3C44:       625145B8         LDR WNL2, [R1, #85]
; 3C48:       C1DBFF18         LDR WNL1, #x700AB037C0
; 3C4C:       5F00016B         CMP WNL2, WNL1
; 3C50:       E1000054         BNE L22
; 3C54:       415141F8         LDR NL1, [R0, #21]
; 3C58:       E0D140F8         LDR NL0, [R5, #13]
; 3C5C:       1F0001EB         CMP NL0, NL1
; 3C60:       20F9FF54         BEQ L12
; 3C64: L21:  EA031DAA         MOV R0, NULL
; 3C68:       1FFFFF17         B L2
; 3C6C: L22:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 3C70:       3F               BYTE #X3F                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 3C71:       .ALIGN           4
; 3C74: L23:  6BD8FF58         LDR R1, #x700AB03780           ; :PREDICATE
; 3C78:       5F010BEB         CMP R0, R1
; 3C7C:       A0FDFF54         BEQ L20
; 3C80:       4BD8FF58         LDR R1, #x700AB03788           ; :ACTION
; 3C84:       5F010BEB         CMP R0, R1
; 3C88:       40FDFF54         BEQ L20
; 3C8C:       2BD8FF58         LDR R1, #x700AB03790           ; :PRECEDENCE
; 3C90:       5F010BEB         CMP R0, R1
; 3C94:       E0FCFF54         BEQ L20
; 3C98:       F3FFFF17         B L21
; 3C9C: L24:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 3CA0:       3F               BYTE #X3F                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 3CA1:       .ALIGN           4
; 3CA4: L25:  E1D140F8         LDR NL1, [R5, #13]
; 3CA8:       3F0000EB         CMP NL1, NL0
; 3CAC:       C0F6FF54         BEQ L12
; 3CB0:       BFFFFF17         B L16
; 3CB4: L26:  60A321D4         BRK #3355                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R3
; 3CB8:       4F               BYTE #X4F                      ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA28883}>
; 3CB9:       .ALIGN           4
; 3CBC: L27:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 3CC0:       53               BYTE #X53                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 3CC1:       .ALIGN           4
; 3CC4: L28:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 3CC8:       3F               BYTE #X3F                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 3CC9:       .ALIGN           4
; 3CCC: L29:  ABD5FF58         LDR R1, #x700AB03780           ; :PREDICATE
; 3CD0:       5F010BEB         CMP R0, R1
; 3CD4:       40F0FF54         BEQ L10
; 3CD8:       8BD5FF58         LDR R1, #x700AB03788           ; :ACTION
; 3CDC:       5F010BEB         CMP R0, R1
; 3CE0:       E0EFFF54         BEQ L10
; 3CE4:       6BD5FF58         LDR R1, #x700AB03790           ; :PRECEDENCE
; 3CE8:       5F010BEB         CMP R0, R1
; 3CEC:       80EFFF54         BEQ L10
; 3CF0:       DDFFFF17         B L21
; 3CF4: L30:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 3CF8:       3F               BYTE #X3F                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 3CF9:       .ALIGN           4
; 3CFC: L31:  608321D4         BRK #3099                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 3D00:       4F               BYTE #X4F                      ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA28883}>
; 3D01:       .ALIGN           4
; 3D04: L32:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 3D08:       53               BYTE #X53                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 3D09:       .ALIGN           4
; 3D0C: L33:  A08321D4         BRK #3101                      ; ETYPECASE-FAILURE-ERROR
                                                              ; R2
; 3D10:       57               BYTE #X57                      ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 3D11:       .ALIGN           4
; 3D14: L34:  83D141F8         LDR NL3, [R2, #29]
; 3D18:       CBD1FF58         LDR R1, #x700AB03750           ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; 3D1C:       61515FB8         LDR WNL1, [R1, #-11]
; 3D20:       AA6A61F8         LDR R0, [THREAD, NL1]
; 3D24:       5F0500B1         CMN R0, #1
; 3D28:       41000054         BNE L35
; 3D2C:       6A1140F8         LDR R0, [R1, #1]
; 3D30: L35:  5F2500F1         CMP R0, #9
; 3D34:       A01A0054         BEQ L74
; 3D38:       5F011DEB         CMP R0, NULL
; 3D3C:       E0160054         BEQ L58
; 3D40:       4AD140F8         LDR R0, [R0, #13]
; 3D44:       4AD140F8         LDR R0, [R0, #13]
; 3D48:       40915FF8         LDR NL0, [R0, #-7]
; 3D4C:       1F0003EB         CMP NL0, NL3
; 3D50:       E9190054         BLS L75
; 3D54:       4909038B         ADD TMP, R0, NL3, LSL #2
; 3D58:       2E1140F8         LDR R4, [TMP, #1]
; 3D5C:       C10D4092         AND NL1, R4, #15
; 3D60:       3F0C00F1         CMP NL1, #3
; 3D64:       61150054         BNE L57
; 3D68:       CB5140F8         LDR R1, [R4, #5]
; 3D6C:       625145B8         LDR WNL2, [R1, #85]
; 3D70:       61D2FF18         LDR WNL1, #x700AB037BC
; 3D74:       5F00016B         CMP WNL2, WNL1
; 3D78:       C1140054         BNE L57
; 3D7C:       CC5142F8         LDR R2, [R4, #37]
; 3D80:       C1D141F8         LDR NL1, [R4, #29]
; 3D84:       A0D141F8         LDR NL0, [R3, #29]
; 3D88:       1F0001EB         CMP NL0, NL1
; 3D8C:       C1010054         BNE L39
; 3D90:       EB030CAA         MOV R1, R2
; 3D94:       020080D2         MOVZ NL2, #0
; 3D98: L36:  7F011DEB         CMP R1, NULL
; 3D9C:       00010054         BEQ L38
; 3DA0:       610D4092         AND NL1, R1, #15
; 3DA4:       3F1C00F1         CMP NL1, #7
; 3DA8:       81000054         BNE L37
; 3DAC:       6B1140F8         LDR R1, [R1, #1]
; 3DB0:       42080091         ADD NL2, NL2, #2
; 3DB4:       F9FFFF17         B L36
; 3DB8: L37:  E06921D4         BRK #2895                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R1
; 3DBC: L38:  5F0800F1         CMP NL2, #2
; 3DC0:       60000054         BEQ L40
; 3DC4: L39:  EA031DAA         MOV R0, NULL
; 3DC8:       C7FEFF17         B L2
; 3DCC: L40:  8A915FF8         LDR R0, [R2, #-7]
; 3DD0:       410D4092         AND NL1, R0, #15
; 3DD4:       3F0C00F1         CMP NL1, #3
; 3DD8:       81110054         BNE L56
; 3DDC:       4B5140F8         LDR R1, [R0, #5]
; 3DE0:       625145B8         LDR WNL2, [R1, #85]
; 3DE4:       E1CEFF18         LDR WNL1, #x700AB037C0
; 3DE8:       5F00016B         CMP WNL2, WNL1
; 3DEC:       E1100054         BNE L56
; 3DF0:       4AD140F8         LDR R0, [R0, #13]
; 3DF4:       6BCBFF58         LDR R1, #x700AB03760           ; :EPSILON
; 3DF8:       5F010BEB         CMP R0, R1
; 3DFC:       80000054         BEQ L41
; 3E00:       4BCBFF58         LDR R1, #x700AB03768           ; :RULE
; 3E04:       5F010BEB         CMP R0, R1
; 3E08:       C10E0054         BNE L55
; 3E0C: L41:  8A915FF8         LDR R0, [R2, #-7]
; 3E10:       410D4092         AND NL1, R0, #15
; 3E14:       3F0C00F1         CMP NL1, #3
; 3E18:       010E0054         BNE L54
; 3E1C:       4B5140F8         LDR R1, [R0, #5]
; 3E20:       625145B8         LDR WNL2, [R1, #85]
; 3E24:       E1CCFF18         LDR WNL1, #x700AB037C0
; 3E28:       5F00016B         CMP WNL2, WNL1
; 3E2C:       610D0054         BNE L54
; 3E30:       405141F8         LDR NL0, [R0, #21]
; 3E34:       EBC8FF58         LDR R1, #x700AB03750           ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; 3E38:       61515FB8         LDR WNL1, [R1, #-11]
; 3E3C:       AA6A61F8         LDR R0, [THREAD, NL1]
; 3E40:       5F0500B1         CMN R0, #1
; 3E44:       41000054         BNE L42
; 3E48:       6A1140F8         LDR R0, [R1, #1]
; 3E4C: L42:  5F2500F1         CMP R0, #9
; 3E50:       20120054         BEQ L76
; 3E54:       5F011DEB         CMP R0, NULL
; 3E58:       C00B0054         BEQ L53
; 3E5C:       4AD140F8         LDR R0, [R0, #13]
; 3E60:       4AD140F8         LDR R0, [R0, #13]
; 3E64:       41915FF8         LDR NL1, [R0, #-7]
; 3E68:       3F0000EB         CMP NL1, NL0
; 3E6C:       69110054         BLS L77
; 3E70:       E10300AA         MOV NL1, NL0
; 3E74:       4909018B         ADD TMP, R0, NL1, LSL #2
; 3E78:       2C1140F8         LDR R2, [TMP, #1]
; 3E7C:       810D4092         AND NL1, R2, #15
; 3E80:       3F0C00F1         CMP NL1, #3
; 3E84:       210A0054         BNE L52
; 3E88:       8B5140F8         LDR R1, [R2, #5]
; 3E8C:       625145B8         LDR WNL2, [R1, #85]
; 3E90:       61C9FF18         LDR WNL1, #x700AB037BC
; 3E94:       5F00016B         CMP WNL2, WNL1
; 3E98:       81090054         BNE L52
; 3E9C:       8F5142F8         LDR R5, [R2, #37]
; 3EA0:       3F0203EB         CMP R7, NL3
; 3EA4:       80E7FF54         BEQ L14
; 3EA8:       E10300AA         MOV NL1, NL0
; 3EAC:       3F0201EB         CMP R7, NL1
; 3EB0:       20E7FF54         BEQ L14
; 3EB4:       CA5141F8         LDR R0, [R4, #21]
; 3EB8:       CBC5FF58         LDR R1, #x700AB03770           ; :BLOCK-END
; 3EBC:       5F010BEB         CMP R0, R1
; 3EC0:       C0070054         BEQ L51
; 3EC4: L43:  8A5141F8         LDR R0, [R2, #21]
; 3EC8:       4BC5FF58         LDR R1, #x700AB03770           ; :BLOCK-END
; 3ECC:       5F010BEB         CMP R0, R1
; 3ED0:       A1F7FF54         BNE L39
; 3ED4:       EB030FAA         MOV R1, R5
; 3ED8:       020080D2         MOVZ NL2, #0
; 3EDC: L44:  7F011DEB         CMP R1, NULL
; 3EE0:       00010054         BEQ L46
; 3EE4:       610D4092         AND NL1, R1, #15
; 3EE8:       3F1C00F1         CMP NL1, #7
; 3EEC:       81000054         BNE L45
; 3EF0:       6B1140F8         LDR R1, [R1, #1]
; 3EF4:       42080091         ADD NL2, NL2, #2
; 3EF8:       F9FFFF17         B L44
; 3EFC: L45:  E06921D4         BRK #2895                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R1
; 3F00: L46:  5F0800F1         CMP NL2, #2
; 3F04:       01F6FF54         BNE L39
; 3F08:       EA915FF8         LDR R0, [R5, #-7]
; 3F0C:       410D4092         AND NL1, R0, #15
; 3F10:       3F0C00F1         CMP NL1, #3
; 3F14:       E1040054         BNE L50
; 3F18:       4B5140F8         LDR R1, [R0, #5]
; 3F1C:       625145B8         LDR WNL2, [R1, #85]
; 3F20:       01C5FF18         LDR WNL1, #x700AB037C0
; 3F24:       5F00016B         CMP WNL2, WNL1
; 3F28:       41040054         BNE L50
; 3F2C:       4AD140F8         LDR R0, [R0, #13]
; 3F30:       8BC1FF58         LDR R1, #x700AB03760           ; :EPSILON
; 3F34:       5F010BEB         CMP R0, R1
; 3F38:       80000054         BEQ L47
; 3F3C:       6BC1FF58         LDR R1, #x700AB03768           ; :RULE
; 3F40:       5F010BEB         CMP R0, R1
; 3F44:       21020054         BNE L49
; 3F48: L47:  EA915FF8         LDR R0, [R5, #-7]
; 3F4C:       410D4092         AND NL1, R0, #15
; 3F50:       3F0C00F1         CMP NL1, #3
; 3F54:       61010054         BNE L48
; 3F58:       4B5140F8         LDR R1, [R0, #5]
; 3F5C:       625145B8         LDR WNL2, [R1, #85]
; 3F60:       01C3FF18         LDR WNL1, #x700AB037C0
; 3F64:       5F00016B         CMP WNL2, WNL1
; 3F68:       C1000054         BNE L48
; 3F6C:       415141F8         LDR NL1, [R0, #21]
; 3F70:       A0D140F8         LDR NL0, [R3, #13]
; 3F74:       1F0001EB         CMP NL0, NL1
; 3F78:       E0E0FF54         BEQ L14
; 3F7C:       92FFFF17         B L39
; 3F80: L48:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 3F84:       3F               BYTE #X3F                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 3F85:       .ALIGN           4
; 3F88: L49:  CBBFFF58         LDR R1, #x700AB03780           ; :PREDICATE
; 3F8C:       5F010BEB         CMP R0, R1
; 3F90:       C0FDFF54         BEQ L47
; 3F94:       ABBFFF58         LDR R1, #x700AB03788           ; :ACTION
; 3F98:       5F010BEB         CMP R0, R1
; 3F9C:       60FDFF54         BEQ L47
; 3FA0:       8BBFFF58         LDR R1, #x700AB03790           ; :PRECEDENCE
; 3FA4:       5F010BEB         CMP R0, R1
; 3FA8:       00FDFF54         BEQ L47
; 3FAC:       86FFFF17         B L39
; 3FB0: L50:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 3FB4:       3F               BYTE #X3F                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 3FB5:       .ALIGN           4
; 3FB8: L51:  A1D140F8         LDR NL1, [R3, #13]
; 3FBC:       3F0000EB         CMP NL1, NL0
; 3FC0:       A0DEFF54         BEQ L14
; 3FC4:       C0FFFF17         B L43
; 3FC8: L52:  608321D4         BRK #3099                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 3FCC:       4F               BYTE #X4F                      ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA28883}>
; 3FCD:       .ALIGN           4
; 3FD0: L53:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 3FD4:       53               BYTE #X53                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 3FD5:       .ALIGN           4
; 3FD8: L54:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 3FDC:       3F               BYTE #X3F                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 3FDD:       .ALIGN           4
; 3FE0: L55:  0BBDFF58         LDR R1, #x700AB03780           ; :PREDICATE
; 3FE4:       5F010BEB         CMP R0, R1
; 3FE8:       20F1FF54         BEQ L41
; 3FEC:       EBBCFF58         LDR R1, #x700AB03788           ; :ACTION
; 3FF0:       5F010BEB         CMP R0, R1
; 3FF4:       C0F0FF54         BEQ L41
; 3FF8:       CBBCFF58         LDR R1, #x700AB03790           ; :PRECEDENCE
; 3FFC:       5F010BEB         CMP R0, R1
; 4000:       60F0FF54         BEQ L41
; 4004:       70FFFF17         B L39
; 4008: L56:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 400C:       3F               BYTE #X3F                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 400D:       .ALIGN           4
; 4010: L57:  60C321D4         BRK #3611                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R4
; 4014:       4F               BYTE #X4F                      ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA28883}>
; 4015:       .ALIGN           4
; 4018: L58:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 401C:       53               BYTE #X53                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 401D:       .ALIGN           4
; 4020: L59:  A0AA23D4         BRK #7509                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NULL
; 4024: L60:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 4028:       4F               BYTE #X4F                      ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA28883}>
; 4029:       .ALIGN           4
; 402C: L61:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4030:       53               BYTE #X53                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 4031:       .ALIGN           4
; 4034: L62:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 4038:       3F               BYTE #X3F                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 4039:       .ALIGN           4
; 403C: L63:  60A321D4         BRK #3355                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R3
; 4040:       4F               BYTE #X4F                      ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA28883}>
; 4041:       .ALIGN           4
; 4044: L64:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4048:       53               BYTE #X53                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 4049:       .ALIGN           4
; 404C:       E00120D4         BRK #15                        ; Invalid argument count trap
; 4050: L65:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 4054: L66:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 4058:       01               BYTE #X01                      ; NL0
; 4059:       .ALIGN           4
; 405C: L67:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 4060: L68:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 4064:       01               BYTE #X01                      ; NL0
; 4065:       .ALIGN           4
; 4068: L69:  202422D4         BRK #4385                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R7
; 406C:       0D               BYTE #X0D                      ; NL3
; 406D:       .ALIGN           4
; 4070: L70:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 4074: L71:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 4078:       11               BYTE #X11                      ; NL4
; 4079:       .ALIGN           4
; 407C: L72:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 4080: L73:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 4084:       01               BYTE #X01                      ; NL0
; 4085:       .ALIGN           4
; 4088: L74:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 408C: L75:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 4090:       0D               BYTE #X0D                      ; NL3
; 4091:       .ALIGN           4
; 4094: L76:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 4098: L77:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 409C:       01               BYTE #X01                      ; NL0
; 409D:       .ALIGN           4
