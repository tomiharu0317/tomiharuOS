get_font_adr:

            ; construct stack frame
            push    bp                                          ; BP+4 | where font address is located
            mov     bp, sp

            ; save registers
            push    ax
            push    bx
            push    si
            push    es
            push    bp

            ; get argumentes
            mov     si, [bp + 4]

            ; get font address
            mov     ax, 0x1130
            mov     bh, 0x06                                    ;8 x 16 font(vga/mcga)
            int     10h                                         ;ES:BP = Font Address

            ; save font address
            mov     [si + 0], es                                ;dest[0] = segment
            mov     [si + 2], bp                                ;dest[1] = offset

            ; return registers
            pop     bp
            pop     es
            pop     si
            pop     bx
            pop     ax

            ; destruct stack frame
            mov     sp, bp
            pop     bp

            ret