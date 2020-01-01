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
SP_TASK_2  equ  STACK_BASE + (STACK_SIZE * 3)
SP_TASK_3  equ  STACK_BASE + (STACK_SIZE * 4)
SP_TASK_4  equ  STACK_BASE + (STACK_SIZE * 5)
SP_TASK_5  equ  STACK_BASE + (STACK_SIZE * 6)
SP_TASK_6  equ  STACK_BASE + (STACK_SIZE * 7)

; Physical address task 4~6 access
PARAM_TASK_4  equ  0x0010_8000  ; Drawing parameter for task 4
PARAM_TASK_5  equ  0x0010_9000  ; Drawing parameter for task 5
PARAM_TASK_6  equ  0x0010_A000  ; Drawing parameter for task 6


; Address of page directory
CR3_BASE  equ 0x0010_5000  ; Page translation table for task 3
CR3_TASK_4  equ  0x0020_0000  ; Page translation table for task 4
CR3_TASK_5  equ  0x0020_2000  ; Page translation table for task 5
CR3_TASK_6  equ  0x0020_4000  ; Page translation table for task 6


; FAT information
FAT_SIZE  equ  (1024 * 128)
ROOT_SIZE  equ  (1024 * 16)

FAT1_START  equ  (KERNEL_SIZE)
FAT2_START  equ  (FAT1_START + FAT_SIZE)
ROOT_START  equ  (FAT2_START + FAT_SIZE)
FILE_START  equ  (ROOT_START + ROOT_SIZE)

ATTR_VOLUME_ID  equ  0x08
ATTR_ARCHIVE  equ  0x20