init_pic:

            ; save register
            push    eax

            ; set up Master PIC
            outp    0x20, 0x11                              ; MASTER.ICW1 = 0x11
            outp    0x21, 0x20                              ; MASTER.ICW2 = 0x20 // interrupt vector
            outp    0x21, 0x04                              ; MASTER.ICW3 = 0x04 // slave connection position : IRQ2
            outp    0x21, 0x05                              ; MASTER.ICW4 = 0x05
            outp    0x21, 0xFF                              ; master interrupt mask

            ; set up Slave
            outp    0xA0, 0x11                              ; SLAVE.ICW1 = 0x11
            outp    0xA1, 0x28                              ; SLAVE.ICW2 = 0x28 // interrupt vector
            outp    0xA1, 0x02                              ; SLAVE.ICW3 = 0x02 // slave ID = 2
            outp    0xA1, 0x01                              ; SLAVE.ICW4 = 0x01
            outp    0xA1, 0xFF                              ; slave interrupt mask

            ; return regisiter
            pop     eax

            ret