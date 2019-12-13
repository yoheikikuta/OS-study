get_font_adr:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +4 | Position of stroing font address
                           ; +2 | IP (return address)
    push   bp              ; BP + 0 | BP
    mov    bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   ax
    push   bx
    push   si
    push   es
    push   bp

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    si, [bp + 4]    ; dst = (save distination of font address)

    ;-----------------------
    ; Get font address
    ;-----------------------
    mov    ax, 0x1130      ; Get font address
    mov    bh, 0x06        ; 8x16 font(vga/mcga)
    int    10h             ; ES:BP = (font address)

    ;-----------------------
    ; Save font address
    ;-----------------------
    mov    [si + 0], es    ; dst[0] = (segment)
    mov    [si + 2], bp    ; dst[1] = (offset)

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    bp
    pop    es
    pop    si
    pop    bx
    pop    ax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret