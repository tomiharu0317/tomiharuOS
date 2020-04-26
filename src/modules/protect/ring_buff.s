ring_rd:

            ; construct stack frame                                     ;    +12 | save_dest address
            push    ebp                                                 ; EBP+ 8 | ring buffer
            mov     ebp, esp

            ; save registers
            push    eax
            push    ebx
            push    esi
            push    edi

            ; get args
            mov     esi, [ebp +  8]
            mov     edi, [ebp + 12]

            ; confirm the reading location
            mov     eax, 0                                              ; EAX = 0 // no data
            mov     ebx, [esi + ring_buff.rp]                           ; EBX = rp
            cmp     ebx, [esi + ring_buff.wp]                           ; if (EBX != wp)
            je      .10E                                                ; {

            mov     al, [esi + ring_buff.item + ebx]                    ;   AL = BUFFER[rp] // store key code(unit:byte)

            mov     [edi], al                                           ;   [EDI] = AL      // save data

            inc     ebx                                                 ;   EBX++           // next reading location
            and     ebx, RING_INDEX_MASK                                ;   EBX &= 0x0F     // limit size
            mov     [esi + ring_buff.rp], ebx                           ;   wp = EBX        // save the reading location

            mov     eax, 1                                              ;   EAX = 1         // data exists
.10E:                                                                   ; }

            ; return registers
            pop     edi
            pop     esi
            pop     ebx
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret