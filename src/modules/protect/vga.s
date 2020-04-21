vga_set_read_plane:

            ; construct stack frame
            push    ebp                                     ;   +8 | reading plane
            mov     ebp, esp                                ;   +4 | IP(instruction pointer)
                                                            ;EBP+0 | EBP

            ; save registers
            push    eax
            push    edx

            ; choose reading plane
            mov     ah, [ebp + 8]                           ; 3=luminance, 2~0=RGB
            and     ah, 0x03                                ; bit mask
            mov     al, 0x04                                ; register of choosing reading plane
            mov     dx, 0x03CE                              ; DX = graphix control port
            out     dx, ax

            ; return registers
            pop     edx
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret

vga_set_write_plane:

            ; construct stack frame
            push    ebp                                     ;   +8 | writing plane
            mov     ebp, esp                                ;   +4 | IP(instruction pointer)
                                                            ;EBP+0 | EBP

            ; save registers
            push    eax
            push    edx

            ; choose writing plane
            mov     ah, [ebp + 8]                           ; AH = ----IRGB
            and     ah, 0x0F                                ; bit mask
            mov     al, 0x02                                ; AL = map mask register(choosing writing plane)
            mov     dx, 0x03C4                              ; DX = sequencer control port
            out     dx, ax

            ; return registers
            pop     edx
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret

vram_font_copy:

            ; construct stack frame                         ;   +20 | color
            push    ebp                                     ;   +16 | color plane
            mov     ebp, esp                                ;   +12 | VRAM address
                                                            ;EBP+ 8 | font address

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    esi
            push    edi

            ; get arguments
            mov     esi, [ebp + 8]
            mov     edi, [ebp + 12]
            movzx   eax, byte [ebp + 16]                    ; EAX = color plane // zero expansion
            movzx   ebx, word [ebp + 20]                    ; EBX = color

            ; make mask data
            test    bh, al                                  ; ZF = (background color & color plane)
            setz    dh                                      ; DH = 0x01 if (ZF == 1) else DH = 0x00
            dec     dh                                      ; DH = 0x00 or 0xFF

            test    bl, al                                  ; ZF = (foreground color & color plane)
            setz    dl                                      ; DH = 0x01 if (ZF == 1) else DH = 0x00
            dec     dl                                      ; DH = 0x00 or 0xFF

            ; copy 16 dot font
            cld                                             ; DF = 0 // plus

            mov     ecx, 16                                 ; font data(height = 16, length = 8)
.10L:

            ; make reversed font
            lodsb                                           ; AL = [ESI]; ESI += <op><size>
            mov     ah, al
            not     ah

            ; foreground color
            and     al, dl                                  ; AL = font & foreground color

            ; background color
            test    ebx, 0x0010                             ; if (transmissive mode)
            jz      .11F                                    ; {
            and     ah, [edi]                               ;   AH = !font & [EDI]; // get current value
            jmp     .11E                                    ; } else
.11F:                                                       ; {
            and     ah, dh                                  ;   AH = !font & background color;
                                                            ; }

.11E:
            ; synthesize bakcground & foreground color
            or      al, ah

            ; out new value
            mov     [edi], al

            add     edi, 80
            loop    .10L
.10E:

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

vram_bit_copy:

            ; construct stack frame                         ;   +20 | display color
            push    ebp                                     ;   +16 | color plane
            mov     ebp, esp                                ;   +12 | VRAM address
                                                            ;EBP+ 8 | bit data

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    esi
            push    edi

            ; get arguments
            mov     edi, [ebp + 12]
            movzx   eax, byte [ebp + 16]
            movzx   ebx, word [ebp + 20]

            ; make mask data(always transmissive mode => only foreground)

            test    bl, al                                  ; ZF = (foreground color & color plane)
            setz    dl                                      ; DH = 0x01 if (ZF == 1) else DH = 0x00
            dec     dl                                      ; DH = 0x00 or 0xFF

            mov     al, [ebp + 8]                           ; AL = output bit pattern
            mov     ah, al
            not     ah                                      ; AH = reversed bit data

            ; drawing process
            and     ah, [edi]                               ; AH = !output bit pattern & current val
            and     al, bl                                  ; AL =  output bit pattern & display color
            or      al, ah
            mov     [edi], al

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