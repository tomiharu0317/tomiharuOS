draw_font:

            ; construct stack frame
            push    ebp                                         ;   +12 | column
            mov     ebp, esp                                    ;EBP+ 8 | row

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    esi
            push    edi

            ; get arguments
            mov     esi, [ebp + 8]
            mov     edi, [ebp + 12]

            ; loop
            mov     ecx, 0                                      ; for (ECX = 0; ECX < 256; ECX++)
.10L:       cmp     ecx, 256
            jae     .10E

            ; figure out current column
            mov     eax, ecx
            and     eax, 0x0F                                   ; begin on a new line per 16 chars
            add     eax, esi

            ; figure out current row
            mov     ebx, ecx
            shr     ebx, 4
            add     ebx, edi

            cdecl   draw_char, eax, ebx, 0x07, ecx

            inc     ecx
            jmp     .10L
.10E:

            ; return registers
            pop     edi
            pop     esi
            pop     edx
            pop     ecx
            pop     ebx
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret