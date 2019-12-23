int_keyboard:
    ; DEFINE interruption procedure
    ;-----------------------
    ; Save registers
    ;-----------------------
    pusha
    push   ds
    push   es

    ;-----------------------
    ; Set segment for data
    ;-----------------------
    mov    ax, 0x0010
    mov    ds, ax
    mov    es, ax

    ;-----------------------
    ; Read buffer of Key Board Controller
    ;-----------------------
    in     al, 0x60        ; AL = (got key code)  The port of keyboard and mouse is 0x60

    ;-----------------------
    ; Save key code
    ;-----------------------
    cdecl  ring_wr, _KEY_BUFF, eax  ; ring_wr(_KEY_BUFF, EAX)

    ;-----------------------
    ; Send finish command of interruption
    ;-----------------------
    outp   0x20, 0x20       ; outp()  master PIC:EOI command

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    es
    pop    ds
    popa

    iret

ALIGN 4, db 0
_KEY_BUFF: times ring_buff_size db 0
