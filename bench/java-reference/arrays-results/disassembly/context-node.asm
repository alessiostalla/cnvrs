; disassembly for CNVRS/RUNTIME::CONTEXT-NODE
; Size: 720 bytes. Origin: #x700D72EE20                       ; CNVRS/RUNTIME::CONTEXT-NODE
; EE20:       81115F38         LDRB WNL1, [R2, #-15]
; EE24:       3FB402F1         CMP NL1, #173
; EE28:       60030054         BEQ L0
; EE2C:       80915FF8         LDR NL0, [R2, #-7]
; EE30:       ED030CAA         MOV R3, R2
; EE34:       81915FF8         LDR NL1, [R2, #-7]
; EE38:       1F0001EB         CMP NL0, NL1
; EE3C:       41140054         BNE L12
; EE40:       02080091         ADD NL2, NL0, #2
; EE44:       41FC4193         ASR NL1, NL2, #1
; EE48:       22F87F92         AND NL2, NL1, #18446744073709551614
; EE4C:       E1E77DB2         MOV NL1, #2305843009213693944
; EE50:       5F0001EB         CMP NL2, NL1
; EE54:       48130054         BHI L11
; EE58:       4E0F00F9         STR R4, [CFP, #24]
; EE5C:       4C2B80D2         MOVZ R2, #346
; EE60:       EB0300AA         MOV R1, NL0
; EE64:       EA0302AA         MOV R0, NL2
; EE68:       9EF9FF58         LDR LR, #x700D72ED98           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; EE6C:       C0033FD6         BLR LR
; EE70:       7A0300F9         STR CFP, [CSP]
; EE74:       EB030DAA         MOV R1, R3
; EE78:       56F7FF58         LDR LEXENV, #x700D72ED60       ; #<SB-KERNEL:FDEFN REPLACE>
; EE7C:       970080D2         MOVZ NARGS, #4
; EE80:       FA031BAA         MOV CFP, CSP
; EE84:       DE9240F8         LDR LR, [LEXENV, #9]
; EE88:       C0033FD6         BLR LR
; EE8C:       4E0F40F9         LDR R4, [CFP, #24]
; EE90:       EC030AAA         MOV R2, R0
; EE94: L0:   430080D2         MOVZ NL3, #2
; EE98:       050080D2         MOVZ NL5, #0
; EE9C:       C6915FF8         LDR NL6, [R4, #-7]
; EEA0:       22000014         B L3
; EEA4: L1:   C909058B         ADD TMP, R4, NL5, LSL #2
; EEA8:       2A1140F8         LDR R0, [TMP, #1]
; EEAC:       A0080091         ADD NL0, NL5, #2
; EEB0:       E50300AA         MOV NL5, NL0
; EEB4:       5F011DEB         CMP R0, NULL
; EEB8:       A10E0054         BNE L9
; EEBC:       000080D2         MOVZ NL0, #0
; EEC0: L2:   29AA85D2         MOVZ TMP, #11601
; EEC4:       C993B9F2         MOVK TMP, #52382, LSL #16
; EEC8:       007C099B         MUL NL0, NL0, TMP
; EECC:       007C7F92         AND NL0, NL0, #8589934590
; EED0:       02C071D3         LSL NL2, NL0, #15
; EED4:       01FC5193         ASR NL1, NL0, #17
; EED8:       20F87F92         AND NL0, NL1, #18446744073709551614
; EEDC:       400000AA         ORR NL0, NL2, NL0
; EEE0:       007C7F92         AND NL0, NL0, #8589934590
; EEE4:       69B286D2         MOVZ TMP, #13715
; EEE8:       E970A3F2         MOVK TMP, #7047, LSL #16
; EEEC:       007C099B         MUL NL0, NL0, TMP
; EEF0:       007C7F92         AND NL0, NL0, #8589934590
; EEF4:       600000CA         EOR NL0, NL3, NL0
; EEF8:       02C873D3         LSL NL2, NL0, #13
; EEFC:       01FC5393         ASR NL1, NL0, #19
; EF00:       20F87F92         AND NL0, NL1, #18446744073709551614
; EF04:       400000AA         ORR NL0, NL2, NL0
; EF08:       007C7F92         AND NL0, NL0, #8589934590
; EF0C:       0008008B         ADD NL0, NL0, NL0, LSL #2
; EF10:       01D99AD2         MOVZ NL1, #54984
; EF14:       0195B9F2         MOVK NL1, #52392, LSL #16
; EF18:       2100C0F2         MOVK NL1, #1, LSL #32
; EF1C:       0000018B         ADD NL0, NL0, NL1
; EF20:       007C7F92         AND NL0, NL0, #8589934590
; EF24:       E30300AA         MOV NL3, NL0
; EF28: L3:   BF0006EB         CMP NL5, NL6
; EF2C:       CBFBFF54         BLT L1
; EF30:       EA030CAA         MOV R0, R2
; EF34:       040080D2         MOVZ NL4, #0
; EF38:       85915FF8         LDR NL5, [R2, #-7]
; EF3C:       20000014         B L5
; EF40: L4:   4905048B         ADD TMP, R0, NL4, LSL #1
; EF44:       201140B8         LDR WNL0, [TMP, #1]
; EF48:       00F87FD3         LSL NL0, NL0, #1
; EF4C:       81080091         ADD NL1, NL4, #2
; EF50:       E40301AA         MOV NL4, NL1
; EF54:       29AA85D2         MOVZ TMP, #11601
; EF58:       C993B9F2         MOVK TMP, #52382, LSL #16
; EF5C:       007C099B         MUL NL0, NL0, TMP
; EF60:       007C7F92         AND NL0, NL0, #8589934590
; EF64:       02C071D3         LSL NL2, NL0, #15
; EF68:       01FC5193         ASR NL1, NL0, #17
; EF6C:       20F87F92         AND NL0, NL1, #18446744073709551614
; EF70:       400000AA         ORR NL0, NL2, NL0
; EF74:       007C7F92         AND NL0, NL0, #8589934590
; EF78:       69B286D2         MOVZ TMP, #13715
; EF7C:       E970A3F2         MOVK TMP, #7047, LSL #16
; EF80:       007C099B         MUL NL0, NL0, TMP
; EF84:       007C7F92         AND NL0, NL0, #8589934590
; EF88:       600000CA         EOR NL0, NL3, NL0
; EF8C:       02C873D3         LSL NL2, NL0, #13
; EF90:       01FC5393         ASR NL1, NL0, #19
; EF94:       20F87F92         AND NL0, NL1, #18446744073709551614
; EF98:       400000AA         ORR NL0, NL2, NL0
; EF9C:       007C7F92         AND NL0, NL0, #8589934590
; EFA0:       0008008B         ADD NL0, NL0, NL0, LSL #2
; EFA4:       01D99AD2         MOVZ NL1, #54984
; EFA8:       0195B9F2         MOVK NL1, #52392, LSL #16
; EFAC:       2100C0F2         MOVK NL1, #1, LSL #32
; EFB0:       0000018B         ADD NL0, NL0, NL1
; EFB4:       007C7F92         AND NL0, NL0, #8589934590
; EFB8:       E30300AA         MOV NL3, NL0
; EFBC: L5:   9F0005EB         CMP NL4, NL5
; EFC0:       0BFCFF54         BLT L4
; EFC4:       80915FF8         LDR NL0, [R2, #-7]
; EFC8:       00FC4193         ASR NL0, NL0, #1
; EFCC:       01F87FD3         LSL NL1, NL0, #1
; EFD0:       E00301AA         MOV NL0, NL1
; EFD4:       E10300AA         MOV NL1, NL0
; EFD8:       3F0442F2         TST NL1, #13835058055282163712
; EFDC:       61050054         BNE L8
; EFE0:       600C00CA         EOR NL0, NL3, NL0, LSL #3
; EFE4:       007C7F92         AND NL0, NL0, #8589934590
; EFE8:       01FC5093         ASR NL1, NL0, #16
; EFEC:       22F87F92         AND NL2, NL1, #18446744073709551614
; EFF0:       000002CA         EOR NL0, NL0, NL2
; EFF4:       694D99D2         MOVZ TMP, #51819
; EFF8:       69BDB0F2         MOVK TMP, #34283, LSL #16
; EFFC:       007C099B         MUL NL0, NL0, TMP
; F000:       007C7F92         AND NL0, NL0, #8589934590
; F004:       01FC4D93         ASR NL1, NL0, #13
; F008:       22F87F92         AND NL2, NL1, #18446744073709551614
; F00C:       000002CA         EOR NL0, NL0, NL2
; F010:       A9C695D2         MOVZ TMP, #44597
; F014:       4956B8F2         MOVK TMP, #49842, LSL #16
; F018:       007C099B         MUL NL0, NL0, TMP
; F01C:       007C7F92         AND NL0, NL0, #8589934590
; F020:       01FC5093         ASR NL1, NL0, #16
; F024:       22F87F92         AND NL2, NL1, #18446744073709551614
; F028:       000002CA         EOR NL0, NL0, NL2
; F02C:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; F030:       A97A47A9         LDP TMP, LR, [THREAD, #112]    ; mixed-tlab.{free-pointer, end-addr}
; F034:       2AC10091         ADD R0, TMP, #48
; F038:       5F011EEB         CMP R0, LR
; F03C:       28050054         BHI L13
; F040:       AA3A00F9         STR R0, [THREAD, #112]         ; mixed-tlab
; F044: L6:   2A0D0091         ADD R0, TMP, #3
; F048:       3E0782D2         MOVZ LR, #4153
; F04C:       5ED11FF8         STR LR, [R0, #-3]
; F050:       BF3A03D5         DMB ISHST
; F054:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; F058:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; F05C:       5E0000B4         CBZ LR, L7
; F060:       200120D4         BRK #9                         ; Pending interrupt trap
; F064: L7:   ABE8FF58         LDR R1, #x700D72ED78           ; #<SB-KERNEL:LAYOUT (ID=391) for CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT {700CD58FC3}>
; F068:       4B5100F8         STR R1, [R0, #5]
; F06C:       40D100F8         STR NL0, [R0, #13]
; F070:       4C5101F8         STR R2, [R0, #21]
; F074:       4ED101F8         STR R4, [R0, #29]
; F078:       FB031AAA         MOV CSP, CFP
; F07C:       5A7B40A9         LDP CFP, LR, [CFP]
; F080:       BF0300F1         CMP NULL, #0
; F084:       C0035FD6         RET
; F088: L8:   201528D4         BRK #16553                     ; OBJECT-NOT-UNSIGNED-FIXNUM-ERROR
                                                              ; NL0
; F08C: L9:   410D4092         AND NL1, R0, #15
; F090:       3F0C00F1         CMP NL1, #3
; F094:       01010054         BNE L10
; F098:       4D5140F8         LDR R3, [R0, #5]
; F09C:       A45145B8         LDR WNL4, [R3, #85]
; F0A0:       41E8FF18         LDR WNL1, #x700D72EDA8
; F0A4:       9F00016B         CMP WNL4, WNL1
; F0A8:       61000054         BNE L10
; F0AC:       40D140F8         LDR NL0, [R0, #13]
; F0B0:       84FFFF17         B L2
; F0B4: L10:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; F0B8:       33               BYTE #X33                      ; #<SB-KERNEL:LAYOUT (ID=389) for CNVRS/RUNTIME:PREDICTION-CONTEXT {700CD58EC3}>
; F0B9:       .ALIGN           4
; F0BC: L11:  604320D4         BRK #539                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NL2
; F0C0:       37               BYTE #X37                      ; '(MOD
                                                              ;   1152921504606846973)
; F0C1:       .ALIGN           4
; F0C4: L12:  EA0301AA         MOV R0, NL1
; F0C8:       EB0300AA         MOV R1, NL0
; F0CC:       F6E4FF58         LDR LEXENV, #x700D72ED68       ; #<SB-KERNEL:FDEFN SB-VM::INITIAL-CONTENTS-ERROR>
; F0D0:       DE9240F8         LDR LR, [LEXENV, #9]
; F0D4:       DE130091         ADD LR, LR, #4
; F0D8:       C0031FD6         BR LR
; F0DC:       E00120D4         BRK #15                        ; Invalid argument count trap
; F0E0: L13:  090680D2         MOVZ TMP, #48
; F0E4:       EAE5FF58         LDR R0, #x700D72EDA0           ; SB-VM::ALLOC-TRAMP
; F0E8:       40013FD6         BLR R0
; F0EC:       D6FFFF17         B L6
