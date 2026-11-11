; disassembly for CNVRS/RUNTIME::CONTEXT-NODE
; Size: 576 bytes. Origin: #x700CE00BDC                       ; CNVRS/RUNTIME::CONTEXT-NODE
; BDC:       430080D2         MOVZ NL3, #2
; BE0:       040080D2         MOVZ NL4, #0
; BE4:       65915FF8         LDR NL5, [R1, #-7]
; BE8:       22000014         B L2
; BEC: L0:   6909048B         ADD TMP, R1, NL4, LSL #2
; BF0:       2A1140F8         LDR R0, [TMP, #1]
; BF4:       80080091         ADD NL0, NL4, #2
; BF8:       E40300AA         MOV NL4, NL0
; BFC:       5F011DEB         CMP R0, NULL
; C00:       C10E0054         BNE L9
; C04:       000080D2         MOVZ NL0, #0
; C08: L1:   29AA85D2         MOVZ TMP, #11601
; C0C:       C993B9F2         MOVK TMP, #52382, LSL #16
; C10:       007C099B         MUL NL0, NL0, TMP
; C14:       007C7F92         AND NL0, NL0, #8589934590
; C18:       02C071D3         LSL NL2, NL0, #15
; C1C:       01FC5193         ASR NL1, NL0, #17
; C20:       20F87F92         AND NL0, NL1, #18446744073709551614
; C24:       400000AA         ORR NL0, NL2, NL0
; C28:       007C7F92         AND NL0, NL0, #8589934590
; C2C:       69B286D2         MOVZ TMP, #13715
; C30:       E970A3F2         MOVK TMP, #7047, LSL #16
; C34:       007C099B         MUL NL0, NL0, TMP
; C38:       007C7F92         AND NL0, NL0, #8589934590
; C3C:       600000CA         EOR NL0, NL3, NL0
; C40:       02C873D3         LSL NL2, NL0, #13
; C44:       01FC5393         ASR NL1, NL0, #19
; C48:       20F87F92         AND NL0, NL1, #18446744073709551614
; C4C:       400000AA         ORR NL0, NL2, NL0
; C50:       007C7F92         AND NL0, NL0, #8589934590
; C54:       0008008B         ADD NL0, NL0, NL0, LSL #2
; C58:       01D99AD2         MOVZ NL1, #54984
; C5C:       0195B9F2         MOVK NL1, #52392, LSL #16
; C60:       2100C0F2         MOVK NL1, #1, LSL #32
; C64:       0000018B         ADD NL0, NL0, NL1
; C68:       007C7F92         AND NL0, NL0, #8589934590
; C6C:       E30300AA         MOV NL3, NL0
; C70: L2:   9F0005EB         CMP NL4, NL5
; C74:       CBFBFF54         BLT L0
; C78:       040080D2         MOVZ NL4, #0
; C7C:       A5915FF8         LDR NL5, [R3, #-7]
; C80:       21000014         B L4
; C84: L3:   A909048B         ADD TMP, R3, NL4, LSL #2
; C88:       2A1140F8         LDR R0, [TMP, #1]
; C8C:       80080091         ADD NL0, NL4, #2
; C90:       E40300AA         MOV NL4, NL0
; C94:       5F7D5FF2         TST R0, #18446744065119617025
; C98:       E1090054         BNE L8
; C9C:       29AA85D2         MOVZ TMP, #11601
; CA0:       C993B9F2         MOVK TMP, #52382, LSL #16
; CA4:       407D099B         MUL NL0, R0, TMP
; CA8:       007C7F92         AND NL0, NL0, #8589934590
; CAC:       02C071D3         LSL NL2, NL0, #15
; CB0:       01FC5193         ASR NL1, NL0, #17
; CB4:       20F87F92         AND NL0, NL1, #18446744073709551614
; CB8:       400000AA         ORR NL0, NL2, NL0
; CBC:       007C7F92         AND NL0, NL0, #8589934590
; CC0:       69B286D2         MOVZ TMP, #13715
; CC4:       E970A3F2         MOVK TMP, #7047, LSL #16
; CC8:       007C099B         MUL NL0, NL0, TMP
; CCC:       007C7F92         AND NL0, NL0, #8589934590
; CD0:       600000CA         EOR NL0, NL3, NL0
; CD4:       02C873D3         LSL NL2, NL0, #13
; CD8:       01FC5393         ASR NL1, NL0, #19
; CDC:       20F87F92         AND NL0, NL1, #18446744073709551614
; CE0:       400000AA         ORR NL0, NL2, NL0
; CE4:       007C7F92         AND NL0, NL0, #8589934590
; CE8:       0008008B         ADD NL0, NL0, NL0, LSL #2
; CEC:       01D99AD2         MOVZ NL1, #54984
; CF0:       0195B9F2         MOVK NL1, #52392, LSL #16
; CF4:       2100C0F2         MOVK NL1, #1, LSL #32
; CF8:       0000018B         ADD NL0, NL0, NL1
; CFC:       007C7F92         AND NL0, NL0, #8589934590
; D00:       E30300AA         MOV NL3, NL0
; D04: L4:   9F0005EB         CMP NL4, NL5
; D08:       EBFBFF54         BLT L3
; D0C:       A0915FF8         LDR NL0, [R3, #-7]
; D10:       00FC4193         ASR NL0, NL0, #1
; D14:       01F87FD3         LSL NL1, NL0, #1
; D18:       E00301AA         MOV NL0, NL1
; D1C:       E10300AA         MOV NL1, NL0
; D20:       3F0442F2         TST NL1, #13835058055282163712
; D24:       61050054         BNE L7
; D28:       600C00CA         EOR NL0, NL3, NL0, LSL #3
; D2C:       007C7F92         AND NL0, NL0, #8589934590
; D30:       01FC5093         ASR NL1, NL0, #16
; D34:       22F87F92         AND NL2, NL1, #18446744073709551614
; D38:       000002CA         EOR NL0, NL0, NL2
; D3C:       694D99D2         MOVZ TMP, #51819
; D40:       69BDB0F2         MOVK TMP, #34283, LSL #16
; D44:       007C099B         MUL NL0, NL0, TMP
; D48:       007C7F92         AND NL0, NL0, #8589934590
; D4C:       01FC4D93         ASR NL1, NL0, #13
; D50:       22F87F92         AND NL2, NL1, #18446744073709551614
; D54:       000002CA         EOR NL0, NL0, NL2
; D58:       A9C695D2         MOVZ TMP, #44597
; D5C:       4956B8F2         MOVK TMP, #49842, LSL #16
; D60:       007C099B         MUL NL0, NL0, TMP
; D64:       007C7F92         AND NL0, NL0, #8589934590
; D68:       01FC5093         ASR NL1, NL0, #16
; D6C:       22F87F92         AND NL2, NL1, #18446744073709551614
; D70:       000002CA         EOR NL0, NL0, NL2
; D74:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; D78:       A97A47A9         LDP TMP, LR, [THREAD, #112]     ; mixed-tlab.{free-pointer, end-addr}
; D7C:       2AC10091         ADD R0, TMP, #48
; D80:       5F011EEB         CMP R0, LR
; D84:       48040054         BHI L11
; D88:       AA3A00F9         STR R0, [THREAD, #112]          ; mixed-tlab
; D8C: L5:   2A0D0091         ADD R0, TMP, #3
; D90:       3E0782D2         MOVZ LR, #4153
; D94:       5ED11FF8         STR LR, [R0, #-3]
; D98:       BF3A03D5         DMB ISHST
; D9C:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; DA0:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; DA4:       5E0000B4         CBZ LR, L6
; DA8:       200120D4         BRK #9                          ; Pending interrupt trap
; DAC: L6:   2CEDFF58         LDR R2, #x700CE00B50            ; #<SB-KERNEL:LAYOUT (ID=391) for CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT {700CD509B3}>
; DB0:       4C5100F8         STR R2, [R0, #5]
; DB4:       40D100F8         STR NL0, [R0, #13]
; DB8:       4D5101F8         STR R3, [R0, #21]
; DBC:       4BD101F8         STR R1, [R0, #29]
; DC0:       FB031AAA         MOV CSP, CFP
; DC4:       5A7B40A9         LDP CFP, LR, [CFP]
; DC8:       BF0300F1         CMP NULL, #0
; DCC:       C0035FD6         RET
; DD0: L7:   201528D4         BRK #16553                      ; OBJECT-NOT-UNSIGNED-FIXNUM-ERROR
                                                              ; NL0
; DD4: L8:   604D21D4         BRK #2667                       ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; DD8: L9:   410D4092         AND NL1, R0, #15
; DDC:       3F0C00F1         CMP NL1, #3
; DE0:       01010054         BNE L10
; DE4:       4C5140F8         LDR R2, [R0, #5]
; DE8:       825145B8         LDR WNL2, [R2, #85]
; DEC:       21ECFF18         LDR WNL1, #x700CE00B70
; DF0:       5F00016B         CMP WNL2, WNL1
; DF4:       61000054         BNE L10
; DF8:       40D140F8         LDR NL0, [R0, #13]
; DFC:       83FFFF17         B L1
; E00: L10:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; E04:       27               BYTE #X27                       ; #<SB-KERNEL:LAYOUT (ID=389) for CNVRS/RUNTIME:PREDICTION-CONTEXT {700CD54203}>
; E05:       .ALIGN           4
; E08:       E00120D4         BRK #15                         ; Invalid argument count trap
; E0C: L11:  090680D2         MOVZ TMP, #48
; E10:       CAEAFF58         LDR R0, #x700CE00B68            ; SB-VM::ALLOC-TRAMP
; E14:       40013FD6         BLR R0
; E18:       DDFFFF17         B L5
