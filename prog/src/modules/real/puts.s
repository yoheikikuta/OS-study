puts:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +4 | output character
                           ; +2 | IP (return address)
                           ; BP + 0 | BP
    push   bp
    mov    bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   ax
    push   bx
    push   si

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    si, [bp + 4]    ; SI = address of string

    ;-----------------------
    ; Start procedure
    ;-----------------------
    mov    ah, 0x0E        ; Output one character with teletype style
    mov    bx, 0x0000      ; Set page number and character color as 0
    cld                    ; DF = 0 add address
.10L:

    lodsb                  ; AL = *SI++

    cmp    al, 0
    je     .10E
    int    0x10
    jmp    .10L
.10E:

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    si
    pop    bx
    pop    ax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret