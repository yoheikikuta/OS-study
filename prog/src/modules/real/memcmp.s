memcmp:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                            ; BP + 8  byte number
                            ; BP + 6  address 1
                            ; BP + 4  address 0
    push   bp
    mov    bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   bx
    push   cx
    push   dx
    push   si
    push   di

    ;-----------------------
    ; Get argument
    ;-----------------------
    cld
    mov    si, [bp + 4]
    mov    di, [bp + 8]
    mov    cx, [bp + 8]

    ;-----------------------
    ; Compare in bytes
    ;-----------------------
    repe cmpsb
    jnz    .10F
    mov    ax, 0
    jmp    .10E
.10F:

    mov    ax, -1
.10E:

    ;-----------------------
    ; Recover registres
    ;-----------------------
    pop    di
    pop    si
    pop    dx
    pop    cx
    pop    bx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret