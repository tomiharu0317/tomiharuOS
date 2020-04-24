draw_time:

            ; construct stack frame                         ;   +20 | time data
            push    ebp                                     ;   +16 | display color
            mov     ebp, esp                                ;   +12 | row
                                                            ;EBP+ 8 | col

            ; save registers
            push    eax
            push    ebx

            ; get arg
            mov     eax, [ebp + 20]

            movzx   ebx, al                                 ; ebx = second
            cdecl   int_to_str, ebx, .sec, 2, 16, 0b0100

            mov     bl, ah                                  ; ebx = min
            cdecl   int_to_str, ebx, .min, 2, 16, 0b0100

            shr     eax, 16                                 ; ax = hour
            cdecl   int_to_str, eax, .hour, 2, 16, 0b0100

            ; display time
            cdecl   draw_str, dword [ebp + 8], dword [ebp + 12], dword [ebp + 16], .hour

            ; return registers
            pop     ebx
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret

.hour:  db  "ZZ:"
.min:  db  "ZZ:"
.sec:  db  "ZZ", 0
