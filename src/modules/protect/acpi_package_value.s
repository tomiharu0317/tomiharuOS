acpi_package_value:

            ; construct stack frame
            push    ebp                                         ; EBP+ 8 | address to Package
            mov     ebp, esp

            ; save register
            push    esi

            ; get arg
            mov     esi, [ebp + 8]

            ; skip packet header
            inc     esi                                         ; ESI++ // skip 'PackageOp'
            inc     esi                                         ; ESI++ // skip 'PkgLength'
            inc     esi                                         ; ESI++ // skip 'NumElements'
                                                                ; ESI = PackageElementList

            ; get only 2 byte
            mov     al, [esi]
            cmp     al, 0x0B
            je      .C0B
            cmp     al, 0x0C
            je      .C0C
            cmp     al, 0x0E
            je      .C0E
            jmp     .C0A
.C0B:                                                           ; case 0x0B: // 'WordPrefix'
.C0C:                                                           ; case 0x0C: // 'DWordPrefix'
.C0E:                                                           ; case 0x0E: // 'QWordPrefix'
            mov     al, [esi + 1]                               ; AL = ESI[1]
            mov     ah, [esi + 2]                               ; AH = ESI[2]
            jmp     .10E

.C0A:                                                           ; default:  // 'BytePrefix' | 'ConstObj'
                                                                ;   // fist 1 byte
                                                                ; if (0x0A == AL)
            cmp     al, 0x0A                                    ; {
            jne     .11E                                        ;   AL = *ESI
            mov     al, [esi + 1]                               ;   ESI++
            inc     esi
.11E:                                                           ; }

            inc     esi                                         ; // next 1 byte

            mov     ah, [esi]                                   ; AH = *ESI
            cmp     ah, 0x0A                                    ; if (0x0A == AL)
            jne     .12E                                        ; {
            mov     ah, [esi + 1]                               ;   AH = ESI[1]
.12E:                                                           ; }
.10E:                                                           ; }


            ; return register
            pop     esi

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret