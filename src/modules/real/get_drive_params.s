get_drive_params:

            ;スタックフレームの構築
            push    bp                                  ;BP +4 | drive構造体のアドレス
            mov     bp, sp

            ;レジスタの保存

            push    bx
            push    cx
            push    es
            push    si
            push    di

            ;処理
            mov     si, [bp + 4]

            mov     ax, 0                               ;Disk Base Table Pointer の初期化
            mov     es, ax
            mov     di, ax                              ;int 0x13命令時ES:DIにディスクベーステーブルのアドレスが設定される

            mov     ah, 8
            mov     dl, [si + drive.no]                 ;DL = ドライブ番号
            int     0x13

.10Q:       jc      .10F                                ; if (0 == CF) // 0:成功, 1:失敗
.10T:                                                   ; {
            mov     al, cl                              ;   AX = セクタ数;
            and     ax, 0x3F                            ;   // 下位6ビットのみ有効

            shr     cl, 6                               ;   CX = シリンダ数;
            ror     cx, 8
            inc     cx                                  ;   //シリンダ番号は0始まりなので，最大シリンダ数を得るために1加算

            movzx   bx, dh                              ;   BX = ヘッド数(1ベース) //ゼロ拡張(2byte)
            inc     bx                                  ;   //ヘッド番号も同様

            mov     [si + drive.cyln], cx               ;   //オフセットアドレスに格納
            mov     [si + drive.head], bx
            mov     [si + drive.sect], ax

            jmp     .10E                                ; }
.10F:                                                   ; else
            mov     ax, 0                               ; {
.10E:                                                   ;   AX = 0; //失敗
                                                        ; }

            ;レジスタの復帰
            pop     di
            pop     si
            pop     es
            pop     cx
            pop     bx

            ;スタックフレームの破棄
            mov     sp, bp
            pop     bp

            ret
