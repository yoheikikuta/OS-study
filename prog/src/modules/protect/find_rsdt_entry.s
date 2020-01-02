find_rsdt_entry:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                            ; EBP + 16  search data
                            ; EBP + 12  name
                            ; EBP + 8  address
    push   ebp
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push    ebx
    push    ecx
    push    esi
    push    edi

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    esi, [ebp + 8]  ; EDI = RSDT
    mov    ecx, [ebp + 12]  ; ECX = name

    mov    ebx, 0          ; adr = 0

    ;-----------------------
    ; Procedure of searching ACPI table
    ;-----------------------
    mov    edi, esi
    add    edi, [esi + 4]  ; EDI = &ENTRY[MAX]
    add    esi, 36         ; ESI = &ENTRY[0]
.10L:
    cmp    esi, edi        ; while (ESI < EDI)
    jge    .10E

    lodsd                  ; EAX = [ESI++]

    cmp    [eax], ecx      ; if (ECX == *EAX)  Entry
    jne    .12E
    mov    ebx, eax        ; adr = EAX  FACP address
    jmp    .10E            ; break
.12E:  jmp    .10L
.10E:

    mov    eax, ebx         ; return adr

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    edi
    pop    esi
    pop    ecx
    pop    ebx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret
