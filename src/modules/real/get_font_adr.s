get_font_adr:

            ;スタックフレームの構築
            push    bp                                          ; BP+4 | フォントアドレスの格納位置
            mov     bp, sp

            ;レジスタの保存

            push    ax
            push    bx
            push    si
            push    es
            push    bp

            ;引数の取得
            mov     si, [bp + 4]

            ;フォントアドレスの取得
            mov     ax, 0x1130
            mov     bh, 0x06                                    ;8 x 16 font(vga/mcga)
            int     0x10                                        ;ES:BP = Font Address

            ;フォントアドレスを保存
            mov     [si + 0], es                                ;dest[0] = セグメント
            mov     [si + 2], bx                                ;dest[1] = オフセット

            ;レジスタの復帰
            pop     bp
            pop     es
            pop     si
            pop     bx
            pop     ax

            ;スタックフレームの破棄
            mov     sp, bp
            pop     bp

            ret