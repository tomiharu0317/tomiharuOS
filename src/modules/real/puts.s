puts:

        ; construct stack frame

        push    bp
        mov     bp, sp                                  ;  +4 | address to strings
                                                        ;  +2 | Instruction Pointer
                                                        ;BP+0 | BP

        ; save registers

        push    ax
        push    bx
        push    si

        ; get args

        mov     si, [bp + 4]                            ;Source Index == address to strings

        ; main process

        mov     ah, 0x0E
        mov     bx, 0x0000
        cld

.10L:                                                   ;do{
                                                        ;   AL = *SI++
        lodsb                                           ;
                                                        ;   if (0 == AL)
        cmp     al, 0                                   ;       break;
        je      .10E                                    ;
                                                        ;   Int10(0x0E, AL); // input char
        int     0x10                                    ;} while(1);
        jmp     .10L

.10E:

        ; return registers

        pop     si
        pop     bx
        pop     ax

        ; destruct stack frame

        mov     sp, bp
        pop     bp

        ret