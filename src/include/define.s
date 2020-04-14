        BOOT_SIZE       equ     (1024 * 8)                      ; boot size
        KERNEL_SIZE     equ     (1024 * 8)                      ; kernel size

        BOOT_LOAD       equ     0x7c00                          ;ブートプログラムのロード位置
        BOOT_END        equ     (BOOT_LOAD + BOOT_SIZE)

        KERNEL_LOAD     equ     0x0010_1000

        SECT_SIZE       equ     (512)                           ;セクタサイズ

        BOOT_SECT       equ     (BOOT_SIZE / SECT_SIZE)         ;ブートプログラムのセクタ数
        KERNEL_SECT     equ     (KERNEL_SIZE / SECT_SIZE)

        E820_RECORD_SIZE        equ     20