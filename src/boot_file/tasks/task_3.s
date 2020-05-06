
task_3:
            ; construct stack frame
            mov     ebp, esp

            push    dword 0                     ; EBP- 4 | x0 = 0 // x coordinate origin
            push    dword 0                     ;    - 8 | y0 = 0 // y coordinate origin
            push    dword 0                     ;    -12 | x  = 0 // x coordinate drawing
            push    dword 0                     ;    -16 | y  = 0 // y coordinate drawing
            push    dword 0                     ;    -20 | r  = 0 // angle

            ; initialization
            ; mov     esi, DRAW_PARAM
            mov     esi, 0x0010_7000                    ; test page fault exception

            ; display title
            mov     eax, [esi + rose.x0]
            mov     ebx, [esi + rose.y0]

            shr     eax, 3                              ; EAX /= 8    // convert x coordinate into char position
            shr     ebx, 4                              ; EBX /= 16   // convert y coordinate into char position
            dec     ebx                                 ; move up one char
            mov     ecx, [esi + rose.color_s]           ; char color
            lea     edx, [esi + rose.title]

            cdecl   draw_str, eax, ebx, ecx, edx

            ; midpoint of X axis
            mov     eax, [esi + rose.x0]
            mov     ebx, [esi + rose.x1]
            sub     ebx, eax
            shr     ebx, 1                              ; EBX /= 2
            add     ebx, eax
            mov     [ebp - 4], ebx                      ; x0 = EBX // x coordinate origin

            ; midpoint of Y axis
            mov     eax, [esi + rose.y0]
            mov     ebx, [esi + rose.y1]
            sub     ebx, eax
            shr     ebx, 1                              ; EBX /= 2
            add     ebx, eax
            mov     [ebp - 8], ebx                      ; y0 = EBX // y coordinate origin

            ; draw X axis
            mov     eax, [esi + rose.x0]
            mov     ebx, [ebp - 8]                      ; midpoint of y axis
            mov     ecx, [esi + rose.x1]

            cdecl   draw_line, eax, ebx, ecx, ebx, dword [esi + rose.color_x]

            ; draw Y axis
            mov     eax, [esi + rose.y0]
            mov     ebx, [ebp - 4]                      ; midpoint of x axis
            mov     ecx, [esi + rose.y1]

            cdecl   draw_line, ebx, eax, ebx, ecx, dword [esi + rose.color_y]

            ; draw frame
            mov     eax, [esi + rose.x0]
            mov     ebx, [esi + rose.y0]
            mov     ecx, [esi + rose.x1]
            mov     edx, [esi + rose.y1]

            cdecl   draw_rect, eax, ebx, ecx, edx, dword [esi + rose.color_z]

            ; Amplitude is about 95% of x axis
            mov     eax, [esi + rose.x1]
            sub     eax, [esi + rose.x0]
            shr     eax, 1                              ; EAX /= 2
            mov     ebx, eax
            shr     ebx, 4                              ; EAX /= 16
            sub     eax, ebx

            ; initialize FPU (initialize rose curve)
            cdecl   fpu_rose_init, eax, dword [esi + rose.n], dword [esi + rose.d]

.10L:

            ; coordinate culculation
            lea     ebx, [ebp - 12]                     ; x
            lea     ecx, [ebp - 16]                     ; y
            mov     eax, [ebp - 20]                     ; r

            cdecl   fpu_rose_update, ebx, ecx, eax

            ; update angle(r = r % 36000)
            mov     edx, 0
            inc     eax
            mov     ebx, 360 * 100
            div     ebx                                 ; EDX = EDX:EAX % EBX
            mov     [ebp - 20], edx

            ; draw dot
            mov     ecx, [ebp - 12]                     ; x
            mov     edx, [ebp - 16]                     ; y

            add     ecx, [ebp - 4]                      ; ECX += x coordinate origin
            add     edx, [ebp - 8]                      ; EDX += y coordinate origin

            mov     ebx, [esi + rose.color_f]           ; EBX = display color
            int     0x82                                ; syscall_82(display color, x, y)

            ; wait
            cdecl   wait_tick, 2

            ; draw dot(erase)
            mov     ebx, [esi + rose.color_b]           ; EBX = background color
            int     0x82                                ; syscall_82(display color, x, y)

            jmp     .10L

ALIGN 4, db 0
DRAW_PARAM:
.t3:
    istruc  rose
        at  rose.x0,            dd          32          ; upper left coordinate : X0
        at  rose.y0,            dd          32          ; upper left coordinate : Y0
        at  rose.x1,            dd         208          ; lower right coordinate : X1
        at  rose.y1,            dd         208          ; lower right coordinate : Y1

        at  rose.n,             dd           2          ; variable : n
        at  rose.d,             dd           1          ; variable : d

        at  rose.color_x,       dd         0x0007       ; display color : x axis
        at  rose.color_y,       dd         0x0007       ; display color : y axis
        at  rose.color_z,       dd         0x000F       ; display color : frame
        at  rose.color_s,       dd         0x030F       ; display color : char
        at  rose.color_f,       dd         0x000F       ; display color : graph display color
        at  rose.color_b,       dd         0x0003       ; display color : graph erase color

        at  rose.title,         db         "Task-3", 0  ; title
    iend

