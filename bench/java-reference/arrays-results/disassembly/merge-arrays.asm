; disassembly for CNVRS/RUNTIME::MERGE-ARRAYS
; Size: 4692 bytes. Origin: #x700D72D290                      ; CNVRS/RUNTIME::MERGE-ARRAYS
; D290:       7A0300F9         STR CFP, [CSP]
; D294:       4A1B40F9         LDR R0, [CFP, #48]
; D298:       4BB341A9         LDP R1, R2, [CFP, #24]
; D29C:       4D1740F9         LDR R3, [CFP, #40]
; D2A0:       96F5FF58         LDR LEXENV, #x700D72D150       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-GET>
; D2A4:       170180D2         MOVZ NARGS, #8
; D2A8:       580B00F9         STR NFP, [CFP, #16]
; D2AC:       FA031BAA         MOV CFP, CSP
; D2B0:       DE9240F8         LDR LR, [LEXENV, #9]
; D2B4:       C0033FD6         BLR LR
; D2B8:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; D2BC:       580B40F9         LDR NFP, [CFP, #16]
; D2C0:       5F011DEB         CMP R0, NULL
; D2C4:       C1830054         BNE L92
; D2C8:       4A0F40F9         LDR R0, [CFP, #24]
; D2CC:       4A5140F8         LDR R0, [R0, #5]
; D2D0:       449145B8         LDR WNL4, [R0, #89]
; D2D4:       01F8FF18         LDR WNL1, #x700D72D1D4
; D2D8:       9F00016B         CMP WNL4, WNL1
; D2DC:       C0820054         BEQ L91
; D2E0:       449145B8         LDR WNL4, [R0, #89]
; D2E4:       A1F7FF18         LDR WNL1, #x700D72D1D8
; D2E8:       9F00016B         CMP WNL4, WNL1
; D2EC:       E1810054         BNE L90
; D2F0:       4A0F40F9         LDR R0, [CFP, #24]
; D2F4:       4A5141F8         LDR R0, [R0, #21]
; D2F8:       40915FF8         LDR NL0, [R0, #-7]
; D2FC: L0:   4A1340F9         LDR R0, [CFP, #32]
; D300:       4A5140F8         LDR R0, [R0, #5]
; D304:       449145B8         LDR WNL4, [R0, #89]
; D308:       61F6FF18         LDR WNL1, #x700D72D1D4
; D30C:       9F00016B         CMP WNL4, WNL1
; D310:       617F0054         BNE L88
; D314:       410080D2         MOVZ NL1, #2
; D318: L1:   00FC4193         ASR NL0, NL0, #1
; D31C:       0404818B         ADD NL4, NL0, NL1, ASR #1
; D320:       E00304AA         MOV NL0, NL4
; D324:       1F0442F2         TST NL0, #13835058055282163712
; D328:       817E0054         BNE L87
; D32C:       80F87FD3         LSL NL0, NL4, #1
; D330:       401F00F9         STR NL0, [CFP, #56]
; D334:       E1EF7DB2         MOV NL1, #9223372036854775800
; D338:       1F0001EB         CMP NL0, NL1
; D33C:       C87D0054         BHI L86
; D340:       02080091         ADD NL2, NL0, #2
; D344:       41FC4193         ASR NL1, NL2, #1
; D348:       22F87F92         AND NL2, NL1, #18446744073709551614
; D34C:       E1E77DB2         MOV NL1, #2305843009213693944
; D350:       5F0001EB         CMP NL2, NL1
; D354:       C87C0054         BHI L85
; D358:       4C2B80D2         MOVZ R2, #346
; D35C:       EB0300AA         MOV R1, NL0
; D360:       EA0302AA         MOV R0, NL2
; D364:       3EF3FF58         LDR LR, #x700D72D1C8           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; D368:       C0033FD6         BLR LR
; D36C:       EF030AAA         MOV R5, R0
; D370:       E1E77DB2         MOV NL1, #2305843009213693944
; D374:       1F0001EB         CMP NL0, NL1
; D378:       687B0054         BHI L84
; D37C:       4C2280D2         MOVZ R2, #274
; D380:       EB0300AA         MOV R1, NL0
; D384:       EA0300AA         MOV R0, NL0
; D388:       1EF2FF58         LDR LR, #x700D72D1C8           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; D38C:       C0033FD6         BLR LR
; D390:       E00304AA         MOV NL0, NL4
; D394:       F0030AAA         MOV R6, R0
; D398:       030080D2         MOVZ NL3, #0
; D39C:       020080D2         MOVZ NL2, #0
; D3A0:       060080D2         MOVZ NL6, #0
; D3A4:       4A0F40F9         LDR R0, [CFP, #24]
; D3A8:       4E5140F8         LDR R4, [R0, #5]
; D3AC:       C49145B8         LDR WNL4, [R4, #89]
; D3B0:       21F1FF18         LDR WNL1, #x700D72D1D4
; D3B4:       9F00016B         CMP WNL4, WNL1
; D3B8:       41470054         BNE L52
; D3BC:       4A0F40F9         LDR R0, [CFP, #24]
; D3C0:       40D141F8         LDR NL0, [R0, #29]
; D3C4:       4A0F40F9         LDR R0, [CFP, #24]
; D3C8:       515141F8         LDR R7, [R0, #21]
; D3CC:       05FC4193         ASR NL5, NL0, #1
; D3D0:       4A1340F9         LDR R0, [CFP, #32]
; D3D4:       4E5140F8         LDR R4, [R0, #5]
; D3D8:       C49145B8         LDR WNL4, [R4, #89]
; D3DC:       C1EFFF18         LDR WNL1, #x700D72D1D4
; D3E0:       9F00016B         CMP WNL4, WNL1
; D3E4:       A12E0054         BNE L36
; D3E8:       4A1340F9         LDR R0, [CFP, #32]
; D3EC:       44D141F8         LDR NL4, [R0, #29]
; D3F0:       4A1340F9         LDR R0, [CFP, #32]
; D3F4:       535141F8         LDR R9, [R0, #21]
; D3F8:       36000014         B L7
; D3FC: L2:   5F0000F1         CMP NL2, #0
; D400:       CC060054         BGT L8
; D404:       A0F87FD3         LSL NL0, NL5, #1
; D408:       9F0000EB         CMP NL4, NL0
; D40C:       21290054         BNE L34
; D410:       E0915FF8         LDR NL0, [R5, #-7]
; D414:       1F0006EB         CMP NL0, NL6
; D418:       E9790054         BLS L93
; D41C:       E905068B         ADD TMP, R5, NL6, LSL #1
; D420:       251100B8         STR WNL5, [TMP, #1]
; D424:       E97B40B2         MOV TMP, #2147483647
; D428:       BF0009EB         CMP NL5, TMP
; D42C:       61000054         BNE L3
; D430:       3F021DEB         CMP R7, NULL
; D434:       80270054         BEQ L33
; D438: L3:   3F021DEB         CMP R7, NULL
; D43C:       60240054         BEQ L32
; D440:       514F04A9         STP R7, R9, [CFP, #64]
; D444:       509B05A9         STP R6, NL6, [CFP, #88]
; D448:       4F4700F9         STR R5, [CFP, #136]
; D44C:       442B00F9         STR NL4, [CFP, #80]
; D450:       050300F9         STR NL5, [NFP]
; D454:       7A0300F9         STR CFP, [CSP]
; D458:       EA0311AA         MOV R0, R7
; D45C:       EB0313AA         MOV R1, R9
; D460:       D6E7FF58         LDR LEXENV, #x700D72D158       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; D464:       970080D2         MOVZ NARGS, #4
; D468:       580B00F9         STR NFP, [CFP, #16]
; D46C:       FA031BAA         MOV CFP, CSP
; D470:       DE9240F8         LDR LR, [LEXENV, #9]
; D474:       C0033FD6         BLR LR
; D478:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; D47C:       580B40F9         LDR NFP, [CFP, #16]
; D480:       050340F9         LDR NL5, [NFP]
; D484:       442B40F9         LDR NL4, [CFP, #80]
; D488:       4F4740F9         LDR R5, [CFP, #136]
; D48C:       509B45A9         LDP R6, NL6, [CFP, #88]
; D490:       514F44A9         LDP R7, R9, [CFP, #64]
; D494:       5F011DEB         CMP R0, NULL
; D498:       80210054         BEQ L32
; D49C: L4:   EA0311AA         MOV R0, R7
; D4A0: L5:   00925FF8         LDR NL0, [R6, #-7]
; D4A4:       1F0006EB         CMP NL0, NL6
; D4A8:       A9750054         BLS L94
; D4AC:       010A068B         ADD NL1, R6, NL6, LSL #2
; D4B0:       21040091         ADD NL1, NL1, #1
; D4B4:       29784BD3         UBFM TMP, NL1, #11, #30
; D4B8:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; D4BC:       2A0000F9         STR R0, [NL1]
; D4C0:       430080D2         MOVZ NL3, #2
; D4C4:       E20303AA         MOV NL2, NL3
; D4C8: L6:   C0080091         ADD NL0, NL6, #2
; D4CC:       E60300AA         MOV NL6, NL0
; D4D0: L7:   7F0000F1         CMP NL3, #0
; D4D4:       4DF9FF54         BLE L2
; D4D8: L8:   11000014         B L10
; D4DC: L9:   E0915FF8         LDR NL0, [R5, #-7]
; D4E0:       1F0006EB         CMP NL0, NL6
; D4E4:       09740054         BLS L95
; D4E8:       E905068B         ADD TMP, R5, NL6, LSL #1
; D4EC:       251100B8         STR WNL5, [TMP, #1]
; D4F0:       00925FF8         LDR NL0, [R6, #-7]
; D4F4:       1F0006EB         CMP NL0, NL6
; D4F8:       A9730054         BLS L96
; D4FC:       010A068B         ADD NL1, R6, NL6, LSL #2
; D500:       21040091         ADD NL1, NL1, #1
; D504:       29784BD3         UBFM TMP, NL1, #11, #30
; D508:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; D50C:       310000F9         STR R7, [NL1]
; D510:       430080D2         MOVZ NL3, #2
; D514:       C0080091         ADD NL0, NL6, #2
; D518:       E60300AA         MOV NL6, NL0
; D51C: L10:  7F0000F1         CMP NL3, #0
; D520:       EDFDFF54         BLE L9
; D524:       12000014         B L12
; D528: L11:  E0915FF8         LDR NL0, [R5, #-7]
; D52C:       1F0006EB         CMP NL0, NL6
; D530:       29720054         BLS L97
; D534:       80FC4193         ASR NL0, NL4, #1
; D538:       E905068B         ADD TMP, R5, NL6, LSL #1
; D53C:       201100B8         STR WNL0, [TMP, #1]
; D540:       00925FF8         LDR NL0, [R6, #-7]
; D544:       1F0006EB         CMP NL0, NL6
; D548:       A9710054         BLS L98
; D54C:       010A068B         ADD NL1, R6, NL6, LSL #2
; D550:       21040091         ADD NL1, NL1, #1
; D554:       29784BD3         UBFM TMP, NL1, #11, #30
; D558:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; D55C:       330000F9         STR R9, [NL1]
; D560:       420080D2         MOVZ NL2, #2
; D564:       C0080091         ADD NL0, NL6, #2
; D568:       E60300AA         MOV NL6, NL0
; D56C: L12:  5F0000F1         CMP NL2, #0
; D570:       CDFDFF54         BLE L11
; D574: L13:  DF0800F1         CMP NL6, #2
; D578:       20170054         BEQ L31
; D57C:       401F40F9         LDR NL0, [CFP, #56]
; D580:       DF0000EB         CMP NL6, NL0
; D584:       2B0C0054         BLT L23
; D588: L14:  502F00F9         STR R6, [CFP, #88]
; D58C:       EA030FAA         MOV R0, R5
; D590:       EB0310AA         MOV R1, R6
; D594:       7A0300F9         STR CFP, [CSP]
; D598:       56DEFF58         LDR LEXENV, #x700D72D160       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::CONTEXT-NODE>
; D59C:       970080D2         MOVZ NARGS, #4
; D5A0:       580B00F9         STR NFP, [CFP, #16]
; D5A4:       FA031BAA         MOV CFP, CSP
; D5A8:       DE9240F8         LDR LR, [LEXENV, #9]
; D5AC:       C0033FD6         BLR LR
; D5B0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; D5B4:       580B40F9         LDR NFP, [CFP, #16]
; D5B8:       502F40F9         LDR R6, [CFP, #88]
; D5BC:       410D4092         AND NL1, R0, #15
; D5C0:       3F0C00F1         CMP NL1, #3
; D5C4:       E1090054         BNE L22
; D5C8:       4E5140F8         LDR R4, [R0, #5]
; D5CC:       C49145B8         LDR WNL4, [R4, #89]
; D5D0:       41E0FF18         LDR WNL1, #x700D72D1D8
; D5D4:       9F00016B         CMP WNL4, WNL1
; D5D8:       41090054         BNE L22
; D5DC:       502F00F9         STR R6, [CFP, #88]
; D5E0:       EF030AAA         MOV R5, R0
; D5E4:       4F1F00F9         STR R5, [CFP, #56]
; D5E8:       EA030FAA         MOV R0, R5
; D5EC:       7A0300F9         STR CFP, [CSP]
; D5F0:       4B0F40F9         LDR R1, [CFP, #24]
; D5F4:       36DBFF58         LDR LEXENV, #x700D72D158       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; D5F8:       970080D2         MOVZ NARGS, #4
; D5FC:       580B00F9         STR NFP, [CFP, #16]
; D600:       FA031BAA         MOV CFP, CSP
; D604:       DE9240F8         LDR LR, [LEXENV, #9]
; D608:       C0033FD6         BLR LR
; D60C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; D610:       580B40F9         LDR NFP, [CFP, #16]
; D614:       502F40F9         LDR R6, [CFP, #88]
; D618:       4F1F40F9         LDR R5, [CFP, #56]
; D61C:       5F011DEB         CMP R0, NULL
; D620:       80000054         BEQ L15
; D624:       ABE30091         ADD R1, NULL, #56              ; T
; D628:       5F010BEB         CMP R0, R1
; D62C:       81060054         BNE L21
; D630: L15:  5F011DEB         CMP R0, NULL
; D634:       01060054         BNE L20
; D638:       4F1F00F9         STR R5, [CFP, #56]
; D63C:       502F00F9         STR R6, [CFP, #88]
; D640:       EA030FAA         MOV R0, R5
; D644:       7A0300F9         STR CFP, [CSP]
; D648:       4B1340F9         LDR R1, [CFP, #32]
; D64C:       76D8FF58         LDR LEXENV, #x700D72D158       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; D650:       970080D2         MOVZ NARGS, #4
; D654:       580B00F9         STR NFP, [CFP, #16]
; D658:       FA031BAA         MOV CFP, CSP
; D65C:       DE9240F8         LDR LR, [LEXENV, #9]
; D660:       C0033FD6         BLR LR
; D664:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; D668:       580B40F9         LDR NFP, [CFP, #16]
; D66C:       502F40F9         LDR R6, [CFP, #88]
; D670:       4F1F40F9         LDR R5, [CFP, #56]
; D674:       5F011DEB         CMP R0, NULL
; D678:       80000054         BEQ L16
; D67C:       ABE30091         ADD R1, NULL, #56              ; T
; D680:       5F010BEB         CMP R0, R1
; D684:       61030054         BNE L19
; D688: L16:  5F011DEB         CMP R0, NULL
; D68C:       80010054         BEQ L18
; D690:       4F1340F9         LDR R5, [CFP, #32]
; D694: L17:  4A1B40F9         LDR R0, [CFP, #48]
; D698:       4BB341A9         LDP R1, R2, [CFP, #24]
; D69C:       4D1740F9         LDR R3, [CFP, #40]
; D6A0:       4F1300F9         STR R5, [CFP, #32]
; D6A4:       36D6FF58         LDR LEXENV, #x700D72D168       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-PUT>
; D6A8:       570180D2         MOVZ NARGS, #10
; D6AC:       1F430091         ADD NSP, NFP, #16
; D6B0:       DE9240F8         LDR LR, [LEXENV, #9]
; D6B4:       DE130091         ADD LR, LR, #4
; D6B8:       C0031FD6         BR LR
; D6BC: L18:  4F1F00F9         STR R5, [CFP, #56]
; D6C0:       EA0310AA         MOV R0, R6
; D6C4:       7A0300F9         STR CFP, [CSP]
; D6C8:       56D5FF58         LDR LEXENV, #x700D72D170       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::COMBINE-COMMON-PARENTS>
; D6CC:       570080D2         MOVZ NARGS, #2
; D6D0:       580B00F9         STR NFP, [CFP, #16]
; D6D4:       FA031BAA         MOV CFP, CSP
; D6D8:       DE9240F8         LDR LR, [LEXENV, #9]
; D6DC:       C0033FD6         BLR LR
; D6E0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; D6E4:       580B40F9         LDR NFP, [CFP, #16]
; D6E8:       4F1F40F9         LDR R5, [CFP, #56]
; D6EC:       EAFFFF17         B L17
; D6F0: L19:  A05221D4         BRK #2709                      ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; D6F4: L20:  4F0F40F9         LDR R5, [CFP, #24]
; D6F8:       E7FFFF17         B L17
; D6FC: L21:  A05221D4         BRK #2709                      ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; D700: L22:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; D704:       4B               BYTE #X4B                      ; #<SB-KERNEL:LAYOUT (ID=391) for CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT {700CD58FC3}>
; D705:       .ALIGN           4
; D708: L23:  ED030FAA         MOV R3, R5
; D70C:       E0915FF8         LDR NL0, [R5, #-7]
; D710:       DF0000EB         CMP NL6, NL0
; D714:       2C090054         BGT L30
; D718:       C0080091         ADD NL0, NL6, #2
; D71C:       01FC4193         ASR NL1, NL0, #1
; D720:       2AF87F92         AND R0, NL1, #18446744073709551614
; D724:       4C2B80D2         MOVZ R2, #346
; D728:       EB0306AA         MOV R1, NL6
; D72C:       FED4FF58         LDR LR, #x700D72D1C8           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; D730:       C0033FD6         BLR LR
; D734:       EB030AAA         MOV R1, R0
; D738:       EA030BAA         MOV R0, R1
; D73C:       E0915FF8         LDR NL0, [R5, #-7]
; D740:       DF0000EB         CMP NL6, NL0
; D744:       02C0869A         CSEL NL2, NL0, NL6, GT
; D748:       41FC4193         ASR NL1, NL2, #1
; D74C:       20F87F92         AND NL0, NL1, #18446744073709551614
; D750:       41007F92         AND NL1, NL2, #2
; D754:       410100B4         CBZ NL1, L24
; D758:       E909008B         ADD TMP, R5, NL0, LSL #2
; D75C:       211140F8         LDR NL1, [TMP, #1]
; D760:       227C7FD3         UBFIZ NL2, NL1, #1, #32
; D764:       6909008B         ADD TMP, R1, NL0, LSL #2
; D768:       211140F8         LDR NL1, [TMP, #1]
; D76C:       217C6092         AND NL1, NL1, #18446744069414584320
; D770:       210482AA         ORR NL1, NL1, NL2, ASR #1
; D774:       6909008B         ADD TMP, R1, NL0, LSL #2
; D778:       211100F8         STR NL1, [TMP, #1]
; D77C: L24:  000800D1         SUB NL0, NL0, #2
; D780:       08000014         B L26
; D784: L25:  E20300AA         MOV NL2, NL0
; D788:       E10300AA         MOV NL1, NL0
; D78C:       A909018B         ADD TMP, R3, NL1, LSL #2
; D790:       211140F8         LDR NL1, [TMP, #1]
; D794:       4909028B         ADD TMP, R0, NL2, LSL #2
; D798:       211100F8         STR NL1, [TMP, #1]
; D79C:       000800D1         SUB NL0, NL0, #2
; D7A0: L26:  20FFFFB6         TBZ NL0, #63, L25
; D7A4:       EF030AAA         MOV R5, R0
; D7A8:       ED0310AA         MOV R3, R6
; D7AC:       00925FF8         LDR NL0, [R6, #-7]
; D7B0:       DF0000EB         CMP NL6, NL0
; D7B4:       0C030054         BGT L29
; D7B8:       4C2280D2         MOVZ R2, #274
; D7BC:       EB0306AA         MOV R1, NL6
; D7C0:       EA0306AA         MOV R0, NL6
; D7C4:       3ED0FF58         LDR LR, #x700D72D1C8           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; D7C8:       C0033FD6         BLR LR
; D7CC:       C0FC4193         ASR NL0, NL6, #1
; D7D0:       EB030AAA         MOV R1, R0
; D7D4:       E00306AA         MOV NL0, NL6
; D7D8:       0B000014         B L28
; D7DC: L27:  020800D1         SUB NL2, NL0, #2
; D7E0:       010800D1         SUB NL1, NL0, #2
; D7E4:       A909018B         ADD TMP, R3, NL1, LSL #2
; D7E8:       2A1140F8         LDR R0, [TMP, #1]
; D7EC:       6109028B         ADD NL1, R1, NL2, LSL #2
; D7F0:       21040091         ADD NL1, NL1, #1
; D7F4:       29784BD3         UBFM TMP, NL1, #11, #30
; D7F8:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; D7FC:       2A0000F9         STR R0, [NL1]
; D800:       000800D1         SUB NL0, NL0, #2
; D804: L28:  1F0000F1         CMP NL0, #0
; D808:       ACFEFF54         BGT L27
; D80C:       F0030BAA         MOV R6, R1
; D810:       5EFFFF17         B L14
; D814: L29:  EA0310AA         MOV R0, R6
; D818:       0B0080D2         MOVZ R1, #0
; D81C:       EC0306AA         MOV R2, NL6
; D820:       D6CAFF58         LDR LEXENV, #x700D72D178       ; #<SB-KERNEL:FDEFN SB-INT:SEQUENCE-BOUNDING-INDICES-BAD-ERROR>
; D824:       D70080D2         MOVZ NARGS, #6
; D828:       1F430091         ADD NSP, NFP, #16
; D82C:       DE9240F8         LDR LR, [LEXENV, #9]
; D830:       DE130091         ADD LR, LR, #4
; D834:       C0031FD6         BR LR
; D838: L30:  EA030FAA         MOV R0, R5
; D83C:       0B0080D2         MOVZ R1, #0
; D840:       EC0306AA         MOV R2, NL6
; D844:       B6C9FF58         LDR LEXENV, #x700D72D178       ; #<SB-KERNEL:FDEFN SB-INT:SEQUENCE-BOUNDING-INDICES-BAD-ERROR>
; D848:       D70080D2         MOVZ NARGS, #6
; D84C:       1F430091         ADD NSP, NFP, #16
; D850:       DE9240F8         LDR LR, [LEXENV, #9]
; D854:       DE130091         ADD LR, LR, #4
; D858:       C0031FD6         BR LR
; D85C: L31:  00925FF8         LDR NL0, [R6, #-7]
; D860:       205900B4         CBZ NL0, L99
; D864:       0A1240F8         LDR R0, [R6, #1]
; D868:       E0915FF8         LDR NL0, [R5, #-7]
; D86C:       005900B4         CBZ NL0, L100
; D870:       E01140B8         LDR WNL0, [R5, #1]
; D874:       0BF87FD3         LSL R1, NL0, #1
; D878:       7A0300F9         STR CFP, [CSP]
; D87C:       36C8FF58         LDR LEXENV, #x700D72D180       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:SINGLETON-CONTEXT>
; D880:       970080D2         MOVZ NARGS, #4
; D884:       580B00F9         STR NFP, [CFP, #16]
; D888:       FA031BAA         MOV CFP, CSP
; D88C:       DE9240F8         LDR LR, [LEXENV, #9]
; D890:       C0033FD6         BLR LR
; D894:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; D898:       580B40F9         LDR NFP, [CFP, #16]
; D89C:       EE030AAA         MOV R4, R0
; D8A0:       4A1B40F9         LDR R0, [CFP, #48]
; D8A4:       4BB341A9         LDP R1, R2, [CFP, #24]
; D8A8:       4D1740F9         LDR R3, [CFP, #40]
; D8AC:       4E1300F9         STR R4, [CFP, #32]
; D8B0:       D6C5FF58         LDR LEXENV, #x700D72D168       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME::MERGE-CACHE-PUT>
; D8B4:       570180D2         MOVZ NARGS, #10
; D8B8:       1F430091         ADD NSP, NFP, #16
; D8BC:       DE9240F8         LDR LR, [LEXENV, #9]
; D8C0:       DE130091         ADD LR, LR, #4
; D8C4:       C0031FD6         BR LR
; D8C8: L32:  514F04A9         STP R7, R9, [CFP, #64]
; D8CC:       509B05A9         STP R6, NL6, [CFP, #88]
; D8D0:       050300F9         STR NL5, [NFP]
; D8D4:       442B00F9         STR NL4, [CFP, #80]
; D8D8:       4F4700F9         STR R5, [CFP, #136]
; D8DC:       7A0300F9         STR CFP, [CSP]
; D8E0:       EA0311AA         MOV R0, R7
; D8E4:       EB0313AA         MOV R1, R9
; D8E8:       4CB742A9         LDP R2, R3, [CFP, #40]
; D8EC:       F6C4FF58         LDR LEXENV, #x700D72D188       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:MERGE-CONTEXTS>
; D8F0:       170180D2         MOVZ NARGS, #8
; D8F4:       580B00F9         STR NFP, [CFP, #16]
; D8F8:       FA031BAA         MOV CFP, CSP
; D8FC:       DE9240F8         LDR LR, [LEXENV, #9]
; D900:       C0033FD6         BLR LR
; D904:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; D908:       580B40F9         LDR NFP, [CFP, #16]
; D90C:       4F4740F9         LDR R5, [CFP, #136]
; D910:       442B40F9         LDR NL4, [CFP, #80]
; D914:       050340F9         LDR NL5, [NFP]
; D918:       509B45A9         LDP R6, NL6, [CFP, #88]
; D91C:       514F44A9         LDP R7, R9, [CFP, #64]
; D920:       E0FEFF17         B L5
; D924: L33:  7F021DEB         CMP R9, NULL
; D928:       A0DBFF54         BEQ L4
; D92C:       C3FEFF17         B L3
; D930: L34:  A0F87FD3         LSL NL0, NL5, #1
; D934:       1F0004EB         CMP NL0, NL4
; D938:       2B020054         BLT L35
; D93C:       E0915FF8         LDR NL0, [R5, #-7]
; D940:       1F0006EB         CMP NL0, NL6
; D944:       89520054         BLS L101
; D948:       80FC4193         ASR NL0, NL4, #1
; D94C:       E905068B         ADD TMP, R5, NL6, LSL #1
; D950:       201100B8         STR WNL0, [TMP, #1]
; D954:       00925FF8         LDR NL0, [R6, #-7]
; D958:       1F0006EB         CMP NL0, NL6
; D95C:       09520054         BLS L102
; D960:       010A068B         ADD NL1, R6, NL6, LSL #2
; D964:       21040091         ADD NL1, NL1, #1
; D968:       29784BD3         UBFM TMP, NL1, #11, #30
; D96C:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; D970:       330000F9         STR R9, [NL1]
; D974:       420080D2         MOVZ NL2, #2
; D978:       D4FEFF17         B L6
; D97C: L35:  E0915FF8         LDR NL0, [R5, #-7]
; D980:       1F0006EB         CMP NL0, NL6
; D984:       09510054         BLS L103
; D988:       E905068B         ADD TMP, R5, NL6, LSL #1
; D98C:       251100B8         STR WNL5, [TMP, #1]
; D990:       00925FF8         LDR NL0, [R6, #-7]
; D994:       1F0006EB         CMP NL0, NL6
; D998:       A9500054         BLS L104
; D99C:       010A068B         ADD NL1, R6, NL6, LSL #2
; D9A0:       21040091         ADD NL1, NL1, #1
; D9A4:       29784BD3         UBFM TMP, NL1, #11, #30
; D9A8:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; D9AC:       310000F9         STR R7, [NL1]
; D9B0:       430080D2         MOVZ NL3, #2
; D9B4:       C5FEFF17         B L6
; D9B8: L36:  4A1340F9         LDR R0, [CFP, #32]
; D9BC:       545141F8         LDR R8, [R0, #21]
; D9C0:       4A1340F9         LDR R0, [CFP, #32]
; D9C4:       53D141F8         LDR R9, [R0, #29]
; D9C8:       45000014         B L42
; D9CC: L37:  80925FF8         LDR NL0, [R8, #-7]
; D9D0:       5F0000EB         CMP NL2, NL0
; D9D4:       8A080054         BGE L43
; D9D8:       8906028B         ADD TMP, R8, NL2, LSL #1
; D9DC:       241140B8         LDR WNL4, [TMP, #1]
; D9E0:       80F87FD3         LSL NL0, NL4, #1
; D9E4:       61925FF8         LDR NL1, [R9, #-7]
; D9E8:       3F0002EB         CMP NL1, NL2
; D9EC:       494E0054         BLS L105
; D9F0:       690A028B         ADD TMP, R9, NL2, LSL #2
; D9F4:       2A1140F8         LDR R0, [TMP, #1]
; D9F8:       EC030AAA         MOV R2, R0
; D9FC:       A1F87FD3         LSL NL1, NL5, #1
; DA00:       1F0001EB         CMP NL0, NL1
; DA04:       81100054         BNE L50
; DA08:       E0915FF8         LDR NL0, [R5, #-7]
; DA0C:       1F0006EB         CMP NL0, NL6
; DA10:       694D0054         BLS L106
; DA14:       E905068B         ADD TMP, R5, NL6, LSL #1
; DA18:       251100B8         STR WNL5, [TMP, #1]
; DA1C:       E97B40B2         MOV TMP, #2147483647
; DA20:       BF0009EB         CMP NL5, TMP
; DA24:       61000054         BNE L38
; DA28:       3F021DEB         CMP R7, NULL
; DA2C:       E00E0054         BEQ L49
; DA30: L38:  3F021DEB         CMP R7, NULL
; DA34:       800B0054         BEQ L48
; DA38:       4C3F00F9         STR R2, [CFP, #120]
; DA3C:       512300F9         STR R7, [CFP, #64]
; DA40:       423B00F9         STR NL2, [CFP, #112]
; DA44:       509B05A9         STP R6, NL6, [CFP, #88]
; DA48:       53D304A9         STP R9, R8, [CFP, #72]
; DA4C:       4F4700F9         STR R5, [CFP, #136]
; DA50:       050300F9         STR NL5, [NFP]
; DA54:       7A0300F9         STR CFP, [CSP]
; DA58:       EA0311AA         MOV R0, R7
; DA5C:       EB030CAA         MOV R1, R2
; DA60:       D6B7FF58         LDR LEXENV, #x700D72D158       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; DA64:       970080D2         MOVZ NARGS, #4
; DA68:       580B00F9         STR NFP, [CFP, #16]
; DA6C:       FA031BAA         MOV CFP, CSP
; DA70:       DE9240F8         LDR LR, [LEXENV, #9]
; DA74:       C0033FD6         BLR LR
; DA78:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; DA7C:       580B40F9         LDR NFP, [CFP, #16]
; DA80:       050340F9         LDR NL5, [NFP]
; DA84:       4F4740F9         LDR R5, [CFP, #136]
; DA88:       53D344A9         LDP R9, R8, [CFP, #72]
; DA8C:       509B45A9         LDP R6, NL6, [CFP, #88]
; DA90:       423B40F9         LDR NL2, [CFP, #112]
; DA94:       512340F9         LDR R7, [CFP, #64]
; DA98:       4C3F40F9         LDR R2, [CFP, #120]
; DA9C:       5F011DEB         CMP R0, NULL
; DAA0:       20080054         BEQ L48
; DAA4: L39:  EA0311AA         MOV R0, R7
; DAA8: L40:  00925FF8         LDR NL0, [R6, #-7]
; DAAC:       1F0006EB         CMP NL0, NL6
; DAB0:       A9480054         BLS L107
; DAB4:       010A068B         ADD NL1, R6, NL6, LSL #2
; DAB8:       21040091         ADD NL1, NL1, #1
; DABC:       29784BD3         UBFM TMP, NL1, #11, #30
; DAC0:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DAC4:       2A0000F9         STR R0, [NL1]
; DAC8:       430080D2         MOVZ NL3, #2
; DACC:       40080091         ADD NL0, NL2, #2
; DAD0:       E20300AA         MOV NL2, NL0
; DAD4: L41:  C0080091         ADD NL0, NL6, #2
; DAD8:       E60300AA         MOV NL6, NL0
; DADC: L42:  7F0000F1         CMP NL3, #0
; DAE0:       6DF7FF54         BLE L37
; DAE4: L43:  11000014         B L45
; DAE8: L44:  E0915FF8         LDR NL0, [R5, #-7]
; DAEC:       1F0006EB         CMP NL0, NL6
; DAF0:       E9460054         BLS L108
; DAF4:       E905068B         ADD TMP, R5, NL6, LSL #1
; DAF8:       251100B8         STR WNL5, [TMP, #1]
; DAFC:       00925FF8         LDR NL0, [R6, #-7]
; DB00:       1F0006EB         CMP NL0, NL6
; DB04:       89460054         BLS L109
; DB08:       010A068B         ADD NL1, R6, NL6, LSL #2
; DB0C:       21040091         ADD NL1, NL1, #1
; DB10:       29784BD3         UBFM TMP, NL1, #11, #30
; DB14:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DB18:       310000F9         STR R7, [NL1]
; DB1C:       430080D2         MOVZ NL3, #2
; DB20:       C0080091         ADD NL0, NL6, #2
; DB24:       E60300AA         MOV NL6, NL0
; DB28: L45:  7F0000F1         CMP NL3, #0
; DB2C:       EDFDFF54         BLE L44
; DB30:       19000014         B L47
; DB34: L46:  8906028B         ADD TMP, R8, NL2, LSL #1
; DB38:       211140B8         LDR WNL1, [TMP, #1]
; DB3C:       E0915FF8         LDR NL0, [R5, #-7]
; DB40:       1F0006EB         CMP NL0, NL6
; DB44:       C9440054         BLS L110
; DB48:       E905068B         ADD TMP, R5, NL6, LSL #1
; DB4C:       211100B8         STR WNL1, [TMP, #1]
; DB50:       60925FF8         LDR NL0, [R9, #-7]
; DB54:       1F0002EB         CMP NL0, NL2
; DB58:       69440054         BLS L111
; DB5C:       690A028B         ADD TMP, R9, NL2, LSL #2
; DB60:       2A1140F8         LDR R0, [TMP, #1]
; DB64:       00925FF8         LDR NL0, [R6, #-7]
; DB68:       1F0006EB         CMP NL0, NL6
; DB6C:       09440054         BLS L112
; DB70:       010A068B         ADD NL1, R6, NL6, LSL #2
; DB74:       21040091         ADD NL1, NL1, #1
; DB78:       29784BD3         UBFM TMP, NL1, #11, #30
; DB7C:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DB80:       2A0000F9         STR R0, [NL1]
; DB84:       40080091         ADD NL0, NL2, #2
; DB88:       E20300AA         MOV NL2, NL0
; DB8C:       C0080091         ADD NL0, NL6, #2
; DB90:       E60300AA         MOV NL6, NL0
; DB94: L47:  80925FF8         LDR NL0, [R8, #-7]
; DB98:       5F0000EB         CMP NL2, NL0
; DB9C:       CBFCFF54         BLT L46
; DBA0:       75FEFF17         B L13
; DBA4: L48:  512300F9         STR R7, [CFP, #64]
; DBA8:       509B05A9         STP R6, NL6, [CFP, #88]
; DBAC:       423B00F9         STR NL2, [CFP, #112]
; DBB0:       050300F9         STR NL5, [NFP]
; DBB4:       4F4700F9         STR R5, [CFP, #136]
; DBB8:       53D304A9         STP R9, R8, [CFP, #72]
; DBBC:       7A0300F9         STR CFP, [CSP]
; DBC0:       EA0311AA         MOV R0, R7
; DBC4:       EB030CAA         MOV R1, R2
; DBC8:       4CB742A9         LDP R2, R3, [CFP, #40]
; DBCC:       F6ADFF58         LDR LEXENV, #x700D72D188       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:MERGE-CONTEXTS>
; DBD0:       170180D2         MOVZ NARGS, #8
; DBD4:       580B00F9         STR NFP, [CFP, #16]
; DBD8:       FA031BAA         MOV CFP, CSP
; DBDC:       DE9240F8         LDR LR, [LEXENV, #9]
; DBE0:       C0033FD6         BLR LR
; DBE4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; DBE8:       580B40F9         LDR NFP, [CFP, #16]
; DBEC:       53D344A9         LDP R9, R8, [CFP, #72]
; DBF0:       4F4740F9         LDR R5, [CFP, #136]
; DBF4:       050340F9         LDR NL5, [NFP]
; DBF8:       423B40F9         LDR NL2, [CFP, #112]
; DBFC:       509B45A9         LDP R6, NL6, [CFP, #88]
; DC00:       512340F9         LDR R7, [CFP, #64]
; DC04:       A9FFFF17         B L40
; DC08: L49:  5F011DEB         CMP R0, NULL
; DC0C:       C0F4FF54         BEQ L39
; DC10:       88FFFF17         B L38
; DC14: L50:  A1F87FD3         LSL NL1, NL5, #1
; DC18:       3F0000EB         CMP NL1, NL0
; DC1C:       4B020054         BLT L51
; DC20:       E0915FF8         LDR NL0, [R5, #-7]
; DC24:       1F0006EB         CMP NL0, NL6
; DC28:       693E0054         BLS L113
; DC2C:       E00304AA         MOV NL0, NL4
; DC30:       E905068B         ADD TMP, R5, NL6, LSL #1
; DC34:       201100B8         STR WNL0, [TMP, #1]
; DC38:       00925FF8         LDR NL0, [R6, #-7]
; DC3C:       1F0006EB         CMP NL0, NL6
; DC40:       E93D0054         BLS L114
; DC44:       010A068B         ADD NL1, R6, NL6, LSL #2
; DC48:       21040091         ADD NL1, NL1, #1
; DC4C:       29784BD3         UBFM TMP, NL1, #11, #30
; DC50:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DC54:       2A0000F9         STR R0, [NL1]
; DC58:       40080091         ADD NL0, NL2, #2
; DC5C:       E20300AA         MOV NL2, NL0
; DC60:       9DFFFF17         B L41
; DC64: L51:  E0915FF8         LDR NL0, [R5, #-7]
; DC68:       1F0006EB         CMP NL0, NL6
; DC6C:       C93C0054         BLS L115
; DC70:       E905068B         ADD TMP, R5, NL6, LSL #1
; DC74:       251100B8         STR WNL5, [TMP, #1]
; DC78:       00925FF8         LDR NL0, [R6, #-7]
; DC7C:       1F0006EB         CMP NL0, NL6
; DC80:       693C0054         BLS L116
; DC84:       010A068B         ADD NL1, R6, NL6, LSL #2
; DC88:       21040091         ADD NL1, NL1, #1
; DC8C:       29784BD3         UBFM TMP, NL1, #11, #30
; DC90:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DC94:       310000F9         STR R7, [NL1]
; DC98:       430080D2         MOVZ NL3, #2
; DC9C:       8EFFFF17         B L41
; DCA0: L52:  4A0F40F9         LDR R0, [CFP, #24]
; DCA4:       545141F8         LDR R8, [R0, #21]
; DCA8:       4A0F40F9         LDR R0, [CFP, #24]
; DCAC:       51D141F8         LDR R7, [R0, #29]
; DCB0:       4A1340F9         LDR R0, [CFP, #32]
; DCB4:       4E5140F8         LDR R4, [R0, #5]
; DCB8:       C49145B8         LDR WNL4, [R4, #89]
; DCBC:       C1A8FF18         LDR WNL1, #x700D72D1D4
; DCC0:       9F00016B         CMP WNL4, WNL1
; DCC4:       21170054         BNE L68
; DCC8:       4A1340F9         LDR R0, [CFP, #32]
; DCCC:       44D141F8         LDR NL4, [R0, #29]
; DCD0:       4A1340F9         LDR R0, [CFP, #32]
; DCD4:       535141F8         LDR R9, [R0, #21]
; DCD8:       43000014         B L58
; DCDC: L53:  5F0000F1         CMP NL2, #0
; DCE0:       8C080054         BGT L59
; DCE4:       8906038B         ADD TMP, R8, NL3, LSL #1
; DCE8:       211140B8         LDR WNL1, [TMP, #1]
; DCEC:       20925FF8         LDR NL0, [R7, #-7]
; DCF0:       1F0003EB         CMP NL0, NL3
; DCF4:       09390054         BLS L117
; DCF8:       290A038B         ADD TMP, R7, NL3, LSL #2
; DCFC:       2C1140F8         LDR R2, [TMP, #1]
; DD00:       ED030CAA         MOV R3, R2
; DD04:       20F87FD3         LSL NL0, NL1, #1
; DD08:       9F0000EB         CMP NL4, NL0
; DD0C:       81100054         BNE L66
; DD10:       E0915FF8         LDR NL0, [R5, #-7]
; DD14:       1F0006EB         CMP NL0, NL6
; DD18:       29380054         BLS L118
; DD1C:       E905068B         ADD TMP, R5, NL6, LSL #1
; DD20:       211100B8         STR WNL1, [TMP, #1]
; DD24:       E97B40B2         MOV TMP, #2147483647
; DD28:       3F0009EB         CMP NL1, TMP
; DD2C:       61000054         BNE L54
; DD30:       9F011DEB         CMP R2, NULL
; DD34:       E00E0054         BEQ L65
; DD38: L54:  9F011DEB         CMP R2, NULL
; DD3C:       C00B0054         BEQ L64
; DD40:       532300F9         STR R9, [CFP, #64]
; DD44:       4D3F00F9         STR R3, [CFP, #120]
; DD48:       460F06A9         STP NL6, NL3, [CFP, #96]
; DD4C:       544305A9         STP R8, R6, [CFP, #80]
; DD50:       4C4B00F9         STR R2, [CFP, #144]
; DD54:       513F08A9         STP R7, R5, [CFP, #128]
; DD58:       442700F9         STR NL4, [CFP, #72]
; DD5C:       7A0300F9         STR CFP, [CSP]
; DD60:       EA030DAA         MOV R0, R3
; DD64:       EB0313AA         MOV R1, R9
; DD68:       969FFF58         LDR LEXENV, #x700D72D158       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; DD6C:       970080D2         MOVZ NARGS, #4
; DD70:       580B00F9         STR NFP, [CFP, #16]
; DD74:       FA031BAA         MOV CFP, CSP
; DD78:       DE9240F8         LDR LR, [LEXENV, #9]
; DD7C:       C0033FD6         BLR LR
; DD80:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; DD84:       580B40F9         LDR NFP, [CFP, #16]
; DD88:       442740F9         LDR NL4, [CFP, #72]
; DD8C:       513F48A9         LDP R7, R5, [CFP, #128]
; DD90:       4C4B40F9         LDR R2, [CFP, #144]
; DD94:       544345A9         LDP R8, R6, [CFP, #80]
; DD98:       460F46A9         LDP NL6, NL3, [CFP, #96]
; DD9C:       4D3F40F9         LDR R3, [CFP, #120]
; DDA0:       532340F9         LDR R9, [CFP, #64]
; DDA4:       5F011DEB         CMP R0, NULL
; DDA8:       60080054         BEQ L64
; DDAC: L55:  EA030CAA         MOV R0, R2
; DDB0: L56:  00925FF8         LDR NL0, [R6, #-7]
; DDB4:       1F0006EB         CMP NL0, NL6
; DDB8:       69330054         BLS L119
; DDBC:       010A068B         ADD NL1, R6, NL6, LSL #2
; DDC0:       21040091         ADD NL1, NL1, #1
; DDC4:       29784BD3         UBFM TMP, NL1, #11, #30
; DDC8:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DDCC:       2A0000F9         STR R0, [NL1]
; DDD0:       60080091         ADD NL0, NL3, #2
; DDD4:       E30300AA         MOV NL3, NL0
; DDD8:       420080D2         MOVZ NL2, #2
; DDDC: L57:  C0080091         ADD NL0, NL6, #2
; DDE0:       E60300AA         MOV NL6, NL0
; DDE4: L58:  80925FF8         LDR NL0, [R8, #-7]
; DDE8:       7F0000EB         CMP NL3, NL0
; DDEC:       8BF7FF54         BLT L53
; DDF0: L59:  19000014         B L61
; DDF4: L60:  8906038B         ADD TMP, R8, NL3, LSL #1
; DDF8:       211140B8         LDR WNL1, [TMP, #1]
; DDFC:       E0915FF8         LDR NL0, [R5, #-7]
; DE00:       1F0006EB         CMP NL0, NL6
; DE04:       49310054         BLS L120
; DE08:       E905068B         ADD TMP, R5, NL6, LSL #1
; DE0C:       211100B8         STR WNL1, [TMP, #1]
; DE10:       20925FF8         LDR NL0, [R7, #-7]
; DE14:       1F0003EB         CMP NL0, NL3
; DE18:       E9300054         BLS L121
; DE1C:       290A038B         ADD TMP, R7, NL3, LSL #2
; DE20:       2A1140F8         LDR R0, [TMP, #1]
; DE24:       00925FF8         LDR NL0, [R6, #-7]
; DE28:       1F0006EB         CMP NL0, NL6
; DE2C:       89300054         BLS L122
; DE30:       010A068B         ADD NL1, R6, NL6, LSL #2
; DE34:       21040091         ADD NL1, NL1, #1
; DE38:       29784BD3         UBFM TMP, NL1, #11, #30
; DE3C:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DE40:       2A0000F9         STR R0, [NL1]
; DE44:       60080091         ADD NL0, NL3, #2
; DE48:       E30300AA         MOV NL3, NL0
; DE4C:       C0080091         ADD NL0, NL6, #2
; DE50:       E60300AA         MOV NL6, NL0
; DE54: L61:  80925FF8         LDR NL0, [R8, #-7]
; DE58:       7F0000EB         CMP NL3, NL0
; DE5C:       CBFCFF54         BLT L60
; DE60:       12000014         B L63
; DE64: L62:  E0915FF8         LDR NL0, [R5, #-7]
; DE68:       1F0006EB         CMP NL0, NL6
; DE6C:       C92E0054         BLS L123
; DE70:       80FC4193         ASR NL0, NL4, #1
; DE74:       E905068B         ADD TMP, R5, NL6, LSL #1
; DE78:       201100B8         STR WNL0, [TMP, #1]
; DE7C:       00925FF8         LDR NL0, [R6, #-7]
; DE80:       1F0006EB         CMP NL0, NL6
; DE84:       492E0054         BLS L124
; DE88:       010A068B         ADD NL1, R6, NL6, LSL #2
; DE8C:       21040091         ADD NL1, NL1, #1
; DE90:       29784BD3         UBFM TMP, NL1, #11, #30
; DE94:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DE98:       330000F9         STR R9, [NL1]
; DE9C:       420080D2         MOVZ NL2, #2
; DEA0:       C0080091         ADD NL0, NL6, #2
; DEA4:       E60300AA         MOV NL6, NL0
; DEA8: L63:  5F0000F1         CMP NL2, #0
; DEAC:       CDFDFF54         BLE L62
; DEB0:       B1FDFF17         B L13
; DEB4: L64:  532300F9         STR R9, [CFP, #64]
; DEB8:       544305A9         STP R8, R6, [CFP, #80]
; DEBC:       460F06A9         STP NL6, NL3, [CFP, #96]
; DEC0:       442700F9         STR NL4, [CFP, #72]
; DEC4:       513F08A9         STP R7, R5, [CFP, #128]
; DEC8:       7A0300F9         STR CFP, [CSP]
; DECC:       EA030DAA         MOV R0, R3
; DED0:       EB0313AA         MOV R1, R9
; DED4:       4CB742A9         LDP R2, R3, [CFP, #40]
; DED8:       9695FF58         LDR LEXENV, #x700D72D188       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:MERGE-CONTEXTS>
; DEDC:       170180D2         MOVZ NARGS, #8
; DEE0:       580B00F9         STR NFP, [CFP, #16]
; DEE4:       FA031BAA         MOV CFP, CSP
; DEE8:       DE9240F8         LDR LR, [LEXENV, #9]
; DEEC:       C0033FD6         BLR LR
; DEF0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; DEF4:       580B40F9         LDR NFP, [CFP, #16]
; DEF8:       513F48A9         LDP R7, R5, [CFP, #128]
; DEFC:       442740F9         LDR NL4, [CFP, #72]
; DF00:       460F46A9         LDP NL6, NL3, [CFP, #96]
; DF04:       544345A9         LDP R8, R6, [CFP, #80]
; DF08:       532340F9         LDR R9, [CFP, #64]
; DF0C:       A9FFFF17         B L56
; DF10: L65:  7F021DEB         CMP R9, NULL
; DF14:       C0F4FF54         BEQ L55
; DF18:       88FFFF17         B L54
; DF1C: L66:  20F87FD3         LSL NL0, NL1, #1
; DF20:       1F0004EB         CMP NL0, NL4
; DF24:       2B020054         BLT L67
; DF28:       E0915FF8         LDR NL0, [R5, #-7]
; DF2C:       1F0006EB         CMP NL0, NL6
; DF30:       29290054         BLS L125
; DF34:       80FC4193         ASR NL0, NL4, #1
; DF38:       E905068B         ADD TMP, R5, NL6, LSL #1
; DF3C:       201100B8         STR WNL0, [TMP, #1]
; DF40:       00925FF8         LDR NL0, [R6, #-7]
; DF44:       1F0006EB         CMP NL0, NL6
; DF48:       A9280054         BLS L126
; DF4C:       010A068B         ADD NL1, R6, NL6, LSL #2
; DF50:       21040091         ADD NL1, NL1, #1
; DF54:       29784BD3         UBFM TMP, NL1, #11, #30
; DF58:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DF5C:       330000F9         STR R9, [NL1]
; DF60:       420080D2         MOVZ NL2, #2
; DF64:       9EFFFF17         B L57
; DF68: L67:  E0915FF8         LDR NL0, [R5, #-7]
; DF6C:       1F0006EB         CMP NL0, NL6
; DF70:       A9270054         BLS L127
; DF74:       E905068B         ADD TMP, R5, NL6, LSL #1
; DF78:       211100B8         STR WNL1, [TMP, #1]
; DF7C:       00925FF8         LDR NL0, [R6, #-7]
; DF80:       1F0006EB         CMP NL0, NL6
; DF84:       49270054         BLS L128
; DF88:       010A068B         ADD NL1, R6, NL6, LSL #2
; DF8C:       21040091         ADD NL1, NL1, #1
; DF90:       29784BD3         UBFM TMP, NL1, #11, #30
; DF94:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; DF98:       2C0000F9         STR R2, [NL1]
; DF9C:       60080091         ADD NL0, NL3, #2
; DFA0:       E30300AA         MOV NL3, NL0
; DFA4:       8EFFFF17         B L57
; DFA8: L68:  4A1340F9         LDR R0, [CFP, #32]
; DFAC:       4A5141F8         LDR R0, [R0, #21]
; DFB0:       4B1340F9         LDR R1, [CFP, #32]
; DFB4:       73D141F8         LDR R9, [R1, #29]
; DFB8:       4A2300F9         STR R0, [CFP, #64]
; DFBC:       50000014         B L74
; DFC0: L69:  4A2340F9         LDR R0, [CFP, #64]
; DFC4:       40915FF8         LDR NL0, [R0, #-7]
; DFC8:       5F0000EB         CMP NL2, NL0
; DFCC:       EA090054         BGE L75
; DFD0:       8906038B         ADD TMP, R8, NL3, LSL #1
; DFD4:       241140B8         LDR WNL4, [TMP, #1]
; DFD8:       4A2340F9         LDR R0, [CFP, #64]
; DFDC:       4905028B         ADD TMP, R0, NL2, LSL #1
; DFE0:       251140B8         LDR WNL5, [TMP, #1]
; DFE4:       A0F87FD3         LSL NL0, NL5, #1
; DFE8:       21925FF8         LDR NL1, [R7, #-7]
; DFEC:       3F0003EB         CMP NL1, NL3
; DFF0:       29240054         BLS L129
; DFF4:       290A038B         ADD TMP, R7, NL3, LSL #2
; DFF8:       2C1140F8         LDR R2, [TMP, #1]
; DFFC:       61925FF8         LDR NL1, [R9, #-7]
; E000:       3F0002EB         CMP NL1, NL2
; E004:       C9230054         BLS L130
; E008:       690A028B         ADD TMP, R9, NL2, LSL #2
; E00C:       2A1140F8         LDR R0, [TMP, #1]
; E010:       ED030CAA         MOV R3, R2
; E014:       4A2700F9         STR R0, [CFP, #72]
; E018:       81F87FD3         LSL NL1, NL4, #1
; E01C:       1F0001EB         CMP NL0, NL1
; E020:       A1110054         BNE L82
; E024:       E0915FF8         LDR NL0, [R5, #-7]
; E028:       1F0006EB         CMP NL0, NL6
; E02C:       C9220054         BLS L131
; E030:       E905068B         ADD TMP, R5, NL6, LSL #1
; E034:       241100B8         STR WNL4, [TMP, #1]
; E038:       E97B40B2         MOV TMP, #2147483647
; E03C:       9F0009EB         CMP NL4, TMP
; E040:       61000054         BNE L70
; E044:       9F011DEB         CMP R2, NULL
; E048:       00100054         BEQ L81
; E04C: L70:  9F011DEB         CMP R2, NULL
; E050:       200D0054         BEQ L80
; E054:       4D4B00F9         STR R3, [CFP, #144]
; E058:       438B06A9         STP NL3, NL2, [CFP, #104]
; E05C:       509B05A9         STP R6, NL6, [CFP, #88]
; E060:       542B00F9         STR R8, [CFP, #80]
; E064:       4C4F00F9         STR R2, [CFP, #152]
; E068:       513F08A9         STP R7, R5, [CFP, #128]
; E06C:       533F00F9         STR R9, [CFP, #120]
; E070:       7A0300F9         STR CFP, [CSP]
; E074:       EA030DAA         MOV R0, R3
; E078:       4B2740F9         LDR R1, [CFP, #72]
; E07C:       F686FF58         LDR LEXENV, #x700D72D158       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:CONTEXT-EQUAL>
; E080:       970080D2         MOVZ NARGS, #4
; E084:       580B00F9         STR NFP, [CFP, #16]
; E088:       FA031BAA         MOV CFP, CSP
; E08C:       DE9240F8         LDR LR, [LEXENV, #9]
; E090:       C0033FD6         BLR LR
; E094:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; E098:       580B40F9         LDR NFP, [CFP, #16]
; E09C:       53C747A9         LDP R9, R7, [CFP, #120]
; E0A0:       4F4740F9         LDR R5, [CFP, #136]
; E0A4:       4C4F40F9         LDR R2, [CFP, #152]
; E0A8:       544345A9         LDP R8, R6, [CFP, #80]
; E0AC:       460F46A9         LDP NL6, NL3, [CFP, #96]
; E0B0:       423B40F9         LDR NL2, [CFP, #112]
; E0B4:       4D4B40F9         LDR R3, [CFP, #144]
; E0B8:       5F011DEB         CMP R0, NULL
; E0BC:       C0090054         BEQ L80
; E0C0: L71:  EA030CAA         MOV R0, R2
; E0C4: L72:  00925FF8         LDR NL0, [R6, #-7]
; E0C8:       1F0006EB         CMP NL0, NL6
; E0CC:       091E0054         BLS L132
; E0D0:       010A068B         ADD NL1, R6, NL6, LSL #2
; E0D4:       21040091         ADD NL1, NL1, #1
; E0D8:       29784BD3         UBFM TMP, NL1, #11, #30
; E0DC:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; E0E0:       2A0000F9         STR R0, [NL1]
; E0E4:       60080091         ADD NL0, NL3, #2
; E0E8:       E30300AA         MOV NL3, NL0
; E0EC:       40080091         ADD NL0, NL2, #2
; E0F0:       E20300AA         MOV NL2, NL0
; E0F4: L73:  C0080091         ADD NL0, NL6, #2
; E0F8:       E60300AA         MOV NL6, NL0
; E0FC: L74:  80925FF8         LDR NL0, [R8, #-7]
; E100:       7F0000EB         CMP NL3, NL0
; E104:       EBF5FF54         BLT L69
; E108: L75:  19000014         B L77
; E10C: L76:  8906038B         ADD TMP, R8, NL3, LSL #1
; E110:       211140B8         LDR WNL1, [TMP, #1]
; E114:       E0915FF8         LDR NL0, [R5, #-7]
; E118:       1F0006EB         CMP NL0, NL6
; E11C:       C91B0054         BLS L133
; E120:       E905068B         ADD TMP, R5, NL6, LSL #1
; E124:       211100B8         STR WNL1, [TMP, #1]
; E128:       20925FF8         LDR NL0, [R7, #-7]
; E12C:       1F0003EB         CMP NL0, NL3
; E130:       691B0054         BLS L134
; E134:       290A038B         ADD TMP, R7, NL3, LSL #2
; E138:       2A1140F8         LDR R0, [TMP, #1]
; E13C:       00925FF8         LDR NL0, [R6, #-7]
; E140:       1F0006EB         CMP NL0, NL6
; E144:       091B0054         BLS L135
; E148:       010A068B         ADD NL1, R6, NL6, LSL #2
; E14C:       21040091         ADD NL1, NL1, #1
; E150:       29784BD3         UBFM TMP, NL1, #11, #30
; E154:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; E158:       2A0000F9         STR R0, [NL1]
; E15C:       60080091         ADD NL0, NL3, #2
; E160:       E30300AA         MOV NL3, NL0
; E164:       C0080091         ADD NL0, NL6, #2
; E168:       E60300AA         MOV NL6, NL0
; E16C: L77:  80925FF8         LDR NL0, [R8, #-7]
; E170:       7F0000EB         CMP NL3, NL0
; E174:       CBFCFF54         BLT L76
; E178:       1A000014         B L79
; E17C: L78:  4A2340F9         LDR R0, [CFP, #64]
; E180:       4905028B         ADD TMP, R0, NL2, LSL #1
; E184:       211140B8         LDR WNL1, [TMP, #1]
; E188:       E0915FF8         LDR NL0, [R5, #-7]
; E18C:       1F0006EB         CMP NL0, NL6
; E190:       E9180054         BLS L136
; E194:       E905068B         ADD TMP, R5, NL6, LSL #1
; E198:       211100B8         STR WNL1, [TMP, #1]
; E19C:       60925FF8         LDR NL0, [R9, #-7]
; E1A0:       1F0002EB         CMP NL0, NL2
; E1A4:       89180054         BLS L137
; E1A8:       690A028B         ADD TMP, R9, NL2, LSL #2
; E1AC:       2A1140F8         LDR R0, [TMP, #1]
; E1B0:       00925FF8         LDR NL0, [R6, #-7]
; E1B4:       1F0006EB         CMP NL0, NL6
; E1B8:       29180054         BLS L138
; E1BC:       010A068B         ADD NL1, R6, NL6, LSL #2
; E1C0:       21040091         ADD NL1, NL1, #1
; E1C4:       29784BD3         UBFM TMP, NL1, #11, #30
; E1C8:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; E1CC:       2A0000F9         STR R0, [NL1]
; E1D0:       40080091         ADD NL0, NL2, #2
; E1D4:       E20300AA         MOV NL2, NL0
; E1D8:       C0080091         ADD NL0, NL6, #2
; E1DC:       E60300AA         MOV NL6, NL0
; E1E0: L79:  4A2340F9         LDR R0, [CFP, #64]
; E1E4:       40915FF8         LDR NL0, [R0, #-7]
; E1E8:       5F0000EB         CMP NL2, NL0
; E1EC:       8BFCFF54         BLT L78
; E1F0:       E1FCFF17         B L13
; E1F4: L80:  544305A9         STP R8, R6, [CFP, #80]
; E1F8:       460F06A9         STP NL6, NL3, [CFP, #96]
; E1FC:       424F07A9         STP NL2, R9, [CFP, #112]
; E200:       513F08A9         STP R7, R5, [CFP, #128]
; E204:       7A0300F9         STR CFP, [CSP]
; E208:       EA030DAA         MOV R0, R3
; E20C:       4B2740F9         LDR R1, [CFP, #72]
; E210:       4CB742A9         LDP R2, R3, [CFP, #40]
; E214:       B67BFF58         LDR LEXENV, #x700D72D188       ; #<SB-KERNEL:FDEFN CNVRS/RUNTIME:MERGE-CONTEXTS>
; E218:       170180D2         MOVZ NARGS, #8
; E21C:       580B00F9         STR NFP, [CFP, #16]
; E220:       FA031BAA         MOV CFP, CSP
; E224:       DE9240F8         LDR LR, [LEXENV, #9]
; E228:       C0033FD6         BLR LR
; E22C:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; E230:       580B40F9         LDR NFP, [CFP, #16]
; E234:       513F48A9         LDP R7, R5, [CFP, #128]
; E238:       424F47A9         LDP NL2, R9, [CFP, #112]
; E23C:       460F46A9         LDP NL6, NL3, [CFP, #96]
; E240:       544345A9         LDP R8, R6, [CFP, #80]
; E244:       A0FFFF17         B L72
; E248: L81:  5F011DEB         CMP R0, NULL
; E24C:       A0F3FF54         BEQ L71
; E250:       7FFFFF17         B L70
; E254: L82:  81F87FD3         LSL NL1, NL4, #1
; E258:       3F0000EB         CMP NL1, NL0
; E25C:       4B020054         BLT L83
; E260:       E0915FF8         LDR NL0, [R5, #-7]
; E264:       1F0006EB         CMP NL0, NL6
; E268:       E9120054         BLS L139
; E26C:       E00305AA         MOV NL0, NL5
; E270:       E905068B         ADD TMP, R5, NL6, LSL #1
; E274:       201100B8         STR WNL0, [TMP, #1]
; E278:       00925FF8         LDR NL0, [R6, #-7]
; E27C:       1F0006EB         CMP NL0, NL6
; E280:       69120054         BLS L140
; E284:       010A068B         ADD NL1, R6, NL6, LSL #2
; E288:       21040091         ADD NL1, NL1, #1
; E28C:       29784BD3         UBFM TMP, NL1, #11, #30
; E290:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; E294:       2A0000F9         STR R0, [NL1]
; E298:       40080091         ADD NL0, NL2, #2
; E29C:       E20300AA         MOV NL2, NL0
; E2A0:       95FFFF17         B L73
; E2A4: L83:  E0915FF8         LDR NL0, [R5, #-7]
; E2A8:       1F0006EB         CMP NL0, NL6
; E2AC:       49110054         BLS L141
; E2B0:       E905068B         ADD TMP, R5, NL6, LSL #1
; E2B4:       241100B8         STR WNL4, [TMP, #1]
; E2B8:       00925FF8         LDR NL0, [R6, #-7]
; E2BC:       1F0006EB         CMP NL0, NL6
; E2C0:       E9100054         BLS L142
; E2C4:       010A068B         ADD NL1, R6, NL6, LSL #2
; E2C8:       21040091         ADD NL1, NL1, #1
; E2CC:       29784BD3         UBFM TMP, NL1, #11, #30
; E2D0:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; E2D4:       2C0000F9         STR R2, [NL1]
; E2D8:       60080091         ADD NL0, NL3, #2
; E2DC:       E30300AA         MOV NL3, NL0
; E2E0:       85FFFF17         B L73
; E2E4: L84:  600320D4         BRK #27                        ; OBJECT-NOT-TYPE-ERROR
                                                              ; NL0
; E2E8:       4F               BYTE #X4F                      ; '(MOD
                                                              ;   1152921504606846973)
; E2E9:       .ALIGN           4
; E2EC: L85:  604320D4         BRK #539                       ; OBJECT-NOT-TYPE-ERROR
                                                              ; NL2
; E2F0:       4F               BYTE #X4F                      ; '(MOD
                                                              ;   1152921504606846973)
; E2F1:       .ALIGN           4
; E2F4: L86:  A01420D4         BRK #165                       ; OBJECT-NOT-INDEX-OR-LIST-ERROR
                                                              ; NL0
; E2F8: L87:  A08A28D4         BRK #17493                     ; OBJECT-NOT-FIXNUM-ERROR
                                                              ; NL4
; E2FC: L88:  449145B8         LDR WNL4, [R0, #89]
; E300:       C176FF18         LDR WNL1, #x700D72D1D8
; E304:       9F00016B         CMP WNL4, WNL1
; E308:       A1000054         BNE L89
; E30C:       4A1340F9         LDR R0, [CFP, #32]
; E310:       4A5141F8         LDR R0, [R0, #21]
; E314:       41915FF8         LDR NL1, [R0, #-7]
; E318:       00FCFF17         B L1
; E31C: L89:  4A1340F9         LDR R0, [CFP, #32]
; E320:       A04321D4         BRK #2589                      ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; E324:       53               BYTE #X53                      ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; E325:       .ALIGN           4
; E328: L90:  4A0F40F9         LDR R0, [CFP, #24]
; E32C:       A04321D4         BRK #2589                      ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; E330:       53               BYTE #X53                      ; '(CNVRS/RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/RUNTIME::ARRAY-PREDICTION-CONTEXT)
; E331:       .ALIGN           4
; E334: L91:  400080D2         MOVZ NL0, #2
; E338:       F1FBFF17         B L0
; E33C: L92:  1F430091         ADD NSP, NFP, #16
; E340:       FB031AAA         MOV CSP, CFP
; E344:       5A7B40A9         LDP CFP, LR, [CFP]
; E348:       BF0300F1         CMP NULL, #0
; E34C:       C0035FD6         RET
; E350:       E00120D4         BRK #15                        ; Invalid argument count trap
; E354: L93:  20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E358:       19               BYTE #X19                      ; NL6
; E359:       .ALIGN           4
; E35C: L94:  200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E360:       19               BYTE #X19                      ; NL6
; E361:       .ALIGN           4
; E364: L95:  20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E368:       19               BYTE #X19                      ; NL6
; E369:       .ALIGN           4
; E36C: L96:  200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E370:       19               BYTE #X19                      ; NL6
; E371:       .ALIGN           4
; E374: L97:  20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E378:       19               BYTE #X19                      ; NL6
; E379:       .ALIGN           4
; E37C: L98:  200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E380:       19               BYTE #X19                      ; NL6
; E381:       .ALIGN           4
; E384: L99:  200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E388:       80808004         BYTE #X80, #X80, #X80, #X04    ; 0
; E38C: L100: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E390:       80808004         BYTE #X80, #X80, #X80, #X04    ; 0
; E394: L101: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E398:       19               BYTE #X19                      ; NL6
; E399:       .ALIGN           4
; E39C: L102: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E3A0:       19               BYTE #X19                      ; NL6
; E3A1:       .ALIGN           4
; E3A4: L103: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E3A8:       19               BYTE #X19                      ; NL6
; E3A9:       .ALIGN           4
; E3AC: L104: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E3B0:       19               BYTE #X19                      ; NL6
; E3B1:       .ALIGN           4
; E3B4: L105: 206422D4         BRK #4897                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R9
; E3B8:       09               BYTE #X09                      ; NL2
; E3B9:       .ALIGN           4
; E3BC: L106: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E3C0:       19               BYTE #X19                      ; NL6
; E3C1:       .ALIGN           4
; E3C4: L107: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E3C8:       19               BYTE #X19                      ; NL6
; E3C9:       .ALIGN           4
; E3CC: L108: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E3D0:       19               BYTE #X19                      ; NL6
; E3D1:       .ALIGN           4
; E3D4: L109: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E3D8:       19               BYTE #X19                      ; NL6
; E3D9:       .ALIGN           4
; E3DC: L110: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E3E0:       19               BYTE #X19                      ; NL6
; E3E1:       .ALIGN           4
; E3E4: L111: 206422D4         BRK #4897                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R9
; E3E8:       09               BYTE #X09                      ; NL2
; E3E9:       .ALIGN           4
; E3EC: L112: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E3F0:       19               BYTE #X19                      ; NL6
; E3F1:       .ALIGN           4
; E3F4: L113: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E3F8:       19               BYTE #X19                      ; NL6
; E3F9:       .ALIGN           4
; E3FC: L114: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E400:       19               BYTE #X19                      ; NL6
; E401:       .ALIGN           4
; E404: L115: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E408:       19               BYTE #X19                      ; NL6
; E409:       .ALIGN           4
; E40C: L116: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E410:       19               BYTE #X19                      ; NL6
; E411:       .ALIGN           4
; E414: L117: 202422D4         BRK #4385                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R7
; E418:       0D               BYTE #X0D                      ; NL3
; E419:       .ALIGN           4
; E41C: L118: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E420:       19               BYTE #X19                      ; NL6
; E421:       .ALIGN           4
; E424: L119: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E428:       19               BYTE #X19                      ; NL6
; E429:       .ALIGN           4
; E42C: L120: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E430:       19               BYTE #X19                      ; NL6
; E431:       .ALIGN           4
; E434: L121: 202422D4         BRK #4385                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R7
; E438:       0D               BYTE #X0D                      ; NL3
; E439:       .ALIGN           4
; E43C: L122: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E440:       19               BYTE #X19                      ; NL6
; E441:       .ALIGN           4
; E444: L123: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E448:       19               BYTE #X19                      ; NL6
; E449:       .ALIGN           4
; E44C: L124: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E450:       19               BYTE #X19                      ; NL6
; E451:       .ALIGN           4
; E454: L125: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E458:       19               BYTE #X19                      ; NL6
; E459:       .ALIGN           4
; E45C: L126: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E460:       19               BYTE #X19                      ; NL6
; E461:       .ALIGN           4
; E464: L127: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E468:       19               BYTE #X19                      ; NL6
; E469:       .ALIGN           4
; E46C: L128: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E470:       19               BYTE #X19                      ; NL6
; E471:       .ALIGN           4
; E474: L129: 202422D4         BRK #4385                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R7
; E478:       0D               BYTE #X0D                      ; NL3
; E479:       .ALIGN           4
; E47C: L130: 206422D4         BRK #4897                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R9
; E480:       09               BYTE #X09                      ; NL2
; E481:       .ALIGN           4
; E484: L131: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E488:       19               BYTE #X19                      ; NL6
; E489:       .ALIGN           4
; E48C: L132: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E490:       19               BYTE #X19                      ; NL6
; E491:       .ALIGN           4
; E494: L133: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E498:       19               BYTE #X19                      ; NL6
; E499:       .ALIGN           4
; E49C: L134: 202422D4         BRK #4385                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R7
; E4A0:       0D               BYTE #X0D                      ; NL3
; E4A1:       .ALIGN           4
; E4A4: L135: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E4A8:       19               BYTE #X19                      ; NL6
; E4A9:       .ALIGN           4
; E4AC: L136: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E4B0:       19               BYTE #X19                      ; NL6
; E4B1:       .ALIGN           4
; E4B4: L137: 206422D4         BRK #4897                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R9
; E4B8:       09               BYTE #X09                      ; NL2
; E4B9:       .ALIGN           4
; E4BC: L138: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E4C0:       19               BYTE #X19                      ; NL6
; E4C1:       .ALIGN           4
; E4C4: L139: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E4C8:       19               BYTE #X19                      ; NL6
; E4C9:       .ALIGN           4
; E4CC: L140: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E4D0:       19               BYTE #X19                      ; NL6
; E4D1:       .ALIGN           4
; E4D4: L141: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; E4D8:       19               BYTE #X19                      ; NL6
; E4D9:       .ALIGN           4
; E4DC: L142: 200422D4         BRK #4129                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R6
; E4E0:       19               BYTE #X19                      ; NL6
; E4E1:       .ALIGN           4
