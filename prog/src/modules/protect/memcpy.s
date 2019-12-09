memcpy:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                            ; EBP + 16  byte number
                            ; EBP + 12  source address
                            ; EBP + 8  target address
    push   ebp
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   ecx
    push   esi
    push   edi

    ;-----------------------
    ; Copy in bytes
    ;-----------------------
    cld
    mov    edi, [ebp + 8]
    mov    esi, [ebp + 12]
    mov    ecx, [ebp + 16]

    rep movsb

    ;-----------------------
    ; Recover registres
    ;-----------------------
    pop    edi
    pop    esi
    pop    ecx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret