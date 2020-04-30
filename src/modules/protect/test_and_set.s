test_and_set:

            ; construct stack frame
                                                                    ; EBP+8 | address of global variable
            push    ebp
            mov     ebp, esp

            ; save registers
            push    eax
            push    ebx

            ; test and set
            mov     eax, 0                                          ; local = 0
            mov     ebx, [ebp + 8]                                  ; global = address

.10L:
            lock bts [ebx], eax                                     ; CF = TEST_AND_SET(IN_USE, 1)
            jnc     .10E                                            ; if(0 == CF)
                                                                    ;   break;

.12L:
            bt      [ebx], eax                                      ; CF = TEST(IN_USE, 1)
            jc      .12L                                            ; if(0 == CF)
                                                                    ;   break;
            jmp     .10L
.10E:

            ; return registers
            pop     ebx
            pop     eax

            ; destruct stakc frame
            mov     esp, ebp
            pop     ebp

            ret