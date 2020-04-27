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
            mov     [esi + ring_buff.rp], ebx                           ;   rp = EBX        // save the reading location

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

ring_wr:

            ; construct stack frame                                     ;    +12 | data to write
            push    ebp                                                 ; EBP+ 8 | ring buffer
            mov     ebp, esp

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    esi
            push    edi

            ; get args
            mov     esi, [ebp + 8]

            ; confirm the writing location
            mov     eax, 0
            mov     ebx, [esi + ring_buff.wp]                           ; writing position
            mov     ecx, ebx
            inc     ecx                                                 ; next writing location
            and     ecx, RING_INDEX_MASK                                ; size limit

            cmp     ecx, [esi + ring_buff.rp]                           ; if (ECX != rp)
            je      .10E                                                ; {

            mov     al, [ebp + 12]                                      ;   AL = data

            mov     [esi + ring_buff.item + ebx], al                    ;   BUFFER[wp] = AL // save key code
            mov     [esi + ring_buff.wp], ecx                           ;   wp = ECX        // save the writing location
            mov     eax, 1
.10E:

            ; return registers
            pop     edi
            pop     esi
            pop     ecx
            pop     ebx
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret

draw_key:

            ; construct stack frame                                     ;    +16 | ring buffer
            push    ebp                                                 ;    +12 | row
            mov     ebp, esp                                            ; EBP+ 8 | col

            ; save registers
            pusha                                                       ; save EAX,EBX,ECX,EDX,EDI,ESI,EBP,ESP

            ; get args
            mov     edx, [ebp +  8]
            mov     edi, [ebp + 12]
            mov     esi, [ebp + 16]

            ; get ring buffer info
            mov     ebx, [esi + ring_buff.rp]                           ; EBX = wp // writing location
            lea     esi, [esi + ring_buff.item]
            mov     ecx, RING_ITEM_SIZE

            ; display data
.10L:

            dec     ebx                                                 ; EBX-- == where data exists
            and     ebx, RING_INDEX_MASK
            mov     al, [esi + ebx]                                     ; EAX = KEY_BUFF[EBX]

            cdecl   int_to_str, eax, .tmp, 2, 16, 0b0100
            cdecl   draw_str, edx, edi, 0x02, .tmp

            add     edx, 3                                              ; updata display position(3 chars)

            loop    .10L
.10E:

            ; return registers
            popa

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret

.tmp        db "-- ", 0