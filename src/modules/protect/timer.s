int_en_timer0:

            ; save register
            push    eax                                     ; use eax register on outp

            outp    0x43, 0b_00_11_010_0                    ; counter 0|access way:lower/upper|mode 2|16 bit binary couner
            outp    0x40, 0x9C                              ; lower byte
            outp    0x40, 0x2E                              ; upper byte

            ; return register
            pop     eax

            ret