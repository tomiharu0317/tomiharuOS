int_timer:

            ; save registers
            pusha
            push    ds
            push    es

            ; set up segment selector for data
            mov     ax, 0x0010
            mov     ds, ax
            mov     es, ax

            ; TICK
            inc     dword [TIMER_COUNT]                                     ; TIMER_COUNT++ //update interrupt count

            ; clear interrupt flag(EOI)
            outp    0x20, 0x20                                              ; master PIC:EOI command

            ; exchange Task
            str     ax                                                      ; AX = TR // current Task Register
            cmp     ax, SS_TASK_0
            je      .11L
            cmp     ax, SS_TASK_1
            je      .12L
            cmp     ax, SS_TASK_2
            je      .13L

            jmp     SS_TASK_0:0
            jmp     .10E
.11L:
            jmp     SS_TASK_1:0
            jmp     .10E
.12L:
            jmp     SS_TASK_2:0
            jmp     .10E
.13L:
            jmp     SS_TASK_3:0
            jmp     .10E
.10E:

            ; return registers
            pop     es
            pop     ds
            popa

            iret

ALIGN 4, db 0
TIMER_COUNT:    dq 0