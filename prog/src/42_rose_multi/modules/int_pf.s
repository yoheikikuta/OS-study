int_pf:
    ;-----------------------
    ; Constract stack frame
    ;-----------------------
    push   ebp
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    pusha
    push   ds
    push   es

    ;-----------------------
    ; Check address of exception
    ;-----------------------
    mov    eax, cr2        ; CR2
    and    eax, ~0x0FFF    ; Access within 4K byte
    cmp    eax, 0x0010_7000  ; ptr = (access address)
    jne    .10F            ; if (0x0010_7000 == ptr)

    ;-----------------------
    ; Copy drawing parameter
    ;-----------------------
    mov    [0x00106000 + 0x107 * 4], dword 0x00107007  ; Enable page
    cdecl  memcpy, 0x0010_7000, DRAW_PARAM, rose_size  ; Drawing parameter for task3

    jmp    .10E
.10F:

    ;-----------------------
    ; Adjust stack frame
    ;-----------------------
    add    esp, 4          ; pop es
    add    esp, 4          ; pop ds
    popa
    pop    ebp

    ;-----------------------
    ; Task finish procedure
    ;-----------------------
    pushf                  ; EFLAGS
    push   cs              ; CS
    push   int_stop        ; Stack displaying procedure

    mov    eax, .s0        ; interruption type
    iret
.10E:

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

    ;-----------------------
    ; Discard error code
    ;-----------------------
    add    esp, 4
    iret

.s0     db " < PAGE FAULT > ", 0
