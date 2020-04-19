draw_str:

            ; construct stack frame
            push    ebp                                         ;   +20 | address of string
            mov     ebp, esp                                    ;   +16 | color
                                                                ;   +12 | row
                                                                ;EBP+ 8 | column

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    esi
            push    edi

            ; get arguments
            mov     ecx, [ebp + 8]
            mov     edx, [ebp + 12]
            movzx   ebx, word [ebp + 16]
            mov     esi, [ebp + 20]

            ; main process
            cld                                                 ; DF = 0 // address addition
.10L:
            lodsb                                               ; AL = *ESI++ // get char
            cmp     al, 0                                       ; if (AL == 0) break;
            je      .10E

            cdecl   draw_char, ecx, edx, ebx, eax

            inc     ecx
            cmp     ecx, 80                                     ; if (80 <= ECX)
            jl      .12E                                        ; {
            mov     ecx, 0                                      ;   ECX = 0;
            inc     edx                                         ;   EDX++;
            cmp     edx, 30                                     ;   if (30 <= EDX)
            jl      .12E                                        ;   {
            mov     edx, 0                                      ;     EDX = 0;
                                                                ;   }
.12E:                                                           ; }
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