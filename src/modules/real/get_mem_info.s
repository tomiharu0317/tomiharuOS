get_mem_info:

            ;レジスタの保存
            push    eax
            push    ebx
            push    ecx
            push    edx
            push    si
            push    di
            push    bp

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

.s2:        db  " <more...>", 0
.s3:        db  0x0D, "          ", 0x0D, 0