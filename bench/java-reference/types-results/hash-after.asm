; disassembly for CNVRS/RUNTIME::MURMUR-UPDATE
; Size: 120 bytes. Origin: #x70084DF1E8                       ; CNVRS/RUNTIME::MURMUR-UPDATE
; 1E8:       29AA85D2         MOVZ TMP, #11601
; 1EC:       C993B9F2         MOVK TMP, #52382, LSL #16
; 1F0:       607D099B         MUL NL0, R1, TMP
; 1F4:       007C7F92         AND NL0, NL0, #8589934590
; 1F8:       02C071D3         LSL NL2, NL0, #15
; 1FC:       01FC5193         ASR NL1, NL0, #17
; 200:       20F87F92         AND NL0, NL1, #18446744073709551614
; 204:       400000AA         ORR NL0, NL2, NL0
; 208:       007C7F92         AND NL0, NL0, #8589934590
; 20C:       69B286D2         MOVZ TMP, #13715
; 210:       E970A3F2         MOVK TMP, #7047, LSL #16
; 214:       007C099B         MUL NL0, NL0, TMP
; 218:       007C7F92         AND NL0, NL0, #8589934590
; 21C:       400100CA         EOR NL0, R0, NL0
; 220:       02C873D3         LSL NL2, NL0, #13
; 224:       01FC5393         ASR NL1, NL0, #19
; 228:       20F87F92         AND NL0, NL1, #18446744073709551614
; 22C:       400000AA         ORR NL0, NL2, NL0
; 230:       007C7F92         AND NL0, NL0, #8589934590
; 234:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 238:       01D99AD2         MOVZ NL1, #54984
; 23C:       0195B9F2         MOVK NL1, #52392, LSL #16
; 240:       2100C0F2         MOVK NL1, #1, LSL #32
; 244:       0000018B         ADD NL0, NL0, NL1
; 248:       0A7C7F92         AND R0, NL0, #8589934590
; 24C:       FB031AAA         MOV CSP, CFP
; 250:       5A7B40A9         LDP CFP, LR, [CFP]
; 254:       BF0300F1         CMP NULL, #0
; 258:       C0035FD6         RET
; 25C:       E00120D4         BRK #15                         ; Invalid argument count trap
; disassembly for CNVRS/RUNTIME::MURMUR-FINISH
; Size: 96 bytes. Origin: #x70084DF2F8                        ; CNVRS/RUNTIME::MURMUR-FINISH
; 2F8:       40090BCA         EOR NL0, R0, R1, LSL #2
; 2FC:       007C7F92         AND NL0, NL0, #8589934590
; 300:       01FC5093         ASR NL1, NL0, #16
; 304:       22F87F92         AND NL2, NL1, #18446744073709551614
; 308:       000002CA         EOR NL0, NL0, NL2
; 30C:       694D99D2         MOVZ TMP, #51819
; 310:       69BDB0F2         MOVK TMP, #34283, LSL #16
; 314:       007C099B         MUL NL0, NL0, TMP
; 318:       007C7F92         AND NL0, NL0, #8589934590
; 31C:       01FC4D93         ASR NL1, NL0, #13
; 320:       22F87F92         AND NL2, NL1, #18446744073709551614
; 324:       000002CA         EOR NL0, NL0, NL2
; 328:       A9C695D2         MOVZ TMP, #44597
; 32C:       4956B8F2         MOVK TMP, #49842, LSL #16
; 330:       007C099B         MUL NL0, NL0, TMP
; 334:       007C7F92         AND NL0, NL0, #8589934590
; 338:       01FC5093         ASR NL1, NL0, #16
; 33C:       22F87F92         AND NL2, NL1, #18446744073709551614
; 340:       0A0002CA         EOR R0, NL0, NL2
; 344:       FB031AAA         MOV CSP, CFP
; 348:       5A7B40A9         LDP CFP, LR, [CFP]
; 34C:       BF0300F1         CMP NULL, #0
; 350:       C0035FD6         RET
; 354:       E00120D4         BRK #15                         ; Invalid argument count trap
