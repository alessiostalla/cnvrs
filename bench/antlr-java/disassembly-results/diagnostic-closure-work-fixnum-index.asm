; disassembly for DIAGNOSTIC-CLOSURE-WORK-FIXNUM-INDEX
; Size: 1884 bytes. Origin: #x70055B1268                      ; DIAGNOSTIC-CLOSURE-WORK-FIXNUM-INDEX
; 268:       4A0F40F9         LDR R0, [CFP, #24]
; 26C:       40D140F8         LDR NL0, [R0, #13]
; 270:       4BF5FF58         LDR R1, #x70055B1118            ; '*SIMULATOR*
; 274:       61515FB8         LDR WNL1, [R1, #-11]
; 278:       AA6A61F8         LDR R0, [THREAD, NL1]
; 27C:       5F0500B1         CMN R0, #1
; 280:       41000054         BNE L0
; 284:       6A1140F8         LDR R0, [R1, #1]
; 288: L0:   5F2500F1         CMP R0, #9
; 28C:       C0370054         BEQ L49
; 290:       5F011DEB         CMP R0, NULL
; 294:       20370054         BEQ L48
; 298:       4AD140F8         LDR R0, [R0, #13]
; 29C:       4AD140F8         LDR R0, [R0, #13]
; 2A0:       41915FF8         LDR NL1, [R0, #-7]
; 2A4:       3F0000EB         CMP NL1, NL0
; 2A8:       09370054         BLS L50
; 2AC:       4909008B         ADD TMP, R0, NL0, LSL #2
; 2B0:       2A1140F8         LDR R0, [TMP, #1]
; 2B4:       4A2700F9         STR R0, [CFP, #72]
; 2B8:       410D4092         AND NL1, R0, #15
; 2BC:       3F0C00F1         CMP NL1, #3
; 2C0:       81350054         BNE L47
; 2C4:       4E5140F8         LDR R4, [R0, #5]
; 2C8:       C25145B8         LDR WNL2, [R4, #85]
; 2CC:       61F6FF18         LDR WNL1, #x70055B1198
; 2D0:       5F00016B         CMP WNL2, WNL1
; 2D4:       E1340054         BNE L47
; 2D8:       4B5142F8         LDR R1, [R0, #37]
; 2DC:       7F011DEB         CMP R1, NULL
; 2E0:       A12F0054         BNE L40
; 2E4: L1:   7A0300F9         STR CFP, [CSP]
; 2E8:       4BAB41A9         LDP R1, R0, [CFP, #24]
; 2EC:       B6EFFF58         LDR LEXENV, #x70055B10E0        ; #<SB-KERNEL:FDEFN CONFIG-SET-ADD>
; 2F0:       970080D2         MOVZ NARGS, #4
; 2F4:       580B00F9         STR NFP, [CFP, #16]
; 2F8:       FA031BAA         MOV CFP, CSP
; 2FC:       DE9240F8         LDR LR, [LEXENV, #9]
; 300:       C0033FD6         BLR LR
; 304:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 308:       580B40F9         LDR NFP, [CFP, #16]
; 30C: L2:   4A2740F9         LDR R0, [CFP, #72]
; 310:       4A5142F8         LDR R0, [R0, #37]
; 314:       4A7F05A9         STP R0, ZR, [CFP, #80]
; 318:       4A2B40F9         LDR R0, [CFP, #80]
; 31C:       5F011DEB         CMP R0, NULL
; 320:       E1000054         BNE L4
; 324: L3:   EA031DAA         MOV R0, NULL
; 328:       1F430091         ADD NSP, NFP, #16
; 32C:       FB031AAA         MOV CSP, CFP
; 330:       5A7B40A9         LDP CFP, LR, [CFP]
; 334:       BF0300F1         CMP NULL, #0
; 338:       C0035FD6         RET
; 33C: L4:   4A2B40F9         LDR R0, [CFP, #80]
; 340:       4A915FF8         LDR R0, [R0, #-7]
; 344:       EF030AAA         MOV R5, R0
; 348:       4A2B40F9         LDR R0, [CFP, #80]
; 34C:       4A1140F8         LDR R0, [R0, #1]
; 350:       4A2B00F9         STR R0, [CFP, #80]
; 354:       53000014         B L11
; 358: L5:   4A1B40F9         LDR R0, [CFP, #48]
; 35C:       5F011DEB         CMP R0, NULL
; 360:       A1290054         BNE L38
; 364: L6:   EA031DAA         MOV R0, NULL
; 368: L7:   4F3B00F9         STR R5, [CFP, #112]
; 36C:       4A3300F9         STR R0, [CFP, #96]
; 370:       EB030FAA         MOV R1, R5
; 374:       000340F9         LDR NL0, [NFP]
; 378:       1F0000F1         CMP NL0, #0
; 37C:       AAE30091         ADD R0, NULL, #56               ; T
; 380:       4D019D9A         CSEL R3, R0, NULL, EQ
; 384:       E0031BAA         MOV NL0, CSP
; 388:       7A0703F8         STR CFP, [CSP], #48
; 38C:       4A0F40F9         LDR R0, [CFP, #24]
; 390:       4C3340F9         LDR R2, [CFP, #96]
; 394:       4E1F40F9         LDR R4, [CFP, #56]
; 398:       0E1000F9         STR R4, [NL0, #32]
; 39C:       4E2340F9         LDR R4, [CFP, #64]
; 3A0:       0E1400F9         STR R4, [NL0, #40]
; 3A4:       36EAFF58         LDR LEXENV, #x70055B10E8        ; #<SB-KERNEL:FDEFN GET-EPSILON-TARGET>
; 3A8:       970180D2         MOVZ NARGS, #12
; 3AC:       580B00F9         STR NFP, [CFP, #16]
; 3B0:       FA0300AA         MOV CFP, NL0
; 3B4:       DE9240F8         LDR LR, [LEXENV, #9]
; 3B8:       C0033FD6         BLR LR
; 3BC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 3C0:       580B40F9         LDR NFP, [CFP, #16]
; 3C4:       4F3B40F9         LDR R5, [CFP, #112]
; 3C8:       EC030AAA         MOV R2, R0
; 3CC:       030340F9         LDR NL3, [NFP]
; 3D0:       9F011DEB         CMP R2, NULL
; 3D4:       A0030054         BEQ L10
; 3D8:       4A2740F9         LDR R0, [CFP, #72]
; 3DC:       4A5141F8         LDR R0, [R0, #21]
; 3E0:       0BEAFF58         LDR R1, #x70055B1120            ; :RULE-STOP
; 3E4:       5F010BEB         CMP R0, R1
; 3E8:       E0100054         BEQ L20
; 3EC:       E10D4092         AND NL1, R5, #15
; 3F0:       3F0C00F1         CMP NL1, #3
; 3F4:       41100054         BNE L19
; 3F8:       EE5140F8         LDR R4, [R5, #5]
; 3FC:       C25145B8         LDR WNL2, [R4, #85]
; 400:       E1ECFF18         LDR WNL1, #x70055B119C
; 404:       5F00016B         CMP WNL2, WNL1
; 408:       A10F0054         BNE L19
; 40C:       EAD140F8         LDR R0, [R5, #13]
; 410:       CBE8FF58         LDR R1, #x70055B1128            ; :EPSILON
; 414:       5F010BEB         CMP R0, R1
; 418:       80000054         BEQ L8
; 41C:       ABE8FF58         LDR R1, #x70055B1130            ; :RULE
; 420:       5F010BEB         CMP R0, R1
; 424:       210B0054         BNE L18
; 428: L8:   EAD140F8         LDR R0, [R5, #13]
; 42C:       2BE8FF58         LDR R1, #x70055B1130            ; :RULE
; 430:       5F010BEB         CMP R0, R1
; 434:       61000054         BNE L9
; 438:       000340F9         LDR NL0, [NFP]
; 43C:       E009F8B6         TBZ NL0, #63, L17
; 440: L9:   9F011DEB         CMP R2, NULL
; 444:       61050054         BNE L14
; 448: L10:  4A2B40F9         LDR R0, [CFP, #80]
; 44C:       410D4092         AND NL1, R0, #15
; 450:       3F1C00F1         CMP NL1, #7
; 454:       A1040054         BNE L13
; 458:       4A2B40F9         LDR R0, [CFP, #80]
; 45C:       5F011DEB         CMP R0, NULL
; 460:       20F6FF54         BEQ L3
; 464:       4A2B40F9         LDR R0, [CFP, #80]
; 468:       4A915FF8         LDR R0, [R0, #-7]
; 46C:       EF030AAA         MOV R5, R0
; 470:       4A2B40F9         LDR R0, [CFP, #80]
; 474:       4A1140F8         LDR R0, [R0, #1]
; 478:       4A2B00F9         STR R0, [CFP, #80]
; 47C:       402F40F9         LDR NL0, [CFP, #88]
; 480:       00FC4193         ASR NL0, NL0, #1
; 484:       01040091         ADD NL1, NL0, #1
; 488:       E00301AA         MOV NL0, NL1
; 48C:       E10300AA         MOV NL1, NL0
; 490:       3F0442F2         TST NL1, #13835058055282163712
; 494:       81020054         BNE L12
; 498:       00F87FD3         LSL NL0, NL0, #1
; 49C:       402F00F9         STR NL0, [CFP, #88]
; 4A0: L11:  402F40F9         LDR NL0, [CFP, #88]
; 4A4:       A0F5FFB5         CBNZ NL0, L5
; 4A8:       4F3B00F9         STR R5, [CFP, #112]
; 4AC:       7A0300F9         STR CFP, [CSP]
; 4B0:       4A0F40F9         LDR R0, [CFP, #24]
; 4B4:       F6E1FF58         LDR LEXENV, #x70055B10F0        ; #<SB-KERNEL:FDEFN CAN-DROP-LOOP-ENTRY-EDGE-IN-LEFT-RECURSIVE-RULE>
; 4B8:       570080D2         MOVZ NARGS, #2
; 4BC:       580B00F9         STR NFP, [CFP, #16]
; 4C0:       FA031BAA         MOV CFP, CSP
; 4C4:       DE9240F8         LDR LR, [LEXENV, #9]
; 4C8:       C0033FD6         BLR LR
; 4CC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 4D0:       580B40F9         LDR NFP, [CFP, #16]
; 4D4:       4F3B40F9         LDR R5, [CFP, #112]
; 4D8:       5F011DEB         CMP R0, NULL
; 4DC:       E0F3FF54         BEQ L5
; 4E0:       DAFFFF17         B L10
; 4E4: L12:  A00A28D4         BRK #16469                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 4E8: L13:  4A2B40F9         LDR R0, [CFP, #80]
; 4EC:       E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 4F0: L14:  EA030CAA         MOV R0, R2
; 4F4:       6E0003AB         ADDS R4, NL3, NL3
; 4F8:       E7010054         BVC L16
; 4FC:       BD2A00B9         STR WNULL, [THREAD, #40]        ; pseudo-atomic-bits
; 500:       A97A47A9         LDP TMP, LR, [THREAD, #112]     ; mixed-tlab.{free-pointer, end-addr}
; 504:       2E410091         ADD R4, TMP, #16
; 508:       DF011EEB         CMP R4, LR
; 50C:       28240054         BHI L51
; 510:       AE3A00F9         STR R4, [THREAD, #112]          ; mixed-tlab
; 514: L15:  2E3D0091         ADD R4, TMP, #15
; 518:       3E2280D2         MOVZ LR, #273
; 51C:       3E0D00A9         STP LR, NL3, [TMP]
; 520:       BF3A03D5         DMB ISHST
; 524:       BF2A00B9         STR WZR, [THREAD, #40]          ; pseudo-atomic-bits
; 528:       BE2E40B9         LDR WLR, [THREAD, #44]          ; pseudo-atomic-bits
; 52C:       5E0000B4         CBZ LR, L16
; 530:       200120D4         BRK #9                          ; Pending interrupt trap
; 534: L16:  E0031BAA         MOV NL0, CSP
; 538:       7A8703F8         STR CFP, [CSP], #56
; 53C:       4B3342A9         LDP R1, R2, [CFP, #32]
; 540:       4D3340F9         LDR R3, [CFP, #96]
; 544:       4F1F40F9         LDR R5, [CFP, #56]
; 548:       0F3802A9         STP R5, R4, [NL0, #32]
; 54C:       4E2340F9         LDR R4, [CFP, #64]
; 550:       0E1800F9         STR R4, [NL0, #48]
; 554:       36DDFF58         LDR LEXENV, #x70055B10F8        ; #<SB-KERNEL:FDEFN CLOSURE-CHECKING-STOP-STATE>
; 558:       D70180D2         MOVZ NARGS, #14
; 55C:       580B00F9         STR NFP, [CFP, #16]
; 560:       FA0300AA         MOV CFP, NL0
; 564:       DE9240F8         LDR LR, [LEXENV, #9]
; 568:       C0033FD6         BLR LR
; 56C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 570:       580B40F9         LDR NFP, [CFP, #16]
; 574:       B5FFFF17         B L10
; 578: L17:  000340F9         LDR NL0, [NFP]
; 57C:       00040091         ADD NL0, NL0, #1
; 580:       E30300AA         MOV NL3, NL0
; 584:       AFFFFF17         B L9
; 588: L18:  8BDDFF58         LDR R1, #x70055B1138            ; :PREDICATE
; 58C:       5F010BEB         CMP R0, R1
; 590:       C0F4FF54         BEQ L8
; 594:       6BDDFF58         LDR R1, #x70055B1140            ; :ACTION
; 598:       5F010BEB         CMP R0, R1
; 59C:       60F4FF54         BEQ L8
; 5A0:       4BDDFF58         LDR R1, #x70055B1148            ; :PRECEDENCE
; 5A4:       5F010BEB         CMP R0, R1
; 5A8:       00F4FF54         BEQ L8
; 5AC:       4C3700F9         STR R2, [CFP, #104]
; 5B0:       030700F9         STR NL3, [NFP, #8]
; 5B4:       4F3B00F9         STR R5, [CFP, #112]
; 5B8:       EB030CAA         MOV R1, R2
; 5BC:       7A0300F9         STR CFP, [CSP]
; 5C0:       4A1740F9         LDR R0, [CFP, #40]
; 5C4:       F6D9FF58         LDR LEXENV, #x70055B1100        ; #<SB-KERNEL:FDEFN BUSY-ADD>
; 5C8:       970080D2         MOVZ NARGS, #4
; 5CC:       580B00F9         STR NFP, [CFP, #16]
; 5D0:       FA031BAA         MOV CFP, CSP
; 5D4:       DE9240F8         LDR LR, [LEXENV, #9]
; 5D8:       C0033FD6         BLR LR
; 5DC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 5E0:       580B40F9         LDR NFP, [CFP, #16]
; 5E4:       4F3B40F9         LDR R5, [CFP, #112]
; 5E8:       030740F9         LDR NL3, [NFP, #8]
; 5EC:       4C3740F9         LDR R2, [CFP, #104]
; 5F0:       5F011DEB         CMP R0, NULL
; 5F4:       AC038C9A         CSEL R2, NULL, R2, EQ
; 5F8:       8CFFFF17         B L8
; 5FC: L19:  60E321D4         BRK #3867                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; 600:       5B               BYTE #X5B                       ; #<SB-KERNEL:LAYOUT (ID=394) for ATN-TRANSITION {700CD64783}>
; 601:       .ALIGN           4
; 604: L20:  ABDAFF58         LDR R1, #x70055B1158            ; '*CURRENT-DFA*
; 608:       61515FB8         LDR WNL1, [R1, #-11]
; 60C:       AA6A61F8         LDR R0, [THREAD, NL1]
; 610:       5F0500B1         CMN R0, #1
; 614:       41000054         BNE L21
; 618:       6A1140F8         LDR R0, [R1, #1]
; 61C: L21:  5F2500F1         CMP R0, #9
; 620:       001C0054         BEQ L52
; 624:       5F011DEB         CMP R0, NULL
; 628:       21050054         BNE L25
; 62C: L22:  810D4092         AND NL1, R2, #15
; 630:       3F0C00F1         CMP NL1, #3
; 634:       81040054         BNE L24
; 638:       8E5140F8         LDR R4, [R2, #5]
; 63C:       C25145B8         LDR WNL2, [R4, #85]
; 640:       81DAFF18         LDR WNL1, #x70055B1190
; 644:       5F00016B         CMP WNL2, WNL1
; 648:       E1030054         BNE L24
; 64C:       80D142F8         LDR NL0, [R2, #45]
; 650:       00FC4193         ASR NL0, NL0, #1
; 654:       00040091         ADD NL0, NL0, #1
; 658:       1F0000AB         CMN NL0, NL0
; 65C:       26030054         BVS L23
; 660:       4C3700F9         STR R2, [CFP, #104]
; 664:       00F87FD3         LSL NL0, NL0, #1
; 668:       80D102F8         STR NL0, [R2, #45]
; 66C:       EB030CAA         MOV R1, R2
; 670:       7A0300F9         STR CFP, [CSP]
; 674:       4A1740F9         LDR R0, [CFP, #40]
; 678:       56D4FF58         LDR LEXENV, #x70055B1100        ; #<SB-KERNEL:FDEFN BUSY-ADD>
; 67C:       970080D2         MOVZ NARGS, #4
; 680:       580B00F9         STR NFP, [CFP, #16]
; 684:       FA031BAA         MOV CFP, CSP
; 688:       DE9240F8         LDR LR, [LEXENV, #9]
; 68C:       C0033FD6         BLR LR
; 690:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 694:       580B40F9         LDR NFP, [CFP, #16]
; 698:       4C3740F9         LDR R2, [CFP, #104]
; 69C:       5F011DEB         CMP R0, NULL
; 6A0:       AC038C9A         CSEL R2, NULL, R2, EQ
; 6A4:       4A1340F9         LDR R0, [CFP, #32]
; 6A8:       ABE30091         ADD R1, NULL, #56               ; T
; 6AC:       4BD103F8         STR R1, [R0, #61]
; 6B0:       000340F9         LDR NL0, [NFP]
; 6B4:       000400D1         SUB NL0, NL0, #1
; 6B8:       E30300AA         MOV NL3, NL0
; 6BC:       61FFFF17         B L9
; 6C0: L23:  A00A28D4         BRK #16469                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 6C4: L24:  608321D4         BRK #3099                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 6C8:       3B               BYTE #X3B                       ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 6C9:       .ALIGN           4
; 6CC: L25:  6BD4FF58         LDR R1, #x70055B1158            ; '*CURRENT-DFA*
; 6D0:       61515FB8         LDR WNL1, [R1, #-11]
; 6D4:       AA6A61F8         LDR R0, [THREAD, NL1]
; 6D8:       5F0500B1         CMN R0, #1
; 6DC:       41000054         BNE L26
; 6E0:       6A1140F8         LDR R0, [R1, #1]
; 6E4: L26:  5F2500F1         CMP R0, #9
; 6E8:       E0150054         BEQ L53
; 6EC:       5F011DEB         CMP R0, NULL
; 6F0:       E00C0054         BEQ L37
; 6F4:       405141F8         LDR NL0, [R0, #21]
; 6F8:       0BD1FF58         LDR R1, #x70055B1118            ; '*SIMULATOR*
; 6FC:       61515FB8         LDR WNL1, [R1, #-11]
; 700:       AA6A61F8         LDR R0, [THREAD, NL1]
; 704:       5F0500B1         CMN R0, #1
; 708:       41000054         BNE L27
; 70C:       6A1140F8         LDR R0, [R1, #1]
; 710: L27:  5F2500F1         CMP R0, #9
; 714:       A0140054         BEQ L54
; 718:       5F011DEB         CMP R0, NULL
; 71C:       400B0054         BEQ L36
; 720:       4AD140F8         LDR R0, [R0, #13]
; 724:       4AD140F8         LDR R0, [R0, #13]
; 728:       41915FF8         LDR NL1, [R0, #-7]
; 72C:       3F0000EB         CMP NL1, NL0
; 730:       E9130054         BLS L55
; 734:       4909008B         ADD TMP, R0, NL0, LSL #2
; 738:       2A1140F8         LDR R0, [TMP, #1]
; 73C:       410D4092         AND NL1, R0, #15
; 740:       3F0C00F1         CMP NL1, #3
; 744:       C1090054         BNE L35
; 748:       4E5140F8         LDR R4, [R0, #5]
; 74C:       C25145B8         LDR WNL2, [R4, #85]
; 750:       41D2FF18         LDR WNL1, #x70055B1198
; 754:       5F00016B         CMP WNL2, WNL1
; 758:       21090054         BNE L35
; 75C:       4A5143F8         LDR R0, [R0, #53]
; 760:       5F011DEB         CMP R0, NULL
; 764:       40F6FF54         BEQ L22
; 768:       E10D4092         AND NL1, R5, #15
; 76C:       3F0C00F1         CMP NL1, #3
; 770:       21080054         BNE L34
; 774:       EE5140F8         LDR R4, [R5, #5]
; 778:       C25145B8         LDR WNL2, [R4, #85]
; 77C:       01D1FF18         LDR WNL1, #x70055B119C
; 780:       5F00016B         CMP WNL2, WNL1
; 784:       81070054         BNE L34
; 788:       E3D142F8         LDR NL3, [R5, #45]
; 78C:       6BCEFF58         LDR R1, #x70055B1158            ; '*CURRENT-DFA*
; 790:       61515FB8         LDR WNL1, [R1, #-11]
; 794:       AA6A61F8         LDR R0, [THREAD, NL1]
; 798:       5F0500B1         CMN R0, #1
; 79C:       41000054         BNE L28
; 7A0:       6A1140F8         LDR R0, [R1, #1]
; 7A4: L28:  5F2500F1         CMP R0, #9
; 7A8:       60100054         BEQ L56
; 7AC:       5F011DEB         CMP R0, NULL
; 7B0:       E0050054         BEQ L33
; 7B4:       405141F8         LDR NL0, [R0, #21]
; 7B8:       0BCBFF58         LDR R1, #x70055B1118            ; '*SIMULATOR*
; 7BC:       61515FB8         LDR WNL1, [R1, #-11]
; 7C0:       AA6A61F8         LDR R0, [THREAD, NL1]
; 7C4:       5F0500B1         CMN R0, #1
; 7C8:       41000054         BNE L29
; 7CC:       6A1140F8         LDR R0, [R1, #1]
; 7D0: L29:  5F2500F1         CMP R0, #9
; 7D4:       200F0054         BEQ L57
; 7D8:       5F011DEB         CMP R0, NULL
; 7DC:       40040054         BEQ L32
; 7E0:       4AD140F8         LDR R0, [R0, #13]
; 7E4:       4AD140F8         LDR R0, [R0, #13]
; 7E8:       41915FF8         LDR NL1, [R0, #-7]
; 7EC:       3F0000EB         CMP NL1, NL0
; 7F0:       690E0054         BLS L58
; 7F4:       4909008B         ADD TMP, R0, NL0, LSL #2
; 7F8:       2A1140F8         LDR R0, [TMP, #1]
; 7FC:       410D4092         AND NL1, R0, #15
; 800:       3F0C00F1         CMP NL1, #3
; 804:       C1020054         BNE L31
; 808:       4E5140F8         LDR R4, [R0, #5]
; 80C:       C25145B8         LDR WNL2, [R4, #85]
; 810:       41CCFF18         LDR WNL1, #x70055B1198
; 814:       5F00016B         CMP WNL2, WNL1
; 818:       21020054         BNE L31
; 81C:       40D141F8         LDR NL0, [R0, #29]
; 820:       1F0003EB         CMP NL0, NL3
; 824:       41F0FF54         BNE L22
; 828:       810D4092         AND NL1, R2, #15
; 82C:       3F0C00F1         CMP NL1, #3
; 830:       21010054         BNE L30
; 834:       8E5140F8         LDR R4, [R2, #5]
; 838:       C25145B8         LDR WNL2, [R4, #85]
; 83C:       A1CAFF18         LDR WNL1, #x70055B1190
; 840:       5F00016B         CMP WNL2, WNL1
; 844:       81000054         BNE L30
; 848:       AAE30091         ADD R0, NULL, #56               ; T
; 84C:       8A5103F8         STR R0, [R2, #53]
; 850:       77FFFF17         B L22
; 854: L30:  608321D4         BRK #3099                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R2
; 858:       3B               BYTE #X3B                       ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 859:       .ALIGN           4
; 85C: L31:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 860:       63               BYTE #X63                       ; #<SB-KERNEL:LAYOUT (ID=393) for ATN-STATE {700CD64703}>
; 861:       .ALIGN           4
; 864: L32:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 868:       67               BYTE #X67                       ; #<SB-KERNEL:LAYOUT (ID=399) for PARSER-ATN-SIMULATOR {700CD64A83}>
; 869:       .ALIGN           4
; 86C: L33:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 870:       6B               BYTE #X6B                       ; #<SB-KERNEL:LAYOUT (ID=398) for DFA {700CD64A03}>
; 871:       .ALIGN           4
; 874: L34:  60E321D4         BRK #3867                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; 878:       5B               BYTE #X5B                       ; #<SB-KERNEL:LAYOUT (ID=394) for ATN-TRANSITION {700CD64783}>
; 879:       .ALIGN           4
; 87C: L35:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 880:       63               BYTE #X63                       ; #<SB-KERNEL:LAYOUT (ID=393) for ATN-STATE {700CD64703}>
; 881:       .ALIGN           4
; 884: L36:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 888:       67               BYTE #X67                       ; #<SB-KERNEL:LAYOUT (ID=399) for PARSER-ATN-SIMULATOR {700CD64A83}>
; 889:       .ALIGN           4
; 88C: L37:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 890:       6B               BYTE #X6B                       ; #<SB-KERNEL:LAYOUT (ID=398) for DFA {700CD64A03}>
; 891:       .ALIGN           4
; 894: L38:  E10D4092         AND NL1, R5, #15
; 898:       3F0C00F1         CMP NL1, #3
; 89C:       81010054         BNE L39
; 8A0:       EE5140F8         LDR R4, [R5, #5]
; 8A4:       C25145B8         LDR WNL2, [R4, #85]
; 8A8:       A1C7FF18         LDR WNL1, #x70055B119C
; 8AC:       5F00016B         CMP WNL2, WNL1
; 8B0:       E1000054         BNE L39
; 8B4:       EAD140F8         LDR R0, [R5, #13]
; 8B8:       4BC4FF58         LDR R1, #x70055B1140            ; :ACTION
; 8BC:       5F010BEB         CMP R0, R1
; 8C0:       20D5FF54         BEQ L6
; 8C4:       AAE30091         ADD R0, NULL, #56               ; T
; 8C8:       A8FEFF17         B L7
; 8CC: L39:  60E321D4         BRK #3867                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; 8D0:       5B               BYTE #X5B                       ; #<SB-KERNEL:LAYOUT (ID=394) for ATN-TRANSITION {700CD64783}>
; 8D1:       .ALIGN           4
; 8D4: L40:  4B5142F8         LDR R1, [R0, #37]
; 8D8:       16000014         B L43
; 8DC: L41:  6A915FF8         LDR R0, [R1, #-7]
; 8E0:       410D4092         AND NL1, R0, #15
; 8E4:       3F0C00F1         CMP NL1, #3
; 8E8:       01040054         BNE L46
; 8EC:       4E5140F8         LDR R4, [R0, #5]
; 8F0:       C25145B8         LDR WNL2, [R4, #85]
; 8F4:       41C5FF18         LDR WNL1, #x70055B119C
; 8F8:       5F00016B         CMP WNL2, WNL1
; 8FC:       61030054         BNE L46
; 900:       4AD140F8         LDR R0, [R0, #13]
; 904:       2CC1FF58         LDR R2, #x70055B1128            ; :EPSILON
; 908:       5F010CEB         CMP R0, R2
; 90C:       80000054         BEQ L42
; 910:       0CC1FF58         LDR R2, #x70055B1130            ; :RULE
; 914:       5F010CEB         CMP R0, R2
; 918:       41010054         BNE L45
; 91C: L42:  6A1140F8         LDR R0, [R1, #1]
; 920:       410D4092         AND NL1, R0, #15
; 924:       3F1C00F1         CMP NL1, #7
; 928:       A1000054         BNE L44
; 92C:       EB030AAA         MOV R1, R0
; 930: L43:  7F011DEB         CMP R1, NULL
; 934:       C0CEFF54         BEQ L2
; 938:       E9FFFF17         B L41
; 93C: L44:  E04921D4         BRK #2639                       ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 940: L45:  CCBFFF58         LDR R2, #x70055B1138            ; :PREDICATE
; 944:       5F010CEB         CMP R0, R2
; 948:       A0FEFF54         BEQ L42
; 94C:       ACBFFF58         LDR R2, #x70055B1140            ; :ACTION
; 950:       5F010CEB         CMP R0, R2
; 954:       40FEFF54         BEQ L42
; 958:       8CBFFF58         LDR R2, #x70055B1148            ; :PRECEDENCE
; 95C:       5F010CEB         CMP R0, R2
; 960:       E0FDFF54         BEQ L42
; 964:       60FEFF17         B L1
; 968: L46:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 96C:       5B               BYTE #X5B                       ; #<SB-KERNEL:LAYOUT (ID=394) for ATN-TRANSITION {700CD64783}>
; 96D:       .ALIGN           4
; 970: L47:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 974:       63               BYTE #X63                       ; #<SB-KERNEL:LAYOUT (ID=393) for ATN-STATE {700CD64703}>
; 975:       .ALIGN           4
; 978: L48:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 97C:       67               BYTE #X67                       ; #<SB-KERNEL:LAYOUT (ID=399) for PARSER-ATN-SIMULATOR {700CD64A83}>
; 97D:       .ALIGN           4
; 980:       E00120D4         BRK #15                         ; Invalid argument count trap
; 984: L49:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 988: L50:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 98C:       01               BYTE #X01                       ; NL0
; 98D:       .ALIGN           4
; 990: L51:  090280D2         MOVZ TMP, #16
; 994:       AEBFFF58         LDR R4, #x70055B1188            ; SB-VM::ALLOC-TRAMP
; 998:       C0013FD6         BLR R4
; 99C:       DEFEFF17         B L15
; 9A0: L52:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 9A4: L53:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 9A8: L54:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 9AC: L55:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 9B0:       01               BYTE #X01                       ; NL0
; 9B1:       .ALIGN           4
; 9B4: L56:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 9B8: L57:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 9BC: L58:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 9C0:       01               BYTE #X01                       ; NL0
; 9C1:       .ALIGN           4
