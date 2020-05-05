get_drive_params:

            ; construct stack frame
            push    bp                                  ;BP +4 | address of drive structure
            mov     bp, sp

            ; save registers

            push    bx
            push    cx
            push    es
            push    si
            push    di

            ; main process
            mov     si, [bp + 4]

            mov     ax, 0                               ; initialize Disk Base Table Pointer
            mov     es, ax
            mov     di, ax                              ; set address of disk base table to ES:DI when int0x13

            mov     ah, 8
            mov     dl, [si + drive.no]                 ; DL = drive no.
            int     0x13

.10Q:       jc      .10F                                ; if (0 == CF) // 0:success, 1:failure
.10T:                                                   ; {
            mov     al, cl                              ;   AX = num of sector;
            and     ax, 0x3F                            ;   // only the lower 6 bits are valid

            shr     cl, 6                               ;   CX = num of cylinder;
            ror     cx, 8
            inc     cx                                  ;   // cuz cylinder num starts at 0, add 1 to get maximum num of cylinders

            movzx   bx, dh                              ;   BX = num of head(1base) // zero extension(2byte)
            inc     bx                                  ;   // head no. is also the same

            mov     [si + drive.cyln], cx               ;   // store at offset address
            mov     [si + drive.head], bx
            mov     [si + drive.sect], ax

            jmp     .10E                                ; }
.10F:                                                   ; else
            mov     ax, 0                               ; {
.10E:                                                   ;   AX = 0; // failure
                                                        ; }

            ; return registers
            pop     di
            pop     si
            pop     es
            pop     cx
            pop     bx

            ; destruct stack frame
            mov     sp, bp
            pop     bp

            ret
