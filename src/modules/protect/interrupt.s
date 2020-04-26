; Initialize vector of IDTR

ALIGN 4
IDTR:       dw      8 * 256 - 1                                     ; limit of IDT
            dd      VECT_BASE                                       ; base address of IDT

; Initialize IDT

init_int:

            ; save registers
            push    eax
            push    ebx
            push    ecx
            push    edi

            ; define Interrupt Gate Descriptor and apply default process to them

            lea     eax, [int_default]                              ; EAX = the address of interrupt process
            mov     ebx, 0x0008_8E00                                ; EBX = segment selector & P,DPL,DT,TYPE
            xchg    ax, bx                                          ; exchange lower word

            mov     ecx, 256                                        ; num of Interrupt Gate Descriptor
            mov     edi, VECT_BASE                                  ; base address of Interrupt Descriptor Table

.10L:
            mov     [edi + 0], ebx                                  ; interrupt descriptor(lower)
            mov     [edi + 4], eax                                  ; interrupt descriptor(upper)
            add     edi, 8                                          ; EDI += 8 byte
            loop    .10L

            ; set up Interrupt Descriptor
            lidt    [IDTR]

            ; return registers
            pop     edi
            pop     ecx
            pop     ebx
            pop     eax

            ret

int_stop:

            sti                                                     ; interrupt enable

            ; display the string indicated in EAX
            cdecl   draw_str, 25, 15, 0x060F, eax

            ; convert stack data into string
            mov     eax, [esp + 0]                                  ; EIP
            cdecl   int_to_str, eax, .p1, 8, 16, 0b0100

            mov     eax, [esp + 4]                                  ; CS
            cdecl   int_to_str, eax, .p2, 8, 16, 0b0100

            mov     eax, [esp + 8]                                  ; EFLAGS
            cdecl   int_to_str, eax, .p3, 8, 16, 0b0100

            mov     eax, [esp + 12]
            cdecl   int_to_str, eax, .p4, 8, 16, 0b0100

            ; display string
            cdecl   draw_str, 25, 16, 0x0F04, .s1
            cdecl   draw_str, 25, 17, 0x0F04, .s2
            cdecl   draw_str, 25, 18, 0x0F04, .s3
            cdecl   draw_str, 25, 19, 0x0F04, .s4

            ; infinite loop
            jmp     $

.s1         db  "ESP+ 0:"
.p1         db  "________ ", 0
.s2         db  "   + 4:"
.p2         db  "________ ", 0
.s3         db  "   + 8:"
.p3         db  "________ ", 0
.s4         db  "   +12:"
.p4         db  "________ ", 0

int_default:
            pushf                                                   ; EFLAGS
            push    cs                                              ; CS
            push    int_stop                                        ; the process of displaying stack

            mov     eax, .s0                                        ; interrupt type
            iret

.s0         db  " <    STOP    > ", 0

int_zero_div:
            pushf                                                   ; EFLAGS
            push    cs                                              ; CS
            push    int_stop                                        ; the process of displaying stack

            mov     eax, .s0                                        ; interrupt type
            iret

.s0         db  " <  ZERO DIV  > ", 0


