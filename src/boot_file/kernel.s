;マクロ

%include    "../include/define.s"
%include    "../include/macro.s"

                ORG     KERNEL_LOAD                             ; load address of kernel

[BITS 32]                                                       ; BIT 32 directive
; entry point

kernel:

                ; Get Font address
                mov     esi, BOOT_LOAD + SECT_SIZE              ; ESI = 0x7x00 + 512
                movzx   eax, word [esi + 0]                     ; segment
                movzx   ebx, word [esi + 2]                     ; offset
                shl     eax, 4
                add     eax, ebx
                mov     [FONT_ADR], eax                         ; FONT_ADR[0] = EAX

                ; put char
                cdecl   draw_char, 0, 0, 0x010F, 'A'
                cdecl   draw_char, 1, 0, 0x010F, 'B'
                cdecl   draw_char, 2, 0, 0x010F, 'C'

                cdecl   draw_char, 0, 0, 0x0402, '0'
                cdecl   draw_char, 1, 0, 0x0212, '1'
                cdecl   draw_char, 2, 0, 0x0212, '_'

                ; End of Process
                jmp     $

ALIGN 4, db 0
FONT_ADR:   dd 0

; modules
%include    "../modules/protect/vga.s"
%include    "../modules/protect/draw_char.s"

                ; Padding

                times   KERNEL_SIZE - ($ - $$)      db 0x00     ; size of kernel // 8K byte