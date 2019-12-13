get_mem_info:
    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx
    push   ecx
    push   edx
    push   si
    push   di
    push   bp

ALIGN 4, db 0
.b0:  times E820_RECORD_SIZE db 0

    cdecl  puts, .s0

    ;-----------------------
    ; Start procedure
    ;-----------------------
    mov    bp, 0           ; lines = 0
    mov    ebx, 0          ; index = 0
.10L:
    mov    eax, 0x0000E820  ; EAX = 0xE820

    mov    ecx, E820_RECORD_SIZE  ; ECX = (required bytes number)
    mov    edx, 'PAMS'     ; EDX = 'SMAP'
    mov    di, .b0         ; ES:DI = (buffer)
    int    0x15            ; BIOS(0x15, 0xE820)

    cmp    eax, 'PAMS'     ; if ('SMAP' != EAX)
    je     .12E
    jmp    .10E
.12E:
    jnc    .14E
    jmp    .10E
.14E:
    cdecl  put_mem_info, di

    ; Get ACPI address
    mov    eax, [di + 16]  ; EAX = (record type)
    cmp    eax, 3          ; if (3 == EAX)
    jne    .15E

    mov    eax, [di + 0]   ; EAX = (BASE address)
    mov    [ACPI_DATA.adr], eax  ; ACPI_DATA.adr = EAX

    mov    eax, [di + 8]   ; EAX = (Length)
    mov    [ACPI_DATA.len], eax  ; ACPI_DATA.len = EAX
.15E:
    cmp   ebx, 0           ; if (0 != EBX)
    jz    .16E

    inc   bp               ; lines++
    and   bp, 0x07         ; linex &= 0x07
    jnz   .16E             ; if (0 == lines)

    cdecl  puts, .s2       ; Print terminating message

    mov    ah, 0x10        ; wait input key
    int    0x16            ; AL = BIOS(0x16, 0x10)

    cdecl  puts, .s3       ; Delete terminating message
.16E:
    cmp    ebx, 0
    jne    .10L
.10E:
    cdecl  puts, .s1

    ;-----------------------
    ; Recover registers
    ;-----------------------
    push   bp
    push   di
    push   si
    push   edx
    push   ecx
    push   ebx
    push   eax

    ret

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db " E820 Memory Map:", 0x0A, 0x0D
     db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:  db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:  db " <more...>", 0
.s3:  db 0x0D, "          ", 0x0D, 0


put_mem_info:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +4 | Buffer address
                           ; +2 | IP (return address)
    push   bp              ; BP + 0 | BP
    mov    bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   bx
    push   si

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    si, [bp + 4]    ; dst = (save distination of font address)

    ;-----------------------
    ; Print contents of record
    ;-----------------------
    ; Base (64bit)
    cdecl  itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
    cdecl  itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
    cdecl  itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
    cdecl  itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

    ; Length (64bit)
    cdecl  itoa, word [si + 14], .p4 + 0, 4, 16, 0b0100
    cdecl  itoa, word [si + 12], .p4 + 4, 4, 16, 0b0100
    cdecl  itoa, word [si + 10], .p5 + 0, 4, 16, 0b0100
    cdecl  itoa, word [si + 8], .p5 + 4, 4, 16, 0b0100

    ; Type (32bit)
    cdecl  itoa, word [si + 18], .p6 + 0, 4, 16, 0b0100
    cdecl  itoa, word [si + 16], .p6 + 4, 4, 16, 0b0100

    cdecl  puts, .s1       ; Print record information

    mov    bx, [si + 16]   ; Print type in string
    and    bx, 0x07        ; BX = Type(0~5)
    shl    bx, 1           ; BX *= 2  Transform to element size
    add    bx, .t0         ; BX += .t0  Add address of the head of the table
    cdecl  puts, word [bx]  ; puts(*BX)

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    si
    pop    bx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret

    ;-----------------------
    ; Data
    ;-----------------------
.s1:  db " "
.p2:  db "ZZZZZZZZ_"
.p3:  db "ZZZZZZZZ "
.p4:  db "ZZZZZZZZ_"
.p5:  db "ZZZZZZZZ "
.p6:  db "ZZZZZZZZ", 0

.s4:  db " (Unknown)", 0x0A, 0x0D, 0
.s5:  db " (usable)", 0x0A, 0x0D, 0
.s6:  db " (reserved)", 0x0A, 0x0D, 0
.s7:  db " (ACPI data)", 0x0A, 0x0D, 0
.s8:  db " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:  db " (bad memory)", 0x0A, 0x0D, 0

.t0:  dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4,