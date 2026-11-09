; disassembly for CNVRS/ANTLR-RUNTIME::MERGE-ARRAYS
; Size: 4236 bytes. Origin: #x700A99838C                      ; CNVRS/ANTLR-RUNTIME::MERGE-ARRAYS
; 838C:       7A0300F9         STR CFP, [CSP]
; 8390:       4A1B40F9         LDR R0, [CFP, #48]
; 8394:       4BB341A9         LDP R1, R2, [CFP, #24]
; 8398:       4D1740F9         LDR R3, [CFP, #40]
; 839C:       36F9FF58         LDR LEXENV, #x700A9982C0       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::MERGE-CACHE-GET>
; 83A0:       170180D2         MOVZ NARGS, #8
; 83A4:       FA031BAA         MOV CFP, CSP
; 83A8:       DE9240F8         LDR LR, [LEXENV, #9]
; 83AC:       C0033FD6         BLR LR
; 83B0:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 83B4:       5F011DEB         CMP R0, NULL
; 83B8:       21790054         BNE L121
; 83BC:       4A0F40F9         LDR R0, [CFP, #24]
; 83C0:       490D4092         AND TMP, R0, #15
; 83C4:       3F0D00F1         CMP TMP, #3
; 83C8:       01780054         BNE L119
; 83CC:       4A5140F8         LDR R0, [R0, #5]
; 83D0:       449145B8         LDR WNL4, [R0, #89]
; 83D4:       21FCFF18         LDR WNL1, #x700A998358
; 83D8:       9F00016B         CMP WNL4, WNL1
; 83DC:       C0770054         BEQ L120
; 83E0:       449145B8         LDR WNL4, [R0, #89]
; 83E4:       C1FBFF18         LDR WNL1, #x700A99835C
; 83E8:       9F00016B         CMP WNL4, WNL1
; 83EC:       E1760054         BNE L119
; 83F0:       4A0F40F9         LDR R0, [CFP, #24]
; 83F4:       4A5141F8         LDR R0, [R0, #21]
; 83F8:       40915FF8         LDR NL0, [R0, #-7]
; 83FC: L0:   4A1340F9         LDR R0, [CFP, #32]
; 8400:       490D4092         AND TMP, R0, #15
; 8404:       3F0D00F1         CMP TMP, #3
; 8408:       A1750054         BNE L118
; 840C:       4A5140F8         LDR R0, [R0, #5]
; 8410:       449145B8         LDR WNL4, [R0, #89]
; 8414:       21FAFF18         LDR WNL1, #x700A998358
; 8418:       9F00016B         CMP WNL4, WNL1
; 841C:       01740054         BNE L117
; 8420:       410080D2         MOVZ NL1, #2
; 8424: L1:   050080D2         MOVZ NL5, #0
; 8428:       5FF703A9         STP ZR, NULL, [CFP, #56]
; 842C:       5D8304A9         STP NULL, NL0, [CFP, #72]
; 8430:       412F00F9         STR NL1, [CFP, #88]
; 8434:       6B010014         B L52
; 8438: L2:   401F40F9         LDR NL0, [CFP, #56]
; 843C:       412F40F9         LDR NL1, [CFP, #88]
; 8440:       1F0001EB         CMP NL0, NL1
; 8444:       4A2D0054         BGE L53
; 8448:       E20305AA         MOV NL2, NL5
; 844C:       4A0F40F9         LDR R0, [CFP, #24]
; 8450:       4E5140F8         LDR R4, [R0, #5]
; 8454:       C49145B8         LDR WNL4, [R4, #89]
; 8458:       01F8FF18         LDR WNL1, #x700A998358
; 845C:       9F00016B         CMP WNL4, WNL1
; 8460:       60710054         BEQ L116
; 8464:       4A0F40F9         LDR R0, [CFP, #24]
; 8468:       4A5141F8         LDR R0, [R0, #21]
; 846C:       40915FF8         LDR NL0, [R0, #-7]
; 8470:       1F0005EB         CMP NL0, NL5
; 8474:       E9730054         BLS L122
; 8478:       4909058B         ADD TMP, R0, NL5, LSL #2
; 847C:       2A1140F8         LDR R0, [TMP, #1]
; 8480:       5F7D5FF2         TST R0, #18446744065119617025
; 8484:       A16E0054         BNE L114
; 8488:       E3030AAA         MOV NL3, R0
; 848C: L3:   421F40F9         LDR NL2, [CFP, #56]
; 8490:       4A1340F9         LDR R0, [CFP, #32]
; 8494:       4E5140F8         LDR R4, [R0, #5]
; 8498:       C49145B8         LDR WNL4, [R4, #89]
; 849C:       E1F5FF18         LDR WNL1, #x700A998358
; 84A0:       9F00016B         CMP WNL4, WNL1
; 84A4:       216C0054         BNE L113
; 84A8:       0F000014         B L5
; 84AC: L4:   421706A9         STP NL2, NL5, [CFP, #96]
; 84B0:       433B00F9         STR NL3, [CFP, #112]
; 84B4:       7A0300F9         STR CFP, [CSP]
; 84B8:       CAF2FF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 84BC:       4B0080D2         MOVZ R1, #2
; 84C0:       CCF2FF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 84C4:       ED0302AA         MOV R3, NL2
; 84C8:       16F0FF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 84CC:       170180D2         MOVZ NARGS, #8
; 84D0:       FA031BAA         MOV CFP, CSP
; 84D4:       DE9240F8         LDR LR, [LEXENV, #9]
; 84D8:       C0033FD6         BLR LR
; 84DC:       458F46A9         LDP NL5, NL3, [CFP, #104]
; 84E0:       423340F9         LDR NL2, [CFP, #96]
; 84E4: L5:   42FEFFB5         CBNZ NL2, L4
; 84E8:       4A1340F9         LDR R0, [CFP, #32]
; 84EC:       4AD141F8         LDR R0, [R0, #29]
; 84F0: L6:   5F0103EB         CMP R0, NL3
; 84F4:       20100054         BEQ L23
; 84F8:       E20305AA         MOV NL2, NL5
; 84FC:       4A0F40F9         LDR R0, [CFP, #24]
; 8500:       4E5140F8         LDR R4, [R0, #5]
; 8504:       C49145B8         LDR WNL4, [R4, #89]
; 8508:       81F2FF18         LDR WNL1, #x700A998358
; 850C:       9F00016B         CMP WNL4, WNL1
; 8510:       41670054         BNE L111
; 8514:       0D000014         B L8
; 8518: L7:   421706A9         STP NL2, NL5, [CFP, #96]
; 851C:       7A0300F9         STR CFP, [CSP]
; 8520:       8AEFFF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 8524:       4B0080D2         MOVZ R1, #2
; 8528:       8CEFFF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 852C:       ED0302AA         MOV R3, NL2
; 8530:       D6ECFF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 8534:       170180D2         MOVZ NARGS, #8
; 8538:       FA031BAA         MOV CFP, CSP
; 853C:       DE9240F8         LDR LR, [LEXENV, #9]
; 8540:       C0033FD6         BLR LR
; 8544:       421746A9         LDP NL2, NL5, [CFP, #96]
; 8548: L8:   82FEFFB5         CBNZ NL2, L7
; 854C:       4A0F40F9         LDR R0, [CFP, #24]
; 8550:       43D141F8         LDR NL3, [R0, #29]
; 8554: L9:   421F40F9         LDR NL2, [CFP, #56]
; 8558:       4A1340F9         LDR R0, [CFP, #32]
; 855C:       4E5140F8         LDR R4, [R0, #5]
; 8560:       C49145B8         LDR WNL4, [R4, #89]
; 8564:       A1EFFF18         LDR WNL1, #x700A998358
; 8568:       9F00016B         CMP WNL4, WNL1
; 856C:       E1620054         BNE L110
; 8570:       0F000014         B L11
; 8574: L10:  421706A9         STP NL2, NL5, [CFP, #96]
; 8578:       433B00F9         STR NL3, [CFP, #112]
; 857C:       7A0300F9         STR CFP, [CSP]
; 8580:       8AECFF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 8584:       4B0080D2         MOVZ R1, #2
; 8588:       8CECFF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 858C:       ED0302AA         MOV R3, NL2
; 8590:       D6E9FF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 8594:       170180D2         MOVZ NARGS, #8
; 8598:       FA031BAA         MOV CFP, CSP
; 859C:       DE9240F8         LDR LR, [LEXENV, #9]
; 85A0:       C0033FD6         BLR LR
; 85A4:       458F46A9         LDP NL5, NL3, [CFP, #104]
; 85A8:       423340F9         LDR NL2, [CFP, #96]
; 85AC: L11:  42FEFFB5         CBNZ NL2, L10
; 85B0:       4A1340F9         LDR R0, [CFP, #32]
; 85B4:       4AD141F8         LDR R0, [R0, #29]
; 85B8: L12:  7F000AEB         CMP NL3, R0
; 85BC:       AB170054         BLT L41
; 85C0:       421F40F9         LDR NL2, [CFP, #56]
; 85C4:       4A1340F9         LDR R0, [CFP, #32]
; 85C8:       4E5140F8         LDR R4, [R0, #5]
; 85CC:       C49145B8         LDR WNL4, [R4, #89]
; 85D0:       41ECFF18         LDR WNL1, #x700A998358
; 85D4:       9F00016B         CMP WNL4, WNL1
; 85D8:       015E0054         BNE L109
; 85DC:       0D000014         B L14
; 85E0: L13:  421706A9         STP NL2, NL5, [CFP, #96]
; 85E4:       7A0300F9         STR CFP, [CSP]
; 85E8:       4AE9FF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 85EC:       4B0080D2         MOVZ R1, #2
; 85F0:       4CE9FF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 85F4:       ED0302AA         MOV R3, NL2
; 85F8:       96E6FF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 85FC:       170180D2         MOVZ NARGS, #8
; 8600:       FA031BAA         MOV CFP, CSP
; 8604:       DE9240F8         LDR LR, [LEXENV, #9]
; 8608:       C0033FD6         BLR LR
; 860C:       421746A9         LDP NL2, NL5, [CFP, #96]
; 8610: L14:  82FEFFB5         CBNZ NL2, L13
; 8614:       4A1340F9         LDR R0, [CFP, #32]
; 8618:       4AD141F8         LDR R0, [R0, #29]
; 861C: L15:  4B2340F9         LDR R1, [CFP, #64]
; 8620:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 8624:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 8628:       30410091         ADD R6, TMP, #16
; 862C:       1F021EEB         CMP R6, LR
; 8630:       48660054         BHI L123
; 8634:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 8638: L16:  301D0091         ADD R6, TMP, #7
; 863C:       2A2D00A9         STP R0, R1, [TMP]
; 8640:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 8644:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 8648:       5E0000B4         CBZ LR, L17
; 864C:       200120D4         BRK #9                         ; Pending interrupt trap
; 8650: L17:  502300F9         STR R6, [CFP, #64]
; 8654:       421F40F9         LDR NL2, [CFP, #56]
; 8658:       4A1340F9         LDR R0, [CFP, #32]
; 865C:       4E5140F8         LDR R4, [R0, #5]
; 8660:       C49145B8         LDR WNL4, [R4, #89]
; 8664:       A1E7FF18         LDR WNL1, #x700A998358
; 8668:       9F00016B         CMP WNL4, WNL1
; 866C:       21580054         BNE L108
; 8670:       0D000014         B L19
; 8674: L18:  421706A9         STP NL2, NL5, [CFP, #96]
; 8678:       7A0300F9         STR CFP, [CSP]
; 867C:       AAE4FF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 8680:       4B0080D2         MOVZ R1, #2
; 8684:       ACE4FF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 8688:       ED0302AA         MOV R3, NL2
; 868C:       F6E1FF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 8690:       170180D2         MOVZ NARGS, #8
; 8694:       FA031BAA         MOV CFP, CSP
; 8698:       DE9240F8         LDR LR, [LEXENV, #9]
; 869C:       C0033FD6         BLR LR
; 86A0:       421746A9         LDP NL2, NL5, [CFP, #96]
; 86A4: L19:  82FEFFB5         CBNZ NL2, L18
; 86A8:       4A1340F9         LDR R0, [CFP, #32]
; 86AC:       4A5141F8         LDR R0, [R0, #21]
; 86B0: L20:  4B2740F9         LDR R1, [CFP, #72]
; 86B4:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 86B8:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 86BC:       30410091         ADD R6, TMP, #16
; 86C0:       1F021EEB         CMP R6, LR
; 86C4:       28620054         BHI L124
; 86C8:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 86CC: L21:  301D0091         ADD R6, TMP, #7
; 86D0:       2A2D00A9         STP R0, R1, [TMP]
; 86D4:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 86D8:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 86DC:       5E0000B4         CBZ LR, L22
; 86E0:       200120D4         BRK #9                         ; Pending interrupt trap
; 86E4: L22:  502700F9         STR R6, [CFP, #72]
; 86E8:       401F40F9         LDR NL0, [CFP, #56]
; 86EC:       00080091         ADD NL0, NL0, #2
; 86F0:       401F00F9         STR NL0, [CFP, #56]
; 86F4:       BB000014         B L52
; 86F8: L23:  E20305AA         MOV NL2, NL5
; 86FC:       4A0F40F9         LDR R0, [CFP, #24]
; 8700:       4E5140F8         LDR R4, [R0, #5]
; 8704:       C49145B8         LDR WNL4, [R4, #89]
; 8708:       81E2FF18         LDR WNL1, #x700A998358
; 870C:       9F00016B         CMP WNL4, WNL1
; 8710:       C1510054         BNE L107
; 8714:       0D000014         B L25
; 8718: L24:  421706A9         STP NL2, NL5, [CFP, #96]
; 871C:       7A0300F9         STR CFP, [CSP]
; 8720:       8ADFFF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 8724:       4B0080D2         MOVZ R1, #2
; 8728:       8CDFFF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 872C:       ED0302AA         MOV R3, NL2
; 8730:       D6DCFF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 8734:       170180D2         MOVZ NARGS, #8
; 8738:       FA031BAA         MOV CFP, CSP
; 873C:       DE9240F8         LDR LR, [LEXENV, #9]
; 8740:       C0033FD6         BLR LR
; 8744:       421746A9         LDP NL2, NL5, [CFP, #96]
; 8748: L25:  82FEFFB5         CBNZ NL2, L24
; 874C:       4A0F40F9         LDR R0, [CFP, #24]
; 8750:       4AD141F8         LDR R0, [R0, #29]
; 8754: L26:  4A3300F9         STR R0, [CFP, #96]
; 8758:       E20305AA         MOV NL2, NL5
; 875C:       4A0F40F9         LDR R0, [CFP, #24]
; 8760:       4E5140F8         LDR R4, [R0, #5]
; 8764:       C49145B8         LDR WNL4, [R4, #89]
; 8768:       81DFFF18         LDR WNL1, #x700A998358
; 876C:       9F00016B         CMP WNL4, WNL1
; 8770:       C14D0054         BNE L106
; 8774:       0D000014         B L28
; 8778: L27:  458B06A9         STP NL5, NL2, [CFP, #104]
; 877C:       7A0300F9         STR CFP, [CSP]
; 8780:       8ADCFF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 8784:       4B0080D2         MOVZ R1, #2
; 8788:       8CDCFF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 878C:       ED0302AA         MOV R3, NL2
; 8790:       D6D9FF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 8794:       170180D2         MOVZ NARGS, #8
; 8798:       FA031BAA         MOV CFP, CSP
; 879C:       DE9240F8         LDR LR, [LEXENV, #9]
; 87A0:       C0033FD6         BLR LR
; 87A4:       458B46A9         LDP NL5, NL2, [CFP, #104]
; 87A8: L28:  82FEFFB5         CBNZ NL2, L27
; 87AC:       4A0F40F9         LDR R0, [CFP, #24]
; 87B0:       515141F8         LDR R7, [R0, #21]
; 87B4: L29:  421F40F9         LDR NL2, [CFP, #56]
; 87B8:       4A1340F9         LDR R0, [CFP, #32]
; 87BC:       4E5140F8         LDR R4, [R0, #5]
; 87C0:       C49145B8         LDR WNL4, [R4, #89]
; 87C4:       A1DCFF18         LDR WNL1, #x700A998358
; 87C8:       9F00016B         CMP WNL4, WNL1
; 87CC:       604A0054         BEQ L105
; 87D0:       4A1340F9         LDR R0, [CFP, #32]
; 87D4:       4AD141F8         LDR R0, [R0, #29]
; 87D8:       40915FF8         LDR NL0, [R0, #-7]
; 87DC:       411F40F9         LDR NL1, [CFP, #56]
; 87E0:       1F0001EB         CMP NL0, NL1
; 87E4:       A9590054         BLS L125
; 87E8:       401F40F9         LDR NL0, [CFP, #56]
; 87EC:       4909008B         ADD TMP, R0, NL0, LSL #2
; 87F0:       2A1140F8         LDR R0, [TMP, #1]
; 87F4: L30:  ED030AAA         MOV R3, R0
; 87F8:       403340F9         LDR NL0, [CFP, #96]
; 87FC:       E97B7FB2         MOV TMP, #4294967294
; 8800:       1F0009EB         CMP NL0, TMP
; 8804:       20460054         BEQ L103
; 8808: L31:  EC031DAA         MOV R2, NULL
; 880C: L32:  3F021DEB         CMP R7, NULL
; 8810:       81430054         BNE L102
; 8814: L33:  EA031DAA         MOV R0, NULL
; 8818: L34:  4B2340F9         LDR R1, [CFP, #64]
; 881C:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 8820:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 8824:       30410091         ADD R6, TMP, #16
; 8828:       1F021EEB         CMP R6, LR
; 882C:       A8570054         BHI L126
; 8830:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 8834: L35:  301D0091         ADD R6, TMP, #7
; 8838:       4F3340F9         LDR R5, [CFP, #96]
; 883C:       2F2D00A9         STP R5, R1, [TMP]
; 8840:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 8844:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 8848:       5E0000B4         CBZ LR, L36
; 884C:       200120D4         BRK #9                         ; Pending interrupt trap
; 8850: L36:  502300F9         STR R6, [CFP, #64]
; 8854:       9F011DEB         CMP R2, NULL
; 8858:       603F0054         BEQ L101
; 885C: L37:  EA0311AA         MOV R0, R7
; 8860: L38:  4B2740F9         LDR R1, [CFP, #72]
; 8864:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 8868:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 886C:       30410091         ADD R6, TMP, #16
; 8870:       1F021EEB         CMP R6, LR
; 8874:       E8550054         BHI L127
; 8878:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 887C: L39:  301D0091         ADD R6, TMP, #7
; 8880:       2A2D00A9         STP R0, R1, [TMP]
; 8884:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 8888:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 888C:       5E0000B4         CBZ LR, L40
; 8890:       200120D4         BRK #9                         ; Pending interrupt trap
; 8894: L40:  502700F9         STR R6, [CFP, #72]
; 8898:       A0080091         ADD NL0, NL5, #2
; 889C:       E50300AA         MOV NL5, NL0
; 88A0:       401F40F9         LDR NL0, [CFP, #56]
; 88A4:       00080091         ADD NL0, NL0, #2
; 88A8:       401F00F9         STR NL0, [CFP, #56]
; 88AC:       4D000014         B L52
; 88B0: L41:  E20305AA         MOV NL2, NL5
; 88B4:       4A0F40F9         LDR R0, [CFP, #24]
; 88B8:       4E5140F8         LDR R4, [R0, #5]
; 88BC:       C49145B8         LDR WNL4, [R4, #89]
; 88C0:       C1D4FF18         LDR WNL1, #x700A998358
; 88C4:       9F00016B         CMP WNL4, WNL1
; 88C8:       A13A0054         BNE L100
; 88CC:       0D000014         B L43
; 88D0: L42:  421706A9         STP NL2, NL5, [CFP, #96]
; 88D4:       7A0300F9         STR CFP, [CSP]
; 88D8:       CAD1FF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 88DC:       4B0080D2         MOVZ R1, #2
; 88E0:       CCD1FF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 88E4:       ED0302AA         MOV R3, NL2
; 88E8:       16CFFF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 88EC:       170180D2         MOVZ NARGS, #8
; 88F0:       FA031BAA         MOV CFP, CSP
; 88F4:       DE9240F8         LDR LR, [LEXENV, #9]
; 88F8:       C0033FD6         BLR LR
; 88FC:       421746A9         LDP NL2, NL5, [CFP, #96]
; 8900: L43:  82FEFFB5         CBNZ NL2, L42
; 8904:       4A0F40F9         LDR R0, [CFP, #24]
; 8908:       4AD141F8         LDR R0, [R0, #29]
; 890C: L44:  4B2340F9         LDR R1, [CFP, #64]
; 8910:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 8914:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 8918:       30410091         ADD R6, TMP, #16
; 891C:       1F021EEB         CMP R6, LR
; 8920:       08510054         BHI L128
; 8924:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 8928: L45:  301D0091         ADD R6, TMP, #7
; 892C:       2A2D00A9         STP R0, R1, [TMP]
; 8930:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 8934:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 8938:       5E0000B4         CBZ LR, L46
; 893C:       200120D4         BRK #9                         ; Pending interrupt trap
; 8940: L46:  502300F9         STR R6, [CFP, #64]
; 8944:       E20305AA         MOV NL2, NL5
; 8948:       4A0F40F9         LDR R0, [CFP, #24]
; 894C:       4E5140F8         LDR R4, [R0, #5]
; 8950:       C49145B8         LDR WNL4, [R4, #89]
; 8954:       21D0FF18         LDR WNL1, #x700A998358
; 8958:       9F00016B         CMP WNL4, WNL1
; 895C:       01350054         BNE L99
; 8960:       0D000014         B L48
; 8964: L47:  421706A9         STP NL2, NL5, [CFP, #96]
; 8968:       7A0300F9         STR CFP, [CSP]
; 896C:       2ACDFF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 8970:       4B0080D2         MOVZ R1, #2
; 8974:       2CCDFF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 8978:       ED0302AA         MOV R3, NL2
; 897C:       76CAFF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 8980:       170180D2         MOVZ NARGS, #8
; 8984:       FA031BAA         MOV CFP, CSP
; 8988:       DE9240F8         LDR LR, [LEXENV, #9]
; 898C:       C0033FD6         BLR LR
; 8990:       421746A9         LDP NL2, NL5, [CFP, #96]
; 8994: L48:  82FEFFB5         CBNZ NL2, L47
; 8998:       4A0F40F9         LDR R0, [CFP, #24]
; 899C:       4A5141F8         LDR R0, [R0, #21]
; 89A0: L49:  4B2740F9         LDR R1, [CFP, #72]
; 89A4:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 89A8:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 89AC:       30410091         ADD R6, TMP, #16
; 89B0:       1F021EEB         CMP R6, LR
; 89B4:       E84C0054         BHI L129
; 89B8:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 89BC: L50:  301D0091         ADD R6, TMP, #7
; 89C0:       2A2D00A9         STP R0, R1, [TMP]
; 89C4:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 89C8:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 89CC:       5E0000B4         CBZ LR, L51
; 89D0:       200120D4         BRK #9                         ; Pending interrupt trap
; 89D4: L51:  502700F9         STR R6, [CFP, #72]
; 89D8:       A0080091         ADD NL0, NL5, #2
; 89DC:       E50300AA         MOV NL5, NL0
; 89E0: L52:  402B40F9         LDR NL0, [CFP, #80]
; 89E4:       BF0000EB         CMP NL5, NL0
; 89E8:       8BD2FF54         BLT L2
; 89EC: L53:  4D000014         B L65
; 89F0: L54:  E20305AA         MOV NL2, NL5
; 89F4:       4A0F40F9         LDR R0, [CFP, #24]
; 89F8:       4E5140F8         LDR R4, [R0, #5]
; 89FC:       C49145B8         LDR WNL4, [R4, #89]
; 8A00:       C1CAFF18         LDR WNL1, #x700A998358
; 8A04:       9F00016B         CMP WNL4, WNL1
; 8A08:       612E0054         BNE L98
; 8A0C:       0D000014         B L56
; 8A10: L55:  421706A9         STP NL2, NL5, [CFP, #96]
; 8A14:       7A0300F9         STR CFP, [CSP]
; 8A18:       CAC7FF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 8A1C:       4B0080D2         MOVZ R1, #2
; 8A20:       CCC7FF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 8A24:       ED0302AA         MOV R3, NL2
; 8A28:       16C5FF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 8A2C:       170180D2         MOVZ NARGS, #8
; 8A30:       FA031BAA         MOV CFP, CSP
; 8A34:       DE9240F8         LDR LR, [LEXENV, #9]
; 8A38:       C0033FD6         BLR LR
; 8A3C:       421746A9         LDP NL2, NL5, [CFP, #96]
; 8A40: L56:  82FEFFB5         CBNZ NL2, L55
; 8A44:       4A0F40F9         LDR R0, [CFP, #24]
; 8A48:       4AD141F8         LDR R0, [R0, #29]
; 8A4C: L57:  4B2340F9         LDR R1, [CFP, #64]
; 8A50:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 8A54:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 8A58:       30410091         ADD R6, TMP, #16
; 8A5C:       1F021EEB         CMP R6, LR
; 8A60:       08480054         BHI L130
; 8A64:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 8A68: L58:  301D0091         ADD R6, TMP, #7
; 8A6C:       2A2D00A9         STP R0, R1, [TMP]
; 8A70:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 8A74:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 8A78:       5E0000B4         CBZ LR, L59
; 8A7C:       200120D4         BRK #9                         ; Pending interrupt trap
; 8A80: L59:  502300F9         STR R6, [CFP, #64]
; 8A84:       E20305AA         MOV NL2, NL5
; 8A88:       4A0F40F9         LDR R0, [CFP, #24]
; 8A8C:       4E5140F8         LDR R4, [R0, #5]
; 8A90:       C49145B8         LDR WNL4, [R4, #89]
; 8A94:       21C6FF18         LDR WNL1, #x700A998358
; 8A98:       9F00016B         CMP WNL4, WNL1
; 8A9C:       C1280054         BNE L97
; 8AA0:       0D000014         B L61
; 8AA4: L60:  421706A9         STP NL2, NL5, [CFP, #96]
; 8AA8:       7A0300F9         STR CFP, [CSP]
; 8AAC:       2AC3FF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 8AB0:       4B0080D2         MOVZ R1, #2
; 8AB4:       2CC3FF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 8AB8:       ED0302AA         MOV R3, NL2
; 8ABC:       76C0FF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 8AC0:       170180D2         MOVZ NARGS, #8
; 8AC4:       FA031BAA         MOV CFP, CSP
; 8AC8:       DE9240F8         LDR LR, [LEXENV, #9]
; 8ACC:       C0033FD6         BLR LR
; 8AD0:       421746A9         LDP NL2, NL5, [CFP, #96]
; 8AD4: L61:  82FEFFB5         CBNZ NL2, L60
; 8AD8:       4A0F40F9         LDR R0, [CFP, #24]
; 8ADC:       4A5141F8         LDR R0, [R0, #21]
; 8AE0: L62:  4B2740F9         LDR R1, [CFP, #72]
; 8AE4:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 8AE8:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 8AEC:       30410091         ADD R6, TMP, #16
; 8AF0:       1F021EEB         CMP R6, LR
; 8AF4:       E8430054         BHI L131
; 8AF8:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 8AFC: L63:  301D0091         ADD R6, TMP, #7
; 8B00:       2A2D00A9         STP R0, R1, [TMP]
; 8B04:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 8B08:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 8B0C:       5E0000B4         CBZ LR, L64
; 8B10:       200120D4         BRK #9                         ; Pending interrupt trap
; 8B14: L64:  502700F9         STR R6, [CFP, #72]
; 8B18:       A0080091         ADD NL0, NL5, #2
; 8B1C:       E50300AA         MOV NL5, NL0
; 8B20: L65:  402B40F9         LDR NL0, [CFP, #80]
; 8B24:       BF0000EB         CMP NL5, NL0
; 8B28:       4BF6FF54         BLT L54
; 8B2C:       4E000014         B L77
; 8B30: L66:  421F40F9         LDR NL2, [CFP, #56]
; 8B34:       4A1340F9         LDR R0, [CFP, #32]
; 8B38:       4E5140F8         LDR R4, [R0, #5]
; 8B3C:       C49145B8         LDR WNL4, [R4, #89]
; 8B40:       C1C0FF18         LDR WNL1, #x700A998358
; 8B44:       9F00016B         CMP WNL4, WNL1
; 8B48:       E1210054         BNE L96
; 8B4C:       0D000014         B L68
; 8B50: L67:  422B00F9         STR NL2, [CFP, #80]
; 8B54:       7A0300F9         STR CFP, [CSP]
; 8B58:       CABDFF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 8B5C:       4B0080D2         MOVZ R1, #2
; 8B60:       CCBDFF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 8B64:       ED0302AA         MOV R3, NL2
; 8B68:       16BBFF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 8B6C:       170180D2         MOVZ NARGS, #8
; 8B70:       FA031BAA         MOV CFP, CSP
; 8B74:       DE9240F8         LDR LR, [LEXENV, #9]
; 8B78:       C0033FD6         BLR LR
; 8B7C:       422B40F9         LDR NL2, [CFP, #80]
; 8B80: L68:  82FEFFB5         CBNZ NL2, L67
; 8B84:       4A1340F9         LDR R0, [CFP, #32]
; 8B88:       4AD141F8         LDR R0, [R0, #29]
; 8B8C: L69:  4B2340F9         LDR R1, [CFP, #64]
; 8B90:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 8B94:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 8B98:       30410091         ADD R6, TMP, #16
; 8B9C:       1F021EEB         CMP R6, LR
; 8BA0:       083F0054         BHI L132
; 8BA4:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 8BA8: L70:  301D0091         ADD R6, TMP, #7
; 8BAC:       2A2D00A9         STP R0, R1, [TMP]
; 8BB0:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 8BB4:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 8BB8:       5E0000B4         CBZ LR, L71
; 8BBC:       200120D4         BRK #9                         ; Pending interrupt trap
; 8BC0: L71:  502300F9         STR R6, [CFP, #64]
; 8BC4:       421F40F9         LDR NL2, [CFP, #56]
; 8BC8:       4A1340F9         LDR R0, [CFP, #32]
; 8BCC:       4E5140F8         LDR R4, [R0, #5]
; 8BD0:       C49145B8         LDR WNL4, [R4, #89]
; 8BD4:       21BCFF18         LDR WNL1, #x700A998358
; 8BD8:       9F00016B         CMP WNL4, WNL1
; 8BDC:       011C0054         BNE L95
; 8BE0:       0D000014         B L73
; 8BE4: L72:  422B00F9         STR NL2, [CFP, #80]
; 8BE8:       7A0300F9         STR CFP, [CSP]
; 8BEC:       2AB9FF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 8BF0:       4B0080D2         MOVZ R1, #2
; 8BF4:       2CB9FF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 8BF8:       ED0302AA         MOV R3, NL2
; 8BFC:       76B6FF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 8C00:       170180D2         MOVZ NARGS, #8
; 8C04:       FA031BAA         MOV CFP, CSP
; 8C08:       DE9240F8         LDR LR, [LEXENV, #9]
; 8C0C:       C0033FD6         BLR LR
; 8C10:       422B40F9         LDR NL2, [CFP, #80]
; 8C14: L73:  82FEFFB5         CBNZ NL2, L72
; 8C18:       4A1340F9         LDR R0, [CFP, #32]
; 8C1C:       4A5141F8         LDR R0, [R0, #21]
; 8C20: L74:  4B2740F9         LDR R1, [CFP, #72]
; 8C24:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 8C28:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 8C2C:       30410091         ADD R6, TMP, #16
; 8C30:       1F021EEB         CMP R6, LR
; 8C34:       E83A0054         BHI L133
; 8C38:       B02E00F9         STR R6, [THREAD, #88]          ; cons-tlab
; 8C3C: L75:  301D0091         ADD R6, TMP, #7
; 8C40:       2A2D00A9         STP R0, R1, [TMP]
; 8C44:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 8C48:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 8C4C:       5E0000B4         CBZ LR, L76
; 8C50:       200120D4         BRK #9                         ; Pending interrupt trap
; 8C54: L76:  502700F9         STR R6, [CFP, #72]
; 8C58:       401F40F9         LDR NL0, [CFP, #56]
; 8C5C:       00080091         ADD NL0, NL0, #2
; 8C60:       401F00F9         STR NL0, [CFP, #56]
; 8C64: L77:  401F40F9         LDR NL0, [CFP, #56]
; 8C68:       412F40F9         LDR NL1, [CFP, #88]
; 8C6C:       1F0001EB         CMP NL0, NL1
; 8C70:       0BF6FF54         BLT L66
; 8C74:       4A2340F9         LDR R0, [CFP, #64]
; 8C78:       7A0300F9         STR CFP, [CSP]
; 8C7C:       B6B2FF58         LDR LEXENV, #x700A9982D0       ; #<SB-KERNEL:FDEFN SB-IMPL::LIST-NREVERSE>
; 8C80:       570080D2         MOVZ NARGS, #2
; 8C84:       FA031BAA         MOV CFP, CSP
; 8C88:       DE9240F8         LDR LR, [LEXENV, #9]
; 8C8C:       C0033FD6         BLR LR
; 8C90:       ED030AAA         MOV R3, R0
; 8C94:       040080D2         MOVZ NL4, #0
; 8C98: L78:  5F011DEB         CMP R0, NULL
; 8C9C:       00010054         BEQ L80
; 8CA0:       410D4092         AND NL1, R0, #15
; 8CA4:       3F1C00F1         CMP NL1, #7
; 8CA8:       81000054         BNE L79
; 8CAC:       4A1140F8         LDR R0, [R0, #1]
; 8CB0:       84080091         ADD NL4, NL4, #2
; 8CB4:       F9FFFF17         B L78
; 8CB8: L79:  E04921D4         BRK #2639                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 8CBC: L80:  E1E77DB2         MOV NL1, #2305843009213693944
; 8CC0:       9F0001EB         CMP NL4, NL1
; 8CC4:       88140054         BHI L94
; 8CC8:       4C2280D2         MOVZ R2, #274
; 8CCC:       EB0304AA         MOV R1, NL4
; 8CD0:       EA0304AA         MOV R0, NL4
; 8CD4:       FEB3FF58         LDR LR, #x700A998350           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; 8CD8:       C0033FD6         BLR LR
; 8CDC:       80FC4193         ASR NL0, NL4, #1
; 8CE0:       7A0300F9         STR CFP, [CSP]
; 8CE4:       EB030DAA         MOV R1, R3
; 8CE8:       96AFFF58         LDR LEXENV, #x700A9982D8       ; #<SB-KERNEL:FDEFN REPLACE>
; 8CEC:       970080D2         MOVZ NARGS, #4
; 8CF0:       FA031BAA         MOV CFP, CSP
; 8CF4:       DE9240F8         LDR LR, [LEXENV, #9]
; 8CF8:       C0033FD6         BLR LR
; 8CFC:       EF030AAA         MOV R5, R0
; 8D00:       4F2B00F9         STR R5, [CFP, #80]
; 8D04:       4F1F00F9         STR R5, [CFP, #56]
; 8D08:       4A2740F9         LDR R0, [CFP, #72]
; 8D0C:       7A0300F9         STR CFP, [CSP]
; 8D10:       16AEFF58         LDR LEXENV, #x700A9982D0       ; #<SB-KERNEL:FDEFN SB-IMPL::LIST-NREVERSE>
; 8D14:       570080D2         MOVZ NARGS, #2
; 8D18:       FA031BAA         MOV CFP, CSP
; 8D1C:       DE9240F8         LDR LR, [LEXENV, #9]
; 8D20:       C0033FD6         BLR LR
; 8D24:       4F2B40F9         LDR R5, [CFP, #80]
; 8D28:       ED030AAA         MOV R3, R0
; 8D2C:       040080D2         MOVZ NL4, #0
; 8D30: L81:  5F011DEB         CMP R0, NULL
; 8D34:       00010054         BEQ L83
; 8D38:       410D4092         AND NL1, R0, #15
; 8D3C:       3F1C00F1         CMP NL1, #7
; 8D40:       81000054         BNE L82
; 8D44:       4A1140F8         LDR R0, [R0, #1]
; 8D48:       84080091         ADD NL4, NL4, #2
; 8D4C:       F9FFFF17         B L81
; 8D50: L82:  E04921D4         BRK #2639                      ; OBJECT-NOT-LIST-ERROR
                                                              ; R0
; 8D54: L83:  E1E77DB2         MOV NL1, #2305843009213693944
; 8D58:       9F0001EB         CMP NL4, NL1
; 8D5C:       880F0054         BHI L93
; 8D60:       4F2B00F9         STR R5, [CFP, #80]
; 8D64:       4C2280D2         MOVZ R2, #274
; 8D68:       EB0304AA         MOV R1, NL4
; 8D6C:       EA0304AA         MOV R0, NL4
; 8D70:       1EAFFF58         LDR LR, #x700A998350           ; SB-VM::ALLOCATE-VECTOR-ON-HEAP
; 8D74:       C0033FD6         BLR LR
; 8D78:       80FC4193         ASR NL0, NL4, #1
; 8D7C:       7A0300F9         STR CFP, [CSP]
; 8D80:       EB030DAA         MOV R1, R3
; 8D84:       B6AAFF58         LDR LEXENV, #x700A9982D8       ; #<SB-KERNEL:FDEFN REPLACE>
; 8D88:       970080D2         MOVZ NARGS, #4
; 8D8C:       FA031BAA         MOV CFP, CSP
; 8D90:       DE9240F8         LDR LR, [LEXENV, #9]
; 8D94:       C0033FD6         BLR LR
; 8D98:       4F2B40F9         LDR R5, [CFP, #80]
; 8D9C:       4A2300F9         STR R0, [CFP, #64]
; 8DA0:       E0915FF8         LDR NL0, [R5, #-7]
; 8DA4:       1F0800F1         CMP NL0, #2
; 8DA8:       400A0054         BEQ L92
; 8DAC:       7A0300F9         STR CFP, [CSP]
; 8DB0:       4AAF43A9         LDP R0, R1, [CFP, #56]
; 8DB4:       76A9FF58         LDR LEXENV, #x700A9982E0       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::CONTEXT-NODE>
; 8DB8:       970080D2         MOVZ NARGS, #4
; 8DBC:       FA031BAA         MOV CFP, CSP
; 8DC0:       DE9240F8         LDR LR, [LEXENV, #9]
; 8DC4:       C0033FD6         BLR LR
; 8DC8:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 8DCC:       410D4092         AND NL1, R0, #15
; 8DD0:       3F0C00F1         CMP NL1, #3
; 8DD4:       A1080054         BNE L91
; 8DD8:       4E5140F8         LDR R4, [R0, #5]
; 8DDC:       C49145B8         LDR WNL4, [R4, #89]
; 8DE0:       E1ABFF18         LDR WNL1, #x700A99835C
; 8DE4:       9F00016B         CMP WNL4, WNL1
; 8DE8:       01080054         BNE L91
; 8DEC:       EF030AAA         MOV R5, R0
; 8DF0:       4F1F00F9         STR R5, [CFP, #56]
; 8DF4:       EA030FAA         MOV R0, R5
; 8DF8:       7A0300F9         STR CFP, [CSP]
; 8DFC:       4E0F40F9         LDR R4, [CFP, #24]
; 8E00:       EB030EAA         MOV R1, R4
; 8E04:       36A7FF58         LDR LEXENV, #x700A9982E8       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:CONTEXT-EQUAL>
; 8E08:       970080D2         MOVZ NARGS, #4
; 8E0C:       FA031BAA         MOV CFP, CSP
; 8E10:       DE9240F8         LDR LR, [LEXENV, #9]
; 8E14:       C0033FD6         BLR LR
; 8E18:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 8E1C:       4F1F40F9         LDR R5, [CFP, #56]
; 8E20:       5F011DEB         CMP R0, NULL
; 8E24:       80000054         BEQ L84
; 8E28:       ABE30091         ADD R1, NULL, #56              ; T
; 8E2C:       5F010BEB         CMP R0, R1
; 8E30:       A1050054         BNE L90
; 8E34: L84:  5F011DEB         CMP R0, NULL
; 8E38:       21050054         BNE L89
; 8E3C:       4F1F00F9         STR R5, [CFP, #56]
; 8E40:       EA030FAA         MOV R0, R5
; 8E44:       7A0300F9         STR CFP, [CSP]
; 8E48:       4B1340F9         LDR R1, [CFP, #32]
; 8E4C:       F6A4FF58         LDR LEXENV, #x700A9982E8       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:CONTEXT-EQUAL>
; 8E50:       970080D2         MOVZ NARGS, #4
; 8E54:       FA031BAA         MOV CFP, CSP
; 8E58:       DE9240F8         LDR LR, [LEXENV, #9]
; 8E5C:       C0033FD6         BLR LR
; 8E60:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 8E64:       4F1F40F9         LDR R5, [CFP, #56]
; 8E68:       5F011DEB         CMP R0, NULL
; 8E6C:       80000054         BEQ L85
; 8E70:       ABE30091         ADD R1, NULL, #56              ; T
; 8E74:       5F010BEB         CMP R0, R1
; 8E78:       01030054         BNE L88
; 8E7C: L85:  5F011DEB         CMP R0, NULL
; 8E80:       60010054         BEQ L87
; 8E84:       4F1340F9         LDR R5, [CFP, #32]
; 8E88: L86:  4A1B40F9         LDR R0, [CFP, #48]
; 8E8C:       4BB341A9         LDP R1, R2, [CFP, #24]
; 8E90:       4D1740F9         LDR R3, [CFP, #40]
; 8E94:       4F1300F9         STR R5, [CFP, #32]
; 8E98:       D6A2FF58         LDR LEXENV, #x700A9982F0       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::MERGE-CACHE-PUT>
; 8E9C:       570180D2         MOVZ NARGS, #10
; 8EA0:       DE9240F8         LDR LR, [LEXENV, #9]
; 8EA4:       DE130091         ADD LR, LR, #4
; 8EA8:       C0031FD6         BR LR
; 8EAC: L87:  4F1F00F9         STR R5, [CFP, #56]
; 8EB0:       7A0300F9         STR CFP, [CSP]
; 8EB4:       4A2340F9         LDR R0, [CFP, #64]
; 8EB8:       16A2FF58         LDR LEXENV, #x700A9982F8       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::COMBINE-COMMON-PARENTS>
; 8EBC:       570080D2         MOVZ NARGS, #2
; 8EC0:       FA031BAA         MOV CFP, CSP
; 8EC4:       DE9240F8         LDR LR, [LEXENV, #9]
; 8EC8:       C0033FD6         BLR LR
; 8ECC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 8ED0:       4F1F40F9         LDR R5, [CFP, #56]
; 8ED4:       EDFFFF17         B L86
; 8ED8: L88:  A05221D4         BRK #2709                      ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; 8EDC: L89:  4F0F40F9         LDR R5, [CFP, #24]
; 8EE0:       EAFFFF17         B L86
; 8EE4: L90:  A05221D4         BRK #2709                      ; OBJECT-NOT-BOOLEAN-ERROR
                                                              ; R0
; 8EE8: L91:  604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 8EEC:       53               BYTE #X53                      ; #<SB-KERNEL:LAYOUT (ID=391) for CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT {700CD509B3}>
; 8EED:       .ALIGN           4
; 8EF0: L92:  40915FF8         LDR NL0, [R0, #-7]
; 8EF4:       602500B4         CBZ NL0, L134
; 8EF8:       4A1140F8         LDR R0, [R0, #1]
; 8EFC:       E0915FF8         LDR NL0, [R5, #-7]
; 8F00:       402500B4         CBZ NL0, L135
; 8F04:       EB1140F8         LDR R1, [R5, #1]
; 8F08:       7A0300F9         STR CFP, [CSP]
; 8F0C:       B69FFF58         LDR LEXENV, #x700A998300       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:SINGLETON-CONTEXT>
; 8F10:       970080D2         MOVZ NARGS, #4
; 8F14:       FA031BAA         MOV CFP, CSP
; 8F18:       DE9240F8         LDR LR, [LEXENV, #9]
; 8F1C:       C0033FD6         BLR LR
; 8F20:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 8F24:       EE030AAA         MOV R4, R0
; 8F28:       4A1B40F9         LDR R0, [CFP, #48]
; 8F2C:       4BB341A9         LDP R1, R2, [CFP, #24]
; 8F30:       4D1740F9         LDR R3, [CFP, #40]
; 8F34:       4E1300F9         STR R4, [CFP, #32]
; 8F38:       D69DFF58         LDR LEXENV, #x700A9982F0       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME::MERGE-CACHE-PUT>
; 8F3C:       570180D2         MOVZ NARGS, #10
; 8F40:       DE9240F8         LDR LR, [LEXENV, #9]
; 8F44:       DE130091         ADD LR, LR, #4
; 8F48:       C0031FD6         BR LR
; 8F4C: L93:  608320D4         BRK #1051                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NL4
; 8F50:       57               BYTE #X57                      ; '(MOD
                                                              ;   1152921504606846973)
; 8F51:       .ALIGN           4
; 8F54: L94:  608320D4         BRK #1051                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; NL4
; 8F58:       57               BYTE #X57                      ; '(MOD
                                                              ;   1152921504606846973)
; 8F59:       .ALIGN           4
; 8F5C: L95:  4A1340F9         LDR R0, [CFP, #32]
; 8F60:       4AD141F8         LDR R0, [R0, #29]
; 8F64:       40915FF8         LDR NL0, [R0, #-7]
; 8F68:       411F40F9         LDR NL1, [CFP, #56]
; 8F6C:       1F0001EB         CMP NL0, NL1
; 8F70:       09220054         BLS L136
; 8F74:       401F40F9         LDR NL0, [CFP, #56]
; 8F78:       4909008B         ADD TMP, R0, NL0, LSL #2
; 8F7C:       2A1140F8         LDR R0, [TMP, #1]
; 8F80:       28FFFF17         B L74
; 8F84: L96:  4A1340F9         LDR R0, [CFP, #32]
; 8F88:       4A5141F8         LDR R0, [R0, #21]
; 8F8C:       40915FF8         LDR NL0, [R0, #-7]
; 8F90:       411F40F9         LDR NL1, [CFP, #56]
; 8F94:       1F0001EB         CMP NL0, NL1
; 8F98:       09210054         BLS L137
; 8F9C:       401F40F9         LDR NL0, [CFP, #56]
; 8FA0:       4909008B         ADD TMP, R0, NL0, LSL #2
; 8FA4:       2A1140F8         LDR R0, [TMP, #1]
; 8FA8:       5F7D5FF2         TST R0, #18446744065119617025
; 8FAC:       00DFFF54         BEQ L69
; 8FB0:       604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 8FB4: L97:  4A0F40F9         LDR R0, [CFP, #24]
; 8FB8:       4AD141F8         LDR R0, [R0, #29]
; 8FBC:       40915FF8         LDR NL0, [R0, #-7]
; 8FC0:       1F0005EB         CMP NL0, NL5
; 8FC4:       E91F0054         BLS L138
; 8FC8:       4909058B         ADD TMP, R0, NL5, LSL #2
; 8FCC:       2A1140F8         LDR R0, [TMP, #1]
; 8FD0:       C4FEFF17         B L62
; 8FD4: L98:  4A0F40F9         LDR R0, [CFP, #24]
; 8FD8:       4A5141F8         LDR R0, [R0, #21]
; 8FDC:       40915FF8         LDR NL0, [R0, #-7]
; 8FE0:       1F0005EB         CMP NL0, NL5
; 8FE4:       291F0054         BLS L139
; 8FE8:       4909058B         ADD TMP, R0, NL5, LSL #2
; 8FEC:       2A1140F8         LDR R0, [TMP, #1]
; 8FF0:       5F7D5FF2         TST R0, #18446744065119617025
; 8FF4:       C0D2FF54         BEQ L57
; 8FF8:       604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 8FFC: L99:  4A0F40F9         LDR R0, [CFP, #24]
; 9000:       4AD141F8         LDR R0, [R0, #29]
; 9004:       40915FF8         LDR NL0, [R0, #-7]
; 9008:       1F0005EB         CMP NL0, NL5
; 900C:       291E0054         BLS L140
; 9010:       4909058B         ADD TMP, R0, NL5, LSL #2
; 9014:       2A1140F8         LDR R0, [TMP, #1]
; 9018:       62FEFF17         B L49
; 901C: L100: 4A0F40F9         LDR R0, [CFP, #24]
; 9020:       4A5141F8         LDR R0, [R0, #21]
; 9024:       40915FF8         LDR NL0, [R0, #-7]
; 9028:       1F0005EB         CMP NL0, NL5
; 902C:       691D0054         BLS L141
; 9030:       4909058B         ADD TMP, R0, NL5, LSL #2
; 9034:       2A1140F8         LDR R0, [TMP, #1]
; 9038:       5F7D5FF2         TST R0, #18446744065119617025
; 903C:       80C6FF54         BEQ L44
; 9040:       604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 9044: L101: 5F011DEB         CMP R0, NULL
; 9048:       A1C0FF54         BNE L37
; 904C:       453700F9         STR NL5, [CFP, #104]
; 9050:       7A0300F9         STR CFP, [CSP]
; 9054:       EA0311AA         MOV R0, R7
; 9058:       EB030DAA         MOV R1, R3
; 905C:       4CB742A9         LDP R2, R3, [CFP, #40]
; 9060:       5695FF58         LDR LEXENV, #x700A998308       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:MERGE-CONTEXTS>
; 9064:       170180D2         MOVZ NARGS, #8
; 9068:       FA031BAA         MOV CFP, CSP
; 906C:       DE9240F8         LDR LR, [LEXENV, #9]
; 9070:       C0033FD6         BLR LR
; 9074:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 9078:       453740F9         LDR NL5, [CFP, #104]
; 907C:       F9FDFF17         B L38
; 9080: L102: 5F011DEB         CMP R0, NULL
; 9084:       80BCFF54         BEQ L33
; 9088:       4D4707A9         STP R3, R7, [CFP, #112]
; 908C:       453700F9         STR NL5, [CFP, #104]
; 9090:       4C4300F9         STR R2, [CFP, #128]
; 9094:       7A0300F9         STR CFP, [CSP]
; 9098:       EA0311AA         MOV R0, R7
; 909C:       EB030DAA         MOV R1, R3
; 90A0:       5692FF58         LDR LEXENV, #x700A9982E8       ; #<SB-KERNEL:FDEFN CNVRS/ANTLR-RUNTIME:CONTEXT-EQUAL>
; 90A4:       970080D2         MOVZ NARGS, #4
; 90A8:       FA031BAA         MOV CFP, CSP
; 90AC:       DE9240F8         LDR LR, [LEXENV, #9]
; 90B0:       C0033FD6         BLR LR
; 90B4:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 90B8:       4C4340F9         LDR R2, [CFP, #128]
; 90BC:       453740F9         LDR NL5, [CFP, #104]
; 90C0:       4D4747A9         LDP R3, R7, [CFP, #112]
; 90C4:       D5FDFF17         B L34
; 90C8: L103: 3F021DEB         CMP R7, NULL
; 90CC:       E1B9FF54         BNE L31
; 90D0:       5F011DEB         CMP R0, NULL
; 90D4:       A1B9FF54         BNE L31
; 90D8:       ACE30091         ADD R2, NULL, #56              ; T
; 90DC:       CCFDFF17         B L32
; 90E0: L104: 458B06A9         STP NL5, NL2, [CFP, #104]
; 90E4:       513F00F9         STR R7, [CFP, #120]
; 90E8:       7A0300F9         STR CFP, [CSP]
; 90EC:       2A91FF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 90F0:       4B0080D2         MOVZ R1, #2
; 90F4:       2C91FF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 90F8:       ED0302AA         MOV R3, NL2
; 90FC:       768EFF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 9100:       170180D2         MOVZ NARGS, #8
; 9104:       FA031BAA         MOV CFP, CSP
; 9108:       DE9240F8         LDR LR, [LEXENV, #9]
; 910C:       C0033FD6         BLR LR
; 9110:       513F40F9         LDR R7, [CFP, #120]
; 9114:       458B46A9         LDP NL5, NL2, [CFP, #104]
; 9118: L105: 42FEFFB5         CBNZ NL2, L104
; 911C:       4A1340F9         LDR R0, [CFP, #32]
; 9120:       4A5141F8         LDR R0, [R0, #21]
; 9124:       B4FDFF17         B L30
; 9128: L106: 4A0F40F9         LDR R0, [CFP, #24]
; 912C:       4AD141F8         LDR R0, [R0, #29]
; 9130:       40915FF8         LDR NL0, [R0, #-7]
; 9134:       1F0005EB         CMP NL0, NL5
; 9138:       49150054         BLS L142
; 913C:       4909058B         ADD TMP, R0, NL5, LSL #2
; 9140:       311140F8         LDR R7, [TMP, #1]
; 9144:       9CFDFF17         B L29
; 9148: L107: 4A0F40F9         LDR R0, [CFP, #24]
; 914C:       4A5141F8         LDR R0, [R0, #21]
; 9150:       40915FF8         LDR NL0, [R0, #-7]
; 9154:       1F0005EB         CMP NL0, NL5
; 9158:       89140054         BLS L143
; 915C:       4909058B         ADD TMP, R0, NL5, LSL #2
; 9160:       2A1140F8         LDR R0, [TMP, #1]
; 9164:       5F7D5FF2         TST R0, #18446744065119617025
; 9168:       60AFFF54         BEQ L26
; 916C:       604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 9170: L108: 4A1340F9         LDR R0, [CFP, #32]
; 9174:       4AD141F8         LDR R0, [R0, #29]
; 9178:       40915FF8         LDR NL0, [R0, #-7]
; 917C:       411F40F9         LDR NL1, [CFP, #56]
; 9180:       1F0001EB         CMP NL0, NL1
; 9184:       69130054         BLS L144
; 9188:       401F40F9         LDR NL0, [CFP, #56]
; 918C:       4909008B         ADD TMP, R0, NL0, LSL #2
; 9190:       2A1140F8         LDR R0, [TMP, #1]
; 9194:       47FDFF17         B L20
; 9198: L109: 4A1340F9         LDR R0, [CFP, #32]
; 919C:       4A5141F8         LDR R0, [R0, #21]
; 91A0:       40915FF8         LDR NL0, [R0, #-7]
; 91A4:       411F40F9         LDR NL1, [CFP, #56]
; 91A8:       1F0001EB         CMP NL0, NL1
; 91AC:       69120054         BLS L145
; 91B0:       401F40F9         LDR NL0, [CFP, #56]
; 91B4:       4909008B         ADD TMP, R0, NL0, LSL #2
; 91B8:       2A1140F8         LDR R0, [TMP, #1]
; 91BC:       5F7D5FF2         TST R0, #18446744065119617025
; 91C0:       E0A2FF54         BEQ L15
; 91C4:       604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 91C8: L110: 4A1340F9         LDR R0, [CFP, #32]
; 91CC:       4A5141F8         LDR R0, [R0, #21]
; 91D0:       40915FF8         LDR NL0, [R0, #-7]
; 91D4:       411F40F9         LDR NL1, [CFP, #56]
; 91D8:       1F0001EB         CMP NL0, NL1
; 91DC:       29110054         BLS L146
; 91E0:       401F40F9         LDR NL0, [CFP, #56]
; 91E4:       4909008B         ADD TMP, R0, NL0, LSL #2
; 91E8:       2A1140F8         LDR R0, [TMP, #1]
; 91EC:       5F7D5FF2         TST R0, #18446744065119617025
; 91F0:       409EFF54         BEQ L12
; 91F4:       604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 91F8: L111: 4A0F40F9         LDR R0, [CFP, #24]
; 91FC:       4A5141F8         LDR R0, [R0, #21]
; 9200:       40915FF8         LDR NL0, [R0, #-7]
; 9204:       1F0005EB         CMP NL0, NL5
; 9208:       09100054         BLS L147
; 920C:       4909058B         ADD TMP, R0, NL5, LSL #2
; 9210:       2A1140F8         LDR R0, [TMP, #1]
; 9214:       5F7D5FF2         TST R0, #18446744065119617025
; 9218:       61000054         BNE L112
; 921C:       E3030AAA         MOV NL3, R0
; 9220:       CDFCFF17         B L9
; 9224: L112: 604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 9228: L113: 4A1340F9         LDR R0, [CFP, #32]
; 922C:       4A5141F8         LDR R0, [R0, #21]
; 9230:       40915FF8         LDR NL0, [R0, #-7]
; 9234:       411F40F9         LDR NL1, [CFP, #56]
; 9238:       1F0001EB         CMP NL0, NL1
; 923C:       A90E0054         BLS L148
; 9240:       401F40F9         LDR NL0, [CFP, #56]
; 9244:       4909008B         ADD TMP, R0, NL0, LSL #2
; 9248:       2A1140F8         LDR R0, [TMP, #1]
; 924C:       5F7D5FF2         TST R0, #18446744065119617025
; 9250:       0095FF54         BEQ L6
; 9254:       604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 9258: L114: 604D21D4         BRK #2667                      ; OBJECT-NOT-UNSIGNED-BYTE-32-ERROR
                                                              ; R0
; 925C: L115: 421706A9         STP NL2, NL5, [CFP, #96]
; 9260:       7A0300F9         STR CFP, [CSP]
; 9264:       6A85FF58         LDR R0, #x700A998310           ; '(ZEROP
                                                              ;   CNVRS/ANTLR-RUNTIME::INDEX)
; 9268:       4B0080D2         MOVZ R1, #2
; 926C:       6C85FF58         LDR R2, #x700A998318           ; 'CNVRS/ANTLR-RUNTIME::INDEX
; 9270:       ED0302AA         MOV R3, NL2
; 9274:       B682FF58         LDR LEXENV, #x700A9982C8       ; #<SB-KERNEL:FDEFN SB-KERNEL:ASSERT-ERROR>
; 9278:       170180D2         MOVZ NARGS, #8
; 927C:       FA031BAA         MOV CFP, CSP
; 9280:       DE9240F8         LDR LR, [LEXENV, #9]
; 9284:       C0033FD6         BLR LR
; 9288:       421746A9         LDP NL2, NL5, [CFP, #96]
; 928C: L116: 82FEFFB5         CBNZ NL2, L115
; 9290:       4A0F40F9         LDR R0, [CFP, #24]
; 9294:       43D141F8         LDR NL3, [R0, #29]
; 9298:       7DFCFF17         B L3
; 929C: L117: 449145B8         LDR WNL4, [R0, #89]
; 92A0:       E185FF18         LDR WNL1, #x700A99835C
; 92A4:       9F00016B         CMP WNL4, WNL1
; 92A8:       A1000054         BNE L118
; 92AC:       4A1340F9         LDR R0, [CFP, #32]
; 92B0:       4A5141F8         LDR R0, [R0, #21]
; 92B4:       41915FF8         LDR NL1, [R0, #-7]
; 92B8:       5BFCFF17         B L1
; 92BC: L118: 4A1340F9         LDR R0, [CFP, #32]
; 92C0:       A04321D4         BRK #2589                      ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; 92C4:       5B               BYTE #X5B                      ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 92C5:       .ALIGN           4
; 92C8: L119: 4A0F40F9         LDR R0, [CFP, #24]
; 92CC:       A04321D4         BRK #2589                      ; ETYPECASE-FAILURE-ERROR
                                                              ; R0
; 92D0:       5B               BYTE #X5B                      ; '(CNVRS/ANTLR-RUNTIME::SINGLETON-PREDICTION-CONTEXT
                                                              ;   CNVRS/ANTLR-RUNTIME::ARRAY-PREDICTION-CONTEXT)
; 92D1:       .ALIGN           4
; 92D4: L120: 400080D2         MOVZ NL0, #2
; 92D8:       49FCFF17         B L0
; 92DC: L121: FB031AAA         MOV CSP, CFP
; 92E0:       5A7B40A9         LDP CFP, LR, [CFP]
; 92E4:       BF0300F1         CMP NULL, #0
; 92E8:       C0035FD6         RET
; 92EC:       E00120D4         BRK #15                        ; Invalid argument count trap
; 92F0: L122: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 92F4:       15               BYTE #X15                      ; NL5
; 92F5:       .ALIGN           4
; 92F8: L123: 090280D2         MOVZ TMP, #16
; 92FC:       7082FF58         LDR R6, #x700A998348           ; SB-VM::LIST-ALLOC-TRAMP
; 9300:       00023FD6         BLR R6
; 9304:       CDFCFF17         B L16
; 9308: L124: 090280D2         MOVZ TMP, #16
; 930C:       F081FF58         LDR R6, #x700A998348           ; SB-VM::LIST-ALLOC-TRAMP
; 9310:       00023FD6         BLR R6
; 9314:       EEFCFF17         B L21
; 9318: L125: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 931C:       05               BYTE #X05                      ; NL1
; 931D:       .ALIGN           4
; 9320: L126: 090280D2         MOVZ TMP, #16
; 9324:       3081FF58         LDR R6, #x700A998348           ; SB-VM::LIST-ALLOC-TRAMP
; 9328:       00023FD6         BLR R6
; 932C:       42FDFF17         B L35
; 9330: L127: 090280D2         MOVZ TMP, #16
; 9334:       B080FF58         LDR R6, #x700A998348           ; SB-VM::LIST-ALLOC-TRAMP
; 9338:       00023FD6         BLR R6
; 933C:       50FDFF17         B L39
; 9340: L128: 090280D2         MOVZ TMP, #16
; 9344:       3080FF58         LDR R6, #x700A998348           ; SB-VM::LIST-ALLOC-TRAMP
; 9348:       00023FD6         BLR R6
; 934C:       77FDFF17         B L45
; 9350: L129: 090280D2         MOVZ TMP, #16
; 9354:       B07FFF58         LDR R6, #x700A998348           ; SB-VM::LIST-ALLOC-TRAMP
; 9358:       00023FD6         BLR R6
; 935C:       98FDFF17         B L50
; 9360: L130: 090280D2         MOVZ TMP, #16
; 9364:       307FFF58         LDR R6, #x700A998348           ; SB-VM::LIST-ALLOC-TRAMP
; 9368:       00023FD6         BLR R6
; 936C:       BFFDFF17         B L58
; 9370: L131: 090280D2         MOVZ TMP, #16
; 9374:       B07EFF58         LDR R6, #x700A998348           ; SB-VM::LIST-ALLOC-TRAMP
; 9378:       00023FD6         BLR R6
; 937C:       E0FDFF17         B L63
; 9380: L132: 090280D2         MOVZ TMP, #16
; 9384:       307EFF58         LDR R6, #x700A998348           ; SB-VM::LIST-ALLOC-TRAMP
; 9388:       00023FD6         BLR R6
; 938C:       07FEFF17         B L70
; 9390: L133: 090280D2         MOVZ TMP, #16
; 9394:       B07DFF58         LDR R6, #x700A998348           ; SB-VM::LIST-ALLOC-TRAMP
; 9398:       00023FD6         BLR R6
; 939C:       28FEFF17         B L75
; 93A0: L134: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93A4:       80808004         BYTE #X80, #X80, #X80, #X04    ; 0
; 93A8: L135: 20E421D4         BRK #3873                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R5
; 93AC:       80808004         BYTE #X80, #X80, #X80, #X04    ; 0
; 93B0: L136: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93B4:       05               BYTE #X05                      ; NL1
; 93B5:       .ALIGN           4
; 93B8: L137: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93BC:       05               BYTE #X05                      ; NL1
; 93BD:       .ALIGN           4
; 93C0: L138: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93C4:       15               BYTE #X15                      ; NL5
; 93C5:       .ALIGN           4
; 93C8: L139: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93CC:       15               BYTE #X15                      ; NL5
; 93CD:       .ALIGN           4
; 93D0: L140: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93D4:       15               BYTE #X15                      ; NL5
; 93D5:       .ALIGN           4
; 93D8: L141: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93DC:       15               BYTE #X15                      ; NL5
; 93DD:       .ALIGN           4
; 93E0: L142: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93E4:       15               BYTE #X15                      ; NL5
; 93E5:       .ALIGN           4
; 93E8: L143: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93EC:       15               BYTE #X15                      ; NL5
; 93ED:       .ALIGN           4
; 93F0: L144: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93F4:       05               BYTE #X05                      ; NL1
; 93F5:       .ALIGN           4
; 93F8: L145: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 93FC:       05               BYTE #X05                      ; NL1
; 93FD:       .ALIGN           4
; 9400: L146: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 9404:       05               BYTE #X05                      ; NL1
; 9405:       .ALIGN           4
; 9408: L147: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 940C:       15               BYTE #X15                      ; NL5
; 940D:       .ALIGN           4
; 9410: L148: 204421D4         BRK #2593                      ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; 9414:       05               BYTE #X05                      ; NL1
; 9415:       .ALIGN           4
