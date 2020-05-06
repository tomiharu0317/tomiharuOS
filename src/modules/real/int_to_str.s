int_to_str:

        ; construct stack frame

        push    bp
        mov     bp, sp                          ;  +12| flag
                                                ;  +10| radix
                                                ;  + 8| save_dest buffer size
                                                ;  + 6| save_dest buffer address
                                                ;  + 4| the value to convert
                                                ;  + 2| IP
                                                ;BP+ 0| BP
        ; save registers
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di

        ; get args

        mov     ax, [bp + 4]                    ; val = value
        mov     si, [bp + 6]                    ; dest= buffer address
        mov     cx, [bp + 8]                    ; size= buffer size

        mov     di, si                          ; the end of buffer
        add     di, cx                          ; dest = &dest[size - 1]
        dec     di

        mov     bx, word [bp + 12]              ; flags
                                                ; B2: fill blanks with zeros B1:+/- add sign B0:treat the value as a signed variable

        ; judge wether signed or not

        test    bx, 0b0001                      ; if (flags & 0x01) // if sined ZF = 0
.10Q:   je      .10E                            ; {                 // if not   ZF = 1 and jmp
        cmp     ax, 0                           ;   if (val < 0)    // CF = 1, ZF = 0
.12Q:   jge     .12E                            ;   {               // if val >= 0 jmp(cuz no necescity)
        or      bx, 0b0010                      ;       flags |= 2; // set B1
                                                ; }}
.12E:
.10E:

        ; sing output judgement

        test    bx, 0b0010
.20Q:   je      .20E
        cmp     ax, 0
.22Q:   jge     .22F
        neg     ax                              ; sign inversion
        mov     [si], byte '-'                  ; display sign
        jmp     .22E
.22F:
        mov     [si], byte '+'
.22E:
        dec     cx                              ; subtract remaining buffer size -> ?
.20E:

        ; ASCII conversion

        mov     bx, [bp + 10]                   ; BX = radix

.30L:                                           ; do{
        mov     dx, 0
        div     bx                              ;   DX = DX:AX % BX;
                                                ;   AX = DX:AX / BX;

        mov     si, dx                          ;   // refer to conversion table
        mov     dl, byte [.ascii + si]          ;   DL = ASCII[DX];

        mov     [di], dl                        ;   *dest = DL;
        dec     di                              ;   dest--;

        cmp     ax, 0
        loopnz  .30L                            ; } while(AX);

.30E:

        ;fill blanks with zero/blank

        cmp     cx, 0                           ; if (size)
.40Q:   je      .40E                            ; {
        mov     al, ' '                         ;   AL = ' '; // blank fill
        cmp     [bp + 12], word 0b0100          ;   if (flags & 0x04)
.42Q:   jne     .42E                            ;   {
        mov     al, '0'                         ;       AL = '0'; // zero fill
.42E:                                           ;   }
        std                                     ;   // DF = 1(subtraction)
        rep stosb                               ;   while (--cx) * DI-- = ' ';
.40E:                                           ; }

        ; return registers

        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax

        ; destruct stack frame

        mov     sp, bp
        pop     bp

        ret


.ascii  db      "0123456789ABCDEF"              ; conversion table