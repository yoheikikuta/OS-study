draw_font:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +12 | row
                           ; +8 | col
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push    ebx
    push    eax
    push    ecx
    push    edx
    push    esi
    push    edi

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    esi, [ebp + 8]  ; ESI = X (colum)
    mov    edi, [ebp + 12]  ; EDI = Y (row)

    ;-----------------------
    ; Display fonts
    ;-----------------------
    mov    ecx, 0
.10L:
    cmp    ecx, 256        ; for (ECX = 0; ECX < 256)
    jae    .10E

    mov    eax, ecx        ; EAX = ECX
    and    eax, 0x0F       ; EAX &= 0x0F
    add    eax, esi        ; EAX += X

    mov    ebx, ecx        ; EBX = ECX
    shr    ebx, 4          ; EBX /= 16
    add    ebx, edi        ; EBX += Y

    cdecl  draw_char, eax, ebx, 0x07, ecx  ; draw_char()

    inc    ecx             ; ECX++
    jmp    .10L
.10E:

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
    mov esp, ebp
    pop ebp

    ret
