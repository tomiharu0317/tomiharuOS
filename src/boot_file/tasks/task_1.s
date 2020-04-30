task_1:

            ; display string
            cdecl   draw_str, 63, 0, 0x07, .s0

;-------------------------------------------------------------
; non-preemptive multitask
;-------------------------------------------------------------

; .10L:
;             ; display time
;             mov     eax, [RTC_TIME]                         ; get time
;             cdecl   draw_time, 72, 0, 0x0700, eax

;             ; call Task
;             jmp    SS_TASK_0:0                             ; jump to Task0(kernel)

;             jmp     .10L

;-------------------------------------------------------------

;-------------------------------------------------------------
; preemptive multitask
;-------------------------------------------------------------

.10L:
            ; display time
            mov     eax, [RTC_TIME]                         ; get time
            cdecl   draw_time, 72, 0, 0x0700, eax
            

            jmp     .10L

;-------------------------------------------------------------

            ; data
.s0:        db  "Task_1", 0