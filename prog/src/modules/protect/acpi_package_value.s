acpi_package_value:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                            ; EBP + 8  address to package
    push   ebp
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   esi

    ;-----------------------
    ; Get argument
    ;-----------------------
    mov    esi, [ebp + 8]  ; ESI = (address to package)

    ;-----------------------
    ; Skip head packet
    ;-----------------------
    inc    esi             ; ESI++ Skip 'PackageOp'
    inc    esi             ; ESI++ Skip 'PkgLength'
    inc    esi             ; ESI++ Skip 'Num Elements'
                           ; ESI = PackageElementList

    ;-----------------------
    ; Get 2 bytes
    ;-----------------------
    mov    al, [esi]       ; AL = *ESI
    cmp    al, 0x0B        ; switch (AL)
    je     .C0B
    cmp    al, 0x0C
    je     .C0C
    cmp    al, 0x0E
    je     .C0E
    jmp    .C0A
.C0B:                      ; case 0x0B  'WordPrefix'
.C0C:                      ; case 0x0C  'DWordPrefix'
.C0E:                      ; case 0x0E  'QWordPrefix'
    mov    al, [esi + 1]   ; AL = ESI[1]
    mov    ah, [esi + 2]   ; AH = ESI[2]
    jmp    .10E            ; break

.C0A:
    cmp    al, 0x0A        ; if (0x0A == AL)
    jne    .11E
    mov    al, [esi + 1]   ; AL = *ESI
    inc    esi             ; ESI++

.11E:
    inc    esi             ; ESI++

    mov    ah, [esi]       ; AH = *ESI
    cmp    ah, 0x0A        ; if (0x0A == AL)
    jne    .12E
    mov    ah, [esi + 1]   ; AH = ESI[1]

.12E:
.10E:
    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    esi

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret
