;----------------------------------------------------------------
;   FAT:FAT-1
;----------------------------------------------------------------
            times (FAT1_START) - ($ - $$)   db  0x00
;----------------------------------------------------------------
FAT1:
            db      0xFF, 0xFF                                   ; cluster 0
            dw      0xFFFF                                       ; cluster 1
            dw      0xFFFF                                       ; cluster 2

;----------------------------------------------------------------
;   FAT:FAT-2
;----------------------------------------------------------------
            times (FAT2_START) - ($ - $$)   db  0x00
;----------------------------------------------------------------
FAT2:
            db      0xFF, 0xFF                                   ; cluster 0
            dw      0xFFFF                                       ; cluster 1
            dw      0xFFFF                                       ; cluster 2
