int_to_str:

        ;construct stack frame

        push    bp
        mov     bp, sp                          ;  +12|フラグ
                                                ;  +10|基数
                                                ;  + 8|保存先バッファサイズ
                                                ;  + 6|保存先バッファアドレス
                                                ;  + 4|変換する値
                                                ;  + 2|IP(戻り番地)
                                                ;BP+ 0|BP
        ;レジスタの保存

        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        ;引数の取得

        mov     eax, [bp + 4]                    ;val = 数値
        mov     esi, [bp + 6]                    ;dest= バッファアドレス
        mov     ecx, [bp + 8]                    ;esize= バッファサイズ

        mov     edi, esi                          ;バッファの最後尾
        add     edi, ecx                          ;dest = &dest[esize - 1]
        dec     edi

        mov     ebx, word [bp + 12]              ;flags = フラグ
                                                ;B2: 空白をゼロで埋める B1:+/-記号を付加する B0:値を符号付き変数として扱う

        ;符号付き判定

        test    ebx, 0b0001                      ; if (flags & 0x01) //符号付きならZF = 0
.10Q    je      .10E                            ; {                 //符号なしならZF = 1だからjmp
        cmp     eax, 0                           ;   if (val < 0)    //CF = 1, ZF = 0
.12Q    jge     .12E                            ;   {               //val >= 0 なら必要ないのでjmp
        or      ebx, 0b0010                      ;       flags |= 2; //B1をセット
                                                ;}}
.12E:
.10E:

        ;符号出力判定

        test    ebx, 0b0010
.20Q    je      .20E
        cmp     eax, 0
.22Q    jge     .22F
        neg     eax                              ;符号反転
        mov     [esi], byte '-'                  ;符号表示
        jmp     .22E
.22F:
        mov     [esi], byte '+'
.22E:
        dec     ecx                              ;残りバッファサイズの減算 -> ?
.20E:

        ;ASCII変換

        mov     ebx, [bp + 10]                   ;ebx = 基数

.30L:                                           ;do{
        mov     edx, 0
        ediv     ebx                              ;   edx = edx:eax % ebx;
                                                ;   eax = edx:eax / ebx;

        mov     esi, edx                          ;   //変換テーブル参照
        mov     dl, byte [.ascii + esi]          ;   DL = ASCII[edx];

        mov     [edi], dl                        ;   *dest = DL;
        dec     edi                              ;   dest--;

        cmp     eax, 0
        loopnz  .30L                            ;} while(eax);

.30E:

        ;空欄をゼロ埋め/空白埋め

        cmp     ecx, 0                           ;if (esize)
.40Q:   je      .40E                            ;{
        mov     al, ' '                         ;   AL = ' '; //空白埋め
        cmp     [bp + 12], word 0b0100          ;   if (flags & 0x04)
.42Q:   jne     .42E                            ;   {
        mov     al, '0'                         ;       AL = '0'; //ゼロ埋め
.42E:                                           ;   }
        std                                     ;   // DF = 1(減算)
        rep stosb                               ;   while (--ecx) * edi-- = ' ';
.40E:                                           ;}

        ;レジスタの復帰

        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ;スタックフレームの破棄

        mov     sp, bp
        pop     bp

        ret


.ascii  db      "0123456789ABCDEF"              ;変換テーブル0