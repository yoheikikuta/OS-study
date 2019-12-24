call_gate:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +24  | character
                           ; +20  | color
                           ; +16  | Y (row)
                           ; +12  | X (column)
                           ; +8  | CS (code segment)
                           ; +4  | EIP (return address)
    push   ebp             ; EBP + 0 | EBP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    pusha
    push   ds
    push   es

    ;-----------------------
    ; Set segment for data
    ;-----------------------
    mov    ax, 0x0010
    mov    ds, ax
    mov    es, ax

    ;-----------------------
    ; Display string
    ;-----------------------
    mov    eax, dword [ebp + 12]  ; EAX = X
    mov    ebx, dword [ebp + 16]  ; EBX = Y
    mov    ecx, dword [ebp + 20]  ; ECX = color
    mov    edx, dword [ebp + 24]  ; EDX = string
    cdecl  draw_str, eax, ebx, ecx, edx  ; draw_str()

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    es
    pop    ds
    popa

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    retf 4 * 4             ; Stack of privilege level 0 copied X, Y, color, character (4 bytes each) from that of privilege level 3
