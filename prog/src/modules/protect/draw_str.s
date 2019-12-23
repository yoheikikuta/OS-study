draw_str:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +20 | p (address of string)
                           ; +16 | color
                           ; +12 | row (Y)
                           ; +8 | column (X)
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
    mov    ecx, [ebp + 8]  ; ECX = (colum)
    mov    edx, [ebp + 12]  ; EDX = (row)
    movzx  ebx, word [ebp + 16]  ; EBX = (display color)
    mov    esi, [ebp + 20]  ; ESI = (address of string)

    ;-----------------------
    ; Draw string
    ;-----------------------
    cld                    ; DF = 0 (address)
.10L:
    lodsb                  ; AL = *ESI++
    cmp    al, 0           ; if (0 == AL)
    je     .10E

    cdecl  draw_char, ecx, edx, ebx, eax  ; draw_char()
    inc    ecx             ; ECX++  move column

    cmp    ecx, 80         ; if (80 <= ECX)
    jl     .12E

    mov    ecx, 0          ; ECX = 0  Initialize column
    inc    edx             ; EDX++  move row

    cmp    edx, 30         ; if (30 <= EDX)
    jl    .12E

    mov   edx, 0           ; EDX = 0  Initialize row

.12E:
    jmp    .10L
.10E:

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov esp, ebp
    pop ebp

    ret
