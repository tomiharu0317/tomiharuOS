lba_chs:

            ; construct stack frame
            push    bp
            mov     bp, sp                                  ;  +8 | LBA value
                                                            ;  +6 | address of drive struc(where conversed parameters will be stored)
                                                            ;BP+4 | address of drive struc(where drive parameters are stored)

            ; save registers

            push    ax
            push    bx
            push    dx
            push    si
            push    di

            ; start of process

            mov     si, [bp + 4]
            mov     di, [bp + 6]

            mov     al,  [si + drive.head]                  ; AL = max head num
            mul     byte [si + drive.sect]                  ; AX = max head * max sect
            mov     bx, ax                                  ; BX = num of sect per cylinder

            mov     dx, 0                                   ; DX = LBA(top 2 byte)
            mov     ax, [bp + 8]                            ; AX = LBA(lower 2 byte)
            div     bx                                      ; AX = DX:AX / BX   => cylinder number
                                                            ; DX = DX:AX % BX

            mov     [di + drive.cyln], ax

            mov     ax, dx
            div     byte [si + drive.sect]                  ; AL = AX / max num of sect => head number
                                                            ; AH = AX % max num of sect => sector number

            movzx   dx, ah                                  ; DX = sector number
            inc     dx                                      ; sect starts from no.1

            mov     ah, 0x00                                ; AX = head num

            mov     [di + drive.head], ax
            mov     [di + drive.sect], dx

            ; return registers
            pop     di
            pop     si
            pop     dx
            pop     bx
            pop     ax

            ; destruct stack frame
            mov     sp, bp
            pop     bp

            ret