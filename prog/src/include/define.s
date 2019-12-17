    BOOT_LOAD  equ  0x7C00  ; Load position of boot program
    BOOT_SIZE  equ  (1024 * 8)  ; Size of booot code
    BOOT_END   equ  (BOOT_LOAD + BOOT_SIZE)
    SECT_SIZE  equ  (512)  ; Size of sector
    BOOT_SECT  equ  (BOOT_SIZE / SECT_SIZE)  ; Sector number of boot program

    E820_RECORD_SIZE  equ  20

    KERNEL_LOAD  equ  0x0010_1000
    KERNEL_SIZE  equ  (1024 * 8)  ; kernel size
    KERNEL_SECT  equ  (KERNEL_SIZE / SECT_SIZE)