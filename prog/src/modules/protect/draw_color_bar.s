draw_color_bar:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +12 | row
                           ; +8 | column
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
    ; Get arguments
    ;-----------------------
    mov    esi, [ebp + 8]  ; ESI = X  column
    mov    edi, [ebp + 12]  ; EDI = Y  row

    ;-----------------------
    ; Display color bar
    ;-----------------------
    mov    ecx, 0          ; if (ECX = 0; ECX < 16)
.10L:
    cmp    ecx, 16
    jae    .10E

    mov    eax, ecx        ; EAX = ECX
    and    eax, 0x01       ; EAX &= 0x01
    shl    eax, 3          ; EAX *= 8  For 8 characters
    add    eax, esi        ; EAX += X

    mov    ebx, ecx        ; EBX = ECX
    shr    ebx, 1          ; EBX /= 2
    add    ebx, edi        ; EBX += Y

    mov    edx, ecx        ; EDX = ECX
    shl    edx, 1          ; EDX *= 2
    mov    edx, [.t0 + edx]  ; EDX += Y

    cdecl  draw_str, eax, ebx, edx, .s0  ; draw_str()

    inc    ecx             ; for (ECX++)
    jmp    .10L
.10E:

    ;-----------------------
    ; Recover fonts
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

.s0:  db '        ', 0  ; For 8 characters
.t0:  dw 0x0000, 0x0800  ; back ground color of color bar
      dw 0x0100, 0x0900
      dw 0x0200, 0x0A00
      dw 0x0300, 0x0B00
      dw 0x0400, 0x0C00
      dw 0x0500, 0x0D00
      dw 0x0600, 0x0E00
      dw 0x0700, 0x0F00
