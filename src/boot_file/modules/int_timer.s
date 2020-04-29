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

            ; return registers
            pop     es
            pop     ds
            popa

            iret

ALIGN 4, db 0
TIMER_COUNT:    dq 0