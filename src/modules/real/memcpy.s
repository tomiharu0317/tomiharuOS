memcpy:

        ; construct stack frame

        push    bp
        mov     bp, sp

        ; save registers used as local variables

        push    cx
        push    si
        push    di

        ; copy byte by byte

        cld                                 ; DF = 0
        mov     di, [bp + 4]
        mov     si, [bp + 6]
        mov     cx, [bp + 8]

        rep movsb                           ; while (*DI++ == *SI++) ;

        ; return registers

        pop     di
        pop     si
        pop     cx

        ; destruct stack frame

        mov     sp, bp
        pop     bp

        ret