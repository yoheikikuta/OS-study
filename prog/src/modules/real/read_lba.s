lba_chs:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +6 | output buffer
                           ; +4 | parameter buffer
                           ; +2 | IP (return address)
    push   bp              ; BP + 0 | BP
    mov bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push ax
    push bx
    push dx
    push si
    push di

    ;-----------------------
    ; Compute sector number
    ;-----------------------
    mov si, [bp + 4]       ; SI = (SRC buffer)
    mov di, [bp + 6]       ; DI = (Output buffer)

    mov al, [si + drive.head]  ; AL = (maximum head number)
    mul byte [si + drive.sect]  ; AX = (maximum head number) * (maximum sector number)
    mov bx, ax             ; BX = (Sector number per cylinder)

    mov dx, 0              ; DX = LBA (upper 2 bytes)
    mov ax, [bp + 8]       ; AX = LBA (lower 2 bytes)
    div bx                 ; DX = DX:AX % BX (mod), AX = DX:AX / BX (cylinder number)

    mov [di + drive.cyln], ax  ; drv_chs.cyln = (cylinder number)

    mov ax, dx             ; AX = (mod)
    div byte [si + drive.sect]  ; AH = AX % AX % (maximum sector number): sector number, AL = AX / maximum sector number: head number

    movzx dx, ah           ; DX = (sector number)
    inc dx                 ; Sector number begins from 1 (not 0)

    mov ah, 0x00           ; AX = (head position)

    mov [di + drive.head], ax  ; drv_chs.head = (head number)
    mov [di + drive.sect], dx  ; drv_chs.sect = (sector number)

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop di
    pop si
    pop dx
    pop bx
    pop ax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov sp, bp
    pop bp

    ret


read_lba:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +6 | LBA
                           ; +4 | parameter buffer
                           ; +2 | IP (return address)
    push   bp              ; BP + 0 | BP
    mov    bp, sp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push si

    ;-----------------------
    ; Transform LBA to CHS
    ;-----------------------
    mov si, [bp + 4]       ; SI = (drive information)
    mov ax, [bp + 6]       ; AX = (LBA)
    cdecl lba_chs, si, .chs, ax  ; lba_chs(drive, .chs, AX)

    ;-----------------------
    ; Copy drive number
    ;-----------------------
    mov al, [si + drive.no]
    mov [.chs + drive.no], al  ; drive number

    ;-----------------------
    ; Read sector number
    ;-----------------------
    cdecl read_chs, .chs, word [bp + 8], word [bp + 10]  ; AX = read_chs(.chs, sector_num, ofs)

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop si

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov sp, bp
    pop bp

    ret

.chs:  times drive_size db 0