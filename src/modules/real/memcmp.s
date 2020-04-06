memcmp:

        ;スタックフレームの構築
                                        
                                        ;BP+ 8 | バイト数
                                        ;BP+ 6 | アドレス1
                                        ;BP+ 4 | アドレス0
                                        ;------|---------
                                        ;BP+ 2 | IP(戻り番地)
                                        ;BP+ 0 | BP(元の値)
        push    bp                  
        mov     bp, sp

        ;レジスタの保存

        push    bx
        push    cx
        push    dx
        push    si
        push    di

        ;引数の取得

        cld
        mov     si, [bp + 4]
        mov     di, [bp + 6]
        mov     cx, [bp + 8]

        ;バイト単位での比較

        repe cmpsb                      ; if(ZF = 異なる文字なし)
        jnz     .10F                    ; {
        mov     ax, 0                   ; ret = 0; // 一致
        jmp     .10E                    ; }
.10F:                                   ; else
        mov     ax, -1                  ; {
.10E:                                   ; ret = -1 // 不一致
                                        ; }
        
        ;レジスタの復帰

        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx

        ;スタックフレームの破棄

        mov     sp, bp
        pop     bp

        ret
