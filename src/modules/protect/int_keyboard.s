int_keyboard:

            ; save registers
            pusha
            push    ds
            push    es

            ; set up segment for data
            mov     ax, 0x0010
            mov     ds, ax
            mov     es, ax

            ; read buffer of KBC
            in      al, 0x60                                    ; AL = get key code

            ; save key code
            cdecl   ring_wr, _KEY_BUFF, eax

            ; send interrupt end command
            outp    0x20, 0x20                                  ; master PIC: EOI command

            ; return registers
            pop     es
            pop     ds
            popa

            iret

ALGIN 4, db 0
_KEY_BUFF:  times ring_buff_size db 0