; macro

%include    "../include/define.s"
%include    "../include/macro.s"

        ORG     BOOT_LOAD


; entry point

entry:

; BIOS Parameter Block


        jmp     ipl                             ; 0x00( 3) jmp instruction to boot code
        times 3 - ($ - $$) db 0x90
        db      'OEM-NAME'                      ; 0x03( 8) OEM name

        dw      512                             ; 0x0B( 2) num of byte of sector
        db      1                               ; 0x0D( 1) num of sector of cluster
        dw      32                              ; 0x0E( 2) num of reserved sector
        db      2                               ; 0x10( 1) num of FAT
        dw      512                             ; 0x11( 2) num of root entry
        dw      0xFFF0                          ; 0x13( 2) total sector:16
        db      0xF8                            ; 0x15( 1) media type
        dw      256                             ; 0x16( 2) num of sector of FAT
        dw      0x10                            ; 0x18( 2) num of sector of track
        dw      2                               ; 0x1A( 2) num of head
        dd      0                               ; 0x1C( 4) num of hidden sector

        dd      0                               ; 0x20( 4) total sector:32
        db      0x80                            ; 0x24( 1) drive no.
        db      0                               ; 0x25( 1) (reserved)
        db      0x29                            ; 0x26( 1) boot flag
        dd      0xbeef                          ; 0x27( 4) serial number
        db      'BOOTABLE   '                   ; 0x2B(11) volume label
        db      'FAT16   '                      ; 0x36( 8) FAT type

; Initial Program Loader

ipl:

        cli                                     ; disable interrupt

        mov     ax, 0x0000
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        mov     sp, BOOT_LOAD

        sti                                     ; enable interrupt

        ; save boot drive no.

        mov     [BOOT + drive.no], dl           ; save boot drive

        ; put char

        cdecl   puts, .s0                       ;puts(.s0)

        ;残りのセクタをすべて読み込む

        mov     bx, BOOT_SECT - 1           ;BX = 残りのブートセクト数
        mov     cx, BOOT_LOAD + SECT_SIZE   ;CX = 次のロードアドレス

        cdecl   read_chs, BOOT, bx, cx     ;AX = read_chs(BOOT, bx, cx)

        cmp     ax, bx
.10Q:   jz      .10E                        ;if (ax != 残りのセクタ数)

.10T:   cdecl   puts, .e0                   ;{  puts(.e0);
        call    reboot                      ;   reboot(); //再起動

.10E:                                       ;}

        ;次のステージへ移行

        jmp     stage_2                     ;ブート処理の第2ステージへ

        ;データ

.s0     db      "booting...", 0x0A, 0x0D, 0
.e0     db      "Error: sector read", 0

;ブートドライブに関する情報

ALIGN 2, db 0
BOOT:
        istruc  drive
            at  drive.no,       dw 0        ;ドライブ番号
            at  drive.cyln,     dw 0        ;シリンダ
            at  drive.head,     dw 0        ;ヘッド
            at  drive.sect,     dw 2        ;セクタ
        iend

;モジュール(512バイト以降に配置)

%include    "../modules/real/puts.s"
%include    "../modules/real/reboot.s"
%include    "../modules/real/read_chs.s"

;ブートフラグ(512biteの終了)

        times   510 - ($ - $$) db 0x00
        db 0x55, 0xAA

;リアルモード時に取得した情報
FONT:                                           ;フォント
.seg:   dw 0
.off:   dw 0
ACPI_DATA:
.adr:   dd 0                                    ; ACPI base address
.len:   dd 0                                    ;      data length

%include    "../modules/real/int_to_str.s"
%include    "../modules/real/get_drive_params.s"
%include    "../modules/real/get_font_adr.s"
%include    "../modules/real/get_mem_info.s"
%include    "../modules/real/kbc.s"
%include    "../modules/real/lba_chs.s"
%include    "../modules/real/read_lba.s"
%include    "../modules/real/memcpy.s"
%include    "../modules/real/memcmp.s"




;ブート処理の第2ステージ

