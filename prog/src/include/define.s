SECT_SIZE  equ  (512)  ; Size of sector


; Boot information
BOOT_LOAD  equ  0x7C00  ; Load position of boot program
BOOT_SIZE  equ  (1024 * 8)  ; Size of booot code
BOOT_END   equ  (BOOT_LOAD + BOOT_SIZE)
BOOT_SECT  equ  (BOOT_SIZE / SECT_SIZE)  ; Sector number of boot program


; Memory map information (BIOS-e820 handles memory map)
E820_RECORD_SIZE  equ  20


; Kernel Information
KERNEL_LOAD  equ  0x0010_1000
KERNEL_SIZE  equ  (1024 * 8)  ; kernel size
KERNEL_SECT  equ  (KERNEL_SIZE / SECT_SIZE)


; Stack information (region and its size)
STACK_BASE  equ  0x0010_3000  ; Stack area for task
STACK_SIZE  equ  1024  ; Stack size
SP_TASK_0  equ  STACK_BASE + (STACK_SIZE * 1)
SP_TASK_1  equ  STACK_BASE + (STACK_SIZE * 2)