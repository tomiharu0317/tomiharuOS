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

struc   drive                               ; define parameters by structure when reading sector
            .no         resw    1           ; drive no.
            .cyln       resw    1           ; cylinder
            .head       resw    1           ; head
            .sect       resw    1           ; sector
endstruc