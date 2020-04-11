KBC_Data_Write:

            ;construct stack frame
                                                        ; BP +4 | data
            push    bp
            mov     bp, sp

            ;save registers
            push    cx

            ;process
            mov     cx, 0                               ; CX = 0; // max count value
.10L:
            in      al, 0x64
            test    al, 0x02                            ; ZF = AL & 0x02 // B1:input buffer full
            loopnz  .10L

            cmp     cx, 0
            jz      .20E                                ; timeout

            mov     al, [bp + 4]
            out     0x60, al
.20E:

            mov     ax, cx                              ; return CX

            ;return registers
            pop     cx

            ;destruct stack frame

            mov     sp, bp
            pop     bp

            ret

