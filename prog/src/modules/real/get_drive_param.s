get_drive_param:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +4 | parameter buffer
                           ; +2 | IP (return address)
    push   bp              ; BP + 0 | BP
    mov    bp, sp


    ;-----------------------
    ; Save registers
    ;-----------------------
    push   bx
    push   cx
    push   es
    push   si
    push   di

    ;-----------------------
    ; Start procedure
    ;-----------------------
    mov    si, [bp + 4]    ; SI = (SRC buffer)

    mov    ax, 0           ; Initialize Disk Base Table Pointer
    mov    es, ax          ; ES = 0
    mov    di, ax          ; DI = 0

    mov    ah, 8           ; Get drive parameters
    mov    dl, [si + drive.no]  ; DL = (drive number)
    int    0x13            ; CF = BIOS(0x13, 8)
.10Q:  jc     .10F         ; if (0 == CF)
.10T:
    mov    al, cl          ; AX = (sector number)
    and    ax, 0x3F        ; Use only lower 6 bits

    shr    cl, 6           ; CX = (cylinder number)
    ror    cx, 8
    inc    cx
    
    movzx  bx, dh          ; BX = (head number)
    inc    bx

    mov    [si + drive.cyln], cx  ; drive.syln = CX
    mov    [si + drive.head], bx  ; drive.head = BX
    mov    [si + drive.sect], ax  ; drive.sect = AX

    jmp    .10E
.10F:
    mov    ax, 0
.10E:

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    di
    pop    si
    pop    es
    pop    cx
    pop    bx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    sp, bp
    pop    bp

    ret