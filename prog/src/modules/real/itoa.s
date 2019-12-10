itoa:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +12 | flag
                           ; +10 | base
                           ; +8  | buffer size
                           ; +6  | buffer address
                           ; +4  | number
                           ; +2  | IP (return address)
    push   bp              ; BP + 0 | BP
    mov    bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   ax
    push   bx
    push   cx
    push   dx
    push   si
    push   di

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    ax, [bp + 4]    ; val = (number)
    mov    si, [bp + 6]    ; dst = (buffer address)
    mov    cx, [bp + 8]    ; size = (rest buffer size)

    mov    di, si          ; Tail of buffer
    add    di, cx          ; dst = &dst[size - 1]
    dec    di

    mov    bx, word [bp + 12]  ; flags = (option)

    ;-----------------------
    ; Check sign of number
    ;-----------------------
    test   bx, 0b0001      ; if (flags & 0x01)
.10Q:  je     .10E
    cmp    ax, 0           ; if (val < 0)
.12Q:  jge    .12E
    or     bx, 0b0010      ; flags |= 2
.12E:
.10E:

    ;-----------------------
    ; Check print sign
    ;-----------------------
    test   bx, 0b0010      ; if (flags & 0x02)
.20Q:  je     .20E
    cmp    ax, 0
.22Q:  jge    .22F
    neg    ax              ; val *= -1 (sign flip)
    mov    [si], byte '-'  ; *dst = '-'
    jmp    .22E
.22F:

    mov    [si], byte '+'  ; *dst = '+'
.22E:
    dec    cx              ; size--
.20E:

    ;-----------------------
    ; ASCII transformation
    ;-----------------------
    mov    bx, [bp + 10]   ; BX = (base)
.30L:

    mov    dx, 0
    div    bx              ; DX = DX:AX % (base), AX = DX:AX / (base)

    mov    si, dx          ; Refer table
    mov    dl, byte [.ascii + si]  ; DL = ASCII[DX]

    mov    [di], dl        ; *dst = DL
    dec    di              ; dst--;

    cmp    ax, 0
    loopnz .30L            ; while (AX)
.30E:

    ;-----------------------
    ; Pad blanks
    ;-----------------------
    cmp    cx, 0           ; if (size)
.40Q:  je    .40E
    mov    al, ' '          ; AL = ' '
    cmp    [bp +12], word 0b0100  ; if (flags & 0x04)
.42Q:  jne   .42E
    mov    al, '0'         ; AL = '0'
.42E:
    std                    ; DF = 1 (minus direction)
    rep    stosb           ; while (--CX) *DI-- = ''
.40E:

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    di
    pop    si
    pop    dx
    pop    cx
    pop    bx
    pop    ax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret

.ascii  db  "0123456789ABCDEF"