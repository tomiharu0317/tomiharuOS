draw_color_bar:

            ; construct stack frame
            push    ebp                                             ;   +12 | row
            mov     ebp, esp                                        ;EBP+ 8 | column

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

            ; display color bar
            mov     ecx, 0                                          ; for(ECX = 0; ECX < 16;; ECX++)
.10L:       cmp     ecx, 16
            jae     .10E

            ; column
            mov     eax, ecx
            and     eax, 0x01
            shl     eax, 3                                          ; EAX *= 8
            add     eax, esi                                        ; EAX += column

            ; row
            mov     ebx, ecx
            shr     ebx, 1                                          ; EBX /= 2
            add     ebx, edi                                        ; EBX += row

            ; display string and background color are created in table
            mov     edx, ecx
            shl     edx, 1                                          ; EDX /= 2
            mov     edx, [.t0 + edx]                                ; EDX += row

            cdecl   draw_str, eax, ebx, edx, .s0

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
            mov     ebp, esp
            pop     ebp

            ret

.s0:        db  '        ', 0                                        ; space for 8 char

.t0:        dw  0x0000, 0x0800                                       ; background color
            dw  0x0100, 0x0900
            dw  0x0200, 0x0A00
            dw  0x0300, 0x0B00
            dw  0x0400, 0x0C00
            dw  0x0500, 0x0D00
            dw  0x0600, 0x0E00
            dw  0x0700, 0x0F00
