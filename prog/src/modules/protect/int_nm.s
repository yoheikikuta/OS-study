int_nm:
    ;-----------------------
    ; Save registers
    ;-----------------------
    pusha
    push   ds
    push   es

    ;-----------------------
    ; Set selector for kernel
    ;-----------------------
    mov    ax, DS_KERNEL
    mov    ds, ax
    mov    es, ax

    ;-----------------------
    ; Clear task switch flag
    ;-----------------------
    clts                   ; CR0.TS = 0

    ;-----------------------
    ; TSS of task using FPU (last/this time)
    ;-----------------------
    mov    edi, [.last_tss]  ; EDI = TSS of task using FPU last time
    str    esi             ; ESI = TSS of task using FPU this time
    and    esi, ~0x0007    ; Mask privilege level

    ;-----------------------
    ; Check whether using FPU first time
    ;-----------------------
    cmp    edi, 0          ; if (0 != EDI)  Task using FPU last time
    je     .10F            ; If no task which does not use FPU last time, go to .10F

    cmp    esi, edi        ; if (ESI != EDI)  Task using FPU this time
    je     .12E            ; If no task which does not use FPU this time, go to .12E

    cli                    ; Forbid interruption

    ;-----------------------
    ; Save FPU context (last time)
    ;-----------------------
    mov    ebx, edi        ; Task of last time
    call   get_tss_base    ; Get TSS address
    call   save_fpu_context  ; Save FPU context

    ;-----------------------
    ; Recover FPU context (this time)
    ;-----------------------
    mov    ebx, esi        ; Task of this time
    call   get_tss_base    ; Get TSS address
    call   load_fpu_context  ; Recover FPU context

    sti                    ; Allow interruption
.12E:
    jmp    .10E
.10F:
    cli                    ; Forbid interruption

    ;-----------------------
    ; Recover FPU context (this time)
    ;-----------------------
    mov    ebx, esi        ; Task of this time
    call   get_tss_base    ; Get TSS address
    call   load_fpu_context  ; Recover FPU context

    sti
.10E:
    mov    [.last_tss], esi  ; Save task using FPU

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    es
    pop    ds
    popa

    iret

ALIGN 4, db 0
.last_tss: dd 0


get_tss_base:
    mov    eax, [GDT + ebx + 2]
    shl    eax, 8
    mov    al,  [GDT + ebx + 7]
    ror    eax, 8

    ret

save_fpu_context:
    fnsave [eax + 104]
    mov    [eax + 104 + 108], dword 1

    ret

load_fpu_context:
    cmp    [eax + 104 + 108], dword 0
    jne    .10F
    fninit
    jmp    .10E
.10F:
    frstor [eax + 104]
.10E:
    ret
