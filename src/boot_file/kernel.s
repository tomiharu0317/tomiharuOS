;macro

%include    "../include/define.s"
%include    "../include/macro.s"

                ORG     KERNEL_LOAD                             ; load address of kernel

[BITS 32]                                                       ; BIT 32 directive
; entry point

kernel:

                ; Get Font address
                mov     esi, BOOT_LOAD + SECT_SIZE              ; ESI = 0x7x00 + 512
                movzx   eax, word [esi + 0]                     ; segment
                movzx   ebx, word [esi + 2]                     ; offset
                shl     eax, 4
                add     eax, ebx
                mov     [FONT_ADR], eax                         ; FONT_ADR[0] = EAX

                ; set up TSS descriptor
                set_desc    GDT.tss_0, TSS_0
                set_desc    GDT.tss_1, TSS_1

                ; set up LDT
                set_desc    GDT.ldt, LDT, word LDT_LIMIT        ; descriptor address/base address/limit

                ; load GDTR (resetting)
                lgdt        [GDTR]

                ; set up stack
                mov     esp, SP_TASK_0                          ; set up stack for Task0

                ; recognize Kernel as Task0
                mov     ax, SS_TASK_0
                ltr     ax                                      ; initialize TR

                ; initialize interrupt vector
                cdecl   init_int
                cdecl   init_pic

                set_vect    0x00, int_zero_div                  ; define interrupt process: Zero div
                set_vect    0x20, int_timer                     ; define interrupt process: Timer
                set_vect    0x21, int_keyboard                  ; define interrupt process: KBC
                set_vect    0x28, int_rtc                       ; define interrupt process: RTC

                ; permit interrupt by device
                cdecl   rtc_int_en, 0x10                        ; Updata-Ended Interrupt Enable

                ; set up IMR(Interrupt Mask Register)
                outp    0x21, 0b1111_1000                       ; interrupt enable: slave PIC/KBC/Timer     // master
                outp    0xA1, 0b1111_1110                       ; interrupt enable: RTC                     // slave

                ; CPU interrupt enable
                sti

                ; display font and color_bar
                cdecl   draw_font, 63, 13
                cdecl   draw_color_bar, 63, 4

                ; display string
                cdecl   draw_str, 25, 14, 0x010F, .s0

;---------------------------------------------------------------------------
; multitask
;---------------------------------------------------------------------------


;                 ; call Task
;                 ; call    SS_TASK_1:0

; .10L:

;                 ; display time
;                 mov     eax, [RTC_TIME]
;                 cdecl   draw_time, 72, 0, 0x0700, eax


;                 ; get key code
;                 cdecl   ring_rd, _KEY_BUFF, .int_key
;                 cmp     eax, 0
;                 je      .10E

;                 ; display key code
;                 cdecl   draw_key, 2, 29, _KEY_BUFF
; .10E:

;                 ; draw rotation bar
;                 cdecl   draw_rotation_bar

;                 jmp     .10L

;----------------------------------------------------------------------------


;----------------------------------------------------------------------------
; non-preemptive multitask
;----------------------------------------------------------------------------

.10L:

                ; call task
                jmp     SS_TASK_1:0                             ; jump to Task1

                ; draw rotation bar
                cdecl   draw_rotation_bar

                ; get key code
                cdecl   ring_rd, _KEY_BUFF, .int_key
                cmp     eax, 0
                je      .10E

                ; display key code
                cdecl   draw_key, 2, 29, _KEY_BUFF
.10E:

                jmp     .10L

;-----------------------------------------------------------------------------

;data
.s0:    db  " Hello, kernel! ", 0

ALIGN 4, db 0
.int_key:   dd 0

ALIGN 4, db 0
FONT_ADR:   dd 0
RTC_TIME:   dd 0


; TASKS
%include    "descriptor.s"
%include    "modules/int_timer.s"
%include    "tasks/task_1.s"

; MODULES
%include    "../modules/protect/vga.s"
%include    "../modules/protect/draw_char.s"
%include    "../modules/protect/draw_font.s"
%include    "../modules/protect/draw_str.s"
%include    "../modules/protect/draw_color_bar.s"
%include    "../modules/protect/draw_pixel.s"
%include    "../modules/protect/draw_line.s"
%include    "../modules/protect/draw_rect.s"
%include    "../modules/protect/int_to_str.s"
%include    "../modules/protect/rtc.s"
%include    "../modules/protect/draw_time.s"
%include    "../modules/protect/interrupt.s"
%include    "../modules/protect/pic.s"
%include    "../modules/protect/int_rtc.s"
%include    "../modules/protect/ring_buff.s"
%include    "../modules/protect/int_keyboard.s"
%include    "../modules/protect/timer.s"
%include    "../modules/protect/draw_rotation_bar.s"


; PADDING

            times   KERNEL_SIZE - ($ - $$)      db 0x00     ; size of kernel // 8K byte