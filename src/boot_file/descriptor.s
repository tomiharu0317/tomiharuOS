GDT:            dq  0x0000000000000000
.cs_kernel:     dq  0x00CF9A000000FFFF                                      ; CODE 4G
.ds_kernel:     dq  0x00CF92000000FFFF                                      ; DATA 4G
.ldt            dq  0x0000820000000000                                      ; LDT descriptor


LDT:            dq  0x0000000000000000                                      ; NULL
.cs_task_0:     dq  0x00CF9A000000FFFF                                      ; CODE 4G
.ds_task_0:     dq  0x00CF92000000FFFF                                      ; DATA 4G
.cs_task_1:     dq  0x00CF9A000000FFFF                                      ; CODE 4G
.ds_task_1:     dq  0x00CF92000000FFFF                                      ; DATA 4G
.end:

CS_TASK_0       equ (.cs_task_0 - LDT) | 4                                  ; cs selector for task0 // set bit 2(TI)
DS_TASK_0       equ (.ds_task_0 - LDT) | 4                                  ; ds selector for task0
CS_TASK_1       equ (.cs_task_1 - LDT) | 4                                  ; cs selector for task1
DS_TASK_1       equ (.ds_task_1 - LDT) | 4                                  ; ds selector for task1

LDT_LIMIT       equ .end        - LDT - 1