stage_2:

        ;文字列を表示
        cdecl   puts, .s0

        ;ドライブ情報を取得
        cdecl   get_drive_params, BOOT          ;get_drive_params(DX, BOOT.CYLN);
        cmp     ax, 0                           ;if (0 == AX){
.10Q:   jne     .10E                            ;       puts(.e0);
.10T:   cdecl   puts, .e0                       ;       reboot();
        call    reboot                          ; }
.10E:

        ;ドライブ情報を表示
        mov     ax, [BOOT + drive.no]           ;AX = ブートドライブ
        cdecl   int_to_str, ax, .p1, 2, 16, 0b0100
        mov     ax, [BOOT + drive.cyln]           ;
        cdecl   int_to_str, ax, .p2, 4, 16, 0b0100
        mov     ax, [BOOT + drive.head]           ;AX = ヘッド数
        cdecl   int_to_str, ax, .p3, 2, 16, 0b0100
        mov     ax, [BOOT + drive.sect]           ;AX = トラック当たりのセクタ数
        cdecl   int_to_str, ax, .p4, 2, 16, 0b0100
        cdecl   puts, .s1


        ;処理の終了

        jmp     stage_3

        ;データ

.s0     db      "2nd stage...", 0x0A, 0x0D, 0

.s1     db      " Drive:0x"
.p1     db      "  , C:0x"
.p2     db      "    , H:0x"
.p3     db      "  , S:0x"
.p4     db      "  ", 0x0A, 0x0D, 0

.e0     db      "Can't get drive Parameter.", 0

stage_3:

        ;文字列を表示
        cdecl   puts, .s0

        ;プロテクトモードで使用するフォントは
        ;BIOSに内蔵されたものを流用する

        cdecl   get_font_adr, FONT

        ;フォントアドレスの表示
        cdecl   int_to_str, word [FONT.seg], .p1, 4, 16, 0b0100
        cdecl   int_to_str, word [FONT.off], .p2, 4, 16, 0b0100
        cdecl   puts, .s1

        ;メモリ情報の取得と表示
        cdecl   get_mem_info              ;get_mem_info()

        mov     eax, [ACPI_DATA.adr]
        cmp     eax, 0
        je      .10E

        cdecl   int_to_str, ax, .p4, 4, 16, 0b0100      ;下位アドレス
        shr     eax, 16                                 ;EAX >>= 16
        cdecl   int_to_str, ax, .p3, 4, 16, 0b0100      ;上位アドレス

        cdecl   puts, .s2
.10E:

        ;処理の終了
        jmp     stage_4

        ;データ
.s0:    db      "3rd stage...", 0x0A, 0x0D, 0

.s1:    db      " Font Address="
.p1:    db      "ZZZZ:"
.p2:    db      "ZZZZ", 0x0A, 0x0D, 0
        db      0x0A, 0x0D, 0

.s2:    db      " ACPI data ="
.p3:    db      "ZZZZ"
.p4:    db      "ZZZZ", 0x0A, 0x0D, 0



stage_4:

        ; put char
        cdecl   puts, .s0

        ; enable A20 gate

        cli                                             ; disable interrupt

        cdecl   KBC_Cmd_Write, 0xAD                     ; disable Keyboard

        cdecl   KBC_Cmd_Write, 0xD0                     ; cmd that read output port
        cdecl   KBC_Data_Read, .key                     ; output port data

        mov     bl, [.key]
        or      bl, 0x02                                ; Enable A20 gate

        cdecl   KBC_Cmd_Write, 0xD1                     ; cmd that write output port
        cdecl   KBC_Data_Write, bx                      ; output port data

        cdecl   KBC_Cmd_Write, 0xAE                     ; Enable Keyboard

        sti

        ; put char
        cdecl   puts, .s1

        ; Test Keyboard LED
        cdecl   puts, .s2

        mov     bx, 0                                   ; BX = initial value of LED

