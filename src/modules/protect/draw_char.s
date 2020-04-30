draw_char:

            ; construct stack frame                             ;   +20 | char code
            push    ebp                                         ;   +16 | color
            mov     ebp, esp                                    ;   +12 | row(0~29)
                                                                ;EBP+ 8 | column(0~79)

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    esi
            push    edi

%ifdef      USE_TEST_AND_SET
            cdecl   test_and_set, IN_USE                        ; TEST_AND_SET(IN_USE) // waiting for resource to be available
%endif

            ; set copy_target font address
            movzx   esi, byte [ebp + 20]
            shl     esi, 4                                      ; *= 16 // 16 byte per char
            add     esi, [FONT_ADR]                             ; ESI = font address

            ; get copy_dest VRAM address
            ; ADR = 0xA0000 + ( ( 640 / 8) * 16 ) * y + x
            ; y:row, x:column

            mov     edi, [ebp + 12]
            shl     edi, 8                                      ; EDI = row * 256
            lea     edi, [edi * 4 + edi + 0xA0000]              ; EDI = row * 4 + row
            add     edi, [ebp + 8]

            ; output a char of font
            movzx   ebx, word [ebp + 16]

            cdecl   vga_set_read_plane, 0x03                    ; writing plane : luminance(I)
            cdecl   vga_set_write_plane, 0x08                   ; reading plane : luminance(I)
            cdecl   vram_font_copy, esi, edi, 0x08, ebx

            cdecl   vga_set_read_plane, 0x02                    ; writing plane : red(R)
            cdecl   vga_set_write_plane, 0x04                   ; reading plane : red(R)
            cdecl   vram_font_copy, esi, edi, 0x04, ebx

            cdecl   vga_set_read_plane, 0x01                    ; writing plane : green(G)
            cdecl   vga_set_write_plane, 0x02                   ; reading plane : green(G)
            cdecl   vram_font_copy, esi, edi, 0x02, ebx

            cdecl   vga_set_read_plane, 0x00                    ; writing plane : blue(B)
            cdecl   vga_set_write_plane, 0x01                   ; reading plane : blue(B)
            cdecl   vram_font_copy, esi, edi, 0x01, ebx

%ifdef      USE_TEST_AND_SET

            mov     [IN_USE], dword 0                           ; clear global variable
%endif

            ; return registers
            pop		edi
		    pop		esi
		    pop		edx
		    pop		ecx
		    pop		ebx
		    pop		eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret

%ifdef      USE_TEST_AND_SET
ALIGN 4, db 0
IN_USE: dd 0
%endif