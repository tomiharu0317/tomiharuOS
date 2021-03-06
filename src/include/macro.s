%macro  cdecl 1-*.nolist

    %rep  %0 - 1
        push    %{-1:-1}
        %rotate -1
    %endrep
    %rotate -1

        call    %1

    %if 1 < %0
        add     sp, (__BITS__ >> 3) * (%0 - 1)
    %endif

%endmacro

%macro  set_vect 1-*
        push    eax
        push    edi

        mov     edi, VECT_BASE + (%1 * 8)   ; vector address
        mov     eax, %2

    %if 3 == %0
        mov     [edi + 4], %3               ; flag
    %endif

        mov     [edi + 0], ax               ; exception address[15:0]
        shr     eax, 16
        mov     [edi + 6], ax               ; exception address[31:16]

        pop     edi
        pop     eax
%endmacro

%macro  outp 2
        mov     al, %2
        out     %1, al
%endmacro

%macro  set_desc 2-*
            push    eax
            push    edi

            mov     edi, %1                             ; descriptor address
            mov     eax, %2                             ; base address

        %if 3 == %0
            mov     [edi + 0], %3                       ; limit
        %endif

            mov     [edi + 2], ax                       ; base([15:0])
            shr     eax, 16
            mov     [edi + 4], al                       ; base([23:16])
            mov     [edi + 7], ah                       ; base([31:24])

            pop     edi
            pop     eax
%endmacro

%macro  set_gate 2-*
            push    eax
            push    edi

            mov     edi, %1                             ; descriptor address
            mov     eax, %2                             ; base address

            mov     [edi + 0], ax                       ; base([15:0])
            shr     eax, 16
            mov     [edi + 6], ax                       ; base([31:16])

            pop     edi
            pop     eax
%endmacro

struc   drive                               ; define parameters by structure when reading sector
            .no         resw    1           ; drive no.
            .cyln       resw    1           ; cylinder
            .head       resw    1           ; head
            .sect       resw    1           ; sector
endstruc

%define     RING_ITEM_SIZE      (1 << 4)
%define     RING_INDEX_MASK     (RING_ITEM_SIZE - 1)

struc   ring_buff
            .rp         resd    1                       ; RP: Reading Position
            .wp         resd    1                       ; WP: Writing Position
            .item       resb    RING_ITEM_SIZE          ; buffer // unit:byte
endstruc

struc   rose
            .x0         resd    1                       ; upper left coordinate : X0
            .y0         resd    1                       ; upper left coordinate : Y0
            .x1         resd    1                       ; lower right coordinate : X1
            .y1         resd    1                       ; lower right coordinate : Y1

            .n          resd    1                       ; variable:n
            .d          resd    1                       ; variable:d

            .color_x    resd    1                       ; display color : X axis
            .color_y    resd    1                       ; display color : Y axis
            .color_z    resd    1                       ; display color : frame
            .color_s    resd    1                       ; display color : char
            .color_f    resd    1                       ; display color : graph display color
            .color_b    resd    1                       ; display color : graph erase color

            .title      resb    16                      ; title
endstruc


