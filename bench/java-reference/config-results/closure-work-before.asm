; disassembly for CNVRS/RUNTIME::CLOSURE-WORK
; Size: 1844 bytes. Origin: #x70086E56F8                      ; CNVRS/RUNTIME::CLOSURE-WORK
; 6F8:       4A0F40F9         LDR R0, [CFP, #24]
; 6FC:       40D140F8         LDR NL0, [R0, #13]
; 700:       4BF5FF58         LDR R1, #x70086E55A8            ; 'CNVRS/RUNTIME::*SIMULATOR*
; 704:       61515FB8         LDR WNL1, [R1, #-11]
; 708:       AA6A61F8         LDR R0, [THREAD, NL1]
; 70C:       5F0500B1         CMN R0, #1
; 710:       41000054         BNE L0
; 714:       6A1140F8         LDR R0, [R1, #1]
; 718: L0:   5F2500F1         CMP R0, #9
; 71C:       80360054         BEQ L51
; 720:       5F011DEB         CMP R0, NULL
; 724:       E0350054         BEQ L50
; 728:       4AD140F8         LDR R0, [R0, #13]
; 72C:       4AD140F8         LDR R0, [R0, #13]
; 730:       41915FF8         LDR NL1, [R0, #-7]
; 734:       3F0000EB         CMP NL1, NL0
; 738:       C9350054         BLS L52
; 73C:       4909008B         ADD TMP, R0, NL0, LSL #2
; 740:       2A1140F8         LDR R0, [TMP, #1]
; 744:       4A2700F9         STR R0, [CFP, #72]
; 748:       410D4092         AND NL1, R0, #15
; 74C:       3F0C00F1         CMP NL1, #3
; 750:       41340054         BNE L49
; 754:       4E5140F8         LDR R4, [R0, #5]
; 758:       C25145B8         LDR WNL2, [R4, #85]
; 75C:       61F6FF18         LDR WNL1, #x70086E5628
; 760:       5F00016B         CMP WNL2, WNL1
; 764:       A1330054         BNE L49
; 768:       4B5142F8         LDR R1, [R0, #37]
; 76C:       7F011DEB         CMP R1, NULL
; 770:       612E0054         BNE L42
; 774: L1:   7A0300F9         STR CFP, [CSP]
; 778:       4BAB41A9         LDP R1, R0, [CFP, #24]
; 77C:       B6EFFF58         LDR LEXENV, #x70086E5570        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONFIG-SET-ADD>
; 780:       970080D2         MOVZ NARGS, #4
; 784:       580B00F9         STR NFP, [CFP, #16]
; 788:       FA031BAA         MOV CFP, CSP
; 78C:       DE9240F8         LDR LR, [LEXENV, #9]
; 790:       C0033FD6         BLR LR
; 794:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 798:       580B40F9         LDR NFP, [CFP, #16]
; 79C: L2:   4A2740F9         LDR R0, [CFP, #72]
; 7A0:       4A5142F8         LDR R0, [R0, #37]
; 7A4:       4A7F05A9         STP R0, ZR, [CFP, #80]
; 7A8:       4A2B40F9         LDR R0, [CFP, #80]
; 7AC:       5F011DEB         CMP R0, NULL
; 7B0:       E1000054         BNE L4
; 7B4: L3:   EA031DAA         MOV R0, NULL
; 7B8:       1F430091         ADD NSP, NFP, #16
; 7BC:       FB031AAA         MOV CSP, CFP
; 7C0:       5A7B40A9         LDP CFP, LR, [CFP]
; 7C4:       BF0300F1         CMP NULL, #0
; 7C8:       C0035FD6         RET
; 7CC: L4:   4A2B40F9         LDR R0, [CFP, #80]
; 7D0:       4A915FF8         LDR R0, [R0, #-7]
; 7D4:       EF030AAA         MOV R5, R0
; 7D8:       4A2B40F9         LDR R0, [CFP, #80]
; 7DC:       4A1140F8         LDR R0, [R0, #1]
; 7E0:       4A2B00F9         STR R0, [CFP, #80]
; 7E4:       48000014         B L11
; 7E8: L5:   4A1B40F9         LDR R0, [CFP, #48]
; 7EC:       5F011DEB         CMP R0, NULL
; 7F0:       61280054         BNE L40
; 7F4: L6:   EA031DAA         MOV R0, NULL
; 7F8: L7:   4F3B00F9         STR R5, [CFP, #112]
; 7FC:       4A3300F9         STR R0, [CFP, #96]
; 800:       EB030FAA         MOV R1, R5
; 804:       000340F9         LDR NL0, [NFP]
; 808:       1F0000F1         CMP NL0, #0
; 80C:       AAE30091         ADD R0, NULL, #56               ; T
; 810:       4D019D9A         CSEL R3, R0, NULL, EQ
; 814:       E0031BAA         MOV NL0, CSP
; 818:       7A0703F8         STR CFP, [CSP], #48
; 81C:       4A0F40F9         LDR R0, [CFP, #24]
; 820:       4C3340F9         LDR R2, [CFP, #96]
; 824:       4E1F40F9         LDR R4, [CFP, #56]
; 828:       0E1000F9         STR R4, [NL0, #32]
; 82C:       4E2340F9         LDR R4, [CFP, #64]
; 830:       0E1400F9         STR R4, [NL0, #40]
; 834:       36EAFF58         LDR LEXENV, #x70086E5578        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::GET-EPSILON-TARGET>
; 838:       970180D2         MOVZ NARGS, #12
; 83C:       580B00F9         STR NFP, [CFP, #16]
; 840:       FA0300AA         MOV CFP, NL0
; 844:       DE9240F8         LDR LR, [LEXENV, #9]
; 848:       C0033FD6         BLR LR
; 84C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 850:       580B40F9         LDR NFP, [CFP, #16]
; 854:       4F3B40F9         LDR R5, [CFP, #112]
; 858:       EC030AAA         MOV R2, R0
; 85C:       010340F9         LDR NL1, [NFP]
; 860:       9F011DEB         CMP R2, NULL
; 864:       40020054         BEQ L10
; 868:       4A2740F9         LDR R0, [CFP, #72]
; 86C:       4A5141F8         LDR R0, [R0, #21]
; 870:       0BEAFF58         LDR R1, #x70086E55B0            ; :RULE-STOP
; 874:       5F010BEB         CMP R0, R1
; 878:       20100054         BEQ L21
; 87C:       EAD140F8         LDR R0, [R5, #13]
; 880:       CBE9FF58         LDR R1, #x70086E55B8            ; :EPSILON
; 884:       5F010BEB         CMP R0, R1
; 888:       210B0054         BNE L18
; 88C: L8:   EAD140F8         LDR R0, [R5, #13]
; 890:       8BE9FF58         LDR R1, #x70086E55C0            ; :RULE
; 894:       5F010BEB         CMP R0, R1
; 898:       61000054         BNE L9
; 89C:       000340F9         LDR NL0, [NFP]
; 8A0:       E009F8B6         TBZ NL0, #63, L17
; 8A4: L9:   9F011DEB         CMP R2, NULL
; 8A8:       61050054         BNE L14
; 8AC: L10:  4A2B40F9         LDR R0, [CFP, #80]
; 8B0:       410D4092         AND NL1, R0, #15
; 8B4:       3F1C00F1         CMP NL1, #7
; 8B8:       A1040054         BNE L13
; 8BC:       4A2B40F9         LDR R0, [CFP, #80]
; 8C0:       5F011DEB         CMP R0, NULL
; 8C4:       80F7FF54         BEQ L3
; 8C8:       4A2B40F9         LDR R0, [CFP, #80]
; 8CC:       4A915FF8         LDR R0, [R0, #-7]
; 8D0:       EF030AAA         MOV R5, R0
; 8D4:       4A2B40F9         LDR R0, [CFP, #80]
; 8D8:       4A1140F8         LDR R0, [R0, #1]
; 8DC:       4A2B00F9         STR R0, [CFP, #80]
; 8E0:       402F40F9         LDR NL0, [CFP, #88]
; 8E4:       00FC4193         ASR NL0, NL0, #1
; 8E8:       01040091         ADD NL1, NL0, #1
; 8EC:       E00301AA         MOV NL0, NL1
; 8F0:       E10300AA         MOV NL1, NL0
; 8F4:       3F0442F2         TST NL1, #13835058055282163712
; 8F8:       81020054         BNE L12
; 8FC:       00F87FD3         LSL NL0, NL0, #1
; 900:       402F00F9         STR NL0, [CFP, #88]
; 904: L11:  402F40F9         LDR NL0, [CFP, #88]
; 908:       00F7FFB5         CBNZ NL0, L5
; 90C:       4F3B00F9         STR R5, [CFP, #112]
; 910:       7A0300F9         STR CFP, [CSP]
; 914:       4A0F40F9         LDR R0, [CFP, #24]
; 918:       56E3FF58         LDR LEXENV, #x70086E5580        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CAN-DROP-LOOP-ENTRY-EDGE-IN-LEFT-RECURSIVE-RULE>
; 91C:       570080D2         MOVZ NARGS, #2
; 920:       580B00F9         STR NFP, [CFP, #16]
; 924:       FA031BAA         MOV CFP, CSP
; 928:       DE9240F8         LDR LR, [LEXENV, #9]
; 92C:       C0033FD6         BLR LR
; 930:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 934:       580B40F9         LDR NFP, [CFP, #16]
; 938:       4F3B40F9         LDR R5, [CFP, #112]
; 93C:       5F011DEB         CMP R0, NULL
; 940:       40F5FF54         BEQ L5
; 944:       DAFFFF17         B L10
; 948: L12:  A00A28D4         BRK #16469                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 94C: L13:  4A2B40F9         LDR R0, [CFP, #80]
; 950:       E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 954: L14:  EA030CAA         MOV R0, R2
; 958:       2E0001AB         ADDS R4, NL1, NL1
; 95C:       E7010054         BVC L16
; 960:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 964:       A97A47A9         LDP TMP, LR, [THREAD, #112]     ; mixed-tlab.{free-pointer, end-addr}
; 968:       2E410091         ADD R4, TMP, #16
; 96C:       DF011EEB         CMP R4, LR
; 970:       48240054         BHI L53
; 974:       AE3A00F9         STR R4, [THREAD, #112]          ; mixed-tlab
; 978: L15:  2E3D0091         ADD R4, TMP, #15
; 97C:       3E2280D2         MOVZ LR, #273
; 980:       3E0500A9         STP LR, NL1, [TMP]
; 984:       BF3A03D5         DMB ISHST
; 988:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 98C:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 990:       5E0000B4         CBZ LR, L16
; 994:       200120D4         BRK #9                          ; Pending interrupt trap
; 998: L16:  E0031BAA         MOV NL0, CSP
; 99C:       7A8703F8         STR CFP, [CSP], #56
; 9A0:       4B3342A9         LDP R1, R2, [CFP, #32]
; 9A4:       4D3340F9         LDR R3, [CFP, #96]
; 9A8:       4F1F40F9         LDR R5, [CFP, #56]
; 9AC:       0F3802A9         STP R5, R4, [NL0, #32]
; 9B0:       4E2340F9         LDR R4, [CFP, #64]
; 9B4:       0E1800F9         STR R4, [NL0, #48]
; 9B8:       96DEFF58         LDR LEXENV, #x70086E5588        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CLOSURE-CHECKING-STOP-STATE>
; 9BC:       D70180D2         MOVZ NARGS, #14
; 9C0:       580B00F9         STR NFP, [CFP, #16]
; 9C4:       FA0300AA         MOV CFP, NL0
; 9C8:       DE9240F8         LDR LR, [LEXENV, #9]
; 9CC:       C0033FD6         BLR LR
; 9D0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 9D4:       580B40F9         LDR NFP, [CFP, #16]
; 9D8:       B5FFFF17         B L10
; 9DC: L17:  000340F9         LDR NL0, [NFP]
; 9E0:       00040091         ADD NL0, NL0, #1
; 9E4:       E10300AA         MOV NL1, NL0
; 9E8:       AFFFFF17         B L9
; 9EC: L18:  ABDEFF58         LDR R1, #x70086E55C0            ; :RULE
; 9F0:       5F010BEB         CMP R0, R1
; 9F4:       C0F4FF54         BEQ L8
; 9F8:       8BDEFF58         LDR R1, #x70086E55C8            ; :PREDICATE
; 9FC:       5F010BEB         CMP R0, R1
; A00:       60F4FF54         BEQ L8
; A04:       6BDEFF58         LDR R1, #x70086E55D0            ; :ACTION
; A08:       5F010BEB         CMP R0, R1
; A0C:       00F4FF54         BEQ L8
; A10:       4BDEFF58         LDR R1, #x70086E55D8            ; :PRECEDENCE
; A14:       5F010BEB         CMP R0, R1
; A18:       A0F3FF54         BEQ L8
; A1C:       4CBF06A9         STP R2, R5, [CFP, #104]
; A20:       010700F9         STR NL1, [NFP, #8]
; A24:       EB030CAA         MOV R1, R2
; A28:       7A0300F9         STR CFP, [CSP]
; A2C:       4A1740F9         LDR R0, [CFP, #40]
; A30:       16DBFF58         LDR LEXENV, #x70086E5590        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::BUSY-ADD>
; A34:       970080D2         MOVZ NARGS, #4
; A38:       580B00F9         STR NFP, [CFP, #16]
; A3C:       FA031BAA         MOV CFP, CSP
; A40:       DE9240F8         LDR LR, [LEXENV, #9]
; A44:       C0033FD6         BLR LR
; A48:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; A4C:       580B40F9         LDR NFP, [CFP, #16]
; A50:       010740F9         LDR NL1, [NFP, #8]
; A54:       4CBF46A9         LDP R2, R5, [CFP, #104]
; A58:       5F011DEB         CMP R0, NULL
; A5C:       80000054         BEQ L19
; A60:       ABE30091         ADD R1, NULL, #56               ; T
; A64:       5F010BEB         CMP R0, R1
; A68:       81000054         BNE L20
; A6C: L19:  5F011DEB         CMP R0, NULL
; A70:       AC038C9A         CSEL R2, NULL, R2, EQ
; A74:       86FFFF17         B L8
; A78: L20:  A05221D4         BRK #2709                       ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; A7C: L21:  2BDBFF58         LDR R1, #x70086E55E0            ; 'CNVRS/RUNTIME::*CURRENT-DFA*
; A80:       61515FB8         LDR WNL1, [R1, #-11]
; A84:       AA6A61F8         LDR R0, [THREAD, NL1]
; A88:       5F0500B1         CMN R0, #1
; A8C:       41000054         BNE L22
; A90:       6A1140F8         LDR R0, [R1, #1]
; A94: L22:  5F2500F1         CMP R0, #9
; A98:       801B0054         BEQ L54
; A9C:       5F011DEB         CMP R0, NULL
; AA0:       E1050054         BNE L28
; AA4: L23:  810D4092         AND NL1, R2, #15
; AA8:       3F0C00F1         CMP NL1, #3
; AAC:       41050054         BNE L27
; AB0:       8E5140F8         LDR R4, [R2, #5]
; AB4:       C25145B8         LDR WNL2, [R4, #85]
; AB8:       41DBFF18         LDR WNL1, #x70086E5620
; ABC:       5F00016B         CMP WNL2, WNL1
; AC0:       A1040054         BNE L27
; AC4:       80D142F8         LDR NL0, [R2, #45]
; AC8:       00FC4193         ASR NL0, NL0, #1
; ACC:       00040091         ADD NL0, NL0, #1
; AD0:       1F0000AB         CMN NL0, NL0
; AD4:       E6030054         BVS L26
; AD8:       4C3700F9         STR R2, [CFP, #104]
; ADC:       00F87FD3         LSL NL0, NL0, #1
; AE0:       80D102F8         STR NL0, [R2, #45]
; AE4:       EB030CAA         MOV R1, R2
; AE8:       7A0300F9         STR CFP, [CSP]
; AEC:       4A1740F9         LDR R0, [CFP, #40]
; AF0:       16D5FF58         LDR LEXENV, #x70086E5590        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::BUSY-ADD>
; AF4:       970080D2         MOVZ NARGS, #4
; AF8:       580B00F9         STR NFP, [CFP, #16]
; AFC:       FA031BAA         MOV CFP, CSP
; B00:       DE9240F8         LDR LR, [LEXENV, #9]
; B04:       C0033FD6         BLR LR
; B08:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; B0C:       580B40F9         LDR NFP, [CFP, #16]
; B10:       4C3740F9         LDR R2, [CFP, #104]
; B14:       5F011DEB         CMP R0, NULL
; B18:       80000054         BEQ L24
; B1C:       ABE30091         ADD R1, NULL, #56               ; T
; B20:       5F010BEB         CMP R0, R1
; B24:       41010054         BNE L25
; B28: L24:  5F011DEB         CMP R0, NULL
; B2C:       AC038C9A         CSEL R2, NULL, R2, EQ
; B30:       4A1340F9         LDR R0, [CFP, #32]
; B34:       ABE30091         ADD R1, NULL, #56               ; T
; B38:       4BD103F8         STR R1, [R0, #61]
; B3C:       000340F9         LDR NL0, [NFP]
; B40:       000400D1         SUB NL0, NL0, #1
; B44:       E10300AA         MOV NL1, NL0
; B48:       57FFFF17         B L9
; B4C: L25:  A05221D4         BRK #2709                       ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; B50: L26:  A00A28D4         BRK #16469                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; B54: L27:  608321D4         BRK #3099                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; B58:       3B               BYTE #X3B                       ; #<SB-KERNEL:LAYOUT (ID=396) for CNVRS/RUNTIME:ATN-CONFIG {7008641703}>
; B59:       .ALIGN           4
; B5C: L28:  2BD4FF58         LDR R1, #x70086E55E0            ; 'CNVRS/RUNTIME::*CURRENT-DFA*
; B60:       61515FB8         LDR WNL1, [R1, #-11]
; B64:       AA6A61F8         LDR R0, [THREAD, NL1]
; B68:       5F0500B1         CMN R0, #1
; B6C:       41000054         BNE L29
; B70:       6A1140F8         LDR R0, [R1, #1]
; B74: L29:  5F2500F1         CMP R0, #9
; B78:       A0140054         BEQ L55
; B7C:       5F011DEB         CMP R0, NULL
; B80:       A00B0054         BEQ L39
; B84:       405141F8         LDR NL0, [R0, #21]
; B88:       0BD1FF58         LDR R1, #x70086E55A8            ; 'CNVRS/RUNTIME::*SIMULATOR*
; B8C:       61515FB8         LDR WNL1, [R1, #-11]
; B90:       AA6A61F8         LDR R0, [THREAD, NL1]
; B94:       5F0500B1         CMN R0, #1
; B98:       41000054         BNE L30
; B9C:       6A1140F8         LDR R0, [R1, #1]
; BA0: L30:  5F2500F1         CMP R0, #9
; BA4:       60130054         BEQ L56
; BA8:       5F011DEB         CMP R0, NULL
; BAC:       000A0054         BEQ L38
; BB0:       4AD140F8         LDR R0, [R0, #13]
; BB4:       4AD140F8         LDR R0, [R0, #13]
; BB8:       41915FF8         LDR NL1, [R0, #-7]
; BBC:       3F0000EB         CMP NL1, NL0
; BC0:       A9120054         BLS L57
; BC4:       4909008B         ADD TMP, R0, NL0, LSL #2
; BC8:       2A1140F8         LDR R0, [TMP, #1]
; BCC:       410D4092         AND NL1, R0, #15
; BD0:       3F0C00F1         CMP NL1, #3
; BD4:       81080054         BNE L37
; BD8:       4E5140F8         LDR R4, [R0, #5]
; BDC:       C25145B8         LDR WNL2, [R4, #85]
; BE0:       41D2FF18         LDR WNL1, #x70086E5628
; BE4:       5F00016B         CMP WNL2, WNL1
; BE8:       E1070054         BNE L37
; BEC:       4A5143F8         LDR R0, [R0, #53]
; BF0:       5F011DEB         CMP R0, NULL
; BF4:       80F5FF54         BEQ L23
; BF8:       E3D142F8         LDR NL3, [R5, #45]
; BFC:       2BCFFF58         LDR R1, #x70086E55E0            ; 'CNVRS/RUNTIME::*CURRENT-DFA*
; C00:       61515FB8         LDR WNL1, [R1, #-11]
; C04:       AA6A61F8         LDR R0, [THREAD, NL1]
; C08:       5F0500B1         CMN R0, #1
; C0C:       41000054         BNE L31
; C10:       6A1140F8         LDR R0, [R1, #1]
; C14: L31:  5F2500F1         CMP R0, #9
; C18:       20100054         BEQ L58
; C1C:       5F011DEB         CMP R0, NULL
; C20:       E0050054         BEQ L36
; C24:       405141F8         LDR NL0, [R0, #21]
; C28:       0BCCFF58         LDR R1, #x70086E55A8            ; 'CNVRS/RUNTIME::*SIMULATOR*
; C2C:       61515FB8         LDR WNL1, [R1, #-11]
; C30:       AA6A61F8         LDR R0, [THREAD, NL1]
; C34:       5F0500B1         CMN R0, #1
; C38:       41000054         BNE L32
; C3C:       6A1140F8         LDR R0, [R1, #1]
; C40: L32:  5F2500F1         CMP R0, #9
; C44:       E00E0054         BEQ L59
; C48:       5F011DEB         CMP R0, NULL
; C4C:       40040054         BEQ L35
; C50:       4AD140F8         LDR R0, [R0, #13]
; C54:       4AD140F8         LDR R0, [R0, #13]
; C58:       41915FF8         LDR NL1, [R0, #-7]
; C5C:       3F0000EB         CMP NL1, NL0
; C60:       290E0054         BLS L60
; C64:       4909008B         ADD TMP, R0, NL0, LSL #2
; C68:       2A1140F8         LDR R0, [TMP, #1]
; C6C:       410D4092         AND NL1, R0, #15
; C70:       3F0C00F1         CMP NL1, #3
; C74:       C1020054         BNE L34
; C78:       4E5140F8         LDR R4, [R0, #5]
; C7C:       C25145B8         LDR WNL2, [R4, #85]
; C80:       41CDFF18         LDR WNL1, #x70086E5628
; C84:       5F00016B         CMP WNL2, WNL1
; C88:       21020054         BNE L34
; C8C:       40D141F8         LDR NL0, [R0, #29]
; C90:       1F0003EB         CMP NL0, NL3
; C94:       81F0FF54         BNE L23
; C98:       810D4092         AND NL1, R2, #15
; C9C:       3F0C00F1         CMP NL1, #3
; CA0:       21010054         BNE L33
; CA4:       8E5140F8         LDR R4, [R2, #5]
; CA8:       C25145B8         LDR WNL2, [R4, #85]
; CAC:       A1CBFF18         LDR WNL1, #x70086E5620
; CB0:       5F00016B         CMP WNL2, WNL1
; CB4:       81000054         BNE L33
; CB8:       AAE30091         ADD R0, NULL, #56               ; T
; CBC:       8A5103F8         STR R0, [R2, #53]
; CC0:       79FFFF17         B L23
; CC4: L33:  608321D4         BRK #3099                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; CC8:       3B               BYTE #X3B                       ; #<SB-KERNEL:LAYOUT (ID=396) for CNVRS/RUNTIME:ATN-CONFIG {7008641703}>
; CC9:       .ALIGN           4
; CCC: L34:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; CD0:       5F               BYTE #X5F                       ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/RUNTIME:ATN-STATE {700860A683}>
; CD1:       .ALIGN           4
; CD4: L35:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; CD8:       63               BYTE #X63                       ; #<SB-KERNEL:LAYOUT (ID=400) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {70086BCDA3}>
; CD9:       .ALIGN           4
; CDC: L36:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; CE0:       67               BYTE #X67                       ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/RUNTIME:DFA {70086B44A3}>
; CE1:       .ALIGN           4
; CE4: L37:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; CE8:       5F               BYTE #X5F                       ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/RUNTIME:ATN-STATE {700860A683}>
; CE9:       .ALIGN           4
; CEC: L38:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; CF0:       63               BYTE #X63                       ; #<SB-KERNEL:LAYOUT (ID=400) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {70086BCDA3}>
; CF1:       .ALIGN           4
; CF4: L39:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; CF8:       67               BYTE #X67                       ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/RUNTIME:DFA {70086B44A3}>
; CF9:       .ALIGN           4
; CFC: L40:  E10D4092         AND NL1, R5, #15
; D00:       3F0C00F1         CMP NL1, #3
; D04:       81010054         BNE L41
; D08:       EE5140F8         LDR R4, [R5, #5]
; D0C:       C25145B8         LDR WNL2, [R4, #85]
; D10:       E1C8FF18         LDR WNL1, #x70086E562C
; D14:       5F00016B         CMP WNL2, WNL1
; D18:       E1000054         BNE L41
; D1C:       EAD140F8         LDR R0, [R5, #13]
; D20:       8BC5FF58         LDR R1, #x70086E55D0            ; :ACTION
; D24:       5F010BEB         CMP R0, R1
; D28:       60D6FF54         BEQ L6
; D2C:       AAE30091         ADD R0, NULL, #56               ; T
; D30:       B2FEFF17         B L7
; D34: L41:  60E321D4         BRK #3867                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; D38:       6B               BYTE #X6B                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-TRANSITION {7008626B13}>
; D39:       .ALIGN           4
; D3C: L42:  4B5142F8         LDR R1, [R0, #37]
; D40:       16000014         B L45
; D44: L43:  6A915FF8         LDR R0, [R1, #-7]
; D48:       410D4092         AND NL1, R0, #15
; D4C:       3F0C00F1         CMP NL1, #3
; D50:       01040054         BNE L48
; D54:       4E5140F8         LDR R4, [R0, #5]
; D58:       C25145B8         LDR WNL2, [R4, #85]
; D5C:       81C6FF18         LDR WNL1, #x70086E562C
; D60:       5F00016B         CMP WNL2, WNL1
; D64:       61030054         BNE L48
; D68:       4AD140F8         LDR R0, [R0, #13]
; D6C:       6CC2FF58         LDR R2, #x70086E55B8            ; :EPSILON
; D70:       5F010CEB         CMP R0, R2
; D74:       80000054         BEQ L44
; D78:       4CC2FF58         LDR R2, #x70086E55C0            ; :RULE
; D7C:       5F010CEB         CMP R0, R2
; D80:       41010054         BNE L47
; D84: L44:  6A1140F8         LDR R0, [R1, #1]
; D88:       410D4092         AND NL1, R0, #15
; D8C:       3F1C00F1         CMP NL1, #7
; D90:       A1000054         BNE L46
; D94:       EB030AAA         MOV R1, R0
; D98: L45:  7F011DEB         CMP R1, NULL
; D9C:       00D0FF54         BEQ L2
; DA0:       E9FFFF17         B L43
; DA4: L46:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; DA8: L47:  0CC1FF58         LDR R2, #x70086E55C8            ; :PREDICATE
; DAC:       5F010CEB         CMP R0, R2
; DB0:       A0FEFF54         BEQ L44
; DB4:       ECC0FF58         LDR R2, #x70086E55D0            ; :ACTION
; DB8:       5F010CEB         CMP R0, R2
; DBC:       40FEFF54         BEQ L44
; DC0:       CCC0FF58         LDR R2, #x70086E55D8            ; :PRECEDENCE
; DC4:       5F010CEB         CMP R0, R2
; DC8:       E0FDFF54         BEQ L44
; DCC:       6AFEFF17         B L1
; DD0: L48:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; DD4:       6B               BYTE #X6B                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-TRANSITION {7008626B13}>
; DD5:       .ALIGN           4
; DD8: L49:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; DDC:       5F               BYTE #X5F                       ; #<SB-KERNEL:LAYOUT (ID=394) for CNVRS/RUNTIME:ATN-STATE {700860A683}>
; DDD:       .ALIGN           4
; DE0: L50:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; DE4:       63               BYTE #X63                       ; #<SB-KERNEL:LAYOUT (ID=400) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {70086BCDA3}>
; DE5:       .ALIGN           4
; DE8:       E00120D4         BRK #15                         ; Invalid argument count trap
; DEC: L51:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; DF0: L52:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; DF4:       01               BYTE #X01                       ; NL0
; DF5:       .ALIGN           4
; DF8: L53:  090280D2         MOVZ TMP, #16
; DFC:       EEC0FF58         LDR R4, #x70086E5618            ; SB-VM::ALLOC-TRAMP
; E00:       C0013FD6         BLR R4
; E04:       DDFEFF17         B L15
; E08: L54:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; E0C: L55:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; E10: L56:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; E14: L57:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; E18:       01               BYTE #X01                       ; NL0
; E19:       .ALIGN           4
; E1C: L58:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; E20: L59:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; E24: L60:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; E28:       01               BYTE #X01                       ; NL0
; E29:       .ALIGN           4
