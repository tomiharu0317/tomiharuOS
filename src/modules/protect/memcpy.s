memcpy:

        ; construct stack frame

        push    ebp
        mov     ebp, esp

        ; save registers

        push    ecx
        push    esi
        push    edi

        ; copy byte by byte

        cld
        mov     edi, [ebp + 8]
        mov     esi, [ebp + 12]
        mov     ecx, [ebp + 16]

        rep movsb

        ; return registers

        pop     edi
        pop     esi
        pop     ecx

        ; destruct stack frame

        mov     esp, ebp
        pop     ebp

        ret