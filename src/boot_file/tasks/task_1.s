task_1:

            ; display string
            cdecl   draw_str, 63, 0, 0x07, .s0

            ; end of task
            iret

            ; data
.s0:        db  "Task_1", 0