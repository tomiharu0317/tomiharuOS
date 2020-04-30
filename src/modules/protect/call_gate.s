;--------------------------------------------------
; This is a rapper of draw_str func.
;--------------------------------------------------

call_gate:

            ; construct stack frame
                                                                    ;    +24 | char
                                                                    ;    +20 | display color
                                                                    ;    +16 | row
                                                                    ;    +12 | column
                                                                    ; EBP+ 8 | CS(code segment)
            push    ebp
            mov     ebp, esp

            ; save registers
            pusha
            push    ds
            push    es

            ; set up segment for data
            mov     ax, 0x0010
            mov     ds, ax
            mov     es, ax

            ; display string
            mov     eax, dword [ebp + 12]
            mov     ebx, dword [ebp + 16]
            mov     ecx, dword [ebp + 20]
            mov     edx, dword [ebp + 24]
            cdecl   draw_str, eax, ebx, ecx, edx

            ; return registers
            pop     es
            pop     ds
            popa

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            retf 4*4                                                ; end func and adjust arguments