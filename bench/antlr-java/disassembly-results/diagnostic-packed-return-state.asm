; disassembly for DIAGNOSTIC-PACKED-RETURN-STATE
; Size: 52 bytes. Origin: #x70055B49D4                        ; DIAGNOSTIC-PACKED-RETURN-STATE
; 9D4:       40915FF8         LDR NL0, [R0, #-7]
; 9D8:       1F000BEB         CMP NL0, R1
; 9DC:       29010054         BLS L0
; 9E0:       49050B8B         ADD TMP, R0, R1, LSL #1
; 9E4:       201140B8         LDR WNL0, [TMP, #1]
; 9E8:       0AF87FD3         LSL R0, NL0, #1
; 9EC:       FB031AAA         MOV CSP, CFP
; 9F0:       5A7B40A9         LDP CFP, LR, [CFP]
; 9F4:       BF0300F1         CMP NULL, #0
; 9F8:       C0035FD6         RET
; 9FC:       E00120D4         BRK #15                         ; Invalid argument count trap
; A00: L0:   204421D4         BRK #2593                       ; INVALID-VECTOR-INDEX-ERROR
                                                              ; R0
; A04:       2D               BYTE #X2D                       ; R1
; A05:       .ALIGN           4
