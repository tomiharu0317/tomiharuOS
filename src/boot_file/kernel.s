;macro

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

                ; display font and color_bar
                cdecl   draw_font, 63, 13
                cdecl   draw_color_bar, 63, 4

                ; display string
                cdecl   draw_str, 25, 14, 0x010F, .s0

                ; End of Process
                jmp     $
;data
.s0    db  " Hello, kernel! ", 0

ALIGN 4, db 0
FONT_ADR:   dd 0


; modules
%include    "../modules/protect/vga.s"
%include    "../modules/protect/draw_char.s"
%include    "../modules/protect/draw_font.s"
%include    "../modules/protect/draw_str.s"
%include    "../modules/protect/draw_color_bar.s"

                ; Padding

                times   KERNEL_SIZE - ($ - $$)      db 0x00     ; size of kernel // 8K byte