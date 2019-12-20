draw_line:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +24 | color
                           ; +20 | Y_end
                           ; +16 | X_end
                           ; +12 | Y_start
                           ; +8 | X_start
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    push   dword 0         ; -4 | sum = 0
    push   dword 0         ; -8 | x_start = 0
    push   dword 0         ; -12 | dx = 0
    push   dword 0         ; -16 | inc_x = 0  1 or -1
    push   dword 0         ; -20 | y_0 = 0
    push   dword 0         ; -24 | dy = 0
    push   dword 0         ; -18 | inc_y = 0  1 or -1

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx
    push   ecx
    push   edx
    push   esi
    push   edi

    ;-----------------------
    ; Compute width (X axis)
    ;-----------------------
    mov    eax, [ebp + 8]
    mov    ebx, [ebp + 16]
    sub    ebx, eax
    jge    .10F            ; if (width < 0)

    neg    ebx
    mov    esi, -1
    jmp    .10E
.10F:
    mov    esi, 1
.10E:

    ;-----------------------
    ; Compute height (Y axis)
    ;-----------------------
    mov    ecx, [ebp + 12]
    mov    edx, [ebp + 20]
    sub    edx, ecx
    jge    .20F            ; if (height < 0)

    neg    edx
    mov    edi, -1
    jmp    .20E
.20F:
    mov    edi, 1
.20E:

    ;-----------------------
    ; X axis
    ;-----------------------
    mov    [ebp - 8], eax  ; x_start
    mov    [ebp - 12], ebx  ; dx
    mov    [ebp - 16], esi  ; inc_x

    ;-----------------------
    ; Y axis
    ;-----------------------
    mov    [ebp - 20], ecx  ; y_start
    mov    [ebp - 24], edx  ; dy
    mov    [ebp - 28], edi  ; inc_y

    ;-----------------------
    ; Decide reference axis
    ;-----------------------
    cmp    ebx, edx
    jg     .22F            ; if (width <= height)

    lea    esi, [ebp - 20]  ; X: referene axis
    lea    edi, [ebp - 8]  ; Y: relative axis

    jmp    .22E
.22F:
    lea    esi, [ebp - 8]  ; Y: reference axis
    lea    edi, [ebp - 20]  ; X: relative axis
.22E:

    ;-----------------------
    ; Repeat number (dot number of reference axis)
    ;-----------------------
    mov    ecx, [esi - 4]
    cmp    ecx, 0
    jnz    .30E
    mov    ecx, 1
.30E:

    ;-----------------------
    ; Draw line
    ;-----------------------
.50L:
    cdecl  draw_pixel, dword [ebp - 8], dword [ebp - 20], dword [ebp + 24]

    mov    eax, [esi - 8]
    add    [esi - 0], eax

    mov    eax, [ebp - 4]
    add    eax, [edi - 4]
    mov    ebx, [esi - 4]

    cmp    eax, ebx
jl .52E
    sub    eax, ebx

    mov    ebx, [edi - 8]
    add    [edi - 0], ebx
.52E:
    mov    [ebp - 4], eax

    loop   .50L
.50E:

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
    mov    esp, ebp
    pop    ebp

    ret

.s0:  db  '        ', 0
.t0:  dw  0x0000, 0x0800
      dw  0x0100, 0x0900
      dw  0x0200, 0x0A00
      dw  0x0300, 0x0B00
      dw  0x0400, 0x0C00
      dw  0x0500, 0x0D00
      dw  0x0600, 0x0E00
      dw  0x0700, 0x0F00
