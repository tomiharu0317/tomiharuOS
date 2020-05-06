reboot:

        ; display message

        cdecl   puts, .s0                       ;// display rebooting message

        ; wait for the key to be pressed

.10L:                                           ; do {
        mov     ah, 0x10                        ;       // wait for the key to be pressed
        int     0x16                            ;       AL = BIOS(0x16, 0x10)

        cmp     al, ' '                         ;       ZF = (AL == ' ');
        jne     .10L                            ; } while (!ZF);

        ; output a line break

        cdecl   puts, .s1

        ; reboot

        int     0x19                            ; BIOS(0x19);

        ; strings data

.s0:    db  0x0A, 0x0D, "Push SPACE key to reboot...", 0
.s1:    db  0x0A, 0x0D, 0x0A, 0x0D, 0