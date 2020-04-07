puts:

        ;スタックフレームの構築

        push    bp
        mov     bp, sp                                  ;  +4 | 文字列へのアドレス
                                                        ;  +2 | Instruction Pointer
                                                        ;BP+0 | BP

        ;レジスタを保存

        push    ax
        push    bx
        push    si

        ;引数の取得

        mov     si, [bp + 4]                            ;Source Index == 文字列へのアドレス

        ;処理

        mov     ah, 0x0E
        mov     bx, 0x0000
        cld

.10L:                                                   ;do{
                                                        ;   AL = *SI++
        lodsb                                           ;
                                                        ;   if (0 == AL)
        cmp     al, 0                                   ;       break;
        je      .10E                                    ;
                                                        ;   Int10(0x0E, AL); //文字出力
        int     0x10                                    ;} while(1);
        jmp     .10L

.10E:

        ;レジスタの復帰

        pop     si
        pop     bx
        pop     ax

        ;スタックフレームの破棄

        mov     sp, bp
        pop     bp

        ret