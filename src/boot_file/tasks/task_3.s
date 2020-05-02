; fpu_rose_init:

;                                                 ; ---------+---------+---------+---------+---------+---------|
;                                                 ;      ST0 |     ST1 |     ST2 |     ST3 |     ST4 |     ST5 |
;                                                 ; ---------+---------+---------+---------+---------+---------|
;             fldpi                               ;   pi     |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
;             fidiv   dword [.c180]               ;   pi/180 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
;                                                 ; ---------+---------+---------+---------+---------+---------|
;                                                 ; ---------+---------+---------+---------+---------+---------|
;                                                 ;      ST0 |     ST1 |     ST2 |     ST3 |     ST4 |     ST5 |
;                                                 ; ---------+---------+---------+---------+---------+---------|
;                                                 ;        r |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
;                                                 ; ---------+---------+---------+---------+---------+---------|
;             fild    dword [.n]                  ;        n |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
;             fidiv   dword [.d]                  ;      n/d |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
;                                                 ; ---------+---------+---------+---------+---------+---------|
;                                                 ;      ST0 |     ST1 |     ST2 |     ST3 |     ST4 |     ST5 |
;                                                 ;        k |       r |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
;             fild    dword [.A]                  ;        A |       k |       r |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|

; ALIGN 4, db 0
; .c1000:     dd  1000
; .c180:      dd  180

; .n: dd 5
; .d: dd 3
; .A: dd 90

;--------------------------------------------------------------------------------------------------------------
; PREPROCESSING

fpu_rose_init:

                                                ;    +16 | d
                                                ;    +12 | n
                                                ; EBP+ 8 | A
            push    ebp
            mov     ebp, esp

            push    dword 180                   ;    - 4 | dword i = 180

            fldpi
            fidiv   dword [ebp -  4]
            fild    dword [ebp + 12]
            fidiv   dword [ebp + 16]
            fild    dword [ebp +  8]
                                                ; ---------+---------+---------+---------+---------+---------|
                                                ;      ST0 |     ST1 |     ST2 |     ST3 |     ST4 |     ST5 |
                                                ;        A |       k |       r |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
                                                ; ---------+---------+---------+---------+---------+---------|

            mov     esp, ebp
            pop     ebp

            ret
