acpi_find:

            ; construct stack frame
            push    ebp
            mov     ebp, esp                                    ;    +16 | search_target data
                                                                ;    +12 | size
                                                                ; EBP+ 8 | address

            ; save registers
            push    ecx
            push    edi

            ; get args
            mov     edi, [ebp + 8]
            mov     ecx, [ebp + 12]
            mov     eax, [ebp + 16]

            ; search name
            cld                                                 ; direction:plus
.10L:                                                           ; for ( ; ; )
                                                                ; {
            repne   scasb                                       ;   while (AL != *EDI) EDI++

            cmp     ecx, 0                                      ;   if (0 == ECX)
            jnz     .11E                                        ;   {
            mov     eax, 0                                      ;       EAX = 0; // not found
            jmp     .10E                                        ;       break;
.11E:                                                           ;   }

            cmp     eax, [es:edi - 1]                           ;   if (EAX != *EDI) // whether corresponds 4 char
            jne     .10L                                        ;       continue;

            ; correspond
            dec     edi
            mov     eax, edi                                    ;   EAX = search target address; // return value

.10E:                                                           ; }

            ; return registers
            pop     edi
            pop     ecx

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret