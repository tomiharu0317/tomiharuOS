power_off:

            ; save registers
            pusha

            ; display 'Power off...'
            cdecl   draw_str, 25, 14, 0x020F, .s0

            ; disable paging
            mov     eax, cr0
            and     eax, 0x7FFF_FFFF                            ; CR0 &= ~PG
            mov     cr0, eax
            jmp     $ + 2                                       ; FLUSH()

            ; confirm ACPI data
            mov     eax, [0x7C00 + 512 + 4]                     ; EAX = ACPI address
            mov     ebx, [0x7C00 + 512 + 8]                     ; EBX = length
            cmp     eax, 0
            je      .10E

            ; search RSDT table
            cdecl   acpi_find, eax, ebx, 'RSDT'                 ; EAX = acpi_find('RSDT')
            cmp     eax, 0
            je      .10E

            ; search FACP table
            cdecl   find_rsdt_entry, eax, 'FACP'                ; EAX = find_rsdt_entry('FACP')
            cmp     eax, 0
            je      .10E

            mov     ebx, [eax + 40]                             ; // get DSDT address
            cmp     ebx, 0
            je      .10E

            ; save ACPI register
            mov     ecx, [eax + 64]                             ; get ACPI register
            mov     [PM1a_CNT_BLK], ecx                         ; PM1a_CNT_BLK = FACP.PM1a_CNT_BLK

            mov     ecx, [eax + 68]
            mov     [PM1b_CNT_BLK], ecx

            ; search S5 Name Space
            mov     ecx, [ebx + 4]                              ; ECX = DSDT.Length // data length
            sub     ecx, 36                                     ; ECX -= 36         // subtract table header
            add     ebx, 36                                     ;                   // add      table header
            cdecl   acpi_find, ebx, ecx, '_S5_'                 ; EAX = acpi_find('_S5_')
            cmp     eax, 0
            je      .10E

            ; get package data
            add     eax, 4                                      ; EAX = top element
            cdecl   acpi_package_value, eax                     ; EAX = package data
            mov     [S5_PACKAGE], eax

.10E:

            ; enable paging
            mov     eax, cr0
            or      eax, (1 << 31)                              ; set PG bit
            mov     cr0, eax
            jmp     $ + 2                                       ; FLUSH()

            ; get ACPI register
            mov     edx, [PM1a_CNT_BLK]                         ; EDX = FACP.PM1a_CNT_BLK
            cmp     edx, 0
            je      .20E

            ; display countdown
            cdecl   draw_str, 38, 14, 0x020F, .s3
            cdecl   wait_tick, 100
            cdecl   draw_str, 38, 14, 0x020F, .s2
            cdecl   wait_tick, 100
            cdecl   draw_str, 38, 14, 0x020F, .s1
            cdecl   wait_tick, 100

            ; set PM1a_CNT_BLK
            movzx   ax, [S5_PACKAGE.0]                          ; // PM1a_CNT_BLK
            shl     ax, 10                                      ; AX  = SLP_TYPx
            or      ax, 1 << 13                                 ; AX |= SLP_EN
            out     dx, ax                                      ; out(PM1a_CNT_BLK, AX)

            ; confirm PM1b_CNT_BLK
            mov     edx, [PM1b_CNT_BLK]
            cmp     edx, 0
            je      .20E

            ; set PM1b_CNT_BLK(lower 1 byte)
            movzx   ax, [S5_PACKAGE.1]
            shl     ax, 10
            or      ax, 1 << 13
            out     dx, ax

.20E:

            ; wait for power off
            cdecl   wait_tick, 100

            ; message that power off process failed
            cdecl   draw_str, 38, 14, 0x020F, .s4

            ; return registers
            popa

            ret

ALIGN   4,  db 0
PM1a_CNT_BLK:   dd 0
PM1b_CNT_BLK:   dd 0
S5_PACKAGE:
.0:             db 0
.1:             db 0
.2:             db 0
.3:             db 0

.s0:            db  " Power off...    ", 0
.s1:            db  " 1", 0
.s2:            db  " 2", 0
.s3:            db  " 3", 0
.s4:            db  "NG", 0

