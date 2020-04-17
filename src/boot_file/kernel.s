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
                mov     [FONT_ADR], eax                             ; FONT[0] = EAX

                ; 8 bit horizontal line
                mov     ah, 0x07                                ; AH = specify writing plane(Bit:----IRGB)
                mov     al, 0x02                                ; AL = map mask register(specify writing plane)
                mov     dx, 0x03C4                              ; DX = sequencer control port(address register)
                out     dx, ax

                mov     [0x000A_0000 + 0], byte 0xFF

                mov     ah, 0x04
                out     dx, ax

                mov     [0x000A_0000 + 1], byte 0xFF

                mov     ah, 0x02
                out     dx, ax

                mov     [0x000A_0000 + 2], byte 0xFF

                mov     ah, 0x01
                out     dx, ax

                mov     [0x000A_0000 + 3], byte 0xFF

                ; a horizontal line crossing the screen
                mov     ah, 0x02                                ; AH = (Bit:----IRGB)
                out     dx, ax

                lea     edi, [0x000A_0000 + 80]                 ; EDI = VRAM address
                mov     ecx, 80                                 ; repeat num of times
                mov     al, 0xFF
                rep     stosb                                   ; stosb: [EDI] = AL
                                                                ; *EDI++ = AL

                ; 8 dot rectangle
                mov     edi, 1                                  ; EDI = num of lines

                shl     edi, 8                                  ; EDI *= 256
                lea     edi, [edi * 4 + edi + 0xA_0000]         ; EDI*4 + EDI == EDI + 1280(one line) // VRAM address

                mov     [edi + (80 * 0)], word 0xFF
                mov     [edi + (80 * 1)], word 0xFF
                mov     [edi + (80 * 2)], word 0xFF
                mov     [edi + (80 * 3)], word 0xFF
                mov     [edi + (80 * 4)], word 0xFF
                mov     [edi + (80 * 5)], word 0xFF
                mov     [edi + (80 * 6)], word 0xFF
                mov     [edi + (80 * 7)], word 0xFF

                ; put char
                mov     esi, 'A'                                ; ESI = char code
                shl     esi, 4                                  ; ESI *= 16
                add     esi, [FONT_ADR]                         ; ESI += FONT_ADR[char code]

                mov     edi, 2                                  ; num of lines
                shl     edi, 8                                  ; EDI *= 256
                lea     edi, [edi * 4 + edi + 0xA_0000]         ; VRAM address

                mov     ecx, 16                                 ; height of one char
.10L:
                movsb                                           ; [DI] = [SI]
                add     edi, 80 - 1
                loop    .10L                                    ; while(--ECX)

                ; End of Process
                jmp     $

ALIGN 4, db 0
FONT_ADR:   dd 0

                ; Padding

                times   KERNEL_SIZE - ($ - $$)      db 0x00     ; size of kernel // 8K byte