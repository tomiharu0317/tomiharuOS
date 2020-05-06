int_to_str:

        ;construct stack frame

        push    ebp
        mov     ebp, esp                                ;   +24|flag
                                                        ;   +20|radix
                                                        ;   +16|dest buffer size
                                                        ;   +12|dest buffer address
                                                        ;   + 8|the value to be converted
                                                        ;   + 4|Instruction Pointer
                                                        ;EBP+ 0|EBP
        ; save registers

        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        ; get args

        mov     eax, [ebp +  8]                         ; val = value
        mov     esi, [ebp + 12]                         ; dest= buffer address
        mov     ecx, [ebp + 16]                         ; size= remaining buffer size

        mov     edi, esi                                ; end of buffer
        add     edi, ecx                                ; dest = &dest[esize - 1]
        dec     edi

        mov     ebx, [ebp + 24]

        ; signing judge

        test    ebx, 0b0001                             ; if (flags & 0x01) //if signed => ZF = 0
.10Q:   je      .10E                                    ; {                 //if not ZF = 1 so => jmp
        cmp     eax, 0                                  ;   if (val < 0)    //CF = 1, ZF = 0
.12Q:   jge     .12E                                    ;   {
        or      ebx, 0b0010                             ;       flags |= 2; //set B1
                                                        ; }}
.12E:
.10E:

        ; sign output judge

        test    ebx, 0b0010
.20Q:   je      .20E
        cmp     eax, 0
.22Q:   jge     .22F
        neg     eax                                     ; sign reverse
        mov     [esi], byte '-'                         ; sign display
        jmp     .22E
.22F:
        mov     [esi], byte '+'
.22E:
        dec     ecx                                     ; subtract remaining buffer size -> ?
.20E:

        ; ASCII conversion

        mov     ebx, [ebp + 20]                          ; ebx = radix

.30L:                                                   ; do{
        mov     edx, 0
        div     ebx                                    ;   edx = edx:eax % ebx;
                                                        ;   eax = edx:eax / ebx;

        mov     esi, edx                                ;   //refer to coversion table
        mov     dl, byte [.ascii + esi]                 ;   DL = ASCII[edx];

        mov     [edi], dl                               ;   *dest = DL;
        dec     edi                                     ;   dest--;

        cmp     eax, 0
        loopnz  .30L                                    ; } while(eax);

.30E:

        ; padding (zero / blank)

        cmp     ecx, 0                                  ; if (esize)
.40Q:   je      .40E                                    ; {
        mov     al, ' '                                 ;   AL = ' '; // padding with blanks
        cmp     [ebp + 24], word 0b0100                  ;   if (flags & 0x04)
.42Q:   jne     .42E                                    ;   {
        mov     al, '0'                                 ;       AL = '0'; // padding with zero
.42E:                                                   ;   }
        std                                             ;   // DF = 1(dec)
        rep     stosb                                       ;   while (--ecx) * edi-- = ' ';
.40E:                                                   ; }

        ; return registers

        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ; destruct stack frame

        mov     esp, ebp
        pop     ebp

        ret


.ascii  db      "0123456789ABCDEF"                      ; conversion table