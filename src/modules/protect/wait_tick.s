wait_tick:

            ; construct stack frame
                                                            ; EBP +8 | waif == num of system interrupt
            push    ebp
            mov     ebp, esp

            ; save registers
            push    eax
            push    ecx

            ; wait
            mov     ecx, [ebp + 8]
            mov     eax, [TIMER_COUNT]

.10L:
            cmp     [TIMER_COUNT], eax                      ; while(TIMER != eax)
            je      .10L
            inc     eax                                     ; eax++
            loop    .10L                                    ; while(--ecx)

            ; return registers
            pop     ecx
            pop     eax

            ; destruct stakc frame
            mov     esp, ebp
            pop     ebp

            ret