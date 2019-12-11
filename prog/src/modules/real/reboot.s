reboot:
    ;-----------------------
    ; Display message
    ;-----------------------
    cdecl  puts, .s0       ; Display rebooting massege

    ;-----------------------
    ; Wait key input
    ;-----------------------
.10L:

    mov    ah, 0x10
    int    0x16            ; AL = BIOS(0x16, 0x10)

    cmp    al, ' '          ; ZF = AL == ' ' (here space is used to reboot)
    jne    .10L

    ;-----------------------
    ; Print line break
    ;-----------------------
    cdecl  puts, .s1       ; line break

    ;-----------------------
    ; Reboot
    ;-----------------------
    int    0x19            ; BIOS(0x19)

    ;-----------------------
    ; String data
    ;-----------------------
.s0  db 0x0A, 0x0D, "Push SPACE key to reboot...", 0
.s1  db 0x0A, 0x0D, 0x0A, 0x0D, 0