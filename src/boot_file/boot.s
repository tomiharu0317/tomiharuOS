        BOOT_LOAD       equ     0x7c00

        ORG     BOOT_LOAD
;マクロ

%include    "../include/macro.s"

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

        mov     [BOOT.DRIVE], dl            ;ブートドライブを保存

        ;文字列の表示

        cdecl   puts, .s0                   ;puts(.s0)

        ;次の512バイトを読み込む

        mov     ah, 0x02                    ;AH = 読み込み命令
        mov     al, 1                       ;AL = 読み込みセクタ数
        mov     cx, 0x0002                  ;CX = シリンダ/セクタ
        mov     dh, 0x00                    ;DH = ヘッド位置
        mov     dl, [BOOT.DRIVE]            ;DL = ドライブ番号
        mov     bx, 0x7C00 + 512            ;BX = 読み込みアドレス（オフセット）
        int     0x13                        ;Cf = 0 if succeed, else 1
.10Q:   jnc     .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:

        ;次のステージへ移行

        jmp     stage_2                     ;ブート処理の第2ステージへ

        ; 処理の終了

        jmp     $

.s0     db      "Booting...", 0x0A, 0x0D, 0
;.s1     db      "--------",   0x0A, 0x0D, 0
.e0     db      "Error: sector read", 0

ALIGN 2, db 0
BOOT:                                       ;ブートドライブに関する情報
.DRIVE:         dw  0                       ;ドライブ番号

;モジュール

%include    "../modules/real/puts.s"
%include    "../modules/real/int_to_str.s"
%include    "../modules/real/reboot.s"

;ブートフラグ(512biteの終了)

        times   510 - ($ - $$) db 0x00
        db 0x55, 0xAA

;ブート処理の第2ステージ

stage_2:

        ;文字列を表示
        cdecl   puts, .s0

        ;処理の終了

        jmp     $

        ;データ

.s0     db      "2nd stage...", 0x0A, 0x0D, 0

;パディング（ファイルサイズは8Kバイト）

        times   (1024 * 8) - ($ - $$)       db  0