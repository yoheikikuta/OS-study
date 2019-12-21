itoa:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +24  | flag
                           ; +20  | base
                           ; +16  | buffer size
                           ; +12  | buffer address
                           ; +8  | number
                           ; +4  | EIP (return address)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    eax, [ebp + 8]  ; val = (number)
    mov    esi, [ebp + 12]  ; dst = (buffer address)
    mov    ecx, [ebp + 16]  ; size = (rest buffer size)

    mov    edi, esi        ; Tail of buffer
    add    edi, ecx        ; dst = &dst[size - 1]
    dec    edi

    mov    ebx, [ebp + 24]  ; flags = (option)

    ;-----------------------
    ; Check sign of number
    ;-----------------------
    test   ebx, 0b0001     ; if (flags & 0x01)
.10Q:  je     .10E
    cmp    eax, 0          ; if (val < 0)
.12Q:  jge    .12E
    or     ebx, 0b0010     ; flags |= 2
.12E:
.10E:

    ;-----------------------
    ; Check print sign
    ;-----------------------
    test   ebx, 0b0010     ; if (flags & 0x02)
.20Q:  je     .20E
    cmp    eax, 0
.22Q:  jge    .22F
    neg    eax             ; val *= -1 (sign flip)
    mov    [esi], byte '-'  ; *dst = '-'
    jmp    .22E
.22F:

    mov    [esi], byte '+'  ; *dst = '+'
.22E:
    dec    ecx             ; size--
.20E:

    ;-----------------------
    ; ASCII transformation
    ;-----------------------
    mov    ebx, [ebp + 20]  ; BX = (base)
.30L:

    mov    edx, 0
    div    ebx             ; DX = DX:AX % (base), AX = DX:AX / (base)

    mov    esi, edx        ; Refer table
    mov    dl, byte [.ascii + esi]  ; DL = ASCII[DX]

    mov    [edi], dl       ; *dst = DL
    dec    edi             ; dst--;

    cmp    eax, 0
    loopnz .30L            ; while (AX)
.30E:

    ;-----------------------
    ; Pad blanks
    ;-----------------------
    cmp    ecx, 0          ; if (size)
.40Q:  je    .40E
    mov    al, ' '          ; AL = ' '
    cmp    [ebp + 24], word 0b0100  ; if (flags & 0x04)
.42Q:  jne   .42E
    mov    al, '0'         ; AL = '0'
.42E:
    std                    ; DF = 1 (minus direction)
    rep    stosb           ; while (--CX) *DI-- = ''
.40E:

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    edi
    pop    esi
    pop    edx
    pop    ecx
    pop    ebx
    pop    eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret

.ascii  db  "0123456789ABCDEF"