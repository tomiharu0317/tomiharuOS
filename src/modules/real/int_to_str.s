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

        ;符号出力判定

        test    bx, 0b0010
.20Q    je      .20E
        cmp     ax, 0
.22Q    jge     .22F
        neg     ax                              ;符号反転
        mov     [si], byte '-'                  ;符号表示
        jmp     .22E
.22F:
        mov     [si], byte '+'
.22E:
        dec     cx                              ;残りバッファサイズの減算 -> ?
.20E:

        ;ASCII変換

        mov     bx, [bp + 10]                   ;BX = 基数

.30L:                                           ;do{
        mov     dx, 0
        div     bx                              ;   DX = DX:AX % BX;
                                                ;   AX = DX:AX / BX;

        mov     si, dx                          ;   //変換テーブル参照
        mov     dl, byte [.ascii + si]          ;   DL = ASCII[DX];

        mov     [di], dl                        ;   *dest = DL;
        dec     di                              ;   dest--;

        cmp     ax, 0
        loopnz  .30L                            ;} while(AX);

.30E:

        ;空欄をゼロ埋め/空白埋め

        cmp     cx, 0                           ;if (size)
.40Q:   je      .40E                            ;{
        mov     al, ' '                         ;   AL = ' '; //空白埋め
        cmp     [bp + 12], word 0b0100          ;   if (flags & 0x04)
.42Q:   jne     .42E                            ;   {
        mov     al, '0'                         ;       AL = '0'; //ゼロ埋め
.42E:                                           ;   }
        std                                     ;   // DF = 1(減算)
        rep stosb                               ;   while (--cx) * DI-- = ' ';
.40E:                                           ;}

        ;レジスタの復帰

        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax

        ;スタックフレームの破棄

        mov     sp, bp
        pop     bp

        ret


.ascii  db      "0123456789ABCDEF"              ;変換テーブル