.10L:
        mov     ah, 0x00
        int     0x16                                    ; AL = BIOS(0x16, 0x00)  //getting key code

        cmp     al, '1'                                 ; if (AL < '1') break;
        jb      .10E

        cmp     al, '3'                                 ; if (AL > '3') break;
        ja      .10E

        mov     cl, al
        dec     cl
        and     cl, 0x03                                ; CL = times of bit shift
        mov     ax, 0x0001                              ; AX = for bit conversion
        shl     ax, cl                                  ; AX <<= CL
        xor     bx, ax                                  ; BX ^= AX      // bit inversion

        ; Send LED command

        cli                                             ; disable interrupt
        cdecl   KBC_Cmd_Write, 0xAD                     ; disable keyboard

        cdecl   KBC_Data_Write, 0xED                    ; AX = KBC_Data_Write(0xED) // LED command
        cdecl   KBC_Data_Read, .key                     ; AX = KBC_Data_Read(&key) // ACK(Acknowledge)

        cmp     [.key], byte 0xFA                       ; whether it's equipped with LED
        jne     .11F

        cdecl   KBC_Data_Write, bx                      ; AX = KBC_Data_Write(BX) // LED data

        jmp     .11E

.11F:
        cdecl   int_to_str, word [.key], .e1, 2, 16, 0b0100
        cdecl   puts, .e0                               ; put received code

.11E:

        cdecl   KBC_Cmd_Write, 0xAE                     ; Enable Keyboard

        sti                                             ; Enable interrupt

        jmp     .10L

.10E:

        ; put char
        cdecl   puts, .s3

        ; End of Process
        jmp     stage_5

        ; data
.s0:    db      "4th stage...", 0x0A, 0x0D, 0
.s1:    db      " A20 Gate Enabled.", 0x0A, 0x0D, 0
.s2:    db      "Keyboard LED Test...", 0
.s3:    db      "(done)", 0x0A, 0x0D, 0
.e0:    db      "["
.e1:    db      "ZZ]", 0

.key:   dw      0

stage_5:

        ; put char
        cdecl   puts, .s0

        ; load Kernel
        cdecl   read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END

        cmp     ax, KERNEL_SECT
.10Q:   jz      .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:

        ; End of Process
        jmp     stage_6

.s0:    db      "5th stage...", 0x0A, 0x0D, 0
.e0:    db      "Failure to load kernel...", 0x0A, 0x0D, 0

stage_6:

        ; put char
        cdecl   puts, .s0

        ; wait until user approves

.10L:

        mov     ah, 0x00
        int     0x16
        cmp     al, ' '
        jne     .10L

        ; set video mode
        mov     ax, 0x0012
        int     0x10

        ; End of Process
        jmp     stage_7

.s0:    db      "6th stage...", 0x0A, 0x0D, 0x0A, 0x0D
        db      " [Push SPACE key to protect mode...]", 0x0A, 0x0D, 0


; read file func-------------------------------------
read_file:

        cdecl   memcpy, 0x7800, .s0, .s1 - .s0

        ret

.s0:    db      'File not found.', 0
.s1:
;-----------------------------------------------------

;
; GLOBAL DESCRIPTOR TABLE
;
ALIGN 4, db 0
GDT:    dq      0x00_0000_000000_0000                   ; NULL Descriptor
.cs:    dq      0x00_CF9A_000000_FFFF                   ; CODE 4G
.ds:    dq      0x00_CF92_000000_FFFF                   ; DATA 4G
.gdt_end:

; SEGMENT SELECTOR

SEL_CODE        equ GDT.cs - GDT                        ; selector for code
SEL_DATA        equ GDT.ds - GDT                        ; selector for data

; GDT

GDTR:   dw      GDT.gdt_end - GDT - 1                   ; limit of descriptor table
        dd      GDT                                     ; base address of descriptor table

; IDT

IDTR:   dw      0                                       ; limit of interrupt descriptor table
        dd      0                                       ; base address of interrupt descriptor table


stage_7:
        cli                                             ; disable interrupt

        ; load Descriptor table

        lgdt    [GDTR]                                  ; load Global Descriptor Table
        lidt    [IDTR]                                  ; load Interrupt Descriptor Table

        ; migrate to protect mode
        mov     eax, cr0                                ; set PE(Protect Enable) bit
        or      ax, 1                                   ; CRO |= 1
        mov     cr0, eax

        jmp     $ + 2                                   ; clear look ahead of cpu instruction

[BITS 32]
        db      0x66                                    ; Operand Size Override prefix
        jmp     SEL_CODE:CODE_32                        ; FAR jump // segment:offset

CODE_32:
        mov     ax, SEL_DATA
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        mov     ss, ax

        ; copy kernel program

        mov     ecx, (KERNEL_SIZE) / 4                  ; ECX = copy by 4 byte unit
        mov     esi, BOOT_END                            ; ESI = 0x0000_9c00 // kernel part
        mov     edi, KERNEL_LOAD                         ; EDI = 0x0010_1000
        cld                                             ; DF => +
        rep     movsd                                   ; while(--ECX) *EDI++ = *ESI++;

        ; jump to Kernel Process
        jmp     KERNEL_LOAD

;-------------------------------------------------------------------------------------------
; migrating to real mode program
;-------------------------------------------------------------------------------------------
TO_REAL_MODE:

        ; construct stack frame
                                                        ;    +20 | *p(address to strings)
                                                        ;    +16 | color
        push    ebp                                     ;    +12 | row
        mov     ebp, esp                                ;    + 8 | column

        ; save registers
        pusha

        cli                                             ; disable interrupt

        ; save current settings
        mov     eax, cr0
        mov     [.cr0_saved], eax                       ; save cr0 register
        mov     [.esp_saved], esp                       ; save esp register
        sidt    [.idtr_save]                            ; save IDTR
        lidt    [.idtr_real]                            ; set interrupt during real mode

        ; migrate to 16bit protect mode
        jmp     0x0018:.bit16                           ; CS = 0x18

[BITS 16]
.bit16:
        mov     ax, 0x0020                              ; DS = 0x20
        mov     ds, ax
        mov     es, ax
        mov     ss, ax

        ; migrate to real mode(disable paging)
        mov     eax, cr0
        and     eax, 0x7FFF_FFFE                       ; clear PG/PE bits
        mov     cr0, eax
        jmp     $ + 2                                   ; Flush()

        ; set up segment(real mode)
        jmp     0:.real                                 ; CS = 0x0000
.real:
        mov     ax, 0x0000
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        mov     sp, 0x7C00

        ; read file
        cdecl   read_file

        ; migrate to 16 bit protect mode
        mov     eax, cr0
        or      eax, 1                                  ; set PE bit
        mov     cr0, eax
        jmp     $ + 2                                   ; Flush()

        ; migrate to 32 bit protect mode
        DB      0x66                                    ; 32 bit override
[BITS 32]
        jmp     0x0008:.bit32                           ; CS = 32 bit CS
.bit32:
        mov     ax, 0x0010                              ; DS = 32 bit DS
        mov     ds, ax
        mov     es, ax
        mov     ss, ax

        ; reset register saved before and complete migration
        mov     esp, [.esp_saved]                       ; return ESP register
        mov     eax, [.cr0_saved]                       ; return CR0 register
        mov     cr0, eax
        lidt    [.idtr_save]                            ; return IDTR

        sti                                             ; enable interrupt

        ; return registers
        popa

        ; destruct stack frame
        mov     esp, ebp
        pop     ebp

        ret

.idtr_real:
        dw      0x3FF                                   ; 8 * 256 - 1   : idt_limit
        dd      0                                       ; VECT_BASE     : idt location

.idtr_save:
        dw      0                                       ; limit
        dd      0                                       ; base

.cr0_saved:
        dd      0

.esp_saved:
        dd      0

;---------------------------------------------------------------------------------
; Padding
;---------------------------------------------------------------------------------
        times   BOOT_SIZE - ($ - $$) - 16  db  0

        dd      TO_REAL_MODE                            ; read mode migration progaram

;---------------------------------------------------------------------------------
; Padding
;---------------------------------------------------------------------------------

        times   BOOT_SIZE - ($ - $$)       db  0        ;8K byte