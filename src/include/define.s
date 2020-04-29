        BOOT_SIZE       equ     (1024 * 8)                      ; boot size
        KERNEL_SIZE     equ     (1024 * 8)                      ; kernel size

        BOOT_LOAD       equ     0x7c00                          ; where boot program is gonna be loaded
        BOOT_END        equ     (BOOT_LOAD + BOOT_SIZE)

        KERNEL_LOAD     equ     0x0010_1000

        SECT_SIZE       equ     (512)                           ; sector size

        BOOT_SECT       equ     (BOOT_SIZE / SECT_SIZE)         ; num of sector of boot program
        KERNEL_SECT     equ     (KERNEL_SIZE / SECT_SIZE)

        E820_RECORD_SIZE        equ     20

        VECT_BASE       equ     0x0010_0000                     ; 0010_0000 ~ 0010_07FF

        STACK_BASE      equ     0x0010_3000                     ; stack area for task
        STACK_SIZE      equ     1024                            ; stack size

        SP_TASK_0       equ     STACK_BASE + (STACK_SIZE * 1)
        SP_TASK_1       equ     STACK_BASE + (STACK_SIZE * 2)

