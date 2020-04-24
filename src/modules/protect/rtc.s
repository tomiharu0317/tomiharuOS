rtc_get_time:

            ; construct stack frame
            push    ebp                                     ; EBP+8 | destination
            mov     ebp, esp

            ; save register
            push    eax
            push    ebx

            ; main process
            mov     al, 0x04                                ; hour
            out     0x70, al
            in      al, 0x71

            shl     eax, 8

            mov     al, 0x02                                ; minute
            out     0x70, al
            in      al, 0x71

            shl     eax, 8

            mov     al, 0x00                                ; second
            out     0x70, al
            in      al, 0x71

            and     eax, 0x00_FF_FF_FF                      ; all data are in lower 3 bytes of eax register

            mov     ebx, [ebp + 8]
            mov     [ebx], eax                              ; [dest] = real time

            ; return register
            pop     ebx
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret