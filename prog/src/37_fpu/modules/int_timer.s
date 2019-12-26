int_timer:
    ;-----------------------
    ; Save registers
    ;-----------------------
    pushad
    push   ds
    push   es

    ;-----------------------
    ; Set segument for data
    ;-----------------------
    mov    ax, 0x0010
    mov    ds, ax
    mov    es, ax

    ;-----------------------
    ; Tick
    ;-----------------------
    inc    dword [TIMER_COUNT]  ; TIMER_COUNT++  Update interrupt number

    ;-----------------------
    ; Clear interrupt flag (EOI)
    ;-----------------------
    outp   0x20, 0x20      ; maser PIC:EOI command

    ;-----------------------
    ; Switch tasks
    ;-----------------------
    str    ax              ; AX = TR  Current task register
    cmp    ax, SS_TASK_0   ; case (AX)
    je     .11L
    cmp    ax, SS_TASK_1
    je     .12L

    jmp    SS_TASK_0:0     ; Switch to task0
    jmp    .10E
.11L:
    jmp    SS_TASK_1:0     ; Switch to task1
    jmp    .10E
.12L:
    jmp    SS_TASK_2:0     ; Switch to task2
    jmp    .10E
.10E:

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    es
    pop    ds
    popad

    iret

ALIGN 4, db 0
TIMER_COUNT:  dq 0
