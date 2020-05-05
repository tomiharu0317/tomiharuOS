find_rsdt_entry:


            ; construct stack frame
            push    ebp
            mov     ebp, esp                                    ;    +12 | tabel identifier
                                                                ; EBP+ 8 | address of RSDT table

            ; save registers
            push    ebx
            push    ecx
            push    esi
            push    edi

            ; get args
            mov     esi, [ebp + 8]
            mov     ecx, [ebp + 12]

            mov     ebx, 0                                      ; initialization // EBX = address of target ACPI table

            ; the process of searching ACPI table
            mov     edi, esi
            add     edi, [esi + 4]                              ; EDI = &ENTRY[MAX]
            add     esi, 36                                     ; ESI = &ENTRY[0]
.10L:
            cmp     esi, edi                                    ; while(ESI < EDI)
            jge     .10E

            lodsd                                              ; EAX = [ESI++]     // entry

            cmp     [eax], ecx                                  ; compare with target table name
            jne     .12E
            mov     ebx, eax                                    ; correspond
            jmp     .10E
.12E:       jmp     .10L

.10E:
            mov     eax, ebx

            ; return registers
            pop     edi
            pop     esi
            pop     ecx
            pop     ebx

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret