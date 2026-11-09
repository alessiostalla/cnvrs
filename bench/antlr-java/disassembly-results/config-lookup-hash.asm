; disassembly for CNVRS/ANTLR-RUNTIME::CONFIG-LOOKUP-HASH
; Size: 412 bytes. Origin: #x700AA62714                       ; CNVRS/ANTLR-RUNTIME::CONFIG-LOOKUP-HASH
; 714:       810D4092         AND NL1, R2, #15
; 718:       3F0C00F1         CMP NL1, #3
; 71C:       410C0054         BNE L2
; 720:       8B5140F8         LDR R1, [R2, #5]
; 724:       625145B8         LDR WNL2, [R1, #85]
; 728:       01FEFF18         LDR WNL1, #x700AA626E8
; 72C:       5F00016B         CMP WNL2, WNL1
; 730:       A10B0054         BNE L2
; 734:       80D140F8         LDR NL0, [R2, #13]
; 738:       037C7F92         AND NL3, NL0, #8589934590
; 73C:       805141F8         LDR NL0, [R2, #21]
; 740:       007C7F92         AND NL0, NL0, #8589934590
; 744:       29AA85D2         MOVZ TMP, #11601
; 748:       C993B9F2         MOVK TMP, #52382, LSL #16
; 74C:       007C099B         MUL NL0, NL0, TMP
; 750:       007C7F92         AND NL0, NL0, #8589934590
; 754:       02C071D3         LSL NL2, NL0, #15
; 758:       01FC5193         ASR NL1, NL0, #17
; 75C:       20F87F92         AND NL0, NL1, #18446744073709551614
; 760:       400000AA         ORR NL0, NL2, NL0
; 764:       007C7F92         AND NL0, NL0, #8589934590
; 768:       69B286D2         MOVZ TMP, #13715
; 76C:       E970A3F2         MOVK TMP, #7047, LSL #16
; 770:       007C099B         MUL NL0, NL0, TMP
; 774:       007C7F92         AND NL0, NL0, #8589934590
; 778:       600000CA         EOR NL0, NL3, NL0
; 77C:       02C873D3         LSL NL2, NL0, #13
; 780:       01FC5393         ASR NL1, NL0, #19
; 784:       20F87F92         AND NL0, NL1, #18446744073709551614
; 788:       400000AA         ORR NL0, NL2, NL0
; 78C:       007C7F92         AND NL0, NL0, #8589934590
; 790:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 794:       01D99AD2         MOVZ NL1, #54984
; 798:       0195B9F2         MOVK NL1, #52392, LSL #16
; 79C:       2100C0F2         MOVK NL1, #1, LSL #32
; 7A0:       0000018B         ADD NL0, NL0, NL1
; 7A4:       037C7F92         AND NL3, NL0, #8589934590
; 7A8:       8A5142F8         LDR R0, [R2, #37]
; 7AC:       ABE30091         ADD R1, NULL, #56               ; T
; 7B0:       5F010BEB         CMP R0, R1
; 7B4:       21060054         BNE L1
; 7B8:       000080D2         MOVZ NL0, #0
; 7BC: L0:   29AA85D2         MOVZ TMP, #11601
; 7C0:       C993B9F2         MOVK TMP, #52382, LSL #16
; 7C4:       007C099B         MUL NL0, NL0, TMP
; 7C8:       007C7F92         AND NL0, NL0, #8589934590
; 7CC:       02C071D3         LSL NL2, NL0, #15
; 7D0:       01FC5193         ASR NL1, NL0, #17
; 7D4:       20F87F92         AND NL0, NL1, #18446744073709551614
; 7D8:       400000AA         ORR NL0, NL2, NL0
; 7DC:       007C7F92         AND NL0, NL0, #8589934590
; 7E0:       69B286D2         MOVZ TMP, #13715
; 7E4:       E970A3F2         MOVK TMP, #7047, LSL #16
; 7E8:       007C099B         MUL NL0, NL0, TMP
; 7EC:       007C7F92         AND NL0, NL0, #8589934590
; 7F0:       600000CA         EOR NL0, NL3, NL0
; 7F4:       02C873D3         LSL NL2, NL0, #13
; 7F8:       01FC5393         ASR NL1, NL0, #19
; 7FC:       20F87F92         AND NL0, NL1, #18446744073709551614
; 800:       400000AA         ORR NL0, NL2, NL0
; 804:       007C7F92         AND NL0, NL0, #8589934590
; 808:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 80C:       01D99AD2         MOVZ NL1, #54984
; 810:       0195B9F2         MOVK NL1, #52392, LSL #16
; 814:       2100C0F2         MOVK NL1, #1, LSL #32
; 818:       0000018B         ADD NL0, NL0, NL1
; 81C:       007C7F92         AND NL0, NL0, #8589934590
; 820:       00047DD2         EOR NL0, NL0, #24
; 824:       01FC5093         ASR NL1, NL0, #16
; 828:       22F87F92         AND NL2, NL1, #18446744073709551614
; 82C:       000002CA         EOR NL0, NL0, NL2
; 830:       694D99D2         MOVZ TMP, #51819
; 834:       69BDB0F2         MOVK TMP, #34283, LSL #16
; 838:       007C099B         MUL NL0, NL0, TMP
; 83C:       007C7F92         AND NL0, NL0, #8589934590
; 840:       01FC4D93         ASR NL1, NL0, #13
; 844:       22F87F92         AND NL2, NL1, #18446744073709551614
; 848:       000002CA         EOR NL0, NL0, NL2
; 84C:       A9C695D2         MOVZ TMP, #44597
; 850:       4956B8F2         MOVK TMP, #49842, LSL #16
; 854:       007C099B         MUL NL0, NL0, TMP
; 858:       007C7F92         AND NL0, NL0, #8589934590
; 85C:       01FC5093         ASR NL1, NL0, #16
; 860:       22F87F92         AND NL2, NL1, #18446744073709551614
; 864:       0A0002CA         EOR R0, NL0, NL2
; 868:       FB031AAA         MOV CSP, CFP
; 86C:       5A7B40A9         LDP CFP, LR, [CFP]
; 870:       BF0300F1         CMP NULL, #0
; 874:       C0035FD6         RET
; 878: L1:   430B00F9         STR NL3, [CFP, #16]
; 87C:       8A5142F8         LDR R0, [R2, #37]
; 880:       7A0300F9         STR CFP, [CSP]
; 884:       76F2FF58         LDR LEXENV, #x700AA626D0        ; #<SB-KERNEL:FDEFN SXHASH>
; 888:       570080D2         MOVZ NARGS, #2
; 88C:       FA031BAA         MOV CFP, CSP
; 890:       DE9240F8         LDR LR, [LEXENV, #9]
; 894:       C0033FD6         BLR LR
; 898:       430B40F9         LDR NL3, [CFP, #16]
; 89C:       407D7F92         AND NL0, R0, #8589934590
; 8A0:       C7FFFF17         B L0
; 8A4: L2:   608321D4         BRK #3099                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 8A8:       27               BYTE #X27                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/ANTLR-RUNTIME:ATN-CONFIG {700AA36813}>
; 8A9:       .ALIGN           4
; 8AC:       E00120D4         BRK #15                         ; Invalid argument count trap
