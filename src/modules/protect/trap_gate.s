trap_gate_81:

            ; output a char
            cdecl   draw_char,  ecx, edx, ebx, eax

            iret

trap_gate_82:

            ; draw dot
            cdecl   draw_pixel, ecx, edx, ebx

            iret