    BOOT_LOAD  equ  0x7C00  ; Load position of boot program

    BOOT_SIZE  equ  (1024 * 8)  ; Size of booot code
    SECT_SIZE  equ  (512)  ; Size of sector
    BOOT_SECT  equ  (BOOT_SIZE / SECT_SIZE)  ; Sector number of boot program