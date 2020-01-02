acpi_find:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                            ; EBP + 16  search data
                            ; EBP + 12  size
                            ; EBP + 8  address
    push   ebp
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ecx
    push   edi

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    edi, [ebp + 8]  ; EDI = (address)
    mov    ecx, [ebp + 12]  ; ECX = (size)
    mov    eax, [ebp + 16]  ; EAX = (search data)

    ;-----------------------
    ; Search name
    ;-----------------------
    cld                    ; DF clear
.10L:

    repne  scasb           ; while (AL != *EDI) EDI++

    cmp    ecx, 0          ; if (0 == ECX)
    jnz    .11E
    mov    eax, 0          ; EAX = 0
    jmp    .10E            ; break
.11E:

    cmp    eax, [es:edi - 1]  ; if (EAX != *EDI)  Mismatch by four characters?
    jne    .10L            ; continue

    dec    edi             ; EAX = EDI - 1
    mov    eax, edi
.10E:

    ;-----------------------
    ; Recover regsiters
    ;-----------------------
    pop    edi
    pop    ecx
    pop    ebx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret