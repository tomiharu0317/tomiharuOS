putc:

        ; construct stack frame

        push    bp
        mov     bp, sp                                  ;  +4 | input char
                                                        ;  +2 | Instruction Pointer
                                                        ;BP+0 | BP

        ; save registers

        push    ax
        push    bx

        mov     al, [bp + 4]
        mov     ah, 0x0E
        mov     bx, 0x0000
        int     0x10

        ; return registers

        pop     bx
        pop     ax

        ; destruct stack frame

        mov     sp, bp
        pop     bp

        ret