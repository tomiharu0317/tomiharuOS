;--------------------------------------------------------------------------------------------
;char update cycle
;=> The value obtained by reading the value of Timer interrupt counter
;   and shifting it to the right by 4 bits
;   and if the value is different from the previous value, it's the time to update.
;--------------------------------------------------------------------------------------------

draw_rotation_bar:

            ; save register
            push    eax

            ; main process
            mov     eax, [TIMER_COUNT]
            shr     eax, 4
            cmp     eax, [.index]
            je      .10E

            mov     [.index], eax
            and     eax, 0x03                                       ; limit to the range 0 to 3

            mov     al, [.table + eax]                              ; AL = table[index]
            cdecl   draw_char, 0, 29, 0x000F, eax

.10E:

            ; return register
            pop     eax

            ret

ALIGN 4, db 0
.index      dd 0                                                    ; previous value
.table      db "|/-\"                                               ; display bar