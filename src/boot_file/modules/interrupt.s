int_stop:

            ; display the string indicated in EAX
            cdecl   draw_str, 25, 15, 0x060F, eax

            ; convert stack data into string
            mov     eax, [esp + 0]                                  ; EIP
            cdecl   int_to_str, eax, .p1, 8, 16, 0b0100

            mov     eax, [esp + 4]                                  ; CS
            cdecl   int_to_str, eax, .p2, 8, 16, 0b0100

            mov     eax, [esp + 8]                                  ; EFLAGS
            cdecl   int_to_str, eax, .p3, 8, 16, 0b0100

            mov     eax, [esp + 12]
            cdecl   int_to_str, eax, .p4, 8, 16, 0b0100

            ; display string
            cdecl   draw_str, 25, 16, 0x0F04, .s1
            cdecl   draw_str, 25, 17, 0x0F04, .s2
            cdecl   draw_str, 25, 18, 0x0F04, .s3
            cdecl   draw_str, 25, 19, 0x0F04, .s4

            ; infinite loop
            jmp     $

.s1         db  "ESP+ 0:"
.p1         db  "-------- ", 0
.s2         db  "   + 4:"
.p2         db  "-------- ", 0
.s3         db  "   + 8:"
.p3         db  "-------- ", 0
.s4         db  "   +12:"
.p4         db  "-------- ", 0


