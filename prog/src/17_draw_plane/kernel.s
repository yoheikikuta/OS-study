;***********************
; Macro
;***********************
%include  "../include/define.s"
%include  "../include/macro.s"

    ORG  KERNEL_LOAD     ; load address of kernel

[BITS 32]
;***********************
; Entry point
;***********************
kernel:
    ;-----------------------
    ; Get font address
    ;-----------------------
    mov    esi, BOOT_LOAD + SECT_SIZE  ; ESI = 0x7C00 + 512
    movzx  eax, word [esi + 0]  ; EAX = [ESI + 0] segment
    movzx  ebx, word [esi + 2]  ; EBX = [ESI + 2] offset
    shl    eax, 4          ; EAX <<= 4
    add    eax, ebx        ; EAX += EBX
    mov    [FONT_ADR], eax  ; FONT_ADR[0] = EAX

    ;-----------------------
    ; 8 bit bar
    ;-----------------------
    mov    ah, 0x07        ; AH = (set write plane) Bit:----IRGB
    mov    al, 0x02        ; AL = (map mask register)
    mov    dx, 0x03C4      ; DX = (sequencer control port)
    out    dx, ax          ; Port output
    mov    [0x000A_0000 + 0], byte 0xFF

    mov    ah, 0x04        ; AH = (set write plane) Bit:----IRGB
    out    dx, ax          ; Port output
    mov    [0x000A_0000 + 1], byte 0xFF

    mov    ah, 0x02        ; AH = (set write plane) Bit:----IRGB
    out    dx, ax          ; Port output
    mov    [0x000A_0000 + 2], byte 0xFF

    mov    ah, 0x01        ; AH = (set write plane) Bit:----IRGB
    out    dx, ax          ; Port output
    mov    [0x000A_0000 + 3], byte 0xFF

    ;-----------------------
    ; Bar across dixsplay
    ;-----------------------
    mov    ah, 0x02         ; AH = (set write plane) Bit:----IRGB
    out    dx, ax           ; Port output
    lea    edi, [0x000A_0000 + 80]  ; EDI = (VRAM address)
    mov    ecx, 80          ; ECX = (repeat number)
    mov    al, 0xFF         ; AL = (bit pattern)
    rep    stosb            ; *EDI++ = AL

    ;-----------------------
    ; 8 dot rectangle in line 2
    ;-----------------------
    mov    edi, 1          ; EDI = (line number)
    shl    edi, 8          ; EDI *= 256
    lea    edi, [edi * 4 + edi + 0xA_0000]  ; EDI = (VRAM address)

    mov    [edi + (80 * 0)], word 0xFF
    mov    [edi + (80 * 1)], word 0xFF
    mov    [edi + (80 * 2)], word 0xFF
    mov    [edi + (80 * 3)], word 0xFF
    mov    [edi + (80 * 4)], word 0xFF
    mov    [edi + (80 * 5)], word 0xFF
    mov    [edi + (80 * 6)], word 0xFF
    mov    [edi + (80 * 7)], word 0xFF

    ;-----------------------
    ; Describe character in line 3
    ;-----------------------
    mov    esi, 'A'        ; ESI = (character code)
    shl    esi, 4          ; ESI *= 16
    add    esi, [FONT_ADR]  ; ESI = FONT_ADR[(character code)]

    mov    edi, 2          ; EDI = (line number)
    shl    edi, 8          ; EDI *= 256
    lea    edi, [edi * 4 + edi + 0xA_0000]  ; EDI = (VRAM address)

    mov    ecx, 16         ; ECX = 16
.10L:
    movsb                  ; *EDI++ = *ESI++
    add    edi, 80 - 1     ; EDI += 79 (for 1 dot)
    loop   .10L

    ;-----------------------
    ; Finish procedure
    ;-----------------------
    jmp    $               ; while (1)

ALIGN 4, db 0
FONT_ADR: dd 0

;***********************
; Padding
;***********************
    times KERNEL_SIZE - ($ - $$) db 0  ; padding