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
            cdecl  page_set_4m, CR3_BASE                               ; make page conversion table : for task3
            cdecl  page_set_4m, CR3_TASK_4                             ; make page conversion table : for task4
            cdecl  page_set_4m, CR3_TASK_5                             ; make page conversion table : for task5
            cdecl  page_set_4m, CR3_TASK_6                             ; make page conversion table : for task6

            ; set page table(absense)
            mov    [0x0010_6000 + 0x107 * 4], dword 0                  ; set 0x0010_7000 to the page not exist

            ; set address conversion
            mov    [0x0020_1000 + 0x107 * 4], dword PARAM_TASK_4 + 7   ; address conversion : for task4
            mov    [0x0020_3000 + 0x107 * 4], dword PARAM_TASK_5 + 7   ; address conversion : for task5
            mov    [0x0020_5000 + 0x107 * 4], dword PARAM_TASK_6 + 7   ; address conversion : for task6

            ; set drawing params
            cdecl   memcpy, PARAM_TASK_4, DRAW_PARAM.t4, rose_size      ; drawing params : for task4
            cdecl   memcpy, PARAM_TASK_5, DRAW_PARAM.t5, rose_size      ; drawing params : for task5
            cdecl   memcpy, PARAM_TASK_6, DRAW_PARAM.t6, rose_size      ; drawing params : for task6



            ; return registers
            popa

            ret