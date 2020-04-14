read_lba:

            ;construct stack frame

            push    bp                                      ;  +10 | destination address
            mov     bp, sp                                  ;  + 8 | read sect num
                                                            ;  + 6 | LBA
                                                            ;BP+ 4 | address of drive struc

            ;save register

            push    si

            ;get argument
            mov     si, [bp + 4]                            ; si = drive info

            ;LBA -> CHS conversion
            mov     ax, [bp + 6]
            cdecl   lba_chs, si, .chs, ax

            ;copy drive no.
            mov     al, [si + drive.no]
            mov     [.chs + drive.no], al

            ;read sector
            cdecl   read_chs, .chs, word [bp + 8], word [bp + 10]
                                                            ; AX = read_chs(.chs, sect num, ofs)

            ;return register

            pop     si

            ;destruct stack frame

            mov     sp, bp
            pop     bp

            ret
ALIGN 2
.chs:	times drive_size	db	0

