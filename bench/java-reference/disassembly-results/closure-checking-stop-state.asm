; disassembly for CNVRS/RUNTIME::CLOSURE-CHECKING-STOP-STATE
; Size: 1120 bytes. Origin: #x700AB1019C                      ; CNVRS/RUNTIME::CLOSURE-CHECKING-STOP-STATE
; 19C:       4A0F40F9         LDR R0, [CFP, #24]
; 1A0:       40D140F8         LDR NL0, [R0, #13]
; 1A4:       6BF6FF58         LDR R1, #x700AB10070            ; 'CNVRS/RUNTIME::*SIMULATOR*
; 1A8:       61515FB8         LDR WNL1, [R1, #-11]
; 1AC:       AA6A61F8         LDR R0, [THREAD, NL1]
; 1B0:       5F0500B1         CMN R0, #1
; 1B4:       41000054         BNE L0
; 1B8:       6A1140F8         LDR R0, [R1, #1]
; 1BC: L0:   5F2500F1         CMP R0, #9
; 1C0:       C0200054         BEQ L25
; 1C4:       5F011DEB         CMP R0, NULL
; 1C8:       20200054         BEQ L24
; 1CC:       4AD140F8         LDR R0, [R0, #13]
; 1D0:       4AD140F8         LDR R0, [R0, #13]
; 1D4:       41915FF8         LDR NL1, [R0, #-7]
; 1D8:       3F0000EB         CMP NL1, NL0
; 1DC:       09200054         BLS L26
; 1E0:       4909008B         ADD TMP, R0, NL0, LSL #2
; 1E4:       2A1140F8         LDR R0, [TMP, #1]
; 1E8:       410D4092         AND NL1, R0, #15
; 1EC:       3F0C00F1         CMP NL1, #3
; 1F0:       A11E0054         BNE L23
; 1F4:       4E5140F8         LDR R4, [R0, #5]
; 1F8:       C25145B8         LDR WNL2, [R4, #85]
; 1FC:       A1F6FF18         LDR WNL1, #x700AB100D0
; 200:       5F00016B         CMP WNL2, WNL1
; 204:       011E0054         BNE L23
; 208:       4A5141F8         LDR R0, [R0, #21]
; 20C:       6BF3FF58         LDR R1, #x700AB10078            ; :RULE-STOP
; 210:       5F010BEB         CMP R0, R1
; 214:       C1030054         BNE L3
; 218:       4A0F40F9         LDR R0, [CFP, #24]
; 21C:       4AD141F8         LDR R0, [R0, #29]
; 220:       4A2B00F9         STR R0, [CFP, #80]
; 224:       ECF2FF58         LDR R2, #x700AB10080            ; 'CNVRS/RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; 228:       81515FB8         LDR WNL1, [R2, #-11]
; 22C:       AB6A61F8         LDR R1, [THREAD, NL1]
; 230:       7F0500B1         CMN R1, #1
; 234:       41000054         BNE L1
; 238:       8B1140F8         LDR R1, [R2, #1]
; 23C: L1:   7F2500F1         CMP R1, #9
; 240:       201D0054         BEQ L27
; 244:       5F010BEB         CMP R0, R1
; 248:       81030054         BNE L4
; 24C:       4A1F40F9         LDR R0, [CFP, #56]
; 250:       5F011DEB         CMP R0, NULL
; 254:       C0010054         BEQ L3
; 258:       7A0300F9         STR CFP, [CSP]
; 25C:       4BAB41A9         LDP R1, R0, [CFP, #24]
; 260:       16EFFF58         LDR LEXENV, #x700AB10040        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONFIG-SET-ADD>
; 264:       970080D2         MOVZ NARGS, #4
; 268:       FA031BAA         MOV CFP, CSP
; 26C:       DE9240F8         LDR LR, [LEXENV, #9]
; 270:       C0033FD6         BLR LR
; 274:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 278:       EA031DAA         MOV R0, NULL
; 27C: L2:   FB031AAA         MOV CSP, CFP
; 280:       5A7B40A9         LDP CFP, LR, [CFP]
; 284:       BF0300F1         CMP NULL, #0
; 288:       C0035FD6         RET
; 28C: L3:   4AAF41A9         LDP R0, R1, [CFP, #24]
; 290:       4CB742A9         LDP R2, R3, [CFP, #40]
; 294:       4E8343A9         LDP R4, NL0, [CFP, #56]
; 298:       4E0302A9         STP R4, NL0, [CFP, #32]
; 29C:       4E2740F9         LDR R4, [CFP, #72]
; 2A0:       4E1B00F9         STR R4, [CFP, #48]
; 2A4:       36EDFF58         LDR LEXENV, #x700AB10048        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CLOSURE-WORK>
; 2A8:       D70180D2         MOVZ NARGS, #14
; 2AC:       DE9240F8         LDR LR, [LEXENV, #9]
; 2B0:       DE130091         ADD LR, LR, #4
; 2B4:       C0031FD6         BR LR
; 2B8: L4:   490D4092         AND TMP, R0, #15
; 2BC:       3F0D00F1         CMP TMP, #3
; 2C0:       81170054         BNE L21
; 2C4:       4B5140F8         LDR R1, [R0, #5]
; 2C8:       629145B8         LDR WNL2, [R1, #89]
; 2CC:       41F0FF18         LDR WNL1, #x700AB100D4
; 2D0:       5F00016B         CMP WNL2, WNL1
; 2D4:       20170054         BEQ L22
; 2D8:       629145B8         LDR WNL2, [R1, #89]
; 2DC:       E1EFFF18         LDR WNL1, #x700AB100D8
; 2E0:       5F00016B         CMP WNL2, WNL1
; 2E4:       61160054         BNE L21
; 2E8:       4A5141F8         LDR R0, [R0, #21]
; 2EC:       40915FF8         LDR NL0, [R0, #-7]
; 2F0:       403300F9         STR NL0, [CFP, #96]
; 2F4: L5:   5F2F00F9         STR ZR, [CFP, #88]
; 2F8:       55000014         B L10
; 2FC: L6:   432F40F9         LDR NL3, [CFP, #88]
; 300:       4A2B40F9         LDR R0, [CFP, #80]
; 304:       4E5140F8         LDR R4, [R0, #5]
; 308:       C29145B8         LDR WNL2, [R4, #89]
; 30C:       41EEFF18         LDR WNL1, #x700AB100D4
; 310:       5F00016B         CMP WNL2, WNL1
; 314:       60140054         BEQ L20
; 318:       4A2B40F9         LDR R0, [CFP, #80]
; 31C:       4A5141F8         LDR R0, [R0, #21]
; 320:       40915FF8         LDR NL0, [R0, #-7]
; 324:       412F40F9         LDR NL1, [CFP, #88]
; 328:       1F0001EB         CMP NL0, NL1
; 32C:       E9150054         BLS L28
; 330:       402F40F9         LDR NL0, [CFP, #88]
; 334:       4909008B         ADD TMP, R0, NL0, LSL #2
; 338:       2A1140F8         LDR R0, [TMP, #1]
; 33C:       5F7D5FF2         TST R0, #18446744065119617025
; 340:       61110054         BNE L18
; 344:       E4030AAA         MOV NL4, R0
; 348: L7:   432F40F9         LDR NL3, [CFP, #88]
; 34C:       4A2B40F9         LDR R0, [CFP, #80]
; 350:       4E5140F8         LDR R4, [R0, #5]
; 354:       C29145B8         LDR WNL2, [R4, #89]
; 358:       E1EBFF18         LDR WNL1, #x700AB100D4
; 35C:       5F00016B         CMP WNL2, WNL1
; 360:       E00F0054         BEQ L17
; 364:       4A2B40F9         LDR R0, [CFP, #80]
; 368:       4AD141F8         LDR R0, [R0, #29]
; 36C:       40915FF8         LDR NL0, [R0, #-7]
; 370:       412F40F9         LDR NL1, [CFP, #88]
; 374:       1F0001EB         CMP NL0, NL1
; 378:       C9130054         BLS L29
; 37C:       402F40F9         LDR NL0, [CFP, #88]
; 380:       4909008B         ADD TMP, R0, NL0, LSL #2
; 384:       2D1140F8         LDR R3, [TMP, #1]
; 388: L8:   E97B7FB2         MOV TMP, #4294967294
; 38C:       9F0009EB         CMP NL4, TMP
; 390:       00070054         BEQ L13
; 394:       EB0304AA         MOV R1, NL4
; 398:       7A0300F9         STR CFP, [CSP]
; 39C:       4A0F40F9         LDR R0, [CFP, #24]
; 3A0:       4CE7FF58         LDR R2, #x700AB10088            ; :CONTEXT
; 3A4:       76E5FF58         LDR LEXENV, #x700AB10050        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 3A8:       170180D2         MOVZ NARGS, #8
; 3AC:       FA031BAA         MOV CFP, CSP
; 3B0:       DE9240F8         LDR LR, [LEXENV, #9]
; 3B4:       C0033FD6         BLR LR
; 3B8:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 3BC:       402340F9         LDR NL0, [CFP, #64]
; 3C0:       00FC4193         ASR NL0, NL0, #1
; 3C4:       000400D1         SUB NL0, NL0, #1
; 3C8:       410D4092         AND NL1, R0, #15
; 3CC:       3F0C00F1         CMP NL1, #3
; 3D0:       C1040054         BNE L12
; 3D4:       4E5140F8         LDR R4, [R0, #5]
; 3D8:       C25145B8         LDR WNL2, [R4, #85]
; 3DC:       61E7FF18         LDR WNL1, #x700AB100C8
; 3E0:       5F00016B         CMP WNL2, WNL1
; 3E4:       21040054         BNE L12
; 3E8:       1F0000AB         CMN NL0, NL0
; 3EC:       C6030054         BVS L11
; 3F0:       02F87FD3         LSL NL2, NL0, #1
; 3F4:       E0031BAA         MOV NL0, CSP
; 3F8:       7A8707F8         STR CFP, [CSP], #120
; 3FC:       E10300D1         SUB NL1, NSP, #0
; 400:       3F000091         MOV NSP, NL1
; 404:       0A0C00F9         STR R0, [NL0, #24]
; 408:       4A1340F9         LDR R0, [CFP, #32]
; 40C:       0A1000F9         STR R0, [NL0, #32]
; 410:       4A1740F9         LDR R0, [CFP, #40]
; 414:       0A1400F9         STR R0, [NL0, #40]
; 418:       4A1B40F9         LDR R0, [CFP, #48]
; 41C:       0A1800F9         STR R0, [NL0, #48]
; 420:       4A1F40F9         LDR R0, [CFP, #56]
; 424:       0A1C00F9         STR R0, [NL0, #56]
; 428:       022000F9         STR NL2, [NL0, #64]
; 42C:       4A2740F9         LDR R0, [CFP, #72]
; 430:       0A2400F9         STR R0, [NL0, #72]
; 434:       FA0300AA         MOV CFP, NL0
; 438:       58FFFF97         BL #x700AB10198
; 43C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 440: L9:   402F40F9         LDR NL0, [CFP, #88]
; 444:       00080091         ADD NL0, NL0, #2
; 448:       402F00F9         STR NL0, [CFP, #88]
; 44C: L10:  402F40F9         LDR NL0, [CFP, #88]
; 450:       413340F9         LDR NL1, [CFP, #96]
; 454:       1F0001EB         CMP NL0, NL1
; 458:       2BF5FF54         BLT L6
; 45C:       EA031DAA         MOV R0, NULL
; 460:       87FFFF17         B L2
; 464: L11:  A00A28D4         BRK #16469                      ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL0
; 468: L12:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 46C:       37               BYTE #X37                       ; #<SB-KERNEL:LAYOUT (ID=395) for CNVRS/RUNTIME:ATN-CONFIG {700AA36813}>
; 46D:       .ALIGN           4
; 470: L13:  4A1F40F9         LDR R0, [CFP, #56]
; 474:       5F011DEB         CMP R0, NULL
; 478:       01020054         BNE L14
; 47C:       E0031BAA         MOV NL0, CSP
; 480:       7A8703F8         STR CFP, [CSP], #56
; 484:       4AAF41A9         LDP R0, R1, [CFP, #24]
; 488:       4CB742A9         LDP R2, R3, [CFP, #40]
; 48C:       412340F9         LDR NL1, [CFP, #64]
; 490:       1D0402A9         STP NULL, NL1, [NL0, #32]
; 494:       4E2740F9         LDR R4, [CFP, #72]
; 498:       0E1800F9         STR R4, [NL0, #48]
; 49C:       76DDFF58         LDR LEXENV, #x700AB10048        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CLOSURE-WORK>
; 4A0:       D70180D2         MOVZ NARGS, #14
; 4A4:       FA0300AA         MOV CFP, NL0
; 4A8:       DE9240F8         LDR LR, [LEXENV, #9]
; 4AC:       C0033FD6         BLR LR
; 4B0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 4B4:       E3FFFF17         B L9
; 4B8: L14:  4A0F40F9         LDR R0, [CFP, #24]
; 4BC:       4BD140F8         LDR R1, [R0, #13]
; 4C0:       0ADEFF58         LDR R0, #x700AB10080            ; 'CNVRS/RUNTIME::*EMPTY-PREDICTION-CONTEXT*
; 4C4:       41515FB8         LDR WNL1, [R0, #-11]
; 4C8:       AD6A61F8         LDR R3, [THREAD, NL1]
; 4CC:       BF0500B1         CMN R3, #1
; 4D0:       41000054         BNE L15
; 4D4:       4D1140F8         LDR R3, [R0, #1]
; 4D8: L15:  BF2500F1         CMP R3, #9
; 4DC:       E0080054         BEQ L30
; 4E0:       7A0300F9         STR CFP, [CSP]
; 4E4:       4A0F40F9         LDR R0, [CFP, #24]
; 4E8:       0CDDFF58         LDR R2, #x700AB10088            ; :CONTEXT
; 4EC:       36DBFF58         LDR LEXENV, #x700AB10050        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::DERIVE-CONFIG>
; 4F0:       170180D2         MOVZ NARGS, #8
; 4F4:       FA031BAA         MOV CFP, CSP
; 4F8:       DE9240F8         LDR LR, [LEXENV, #9]
; 4FC:       C0033FD6         BLR LR
; 500:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 504:       EB030AAA         MOV R1, R0
; 508:       7A0300F9         STR CFP, [CSP]
; 50C:       4A1340F9         LDR R0, [CFP, #32]
; 510:       96D9FF58         LDR LEXENV, #x700AB10040        ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONFIG-SET-ADD>
; 514:       970080D2         MOVZ NARGS, #4
; 518:       FA031BAA         MOV CFP, CSP
; 51C:       DE9240F8         LDR LR, [LEXENV, #9]
; 520:       C0033FD6         BLR LR
; 524:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 528:       C6FFFF17         B L9
; 52C: L16:  439306A9         STP NL3, NL4, [CFP, #104]
; 530:       7A0300F9         STR CFP, [CSP]
; 534:       EADAFF58         LDR R0, #x700AB10090            ; '(ZEROP
                                                              ;   CNVRS/RUNTIME::INDEX)
; 538:       4B0080D2         MOVZ R1, #2
; 53C:       ECDAFF58         LDR R2, #x700AB10098            ; 'CNVRS/RUNTIME::INDEX
; 540:       ED0303AA         MOV R3, NL3
; 544:       B6D8FF58         LDR LEXENV, #x700AB10058        ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 548:       170180D2         MOVZ NARGS, #8
; 54C:       FA031BAA         MOV CFP, CSP
; 550:       DE9240F8         LDR LR, [LEXENV, #9]
; 554:       C0033FD6         BLR LR
; 558:       439346A9         LDP NL3, NL4, [CFP, #104]
; 55C: L17:  83FEFFB5         CBNZ NL3, L16
; 560:       4A2B40F9         LDR R0, [CFP, #80]
; 564:       4D5141F8         LDR R3, [R0, #21]
; 568:       88FFFF17         B L8
; 56C: L18:  604D21D4         BRK #2667                       ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 570: L19:  433700F9         STR NL3, [CFP, #104]
; 574:       7A0300F9         STR CFP, [CSP]
; 578:       CAD8FF58         LDR R0, #x700AB10090            ; '(ZEROP
                                                              ;   CNVRS/RUNTIME::INDEX)
; 57C:       4B0080D2         MOVZ R1, #2
; 580:       CCD8FF58         LDR R2, #x700AB10098            ; 'CNVRS/RUNTIME::INDEX
; 584:       ED0303AA         MOV R3, NL3
; 588:       96D6FF58         LDR LEXENV, #x700AB10058        ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 58C:       170180D2         MOVZ NARGS, #8
; 590:       FA031BAA         MOV CFP, CSP
; 594:       DE9240F8         LDR LR, [LEXENV, #9]
; 598:       C0033FD6         BLR LR
; 59C:       433740F9         LDR NL3, [CFP, #104]
; 5A0: L20:  83FEFFB5         CBNZ NL3, L19
; 5A4:       4A2B40F9         LDR R0, [CFP, #80]
; 5A8:       44D141F8         LDR NL4, [R0, #29]
; 5AC:       67FFFF17         B L7
; 5B0: L21:  A04321D4         BRK #2589                       ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; 5B4:       53               BYTE #X53                       ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 5B5:       .ALIGN           4
; 5B8: L22:  400080D2         MOVZ NL0, #2
; 5BC:       403300F9         STR NL0, [CFP, #96]
; 5C0:       4DFFFF17         B L5
; 5C4: L23:  604321D4         BRK #2587                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 5C8:       57               BYTE #X57                       ; #<SB-KERNEL:LAYOUT (ID=393) for CNVRS/RUNTIME:ATN-STATE {700AA20B83}>
; 5C9:       .ALIGN           4
; 5CC: L24:  60A323D4         BRK #7451                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NULL
; 5D0:       5B               BYTE #X5B                       ; #<SB-KERNEL:LAYOUT (ID=399) for CNVRS/RUNTIME:PARSER-ATN-SIMULATOR {700AAD1EE3}>
; 5D1:       .ALIGN           4
; 5D4:       E00120D4         BRK #15                         ; Invalid argument count trap
; 5D8: L25:  E06221D4         BRK #2839                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R1
; 5DC: L26:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 5E0:       01               BYTE #X01                       ; NL0
; 5E1:       .ALIGN           4
; 5E4: L27:  E08221D4         BRK #3095                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; 5E8: L28:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 5EC:       05               BYTE #X05                       ; NL1
; 5ED:       .ALIGN           4
; 5F0: L29:  204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 5F4:       05               BYTE #X05                       ; NL1
; 5F5:       .ALIGN           4
; 5F8: L30:  E04221D4         BRK #2583                       ; UNBOUND-SYMBOL-ERROR
                                                              ; R0
