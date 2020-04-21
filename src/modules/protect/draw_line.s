draw_line:

            ; construct stack frame
            ; and reserve stack for some local variables

            ;   +24 | display color
            ;   +20 | Y_end
            ;   +16 | X_end
            ;   +12 | Y_start
            ;   + 8 | X_start
            ;EBP+ 4 | IP
            ;EBP+ 0 | EBP
            ;   - 4 | sum       = 0 // total value of relative axis
            ;   - 8 | X_start   = 0 // x coordinate
            ;   -12 | dx        = 0 // x increment
            ;   -16 | inc_x     = 0 // increment of x coordinate(1 or -1)
            ;   -20 | Y_start   = 0 // y coordinate
            ;   -24 | dy        = 0 // y increment
            ;   -28 | inc_y     = 0 // increment of y coordinate(1 or -1)

            push    ebp
            mov     ebp, esp

            push    dword 0
            push    dword 0
            push    dword 0
            push    dword 0
            push    dword 0
            push    dword 0
            push    dword 0

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    esi
            push    edi

            ; calculate width(X axis)
            mov     eax, [ebp + 8]                                  ; eax = x_start
            mov     ebx, [ebp + 16]                                 ; ebx = x_end
            sub     ebx, eax                                        ; ebx = x_e - x_s //width
            jge     .10F                                            ; if (width < 0){

            neg     ebx                                             ;   width *= -1
            mov     esi, -1                                         ;   // increment of x coordinate
            jmp     .10E                                            ; } else {
.10F:
            mov     esi, 1                                          ;   // increment of x coordinate
.10E:                                                               ; }

            ; calculate height(Y axis)
            mov     ecx, [ebp + 12]                                 ; eax = y_start
            mov     edx, [ebp + 20]                                 ; ebx = y_end
            sub     edx, ecx                                        ; ebx = y_e - y_s //height
            jge     .20F                                            ; if (height < 0){

            neg     edx                                             ;   height *= -1
            mov     edi, -1                                         ;   // increment of y coordinate
            jmp     .20E                                            ; } else {
.20F:
            mov     edi, 1                                          ;   // increment of y coordinate
.20E:                                                               ; }

            ; store the calculated value in local variables

            ; X axis
            mov     [ebp -  8], eax                                  ; start coordinate
            mov     [ebp - 12], ebx                                 ; width
            mov     [ebp - 16], esi                                 ; increment(base axis: 1 or -1)

            ; Y axis
            mov     [ebp - 20], ecx                                 ; start coordinate
            mov     [ebp - 24], edx                                 ; height
            mov     [ebp - 28], edi                                 ; increment(base axis: 1 or -1)

            ;--------------------------------------------------
            ; what is base axis?
            ; x axis if (width > height) else y axis.
            ; relative axis is what is not base axis.
            ;--------------------------------------------------

            ; define base axis
            cmp     ebx, edx                                        ; if (width <= height)
            jg      .22F                                            ; {

            lea     esi, [ebp - 20]                                 ;   // x axis is base one.
            lea     edi, [ebp -  8]                                 ;   // y axis is relative one.
                                                                    ; }
            jmp     .22E                                            ; else
.22F:                                                               ; {
                                                                    ;   // y axis is base one.
            lea     esi, [ebp -  8]                                 ;   // x axis is relative one.
            lea     edi, [ebp - 20]                                 ; }
.22E:

            ; num of repetitions(== num of dots of base axis)
            mov     ecx, [esi - 4]                                  ; ECX == width of base axis
            cmp     ecx, 0
            jnz     .30E
            mov     ecx, 1
.30E:

            ; draw line
.50L:
            cdecl   draw_pixel, dword [ebp -  8], \
                                dword [ebp - 20], \
                                dword [ebp + 24]

            ; update base axis(1 dot)
            mov     eax, [esi - 8]                                  ; EAX = inc of base axis(1 or -1)
            add     [esi - 0], eax

            ; update relative axis
            mov     eax, [ebp - 4]                                  ; EAX = sum // total val of relative axis
            add     eax, [edi - 4]                                  ; EAX += dy // inc(draw_width of relative axis)

            mov     ebx, [esi - 4]                                  ; EBX = dx  // inc(draw_width of base axis)

            cmp     eax, ebx                                        ; if (total val <= inc of relative axis)
            jl      .52E                                            ; {
            sub     eax, ebx                                        ;   EAX -= EBX // subtract inc of relative axis from total val
                                                                    ;   // update coordinate of relative axis(1 dot)
            mov     ebx, [edi - 8]                                  ;   EBX = inc of relative axis
            add     [edi - 0], ebx
.52E:                                                               ; }

            mov     [ebp - 4], eax                                  ; update total val

            loop    .50L
.50E:

            ; return registers
            pop     edi
            pop     esi
            pop     edx
            pop     ecx
            pop     ebx
            pop     eax

            ; destruct stack frame
            mov     esp, ebp
            pop     ebp

            ret