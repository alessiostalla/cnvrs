; disassembly for CNVRS/ANTLR-RUNTIME:CONTEXT-EQUAL
; Size: 844 bytes. Origin: #x700D72E5F0                       ; CNVRS/ANTLR-RUNTIME:CONTEXT-EQUAL
; 5F0: L0:   BF010CEB         CMP R3, R2
; 5F4:       60180054         BEQ L20
; 5F8:       BF011DEB         CMP R3, NULL
; 5FC:       40030054         BEQ L1
; 600:       9F011DEB         CMP R2, NULL
; 604:       00030054         BEQ L1
; 608:       A1D140F8         LDR NL1, [R3, #13]
; 60C:       80D140F8         LDR NL0, [R2, #13]
; 610:       1F0001EB         CMP NL0, NL1
; 614:       81020054         BNE L1
; 618:       AA5140F8         LDR R0, [R3, #5]
; 61C:       429145B8         LDR WNL2, [R0, #89]
; 620:       61F9FF18         LDR WNL1, #x700D72E54C
; 624:       5F00016B         CMP WNL2, WNL1
; 628:       21070054         BNE L7
; 62C:       8A5140F8         LDR R0, [R2, #5]
; 630:       429145B8         LDR WNL2, [R0, #89]
; 634:       C1F8FF18         LDR WNL1, #x700D72E54C
; 638:       5F00016B         CMP WNL2, WNL1
; 63C:       E1010054         BNE L3
; 640:       A1D141F8         LDR NL1, [R3, #29]
; 644:       80D141F8         LDR NL0, [R2, #29]
; 648:       1F0001EB         CMP NL0, NL1
; 64C:       C1000054         BNE L1
; 650:       AA5141F8         LDR R0, [R3, #21]
; 654:       8B5141F8         LDR R1, [R2, #21]
; 658:       ED030AAA         MOV R3, R0
; 65C:       EC030BAA         MOV R2, R1
; 660:       E4FFFF17         B L0
; 664: L1:   EA031DAA         MOV R0, NULL
; 668: L2:   FB031AAA         MOV CSP, CFP
; 66C:       5A7B40A9         LDP CFP, LR, [CFP]
; 670:       BF0300F1         CMP NULL, #0
; 674:       C0035FD6         RET
; 678: L3:   429145B8         LDR WNL2, [R0, #89]
; 67C:       A1F6FF18         LDR WNL1, #x700D72E550
; 680:       5F00016B         CMP WNL2, WNL1
; 684:       01040054         BNE L6
; 688:       8A5141F8         LDR R0, [R2, #21]
; 68C:       40915FF8         LDR NL0, [R0, #-7]
; 690:       1F0800F1         CMP NL0, #2
; 694:       81FEFF54         BNE L1
; 698:       A1D141F8         LDR NL1, [R3, #29]
; 69C:       40915FF8         LDR NL0, [R0, #-7]
; 6A0:       601300B4         CBZ NL0, L21
; 6A4:       401140B8         LDR WNL0, [R0, #1]
; 6A8:       00F87FD3         LSL NL0, NL0, #1
; 6AC:       1F0001EB         CMP NL0, NL1
; 6B0:       A1FDFF54         BNE L1
; 6B4:       AB5141F8         LDR R1, [R3, #21]
; 6B8:       8AD141F8         LDR R0, [R2, #29]
; 6BC:       40915FF8         LDR NL0, [R0, #-7]
; 6C0:       A01200B4         CBZ NL0, L22
; 6C4:       4A1140F8         LDR R0, [R0, #1]
; 6C8:       5F011DEB         CMP R0, NULL
; 6CC:       20010054         BEQ L4
; 6D0:       410D4092         AND NL1, R0, #15
; 6D4:       3F0C00F1         CMP NL1, #3
; 6D8:       21010054         BNE L5
; 6DC:       4C5140F8         LDR R2, [R0, #5]
; 6E0:       825145B8         LDR WNL2, [R2, #85]
; 6E4:       21F3FF18         LDR WNL1, #x700D72E548
; 6E8:       5F00016B         CMP WNL2, WNL1
; 6EC:       81000054         BNE L5
; 6F0: L4:   ED030BAA         MOV R3, R1
; 6F4:       EC030AAA         MOV R2, R0
; 6F8:       BEFFFF17         B L0
; 6FC: L5:   604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 700:       23               BYTE #X23                       ; '(OR NULL
                                                              ;      CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT)
; 701:       .ALIGN           4
; 704: L6:   A08321D4         BRK #3101                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R2
; 708:       27               BYTE #X27                       ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 709:       .ALIGN           4
; 70C: L7:   429145B8         LDR WNL2, [R0, #89]
; 710:       01F2FF18         LDR WNL1, #x700D72E550
; 714:       5F00016B         CMP WNL2, WNL1
; 718:       010F0054         BNE L19
; 71C:       AB5141F8         LDR R1, [R3, #21]
; 720:       ADD141F8         LDR R3, [R3, #29]
; 724:       F0030BAA         MOV R6, R1
; 728:       EE030DAA         MOV R4, R3
; 72C:       8A5140F8         LDR R0, [R2, #5]
; 730:       429145B8         LDR WNL2, [R0, #89]
; 734:       C1F0FF18         LDR WNL1, #x700D72E54C
; 738:       5F00016B         CMP WNL2, WNL1
; 73C:       C1030054         BNE L10
; 740:       60915FF8         LDR NL0, [R1, #-7]
; 744:       1F0800F1         CMP NL0, #2
; 748:       E1F8FF54         BNE L1
; 74C:       60915FF8         LDR NL0, [R1, #-7]
; 750:       600E00B4         CBZ NL0, L23
; 754:       601140B8         LDR WNL0, [R1, #1]
; 758:       01F87FD3         LSL NL1, NL0, #1
; 75C:       80D141F8         LDR NL0, [R2, #29]
; 760:       1F0001EB         CMP NL0, NL1
; 764:       01F8FF54         BNE L1
; 768:       A0915FF8         LDR NL0, [R3, #-7]
; 76C:       C00D00B4         CBZ NL0, L24
; 770:       AA1140F8         LDR R0, [R3, #1]
; 774:       8B5141F8         LDR R1, [R2, #21]
; 778:       5F011DEB         CMP R0, NULL
; 77C:       20010054         BEQ L8
; 780:       410D4092         AND NL1, R0, #15
; 784:       3F0C00F1         CMP NL1, #3
; 788:       21010054         BNE L9
; 78C:       4C5140F8         LDR R2, [R0, #5]
; 790:       825145B8         LDR WNL2, [R2, #85]
; 794:       A1EDFF18         LDR WNL1, #x700D72E548
; 798:       5F00016B         CMP WNL2, WNL1
; 79C:       81000054         BNE L9
; 7A0: L8:   ED030AAA         MOV R3, R0
; 7A4:       EC030BAA         MOV R2, R1
; 7A8:       92FFFF17         B L0
; 7AC: L9:   604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 7B0:       23               BYTE #X23                       ; '(OR NULL
                                                              ;      CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT)
; 7B1:       .ALIGN           4
; 7B4: L10:  429145B8         LDR WNL2, [R0, #89]
; 7B8:       C1ECFF18         LDR WNL1, #x700D72E550
; 7BC:       5F00016B         CMP WNL2, WNL1
; 7C0:       81090054         BNE L18
; 7C4:       8A5141F8         LDR R0, [R2, #21]
; 7C8:       8FD141F8         LDR R5, [R2, #29]
; 7CC:       F1030AAA         MOV R7, R0
; 7D0:       61915FF8         LDR NL1, [R1, #-7]
; 7D4:       40915FF8         LDR NL0, [R0, #-7]
; 7D8:       1F0001EB         CMP NL0, NL1
; 7DC:       41F4FF54         BNE L1
; 7E0:       64915FF8         LDR NL4, [R1, #-7]
; 7E4:       030080D2         MOVZ NL3, #0
; 7E8:       38000014         B L14
; 7EC: L11:  0906038B         ADD TMP, R6, NL3, LSL #1
; 7F0:       201140B8         LDR WNL0, [TMP, #1]
; 7F4:       01F87FD3         LSL NL1, NL0, #1
; 7F8:       2906038B         ADD TMP, R7, NL3, LSL #1
; 7FC:       201140B8         LDR WNL0, [TMP, #1]
; 800:       00F87FD3         LSL NL0, NL0, #1
; 804:       1F0001EB         CMP NL0, NL1
; 808:       81060054         BNE L15
; 80C:       C0915FF8         LDR NL0, [R4, #-7]
; 810:       1F0003EB         CMP NL0, NL3
; 814:       C9080054         BLS L25
; 818:       C909038B         ADD TMP, R4, NL3, LSL #2
; 81C:       2D1140F8         LDR R3, [TMP, #1]
; 820:       E0915FF8         LDR NL0, [R5, #-7]
; 824:       1F0003EB         CMP NL0, NL3
; 828:       69080054         BLS L26
; 82C:       E909038B         ADD TMP, R5, NL3, LSL #2
; 830:       2B1140F8         LDR R1, [TMP, #1]
; 834:       BF011DEB         CMP R3, NULL
; 838:       20010054         BEQ L12
; 83C:       A10D4092         AND NL1, R3, #15
; 840:       3F0C00F1         CMP NL1, #3
; 844:       21050054         BNE L17
; 848:       AC5140F8         LDR R2, [R3, #5]
; 84C:       825145B8         LDR WNL2, [R2, #85]
; 850:       C1E7FF18         LDR WNL1, #x700D72E548
; 854:       5F00016B         CMP WNL2, WNL1
; 858:       81040054         BNE L17
; 85C: L12:  7F011DEB         CMP R1, NULL
; 860:       20010054         BEQ L13
; 864:       610D4092         AND NL1, R1, #15
; 868:       3F0C00F1         CMP NL1, #3
; 86C:       A1030054         BNE L16
; 870:       6C5140F8         LDR R2, [R1, #5]
; 874:       825145B8         LDR WNL2, [R2, #85]
; 878:       81E6FF18         LDR WNL1, #x700D72E548
; 87C:       5F00016B         CMP WNL2, WNL1
; 880:       01030054         BNE L16
; 884: L13:  448F01A9         STP NL4, NL3, [CFP, #24]
; 888:       4FBB02A9         STP R5, R4, [CFP, #40]
; 88C:       50C703A9         STP R6, R7, [CFP, #56]
; 890:       E0031BAA         MOV NL0, CSP
; 894:       7A8704F8         STR CFP, [CSP], #72
; 898:       E10300D1         SUB NL1, NSP, #0
; 89C:       3F000091         MOV NSP, NL1
; 8A0:       EC030BAA         MOV R2, R1
; 8A4:       FA0300AA         MOV CFP, NL0
; 8A8:       51FFFF97         BL #x700D72E5EC
; 8AC:       50C743A9         LDP R6, R7, [CFP, #56]
; 8B0:       4FBB42A9         LDP R5, R4, [CFP, #40]
; 8B4:       448F41A9         LDP NL4, NL3, [CFP, #24]
; 8B8:       5F011DEB         CMP R0, NULL
; 8BC:       E0000054         BEQ L15
; 8C0:       60080091         ADD NL0, NL3, #2
; 8C4:       E30300AA         MOV NL3, NL0
; 8C8: L14:  7F0004EB         CMP NL3, NL4
; 8CC:       0BF9FF54         BLT L11
; 8D0:       AAE30091         ADD R0, NULL, #56               ; T
; 8D4:       65FFFF17         B L2
; 8D8: L15:  EA031DAA         MOV R0, NULL
; 8DC:       63FFFF17         B L2
; 8E0: L16:  606321D4         BRK #2843                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R1
; 8E4:       23               BYTE #X23                       ; '(OR NULL
                                                              ;      CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT)
; 8E5:       .ALIGN           4
; 8E8: L17:  60A321D4         BRK #3355                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R3
; 8EC:       23               BYTE #X23                       ; '(OR NULL
                                                              ;      CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT)
; 8ED:       .ALIGN           4
; 8F0: L18:  A08321D4         BRK #3101                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R2
; 8F4:       27               BYTE #X27                       ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 8F5:       .ALIGN           4
; 8F8: L19:  A0A321D4         BRK #3357                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R3
; 8FC:       27               BYTE #X27                       ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 8FD:       .ALIGN           4
; 900: L20:  AAE30091         ADD R0, NULL, #56               ; T
; 904:       59FFFF17         B L2
; 908:       E00120D4         BRK #15                         ; Invalid argument count trap
; 90C: L21:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 910:       80808004         BYTE #X80, #X80, #X80, #X04     ; 0
; 914: L22:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 918:       80808004         BYTE #X80, #X80, #X80, #X04     ; 0
; 91C: L23:  206421D4         BRK #2849                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R1
; 920:       80808004         BYTE #X80, #X80, #X80, #X04     ; 0
; 924: L24:  20A421D4         BRK #3361                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R3
; 928:       80808004         BYTE #X80, #X80, #X80, #X04     ; 0
; 92C: L25:  20C421D4         BRK #3617                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R4
; 930:       0D               BYTE #X0D                       ; NL3
; 931:       .ALIGN           4
; 934: L26:  20E421D4         BRK #3873                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; 938:       0D               BYTE #X0D                       ; NL3
; 939:       .ALIGN           4
