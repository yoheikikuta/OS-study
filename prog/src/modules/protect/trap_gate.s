trap_gate_81:
    ; This is called by INT, so iret is required
    ;-----------------------
    ; Draw one character
    ;-----------------------
    cdecl  draw_char, ecx, edx, ebx, eax

    iret


trap_gate_82:
    ; This is called by INT, so iret is required
    ;-----------------------
    ; Draw pixels
    ;-----------------------
    cdecl  draw_pixel, ecx, edx, ebx

    iret