;マクロ

%include    "../include/define.s"
%include    "../include/macro.s"

        ORG     KERNEL_LOAD                             ; load address of kernel

[BITS 32]                                               ; BIT 32 directive
; entry point

kernel:
            ; End of Process

            jmp     $

; Padding

            times   KERNEL_SIZE - ($ - $$)      db 0    ; size of kernel // 8K byte