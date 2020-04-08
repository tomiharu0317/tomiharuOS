int_to_str:

        ;スタックフレームの構築

        push    bp
        mov     bp, sp                          ;  +12|フラグ
                                                ;  +10|基数
                                                ;  + 8|保存先バッファサイズ
                                                ;  + 6|保存先バッファアドレス
                                                ;  + 4|変換する値
                                                ;  + 2|IP(戻り番地)
                                                ;BP+ 0|BP
        ;レジスタの保存

        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di

        ;引数の取得

        mov     ax, [bp + 4]                    ;val = 数値
        mov     si, [bp + 6]                    ;dest= バッファアドレス
        mov     cx, [bp + 8]                    ;size= バッファサイズ

        mov     di, si                          ;バッファの最後尾
        add     di, cx                          ;dest = &dest[size - 1]
        dec     di

        mov     bx, word [bp + 12]              ;flags = フラグ
                                                ;B2: 空白をゼロで埋める B1:+/-記号を付加する B0:値を符号付き変数として扱う

        ;符号付き判定

        test    bx, 0b0001                      ; if (flags & 0x01) //符号付きならZF = 0
.10Q    je      .10E                            ; {                 //符号なしならZF = 1だからjmp
        cmp     ax, 0                           ;   if (val < 0)    //CF = 1, ZF = 0
.12Q    jge     .12E                            ;   {               //val >= 0 なら必要ないのでjmp
        or      bx, 0b0010                      ;       flags |= 2; //B1をセット
                                                ;}}
.12E:
.10E:

