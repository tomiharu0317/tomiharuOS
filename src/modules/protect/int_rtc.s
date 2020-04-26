int_rtc:

            ; save registers
            pusha
            push    ds
            push    es

            ; set up segment selector for data
            mov     ax, 0x0010                                      ; offset from the beginnig of GDT // second element
            mov     ds, ax
            mov     es, ax

            ; get time from RTC
            cdecl   rtc_get_time, RTC_TIME

            ; get RTC interrupt factor
            outp    0x70, 0x0C                                      ; select register C
            in      al, 0x71

            ; clear interrupt flag
            mov     al, 0x20                                        ; AL = EOI command
            out     0xA0, al                                        ; slave PIC
            out     0x20, al                                        ; master PIC

            ; return register
            pop     es
            pop     ds
            popa

            iret                                                    ; end of interrupt process
                                                                    ; return including flag register => iret

; Enable interrupt by RTC itself

rtc_int_en:

            ; construct stack frame
            push    ebp
            mov     ebp, esp                                        ;EBP+8 | enable bit

            ; save register
            push    eax

            ; set up Interrupt Permission
            outp    0x70, 0x0B                                      ; select register B

            in      al, 0x71
            or      al, [ebp + 8]                                   ; set the specified bit

            out     0x71, al                                        ; write down to register B

            ; return register
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret