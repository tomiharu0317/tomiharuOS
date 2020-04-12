;マクロ

%include    "../include/define.s"
%include    "../include/macro.s"

        ORG     BOOT_LOAD


;エントリポイント

entry:
        jmp     ipl

; BIOS Parameter Block

        times 90 - ($ - $$) db 0x90

; Initial Program Loader

ipl:

        cli                                 ;割り込みの禁止

        mov     ax, 0x0000
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        mov     sp, BOOT_LOAD

        sti                                 ;割り込みの許可

        ;ブートドライブ番号の保存

        mov     [BOOT + drive.no], dl       ;ブートドライブを保存

        ;文字列の表示

        cdecl   puts, .s0                   ;puts(.s0)

        ;残りのセクタをすべて読み込む

        mov     bx, BOOT_SECT - 1           ;BX = 残りのブートセクト数
        mov     cx, BOOT_LOAD + SECT_SIZE   ;CX = 次のロードアドレス

        cdecl   read_sect, BOOT, bx, cx     ;AX = read_sect(BOOT, bx, cx)

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
%include    "../modules/real/read_sect.s"

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
.p4:    db      "XXXX", 0x0A, 0x0D, 0



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
        jmp     $

        ; data
.s0:    db      "4th stage...", 0x0A, 0x0D, 0
.s1:    db      " A20 Gate Enabled.", 0x0A, 0x0D, 0
.s2:    db      "Keyboard LED Test...", 0
.s3:    db      "(done)", 0x0A, 0x0D, 0
.e0:    db      "["
.e1:    db      "ZZ]", 0

.key:   dw      0

        ; Padding

        times   BOOT_SIZE - ($ - $$)       db  0        ;8Kバイト