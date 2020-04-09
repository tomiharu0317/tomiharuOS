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

;モジュール

%include    "../modules/real/puts.s"
%include    "../modules/real/int_to_str.s"
%include    "../modules/real/reboot.s"
%include    "../modules/real/read_sect.s"

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

        times   BOOT_SIZE - ($ - $$)       db  0