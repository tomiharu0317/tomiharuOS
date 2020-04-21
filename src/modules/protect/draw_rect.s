draw_rect:

            ; construct stack frame                                 ;   +24 | display color
            push    ebp                                             ;   +20 | Y end
            mov     ebp, esp                                        ;   +16 | X end
                                                                    ;   +12 | Y_start
                                                                    ;EBP+ 8 | X_start

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    esi
            push    edi

            ; get arguments
            mov     eax, [ebp +  8]
            mov     ebx, [ebp + 12]
            mov     ecx, [ebp + 16]
            mov     edx, [ebp + 20]
            mov     esi, [ebp + 24]

            ; confirm the size of the coordinate axes
            cmp     eax, ecx
            jl      .10E
            xchg    eax, ecx
.10E:
            cmp     ebx, edx
            jl      .20E
            xchg    ebx, edx
.20E:

            ; draw rectangle
            cdecl   draw_line, eax, ebx, ecx, ebx, esi              ; upper line
            cdecl   draw_line, eax, ebx, eax, edx, esi              ; left  line

            dec     edx                                             ; // lower line up 1 dot
            cdecl   draw_line, eax, edx, ecx, edx, esi              ; lower line
            inc     edx

            dec     ecx                                             ; // right line left 1 dot
            cdecl   draw_line, ecx, ebx, ecx, edx, esi              ; right line

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