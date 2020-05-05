ctrl_alt_end:

            ; construct stack frame
            push    ebp
            mov     ebp, esp                                        ; EBP +8 | key code

            ; save registers
            push    eax

            ; save key state
            mov     eax, [ebp + 8]
            btr     eax, 7                                          ; CF = EAX & 0x80
            jc      .10F                                            ; if (0 == CF)
            bts     [.key_state], eax                               ; {
            jmp     .10E                                            ;   // set flag
.10F:                                                               ; } else {
            btc     [.key_state], eax                               ;   // clear flag
.10E:                                                               ; }

            ; judge whether target key pressed
            mov     eax, 0x1D                                       ; [Ctrl]
            bt      [.key_state], eax                               ; CF = .key_state[0x1D]
            jnc     .20E

            mov     eax, 0x38                                       ; [Alt]
            bt      [.key_state], eax
            jnc     .20E

            mov     eax, 0x4F                                       ; [End]
            bt      [.key_state], eax
            jnc     .20E

            mov     eax, -1                                         ; if (get target key code) return -1;
.20E:
            sar     eax, 8                                          ; ret >>= 8 // MSB = MSB, CF = LSB

            ; return registers
            pop     eax

            ; destruct stack frame
            mov     ebp, esp
            pop     ebp

            ret

.key_state: times 32 db 0