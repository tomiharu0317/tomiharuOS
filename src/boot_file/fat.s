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

;----------------------------------------------------------------
;   FAT:ROOT DIRECTORY SPACE
;----------------------------------------------------------------
            times (ROOT_START) - ($ - $$)   db  0x00
;----------------------------------------------------------------
FAT_ROOT:
            db      'BOOTABLE', 'DSK'                           ; + 0:volume label
            db      ATTR_ARCHIVE | ATTR_VOLUME_ID              ; +11:type
            db      0x00                                        ; +12:(reserved)
            db      0x00                                        ; +13:TS
            dw      ( 0 << 11) | ( 0 << 5) | (0 / 2)            ; +14:created time
            dw      ( 0 <<  9) | ( 0 << 5) | ( 1)               ; +16:created day
            dw      ( 0 <<  9) | ( 0 << 5) | ( 1)               ; +18:accessed day
            dw      0x0000                                      ; +20:(reserved)
            dw      ( 0 << 11) | ( 0 << 5) | (0 / 2)            ; +22:updated time
            dw      ( 0 <<  9) | ( 0 << 5) | ( 1)               ; +24:updated day
            dw      0                                           ; +26:first cluster
            dd      0                                           ; +28:file size

            db      'SPECIAL ', 'TXT'                           ; + 0:volume label
            db      ATTR_ARCHIVE                                ; +11:type
            db      0x00                                        ; +12:(reserved)
            db      0x00                                        ; +13:TS
            dw      ( 0 << 11) | ( 0 << 5) | (0 / 2)            ; +14:created time
            dw      ( 0 <<  9) | ( 0 << 5) | ( 1)               ; +16:created day
            dw      ( 0 <<  9) | ( 0 << 5) | ( 1)               ; +18:accessed day
            dw      0x0000                                      ; +20:(reserved)
            dw      ( 0 << 11) | ( 0 << 5) | (0 / 2)            ; +22:updated time
            dw      ( 0 <<  9) | ( 0 << 5) | ( 1)               ; +24:updated day
            dw      2                                           ; +26:first cluster
            dd      FILE.end - FILE                             ; +28:file size

;----------------------------------------------------------------
;   FAT:DATA SPACE
;----------------------------------------------------------------
            times FILE_START - ($ - $$) db 0x00
;----------------------------------------------------------------
FILE:       db      'THANKS!'
.end:       db      0

ALIGN 512, db 0x00

            times (512 * 63)    db 0x00