read_chs:

            ; construct stack frame
                                                    ;   +8 | read dest address
                                                    ;   +6 | num of sector
                                                    ;   +4 | address of drive structure
                                                    ;   +2 | IP
                                                    ;BP +0 | BP
                                                    ;   -2 | retry = 3; // retry count
                                                    ;   -4 | sect  = 0; // num of read sector
            push    bp
            mov     bp, sp
            push    3
            push    0

            ; save registers

            push    bx
            push    cx
            push    dx
            push    es
            push    si

            ; main process
            mov     si, [bp + 4]                    ; address of struc

            ; set up CX register
            ; [address of struc + offset + ?]

            mov     ch, [si + drive.cyln + 0]       ; CH = cylinder no.(lower byte)
            mov     cl, [si + drive.cyln + 1]       ; CL = cylinder no.(upper byte)
            shl     cl, 6                           ; CL <<= 6; // shift to highest 2 bits
            or      cl, [si + drive.sect]           ; CL |= sect no.;

            ; read sector

            mov     dh, [si + drive.head]           ; DH = head no.
            mov     dl, [si + 0]                    ; DL = drive no.
            mov     ax, 0x0000
            mov     es, ax                          ; initialize ES segment
            mov     bx, [bp + 8]                    ; read dest address

            ; do{
            ;     AH = read sect
            ;     AL = num of sect

            ;     CF = BIOS(0x13, 0x02);
            ;     if (CF)
            ;     {
            ;         AL = 0;
            ;         break;
            ;     }

            ;     if (read sect exists)
            ;         break;

            ;     ret = 0;
            ; } while(--retry);

.10L:
            mov     ah, 0x02
            mov     al, [bp + 6]

            int     0x13
            jnc     .11E                            ; jump to .11E if succeeded

            mov     al, 0
            jmp     .10E                            ; jump to .10E without retry if failed
.11E:
            cmp     al, 0                           ; if (num of read sect > 0)
            jne     .10E                            ;   break;

            mov     ax, 0                           ; return value
            dec     word [bp - 2]
            jnz     .10L                            ; jump to .10L if num of read sect was 0
.10E:
            mov     ah, 0                           ;AH = 0 // discard starus info

            ; return registers

            pop     si
            pop     es
            pop     dx
            pop     cx
            pop     bx

            ; destruct stack frame

            mov     sp, bp
            pop     bp

            ret