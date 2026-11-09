; disassembly for CNVRS/ANTLR-RUNTIME::CLOSURE-WORK
; Size: 1844 bytes. Origin: #x700AB04938                      ; CNVRS/ANTLR-RUNTIME::CLOSURE-WORK
; 4938:       4A0F40F9         LDR R0, [CFP, #24]
; 493C:       40D140F8         LDR NL0, [R0, #13]
; 4940:       4BF5FF58         LDR R1, #x700AB047E8           ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; 4944:       61515FB8         LDR WNL1, [R1, #-11]
; 4948:       AA6A61F8         LDR R0, [THREAD, NL1]
; 494C:       5F0500B1         CMN R0, #1
; 4950:       41000054         BNE L0
; 4954:       6A1140F8         LDR R0, [R1, #1]
; 4958: L0:   5F2500F1         CMP R0, #9
; 495C:       80360054         BEQ L51
; 4960:       5F011DEB         CMP R0, NULL
; 4964:       E0350054         BEQ L50
; 4968:       4AD140F8         LDR R0, [R0, #13]
; 496C:       4AD140F8         LDR R0, [R0, #13]
; 4970:       41915FF8         LDR NL1, [R0, #-7]
; 4974:       3F0000EB         CMP NL1, NL0
; 4978:       C9350054         BLS L52
; 497C:       4909008B         ADD TMP, R0, NL0, LSL #2
; 4980:       2A1140F8         LDR R0, [TMP, #1]
; 4984:       4A2700F9         STR R0, [CFP, #72]
; 4988:       410D4092         AND NL1, R0, #15
; 498C:       3F0C00F1         CMP NL1, #3
; 4990:       41340054         BNE L49
; 4994:       4E5140F8         LDR R4, [R0, #5]
; 4998:       C25145B8         LDR WNL2, [R4, #85]
; 499C:       61F6FF18         LDR WNL1, #x700AB04868
; 49A0:       5F00016B         CMP WNL2, WNL1
; 49A4:       A1330054         BNE L49
; 49A8:       4B5142F8         LDR R1, [R0, #37]
; 49AC:       7F011DEB         CMP R1, NULL
; 49B0:       612E0054         BNE L42
; 49B4: L1:   7A0300F9         STR CFP, [CSP]
; 49B8:       4BAB41A9         LDP R1, R0, [CFP, #24]
; 49BC:       B6EFFF58         LDR LEXENV, #x700AB047B0       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:CONFIG-SET-ADD>
; 49C0:       970080D2         MOVZ NARGS, #4
; 49C4:       580B00F9         STR NFP, [CFP, #16]
; 49C8:       FA031BAA         MOV CFP, CSP
; 49CC:       DE9240F8         LDR LR, [LEXENV, #9]
; 49D0:       C0033FD6         BLR LR
; 49D4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 49D8:       580B40F9         LDR NFP, [CFP, #16]
; 49DC: L2:   4A2740F9         LDR R0, [CFP, #72]
; 49E0:       4A5142F8         LDR R0, [R0, #37]
; 49E4:       4A7F05A9         STP R0, ZR, [CFP, #80]
; 49E8:       4A2B40F9         LDR R0, [CFP, #80]
; 49EC:       5F011DEB         CMP R0, NULL
; 49F0:       E1000054         BNE L4
; 49F4: L3:   EA031DAA         MOV R0, NULL
; 49F8:       1F430091         ADD NSP, NFP, #16
; 49FC:       FB031AAA         MOV CSP, CFP
; 4A00:       5A7B40A9         LDP CFP, LR, [CFP]
; 4A04:       BF0300F1         CMP NULL, #0
; 4A08:       C0035FD6         RET
; 4A0C: L4:   4A2B40F9         LDR R0, [CFP, #80]
; 4A10:       4A915FF8         LDR R0, [R0, #-7]
; 4A14:       EF030AAA         MOV R5, R0
; 4A18:       4A2B40F9         LDR R0, [CFP, #80]
; 4A1C:       4A1140F8         LDR R0, [R0, #1]
; 4A20:       4A2B00F9         STR R0, [CFP, #80]
; 4A24:       48000014         B L11
; 4A28: L5:   4A1B40F9         LDR R0, [CFP, #48]
; 4A2C:       5F011DEB         CMP R0, NULL
; 4A30:       61280054         BNE L40
; 4A34: L6:   EA031DAA         MOV R0, NULL
; 4A38: L7:   4F3B00F9         STR R5, [CFP, #112]
; 4A3C:       4A3300F9         STR R0, [CFP, #96]
; 4A40:       EB030FAA         MOV R1, R5
; 4A44:       000340F9         LDR NL0, [NFP]
; 4A48:       1F0000F1         CMP NL0, #0
; 4A4C:       AAE30091         ADD R0, NULL, #56              ; T
; 4A50:       4D019D9A         CSEL R3, R0, NULL, EQ
; 4A54:       E0031BAA         MOV NL0, CSP
; 4A58:       7A0703F8         STR CFP, [CSP], #48
; 4A5C:       4A0F40F9         LDR R0, [CFP, #24]
; 4A60:       4C3340F9         LDR R2, [CFP, #96]
; 4A64:       4E1F40F9         LDR R4, [CFP, #56]
; 4A68:       0E1000F9         STR R4, [NL0, #32]
; 4A6C:       4E2340F9         LDR R4, [CFP, #64]
; 4A70:       0E1400F9         STR R4, [NL0, #40]
; 4A74:       36EAFF58         LDR LEXENV, #x700AB047B8       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::GET-EPSILON-TARGET>
; 4A78:       970180D2         MOVZ NARGS, #12
; 4A7C:       580B00F9         STR NFP, [CFP, #16]
; 4A80:       FA0300AA         MOV CFP, NL0
; 4A84:       DE9240F8         LDR LR, [LEXENV, #9]
; 4A88:       C0033FD6         BLR LR
; 4A8C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 4A90:       580B40F9         LDR NFP, [CFP, #16]
; 4A94:       4F3B40F9         LDR R5, [CFP, #112]
; 4A98:       EC030AAA         MOV R2, R0
; 4A9C:       010340F9         LDR NL1, [NFP]
; 4AA0:       9F011DEB         CMP R2, NULL
; 4AA4:       40020054         BEQ L10
; 4AA8:       4A2740F9         LDR R0, [CFP, #72]
; 4AAC:       4A5141F8         LDR R0, [R0, #21]
; 4AB0:       0BEAFF58         LDR R1, #x700AB047F0           ; :RULE-STOP
; 4AB4:       5F010BEB         CMP R0, R1
; 4AB8:       20100054         BEQ L21
; 4ABC:       EAD140F8         LDR R0, [R5, #13]
; 4AC0:       CBE9FF58         LDR R1, #x700AB047F8           ; :EPSILON
; 4AC4:       5F010BEB         CMP R0, R1
; 4AC8:       210B0054         BNE L18
; 4ACC: L8:   EAD140F8         LDR R0, [R5, #13]
; 4AD0:       8BE9FF58         LDR R1, #x700AB04800           ; :RULE
; 4AD4:       5F010BEB         CMP R0, R1
; 4AD8:       61000054         BNE L9
; 4ADC:       000340F9         LDR NL0, [NFP]
; 4AE0:       E009F8B6         TBZ NL0, #63, L17
; 4AE4: L9:   9F011DEB         CMP R2, NULL
; 4AE8:       61050054         BNE L14
; 4AEC: L10:  4A2B40F9         LDR R0, [CFP, #80]
; 4AF0:       410D4092         AND NL1, R0, #15
; 4AF4:       3F1C00F1         CMP NL1, #7
; 4AF8:       A1040054         BNE L13
; 4AFC:       4A2B40F9         LDR R0, [CFP, #80]
; 4B00:       5F011DEB         CMP R0, NULL
; 4B04:       80F7FF54         BEQ L3
; 4B08:       4A2B40F9         LDR R0, [CFP, #80]
; 4B0C:       4A915FF8         LDR R0, [R0, #-7]
; 4B10:       EF030AAA         MOV R5, R0
; 4B14:       4A2B40F9         LDR R0, [CFP, #80]
; 4B18:       4A1140F8         LDR R0, [R0, #1]
; 4B1C:       4A2B00F9         STR R0, [CFP, #80]
; 4B20:       402F40F9         LDR NL0, [CFP, #88]
; 4B24:       00FC4193         ASR NL0, NL0, #1
; 4B28:       01040091         ADD NL1, NL0, #1
; 4B2C:       E00301AA         MOV NL0, NL1
; 4B30:       E10300AA         MOV NL1, NL0
; 4B34:       3F0442F2         TST NL1, #13835058055282163712
; 4B38:       81020054         BNE L12
; 4B3C:       00F87FD3         LSL NL0, NL0, #1
; 4B40:       402F00F9         STR NL0, [CFP, #88]
; 4B44: L11:  402F40F9         LDR NL0, [CFP, #88]
; 4B48:       00F7FFB5         CBNZ NL0, L5
; 4B4C:       4F3B00F9         STR R5, [CFP, #112]
; 4B50:       7A0300F9         STR CFP, [CSP]
; 4B54:       4A0F40F9         LDR R0, [CFP, #24]
; 4B58:       56E3FF58         LDR LEXENV, #x700AB047C0       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::CAN-DROP-LOOP-ENTRY-EDGE-IN-LEFT-RECURSIVE-RULE>
; 4B5C:       570080D2         MOVZ NARGS, #2
; 4B60:       580B00F9         STR NFP, [CFP, #16]
; 4B64:       FA031BAA         MOV CFP, CSP
; 4B68:       DE9240F8         LDR LR, [LEXENV, #9]
; 4B6C:       C0033FD6         BLR LR
; 4B70:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 4B74:       580B40F9         LDR NFP, [CFP, #16]
; 4B78:       4F3B40F9         LDR R5, [CFP, #112]
; 4B7C:       5F011DEB         CMP R0, NULL
; 4B80:       40F5FF54         BEQ L5
; 4B84:       DAFFFF17         B L10
; 4B88: L12:  A00A28D4         BRK #16469                     ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 4B8C: L13:  4A2B40F9         LDR R0, [CFP, #80]
; 4B90:       E04921D4         BRK #2639                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 4B94: L14:  EA030CAA         MOV R0, R2
; 4B98:       2E0001AB         ADDS R4, NL1, NL1
; 4B9C:       E7010054         BVC L16
; 4BA0:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 4BA4:       A97A47A9         LDP TMP, LR, [THREAD, #112]    ; mixed-tlab.{free-pointer, end-addr}
; 4BA8:       2E410091         ADD R4, TMP, #16
; 4BAC:       DF011EEB         CMP R4, LR
; 4BB0:       48240054         BHI L53
; 4BB4:       AE3A00F9         STR R4, [THREAD, #112]         ; mixed-tlab
; 4BB8: L15:  2E3D0091         ADD R4, TMP, #15
; 4BBC:       3E2280D2         MOVZ LR, #273
; 4BC0:       3E0500A9         STP LR, NL1, [TMP]
; 4BC4:       BF3A03D5         DMB ISHST
; 4BC8:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 4BCC:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 4BD0:       5E0000B4         CBZ LR, L16
; 4BD4:       200120D4         BRK #9                         ; Pending interrupt trap
; 4BD8: L16:  E0031BAA         MOV NL0, CSP
; 4BDC:       7A8703F8         STR CFP, [CSP], #56
; 4BE0:       4B3342A9         LDP R1, R2, [CFP, #32]
; 4BE4:       4D3340F9         LDR R3, [CFP, #96]
; 4BE8:       4F1F40F9         LDR R5, [CFP, #56]
; 4BEC:       0F3802A9         STP R5, R4, [NL0, #32]
; 4BF0:       4E2340F9         LDR R4, [CFP, #64]
; 4BF4:       0E1800F9         STR R4, [NL0, #48]
; 4BF8:       96DEFF58         LDR LEXENV, #x700AB047C8       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::CLOSURE-CHECKING-STOP-STATE>
; 4BFC:       D70180D2         MOVZ NARGS, #14
; 4C00:       580B00F9         STR NFP, [CFP, #16]
; 4C04:       FA0300AA         MOV CFP, NL0
; 4C08:       DE9240F8         LDR LR, [LEXENV, #9]
; 4C0C:       C0033FD6         BLR LR
; 4C10:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 4C14:       580B40F9         LDR NFP, [CFP, #16]
; 4C18:       B5FFFF17         B L10
; 4C1C: L17:  000340F9         LDR NL0, [NFP]
; 4C20:       00040091         ADD NL0, NL0, #1
; 4C24:       E10300AA         MOV NL1, NL0
; 4C28:       AFFFFF17         B L9
; 4C2C: L18:  ABDEFF58         LDR R1, #x700AB04800           ; :RULE
; 4C30:       5F010BEB         CMP R0, R1
; 4C34:       C0F4FF54         BEQ L8
; 4C38:       8BDEFF58         LDR R1, #x700AB04808           ; :PREDICATE
; 4C3C:       5F010BEB         CMP R0, R1
; 4C40:       60F4FF54         BEQ L8
; 4C44:       6BDEFF58         LDR R1, #x700AB04810           ; :ACTION
; 4C48:       5F010BEB         CMP R0, R1
; 4C4C:       00F4FF54         BEQ L8
; 4C50:       4BDEFF58         LDR R1, #x700AB04818           ; :PRECEDENCE
; 4C54:       5F010BEB         CMP R0, R1
; 4C58:       A0F3FF54         BEQ L8
; 4C5C:       4CBF06A9         STP R2, R5, [CFP, #104]
; 4C60:       010700F9         STR NL1, [NFP, #8]
; 4C64:       EB030CAA         MOV R1, R2
; 4C68:       7A0300F9         STR CFP, [CSP]
; 4C6C:       4A1740F9         LDR R0, [CFP, #40]
; 4C70:       16DBFF58         LDR LEXENV, #x700AB047D0       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::BUSY-ADD>
; 4C74:       970080D2         MOVZ NARGS, #4
; 4C78:       580B00F9         STR NFP, [CFP, #16]
; 4C7C:       FA031BAA         MOV CFP, CSP
; 4C80:       DE9240F8         LDR LR, [LEXENV, #9]
; 4C84:       C0033FD6         BLR LR
; 4C88:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 4C8C:       580B40F9         LDR NFP, [CFP, #16]
; 4C90:       010740F9         LDR NL1, [NFP, #8]
; 4C94:       4CBF46A9         LDP R2, R5, [CFP, #104]
; 4C98:       5F011DEB         CMP R0, NULL
; 4C9C:       80000054         BEQ L19
; 4CA0:       ABE30091         ADD R1, NULL, #56              ; T
; 4CA4:       5F010BEB         CMP R0, R1
; 4CA8:       81000054         BNE L20
; 4CAC: L19:  5F011DEB         CMP R0, NULL
; 4CB0:       AC038C9A         CSEL R2, NULL, R2, EQ
; 4CB4:       86FFFF17         B L8
; 4CB8: L20:  A05221D4         BRK #2709                      ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; 4CBC: L21:  2BDBFF58         LDR R1, #x700AB04820           ; 'CNVRS/ANTLR-RUNTIME::*CURRENT-DFA*
; 4CC0:       61515FB8         LDR WNL1, [R1, #-11]
; 4CC4:       AA6A61F8         LDR R0, [THREAD, NL1]
; 4CC8:       5F0500B1         CMN R0, #1
; 4CCC:       41000054         BNE L22
; 4CD0:       6A1140F8         LDR R0, [R1, #1]
; 4CD4: L22:  5F2500F1         CMP R0, #9
; 4CD8:       801B0054         BEQ L54
; 4CDC:       5F011DEB         CMP R0, NULL
; 4CE0:       E1050054         BNE L28
; 4CE4: L23:  810D4092         AND NL1, R2, #15
; 4CE8:       3F0C00F1         CMP NL1, #3
; 4CEC:       41050054         BNE L27
; 4CF0:       8E5140F8         LDR R4, [R2, #5]
; 4CF4:       C25145B8         LDR WNL2, [R4, #85]
; 4CF8:       41DBFF18         LDR WNL1, #x700AB04860
; 4CFC:       5F00016B         CMP WNL2, WNL1
; 4D00:       A1040054         BNE L27
; 4D04:       80D142F8         LDR NL0, [R2, #45]
; 4D08:       00FC4193         ASR NL0, NL0, #1
; 4D0C:       00040091         ADD NL0, NL0, #1
; 4D10:       1F0000AB         CMN NL0, NL0
; 4D14:       E6030054         BVS L26
; 4D18:       4C3700F9         STR R2, [CFP, #104]
; 4D1C:       00F87FD3         LSL NL0, NL0, #1
; 4D20:       80D102F8         STR NL0, [R2, #45]
; 4D24:       EB030CAA         MOV R1, R2
; 4D28:       7A0300F9         STR CFP, [CSP]
; 4D2C:       4A1740F9         LDR R0, [CFP, #40]
; 4D30:       16D5FF58         LDR LEXENV, #x700AB047D0       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::BUSY-ADD>
; 4D34:       970080D2         MOVZ NARGS, #4
; 4D38:       580B00F9         STR NFP, [CFP, #16]
; 4D3C:       FA031BAA         MOV CFP, CSP
; 4D40:       DE9240F8         LDR LR, [LEXENV, #9]
; 4D44:       C0033FD6         BLR LR
; 4D48:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 4D4C:       580B40F9         LDR NFP, [CFP, #16]
; 4D50:       4C3740F9         LDR R2, [CFP, #104]
; 4D54:       5F011DEB         CMP R0, NULL
; 4D58:       80000054         BEQ L24
; 4D5C:       ABE30091         ADD R1, NULL, #56              ; T
; 4D60:       5F010BEB         CMP R0, R1
; 4D64:       41010054         BNE L25
; 4D68: L24:  5F011DEB         CMP R0, NULL
; 4D6C:       AC038C9A         CSEL R2, NULL, R2, EQ
; 4D70:       4A1340F9         LDR R0, [CFP, #32]
; 4D74:       ABE30091         ADD R1, NULL, #56              ; T
; 4D78:       4BD103F8         STR R1, [R0, #61]
; 4D7C:       000340F9         LDR NL0, [NFP]
; 4D80:       000400D1         SUB NL0, NL0, #1
; 4D84:       E10300AA         MOV NL1, NL0
; 4D88:       57FFFF17         B L9
; 4D8C: L25:  A05221D4         BRK #2709                      ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; 4D90: L26:  A00A28D4         BRK #16469                     ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 4D94: L27:  608321D4         BRK #3099                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 4D98:       3B               BYTE #X3B                      ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA4E5D3}>
; 4D99:       .ALIGN           4
; 4D9C: L28:  2BD4FF58         LDR R1, #x700AB04820           ; 'CNVRS/ANTLR-RUNTIME::*CURRENT-DFA*
; 4DA0:       61515FB8         LDR WNL1, [R1, #-11]
; 4DA4:       AA6A61F8         LDR R0, [THREAD, NL1]
; 4DA8:       5F0500B1         CMN R0, #1
; 4DAC:       41000054         BNE L29
; 4DB0:       6A1140F8         LDR R0, [R1, #1]
; 4DB4: L29:  5F2500F1         CMP R0, #9
; 4DB8:       A0140054         BEQ L55
; 4DBC:       5F011DEB         CMP R0, NULL
; 4DC0:       A00B0054         BEQ L39
; 4DC4:       405141F8         LDR NL0, [R0, #21]
; 4DC8:       0BD1FF58         LDR R1, #x700AB047E8           ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; 4DCC:       61515FB8         LDR WNL1, [R1, #-11]
; 4DD0:       AA6A61F8         LDR R0, [THREAD, NL1]
; 4DD4:       5F0500B1         CMN R0, #1
; 4DD8:       41000054         BNE L30
; 4DDC:       6A1140F8         LDR R0, [R1, #1]
; 4DE0: L30:  5F2500F1         CMP R0, #9
; 4DE4:       60130054         BEQ L56
; 4DE8:       5F011DEB         CMP R0, NULL
; 4DEC:       000A0054         BEQ L38
; 4DF0:       4AD140F8         LDR R0, [R0, #13]
; 4DF4:       4AD140F8         LDR R0, [R0, #13]
; 4DF8:       41915FF8         LDR NL1, [R0, #-7]
; 4DFC:       3F0000EB         CMP NL1, NL0
; 4E00:       A9120054         BLS L57
; 4E04:       4909008B         ADD TMP, R0, NL0, LSL #2
; 4E08:       2A1140F8         LDR R0, [TMP, #1]
; 4E0C:       410D4092         AND NL1, R0, #15
; 4E10:       3F0C00F1         CMP NL1, #3
; 4E14:       81080054         BNE L37
; 4E18:       4E5140F8         LDR R4, [R0, #5]
; 4E1C:       C25145B8         LDR WNL2, [R4, #85]
; 4E20:       41D2FF18         LDR WNL1, #x700AB04868
; 4E24:       5F00016B         CMP WNL2, WNL1
; 4E28:       E1070054         BNE L37
; 4E2C:       4A5143F8         LDR R0, [R0, #53]
; 4E30:       5F011DEB         CMP R0, NULL
; 4E34:       80F5FF54         BEQ L23
; 4E38:       E3D142F8         LDR NL3, [R5, #45]
; 4E3C:       2BCFFF58         LDR R1, #x700AB04820           ; 'CNVRS/ANTLR-RUNTIME::*CURRENT-DFA*
; 4E40:       61515FB8         LDR WNL1, [R1, #-11]
; 4E44:       AA6A61F8         LDR R0, [THREAD, NL1]
; 4E48:       5F0500B1         CMN R0, #1
; 4E4C:       41000054         BNE L31
; 4E50:       6A1140F8         LDR R0, [R1, #1]
; 4E54: L31:  5F2500F1         CMP R0, #9
; 4E58:       20100054         BEQ L58
; 4E5C:       5F011DEB         CMP R0, NULL
; 4E60:       E0050054         BEQ L36
; 4E64:       405141F8         LDR NL0, [R0, #21]
; 4E68:       0BCCFF58         LDR R1, #x700AB047E8           ; 'CNVRS/ANTLR-RUNTIME::*SIMULATOR*
; 4E6C:       61515FB8         LDR WNL1, [R1, #-11]
; 4E70:       AA6A61F8         LDR R0, [THREAD, NL1]
; 4E74:       5F0500B1         CMN R0, #1
; 4E78:       41000054         BNE L32
; 4E7C:       6A1140F8         LDR R0, [R1, #1]
; 4E80: L32:  5F2500F1         CMP R0, #9
; 4E84:       E00E0054         BEQ L59
; 4E88:       5F011DEB         CMP R0, NULL
; 4E8C:       40040054         BEQ L35
; 4E90:       4AD140F8         LDR R0, [R0, #13]
; 4E94:       4AD140F8         LDR R0, [R0, #13]
; 4E98:       41915FF8         LDR NL1, [R0, #-7]
; 4E9C:       3F0000EB         CMP NL1, NL0
; 4EA0:       290E0054         BLS L60
; 4EA4:       4909008B         ADD TMP, R0, NL0, LSL #2
; 4EA8:       2A1140F8         LDR R0, [TMP, #1]
; 4EAC:       410D4092         AND NL1, R0, #15
; 4EB0:       3F0C00F1         CMP NL1, #3
; 4EB4:       C1020054         BNE L34
; 4EB8:       4E5140F8         LDR R4, [R0, #5]
; 4EBC:       C25145B8         LDR WNL2, [R4, #85]
; 4EC0:       41CDFF18         LDR WNL1, #x700AB04868
; 4EC4:       5F00016B         CMP WNL2, WNL1
; 4EC8:       21020054         BNE L34
; 4ECC:       40D141F8         LDR NL0, [R0, #29]
; 4ED0:       1F0003EB         CMP NL0, NL3
; 4ED4:       81F0FF54         BNE L23
; 4ED8:       810D4092         AND NL1, R2, #15
; 4EDC:       3F0C00F1         CMP NL1, #3
; 4EE0:       21010054         BNE L33
; 4EE4:       8E5140F8         LDR R4, [R2, #5]
; 4EE8:       C25145B8         LDR WNL2, [R4, #85]
; 4EEC:       A1CBFF18         LDR WNL1, #x700AB04860
; 4EF0:       5F00016B         CMP WNL2, WNL1
; 4EF4:       81000054         BNE L33
; 4EF8:       AAE30091         ADD R0, NULL, #56              ; T
; 4EFC:       8A5103F8         STR R0, [R2, #53]
; 4F00:       79FFFF17         B L23
; 4F04: L33:  608321D4         BRK #3099                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 4F08:       3B               BYTE #X3B                      ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA4E5D3}>
; 4F09:       .ALIGN           4
; 4F0C: L34:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 4F10:       5F               BYTE #X5F                      ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA28883}>
; 4F11:       .ALIGN           4
; 4F14: L35:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4F18:       63               BYTE #X63                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 4F19:       .ALIGN           4
; 4F1C: L36:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4F20:       67               BYTE #X67                      ; #<SB-KERNEL:LAYOUT (ID=398) for CNVRS/ANTLR-RUNTIME:DFA {700AAD1FA3}>
; 4F21:       .ALIGN           4
; 4F24: L37:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 4F28:       5F               BYTE #X5F                      ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA28883}>
; 4F29:       .ALIGN           4
; 4F2C: L38:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4F30:       63               BYTE #X63                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 4F31:       .ALIGN           4
; 4F34: L39:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4F38:       67               BYTE #X67                      ; #<SB-KERNEL:LAYOUT (ID=398) for CNVRS/ANTLR-RUNTIME:DFA {700AAD1FA3}>
; 4F39:       .ALIGN           4
; 4F3C: L40:  E10D4092         AND NL1, R5, #15
; 4F40:       3F0C00F1         CMP NL1, #3
; 4F44:       81010054         BNE L41
; 4F48:       EE5140F8         LDR R4, [R5, #5]
; 4F4C:       C25145B8         LDR WNL2, [R4, #85]
; 4F50:       E1C8FF18         LDR WNL1, #x700AB0486C
; 4F54:       5F00016B         CMP WNL2, WNL1
; 4F58:       E1000054         BNE L41
; 4F5C:       EAD140F8         LDR R0, [R5, #13]
; 4F60:       8BC5FF58         LDR R1, #x700AB04810           ; :ACTION
; 4F64:       5F010BEB         CMP R0, R1
; 4F68:       60D6FF54         BEQ L6
; 4F6C:       AAE30091         ADD R0, NULL, #56              ; T
; 4F70:       B2FEFF17         B L7
; 4F74: L41:  60E321D4         BRK #3867                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; 4F78:       6B               BYTE #X6B                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 4F79:       .ALIGN           4
; 4F7C: L42:  4B5142F8         LDR R1, [R0, #37]
; 4F80:       16000014         B L45
; 4F84: L43:  6A915FF8         LDR R0, [R1, #-7]
; 4F88:       410D4092         AND NL1, R0, #15
; 4F8C:       3F0C00F1         CMP NL1, #3
; 4F90:       01040054         BNE L48
; 4F94:       4E5140F8         LDR R4, [R0, #5]
; 4F98:       C25145B8         LDR WNL2, [R4, #85]
; 4F9C:       81C6FF18         LDR WNL1, #x700AB0486C
; 4FA0:       5F00016B         CMP WNL2, WNL1
; 4FA4:       61030054         BNE L48
; 4FA8:       4AD140F8         LDR R0, [R0, #13]
; 4FAC:       6CC2FF58         LDR R2, #x700AB047F8           ; :EPSILON
; 4FB0:       5F010CEB         CMP R0, R2
; 4FB4:       80000054         BEQ L44
; 4FB8:       4CC2FF58         LDR R2, #x700AB04800           ; :RULE
; 4FBC:       5F010CEB         CMP R0, R2
; 4FC0:       41010054         BNE L47
; 4FC4: L44:  6A1140F8         LDR R0, [R1, #1]
; 4FC8:       410D4092         AND NL1, R0, #15
; 4FCC:       3F1C00F1         CMP NL1, #7
; 4FD0:       A1000054         BNE L46
; 4FD4:       EB030AAA         MOV R1, R0
; 4FD8: L45:  7F011DEB         CMP R1, NULL
; 4FDC:       00D0FF54         BEQ L2
; 4FE0:       E9FFFF17         B L43
; 4FE4: L46:  E04921D4         BRK #2639                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 4FE8: L47:  0CC1FF58         LDR R2, #x700AB04808           ; :PREDICATE
; 4FEC:       5F010CEB         CMP R0, R2
; 4FF0:       A0FEFF54         BEQ L44
; 4FF4:       ECC0FF58         LDR R2, #x700AB04810           ; :ACTION
; 4FF8:       5F010CEB         CMP R0, R2
; 4FFC:       40FEFF54         BEQ L44
; 5000:       CCC0FF58         LDR R2, #x700AB04818           ; :PRECEDENCE
; 5004:       5F010CEB         CMP R0, R2
; 5008:       E0FDFF54         BEQ L44
; 500C:       6AFEFF17         B L1
; 5010: L48:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 5014:       6B               BYTE #X6B                      ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/ANTLR-RUNTIME:ATN-TRANSITION {700AA44DD3}>
; 5015:       .ALIGN           4
; 5018: L49:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 501C:       5F               BYTE #X5F                      ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/ANTLR-RUNTIME:ATN-STATE {700AA28883}>
; 501D:       .ALIGN           4
; 5020: L50:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 5024:       63               BYTE #X63                      ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/ANTLR-RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 5025:       .ALIGN           4
; 5028:       E00120D4         BRK #15                        ; Invalid argument count trap
; 502C: L51:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 5030: L52:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 5034:       01               BYTE #X01                      ; NL0
; 5035:       .ALIGN           4
; 5038: L53:  090280D2         MOVZ TMP, #16
; 503C:       EEC0FF58         LDR R4, #x700AB04858           ; SB-VM::ALLOC-TRAMP
; 5040:       C0013FD6         BLR R4
; 5044:       DDFEFF17         B L15
; 5048: L54:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 504C: L55:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 5050: L56:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 5054: L57:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 5058:       01               BYTE #X01                      ; NL0
; 5059:       .ALIGN           4
; 505C: L58:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 5060: L59:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 5064: L60:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 5068:       01               BYTE #X01                      ; NL0
; 5069:       .ALIGN           4
