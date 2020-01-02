f1_f2_f3:
    ; F1 + F2 + F3 are keys for poewr off
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
    push   ebp
    mov    ebp, esp

    ;-----------------------
    ; Save key state
    ;-----------------------
    mov    eax, [ebp + 8]  ; EAX = key
    btr    eax, 7          ; CF = EAX & 0x80
    jc     .10F            ; if (0 == CF)
    bts    [.key_state], eax
    jmp    .10E            ; Flag set
.10F:
    btc    [.key_state], eax  ; Flag clear
.10E:

    ;-----------------------
    ; Key push judgement
    ;-----------------------
    mov    eax, 0x3B       ; [F1] key is pushed?
    bt     [.key_state], eax  ; if (F1 != key)
    jnc    .20E

    mov    eax, 0x3C       ; [F2] key is pushed?
    bt     [.key_state], eax  ; if (F2 != key)
    jnc    .20E

    mov    eax, 0x3D       ; [F3] key is pushed?
    bt     [.key_state], eax  ; if (F3 != key)
    jnc    .20E

    mov    eax, -1         ; ret = -1

.20E:
    sar    eax, 8          ; ret >>= 8

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret

.key_state:  times 32 db 0