init_pic:
    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax

    ;-----------------------
    ; Master settings
    ;-----------------------
    outp   0x20, 0x11      ; MASTER.ICW1 = 0x11
    outp   0x21, 0x20      ; MASTER.ICW2 = 0x20  This tells CPU as 0x28 is base master PIC interrupt vector
    outp   0x21, 0x04      ; MASTER.ICW3 = 0x04
    outp   0x21, 0x05      ; MASTER.ICW4 = 0x05
    outp   0x21, 0xFF      ; Master interruption mask

    ;-----------------------
    ; Slave settings
    ;-----------------------
    outp   0xA0, 0x11      ; SLAVE.ICW1 = 0x11
    outp   0xA1, 0x28      ; SLAVE.ICW2 = 0x28  This tells CPU as 0x28 is base slave PIC interrupt vector
    outp   0xA1, 0x02      ; SLAVE.ICW3 = 0x02
    outp   0xA1, 0x01      ; SLAVE.ICW4 = 0x01
    outp   0xA1, 0xFF      ; Slave interruption mask

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    eax

    ret
