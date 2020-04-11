KBC_Data_Write:

            ;construct stack frame
                                                        ; BP +4 | data
            push    bp
            mov     bp, sp

            ;save register
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

            ;return register
            pop     cx

            ;destruct stack frame

            mov     sp, bp
            pop     bp

            ret

KBC_Data_Read:

            ;construct stack frame

            push    bp
            mov     bp, sp

            ;save register
            push    cx

            ;process
            mov     cx, 0
.10L:
            in      al, 0x64
            test    al, 0x01                            ; ZF = AL & 0x01 // B0:output buffer full
            loopnz  .10L

            cmp     cx, 0
            jz      .20E

            mov     ah, 0x00
            in      al, 0x60

            mov     di, [bp + 4]                        ; DI = Address where read data will be saved
            mov     [di + 0], ax
.20E:

            mov     ax, cx

            ;return register
            pop     cx

            ;destruct stack frame

            mov     sp, bp
            pop     bp

            ret

KBC_Cmd_Write:

            ;construct stack frame
                                                        ; BP +4 | data
            push    bp
            mov     bp, sp

            ;save register
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
            out     0x64, al
.20E:

            mov     ax, cx                              ; return CX

            ;return register
            pop     cx

            ;destruct stack frame

            mov     sp, bp
            pop     bp

            ret