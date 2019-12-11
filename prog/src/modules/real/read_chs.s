read_chs:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +8 | copy destination
                           ; +6 | sector number
                           ; +4 | parameter buffer
                           ; +2 | IP (return address)
    push   bp              ; BP + 0 | BP
    mov    bp, sp
    push   3               ; -2 | retry = 3 (trial number)
    push   0               ; -4 | sect = 0 (reading sector number)


    ;-----------------------
    ; Save registers
    ;-----------------------
    push   bx
    push   cx
    push   dx
    push   es
    push   si

    ;-----------------------
    ; Start procedure
    ;-----------------------
    mov    si, [bp + 4]    ; SI = (SRC buffer)

    ;-----------------------
    ; Set CX register
    ; (Modify its form for BIOS call)
    ;-----------------------
    mov    ch, [si + drive.cyln + 0]  ; CH = (cylinder number: lower bytes)
    mov    cl, [si + drive.cyln + 1]  ; CL = (cylinder number: higher bytes)
    shl    cl, 6           ; CL <<= 6 (the higest 2 bits)
    or     cl, [si + drive.sect]  ; CL |= (sector number)

    ;-----------------------
    ; Read sector
    ;-----------------------
    mov    dh, [si + drive.head]  ; DH = (head number)
    mov    dl, [si + 0]    ; DL = (drive number)
    mov    ax, 0x0000      ; AX = 0x0000
    mov    es, ax          ; ES = (segment)
    mov    bx, [bp + 8]    ; BX = (copy destination)
.10L:

    mov    ah, 0x02        ; AH = (read sector)
    mov    al, [bp + 6]    ; AL = (sector number)

    int    0x13            ; CF = BIOS(0x13, 0x02)
    jnc    .11E            ; if (CF)

    mov    al, 0           ; AL = 0
    jmp    .10E            ; break
.11E:

    cmp    al, 0           ; if existing a read sector
    jne    .10E            ; break

    mov    ax, 0           ; ret = 0 (set the return value)
    dec    word [bp -2]
    jnz    .10L            ; while (--retry)
.10E:
    mov    ah, 0           ; AH = 0 (discard status information)

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    si
    pop    es
    pop    dx
    pop    cx
    pop    bx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret