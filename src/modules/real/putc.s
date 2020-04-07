putc:

        ;スタックフレームの構築

        push    bp
        mov     bp, sp                                  ;  +4 | 出力文字
                                                        ;  +2 | Instruction Pointer
                                                        ;BP+0 | BP

        ;破壊される可能性のあるレジスタを保存

        push    ax
        push    bx

        ;処理

        mov     al, [bp + 4]
        mov     ah, 0x0E
        mov     bx, 0x0000
        int     0x10

        ;レジスタの復帰

        pop     bx
        pop     ax

        ;スタックフレームの破棄

        mov     sp, bp
        pop     bp

        ret