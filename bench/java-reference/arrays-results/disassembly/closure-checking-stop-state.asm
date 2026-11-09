; disassembly for CNVRS/RUNTIME::CLOSURE-CHECKING-STOP-STATE
; Size: 1328 bytes. Origin: #x700AB0422C                      ; CNVRS/RUNTIME::CLOSURE-CHECKING-STOP-STATE
; 22C:       00D240F8         LDR NL0, [R6, #13]
; 230:       4BF7FF58         LDR R1, #x700AB04118            ; 'CNVRS/RUNTIME::*SIMULATOR*
; 234:       61515FB8         LDR WNL1, [R1, #-11]
; 238:       AA6A61F8         LDR R0, [THREAD, NL1]
; 23C:       5F0500B1         CMN R0, #1
; 240:       41000054         BNE L0
; 244:       6A1140F8         LDR R0, [R1, #1]
; 248: L0:   5F2500F1         CMP R0, #9
; 24C:       80270054         BEQ L23
; 250:       5F011DEB         CMP R0, NULL
; 254:       E0260054         BEQ L22
; 258:       4AD140F8         LDR R0, [R0, #13]
; 25C:       4AD140F8         LDR R0, [R0, #13]
; 260:       41915FF8         LDR NL1, [R0, #-7]
; 264:       3F0000EB         CMP NL1, NL0
; 268:       C9260054         BLS L24
; 26C:       4909008B         ADD TMP, R0, NL0, LSL #2
; 270:       2A1140F8         LDR R0, [TMP, #1]
; 274:       410D4092         AND NL1, R0, #15
; 278:       3F0C00F1         CMP NL1, #3
; 27C:       61250054         BNE L21
; 280:       4E5140F8         LDR R4, [R0, #5]
; 284:       C25145B8         LDR WNL2, [R4, #85]
; 288:       C1F6FF18         LDR WNL1, #x700AB04160
; 28C:       5F00016B         CMP WNL2, WNL1
; 290:       C1240054         BNE L21
; 294:       4A5141F8         LDR R0, [R0, #21]
; 298:       4BF4FF58         LDR R1, #x700AB04120            ; :RULE-STOP
; 29C:       5F010BEB         CMP R0, R1
; 2A0:       A1030054         BNE L3
; 2A4:       0AD241F8         LDR R0, [R6, #29]
; 2A8:       0CF4FF58         LDR R2, #x700AB04128            ; 'CNVRS/RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; 2AC:       81515FB8         LDR WNL1, [R2, #-11]
; 2B0:       AB6A61F8         LDR R1, [THREAD, NL1]
; 2B4:       7F0500B1         CMN R1, #1
; 2B8:       41000054         BNE L1
; 2BC:       8B1140F8         LDR R1, [R2, #1]
; 2C0: L1:   7F2500F1         CMP R1, #9
; 2C4:       20240054         BEQ L25
; 2C8:       5F010BEB         CMP R0, R1
; 2CC:       C1030054         BNE L4
; 2D0:       4A1B40F9         LDR R0, [CFP, #48]
; 2D4:       5F011DEB         CMP R0, NULL
; 2D8:       E0010054         BEQ L3
; 2DC:       7A0300F9         STR CFP, [CSP]
; 2E0:       4A0F40F9         LDR R0, [CFP, #24]
; 2E4:       EB0310AA         MOV R1, R6
; 2E8:       56F0FF58         LDR LEXENV, #x700AB040F0        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONFIG-SET-ADD>
; 2EC:       970080D2         MOVZ NARGS, #4
; 2F0:       FA031BAA         MOV CFP, CSP
; 2F4:       DE9240F8         LDR LR, [LEXENV, #9]
; 2F8:       C0033FD6         BLR LR
; 2FC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 300:       EA031DAA         MOV R0, NULL
; 304: L2:   FB031AAA         MOV CSP, CFP
; 308:       5A7B40A9         LDP CFP, LR, [CFP]
; 30C:       BF0300F1         CMP NULL, #0
; 310:       C0035FD6         RET
; 314: L3:   EA0310AA         MOV R0, R6
; 318:       4BB341A9         LDP R1, R2, [CFP, #24]
; 31C:       4D1740F9         LDR R3, [CFP, #40]
; 320:       4E0343A9         LDP R4, NL0, [CFP, #48]
; 324:       4E0302A9         STP R4, NL0, [CFP, #32]
; 328:       4E2340F9         LDR R4, [CFP, #64]
; 32C:       4E1B00F9         STR R4, [CFP, #48]
; 330:       56EEFF58         LDR LEXENV, #x700AB040F8        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CLOSURE-WORK>
; 334:       D70180D2         MOVZ NARGS, #14
; 338:       DE9240F8         LDR LR, [LEXENV, #9]
; 33C:       DE130091         ADD LR, LR, #4
; 340:       C0031FD6         BR LR
; 344: L4:   490D4092         AND TMP, R0, #15
; 348:       3F0D00F1         CMP TMP, #3
; 34C:       41120054         BNE L14
; 350:       4B5140F8         LDR R1, [R0, #5]
; 354:       629145B8         LDR WNL2, [R1, #89]
; 358:       61F0FF18         LDR WNL1, #x700AB04164
; 35C:       5F00016B         CMP WNL2, WNL1
; 360:       E0110054         BEQ L15
; 364:       629145B8         LDR WNL2, [R1, #89]
; 368:       01F0FF18         LDR WNL1, #x700AB04168
; 36C:       5F00016B         CMP WNL2, WNL1
; 370:       21110054         BNE L14
; 374:       4B5141F8         LDR R1, [R0, #21]
; 378:       4AD141F8         LDR R0, [R0, #29]
; 37C:       4A2B00F9         STR R0, [CFP, #80]
; 380:       4B2700F9         STR R1, [CFP, #72]
; 384:       60915FF8         LDR NL0, [R1, #-7]
; 388:       403300F9         STR NL0, [CFP, #96]
; 38C:       5F2F00F9         STR ZR, [CFP, #88]
; 390:       2B000014         B L7
; 394: L5:   4A2740F9         LDR R0, [CFP, #72]
; 398:       402F40F9         LDR NL0, [CFP, #88]
; 39C:       4905008B         ADD TMP, R0, NL0, LSL #1
; 3A0:       201140B8         LDR WNL0, [TMP, #1]
; 3A4:       00F87FD3         LSL NL0, NL0, #1
; 3A8:       4A2B40F9         LDR R0, [CFP, #80]
; 3AC:       41915FF8         LDR NL1, [R0, #-7]
; 3B0:       4A2B40F9         LDR R0, [CFP, #80]
; 3B4:       422F40F9         LDR NL2, [CFP, #88]
; 3B8:       3F0002EB         CMP NL1, NL2
; 3BC:       891C0054         BLS L26
; 3C0:       4A2B40F9         LDR R0, [CFP, #80]
; 3C4:       412F40F9         LDR NL1, [CFP, #88]
; 3C8:       4909018B         ADD TMP, R0, NL1, LSL #2
; 3CC:       2D1140F8         LDR R3, [TMP, #1]
; 3D0:       EB0300AA         MOV R1, NL0
; 3D4:       E97B7FB2         MOV TMP, #4294967294
; 3D8:       1F0009EB         CMP NL0, TMP
; 3DC:       81070054         BNE L11
; 3E0:       4A1B40F9         LDR R0, [CFP, #48]
; 3E4:       5F011DEB         CMP R0, NULL
; 3E8:       61030054         BNE L9
; 3EC:       503700F9         STR R6, [CFP, #104]
; 3F0:       E0031BAA         MOV NL0, CSP
; 3F4:       7A8703F8         STR CFP, [CSP], #56
; 3F8:       EA0310AA         MOV R0, R6
; 3FC:       4BB341A9         LDP R1, R2, [CFP, #24]
; 400:       4D1740F9         LDR R3, [CFP, #40]
; 404:       411F40F9         LDR NL1, [CFP, #56]
; 408:       1D0402A9         STP NULL, NL1, [NL0, #32]
; 40C:       4E2340F9         LDR R4, [CFP, #64]
; 410:       0E1800F9         STR R4, [NL0, #48]
; 414:       36E7FF58         LDR LEXENV, #x700AB040F8        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CLOSURE-WORK>
; 418:       D70180D2         MOVZ NARGS, #14
; 41C:       FA0300AA         MOV CFP, NL0
; 420:       DE9240F8         LDR LR, [LEXENV, #9]
; 424:       C0033FD6         BLR LR
; 428:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 42C:       503740F9         LDR R6, [CFP, #104]
; 430: L6:   402F40F9         LDR NL0, [CFP, #88]
; 434:       00080091         ADD NL0, NL0, #2
; 438:       402F00F9         STR NL0, [CFP, #88]
; 43C: L7:   402F40F9         LDR NL0, [CFP, #88]
; 440:       413340F9         LDR NL1, [CFP, #96]
; 444:       1F0001EB         CMP NL0, NL1
; 448:       6BFAFF54         BLT L5
; 44C: L8:   EA031DAA         MOV R0, NULL
; 450:       ADFFFF17         B L2
; 454: L9:   0BD240F8         LDR R1, [R6, #13]
; 458:       8AE6FF58         LDR R0, #x700AB04128            ; 'CNVRS/RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; 45C:       41515FB8         LDR WNL1, [R0, #-11]
; 460:       AD6A61F8         LDR R3, [THREAD, NL1]
; 464:       BF0500B1         CMN R3, #1
; 468:       41000054         BNE L10
; 46C:       4D1140F8         LDR R3, [R0, #1]
; 470: L10:  BF2500F1         CMP R3, #9
; 474:       00170054         BEQ L27
; 478:       503700F9         STR R6, [CFP, #104]
; 47C:       7A0300F9         STR CFP, [CSP]
; 480:       EA0310AA         MOV R0, R6
; 484:       6CE5FF58         LDR R2, #x700AB04130            ; :CONTEXT
; 488:       D6E3FF58         LDR LEXENV, #x700AB04100        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 48C:       170180D2         MOVZ NARGS, #8
; 490:       FA031BAA         MOV CFP, CSP
; 494:       DE9240F8         LDR LR, [LEXENV, #9]
; 498:       C0033FD6         BLR LR
; 49C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 4A0:       EB030AAA         MOV R1, R0
; 4A4:       7A0300F9         STR CFP, [CSP]
; 4A8:       4A0F40F9         LDR R0, [CFP, #24]
; 4AC:       36E2FF58         LDR LEXENV, #x700AB040F0        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONFIG-SET-ADD>
; 4B0:       970080D2         MOVZ NARGS, #4
; 4B4:       FA031BAA         MOV CFP, CSP
; 4B8:       DE9240F8         LDR LR, [LEXENV, #9]
; 4BC:       C0033FD6         BLR LR
; 4C0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 4C4:       503740F9         LDR R6, [CFP, #104]
; 4C8:       DAFFFF17         B L6
; 4CC: L11:  503700F9         STR R6, [CFP, #104]
; 4D0:       7A0300F9         STR CFP, [CSP]
; 4D4:       EA0310AA         MOV R0, R6
; 4D8:       CCE2FF58         LDR R2, #x700AB04130            ; :CONTEXT
; 4DC:       36E1FF58         LDR LEXENV, #x700AB04100        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 4E0:       170180D2         MOVZ NARGS, #8
; 4E4:       FA031BAA         MOV CFP, CSP
; 4E8:       DE9240F8         LDR LR, [LEXENV, #9]
; 4EC:       C0033FD6         BLR LR
; 4F0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 4F4:       503740F9         LDR R6, [CFP, #104]
; 4F8:       401F40F9         LDR NL0, [CFP, #56]
; 4FC:       00FC4193         ASR NL0, NL0, #1
; 500:       000400D1         SUB NL0, NL0, #1
; 504:       410D4092         AND NL1, R0, #15
; 508:       3F0C00F1         CMP NL1, #3
; 50C:       01040054         BNE L13
; 510:       4E5140F8         LDR R4, [R0, #5]
; 514:       C25145B8         LDR WNL2, [R4, #85]
; 518:       01E2FF18         LDR WNL1, #x700AB04158
; 51C:       5F00016B         CMP WNL2, WNL1
; 520:       61030054         BNE L13
; 524:       1F0000AB         CMN NL0, NL0
; 528:       06030054         BVS L12
; 52C:       503700F9         STR R6, [CFP, #104]
; 530:       02F87FD3         LSL NL2, NL0, #1
; 534:       E0031BAA         MOV NL0, CSP
; 538:       7A0707F8         STR CFP, [CSP], #112
; 53C:       E10300D1         SUB NL1, NSP, #0
; 540:       3F000091         MOV NSP, NL1
; 544:       F0030AAA         MOV R6, R0
; 548:       4A0F40F9         LDR R0, [CFP, #24]
; 54C:       0A0C00F9         STR R0, [NL0, #24]
; 550:       4A1340F9         LDR R0, [CFP, #32]
; 554:       0A1000F9         STR R0, [NL0, #32]
; 558:       4A1740F9         LDR R0, [CFP, #40]
; 55C:       0A1400F9         STR R0, [NL0, #40]
; 560:       4A1B40F9         LDR R0, [CFP, #48]
; 564:       0A1800F9         STR R0, [NL0, #48]
; 568:       021C00F9         STR NL2, [NL0, #56]
; 56C:       4A2340F9         LDR R0, [CFP, #64]
; 570:       0A2000F9         STR R0, [NL0, #64]
; 574:       FA0300AA         MOV CFP, NL0
; 578:       2CFFFF97         BL #x700AB04228
; 57C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 580:       503740F9         LDR R6, [CFP, #104]
; 584:       ABFFFF17         B L6
; 588: L12:  A00A28D4         BRK #16469                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 58C: L13:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 590:       33               BYTE #X33                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-CONFIG {700AA4E5D3}>
; 591:       .ALIGN           4
; 594: L14:  A04321D4         BRK #2589                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; 598:       47               BYTE #X47                       ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 599:       .ALIGN           4
; 59C: L15:  40D141F8         LDR NL0, [R0, #29]
; 5A0:       4D5141F8         LDR R3, [R0, #21]
; 5A4:       EB0300AA         MOV R1, NL0
; 5A8:       E97B7FB2         MOV TMP, #4294967294
; 5AC:       1F0009EB         CMP NL0, TMP
; 5B0:       E0050054         BEQ L18
; 5B4:       7A0300F9         STR CFP, [CSP]
; 5B8:       EA0310AA         MOV R0, R6
; 5BC:       ACDBFF58         LDR R2, #x700AB04130            ; :CONTEXT
; 5C0:       16DAFF58         LDR LEXENV, #x700AB04100        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 5C4:       170180D2         MOVZ NARGS, #8
; 5C8:       FA031BAA         MOV CFP, CSP
; 5CC:       DE9240F8         LDR LR, [LEXENV, #9]
; 5D0:       C0033FD6         BLR LR
; 5D4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 5D8:       401F40F9         LDR NL0, [CFP, #56]
; 5DC:       00FC4193         ASR NL0, NL0, #1
; 5E0:       000400D1         SUB NL0, NL0, #1
; 5E4:       410D4092         AND NL1, R0, #15
; 5E8:       3F0C00F1         CMP NL1, #3
; 5EC:       C1030054         BNE L17
; 5F0:       4E5140F8         LDR R4, [R0, #5]
; 5F4:       C25145B8         LDR WNL2, [R4, #85]
; 5F8:       01DBFF18         LDR WNL1, #x700AB04158
; 5FC:       5F00016B         CMP WNL2, WNL1
; 600:       21030054         BNE L17
; 604:       1F0000AB         CMN NL0, NL0
; 608:       C6020054         BVS L16
; 60C:       02F87FD3         LSL NL2, NL0, #1
; 610:       E0031BAA         MOV NL0, CSP
; 614:       7A0707F8         STR CFP, [CSP], #112
; 618:       E10300D1         SUB NL1, NSP, #0
; 61C:       3F000091         MOV NSP, NL1
; 620:       F0030AAA         MOV R6, R0
; 624:       4A0F40F9         LDR R0, [CFP, #24]
; 628:       0A0C00F9         STR R0, [NL0, #24]
; 62C:       4A1340F9         LDR R0, [CFP, #32]
; 630:       0A1000F9         STR R0, [NL0, #32]
; 634:       4A1740F9         LDR R0, [CFP, #40]
; 638:       0A1400F9         STR R0, [NL0, #40]
; 63C:       4A1B40F9         LDR R0, [CFP, #48]
; 640:       0A1800F9         STR R0, [NL0, #48]
; 644:       021C00F9         STR NL2, [NL0, #56]
; 648:       4A2340F9         LDR R0, [CFP, #64]
; 64C:       0A2000F9         STR R0, [NL0, #64]
; 650:       FA0300AA         MOV CFP, NL0
; 654:       F5FEFF97         BL #x700AB04228
; 658:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 65C:       7CFFFF17         B L8
; 660: L16:  A00A28D4         BRK #16469                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 664: L17:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 668:       33               BYTE #X33                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-CONFIG {700AA4E5D3}>
; 669:       .ALIGN           4
; 66C: L18:  4A1B40F9         LDR R0, [CFP, #48]
; 670:       5F011DEB         CMP R0, NULL
; 674:       21020054         BNE L19
; 678:       E0031BAA         MOV NL0, CSP
; 67C:       7A8703F8         STR CFP, [CSP], #56
; 680:       EA0310AA         MOV R0, R6
; 684:       4BB341A9         LDP R1, R2, [CFP, #24]
; 688:       4D1740F9         LDR R3, [CFP, #40]
; 68C:       411F40F9         LDR NL1, [CFP, #56]
; 690:       1D0402A9         STP NULL, NL1, [NL0, #32]
; 694:       4E2340F9         LDR R4, [CFP, #64]
; 698:       0E1800F9         STR R4, [NL0, #48]
; 69C:       F6D2FF58         LDR LEXENV, #x700AB040F8        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CLOSURE-WORK>
; 6A0:       D70180D2         MOVZ NARGS, #14
; 6A4:       FA0300AA         MOV CFP, NL0
; 6A8:       DE9240F8         LDR LR, [LEXENV, #9]
; 6AC:       C0033FD6         BLR LR
; 6B0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 6B4:       66FFFF17         B L8
; 6B8: L19:  0BD240F8         LDR R1, [R6, #13]
; 6BC:       6AD3FF58         LDR R0, #x700AB04128            ; 'CNVRS/RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; 6C0:       41515FB8         LDR WNL1, [R0, #-11]
; 6C4:       AD6A61F8         LDR R3, [THREAD, NL1]
; 6C8:       BF0500B1         CMN R3, #1
; 6CC:       41000054         BNE L20
; 6D0:       4D1140F8         LDR R3, [R0, #1]
; 6D4: L20:  BF2500F1         CMP R3, #9
; 6D8:       00040054         BEQ L28
; 6DC:       7A0300F9         STR CFP, [CSP]
; 6E0:       EA0310AA         MOV R0, R6
; 6E4:       6CD2FF58         LDR R2, #x700AB04130            ; :CONTEXT
; 6E8:       D6D0FF58         LDR LEXENV, #x700AB04100        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 6EC:       170180D2         MOVZ NARGS, #8
; 6F0:       FA031BAA         MOV CFP, CSP
; 6F4:       DE9240F8         LDR LR, [LEXENV, #9]
; 6F8:       C0033FD6         BLR LR
; 6FC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 700:       EB030AAA         MOV R1, R0
; 704:       7A0300F9         STR CFP, [CSP]
; 708:       4A0F40F9         LDR R0, [CFP, #24]
; 70C:       36CFFF58         LDR LEXENV, #x700AB040F0        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONFIG-SET-ADD>
; 710:       970080D2         MOVZ NARGS, #4
; 714:       FA031BAA         MOV CFP, CSP
; 718:       DE9240F8         LDR LR, [LEXENV, #9]
; 71C:       C0033FD6         BLR LR
; 720:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 724:       4AFFFF17         B L8
; 728: L21:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 72C:       4B               BYTE #X4B                       ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/RUNTIME:ATN-STATE {700AA28883}>
; 72D:       .ALIGN           4
; 730: L22:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 734:       4F               BYTE #X4F                       ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {700AADA7F3}>
; 735:       .ALIGN           4
; 738:       E00120D4         BRK #15                         ; Invalid argument count trap
; 73C: L23:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 740: L24:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 744:       01               BYTE #X01                       ; NL0
; 745:       .ALIGN           4
; 748: L25:  E08221D4         BRK #3095                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; 74C: L26:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 750:       09               BYTE #X09                       ; NL2
; 751:       .ALIGN           4
; 754: L27:  E04221D4         BRK #2583                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R0
; 758: L28:  E04221D4         BRK #2583                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R0
