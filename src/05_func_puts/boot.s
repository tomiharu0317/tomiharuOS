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

        ;数値の表示

	cdecl	int_to_str,  8086, .s1, 8, 10, 0b0001	; "    8086"
	cdecl	puts, .s1

	cdecl	int_to_str,  8086, .s1, 8, 10, 0b0011	; "+   8086"
	cdecl	puts, .s1

	cdecl	int_to_str, -8086, .s1, 8, 10, 0b0001	; "-   8086"
	cdecl	puts, .s1

	cdecl	int_to_str,    -1, .s1, 8, 10, 0b0001	; "-      1"
	cdecl	puts, .s1

	cdecl	int_to_str,    -1, .s1, 8, 10, 0b0000	; "   65535"
	cdecl	puts, .s1

	cdecl	int_to_str,    -1, .s1, 8, 16, 0b0000	; "    FFFF"
	cdecl	puts, .s1

	cdecl	int_to_str,    12, .s1, 8,  2, 0b0100	; "00001100"
	cdecl	puts, .s1

        ; 処理の終了

        jmp     $

.s0     db      "Booting...", 0x0A, 0x0D, 0
.s1     db      "--------",   0x0A, 0x0D, 0

ALIGN 2, db 0
BOOT:                                       ;ブートドライブに関する情報
.DRIVE:         dw  0                       ;ドライブ番号

;モジュール

%include    "../modules/real/puts.s"
%include    "../modules/real/int_to_str.s"

;ブートフラグ(512biteの終了)

        times   510 - ($ - $$) db 0x00
        db 0x55, 0xAA