.t4:
    istruc  rose
        at  rose.x0,            dd         248          ; upper left coordinate : X0
        at  rose.y0,            dd          32          ; upper left coordinate : Y0
        at  rose.x1,            dd         424          ; lower right coordinate : X1
        at  rose.y1,            dd         208          ; lower right coordinate : Y1

        at  rose.n,             dd           3          ; variable : n
        at  rose.d,             dd           1          ; variable : d

        at  rose.color_x,       dd         0x0007       ; display color : x axis
        at  rose.color_y,       dd         0x0007       ; display color : y axis
        at  rose.color_z,       dd         0x000F       ; display color : frame
        at  rose.color_s,       dd         0x040F       ; display color : char
        at  rose.color_f,       dd         0x000F       ; display color : graph display color
        at  rose.color_b,       dd         0x0004       ; display color : graph erase color

        at  rose.title,         db         "Task-4", 0  ; title
    iend

.t5:
    istruc  rose
        at  rose.x0,            dd          32          ; upper left coordinate : X0
        at  rose.y0,            dd         272          ; upper left coordinate : Y0
        at  rose.x1,            dd         208          ; lower right coordinate : X1
        at  rose.y1,            dd         448          ; lower right coordinate : Y1

        at  rose.n,             dd           2          ; variable : n
        at  rose.d,             dd           6          ; variable : d

        at  rose.color_x,       dd         0x0007       ; display color : x axis
        at  rose.color_y,       dd         0x0007       ; display color : y axis
        at  rose.color_z,       dd         0x000F       ; display color : frame
        at  rose.color_s,       dd         0x050F       ; display color : char
        at  rose.color_f,       dd         0x000F       ; display color : graph display color
        at  rose.color_b,       dd         0x0005       ; display color : graph erase color

        at  rose.title,         db         "Task-5", 0  ; title
    iend

.t6:
    istruc  rose
        at  rose.x0,            dd         248          ; upper left coordinate : X0
        at  rose.y0,            dd         272          ; upper left coordinate : Y0
        at  rose.x1,            dd         424          ; lower right coordinate : X1
        at  rose.y1,            dd         448          ; lower right coordinate : Y1

        at  rose.n,             dd           4          ; variable : n
        at  rose.d,             dd           6          ; variable : d

        at  rose.color_x,       dd         0x0007       ; display color : x axis
        at  rose.color_y,       dd         0x0007       ; display color : y axis
        at  rose.color_z,       dd         0x000F       ; display color : frame
        at  rose.color_s,       dd         0x060F       ; display color : char
        at  rose.color_f,       dd         0x000F       ; display color : graph display color
        at  rose.color_b,       dd         0x0006       ; display color : graph erase color

        at  rose.title,         db         "Task-6", 0  ; title
    iend


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

fpu_rose_update:

            ; construct stack frame
                                                ;    +16 | t(angle)
                                                ;    +12 | Y(float)
                                                ; EBP+ 8 | X(float)
            push    ebp
            mov     ebp, esp

            ; save registers
            push    eax
            push    ebx

            ; set save_dest of X/Y coordinate
            mov     eax, [ebp +  8]
            mov     ebx, [ebp + 12]
                                                ; ---------+---------+---------+---------+---------+---------|
                                                ;      ST0 |     ST1 |     ST2 |     ST3 |     ST4 |     ST5 |
            fild    dword [ebp + 16]            ;       t  |      A  |      k  |      r  |xxxxxxxxx|xxxxxxxxx|
            fmul    st0, st3                    ;      rt  |         |         |         |         |         |
            fld     st0                         ;      rt  |     rt  |      A  |      k  |      r  |xxxxxxxxx|
                                                ;   θ=(rt) |  θ=(rt) |      A  |      k  |      r  |xxxxxxxxx|
                                                ; ---------+---------+---------+---------+---------+---------|
            fsincos                             ;   cos(θ) |  sin(θ) |      θ  |      A  |      k  |      r  |

            fxch    st2                         ;       θ  |  sin(θ) |  cos(θ) |      A  |      k  |      r  |
            fmul    st0, st4                    ;      kθ  |  sin(θ) |  cos(θ) |      A  |      k  |      r  |
            fsin                                ;  sin(kθ) |  sin(θ) |  cos(θ) |      A  |      k  |      r  |
            fmul    st0, st3                    ; Asin(kθ) |  sin(θ) |  cos(θ) |      A  |      k  |      r  |

            fxch    st2                         ;   cos(θ) |  sin(θ) | Asin(kθ)|      A  |      k  |      r  |
            fmul    st0, st2                    ;       X  |  sin(θ) | Asin(kθ)|      A  |      k  |      r  |
            fistp   dword [eax]                 ;   sin(θ) | Asin(kθ)|      A  |      k  |      r  |xxxxxxxxx|

            fmulp   st1, st0                    ;       Y  |      A  |      k  |      r  |xxxxxxxxx|xxxxxxxxx|
            fchs                                ;      -Y  |      A  |      k  |      r  |xxxxxxxxx|xxxxxxxxx|
            fistp   dword [ebx]                 ;       A  |      k  |      r  |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
                                                ; ---------+---------+---------+---------+---------+---------|

            ; return registers
            pop     ebx
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret