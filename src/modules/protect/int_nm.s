get_tss_base:

            ; EBX == TSS selector

            mov     eax, [GDT + ebx + 2]                            ; EAX = TSS[23:0]
            shl     eax, 8
            mov     al,  [GDT + ebx + 7]                            ; AL  = TSS[31:24]
            ror     eax, 8

            ret

save_fpu_context:

            ; EAX == base address of TSS descriptor

            fnsave  [eax + 104]                                     ; // save FPU context
            mov     [eax + 104 + 108], dword 1                      ; saved = 1 // a flag which shows FPU context is saved.

            ret

load_fpu_context:

            cmp     [eax + 104 + 108], dword 0                      ; if (0 == saved)
            jne     .10F
            fninit                                                  ; initialize FPU
            jmp     .10E
.10F:
            frstor  [eax + 104]                                     ; return FPU context
.10E:
            ret

int_nm:

            ; save registers
            pusha
            push    ds
            push    es

            ; set up selector for Kernel
            mov     ax, DS_KERNEL
            mov     ds, ax
            mov     es, ax

            ; clear Task Switch flag
            clts                                                    ; CR0.TS = 0
                                                                    ; // TS bit is gonna be set by CPU
                                                                    ; // when Task Switching happend.

            ; get previous/this time task
            mov     edi, [.last_tss]                                ; TSS of the task that last used FPU
            str     esi                                             ; TSS of the task using FPU this time
            and     esi, ~0x0007                                    ; mask segment selector[2:0] // TI:RPL

            ; compare previous task with the one of this time
            cmp     edi, 0                                          ; if not exist previous task
            je      .10F

            cmp     esi, edi
            je      .12E

            cli                                                     ; disable interrupt

            ; save previous FPU context
            mov     ebx, edi
            call    get_tss_base                                    ; get TSS address
            call    save_fpu_context

            ; return FPU context of this time
            mov     ebx, esi
            call    get_tss_base
            call    load_fpu_context

            sti                                                     ; enable interrupt

.12E:
            jmp     .10E
.10F:

            cli                                                     ; disable interrupt

            ; return FPU context of this time
            mov     ebx, esi
            call    get_tss_base
            call    load_fpu_context

            sti                                                     ; enable interrupt

.10E:
            mov     [.last_tss], esi                                ; save task that used FPU

            ; return registers
            pop     es
            pop     ds
            popa

            iret

ALIGN 4, db 0
.last_tss:  dd  0