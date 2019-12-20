vga_set_read_plane:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +8 | read plane
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   edx

    ;-----------------------
    ; Select read plane
    ;-----------------------
    mov    ah, [ebp + 8]   ; AH = (select plane), 3 = intensity, 2~0 = RGB
    and    ah, 0x03        ; AH &= 0x03  Mask extra bit
    mov    al, 0x04        ; AL = (read map select register)
    mov    dx, 0x03CE      ; DX = (graphics control port)
    out    dx, ax          ; Port output

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    edx
    pop    eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret


vga_set_write_plane:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +8 | write plane
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   edx

    ;-----------------------
    ; Select write plane
    ;-----------------------
    mov    ah, [ebp + 8]   ; AH = (select write plane), Bit:----IRGB
    and    ah, 0x0F        ; AH = 0x0F Mask extra bit
    mov    al, 0x02        ; AL = (map mask register)
    mov    dx, 0x03C4      ; DX = (sequencer control port)
    out    dx, ax          ; Port output

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    edx
    pop    eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret


vram_font_copy:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +20 | color (use only 16bits = 2bytes)
                           ; +16 | plane (use only 8bits = 1bytes)
                           ; +12 | VRAM address
                           ; +8 | font address
                           ; +4 | return address (32bits = 4bytes)
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
    ; Create mask data
    ;-----------------------
    mov    esi, [ebp + 8]  ; ESI = (font address)
    mov    edi, [ebp + 12]  ; EDI = (VRAM address)
    movzx  eax, byte [ebp + 16]  ; EAX = (plane)
    movzx  ebx, word [ebp + 20]  ; EBX = (color)

    test   bh, al          ; ZF = (back ground color & plane)
    setz   dh              ; ZF ? 0x01 : 0x00
    dec    dh              ; AH--  0x00 or 0xFF

    test   bl, al          ; ZF = (fore ground color & plane)
    setz   dl              ; AL = ZF ? 0x01 : 0x00
    dec    dl              ; AL--  0x00 or 0xFF

    ;-----------------------
    ; Copy 16 dot font
    ;-----------------------
    cld                    ; DF = 0
    
    mov    ecx, 16         ; ECX = 16  16bits
.10L:

    ;-----------------------
    ; Create font mask
    ;-----------------------
    lodsb                  ; AL = *ESI++  font
    mov    ah, al          ; AH ~= AL  !font
    not    ah

    ;-----------------------
    ; Fore ground color
    ;-----------------------
    and    al, dl          ; AL = (fore ground color & font)

    ;-----------------------
    ; Back ground color
    ;-----------------------
    test   ebx, 0x0010     ; if (transparent mode)
    jz     .11F
    and    ah, [edi]       ; AH = !font & [EDI]  current value
    jmp    .11E
.11F:
    and    ah, dh          ; AH = !font & back ground color
.11E:

    ;-----------------------
    ; Merge fore ground and back ground colors
    ;-----------------------
    or     al, ah          ; AL = (back ground | fore ground)

    ;-----------------------
    ; Output new value
    ;-----------------------
    mov    [edi], al       ; [EDI] = AL  Write on plane
    
    add    edi, 80         ; EDI += 80
    loop   .10L            ; while (--ECX)
.10E:

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    esi
    pop    edx
    pop    edi
    pop    ecx
    pop    ebx
    pop    eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp
    
    ret
