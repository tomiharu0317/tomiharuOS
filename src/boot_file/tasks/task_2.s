task_2:

            cdecl   draw_str, 63, 1, 0x07, .s0

                                                ; ---------+---------+---------+---------+---------+---------|
                                                ;      ST0 |     ST1 |     ST2 |     ST3 |     ST4 |     ST5 |
                                                ; ---------+---------+---------+---------+---------+---------|
            fild    dword [.c1000]              ;     1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
            fldpi                               ;       pi |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
            fidiv   dword [.c180]               ;   pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
            fldpi                               ;       pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
            fadd    st0, st0                    ;     2*pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
            fldz                                ;    θ = 0 |    2*pi |  pi/180 |    1000 |xxxxxxxxx|xxxxxxxxx|
                                                ; ---------+---------+---------+---------+---------+---------|
                                                ;    θ = 0 |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
                                                ; ---------+---------+---------+---------+---------+---------|

                                                ; ---------+---------+---------+---------+---------+---------|
                                                ;      ST0 |     ST1 |     ST2 |     ST3 |     ST4 |     ST5 |
                                                ; ---------+---------+---------+---------+---------+---------|
.10L:                                           ;        θ |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
                                                ; ---------+---------+---------+---------+---------+---------|
            fadd    st0, st2                    ;    θ + d |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
            fprem                               ;    MOD(θ)|    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx| // fprem(ST0 %= ST1)
            fld     st0                         ;        θ |       θ |    2*pi |       d |    1000 |xxxxxxxxx|
            fsin                                ;    SIN(θ)|       θ |    2*pi |       d |    1000 |xxxxxxxxx|
            fmul    st0, st4                    ;ST4*SIN(θ)|       θ |    2*pi |       d |    1000 |xxxxxxxxx|
            fbstp   [.bcd]                      ;        θ |    2*pi |       d |    1000 |xxxxxxxxx|xxxxxxxxx|
                                                ; ---------+---------+---------+---------+---------+---------|

            ; convert into ASCII code
            mov     eax, [.bcd]                 ; EAX = 1000 * sin(t)
            mov     ebx, eax                    ; EBX = EAX

            and     eax, 0x0F0F                 ; mask upper 4 bits
            or      eax, 0x3030                 ; set 0x3 to upper 4 bits

            shr     ebx, 4                      ; EBX = upper 16 bits
            and     ebx, 0x0F0F
            or      ebx, 0x3030

            ; set the result to the buffer which is for screen display byte by byte
            mov     [.s2 + 0], bh               ; first digit
            mov     [.s3 + 0], ah               ; the first decimal place
            mov     [.s3 + 1], bl               ; the second decimal place
            mov     [.s3 + 2], al               ; the third decimal place

            ; whether displaying sign or not
            mov     eax, 7
            bt      [.bcd + 9], eax             ; CF = bcd[9] & 0x80
            jc      .10F

            mov     [.s1 + 0], byte '+'
            jmp     .10E
.10F:
            mov     [.s1 + 0], byte '-'
.10E:
            cdecl   draw_str, 72, 1, 0x07, .s1

            ; wait
            cdecl   wait_tick, 10

;           mov		ecx, 20							;   ECX = 20
; 		    										;   do
; 		    										;   {
; .20L:	    mov		eax, [TIMER_COUNT]				;     EAX = TIMER_COUNT;
; .21L:	    cmp		[TIMER_COUNT], eax				;     while (TIMER_COUNT != EAX)
; 		    je		.21L							;       ;
; 		    loop	.20L							;   } while (--ECX);

; 		    jmp		.10L							; }

            jmp     .10L

ALIGN 4, db 0
.c1000:     dd  1000
.c180:      dd  180

.bcd:       times 10 db 0x00

.s0:        db   "Task-2", 0
.s1:        db  "-"
.s2:        db  "0."
.s3:        db  "000", 0