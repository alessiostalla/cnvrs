; disassembly for CNVRS/RUNTIME:SINGLETON-CONTEXT
; Size: 464 bytes. Origin: #x700D72F1E0                       ; CNVRS/RUNTIME:SINGLETON-CONTEXT
; 1E0:       BF011DEB         CMP R3, NULL
; 1E4:       200C0054         BEQ L6
; 1E8: L0:   BF011DEB         CMP R3, NULL
; 1EC:       A00B0054         BEQ L5
; 1F0:       A0D140F8         LDR NL0, [R3, #13]
; 1F4: L1:   29AA85D2         MOVZ TMP, #11601
; 1F8:       C993B9F2         MOVK TMP, #52382, LSL #16
; 1FC:       007C099B         MUL NL0, NL0, TMP
; 200:       007C7F92         AND NL0, NL0, #8589934590
; 204:       02C071D3         LSL NL2, NL0, #15
; 208:       01FC5193         ASR NL1, NL0, #17
; 20C:       20F87F92         AND NL0, NL1, #18446744073709551614
; 210:       400000AA         ORR NL0, NL2, NL0
; 214:       007C7F92         AND NL0, NL0, #8589934590
; 218:       69B286D2         MOVZ TMP, #13715
; 21C:       E970A3F2         MOVK TMP, #7047, LSL #16
; 220:       007C099B         MUL NL0, NL0, TMP
; 224:       007C7F92         AND NL0, NL0, #8589934590
; 228:       00007FD2         EOR NL0, NL0, #2
; 22C:       02C873D3         LSL NL2, NL0, #13
; 230:       01FC5393         ASR NL1, NL0, #19
; 234:       20F87F92         AND NL0, NL1, #18446744073709551614
; 238:       400000AA         ORR NL0, NL2, NL0
; 23C:       007C7F92         AND NL0, NL0, #8589934590
; 240:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 244:       01D99AD2         MOVZ NL1, #54984
; 248:       0195B9F2         MOVK NL1, #52392, LSL #16
; 24C:       2100C0F2         MOVK NL1, #1, LSL #32
; 250:       0000018B         ADD NL0, NL0, NL1
; 254:       037C7F92         AND NL3, NL0, #8589934590
; 258:       29AA85D2         MOVZ TMP, #11601
; 25C:       C993B9F2         MOVK TMP, #52382, LSL #16
; 260:       607D099B         MUL NL0, R1, TMP
; 264:       007C7F92         AND NL0, NL0, #8589934590
; 268:       02C071D3         LSL NL2, NL0, #15
; 26C:       01FC5193         ASR NL1, NL0, #17
; 270:       20F87F92         AND NL0, NL1, #18446744073709551614
; 274:       400000AA         ORR NL0, NL2, NL0
; 278:       007C7F92         AND NL0, NL0, #8589934590
; 27C:       69B286D2         MOVZ TMP, #13715
; 280:       E970A3F2         MOVK TMP, #7047, LSL #16
; 284:       007C099B         MUL NL0, NL0, TMP
; 288:       007C7F92         AND NL0, NL0, #8589934590
; 28C:       600000CA         EOR NL0, NL3, NL0
; 290:       02C873D3         LSL NL2, NL0, #13
; 294:       01FC5393         ASR NL1, NL0, #19
; 298:       20F87F92         AND NL0, NL1, #18446744073709551614
; 29C:       400000AA         ORR NL0, NL2, NL0
; 2A0:       007C7F92         AND NL0, NL0, #8589934590
; 2A4:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 2A8:       01D99AD2         MOVZ NL1, #54984
; 2AC:       0195B9F2         MOVK NL1, #52392, LSL #16
; 2B0:       2100C0F2         MOVK NL1, #1, LSL #32
; 2B4:       0000018B         ADD NL0, NL0, NL1
; 2B8:       007C7F92         AND NL0, NL0, #8589934590
; 2BC:       00007CD2         EOR NL0, NL0, #16
; 2C0:       01FC5093         ASR NL1, NL0, #16
; 2C4:       22F87F92         AND NL2, NL1, #18446744073709551614
; 2C8:       000002CA         EOR NL0, NL0, NL2
; 2CC:       694D99D2         MOVZ TMP, #51819
; 2D0:       69BDB0F2         MOVK TMP, #34283, LSL #16
; 2D4:       007C099B         MUL NL0, NL0, TMP
; 2D8:       007C7F92         AND NL0, NL0, #8589934590
; 2DC:       01FC4D93         ASR NL1, NL0, #13
; 2E0:       22F87F92         AND NL2, NL1, #18446744073709551614
; 2E4:       000002CA         EOR NL0, NL0, NL2
; 2E8:       A9C695D2         MOVZ TMP, #44597
; 2EC:       4956B8F2         MOVK TMP, #49842, LSL #16
; 2F0:       007C099B         MUL NL0, NL0, TMP
; 2F4:       007C7F92         AND NL0, NL0, #8589934590
; 2F8:       01FC5093         ASR NL1, NL0, #16
; 2FC:       22F87F92         AND NL2, NL1, #18446744073709551614
; 300:       000002CA         EOR NL0, NL0, NL2
; 304:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 308:       A97A47A9         LDP TMP, LR, [THREAD, #112]     ; mixed-tlab.{free-pointer, end-addr}
; 30C:       2AC10091         ADD R0, TMP, #48
; 310:       5F011EEB         CMP R0, LR
; 314:       48040054         BHI L8
; 318:       AA3A00F9         STR R0, [THREAD, #112]          ; mixed-tlab
; 31C: L2:   2A0D0091         ADD R0, TMP, #3
; 320:       3E0782D2         MOVZ LR, #4153
; 324:       5ED11FF8         STR LR, [R0, #-3]
; 328:       BF3A03D5         DMB ISHST
; 32C:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 330:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 334:       5E0000B4         CBZ LR, L3
; 338:       200120D4         BRK #9                          ; Pending interrupt trap
; 33C: L3:   6CF0FF58         LDR R2, #x700D72F148            ; #<SB-KERNEL:LAYOUT (ID=390) for CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT {700CD58F43}>
; 340:       4C5100F8         STR R2, [R0, #5]
; 344:       40D100F8         STR NL0, [R0, #13]
; 348:       4D5101F8         STR R3, [R0, #21]
; 34C:       4BD101F8         STR R1, [R0, #29]
; 350: L4:   FB031AAA         MOV CSP, CFP
; 354:       5A7B40A9         LDP CFP, LR, [CFP]
; 358:       BF0300F1         CMP NULL, #0
; 35C:       C0035FD6         RET
; 360: L5:   000080D2         MOVZ NL0, #0
; 364:       A4FFFF17         B L1
; 368: L6:   E97B7FB2         MOV TMP, #4294967294
; 36C:       7F0109EB         CMP R1, TMP
; 370:       C1F3FF54         BNE L0
; 374:       EBEEFF58         LDR R1, #x700D72F150            ; 'CNVRS/RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; 378:       61515FB8         LDR WNL1, [R1, #-11]
; 37C:       AA6A61F8         LDR R0, [THREAD, NL1]
; 380:       5F0500B1         CMN R0, #1
; 384:       41000054         BNE L7
; 388:       6A1140F8         LDR R0, [R1, #1]
; 38C: L7:   5F2500F1         CMP R0, #9
; 390:       E0000054         BEQ L9
; 394:       EFFFFF17         B L4
; 398:       E00120D4         BRK #15                         ; Invalid argument count trap
; 39C: L8:   090680D2         MOVZ TMP, #48
; 3A0:       4AEEFF58         LDR R0, #x700D72F168            ; SB-VM::ALLOC-TRAMP
; 3A4:       40013FD6         BLR R0
; 3A8:       DDFFFF17         B L2
; 3AC: L9:   E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
