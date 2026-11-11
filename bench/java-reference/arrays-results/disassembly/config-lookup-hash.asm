; disassembly for CNVRS/RUNTIME::CONFIG-LOOKUP-HASH
; Size: 372 bytes. Origin: #x700D72C8AC                       ; CNVRS/RUNTIME::CONFIG-LOOKUP-HASH
; 8AC:       80D140F8         LDR NL0, [R2, #13]
; 8B0:       037C7F92         AND NL3, NL0, #8589934590
; 8B4:       805141F8         LDR NL0, [R2, #21]
; 8B8:       007C7F92         AND NL0, NL0, #8589934590
; 8BC:       29AA85D2         MOVZ TMP, #11601
; 8C0:       C993B9F2         MOVK TMP, #52382, LSL #16
; 8C4:       007C099B         MUL NL0, NL0, TMP
; 8C8:       007C7F92         AND NL0, NL0, #8589934590
; 8CC:       02C071D3         LSL NL2, NL0, #15
; 8D0:       01FC5193         ASR NL1, NL0, #17
; 8D4:       20F87F92         AND NL0, NL1, #18446744073709551614
; 8D8:       400000AA         ORR NL0, NL2, NL0
; 8DC:       007C7F92         AND NL0, NL0, #8589934590
; 8E0:       69B286D2         MOVZ TMP, #13715
; 8E4:       E970A3F2         MOVK TMP, #7047, LSL #16
; 8E8:       007C099B         MUL NL0, NL0, TMP
; 8EC:       007C7F92         AND NL0, NL0, #8589934590
; 8F0:       600000CA         EOR NL0, NL3, NL0
; 8F4:       02C873D3         LSL NL2, NL0, #13
; 8F8:       01FC5393         ASR NL1, NL0, #19
; 8FC:       20F87F92         AND NL0, NL1, #18446744073709551614
; 900:       400000AA         ORR NL0, NL2, NL0
; 904:       007C7F92         AND NL0, NL0, #8589934590
; 908:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 90C:       01D99AD2         MOVZ NL1, #54984
; 910:       0195B9F2         MOVK NL1, #52392, LSL #16
; 914:       2100C0F2         MOVK NL1, #1, LSL #32
; 918:       0000018B         ADD NL0, NL0, NL1
; 91C:       037C7F92         AND NL3, NL0, #8589934590
; 920:       8A5142F8         LDR R0, [R2, #37]
; 924:       ABE30091         ADD R1, NULL, #56               ; T
; 928:       5F010BEB         CMP R0, R1
; 92C:       21060054         BNE L1
; 930:       000080D2         MOVZ NL0, #0
; 934: L0:   29AA85D2         MOVZ TMP, #11601
; 938:       C993B9F2         MOVK TMP, #52382, LSL #16
; 93C:       007C099B         MUL NL0, NL0, TMP
; 940:       007C7F92         AND NL0, NL0, #8589934590
; 944:       02C071D3         LSL NL2, NL0, #15
; 948:       01FC5193         ASR NL1, NL0, #17
; 94C:       20F87F92         AND NL0, NL1, #18446744073709551614
; 950:       400000AA         ORR NL0, NL2, NL0
; 954:       007C7F92         AND NL0, NL0, #8589934590
; 958:       69B286D2         MOVZ TMP, #13715
; 95C:       E970A3F2         MOVK TMP, #7047, LSL #16
; 960:       007C099B         MUL NL0, NL0, TMP
; 964:       007C7F92         AND NL0, NL0, #8589934590
; 968:       600000CA         EOR NL0, NL3, NL0
; 96C:       02C873D3         LSL NL2, NL0, #13
; 970:       01FC5393         ASR NL1, NL0, #19
; 974:       20F87F92         AND NL0, NL1, #18446744073709551614
; 978:       400000AA         ORR NL0, NL2, NL0
; 97C:       007C7F92         AND NL0, NL0, #8589934590
; 980:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 984:       01D99AD2         MOVZ NL1, #54984
; 988:       0195B9F2         MOVK NL1, #52392, LSL #16
; 98C:       2100C0F2         MOVK NL1, #1, LSL #32
; 990:       0000018B         ADD NL0, NL0, NL1
; 994:       007C7F92         AND NL0, NL0, #8589934590
; 998:       00047DD2         EOR NL0, NL0, #24
; 99C:       01FC5093         ASR NL1, NL0, #16
; 9A0:       22F87F92         AND NL2, NL1, #18446744073709551614
; 9A4:       000002CA         EOR NL0, NL0, NL2
; 9A8:       694D99D2         MOVZ TMP, #51819
; 9AC:       69BDB0F2         MOVK TMP, #34283, LSL #16
; 9B0:       007C099B         MUL NL0, NL0, TMP
; 9B4:       007C7F92         AND NL0, NL0, #8589934590
; 9B8:       01FC4D93         ASR NL1, NL0, #13
; 9BC:       22F87F92         AND NL2, NL1, #18446744073709551614
; 9C0:       000002CA         EOR NL0, NL0, NL2
; 9C4:       A9C695D2         MOVZ TMP, #44597
; 9C8:       4956B8F2         MOVK TMP, #49842, LSL #16
; 9CC:       007C099B         MUL NL0, NL0, TMP
; 9D0:       007C7F92         AND NL0, NL0, #8589934590
; 9D4:       01FC5093         ASR NL1, NL0, #16
; 9D8:       22F87F92         AND NL2, NL1, #18446744073709551614
; 9DC:       0A0002CA         EOR R0, NL0, NL2
; 9E0:       FB031AAA         MOV CSP, CFP
; 9E4:       5A7B40A9         LDP CFP, LR, [CFP]
; 9E8:       BF0300F1         CMP NULL, #0
; 9EC:       C0035FD6         RET
; 9F0: L1:   430B00F9         STR NL3, [CFP, #16]
; 9F4:       8A5142F8         LDR R0, [R2, #37]
; 9F8:       7A0300F9         STR CFP, [CSP]
; 9FC:       36F2FF58         LDR LEXENV, #x700D72C840        ; #<SB-KERNEL:FDEFN SXHASH>
; A00:       570080D2         MOVZ NARGS, #2
; A04:       FA031BAA         MOV CFP, CSP
; A08:       DE9240F8         LDR LR, [LEXENV, #9]
; A0C:       C0033FD6         BLR LR
; A10:       430B40F9         LDR NL3, [CFP, #16]
; A14:       407D7F92         AND NL0, R0, #8589934590
; A18:       C7FFFF17         B L0
; A1C:       E00120D4         BRK #15                         ; Invalid argument count trap
