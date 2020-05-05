get_mem_info:

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    si
            push    di
            push    bp

            ; put char
            cdecl   puts, .s0

            mov     bp, 0                           ; lines = 0; // num of lines
            mov     ebx, 0                          ; index = 0; // initialization
.10L:                                               ; do
                                                    ; {
            mov     eax, 0x0000E820                 ;   EAX  = 0xE820;
            mov     ecx, E820_RECORD_SIZE           ;   ECX  = requested bytes;
            mov     edx, 'PAMS'                     ;   EDX  = 'SMAP' // fixed value
            mov     di, .b0                         ;   ES:DI= write_dest
            int     0x15                            ;   BIOS(0x15, 0xE820);
                                                    ; }

            cmp     eax, 'PAMS'                     ; end if command not supported
            je      .12E
            jmp     .10E

.12E:


            jnc     .14E                            ; CF 0:success 1:failure
            jmp     .10E
.14E:

            cdecl   put_mem_info, di                ; display memory info for one record

            ; get ACPI data address
            mov     eax, [di + 16]                  ; EAX = data type
            cmp     eax, 3                          ; 3:AddressRangeACPI
            jne     .15E

            mov     eax, [di + 0]                   ; EAX = BASE address
            mov     [ACPI_DATA.adr], eax

            mov     eax, [di + 8]
            mov     [ACPI_DATA.len], eax
.15E:

            cmp     ebx, 0
            jz      .16E

            inc     bp                              ; lines++
            and     bp, 0x07                        ; lines &= 0x07; // every time 8 lines of memory info are displayed,
            jnz     .16E                            ;                // the process is suspended
                                                    ;                // until there is a key input from the user
            cdecl   puts, .s2                       ; interrupt message
            mov     ah, 0x10                        ; wait for the key to be pressed
            int     0x16

            cdecl   puts, .s3
.16E:

            cmp     ebx, 0
            jne     .10L
.10E:

            cdecl   puts, .s1

            ; return registers
            pop     bp
            pop     di
            pop     si
            pop     edx
            pop     ecx
            pop     ebx
            pop     eax

            ret

.s0:	    db " E820 Memory Map:", 0x0A, 0x0D
		    db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	    db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:	    db " <more...>", 0
.s3:	    db 0x0D, "          ", 0x0D, 0

ALIGN 4, db 0
.b0:    times E820_RECORD_SIZE db 0

put_mem_info:

            ; construct stack frame
            push    bp                              ;BP +4 | buffer address of where memory info is stored
            mov     bp, sp

            ; save registers
            push    bx
            push    si

            ; get args
            mov     si, [bp + 4]

            ; Base(64bit)
            cdecl int_to_str, word [si + 6], .p2 + 0, 4, 16, 0b0100
            cdecl int_to_str, word [si + 4], .p2 + 4, 4, 16, 0b0100
            cdecl int_to_str, word [si + 2], .p3 + 0, 4, 16, 0b0100
            cdecl int_to_str, word [si + 0], .p3 + 4, 4, 16, 0b0100

            ; Length(64bit)
            cdecl int_to_str, word [si + 14], .p4 + 0, 4, 16, 0b0100
            cdecl int_to_str, word [si + 12], .p4 + 4, 4, 16, 0b0100
            cdecl int_to_str, word [si + 10], .p5 + 0, 4, 16, 0b0100
            cdecl int_to_str, word [si + 8 ], .p5 + 4, 4, 16, 0b0100

            ; Type(32bit)
            cdecl int_to_str, word [si + 18], .p6 + 0, 4, 16, 0b0100
            cdecl int_to_str, word [si + 16], .p6 + 4, 4, 16, 0b0100

            cdecl   puts, .s1                       ; // display record info

            mov     bx, [si + 16]                   ; // display type as string
            and     bx, 0x07                        ; BX = Type(0~5)
            shl     bx, 1                           ; BX *= 2   // convert to element size
            add     bx, .t0                         ; BX += .t0 // add the start address of the table
            cdecl   puts, word [bx]

            ; return registers
            pop     si
            pop     bx

            ; destruct stack frame
            mov     sp, bp
            pop     bp

            ret

.s1:        db  " "
.p2:        db  "ZZZZZZZZ_"
.p3:        db  "ZZZZZZZZ "
.p4:        db  "ZZZZZZZZ_"
.p5:        db  "ZZZZZZZZ "
.p6:        db  "ZZZZZZZZ ", 0

.s4:        db  " (Unknown)", 0x0A, 0x0D, 0
.s5:        db  " (usable)", 0x0A, 0x0D, 0
.s6:        db  " (reserved)", 0x0A, 0x0D, 0
.s7:        db  " (ACPI data)", 0x0A, 0x0D, 0
.s8:        db  " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:        db  " (bad memory)", 0x0A, 0x0D, 0

.t0:        dw  .s4, .s5, .s6, .s7, .s8, .s4, .s4