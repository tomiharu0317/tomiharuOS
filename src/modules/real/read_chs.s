read_chs:

            ; construct stack frame
                                                    ;   +8 | 読み出し先アドレス
                                                    ;   +6 | セクタ数
                                                    ;   +4 | drive構造体のアドレス
                                                    ;   +2 | 戻り番地
                                                    ;BP +0 | BP
                                                    ;   -2 | retry = 3; //リトライ回数
                                                    ;   -4 | sect  = 0; //読み込みセクタ数
            push    bp
            mov     bp, sp
            push    3
            push    0

            ; save registers

            push    bx
            push    cx
            push    dx
            push    es
            push    si

            ; main process
            mov     si, [bp + 4]                    ;構造体のアドレス

            ;CXレジスタの設定
            ;[構造体のアドレス + オフセット + ?]

            mov     ch, [si + drive.cyln + 0]       ;CH = シリンダ番号（下位バイト）
            mov     cl, [si + drive.cyln + 1]       ;CL = シリンダ番号（上位バイト）
            shl     cl, 6                           ;CL <<= 6; //最上位2ビットにシフト
            or      cl, [si + drive.sect]           ;CL |= セクタ番号;

            ;セクタ読み込み

            mov     dh, [si + drive.head]           ;DH = ヘッド番号
            mov     dl, [si + 0]                    ;DL = ドライブ番号
            mov     ax, 0x0000
            mov     es, ax                          ;ESセグメント初期化
            mov     bx, [bp + 8]                    ;読み出し先アドレス

            ; do{
            ;     AH = セクタ読み込み
            ;     AL = セクタ数

            ;     CF = BIOS(0x13, 0x02);
            ;     if (CF)
            ;     {
            ;         AL = 0;
            ;         break;
            ;     }

            ;     if (読み込んだセクタがある)
            ;         break;

            ;     ret = 0;
            ; } while(--retry);

.10L:
            mov     ah, 0x02
            mov     al, [bp + 6]

            int     0x13
            jnc     .11E                            ;成功したら.11Eへ

            mov     al, 0
            jmp     .10E                            ;失敗したらリトライなしで.10Eへ
.11E:
            cmp     al, 0                           ; if (読み込んだセクタ数 > 0)
            jne     .10E                            ;   break;

            mov     ax, 0                           ;戻り値
            dec     word [bp - 2]
            jnz     .10L                            ;読み込んだセクタ数が0なら.10Lへ
.10E:
            mov     ah, 0                           ;AH = 0 //ステータス情報の破棄

            ;レジスタの復帰

            pop     si
            pop     es
            pop     dx
            pop     cx
            pop     bx

            ;スタックフレームの破棄

            mov     sp, bp
            pop     bp

            ret