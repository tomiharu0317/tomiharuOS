memcpy:

        ; スタックフレームの構築

        push    bp
        mov     bp, sp

        
        ; ローカル変数として使用するレジスタの保存

        push    cx
        push    si
        push    di

        ; バイト単位でのコピー

        cld                                 ; DF = 0
        mov     di, [bp + 4]
        mov     si, [bp + 6]
        mov     cx, [bp + 8]

        rep movsb                           ; while (*DI++ == *SI++) ;

        ; レジスタの復帰

        pop     di
        pop     si
        pop     cx

        ; スタックフレームの破棄

        mov     sp, bp
        pop     bp

        ret