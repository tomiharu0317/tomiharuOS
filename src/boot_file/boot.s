;マクロ

%include    "../include/define.s"
%include    "../include/macro.s"

        ORG     BOOT_LOAD


;エントリポイント

entry:
        jmp     ipl

; BIOS Parameter Block

        times 90 - ($ - $$) db 0x90

; Initial Program Loader

ipl:

        cli                                 ;割り込みの禁止

        mov     ax, 0x0000
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        mov     sp, BOOT_LOAD

        sti                                 ;割り込みの許可

        ;ブートドライブ番号の保存

        mov     [BOOT + drive.no], dl       ;ブートドライブを保存

        ;文字列の表示

        cdecl   puts, .s0                   ;puts(.s0)

        ;残りのセクタをすべて読み込む

        mov     bx, BOOT_SECT - 1           ;BX = 残りのブートセクト数
        mov     cx, BOOT_LOAD + SECT_SIZE   ;CX = 次のロードアドレス

        cdecl   read_sect, BOOT, bx, cx     ;AX = read_sect(BOOT, bx, cx)

        cmp     ax, bx
.10Q:   jz      .10E                        ;if (ax != 残りのセクタ数)

.10T:   cdecl   puts, .e0                   ;{  puts(.e0);
        call    reboot                      ;   reboot(); //再起動

.10E:                                       ;}

        ;次のステージへ移行

        jmp     stage_2                     ;ブート処理の第2ステージへ

        ;データ

.s0     db      "booting...", 0x0A, 0x0D, 0
.e0     db      "Error: sector read", 0

;ブートドライブに関する情報

ALIGN 2, db 0
BOOT:
        istruc  drive
            at  drive.no,       dw 0        ;ドライブ番号
            at  drive.cyln,     dw 0        ;シリンダ
            at  drive.head,     dw 0        ;ヘッド
            at  drive.sect,     dw 2        ;セクタ
        iend

;モジュール(512バイト以降に配置)

%include    "../modules/real/puts.s"
%include    "../modules/real/reboot.s"
%include    "../modules/real/read_sect.s"

;ブートフラグ(512biteの終了)

        times   510 - ($ - $$) db 0x00
        db 0x55, 0xAA

;リアルモード時に取得した情報
FONT:                                           ;フォント
.seg:   dw 0
.off:   dw 0

%include    "../modules/real/int_to_str.s"
%include    "../modules/real/get_drive_params.s"
%include    "../modules/real/get_font_adr.s"

;ブート処理の第2ステージ

stage_2:

        ;文字列を表示
        cdecl   puts, .s0

        ;ドライブ情報を取得
        cdecl   get_drive_params, BOOT          ;get_drive_params(DX, BOOT.CYLN);
        cmp     ax, 0                           ;if (0 == AX){
.10Q:   jne     .10E                            ;       puts(.e0);
.10T:   cdecl   puts, .e0                       ;       reboot();
        call    reboot                          ; }
.10E:

        ;ドライブ情報を表示
        mov     ax, [BOOT + drive.no]           ;AX = ブートドライブ
        cdecl   int_to_str, ax, .p1, 2, 16, 0b0100
        mov     ax, [BOOT + drive.cyln]           ;
        cdecl   int_to_str, ax, .p2, 4, 16, 0b0100
        mov     ax, [BOOT + drive.head]           ;AX = ヘッド数
        cdecl   int_to_str, ax, .p3, 2, 16, 0b0100
        mov     ax, [BOOT + drive.sect]           ;AX = トラック当たりのセクタ数
        cdecl   int_to_str, ax, .p4, 2, 16, 0b0100
        cdecl   puts, .s1


        ;処理の終了

        jmp     stage_3

        ;データ

.s0     db      "2nd stage...", 0x0A, 0x0D, 0

.s1     db      " Drive:0x"
.p1     db      "  , C:0x"
.p2     db      "    , H:0x"
.p3     db      "  , S:0x"
.p4     db      "  ", 0x0A, 0x0D, 0

.e0     db      "Can't get drive Parameter.", 0

stage_3:

        ;文字列を表示
        cdecl   puts, .s0

        ;プロテクトモードで使用するフォントは
        ;BIOSに内蔵されたものを流用する

        cdecl   get_font_adr, FONT

        ;フォントアドレスの表示
        cdecl   int_to_str, word [FONT.seg], .p1, 4, 16, 0b0100
        cdecl   int_to_str, word [FONT.off], .p2, 4, 16, 0b0100
        cdecl   puts, .s1

        ;処理の終了

        jmp     $

        ;データ
.s0     db      "3rd stage...", 0x0A, 0x0D, 0

.s1     db      " Font Address="
.p1     db      "ZZZZ:"
.p2     db      "ZZZZ", 0x0A, 0x0D, 0
        db      0x0A, 0x0D, 0

;パディング

        times   BOOT_SIZE - ($ - $$)       db  0        ;8Kバイト