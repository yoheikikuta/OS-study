draw_rect:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +24 | color
                           ; +20 | y_end
                           ; +16 | x_end
                           ; +12 | y_start
                           ; +8 | x_start
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx
    push   ecx
    push   edx
    push   esi

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    eax, [ebp + 8]  ; EAX = x_start
    mov    ebx, [ebp + 12]  ; EBX = y_start
    mov    ecx, [ebp + 16]  ; ECX = x_end
    mov    edx, [ebp + 20]  ; EDX = y_start
    mov    esi, [ebp + 24]  ; ESI = (color)

    ;-----------------------
    ; Set start positons < end positions
    ;-----------------------
    cmp    eax, ecx        ; if (x_end < x_start)
    jl     .10E
    xchg   eax, ecx        ; swap(x_end, x_start)
.10E:
    cmp    ebx, edx        ; if (y_end < y_start)
    jl     .20E
    xchg   ebx, edx        ; swap(y_end, y_start)
.20E:

    ;-----------------------
    ; Draw rectangler
    ;-----------------------
    cdecl  draw_line, eax, ebx, ecx, ebx, esi
    cdecl  draw_line, eax, ebx, eax, edx, esi

    dec    edx             ; EDX--  make bottom line one dot upper
    cdecl  draw_line, eax, edx, ecx, edx, esi
    inc    edx

    dec    ecx             ; ECX--  make right line one dot lefter
    cdecl  draw_line, ecx, ebx, ecx, edx, esi

    ;-----------------------
    ; Recover registers
    ;-----------------------
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
