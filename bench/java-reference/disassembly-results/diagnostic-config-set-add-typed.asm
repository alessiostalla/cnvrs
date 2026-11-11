; disassembly for DIAGNOSTIC-CONFIG-SET-ADD-TYPED
; Size: 1060 bytes. Origin: #x70055B1EB0                      ; DIAGNOSTIC-CONFIG-SET-ADD-TYPED
; 1EB0:       4A0B40F9         LDR R0, [CFP, #16]
; 1EB4:       4A5144F8         LDR R0, [R0, #69]
; 1EB8:       5F011DEB         CMP R0, NULL
; 1EBC:       211F0054         BNE L16
; 1EC0:       4A0F40F9         LDR R0, [CFP, #24]
; 1EC4:       4A5142F8         LDR R0, [R0, #37]
; 1EC8:       ABE30091         ADD R1, NULL, #56              ; T
; 1ECC:       5F010BEB         CMP R0, R1
; 1ED0:       011E0054         BNE L15
; 1ED4: L0:   4A0F40F9         LDR R0, [CFP, #24]
; 1ED8:       40D142F8         LDR NL0, [R0, #45]
; 1EDC:       1F0000F1         CMP NL0, #0
; 1EE0:       0C1D0054         BGT L14
; 1EE4: L1:   4A0F40F9         LDR R0, [CFP, #24]
; 1EE8:       40D140F8         LDR NL0, [R0, #13]
; 1EEC:       037C7F92         AND NL3, NL0, #8589934590
; 1EF0:       4A0F40F9         LDR R0, [CFP, #24]
; 1EF4:       405141F8         LDR NL0, [R0, #21]
; 1EF8:       007C7F92         AND NL0, NL0, #8589934590
; 1EFC:       29AA85D2         MOVZ TMP, #11601
; 1F00:       C993B9F2         MOVK TMP, #52382, LSL #16
; 1F04:       007C099B         MUL NL0, NL0, TMP
; 1F08:       007C7F92         AND NL0, NL0, #8589934590
; 1F0C:       02C071D3         LSL NL2, NL0, #15
; 1F10:       01FC5193         ASR NL1, NL0, #17
; 1F14:       20F87F92         AND NL0, NL1, #18446744073709551614
; 1F18:       400000AA         ORR NL0, NL2, NL0
; 1F1C:       007C7F92         AND NL0, NL0, #8589934590
; 1F20:       69B286D2         MOVZ TMP, #13715
; 1F24:       E970A3F2         MOVK TMP, #7047, LSL #16
; 1F28:       007C099B         MUL NL0, NL0, TMP
; 1F2C:       007C7F92         AND NL0, NL0, #8589934590
; 1F30:       600000CA         EOR NL0, NL3, NL0
; 1F34:       02C873D3         LSL NL2, NL0, #13
; 1F38:       01FC5393         ASR NL1, NL0, #19
; 1F3C:       20F87F92         AND NL0, NL1, #18446744073709551614
; 1F40:       400000AA         ORR NL0, NL2, NL0
; 1F44:       007C7F92         AND NL0, NL0, #8589934590
; 1F48:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 1F4C:       01D99AD2         MOVZ NL1, #54984
; 1F50:       0195B9F2         MOVK NL1, #52392, LSL #16
; 1F54:       2100C0F2         MOVK NL1, #1, LSL #32
; 1F58:       0000018B         ADD NL0, NL0, NL1
; 1F5C:       037C7F92         AND NL3, NL0, #8589934590
; 1F60:       4A0F40F9         LDR R0, [CFP, #24]
; 1F64:       4A5142F8         LDR R0, [R0, #37]
; 1F68:       ABE30091         ADD R1, NULL, #56              ; T
; 1F6C:       5F010BEB         CMP R0, R1
; 1F70:       01170054         BNE L13
; 1F74:       000080D2         MOVZ NL0, #0
; 1F78: L2:   29AA85D2         MOVZ TMP, #11601
; 1F7C:       C993B9F2         MOVK TMP, #52382, LSL #16
; 1F80:       007C099B         MUL NL0, NL0, TMP
; 1F84:       007C7F92         AND NL0, NL0, #8589934590
; 1F88:       02C071D3         LSL NL2, NL0, #15
; 1F8C:       01FC5193         ASR NL1, NL0, #17
; 1F90:       20F87F92         AND NL0, NL1, #18446744073709551614
; 1F94:       400000AA         ORR NL0, NL2, NL0
; 1F98:       007C7F92         AND NL0, NL0, #8589934590
; 1F9C:       69B286D2         MOVZ TMP, #13715
; 1FA0:       E970A3F2         MOVK TMP, #7047, LSL #16
; 1FA4:       007C099B         MUL NL0, NL0, TMP
; 1FA8:       007C7F92         AND NL0, NL0, #8589934590
; 1FAC:       600000CA         EOR NL0, NL3, NL0
; 1FB0:       02C873D3         LSL NL2, NL0, #13
; 1FB4:       01FC5393         ASR NL1, NL0, #19
; 1FB8:       20F87F92         AND NL0, NL1, #18446744073709551614
; 1FBC:       400000AA         ORR NL0, NL2, NL0
; 1FC0:       007C7F92         AND NL0, NL0, #8589934590
; 1FC4:       0008008B         ADD NL0, NL0, NL0, LSL #2
; 1FC8:       01D99AD2         MOVZ NL1, #54984
; 1FCC:       0195B9F2         MOVK NL1, #52392, LSL #16
; 1FD0:       2100C0F2         MOVK NL1, #1, LSL #32
; 1FD4:       0000018B         ADD NL0, NL0, NL1
; 1FD8:       007C7F92         AND NL0, NL0, #8589934590
; 1FDC:       00047DD2         EOR NL0, NL0, #24
; 1FE0:       01FC5093         ASR NL1, NL0, #16
; 1FE4:       22F87F92         AND NL2, NL1, #18446744073709551614
; 1FE8:       000002CA         EOR NL0, NL0, NL2
; 1FEC:       694D99D2         MOVZ TMP, #51819
; 1FF0:       69BDB0F2         MOVK TMP, #34283, LSL #16
; 1FF4:       007C099B         MUL NL0, NL0, TMP
; 1FF8:       007C7F92         AND NL0, NL0, #8589934590
; 1FFC:       01FC4D93         ASR NL1, NL0, #13
; 2000:       22F87F92         AND NL2, NL1, #18446744073709551614
; 2004:       000002CA         EOR NL0, NL0, NL2
; 2008:       A9C695D2         MOVZ TMP, #44597
; 200C:       4956B8F2         MOVK TMP, #49842, LSL #16
; 2010:       007C099B         MUL NL0, NL0, TMP
; 2014:       007C7F92         AND NL0, NL0, #8589934590
; 2018:       01FC5093         ASR NL1, NL0, #16
; 201C:       22F87F92         AND NL2, NL1, #18446744073709551614
; 2020:       000002CA         EOR NL0, NL0, NL2
; 2024:       401700F9         STR NL0, [CFP, #40]
; 2028:       4A0B40F9         LDR R0, [CFP, #16]
; 202C:       4B5141F8         LDR R1, [R0, #21]
; 2030:       7A0300F9         STR CFP, [CSP]
; 2034:       4A1740F9         LDR R0, [CFP, #40]
; 2038:       EC031DAA         MOV R2, NULL
; 203C:       B6E3FF58         LDR LEXENV, #x70055B1CB0       ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 2040:       FA031BAA         MOV CFP, CSP
; 2044:       DE9240F8         LDR LR, [LEXENV, #9]
; 2048:       C0033FD6         BLR LR
; 204C:       FB0319AA         MOV CSP, OCFP
; 2050:       EB030AAA         MOV R1, R0
; 2054:       2AE3FF58         LDR R0, #x70055B1CB8           ; #<SB-KERNEL:FDEFN CONFIG-LOOKUP-EQUAL>
; 2058:       4D1140F8         LDR R3, [R0, #1]
; 205C:       BF011DEB         CMP R3, NULL
; 2060:       00130054         BEQ L17
; 2064:       7A0300F9         STR CFP, [CSP]
; 2068:       4A0F40F9         LDR R0, [CFP, #24]
; 206C:       2CE5FF58         LDR R2, #x70055B1D10           ; :TEST
; 2070:       96E2FF58         LDR LEXENV, #x70055B1CC0       ; #<SB-KERNEL:FDEFN FIND>
; 2074:       170180D2         MOVZ NARGS, #8
; 2078:       FA031BAA         MOV CFP, CSP
; 207C:       DE9240F8         LDR LR, [LEXENV, #9]
; 2080:       C0033FD6         BLR LR
; 2084:       EF030AAA         MOV R5, R0
; 2088:       FF011DEB         CMP R5, NULL
; 208C:       60080054         BEQ L9
; 2090:       E10D4092         AND NL1, R5, #15
; 2094:       3F0C00F1         CMP NL1, #3
; 2098:       C1070054         BNE L8
; 209C:       EE5140F8         LDR R4, [R5, #5]
; 20A0:       C25145B8         LDR WNL2, [R4, #85]
; 20A4:       01E5FF18         LDR WNL1, #x70055B1D44
; 20A8:       5F00016B         CMP WNL2, WNL1
; 20AC:       21070054         BNE L8
; 20B0:       EBD141F8         LDR R1, [R5, #29]
; 20B4:       4A0F40F9         LDR R0, [CFP, #24]
; 20B8:       4CD141F8         LDR R2, [R0, #29]
; 20BC:       4A0B40F9         LDR R0, [CFP, #16]
; 20C0:       4AD141F8         LDR R0, [R0, #29]
; 20C4:       5F011DEB         CMP R0, NULL
; 20C8:       AAE30091         ADD R0, NULL, #56              ; T
; 20CC:       4D019D9A         CSEL R3, R0, NULL, EQ
; 20D0:       4F1B00F9         STR R5, [CFP, #48]
; 20D4:       7A0300F9         STR CFP, [CSP]
; 20D8:       EA030BAA         MOV R0, R1
; 20DC:       EB030CAA         MOV R1, R2
; 20E0:       EC030DAA         MOV R2, R3
; 20E4:       4D1340F9         LDR R3, [CFP, #32]
; 20E8:       16DFFF58         LDR LEXENV, #x70055B1CC8       ; #<SB-KERNEL:FDEFN MERGE-CONTEXTS>
; 20EC:       170180D2         MOVZ NARGS, #8
; 20F0:       FA031BAA         MOV CFP, CSP
; 20F4:       DE9240F8         LDR LR, [LEXENV, #9]
; 20F8:       C0033FD6         BLR LR
; 20FC:       3B039B9A         CSEL CSP, OCFP, CSP, EQ
; 2100:       4F1B40F9         LDR R5, [CFP, #48]
; 2104:       5F011DEB         CMP R0, NULL
; 2108:       20010054         BEQ L3
; 210C:       410D4092         AND NL1, R0, #15
; 2110:       3F0C00F1         CMP NL1, #3
; 2114:       A1030054         BNE L7
; 2118:       4E5140F8         LDR R4, [R0, #5]
; 211C:       C25145B8         LDR WNL2, [R4, #85]
; 2120:       41E1FF18         LDR WNL1, #x70055B1D48
; 2124:       5F00016B         CMP WNL2, WNL1
; 2128:       01030054         BNE L7
; 212C: L3:   E9794BD3         UBFM TMP, R5, #11, #30
; 2130:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 2134:       EAD101F8         STR R0, [R5, #29]
; 2138:       E0D142F8         LDR NL0, [R5, #45]
; 213C:       4A0F40F9         LDR R0, [CFP, #24]
; 2140:       41D142F8         LDR NL1, [R0, #45]
; 2144:       1F0001EB         CMP NL0, NL1
; 2148:       20B0809A         CSEL NL0, NL1, NL0, LT
; 214C:       E0D102F8         STR NL0, [R5, #45]
; 2150:       EA5143F8         LDR R0, [R5, #53]
; 2154:       5F011DEB         CMP R0, NULL
; 2158:       20010054         BEQ L6
; 215C: L4:   E9794BD3         UBFM TMP, R5, #11, #30
; 2160:       9F6B2938         STRB WZR, [CARDTABLE, TMP]
; 2164:       EA5103F8         STR R0, [R5, #53]
; 2168: L5:   AAE30091         ADD R0, NULL, #56              ; T
; 216C:       FB031AAA         MOV CSP, CFP
; 2170:       5A7B40A9         LDP CFP, LR, [CFP]
; 2174:       BF0300F1         CMP NULL, #0
; 2178:       C0035FD6         RET
; 217C: L6:   4A0F40F9         LDR R0, [CFP, #24]
; 2180:       4A5143F8         LDR R0, [R0, #53]
; 2184:       F6FFFF17         B L4
; 2188: L7:   604321D4         BRK #2587                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R0
; 218C:       57               BYTE #X57                      ; '(OR NULL
                                                              ;      PREDICTION-CONTEXT)
; 218D:       .ALIGN           4
; 2190: L8:   60E321D4         BRK #3867                      ; OBJECT-NOT-TYPE-ERROR
                                                              ; R5
; 2194:       43               BYTE #X43                      ; #<SB-KERNEL:LAYOUT (ID=395) for ATN-CONFIG {700CD64803}>
; 2195:       .ALIGN           4
; 2198: L9:   4A0B40F9         LDR R0, [CFP, #16]
; 219C:       4D5141F8         LDR R3, [R0, #21]
; 21A0:       BF011DEB         CMP R3, NULL
; 21A4:       40050054         BEQ L12
; 21A8:       4D1300F9         STR R3, [CFP, #32]
; 21AC:       7A0300F9         STR CFP, [CSP]
; 21B0:       4A1740F9         LDR R0, [CFP, #40]
; 21B4:       EB030DAA         MOV R1, R3
; 21B8:       EC031DAA         MOV R2, NULL
; 21BC:       B6D7FF58         LDR LEXENV, #x70055B1CB0       ; #<SB-KERNEL:FDEFN SB-IMPL::GETHASH3>
; 21C0:       FA031BAA         MOV CFP, CSP
; 21C4:       DE9240F8         LDR LR, [LEXENV, #9]
; 21C8:       C0033FD6         BLR LR
; 21CC:       FB0319AA         MOV CSP, OCFP
; 21D0:       4D1340F9         LDR R3, [CFP, #32]
; 21D4:       BD2A00B9         STR WNULL, [THREAD, #40]       ; pseudo-atomic-bits
; 21D8:       A9FA45A9         LDP TMP, LR, [THREAD, #88]     ; cons-tlab.{free-pointer, end-addr}
; 21DC:       2C410091         ADD R2, TMP, #16
; 21E0:       9F011EEB         CMP R2, LR
; 21E4:       08070054         BHI L18
; 21E8:       AC2E00F9         STR R2, [THREAD, #88]          ; cons-tlab
; 21EC: L10:  2C1D0091         ADD R2, TMP, #7
; 21F0:       4F0F40F9         LDR R5, [CFP, #24]
; 21F4:       2F2900A9         STP R5, R0, [TMP]
; 21F8:       BF2A00B9         STR WZR, [THREAD, #40]         ; pseudo-atomic-bits
; 21FC:       BE2E40B9         LDR WLR, [THREAD, #44]         ; pseudo-atomic-bits
; 2200:       5E0000B4         CBZ LR, L11
; 2204:       200120D4         BRK #9                         ; Pending interrupt trap
; 2208: L11:  7A0300F9         STR CFP, [CSP]
; 220C:       4A1740F9         LDR R0, [CFP, #40]
; 2210:       EB030DAA         MOV R1, R3
; 2214:       F6D5FF58         LDR LEXENV, #x70055B1CD0       ; #<SB-KERNEL:FDEFN SB-KERNEL:%PUTHASH>
; 2218:       FA031BAA         MOV CFP, CSP
; 221C:       DE9240F8         LDR LR, [LEXENV, #9]
; 2220:       C0033FD6         BLR LR
; 2224:       4A0B40F9         LDR R0, [CFP, #16]
; 2228:       4BD140F8         LDR R1, [R0, #13]
; 222C:       7A0300F9         STR CFP, [CSP]
; 2230:       4A0F40F9         LDR R0, [CFP, #24]
; 2234:       36D5FF58         LDR LEXENV, #x70055B1CD8       ; #<SB-KERNEL:FDEFN VECTOR-PUSH-EXTEND>
; 2238:       970080D2         MOVZ NARGS, #4
; 223C:       FA031BAA         MOV CFP, CSP
; 2240:       DE9240F8         LDR LR, [LEXENV, #9]
; 2244:       C0033FD6         BLR LR
; 2248:       C8FFFF17         B L5
; 224C: L12:  40B323D4         BRK #7578                      ; OBJECT-NOT-HASH-TABLE-ERROR
                                                              ; NULL
; 2250: L13:  431700F9         STR NL3, [CFP, #40]
; 2254:       4A0F40F9         LDR R0, [CFP, #24]
; 2258:       4A5142F8         LDR R0, [R0, #37]
; 225C:       7A0300F9         STR CFP, [CSP]
; 2260:       16D4FF58         LDR LEXENV, #x70055B1CE0       ; #<SB-KERNEL:FDEFN SXHASH>
; 2264:       570080D2         MOVZ NARGS, #2
; 2268:       FA031BAA         MOV CFP, CSP
; 226C:       DE9240F8         LDR LR, [LEXENV, #9]
; 2270:       C0033FD6         BLR LR
; 2274:       431740F9         LDR NL3, [CFP, #40]
; 2278:       407D7F92         AND NL0, R0, #8589934590
; 227C:       3FFFFF17         B L2
; 2280: L14:  4A0B40F9         LDR R0, [CFP, #16]
; 2284:       ABE30091         ADD R1, NULL, #56              ; T
; 2288:       4BD103F8         STR R1, [R0, #61]
; 228C:       16FFFF17         B L1
; 2290: L15:  4A0B40F9         LDR R0, [CFP, #16]
; 2294:       ABE30091         ADD R1, NULL, #56              ; T
; 2298:       4B5103F8         STR R1, [R0, #53]
; 229C:       0EFFFF17         B L0
; 22A0: L16:  0AD4FF58         LDR R0, #x70055B1D20           ; "ATNConfigSet is read-only"
; 22A4:       570080D2         MOVZ NARGS, #2
; 22A8:       29D280D2         MOVZ TMP, #1681
; 22AC:       BE6B69F8         LDR LR, [NULL, TMP]            ; ERROR
; 22B0:       DE130091         ADD LR, LR, #4
; 22B4:       C0031FD6         BR LR
; 22B8:       E00120D4         BRK #15                        ; Invalid argument count trap
; 22BC:       E08221D4         BRK #3095                      ; UNBOUND-SYMBOL-ERROR
                                                              ; R2
; 22C0: L17:  204221D4         BRK #2577                      ; UNDEFINED-FUN-ERROR
                                                              ; R0
; 22C4: L18:  090280D2         MOVZ TMP, #16
; 22C8:       8CD3FF58         LDR R2, #x70055B1D38           ; SB-VM::LIST-ALLOC-TRAMP
; 22CC:       80013FD6         BLR R2
; 22D0:       C7FFFF17         B L10
