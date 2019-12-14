KBC_Data_Write:
    ;-----------------------
    ; Save registers
    ;-----------------------
                           ; +4 | data
                           ; +2 | IP (return address)
    push   bp              ; BP + 0 | BP
    mov    bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   cx

    ;-----------------------
    ; Start procedure
    ;-----------------------
    mov    cx, 0
.10L:
    in     al, 0x64        ; AL = inp(0x64)  KBC status
    test   al, 0x02        ; ZF = AL & 0x02  Check if it's writable
    loopnz .10L            ; while (--CX && !ZF)

    cmp    cx, 0           ; if (CX)
    jz     .20E

    mov    al, [bp + 4]
    out    0x60, al
.20E:
    mov    ax, cx

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    cx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret


KBC_Data_Read:
    ;-----------------------
    ; Save registers
    ;-----------------------
                           ; +4 | data
                           ; +2 | IP (return address)
    push   bp              ; BP + 0 | BP
    mov    bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   cx

    ;-----------------------
    ; Start procedure
    ;-----------------------
    mov    cx, 0
.10L:
    in     al, 0x64        ; AL = inp(0x64)  KBC status
    test   al, 0x01        ; ZF = AL & 0x02  Check if it's readable
    loopnz .10L            ; while (--CX && !ZF)

    cmp    cx, 0           ; if (CX)
    jz     .20E

    mov    ah, 0x00        ; AH = 0x00
    in     al, 0x60        ; AL = inp(0x60)

    mov    di, [bp + 4]    ; DI = ptr
    mov    [di + 0], ax    ; DI[0] = AX
.20E:
    mov    ax, cx

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    cx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret


KBC_Cmd_Write:
    ;-----------------------
    ; Save registers
    ;-----------------------
                           ; +4 | data
                           ; +2 | IP (return address)
    push   bp              ; BP + 0 | BP
    mov    bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   cx

    ;-----------------------
    ; Start procedure
    ;-----------------------
    mov    cx, 0
.10L:
    in     al, 0x64        ; AL = inp(0x64)  KBC status
    test   al, 0x02        ; ZF = AL & 0x02  Check if it's writable
    loopnz .10L            ; while (--CX && !ZF)

    cmp    cx, 0           ; if (CX)
    jz     .20E

    mov    al, [bp + 4]
    out    0x64, al
.20E:
    mov    ax, cx

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    cx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret