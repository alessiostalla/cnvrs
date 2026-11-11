; disassembly for CNVRS/RUNTIME::MURMUR-UPDATE
; Size: 324 bytes. Origin: #x70084BF26C                       ; CNVRS/RUNTIME::MURMUR-UPDATE
; 26C:       AA0A40F9         LDR R0, [THREAD, #16]           ; binding-stack-pointer
; 270:       4A0B00F9         STR R0, [CFP, #16]
; 274:       7A0300F9         STR CFP, [CSP]
; 278:       4A1340F9         LDR R0, [CFP, #32]
; 27C:       4B548BD2         MOVZ R1, #23202
; 280:       8B27B3F2         MOVK R1, #39228, LSL #16
; 284:       2B00C0F2         MOVK R1, #1, LSL #32
; 288:       FA031BAA         MOV CFP, CSP
; 28C:       29B280D2         MOVZ TMP, #1425
; 290:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:TWO-ARG-*
; 294:       C0033FD6         BLR LR
; 298:       7A0300F9         STR CFP, [CSP]
; 29C:       B6FBFF58         LDR LEXENV, #x70084BF210        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::U32>
; 2A0:       570080D2         MOVZ NARGS, #2
; 2A4:       FA031BAA         MOV CFP, CSP
; 2A8:       DE9240F8         LDR LR, [LEXENV, #9]
; 2AC:       C0033FD6         BLR LR
; 2B0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 2B4:       5F7D5FF2         TST R0, #18446744065119617025
; 2B8:       81070054         BNE L1
; 2BC:       7A0300F9         STR CFP, [CSP]
; 2C0:       CB0380D2         MOVZ R1, #30
; 2C4:       B6FAFF58         LDR LEXENV, #x70084BF218        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::ROTATE-LEFT-32>
; 2C8:       970080D2         MOVZ NARGS, #4
; 2CC:       FA031BAA         MOV CFP, CSP
; 2D0:       DE9240F8         LDR LR, [LEXENV, #9]
; 2D4:       C0033FD6         BLR LR
; 2D8:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 2DC:       7A0300F9         STR CFP, [CSP]
; 2E0:       CB648DD2         MOVZ R1, #27430
; 2E4:       CBE1A6F2         MOVK R1, #14094, LSL #16
; 2E8:       FA031BAA         MOV CFP, CSP
; 2EC:       29B280D2         MOVZ TMP, #1425
; 2F0:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:TWO-ARG-*
; 2F4:       C0033FD6         BLR LR
; 2F8:       7A0300F9         STR CFP, [CSP]
; 2FC:       B6F8FF58         LDR LEXENV, #x70084BF210        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::U32>
; 300:       570080D2         MOVZ NARGS, #2
; 304:       FA031BAA         MOV CFP, CSP
; 308:       DE9240F8         LDR LR, [LEXENV, #9]
; 30C:       C0033FD6         BLR LR
; 310:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 314:       5F7D5FF2         TST R0, #18446744065119617025
; 318:       61040054         BNE L0
; 31C:       EB030AAA         MOV R1, R0
; 320:       7A0300F9         STR CFP, [CSP]
; 324:       4A0F40F9         LDR R0, [CFP, #24]
; 328:       D6F7FF58         LDR LEXENV, #x70084BF220        ; #<SB-KERNEL:FDEFN SB-KERNEL:TWO-ARG-XOR>
; 32C:       FA031BAA         MOV CFP, CSP
; 330:       DE9240F8         LDR LR, [LEXENV, #9]
; 334:       C0033FD6         BLR LR
; 338:       7A0300F9         STR CFP, [CSP]
; 33C:       4B0380D2         MOVZ R1, #26
; 340:       D6F6FF58         LDR LEXENV, #x70084BF218        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::ROTATE-LEFT-32>
; 344:       970080D2         MOVZ NARGS, #4
; 348:       FA031BAA         MOV CFP, CSP
; 34C:       DE9240F8         LDR LR, [LEXENV, #9]
; 350:       C0033FD6         BLR LR
; 354:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 358:       7A0300F9         STR CFP, [CSP]
; 35C:       4B0180D2         MOVZ R1, #10
; 360:       FA031BAA         MOV CFP, CSP
; 364:       29B280D2         MOVZ TMP, #1425
; 368:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:TWO-ARG-*
; 36C:       C0033FD6         BLR LR
; 370:       7A0300F9         STR CFP, [CSP]
; 374:       0BD99AD2         MOVZ R1, #54984
; 378:       0B95B9F2         MOVK R1, #52392, LSL #16
; 37C:       2B00C0F2         MOVK R1, #1, LSL #32
; 380:       FA031BAA         MOV CFP, CSP
; 384:       29AA80D2         MOVZ TMP, #1361
; 388:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:TWO-ARG-+
; 38C:       C0033FD6         BLR LR
; 390:       16F4FF58         LDR LEXENV, #x70084BF210        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::U32>
; 394:       570080D2         MOVZ NARGS, #2
; 398:       DE9240F8         LDR LR, [LEXENV, #9]
; 39C:       DE130091         ADD LR, LR, #4
; 3A0:       C0031FD6         BR LR
; 3A4: L0:   604D21D4         BRK #2667                       ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 3A8: L1:   604D21D4         BRK #2667                       ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 3AC:       E00120D4         BRK #15                         ; Invalid argument count trap
; disassembly for CNVRS/RUNTIME::MURMUR-FINISH
; Size: 432 bytes. Origin: #x70084BF45C                       ; CNVRS/RUNTIME::MURMUR-FINISH
; 45C:       AA0A40F9         LDR R0, [THREAD, #16]           ; binding-stack-pointer
; 460:       4A0F00F9         STR R0, [CFP, #24]
; 464:       7A0300F9         STR CFP, [CSP]
; 468:       4A1740F9         LDR R0, [CFP, #40]
; 46C:       0B0180D2         MOVZ R1, #8
; 470:       FA031BAA         MOV CFP, CSP
; 474:       29B280D2         MOVZ TMP, #1425
; 478:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:TWO-ARG-*
; 47C:       C0033FD6         BLR LR
; 480:       EB030AAA         MOV R1, R0
; 484:       7A0300F9         STR CFP, [CSP]
; 488:       4A1340F9         LDR R0, [CFP, #32]
; 48C:       B6FBFF58         LDR LEXENV, #x70084BF400        ; #<SB-KERNEL:FDEFN SB-KERNEL:TWO-ARG-XOR>
; 490:       FA031BAA         MOV CFP, CSP
; 494:       DE9240F8         LDR LR, [LEXENV, #9]
; 498:       C0033FD6         BLR LR
; 49C:       EC030AAA         MOV R2, R0
; 4A0:       ED030CAA         MOV R3, R2
; 4A4:       4D1B00F9         STR R3, [CFP, #48]
; 4A8:       EA030CAA         MOV R0, R2
; 4AC:       7A0300F9         STR CFP, [CSP]
; 4B0:       EB038092         MOVN R1, #31
; 4B4:       B6FAFF58         LDR LEXENV, #x70084BF408        ; #<SB-KERNEL:FDEFN ASH>
; 4B8:       970080D2         MOVZ NARGS, #4
; 4BC:       FA031BAA         MOV CFP, CSP
; 4C0:       DE9240F8         LDR LR, [LEXENV, #9]
; 4C4:       C0033FD6         BLR LR
; 4C8:       4D1B40F9         LDR R3, [CFP, #48]
; 4CC:       EB030AAA         MOV R1, R0
; 4D0:       7A0300F9         STR CFP, [CSP]
; 4D4:       EA030DAA         MOV R0, R3
; 4D8:       56F9FF58         LDR LEXENV, #x70084BF400        ; #<SB-KERNEL:FDEFN SB-KERNEL:TWO-ARG-XOR>
; 4DC:       FA031BAA         MOV CFP, CSP
; 4E0:       DE9240F8         LDR LR, [LEXENV, #9]
; 4E4:       C0033FD6         BLR LR
; 4E8:       EC030AAA         MOV R2, R0
; 4EC:       EA030CAA         MOV R0, R2
; 4F0:       7A0300F9         STR CFP, [CSP]
; 4F4:       CB9A92D2         MOVZ R1, #38102
; 4F8:       EB7AA1F2         MOVK R1, #3031, LSL #16
; 4FC:       2B00C0F2         MOVK R1, #1, LSL #32
; 500:       FA031BAA         MOV CFP, CSP
; 504:       29B280D2         MOVZ TMP, #1425
; 508:       BE6B69F8         LDR LR, [NULL, TMP]             ; SB-KERNEL:TWO-ARG-*
; 50C:       C0033FD6         BLR LR
; 510:       7A0300F9         STR CFP, [CSP]
; 514:       F6F7FF58         LDR LEXENV, #x70084BF410        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::U32>
; 518:       570080D2         MOVZ NARGS, #2
; 51C:       FA031BAA         MOV CFP, CSP
; 520:       DE9240F8         LDR LR, [LEXENV, #9]
; 524:       C0033FD6         BLR LR
; 528:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 52C:       5F7D5FF2         TST R0, #18446744065119617025
; 530:       21060054         BNE L4
; 534:       EC030AAA         MOV R2, R0
; 538:       E3030CAA         MOV NL3, R2
; 53C:       81FD4D93         ASR NL1, R2, #13
; 540:       22F87F92         AND NL2, NL1, #18446744073709551614
; 544:       6C0002CA         EOR R2, NL3, NL2
; 548:       81FD4193         ASR NL1, R2, #1
; 54C:       A9C695D2         MOVZ TMP, #44597
; 550:       4956B8F2         MOVK TMP, #49842, LSL #16
; 554:       227C099B         MUL NL2, NL1, TMP
; 558:       7A0300F9         STR CFP, [CSP]
; 55C:       5F0442F2         TST NL2, #13835058055282163712
; 560:       4AF87FD3         LSL R0, NL2, #1
; 564:       20020054         BEQ L2
; 568:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 56C:       A97A47A9         LDP TMP, LR, [THREAD, #112]     ; mixed-tlab.{free-pointer, end-addr}
; 570:       2A810091         ADD R0, TMP, #32
; 574:       5F011EEB         CMP R0, LR
; 578:       28040054         BHI L5
; 57C:       AA3A00F9         STR R0, [THREAD, #112]          ; mixed-tlab
; 580: L0:   2A3D0091         ADD R0, TMP, #15
; 584:       3E4280D2         MOVZ LR, #529
; 588:       4200F8B7         TBNZ NL2, #63, L1
; 58C:       3E2280D2         MOVZ LR, #273
; 590: L1:   3E0900A9         STP LR, NL2, [TMP]
; 594:       BF3A03D5         DMB ISHST
; 598:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 59C:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 5A0:       5E0000B4         CBZ LR, L2
; 5A4:       200120D4         BRK #9                          ; Pending interrupt trap
; 5A8: L2:   56F3FF58         LDR LEXENV, #x70084BF410        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::U32>
; 5AC:       570080D2         MOVZ NARGS, #2
; 5B0:       FA031BAA         MOV CFP, CSP
; 5B4:       DE9240F8         LDR LR, [LEXENV, #9]
; 5B8:       C0033FD6         BLR LR
; 5BC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 5C0:       5F7D5FF2         TST R0, #18446744065119617025
; 5C4:       61010054         BNE L3
; 5C8:       EC030AAA         MOV R2, R0
; 5CC:       E3030CAA         MOV NL3, R2
; 5D0:       81FD5093         ASR NL1, R2, #16
; 5D4:       22F87F92         AND NL2, NL1, #18446744073709551614
; 5D8:       6A0002CA         EOR R0, NL3, NL2
; 5DC:       B6F1FF58         LDR LEXENV, #x70084BF410        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::U32>
; 5E0:       570080D2         MOVZ NARGS, #2
; 5E4:       DE9240F8         LDR LR, [LEXENV, #9]
; 5E8:       DE130091         ADD LR, LR, #4
; 5EC:       C0031FD6         BR LR
; 5F0: L3:   604D21D4         BRK #2667                       ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 5F4: L4:   604D21D4         BRK #2667                       ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 5F8:       E00120D4         BRK #15                         ; Invalid argument count trap
; 5FC: L5:   090480D2         MOVZ TMP, #32
; 600:       4AF1FF58         LDR R0, #x70084BF428            ; SB-VM::ALLOC-TRAMP
; 604:       40013FD6         BLR R0
; 608:       DEFFFF17         B L0
