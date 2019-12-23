draw_rotation_bar:
    ;-----------------------
    ; Save registers
    ;-----------------------
    push eax

    ;-----------------------
    ; Periodic drawing
    ;-----------------------
    mov    eax, [TIMER_COUNT]  ; EAX = (timer interrupt counter)
    shr    eax, 4          ; EAX /= 4  Update in every 160 [msec]
    cmp    eax, [.index]   ; if (EAX != previous value)
    je     .10E

    mov    [.index], eax   ; (previous value) = EAX
    and    eax, 0x03       ; EAX &= 0x03  Use only 0~3

    mov    al, [.table + eax]  ; AL = table[index]
    cdecl  draw_char, 0, 29, 0x000F, eax  ; draw_char()
.10E:

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop eax

    ret

ALIGN 4, db 0
.index: dd 0  ; previous value
.table: db "|/-\"  ; display characters
