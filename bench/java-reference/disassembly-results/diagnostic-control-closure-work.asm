; disassembly for DIAGNOSTIC-CONTROL-CLOSURE-WORK
; Size: 1892 bytes. Origin: #x70055B3A38                      ; DIAGNOSTIC-CONTROL-CLOSURE-WORK
; 3A38:       4A0F40F9         LDR R0, [CFP, #24]
; 3A3C:       40D140F8         LDR NL0, [R0, #13]
; 3A40:       4BF5FF58         LDR R1, #x70055B38E8           ; '*SIMULATOR*
; 3A44:       61515FB8         LDR WNL1, [R1, #-11]
; 3A48:       AA6A61F8         LDR R0, [THREAD, NL1]
; 3A4C:       5F0500B1         CMN R0, #1
; 3A50:       41000054         BNE L0
; 3A54:       6A1140F8         LDR R0, [R1, #1]
; 3A58: L0:   5F2500F1         CMP R0, #9
; 3A5C:       00380054         BEQ L48
; 3A60:       5F011DEB         CMP R0, NULL
; 3A64:       60370054         BEQ L47
; 3A68:       4AD140F8         LDR R0, [R0, #13]
; 3A6C:       4AD140F8         LDR R0, [R0, #13]
; 3A70:       41915FF8         LDR NL1, [R0, #-7]
; 3A74:       3F0000EB         CMP NL1, NL0
; 3A78:       49370054         BLS L49
; 3A7C:       4909008B         ADD TMP, R0, NL0, LSL #2
; 3A80:       2A1140F8         LDR R0, [TMP, #1]
; 3A84:       4A2700F9         STR R0, [CFP, #72]
; 3A88:       410D4092         AND NL1, R0, #15
; 3A8C:       3F0C00F1         CMP NL1, #3
; 3A90:       C1350054         BNE L46
; 3A94:       4E5140F8         LDR R4, [R0, #5]
; 3A98:       C25145B8         LDR WNL2, [R4, #85]
; 3A9C:       61F6FF18         LDR WNL1, #x70055B3968
; 3AA0:       5F00016B         CMP WNL2, WNL1
; 3AA4:       21350054         BNE L46
; 3AA8:       4B5142F8         LDR R1, [R0, #37]
; 3AAC:       7F011DEB         CMP R1, NULL
; 3AB0:       E12F0054         BNE L39
; 3AB4: L1:   7A0300F9         STR CFP, [CSP]
; 3AB8:       4BAB41A9         LDP R1, R0, [CFP, #24]
; 3ABC:       B6EFFF58         LDR LEXENV, #x70055B38B0       ; #<SB-KERNEL:FDEFN CONFIG-SET-ADD>
; 3AC0:       970080D2         MOVZ NARGS, #4
; 3AC4:       580B00F9         STR NFP, [CFP, #16]
; 3AC8:       FA031BAA         MOV CFP, CSP
; 3ACC:       DE9240F8         LDR LR, [LEXENV, #9]
; 3AD0:       C0033FD6         BLR LR
; 3AD4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 3AD8:       580B40F9         LDR NFP, [CFP, #16]
; 3ADC: L2:   4A2740F9         LDR R0, [CFP, #72]
; 3AE0:       4A5142F8         LDR R0, [R0, #37]
; 3AE4:       4A7F05A9         STP R0, ZR, [CFP, #80]
; 3AE8:       4A2B40F9         LDR R0, [CFP, #80]
; 3AEC:       5F011DEB         CMP R0, NULL
; 3AF0:       E1000054         BNE L4
; 3AF4: L3:   EA031DAA         MOV R0, NULL
; 3AF8:       1F430091         ADD NSP, NFP, #16
; 3AFC:       FB031AAA         MOV CSP, CFP
; 3B00:       5A7B40A9         LDP CFP, LR, [CFP]
; 3B04:       BF0300F1         CMP NULL, #0
; 3B08:       C0035FD6         RET
; 3B0C: L4:   4A2B40F9         LDR R0, [CFP, #80]
; 3B10:       4A915FF8         LDR R0, [R0, #-7]
; 3B14:       EF030AAA         MOV R5, R0
; 3B18:       4A2B40F9         LDR R0, [CFP, #80]
; 3B1C:       4A1140F8         LDR R0, [R0, #1]
; 3B20:       4A2B00F9         STR R0, [CFP, #80]
; 3B24:       56000014         B L11
; 3B28: L5:   4A1B40F9         LDR R0, [CFP, #48]
; 3B2C:       5F011DEB         CMP R0, NULL
; 3B30:       E1290054         BNE L37
; 3B34: L6:   EA031DAA         MOV R0, NULL
; 3B38: L7:   4F3B00F9         STR R5, [CFP, #112]
; 3B3C:       4A3300F9         STR R0, [CFP, #96]
; 3B40:       EB030FAA         MOV R1, R5
; 3B44:       000340F9         LDR NL0, [NFP]
; 3B48:       1F0000F1         CMP NL0, #0
; 3B4C:       AAE30091         ADD R0, NULL, #56              ; T
; 3B50:       4D019D9A         CSEL R3, R0, NULL, EQ
; 3B54:       E0031BAA         MOV NL0, CSP
; 3B58:       7A0703F8         STR CFP, [CSP], #48
; 3B5C:       4A0F40F9         LDR R0, [CFP, #24]
; 3B60:       4C3340F9         LDR R2, [CFP, #96]
; 3B64:       4E1F40F9         LDR R4, [CFP, #56]
; 3B68:       0E1000F9         STR R4, [NL0, #32]
; 3B6C:       4E2340F9         LDR R4, [CFP, #64]
; 3B70:       0E1400F9         STR R4, [NL0, #40]
; 3B74:       36EAFF58         LDR LEXENV, #x70055B38B8       ; #<SB-KERNEL:FDEFN GET-EPSILON-TARGET>
; 3B78:       970180D2         MOVZ NARGS, #12
; 3B7C:       580B00F9         STR NFP, [CFP, #16]
; 3B80:       FA0300AA         MOV CFP, NL0
; 3B84:       DE9240F8         LDR LR, [LEXENV, #9]
; 3B88:       C0033FD6         BLR LR
; 3B8C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 3B90:       580B40F9         LDR NFP, [CFP, #16]
; 3B94:       4F3B40F9         LDR R5, [CFP, #112]
; 3B98:       EC030AAA         MOV R2, R0
; 3B9C:       030340F9         LDR NL3, [NFP]
; 3BA0:       9F011DEB         CMP R2, NULL
; 3BA4:       A0030054         BEQ L10
; 3BA8:       4A2740F9         LDR R0, [CFP, #72]
; 3BAC:       4A5141F8         LDR R0, [R0, #21]
; 3BB0:       0BEAFF58         LDR R1, #x70055B38F0           ; :RULE-STOP
; 3BB4:       5F010BEB         CMP R0, R1
; 3BB8:       20110054         BEQ L19
; 3BBC:       E10D4092         AND NL1, R5, #15
; 3BC0:       3F0C00F1         CMP NL1, #3
; 3BC4:       81100054         BNE L18
; 3BC8:       EE5140F8         LDR R4, [R5, #5]
; 3BCC:       C25145B8         LDR WNL2, [R4, #85]
; 3BD0:       E1ECFF18         LDR WNL1, #x70055B396C
; 3BD4:       5F00016B         CMP WNL2, WNL1
; 3BD8:       E10F0054         BNE L18
; 3BDC:       EAD140F8         LDR R0, [R5, #13]
; 3BE0:       CBE8FF58         LDR R1, #x70055B38F8           ; :EPSILON
; 3BE4:       5F010BEB         CMP R0, R1
; 3BE8:       80000054         BEQ L8
; 3BEC:       ABE8FF58         LDR R1, #x70055B3900           ; :RULE
; 3BF0:       5F010BEB         CMP R0, R1
; 3BF4:       610B0054         BNE L17
; 3BF8: L8:   EAD140F8         LDR R0, [R5, #13]
; 3BFC:       2BE8FF58         LDR R1, #x70055B3900           ; :RULE
; 3C00:       5F010BEB         CMP R0, R1
; 3C04:       61000054         BNE L9
; 3C08:       000340F9         LDR NL0, [NFP]
; 3C0C:       200AF8B6         TBZ NL0, #63, L16
; 3C10: L9:   9F011DEB         CMP R2, NULL
; 3C14:       A1050054         BNE L13
; 3C18: L10:  4A2B40F9         LDR R0, [CFP, #80]
; 3C1C:       410D4092         AND NL1, R0, #15
; 3C20:       3F1C00F1         CMP NL1, #7
; 3C24:       E1040054         BNE L12
; 3C28:       4A2B40F9         LDR R0, [CFP, #80]
; 3C2C:       5F011DEB         CMP R0, NULL
; 3C30:       20F6FF54         BEQ L3
; 3C34:       4A2B40F9         LDR R0, [CFP, #80]
; 3C38:       4A915FF8         LDR R0, [R0, #-7]
; 3C3C:       EF030AAA         MOV R5, R0
; 3C40:       4F3B00F9         STR R5, [CFP, #112]
; 3C44:       4A2B40F9         LDR R0, [CFP, #80]
; 3C48:       4A1140F8         LDR R0, [R0, #1]
; 3C4C:       4A2B00F9         STR R0, [CFP, #80]
; 3C50:       4A2F40F9         LDR R0, [CFP, #88]
; 3C54:       7A0300F9         STR CFP, [CSP]
; 3C58:       4B0080D2         MOVZ R1, #2
; 3C5C:       580B00F9         STR NFP, [CFP, #16]
; 3C60:       FA031BAA         MOV CFP, CSP
; 3C64:       29AA80D2         MOVZ TMP, #1361
; 3C68:       BE6B69F8         LDR LR, [NULL, TMP]            ; SB-KERNEL:TWO-ARG-+
; 3C6C:       C0033FD6         BLR LR
; 3C70:       580B40F9         LDR NFP, [CFP, #16]
; 3C74:       4F3B40F9         LDR R5, [CFP, #112]
; 3C78:       4A2F00F9         STR R0, [CFP, #88]
; 3C7C: L11:  4A2F40F9         LDR R0, [CFP, #88]
; 3C80:       4AF5FFB5         CBNZ R0, L5
; 3C84:       4F3B00F9         STR R5, [CFP, #112]
; 3C88:       7A0300F9         STR CFP, [CSP]
; 3C8C:       4A0F40F9         LDR R0, [CFP, #24]
; 3C90:       96E1FF58         LDR LEXENV, #x70055B38C0       ; #<SB-KERNEL:FDEFN CAN-DROP-LOOP-ENTRY-EDGE-IN-LEFT-RECURSIVE-RULE>
; 3C94:       570080D2         MOVZ NARGS, #2
; 3C98:       580B00F9         STR NFP, [CFP, #16]
; 3C9C:       FA031BAA         MOV CFP, CSP
; 3CA0:       DE9240F8         LDR LR, [LEXENV, #9]
; 3CA4:       C0033FD6         BLR LR
; 3CA8:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 3CAC:       580B40F9         LDR NFP, [CFP, #16]
; 3CB0:       4F3B40F9         LDR R5, [CFP, #112]
; 3CB4:       5F011DEB         CMP R0, NULL
; 3CB8:       80F3FF54         BEQ L5
; 3CBC:       D7FFFF17         B L10
; 3CC0: L12:  4A2B40F9         LDR R0, [CFP, #80]
; 3CC4:       E04921D4         BRK #2639                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 3CC8: L13:  EA030CAA         MOV R0, R2
; 3CCC:       6E0003AB         ADDS R4, NL3, NL3
; 3CD0:       E7010054         BVC L15
; 3CD4:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 3CD8:       A97A47A9         LDP TMP, LR, [THREAD, #112]    ; mixed-tlab.{free-pointer, end-addr}
; 3CDC:       2E410091         ADD R4, TMP, #16
; 3CE0:       DF011EEB         CMP R4, LR
; 3CE4:       28240054         BHI L50
; 3CE8:       AE3A00F9         STR R4, [THREAD, #112]         ; mixed-tlab
; 3CEC: L14:  2E3D0091         ADD R4, TMP, #15
; 3CF0:       3E2280D2         MOVZ LR, #273
; 3CF4:       3E0D00A9         STP LR, NL3, [TMP]
; 3CF8:       BF3A03D5         DMB ISHST
; 3CFC:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 3D00:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 3D04:       5E0000B4         CBZ LR, L15
; 3D08:       200120D4         BRK #9                         ; Pending interrupt trap
; 3D0C: L15:  E0031BAA         MOV NL0, CSP
; 3D10:       7A8703F8         STR CFP, [CSP], #56
; 3D14:       4B3342A9         LDP R1, R2, [CFP, #32]
; 3D18:       4D3340F9         LDR R3, [CFP, #96]
; 3D1C:       4F1F40F9         LDR R5, [CFP, #56]
; 3D20:       0F3802A9         STP R5, R4, [NL0, #32]
; 3D24:       4E2340F9         LDR R4, [CFP, #64]
; 3D28:       0E1800F9         STR R4, [NL0, #48]
; 3D2C:       F6DCFF58         LDR LEXENV, #x70055B38C8       ; #<SB-KERNEL:FDEFN CLOSURE-CHECKING-STOP-STATE>
; 3D30:       D70180D2         MOVZ NARGS, #14
; 3D34:       580B00F9         STR NFP, [CFP, #16]
; 3D38:       FA0300AA         MOV CFP, NL0
; 3D3C:       DE9240F8         LDR LR, [LEXENV, #9]
; 3D40:       C0033FD6         BLR LR
; 3D44:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 3D48:       580B40F9         LDR NFP, [CFP, #16]
; 3D4C:       B3FFFF17         B L10
; 3D50: L16:  000340F9         LDR NL0, [NFP]
; 3D54:       00040091         ADD NL0, NL0, #1
; 3D58:       E30300AA         MOV NL3, NL0
; 3D5C:       ADFFFF17         B L9
; 3D60: L17:  4BDDFF58         LDR R1, #x70055B3908           ; :PREDICATE
; 3D64:       5F010BEB         CMP R0, R1
; 3D68:       80F4FF54         BEQ L8
; 3D6C:       2BDDFF58         LDR R1, #x70055B3910           ; :ACTION
; 3D70:       5F010BEB         CMP R0, R1
; 3D74:       20F4FF54         BEQ L8
; 3D78:       0BDDFF58         LDR R1, #x70055B3918           ; :PRECEDENCE
; 3D7C:       5F010BEB         CMP R0, R1
; 3D80:       C0F3FF54         BEQ L8
; 3D84:       4C3700F9         STR R2, [CFP, #104]
; 3D88:       030700F9         STR NL3, [NFP, #8]
; 3D8C:       4F3B00F9         STR R5, [CFP, #112]
; 3D90:       EB030CAA         MOV R1, R2
; 3D94:       7A0300F9         STR CFP, [CSP]
; 3D98:       4A1740F9         LDR R0, [CFP, #40]
; 3D9C:       B6D9FF58         LDR LEXENV, #x70055B38D0       ; #<SB-KERNEL:FDEFN BUSY-ADD>
; 3DA0:       970080D2         MOVZ NARGS, #4
; 3DA4:       580B00F9         STR NFP, [CFP, #16]
; 3DA8:       FA031BAA         MOV CFP, CSP
; 3DAC:       DE9240F8         LDR LR, [LEXENV, #9]
; 3DB0:       C0033FD6         BLR LR
; 3DB4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 3DB8:       580B40F9         LDR NFP, [CFP, #16]
; 3DBC:       4F3B40F9         LDR R5, [CFP, #112]
; 3DC0:       030740F9         LDR NL3, [NFP, #8]
; 3DC4:       4C3740F9         LDR R2, [CFP, #104]
; 3DC8:       5F011DEB         CMP R0, NULL
; 3DCC:       AC038C9A         CSEL R2, NULL, R2, EQ
; 3DD0:       8AFFFF17         B L8
; 3DD4: L18:  60E321D4         BRK #3867                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; 3DD8:       5B               BYTE #X5B                      ; #<SB-KERNEL:LAYOUT (ID=394) for ATN-TRANSITION {700CD64783}>
; 3DD9:       .ALIGN           4
; 3DDC: L19:  6BDAFF58         LDR R1, #x70055B3928           ; '*CURRENT-DFA*
; 3DE0:       61515FB8         LDR WNL1, [R1, #-11]
; 3DE4:       AA6A61F8         LDR R0, [THREAD, NL1]
; 3DE8:       5F0500B1         CMN R0, #1
; 3DEC:       41000054         BNE L20
; 3DF0:       6A1140F8         LDR R0, [R1, #1]
; 3DF4: L20:  5F2500F1         CMP R0, #9
; 3DF8:       001C0054         BEQ L51
; 3DFC:       5F011DEB         CMP R0, NULL
; 3E00:       21050054         BNE L24
; 3E04: L21:  810D4092         AND NL1, R2, #15
; 3E08:       3F0C00F1         CMP NL1, #3
; 3E0C:       81040054         BNE L23
; 3E10:       8E5140F8         LDR R4, [R2, #5]
; 3E14:       C25145B8         LDR WNL2, [R4, #85]
; 3E18:       41DAFF18         LDR WNL1, #x70055B3960
; 3E1C:       5F00016B         CMP WNL2, WNL1
; 3E20:       E1030054         BNE L23
; 3E24:       80D142F8         LDR NL0, [R2, #45]
; 3E28:       00FC4193         ASR NL0, NL0, #1
; 3E2C:       00040091         ADD NL0, NL0, #1
; 3E30:       1F0000AB         CMN NL0, NL0
; 3E34:       26030054         BVS L22
; 3E38:       4C3700F9         STR R2, [CFP, #104]
; 3E3C:       00F87FD3         LSL NL0, NL0, #1
; 3E40:       80D102F8         STR NL0, [R2, #45]
; 3E44:       EB030CAA         MOV R1, R2
; 3E48:       7A0300F9         STR CFP, [CSP]
; 3E4C:       4A1740F9         LDR R0, [CFP, #40]
; 3E50:       16D4FF58         LDR LEXENV, #x70055B38D0       ; #<SB-KERNEL:FDEFN BUSY-ADD>
; 3E54:       970080D2         MOVZ NARGS, #4
; 3E58:       580B00F9         STR NFP, [CFP, #16]
; 3E5C:       FA031BAA         MOV CFP, CSP
; 3E60:       DE9240F8         LDR LR, [LEXENV, #9]
; 3E64:       C0033FD6         BLR LR
; 3E68:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 3E6C:       580B40F9         LDR NFP, [CFP, #16]
; 3E70:       4C3740F9         LDR R2, [CFP, #104]
; 3E74:       5F011DEB         CMP R0, NULL
; 3E78:       AC038C9A         CSEL R2, NULL, R2, EQ
; 3E7C:       4A1340F9         LDR R0, [CFP, #32]
; 3E80:       ABE30091         ADD R1, NULL, #56              ; T
; 3E84:       4BD103F8         STR R1, [R0, #61]
; 3E88:       000340F9         LDR NL0, [NFP]
; 3E8C:       000400D1         SUB NL0, NL0, #1
; 3E90:       E30300AA         MOV NL3, NL0
; 3E94:       5FFFFF17         B L9
; 3E98: L22:  A00A28D4         BRK #16469                     ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 3E9C: L23:  608321D4         BRK #3099                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 3EA0:       3B               BYTE #X3B                      ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 3EA1:       .ALIGN           4
; 3EA4: L24:  2BD4FF58         LDR R1, #x70055B3928           ; '*CURRENT-DFA*
; 3EA8:       61515FB8         LDR WNL1, [R1, #-11]
; 3EAC:       AA6A61F8         LDR R0, [THREAD, NL1]
; 3EB0:       5F0500B1         CMN R0, #1
; 3EB4:       41000054         BNE L25
; 3EB8:       6A1140F8         LDR R0, [R1, #1]
; 3EBC: L25:  5F2500F1         CMP R0, #9
; 3EC0:       E0150054         BEQ L52
; 3EC4:       5F011DEB         CMP R0, NULL
; 3EC8:       E00C0054         BEQ L36
; 3ECC:       405141F8         LDR NL0, [R0, #21]
; 3ED0:       CBD0FF58         LDR R1, #x70055B38E8           ; '*SIMULATOR*
; 3ED4:       61515FB8         LDR WNL1, [R1, #-11]
; 3ED8:       AA6A61F8         LDR R0, [THREAD, NL1]
; 3EDC:       5F0500B1         CMN R0, #1
; 3EE0:       41000054         BNE L26
; 3EE4:       6A1140F8         LDR R0, [R1, #1]
; 3EE8: L26:  5F2500F1         CMP R0, #9
; 3EEC:       A0140054         BEQ L53
; 3EF0:       5F011DEB         CMP R0, NULL
; 3EF4:       400B0054         BEQ L35
; 3EF8:       4AD140F8         LDR R0, [R0, #13]
; 3EFC:       4AD140F8         LDR R0, [R0, #13]
; 3F00:       41915FF8         LDR NL1, [R0, #-7]
; 3F04:       3F0000EB         CMP NL1, NL0
; 3F08:       E9130054         BLS L54
; 3F0C:       4909008B         ADD TMP, R0, NL0, LSL #2
; 3F10:       2A1140F8         LDR R0, [TMP, #1]
; 3F14:       410D4092         AND NL1, R0, #15
; 3F18:       3F0C00F1         CMP NL1, #3
; 3F1C:       C1090054         BNE L34
; 3F20:       4E5140F8         LDR R4, [R0, #5]
; 3F24:       C25145B8         LDR WNL2, [R4, #85]
; 3F28:       01D2FF18         LDR WNL1, #x70055B3968
; 3F2C:       5F00016B         CMP WNL2, WNL1
; 3F30:       21090054         BNE L34
; 3F34:       4A5143F8         LDR R0, [R0, #53]
; 3F38:       5F011DEB         CMP R0, NULL
; 3F3C:       40F6FF54         BEQ L21
; 3F40:       E10D4092         AND NL1, R5, #15
; 3F44:       3F0C00F1         CMP NL1, #3
; 3F48:       21080054         BNE L33
; 3F4C:       EE5140F8         LDR R4, [R5, #5]
; 3F50:       C25145B8         LDR WNL2, [R4, #85]
; 3F54:       C1D0FF18         LDR WNL1, #x70055B396C
; 3F58:       5F00016B         CMP WNL2, WNL1
; 3F5C:       81070054         BNE L33
; 3F60:       E3D142F8         LDR NL3, [R5, #45]
; 3F64:       2BCEFF58         LDR R1, #x70055B3928           ; '*CURRENT-DFA*
; 3F68:       61515FB8         LDR WNL1, [R1, #-11]
; 3F6C:       AA6A61F8         LDR R0, [THREAD, NL1]
; 3F70:       5F0500B1         CMN R0, #1
; 3F74:       41000054         BNE L27
; 3F78:       6A1140F8         LDR R0, [R1, #1]
; 3F7C: L27:  5F2500F1         CMP R0, #9
; 3F80:       60100054         BEQ L55
; 3F84:       5F011DEB         CMP R0, NULL
; 3F88:       E0050054         BEQ L32
; 3F8C:       405141F8         LDR NL0, [R0, #21]
; 3F90:       CBCAFF58         LDR R1, #x70055B38E8           ; '*SIMULATOR*
; 3F94:       61515FB8         LDR WNL1, [R1, #-11]
; 3F98:       AA6A61F8         LDR R0, [THREAD, NL1]
; 3F9C:       5F0500B1         CMN R0, #1
; 3FA0:       41000054         BNE L28
; 3FA4:       6A1140F8         LDR R0, [R1, #1]
; 3FA8: L28:  5F2500F1         CMP R0, #9
; 3FAC:       200F0054         BEQ L56
; 3FB0:       5F011DEB         CMP R0, NULL
; 3FB4:       40040054         BEQ L31
; 3FB8:       4AD140F8         LDR R0, [R0, #13]
; 3FBC:       4AD140F8         LDR R0, [R0, #13]
; 3FC0:       41915FF8         LDR NL1, [R0, #-7]
; 3FC4:       3F0000EB         CMP NL1, NL0
; 3FC8:       690E0054         BLS L57
; 3FCC:       4909008B         ADD TMP, R0, NL0, LSL #2
; 3FD0:       2A1140F8         LDR R0, [TMP, #1]
; 3FD4:       410D4092         AND NL1, R0, #15
; 3FD8:       3F0C00F1         CMP NL1, #3
; 3FDC:       C1020054         BNE L30
; 3FE0:       4E5140F8         LDR R4, [R0, #5]
; 3FE4:       C25145B8         LDR WNL2, [R4, #85]
; 3FE8:       01CCFF18         LDR WNL1, #x70055B3968
; 3FEC:       5F00016B         CMP WNL2, WNL1
; 3FF0:       21020054         BNE L30
; 3FF4:       40D141F8         LDR NL0, [R0, #29]
; 3FF8:       1F0003EB         CMP NL0, NL3
; 3FFC:       41F0FF54         BNE L21
; 4000:       810D4092         AND NL1, R2, #15
; 4004:       3F0C00F1         CMP NL1, #3
; 4008:       21010054         BNE L29
; 400C:       8E5140F8         LDR R4, [R2, #5]
; 4010:       C25145B8         LDR WNL2, [R4, #85]
; 4014:       61CAFF18         LDR WNL1, #x70055B3960
; 4018:       5F00016B         CMP WNL2, WNL1
; 401C:       81000054         BNE L29
; 4020:       AAE30091         ADD R0, NULL, #56              ; T
; 4024:       8A5103F8         STR R0, [R2, #53]
; 4028:       77FFFF17         B L21
; 402C: L29:  608321D4         BRK #3099                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 4030:       3B               BYTE #X3B                      ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 4031:       .ALIGN           4
; 4034: L30:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 4038:       63               BYTE #X63                      ; #<SB-KERNEL:LAYOUT (ID=393) for ATN-STATE {700CD64703}>
; 4039:       .ALIGN           4
; 403C: L31:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4040:       67               BYTE #X67                      ; #<SB-KERNEL:LAYOUT (ID=399) for PARSER-ATN-SIMULATOR {700CD64A83}>
; 4041:       .ALIGN           4
; 4044: L32:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4048:       6B               BYTE #X6B                      ; #<SB-KERNEL:LAYOUT (ID=398) for DFA {700CD64A03}>
; 4049:       .ALIGN           4
; 404C: L33:  60E321D4         BRK #3867                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; 4050:       5B               BYTE #X5B                      ; #<SB-KERNEL:LAYOUT (ID=394) for ATN-TRANSITION {700CD64783}>
; 4051:       .ALIGN           4
; 4054: L34:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 4058:       63               BYTE #X63                      ; #<SB-KERNEL:LAYOUT (ID=393) for ATN-STATE {700CD64703}>
; 4059:       .ALIGN           4
; 405C: L35:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4060:       67               BYTE #X67                      ; #<SB-KERNEL:LAYOUT (ID=399) for PARSER-ATN-SIMULATOR {700CD64A83}>
; 4061:       .ALIGN           4
; 4064: L36:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4068:       6B               BYTE #X6B                      ; #<SB-KERNEL:LAYOUT (ID=398) for DFA {700CD64A03}>
; 4069:       .ALIGN           4
; 406C: L37:  E10D4092         AND NL1, R5, #15
; 4070:       3F0C00F1         CMP NL1, #3
; 4074:       81010054         BNE L38
; 4078:       EE5140F8         LDR R4, [R5, #5]
; 407C:       C25145B8         LDR WNL2, [R4, #85]
; 4080:       61C7FF18         LDR WNL1, #x70055B396C
; 4084:       5F00016B         CMP WNL2, WNL1
; 4088:       E1000054         BNE L38
; 408C:       EAD140F8         LDR R0, [R5, #13]
; 4090:       0BC4FF58         LDR R1, #x70055B3910           ; :ACTION
; 4094:       5F010BEB         CMP R0, R1
; 4098:       E0D4FF54         BEQ L6
; 409C:       AAE30091         ADD R0, NULL, #56              ; T
; 40A0:       A6FEFF17         B L7
; 40A4: L38:  60E321D4         BRK #3867                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; 40A8:       5B               BYTE #X5B                      ; #<SB-KERNEL:LAYOUT (ID=394) for ATN-TRANSITION {700CD64783}>
; 40A9:       .ALIGN           4
; 40AC: L39:  4B5142F8         LDR R1, [R0, #37]
; 40B0:       16000014         B L42
; 40B4: L40:  6A915FF8         LDR R0, [R1, #-7]
; 40B8:       410D4092         AND NL1, R0, #15
; 40BC:       3F0C00F1         CMP NL1, #3
; 40C0:       01040054         BNE L45
; 40C4:       4E5140F8         LDR R4, [R0, #5]
; 40C8:       C25145B8         LDR WNL2, [R4, #85]
; 40CC:       01C5FF18         LDR WNL1, #x70055B396C
; 40D0:       5F00016B         CMP WNL2, WNL1
; 40D4:       61030054         BNE L45
; 40D8:       4AD140F8         LDR R0, [R0, #13]
; 40DC:       ECC0FF58         LDR R2, #x70055B38F8           ; :EPSILON
; 40E0:       5F010CEB         CMP R0, R2
; 40E4:       80000054         BEQ L41
; 40E8:       CCC0FF58         LDR R2, #x70055B3900           ; :RULE
; 40EC:       5F010CEB         CMP R0, R2
; 40F0:       41010054         BNE L44
; 40F4: L41:  6A1140F8         LDR R0, [R1, #1]
; 40F8:       410D4092         AND NL1, R0, #15
; 40FC:       3F1C00F1         CMP NL1, #7
; 4100:       A1000054         BNE L43
; 4104:       EB030AAA         MOV R1, R0
; 4108: L42:  7F011DEB         CMP R1, NULL
; 410C:       80CEFF54         BEQ L2
; 4110:       E9FFFF17         B L40
; 4114: L43:  E04921D4         BRK #2639                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 4118: L44:  8CBFFF58         LDR R2, #x70055B3908           ; :PREDICATE
; 411C:       5F010CEB         CMP R0, R2
; 4120:       A0FEFF54         BEQ L41
; 4124:       6CBFFF58         LDR R2, #x70055B3910           ; :ACTION
; 4128:       5F010CEB         CMP R0, R2
; 412C:       40FEFF54         BEQ L41
; 4130:       4CBFFF58         LDR R2, #x70055B3918           ; :PRECEDENCE
; 4134:       5F010CEB         CMP R0, R2
; 4138:       E0FDFF54         BEQ L41
; 413C:       5EFEFF17         B L1
; 4140: L45:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 4144:       5B               BYTE #X5B                      ; #<SB-KERNEL:LAYOUT (ID=394) for ATN-TRANSITION {700CD64783}>
; 4145:       .ALIGN           4
; 4148: L46:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 414C:       63               BYTE #X63                      ; #<SB-KERNEL:LAYOUT (ID=393) for ATN-STATE {700CD64703}>
; 414D:       .ALIGN           4
; 4150: L47:  60A323D4         BRK #7451                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 4154:       67               BYTE #X67                      ; #<SB-KERNEL:LAYOUT (ID=399) for PARSER-ATN-SIMULATOR {700CD64A83}>
; 4155:       .ALIGN           4
; 4158:       E00120D4         BRK #15                        ; Invalid argument count trap
; 415C: L48:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 4160: L49:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 4164:       01               BYTE #X01                      ; NL0
; 4165:       .ALIGN           4
; 4168: L50:  090280D2         MOVZ TMP, #16
; 416C:       6EBFFF58         LDR R4, #x70055B3958           ; SB-VM::ALLOC-TRAMP
; 4170:       C0013FD6         BLR R4
; 4174:       DEFEFF17         B L14
; 4178: L51:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 417C: L52:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 4180: L53:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 4184: L54:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 4188:       01               BYTE #X01                      ; NL0
; 4189:       .ALIGN           4
; 418C: L55:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 4190: L56:  E06221D4         BRK #2839                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 4194: L57:  204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 4198:       01               BYTE #X01                      ; NL0
; 4199:       .ALIGN           4
