        BOOT_LOAD       equ     0x7c00

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

        mov     [BOOT.DRIVE], dl            ;ブートドライブを保存

        mov     al, 'A'
        mov     ah, 0x0E
        mov     bx, 0x0000
        int     0x10

        ; 処理の終了

        jmp     $

ALIGN 2, db 0
BOOT:                                       ;ブートドライブに関する情報
.DRIVE:         dw  0                       ;ドライブ番号

;ブートフラグ(512biteの終了)

        times   510 - ($ - $$) db 0x00
        db 0x55, 0xAA