putc:
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

    ;-----------------------
    ; Start procedure
    ;-----------------------
    mov    al, [bp + 4]    ; Get character
    mov    ah, 0x0E        ; Output one character with teletype style
    mov    bx, 0x0000      ; Set page number and character color as 0
    int    0x10            ; Video BIOS call

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    bx
    pop    ax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret