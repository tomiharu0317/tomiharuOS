page_set_4m:

            ; construct stack frame
            push    ebp
            mov     ebp, esp                                        ; EBP+8 | base address of page directory

            ; save registers
            pusha

            ; make page directory
            mov     edi, [ebp + 8]
            mov     eax, 0x00000000                                 ; // P = 0
            mov     ecx, 1024
            rep     stosd                                           ; while(ecx--) *edi++ = type

            ; set top entry
            mov     eax, edi                                        ; EAX = right after the page directory = address of page table
            and     eax, ~0x0000_0FFF                               ; specifying the physical address
            or      eax, 7                                          ; permit R/W
            mov     [edi - (1024 * 4)], eax                         ; set top entry of page directory

            ; set page table
            mov     eax, 0x000000007                                ; specifying physical address and permit R/W
            mov     ecx, 1024

.10L:
            stosd
            add     eax, 0x00001000
            loop    .10L

            ; return registers
            popa

            ; desctruct stack frame
            mov     esp, ebp
            pop     ebp

            ret

init_page:

             ; save registers
             pusha

             ; make page conversion table
             cdecl  page_set_4m, CR3_BASE
             mov    [0x00106000 + 0x107 * 16], dword 0               ; set 0x0010_7000 to the page not exist

             ; return registers
             popa

             ret