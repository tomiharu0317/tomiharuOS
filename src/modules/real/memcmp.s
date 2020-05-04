memcmp:

        ; construct stack frame

                                        ;BP+ 8 | num of byte
                                        ;BP+ 6 | address1
                                        ;BP+ 4 | address0
                                        ;------|---------
                                        ;BP+ 2 | IP(instruction pointer)
                                        ;BP+ 0 | BP
        push    bp
        mov     bp, sp

        ; save registers

        push    bx
        push    cx
        push    dx
        push    si
        push    di

        ; get args

        cld
        mov     si, [bp + 4]
        mov     di, [bp + 6]
        mov     cx, [bp + 8]

        ; compare byte by byte

        repe cmpsb                      ; if(ZF = no different char)
        jnz     .10F                    ; {
        mov     ax, 0                   ; ret = 0; // correspond
        jmp     .10E                    ; }
.10F:                                   ; else
        mov     ax, -1                  ; {
.10E:                                   ; ret = -1 // not correspond
                                        ; }

        ; return registers

        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx

        ; destruct stack frame

        mov     sp, bp
        pop     bp

        ret
