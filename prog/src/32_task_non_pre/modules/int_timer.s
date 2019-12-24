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
    ; Recover registers
    ;-----------------------
    pop    es
    pop    ds
    popad

    iret

ALIGN 4, db 0
TIMER_COUNT:  dq 0
