put_mem_info:

            ; construct stack frame
            push    bp                              ;BP +4 | buffer address of where the memory info is stored
            mov     bp, sp

            ; save registers
            push    bx
            push    si

            ; get args
            mov     si, [bp + 4]

            ; Base(64bit)
            cdecl int_to_str, word [si + 6], .p2 + 0, 4, 16, 0x0100
            cdecl int_to_str, word [si + 4], .p2 + 4, 4, 16, 0x0100
            cdecl int_to_str, word [si + 2], .p3 + 0, 4, 16, 0x0100
            cdecl int_to_str, word [si + 0], .p3 + 4, 4, 16, 0x0100

            ; Length(64bit)
            cdecl int_to_str, word [si + 14], .p4 + 0, 4, 16, 0x0100
            cdecl int_to_str, word [si + 12], .p4 + 4, 4, 16, 0x0100
            cdecl int_to_str, word [si + 10], .p5 + 0, 4, 16, 0x0100
            cdecl int_to_str, word [si + 8 ], .p5 + 4, 4, 16, 0x0100

            ; Type(32bit)
            cdecl int_to_str, word [si + 18], .p6 + 0, 4, 16, 0x0100
            cdecl int_to_str, word [si + 16], .p6 + 4, 4, 16, 0x0100

            cdecl   puts, .s1                       ; // display record info

.s1:        db  " "
.p2:        db  "ZZZZZZZZ_"
.p3:        db  "ZZZZZZZZ "
.p4:        db  "ZZZZZZZZ_"
.p5:        db  "ZZZZZZZZ "
.p6:        db  "ZZZZZZZZ ", 0

            mov     bx, [si + 16]                   ; // display type as strings
            and     bx, 0x07                        ; BX = Type(0~5)
            shl     bx, 1                           ; BX *= 2   // convert to element size
            add     bx, .t0                         ; BX += .t0 // add the start address of the table
            cdecl   puts, word [bx]

.s4:        db  " (nknown)", 0x0A, 0x0D, 0
.s5:        db  " (usable)", 0x0A, 0x0D, 0
.s6:        db  " (reserved)", 0x0A, 0x0D, 0
.s7:        db  " (ACPI data)", 0x0A, 0x0D, 0
.s8:        db  " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:        db  " (bad memory)", 0x0A, 0x0D, 0

.t0:        dw  .s4, .s5, .s6, .s7, .s8, .s4, .s4

            ; return registers
            pop     si
            pop     bx

            ; destruct stack frame
            mov     sp, bp
            pop     bp

            ret
