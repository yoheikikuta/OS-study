int_en_timer0:
    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax

    ;-----------------------
    ; Timer
    ;-----------------------
    outp   0x43, 0b_00_11_010_0  ; counter-0, lower->upper access, mode-2, binary
    outp   0x40, 0x9C      ; 0x2e9c = 11,932 [HZ] = 10 [msec] for 1,193,182 [HZ] clock
    outp   0x40, 0x2E

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    eax

    ret