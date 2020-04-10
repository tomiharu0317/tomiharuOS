put_mem_info:

            ;スタックフレームの構築
            push    bp                              ;BP +4 | メモリ情報が格納されたバッファアドレス
            mov     bp, sp

            ;レジスタの保存
            push    bx
            push    si

            ;引数の取得
            mov     si, [bp + 4]