init_page:
    ;-----------------------
    ; Save registers
    ;-----------------------
    pusha

    ;-----------------------
    ; Create page translation table
    ;-----------------------
    cdecl  page_set_4m, CR3_BASE  ; for task 3
    cdecl  page_set_4m, CR3_TASK_4  ; for task 4
    cdecl  page_set_4m, CR3_TASK_5  ; for task 5
    cdecl  page_set_4m, CR3_TASK_6  ; for task 6

    ;-----------------------
    ; Set page table (if absence)
    ;-----------------------
    mov    [0x00106000 + 0x107 * 4], dword 0  ; Set 0x0010_7000 as page fault

    ;-----------------------
    ; Set address translation
    ;-----------------------
    mov    [0x0020_1000 + 0x107 * 4], dword PARAM_TASK_4 + 7  ; Address translation for task 4
    mov    [0x0020_3000 + 0x107 * 4], dword PARAM_TASK_5 + 7  ; Address translation for task 5
    mov    [0x0020_5000 + 0x107 * 4], dword PARAM_TASK_6 + 7  ; Address translation for task 6

    ;-----------------------
    ; Set drawing parameter
    ;-----------------------
    cdecl  memcpy, PARAM_TASK_4, DRAW_PARAM.t4, rose_size
    cdecl  memcpy, PARAM_TASK_5, DRAW_PARAM.t5, rose_size
    cdecl  memcpy, PARAM_TASK_6, DRAW_PARAM.t6, rose_size

    ;-----------------------
    ; Recover registers
    ;-----------------------
    popa

    ret


page_set_4m:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +8 | head of page directory
    push   ebp             ; EBP + 4 | EIP
    mov    ebp, esp        ; EBP + 0 | EBP

    ;-----------------------
    ; Save registers
    ;-----------------------
    pusha

    ;-----------------------
    ; Create page directory (P=0)
    ;-----------------------
    cld                    ; clear DF
    mov    edi, [ebp + 8]  ; EDI = (head of page directory)
    mov    eax, 0x00000000  ; EAX = 0 (P = 0)
    mov    ecx, 1024       ; count = 1024
    rep    stosd           ; while (count--)  *dst++ = attribute

    ;-----------------------
    ; Set head entry
    ;-----------------------
    mov    eax, edi        ; EAX = EDI 
    and    eax, ~0x0000_0FFF  ; EAX &= ~0FFFF  Specify physical address
    or     eax, 7          ; EAX |= 7  Permit RW
    mov    [edi - (1024 * 4)], eax  ; Set head entry

    ;-----------------------
    ; Set page table (linear)
    ;-----------------------
    mov    eax, 0x00000007  ; Specify physical address and permit RW
    mov    ecx, 1024        ; count = 1024

.10L:
    stosd                   ; *dst++ = attribute
    add    eax, 0x00001000  ; adr += 0x1000
    loop   .10L             ; while (--count)

    ;-----------------------
    ; Recover registers
    ;-----------------------
    popa

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret
