int_pf:

            ; construct stack frame
            push    ebp
            mov     ebp, esp

            ; save registers
            pusha
            push    ds
            push    es

            mov     ax, 0x0010
            mov     ds, ax
            mov     es, ax

            ; confirm the address of what raised exception
            mov     eax, cr2
            and     eax, ~0xFFF                                     ; access within 4K bytes
            cmp     eax, 0x0010_7000                                ; if (0x0010_7000 == ptr) => page activation process
            jne     .10F                                            ; if (0x0010_7000 != ptr) => task termination process

            ; enable page
            mov     [0x00106000 + 0x107 * 4], dword 0x00107007
            cdecl   memcpy, 0x0010_7000, DRAW_PARAM, rose_size

            jmp     .10E

.10F:
            ; adjust stack
            add     esp, 4                                          ; pop es
            add     esp, 4                                          ; pop ds
            popa
            pop     ebp

            ; task termination process
            pushf                                                   ; EFLAGS
            push    cs
            push    int_stop                                        ; stack displaying process

            mov     eax, .s0                                        ; interrupt type
            iret

.10E:

            ; return registers
            pop     es
            pop     ds
            popa

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            add     esp, 4                                          ; discard error code
            iret

.s0:        db  " < PAGE FAULT > ", 0