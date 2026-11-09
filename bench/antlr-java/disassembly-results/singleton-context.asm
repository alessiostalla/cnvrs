; disassembly for CNVRS/ANTLR-RUNTIME:SINGLETON-CONTEXT
; Size: 504 bytes. Origin: #x700CE01880                       ; CNVRS/ANTLR-RUNTIME:SINGLETON-CONTEXT
; 880:       BF011DEB         CMP R3, NULL
; 884:       600D0054         BEQ L7
; 888: L0:   BF011DEB         CMP R3, NULL
; 88C:       E00C0054         BEQ L6
; 890:       A10D4092         AND NL1, R3, #15
; 894:       3F0C00F1         CMP NL1, #3
; 898:       410C0054         BNE L5
; 89C:       AC5140F8         LDR R2, [R3, #5]
; 8A0:       825145B8         LDR WNL2, [R2, #85]
; 8A4:       E1FCFF18         LDR WNL1, #x700CE01840
; 8A8:       5F00016B         CMP WNL2, WNL1
; 8AC:       A10B0054         BNE L5
; 8B0:       A0D140F8         LDR NL0, [R3, #13]
; 8B4: L1:   29AA85D2         MOVZ TMP, #11601
; 8B8:       C993B9F2         MOVK TMP, #52382, LSL #16
; 8BC:       007C099B         MUL NL0, NL0, TMP
; 8C0:       007C7F92         AND NL0, NL0, #8589934590
; 8C4:       02C071D3         LSL NL2, NL0, #15
; 8C8:       01FC5193         ASR NL1, NL0, #17
; 8CC:       20F87F92         AND NL0, NL1, #18446744073709551614
; 8D0:       400000AA         ORR NL0, NL2, NL0
; 8D4:       007C7F92         AND NL0, NL0, #8589934590
; 8D8:       69B286D2         MOVZ TMP, #13715
; 8DC:       E970A3F2         MOVK TMP, #7047, LSL #16
; 8E0:       007C099B         MUL NL0, NL0, TMP
; 8E4:       007C7F92         AND NL0, NL0, #8589934590
; 8E8:       00007FD2         EOR NL0, NL0, #2
; 8EC:       02C873D3         LSL NL2, NL0, #13
; 8F0:       01FC5393         ASR NL1, NL0, #19
; 8F4:       20F87F92         AND NL0, NL1, #18446744073709551614
; 8F8:       400000AA         ORR NL0, NL2, NL0
; 8FC:       007C7F92         AND NL0, NL0, #8589934590
; 900:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 904:       01D99AD2         MOVZ NL1, #54984
; 908:       0195B9F2         MOVK NL1, #52392, LSL #16
; 90C:       2100C0F2         MOVK NL1, #1, LSL #32
; 910:       0000018B         ADD NL0, NL0, NL1
; 914:       037C7F92         AND NL3, NL0, #8589934590
; 918:       29AA85D2         MOVZ TMP, #11601
; 91C:       C993B9F2         MOVK TMP, #52382, LSL #16
; 920:       607D099B         MUL NL0, R1, TMP
; 924:       007C7F92         AND NL0, NL0, #8589934590
; 928:       02C071D3         LSL NL2, NL0, #15
; 92C:       01FC5193         ASR NL1, NL0, #17
; 930:       20F87F92         AND NL0, NL1, #18446744073709551614
; 934:       400000AA         ORR NL0, NL2, NL0
; 938:       007C7F92         AND NL0, NL0, #8589934590
; 93C:       69B286D2         MOVZ TMP, #13715
; 940:       E970A3F2         MOVK TMP, #7047, LSL #16
; 944:       007C099B         MUL NL0, NL0, TMP
; 948:       007C7F92         AND NL0, NL0, #8589934590
; 94C:       600000CA         EOR NL0, NL3, NL0
; 950:       02C873D3         LSL NL2, NL0, #13
; 954:       01FC5393         ASR NL1, NL0, #19
; 958:       20F87F92         AND NL0, NL1, #18446744073709551614
; 95C:       400000AA         ORR NL0, NL2, NL0
; 960:       007C7F92         AND NL0, NL0, #8589934590
; 964:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 968:       01D99AD2         MOVZ NL1, #54984
; 96C:       0195B9F2         MOVK NL1, #52392, LSL #16
; 970:       2100C0F2         MOVK NL1, #1, LSL #32
; 974:       0000018B         ADD NL0, NL0, NL1
; 978:       007C7F92         AND NL0, NL0, #8589934590
; 97C:       00007CD2         EOR NL0, NL0, #16
; 980:       01FC5093         ASR NL1, NL0, #16
; 984:       22F87F92         AND NL2, NL1, #18446744073709551614
; 988:       000002CA         EOR NL0, NL0, NL2
; 98C:       694D99D2         MOVZ TMP, #51819
; 990:       69BDB0F2         MOVK TMP, #34283, LSL #16
; 994:       007C099B         MUL NL0, NL0, TMP
; 998:       007C7F92         AND NL0, NL0, #8589934590
; 99C:       01FC4D93         ASR NL1, NL0, #13
; 9A0:       22F87F92         AND NL2, NL1, #18446744073709551614
; 9A4:       000002CA         EOR NL0, NL0, NL2
; 9A8:       A9C695D2         MOVZ TMP, #44597
; 9AC:       4956B8F2         MOVK TMP, #49842, LSL #16
; 9B0:       007C099B         MUL NL0, NL0, TMP
; 9B4:       007C7F92         AND NL0, NL0, #8589934590
; 9B8:       01FC5093         ASR NL1, NL0, #16
; 9BC:       22F87F92         AND NL2, NL1, #18446744073709551614
; 9C0:       000002CA         EOR NL0, NL0, NL2
; 9C4:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 9C8:       A97A47A9         LDP TMP, LR, [THREAD, #112]     ; mixed-tlab.{free-pointer, end-addr}
; 9CC:       2AC10091         ADD R0, TMP, #48
; 9D0:       5F011EEB         CMP R0, LR
; 9D4:       88040054         BHI L9
; 9D8:       AA3A00F9         STR R0, [THREAD, #112]          ; mixed-tlab
; 9DC: L2:   2A0D0091         ADD R0, TMP, #3
; 9E0:       3E0782D2         MOVZ LR, #4153
; 9E4:       5ED11FF8         STR LR, [R0, #-3]
; 9E8:       BF3A03D5         DMB ISHST
; 9EC:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 9F0:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 9F4:       5E0000B4         CBZ LR, L3
; 9F8:       200120D4         BRK #9                          ; Pending interrupt trap
; 9FC: L3:   ACF0FF58         LDR R2, #x700CE01810            ; #<SB-KERNEL:LAYOUT (ID=390) for CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT {700CD54283}>
; A00:       4C5100F8         STR R2, [R0, #5]
; A04:       40D100F8         STR NL0, [R0, #13]
; A08:       4D5101F8         STR R3, [R0, #21]
; A0C:       4BD101F8         STR R1, [R0, #29]
; A10: L4:   FB031AAA         MOV CSP, CFP
; A14:       5A7B40A9         LDP CFP, LR, [CFP]
; A18:       BF0300F1         CMP NULL, #0
; A1C:       C0035FD6         RET
; A20: L5:   60A321D4         BRK #3355                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R3
; A24:       27               BYTE #X27                       ; #<SB-KERNEL:LAYOUT (ID=389) for CNVRS/ANTLR-RUNTIME:PREDICTION-CONTEXT {700CD54203}>
; A25:       .ALIGN           4
; A28: L6:   000080D2         MOVZ NL0, #0
; A2C:       A2FFFF17         B L1
; A30: L7:   E97B7FB2         MOV TMP, #4294967294
; A34:       7F0109EB         CMP R1, TMP
; A38:       81F2FF54         BNE L0
; A3C:       2BEFFF58         LDR R1, #x700CE01820            ; 'CNVRS/ANTLR-RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; A40:       61515FB8         LDR WNL1, [R1, #-11]
; A44:       AA6A61F8         LDR R0, [THREAD, NL1]
; A48:       5F0500B1         CMN R0, #1
; A4C:       41000054         BNE L8
; A50:       6A1140F8         LDR R0, [R1, #1]
; A54: L8:   5F2500F1         CMP R0, #9
; A58:       E0000054         BEQ L10
; A5C:       EDFFFF17         B L4
; A60:       E00120D4         BRK #15                         ; Invalid argument count trap
; A64: L9:   090680D2         MOVZ TMP, #48
; A68:       8AEEFF58         LDR R0, #x700CE01838            ; SB-VM::ALLOC-TRAMP
; A6C:       40013FD6         BLR R0
; A70:       DBFFFF17         B L2
; A74: L10:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
