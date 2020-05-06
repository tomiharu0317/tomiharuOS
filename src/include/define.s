        BOOT_SIZE       equ     (1024 * 8)                      ; boot size
        KERNEL_SIZE     equ     (1024 * 8)                      ; kernel size

        BOOT_LOAD       equ     0x7C00                          ; where boot program is gonna be loaded
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
        SP_TASK_2       equ     STACK_BASE + (STACK_SIZE * 3)
        SP_TASK_3       equ     STACK_BASE + (STACK_SIZE * 4)
        SP_TASK_4       equ     STACK_BASE + (STACK_SIZE * 5)
        SP_TASK_5       equ     STACK_BASE + (STACK_SIZE * 6)
        SP_TASK_6       equ     STACK_BASE + (STACK_SIZE * 7)

        CR3_BASE        equ     0x0010_5000                     ; page conversion table: for task 3

        PARAM_TASK_4    equ     0x0010_8000                     ; drawing params : for task4
        PARAM_TASK_5    equ     0x0010_9000                     ; drawing params : for task5
        PARAM_TASK_6    equ     0x0010_A000                     ; drawing params : for task6

        CR3_TASK_4      equ     0x0020_0000                     ; page conversion table: for task 4
        CR3_TASK_5      equ     0x0020_2000                     ; page conversion table: for task 5
        CR3_TASK_6      equ     0x0020_4000                     ; page conversion table: for task 6

;------------------------------------------------------------------------------------------------------
; FAT settings
;------------------------------------------------------------------------------------------------------

        FAT_SIZE        equ     (1024 * 128)                    ; FAT-1/2
        ROOT_SIZE       equ     (1024 * 16)                     ; Root Directory space

        ENTRY_SIZE      equ     32

	FAT1_START      equ     (KERNEL_SIZE)
	FAT2_START      equ     (FAT1_START + FAT_SIZE)
	ROOT_START      equ     (FAT2_START + FAT_SIZE)
	FILE_START      equ     (ROOT_START + ROOT_SIZE)

        ATTR_ARCHIVE    equ     0x20
        ATTR_VOLUME_ID  equ     0x08