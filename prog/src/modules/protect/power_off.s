power_off:
    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx
    push   ecx
    push   edx
    push   esi

    ;-----------------------
    ; Display string
    ;-----------------------
    cdecl  draw_str, 25, 14, 0x020F, .s0

    ;-----------------------
    ; Disable paging
    ;-----------------------
    mov    eax, cr0        ; Clear PG bit
    and    eax, 0x7FFF_FFFF  ; CR0 &= ~PG
    mov    cr0, eax
    jmp    $ + 2           ; FLUSH()

    ;-----------------------
    ; Check ACPI data
    ;-----------------------
    mov    eax, [0x7C00 + 512 + 4]  ; EAX = (ACPI address)
    mov    ebx, [0x7C00 + 512 + 8]  ; EBX = (length)
    cmp    eax, 0          ; if (0 == EAX)
    je     .10E            ; break

    ;-----------------------
    ; Search RSDT table
    ;-----------------------
    cdecl  acpi_find, eax, ebx, 'RSDT'  ; EAX = acpi_find("RSDT)
    cmp    eax, 0          ; if (0 == EAX)
    je    .10E             ; break

    ;-----------------------
    ; Search FACP table
    ;-----------------------
    cdecl  find_rsdt_entry, eax, 'FACP'  ; EAX = find_rsdt_entry('FACT')
    cmp    eax, 0          ; if (0 == EAX)
    je     .10E            ; break

    mov    ebx, [eax + 40]  ; Get DSDT address
    cmp    ebx, 0          ; if (0 == DSDT)
    je     .10E            ; break

    ;-----------------------
    ; Save ACPI registers
    ;-----------------------
    mov    ecx, [eax + 64]  ; Get ACPI register
    mov    [PM1a_CNT_BLK], ecx  ; PM1a_CNT_BLK = FACP.PM1a_CNT_BLK

    mov    ecx, [eax + 68]  ; Get ACPI register
    mov    [PM1b_CNT_BLK], ecx  ; PM1b_CNT_BLK = FACP.PM1b_CNT_BLK

    ;-----------------------
    ; Search S5 name space
    ;-----------------------
    mov    ecx, [ebx + 4]  ; ECX = DSDT.Length  Data length
    sub    ecx, 36         ; ECX -= 36  Subtract by table header
    add    ebx, 36         ; EBX += 36  Add by table header
    cdecl  acpi_find, ebx, ecx, '_S5_'  ; EAX = acpi_find('_S5_')
    cmp    eax, 0          ; if (0 == EAX)
    je    .10E             ; break

    ;-----------------------
    ; Get package data
    ;-----------------------
    add    eax, 4          ; EAX = (head element)
    cdecl  acpi_package_value, eax  ; EAX = package data
    mov    [S5_PACKAGE], eax  ; S%_PACKAGE = EAX

.10E:

    ;-----------------------
    ; Enable paging
    ;-----------------------
    mov    eax, cr0        ; Set PG bit
    or     eax, (1 << 31)  ; CR0 |= PG
    mov    cr0, eax
    jmp    $ + 2           ; FLUSH()

    ;-----------------------
    ; Get ACPI register
    ;-----------------------
    mov    edx, [PM1a_CNT_BLK]  ; EDX = FACP.PM1a_CNT_BLK
    cmp    edx, 0          ; if (0 == EDX)
    je     .20E            ; break

    ;-----------------------
    ; Display count down
    ;-----------------------
    cdecl  draw_str, 38, 14, 0x020F, .s3
    cdecl  wait_tick, 100
    cdecl  draw_str, 38, 14, 0x020F, .s2
    cdecl  wait_tick, 100
    cdecl  draw_str, 38, 14, 0x020F, .s1
    cdecl  wait_tick, 100

    ;-----------------------
    ; Setting of PM1a_CNT_BLK
    ;-----------------------
    movzx  ax, [S5_PACKAGE.0]
    shl    ax, 10          ; AX = SLP_TYPx
    or     ax, 1 << 13     ; AX |= SLP_EN
    out    dx, ax          ; out(PM1a_CNT_BLK, AX)

    ;-----------------------
    ; Check PM1b_CNT_BLK
    ;-----------------------
    mov    edx, [PM1b_CNT_BLK]  ; EDX = FACP.PM1b_CNT_BLK
    cmp    edx, 0          ; if (0 == EDX)
    je     .20E            ; break

    ;-----------------------
    ; Setting of PM1b_CNT_BLK
    ;-----------------------
    movzx  ax, [S5_PACKAGE.1]
    shl    ax, 10          ; AX = SLP_TYPx
    or     ax, 1 << 13     ; AX |= SLP_EN
    out    dx, ax          ; out(PM1b_CNT_BLK, AX)

.20E:

    ;-----------------------
    ; Wait power off
    ;-----------------------
    cdecl  wait_tick, 100

    ;-----------------------
    ; Message of failuer of power off
    ;-----------------------
    cdecl  draw_str, 38, 14, 0x020F, .s4

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    esi
    pop    edx
    pop    ecx
    pop    ebx
    pop    eax

    ret

.s0:  db " Power off...   ", 0
.s1:  db " 1", 0
.s2:  db " 2", 0
.s3:  db " 3", 0
.s4:  db "NG", 0

ALIGN 4, db 0
PM1a_CNT_BLK:  dd 0
PM1b_CNT_BLK:  dd 0
S5_PACKAGE:
.0:  db 0
.1:  db 0
.2:  db 0
.3:  db 0