%define     USE_SYSTEM_CALL
%define     USE_TEST_AND_SET

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
                set_desc    GDT.tss_2, TSS_2
                set_desc    GDT.tss_3, TSS_3
                set_desc    GDT.tss_4, TSS_4
                set_desc    GDT.tss_5, TSS_5
                set_desc    GDT.tss_6, TSS_6


                ; set up Call Gate
                set_gate    GDT.call_gate, call_gate

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
                cdecl   init_int                                ; initialize Interrupt Descriptor Table
                cdecl   init_pic                                ; initialize Programmable Interrupt Controler
                cdecl   init_page                               ; initialize Paging

                set_vect    0x00, int_zero_div                  ; define interrupt process: Zero div
                set_vect    0x07, int_nm                        ; define interrupt process: device unavailable exception
                set_vect    0x0E, int_pf                        ; define interrupt process; page fault
                set_vect    0x20, int_timer                     ; define interrupt process: Timer
                set_vect    0x21, int_keyboard                  ; define interrupt process: KBC
                set_vect    0x28, int_rtc                       ; define interrupt process: RTC
                set_vect    0x81, trap_gate_81, word 0xEF00     ; define trap gate        : display a char
                set_vect    0x82, trap_gate_82, word 0xEF00     ; define trap gate        : draw pixel

                ; permit interrupt by device
                cdecl   rtc_int_en, 0x10                        ; Updata-Ended Interrupt Enable
                cdecl   int_en_timer0

                ; set up IMR(Interrupt Mask Register)
                outp    0x21, 0b_1111_1000                       ; interrupt enable: slave PIC/KBC/Timer     // master
                outp    0xA1, 0b_1111_1110                       ; interrupt enable: RTC                     // slave

                ; register page table
                mov     eax, CR3_BASE
                mov     cr3, eax

                ; enable paging
                mov     eax, cr0
                or      eax, (1 << 31)                          ; CR0 |= PG
                mov     cr0, eax
                jmp     $ + 2                                   ; FLUSH()

                ; CPU interrupt enable
                sti

                ; display font and color_bar
                cdecl   draw_font, 63, 13
                cdecl   draw_color_bar, 63, 4

                ; display string
                cdecl   draw_str, 25, 14, 0x010F, .s0

;---------------------------------------------------------------------------
; default multitask
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

; .10L:

;                 ; call task
;                 jmp     SS_TASK_1:0                             ; jump to Task1

;                 ; draw rotation bar
;                 cdecl   draw_rotation_bar

;                 ; get key code
;                 cdecl   ring_rd, _KEY_BUFF, .int_key
;                 cmp     eax, 0
;                 je      .10E

;                 ; display key code
;                 cdecl   draw_key, 2, 29, _KEY_BUFF
; .10E:

;                 jmp     .10L

;-----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; preemptive multitask
;----------------------------------------------------------------------------

.10L:

                ; draw rotation bar
                cdecl   draw_rotation_bar

                ; get key code
                cdecl   ring_rd, _KEY_BUFF, .int_key
                cmp     eax, 0
                je      .10E

                ; display key code
                cdecl   draw_key, 2, 29, _KEY_BUFF

                ; the process when the exact key is pressed
                mov     al, [.int_key]
                cmp     al, 0x02                            ; key[0x02] == '1'
                jne     .12E

                ; read file
                call    [BOOT_LOAD + BOOT_SIZE - 16]        ; read mode transition file

                ; display contents of file
                mov     esi, 0x7800                         ; ESI = read dest address
                mov     [esi + 32], byte 0
                cdecl   draw_str, 0, 0, 0x0F04, esi
.12E:

                ; CTRL + ALt + END => '2'(temp)
                mov     al, [.int_key]                      ; // key code
                ; cdecl   ctrl_alt_end, eax
                ; cmp     eax, 0
                cmp     al, 0x03
                jne      .14E                                ; if (eax == 0) => failure

                mov     eax, 0                              ; do POWER_OFF process only once
                bts     [.once], eax                        ; if (0 == bts(.once))
                jc      .14E                                ; {
                cdecl   power_off                           ;   power_off();
                                                            ; }
.14E:

.10E:

                jmp     .10L

;-----------------------------------------------------------------------------

;data
.s0:    db  " Hello, kernel! ", 0

ALIGN 4, db 0
.int_key:   dd 0
.once:      dd 0

ALIGN 4, db 0
FONT_ADR:   dd 0
RTC_TIME:   dd 0


; TASKS
%include    "descriptor.s"
%include    "modules/paging.s"
%include    "modules/int_timer.s"
%include    "modules/int_pf.s"
%include    "tasks/task_1.s"
%include    "tasks/task_2.s"
%include    "tasks/task_3.s"


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
%include    "../modules/protect/int_keyboard.s"
%include    "../modules/protect/ring_buff.s"
%include    "../modules/protect/timer.s"
%include    "../modules/protect/draw_rotation_bar.s"
%include    "../modules/protect/call_gate.s"
%include    "../modules/protect/trap_gate.s"
%include    "../modules/protect/test_and_set.s"
%include    "../modules/protect/int_nm.s"
%include    "../modules/protect/wait_tick.s"
%include    "../modules/protect/memcpy.s"
%include    "../modules/protect/ctrl_alt_end.s"
%include    "../modules/protect/power_off.s"
%include    "../modules/protect/acpi_find.s"
%include    "../modules/protect/find_rsdt_entry.s"
%include    "../modules/protect/acpi_package_value.s"

;-------------------------------------------------------------------------------------------------
; PADDING
;-------------------------------------------------------------------------------------------------
            times   KERNEL_SIZE - ($ - $$)      db 0x00     ; size of kernel // 8K byte

;-------------------------------------------------------------------------------------------------
; FAT
;-------------------------------------------------------------------------------------------------

%include    "fat.s"