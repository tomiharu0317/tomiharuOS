draw_pixel:

            ; construct stack frame                                 ;   +16 | display color
            push    ebp                                             ;   +12 | Y coordinate
            mov     ebp, esp                                        ;EBP+ 8 | X coordinate

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    esi
            push    edi

            ;
            ; calculate the corresponding VRAM address
            ;

            ; multiply Y coordinate by 80 (640/8)
            mov     edi, [ebp + 12]
            shl     edi, 4                                          ; EDI *= 4
            lea     edi, [edi * 4 + edi + 0xA_0000]                 ; 80 = 16 * 4 + 16

            ; divide X coodinate by 8 and add
            mov     ebx, [ebp + 8]
            mov     ecx, ebx                                        ; ECX = x coodinate(buffer)
            shr     ebx, 3                                          ; EBX /= 8
            add     edi, ebx                                        ; EDX += EBX

            ; calculate bit position from remainder of X coordinate divided by 8
            ; (0=0x80, 1=0x40,... 7=0x01)

            and     ecx, 0x07                                       ; ECX = X & 0x07
            mov     ebx, 0x80
            shr     ebx, cl                                         ; EBX >>= ECX

            ; color specification
            mov     ecx, [ebp + 16]

%ifdef      USE_TEST_AND_SET
            cdecl   test_and_set, IN_USE
%endif

            ;------------------------------------------------------------------------

            cdecl   vga_set_read_plane, 0x03                    ; writing plane : luminance(I)
            cdecl   vga_set_write_plane, 0x08                   ; reading plane : luminance(I)
            cdecl   vram_bit_copy, ebx, edi, 0x08, ecx

            cdecl   vga_set_read_plane, 0x02                    ; writing plane : red(R)
            cdecl   vga_set_write_plane, 0x04                   ; reading plane : red(R)
            cdecl   vram_bit_copy, ebx, edi, 0x04, ecx

            cdecl   vga_set_read_plane, 0x01                    ; writing plane : green(G)
            cdecl   vga_set_write_plane, 0x02                   ; reading plane : green(G)
            cdecl   vram_bit_copy, ebx, edi, 0x02, ecx

            cdecl   vga_set_read_plane, 0x00                    ; writing plane : blue(B)
            cdecl   vga_set_write_plane, 0x01                   ; reading plane : blue(B)
            cdecl   vram_bit_copy, ebx, edi, 0x01, ecx

%ifdef      USE_TEST_AND_SET

            mov     [IN_USE], dword 0
%endif

            ; return registers
            pop     edi
            pop     esi
            pop     edx
            pop     ecx
            pop     ebx
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret
