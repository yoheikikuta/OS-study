memcpy:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                            ; BP + 8  byte number
                            ; BP + 6  source address
                            ; BP + 4  target address
    push   bp
    mov    bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   cx
    push   si
    push   di

    ;-----------------------
    ; Copy in bytes
    ;-----------------------
    cld
    mov    di, [bp + 4]
    mov    si, [bp + 6]
    mov    cx, [bp + 8]

    rep movsb

    ;-----------------------
    ; Recover registres
    ;-----------------------
    pop    di
    pop    si
    pop    cx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret