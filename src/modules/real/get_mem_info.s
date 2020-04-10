get_mem_info:

            ;レジスタの保存
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    si
            push    di
            push    bp

            ;文字列を表示
            cdecl   puts, .s0

            mov     bp, 0                           ; lines = 0; //行数
            mov     ebx, 0                          ; index = 0; //初期化
.10L:                                               ; do
                                                    ; {
            mov     eax, 0x0000E820                 ;   EAX  = 0xE820;
            mov     ecx, E820_RECORD_SIZE           ;   ECX  = 要求バイト数;
            mov     edx, 'PAMS'                     ;   EDX  = 'SMAP' //固定値
            mov     di, .b0                         ;   ES:DI= 書き込み先
            int     0x15                            ;   BIOS(0x15, 0xE820);
                                                    ; }

            cmp     eax, 'PAMS'                     ; コマンド未対応なら終了
            je      .12E
            jmp     .10E

.12E:


            jnc     .14E                            ; CF 0:成功 1:失敗
            jmp     .10E
.14E:

            cdecl   put_mem_info, di                ; 1レコード分のメモリ情報を表示

            ;ACPI data のアドレスを取得
            mov     eax, [di + 16]                  ; EAX = データタイプ
            cmp     eax, 3                          ; 3:AddressRangeACPI
            jne     .15E

            mov     eax, [di + 0]                   ; EAX = BASE address
            mov     [ACPI_DATA.adr], eax

            mov     eax, [di + 8]
            mov     [ACPI_DATA.len], eax
.15E:

            cmp     ebx, 0
            jz      .16E

            inc     bp                              ; lines++
            and     bp, 0x07                        ; lines &= 0x07; //メモリ情報を8行表示するたびに
            jnz     .16E                            ;                //ユーザーからのキー入力があるまで
                                                    ;                //処理を中断
            cdecl   puts, .s2                       ; 中断メッセージ
            mov     ah, 0x10                        ; キー入力待ち
            int     0x16

            cdecl   puts, .s3
.16E:

            cmp     ebx, 0
            jne     .10L
.10E:

            cdecl   puts, .s1

            ;レジスタの復帰
            pop     bp
            pop     di
            pop     si
            pop     edx
            pop     ecx
            pop     ebx
            pop     eax

            ret

.s0:	    db " E820 Memory Map:", 0x0A, 0x0D
		    db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	    db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:	    db " <more...>", 0
.s3:	    db 0x0D, "          ", 0x0D, 0

ALIGN 4, db 0
.b0:    times E820_RECORD_SIZE db 0

put_mem_info:

            ;スタックフレームの構築
            push    bp                              ;BP +4 | メモリ情報が格納されたバッファアドレス
            mov     bp, sp

            ;レジスタの保存
            push    bx
            push    si

            ;引数の取得
            mov     si, [bp + 4]

            ; Base(64bit)
            cdecl int_to_str, word [si + 6], .p2 + 0, 4, 16, 0b0100
            cdecl int_to_str, word [si + 4], .p2 + 4, 4, 16, 0b0100
            cdecl int_to_str, word [si + 2], .p3 + 0, 4, 16, 0b0100
            cdecl int_to_str, word [si + 0], .p3 + 4, 4, 16, 0b0100

            ; Length(64bit)
            cdecl int_to_str, word [si + 14], .p4 + 0, 4, 16, 0b0100
            cdecl int_to_str, word [si + 12], .p4 + 4, 4, 16, 0b0100
            cdecl int_to_str, word [si + 10], .p5 + 0, 4, 16, 0b0100
            cdecl int_to_str, word [si + 8 ], .p5 + 4, 4, 16, 0b0100

            ; Type(32bit)
            cdecl int_to_str, word [si + 18], .p6 + 0, 4, 16, 0b0100
            cdecl int_to_str, word [si + 16], .p6 + 4, 4, 16, 0b0100

            cdecl   puts, .s1                       ; //レコード情報を表示

            mov     bx, [si + 16]                   ; //タイプを文字列で表示
            and     bx, 0x07                        ; BX = Type(0~5)
            shl     bx, 1                           ; BX *= 2   //要素サイズに変換
            add     bx, .t0                         ; BX += .t0 //テーブルの先頭アドレスを加算
            cdecl   puts, word [bx]

            ;レジスタの復帰
            pop     si
            pop     bx

            ;スタックフレームの破棄
            mov     sp, bp
            pop     bp

            ret

.s1:        db  " "
.p2:        db  "ZZZZZZZZ_"
.p3:        db  "ZZZZZZZZ "
.p4:        db  "ZZZZZZZZ_"
.p5:        db  "ZZZZZZZZ "
.p6:        db  "ZZZZZZZZ ", 0

.s4:        db  " (Unknown)", 0x0A, 0x0D, 0
.s5:        db  " (usable)", 0x0A, 0x0D, 0
.s6:        db  " (reserved)", 0x0A, 0x0D, 0
.s7:        db  " (ACPI data)", 0x0A, 0x0D, 0
.s8:        db  " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:        db  " (bad memory)", 0x0A, 0x0D, 0

.t0:        dw  .s4, .s5, .s6, .s7, .s8, .s4, .s4