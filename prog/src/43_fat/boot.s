;***********************
; Macro
;***********************
%include  "../include/define.s"
%include  "../include/macro.s"

    ORG  BOOT_LOAD     ; Tell load address to assembler


;***********************
; Entry point
;***********************
entry:
    ;-----------------------
    ; BIOS Parameter Block (BPB)
    ;-----------------------
    jmp    ipl             ; 0x00( 2)  JMP instruction to boot code
    times  3 - ($ - $$) db 0x90
    db     'OEM-NAME'      ; 0x03( 8)  OEM name

    dw     512             ; 0x0B( 2)  Byte number of sector
    db     1               ; 0x0D( 1)  Sector number of cluster 
    dw     32              ; 0x0E( 2)  Reserved sector number 
    db     2               ; 0x10( 1)  FAT number
    dw     512             ; 0x11( 2)  Root entry number
    dw     0xFFF0          ; 0x13( 2)  Total sector number 16 
    db     0xF8            ; 0x15( 1)  Media type 
    dw     256             ; 0x16( 2)  Sector number of FAT
    dw     0x10            ; 0x18( 2)  Sector numebr of track 
    dw     2               ; 0x1A( 2)  Head number
    dd     0               ; 0x1C( 4)  Hidden sector number

    dd     0               ; 0x20( 4)  Total sector numebr 32
    db     0x80            ; 0x24( 1)  Drive number
    db     0               ; 0x25( 1)  Reserved
    db     0x29            ; 0x26( 1)  Boot flag
    dd     0xbeef          ; 0x27( 4)  Serial number
    db     'BOOTABLE   '   ; 0x2B(11)  Volume label
    db     'FAT16   '      ; 0x36( 8)  FAT type

    ;-----------------------
    ; Initial Program Loader (IPL)
    ;-----------------------
ipl:
    cli                    ; Forbid interruption

    mov    ax, 0x0000      ; AX = 0x0000
    mov    ds, ax          ; DS = 0x0000
    mov    es, ax          ; ES = 0x0000
    mov    ss, ax          ; SS = 0x0000
    mov    sp, BOOT_LOAD   ; SP = 0x7C00

    sti                    ; Allow interruption

    mov    [BOOT + drive.no], dl  ; Save boot drive

    ;-----------------------
    ; Print characters
    ;-----------------------
    cdecl  puts, .s0

    ;-----------------------
    ; Read all rest of sectors
    ;-----------------------
    mov    bx, BOOT_SECT - 1  ; BX = (number of the rest of sectors)
    mov    cx, BOOT_LOAD + SECT_SIZE  ; CX = (netx load address)

    cdecl  read_chs, BOOT, bx, cx  ; AX = read_chs(.chs, bx, cx)

    cmp    ax, bx          ; if (AX != (number of the rest of sector))
.10Q:  jz     .10E
.10T:  cdecl  puts, .e0
    call    reboot
.10E:

    ;-----------------------
    ; Move to next stage
    ;-----------------------
    jmp    stage_2

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db "Booting...", 0x0A, 0x0D, 0
.e0:  db "Error:sector read", 0

;=======================
; Information of boot drive
;=======================
ALIGN 2, db 0
BOOT:                      ; Information about boot drive
  istruc drive
    at  drive.no,    dw 0  ; drive number
    at  drive.cyln,  dw 0  ; C - cylinder
    at  drive.head,  dw 0  ; H - head
    at  drive.sect,  dw 2  ; S - sector
  iend

;=======================
; Modules
;=======================
%include  "../modules/real/puts.s"
%include  "../modules/real/reboot.s"
%include  "../modules/real/read_chs.s"

;=======================
; Boot flag
;=======================
    times  510 - ($ - $$) db 0x00
    db 0x55, 0xAA

;=======================
; Information obtained in real mode
;=======================
FONT:                  ; font
.seg: dw 0
.off: dw 0
ACPI_DATA:             ; ACPI data
.adr: dd 0             ; ACPI data address
.len: dd 0             ; ACPI data length

;=======================
; Modules  (After head 512 bytes)
;=======================
%include  "../modules/real/itoa.s"
%include  "../modules/real/get_drive_param.s"
%include  "../modules/real/get_font_adr.s"
%include  "../modules/real/get_mem_info.s"
%include  "../modules/real/kbc.s"
%include  "../modules/real/read_lba.s"


;***********************
; Second stage of boot process
;***********************
stage_2:
    ;-----------------------
    ; Print string
    ;-----------------------
    cdecl  puts, .s0

    ;-----------------------
    ; Get drive information
    ;-----------------------
    cdecl  get_drive_param, BOOT  ; get_drive_param(DX, BOOT.CYLN)
    cmp    ax, 0            ; if (0 == AX)
.10Q:  jne    .10E
.10T:  cdecl  puts, .e0
    call   reboot
.10E:

    ;-----------------------
    ; Show drive information
    ;-----------------------
    mov    ax, [BOOT + drive.no]
    cdecl  itoa, ax, .p1, 2, 16, 0b0100
    mov    ax, [BOOT + drive.cyln]
    cdecl  itoa, ax, .p2, 4, 16, 0b0100
    mov    ax, [BOOT + drive.head]
    cdecl  itoa, ax, .p3, 2, 16, 0b0100
    mov    ax, [BOOT + drive.sect]
    cdecl  itoa, ax, .p4, 2, 16, 0b0100
    cdecl  puts, .s1

    ;-----------------------
    ; Move to next stage
    ;-----------------------
    jmp    stage_3         ; Move to the next stage

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db "2nd stage...", 0x0A, 0x0D, 0
.s1:  db " Drive:0x"
.p1:  db "XX, C:0x"
.p2:  db "XXXX, H:0x"
.p3:  db "XX, S:0x"
.p4:  db "XX", 0x0A, 0x0D, 0

.e0:  db "Can't get drive parameters.", 0


;***********************
; Third stage of boot process
;***********************
stage_3:
    ;-----------------------
    ; Print string
    ;-----------------------
    cdecl  puts, .s0

    ;-----------------------
    ; Use BIOS' font in protect mode
    ;-----------------------
    cdecl  get_font_adr, FONT  ; Get BIOS' font address

    ;-----------------------
    ; Print font address
    ;-----------------------
    cdecl  itoa, word [FONT.seg], .p1, 4, 16, 0b0100
    cdecl  itoa, word [FONT.off], .p2, 4, 16, 0b0100
    cdecl  puts, .s1

    ;-----------------------
    ; Get and pring memory info.
    ;-----------------------
    cdecl  get_mem_info    ; get_mem_info()

    mov    eax, [ACPI_DATA.adr]  ; EAX = ACPI_DATA.adr
    cmp    eax, 0          ; if (EAX)
    je     .10E

    cdecl  itoa, ax, .p4, 4, 16, 0b0100  ; itoa(AX)
    shr    eax, 16         ; EAX >>= 16
    cdecl  itoa, ax, .p3, 4, 16, 0b0100  ; itoa(AX)

    cdecl  puts, .s2       ; puts(.s2)
.10E:

    ;-----------------------
    ; Move to next stage
    ;-----------------------
    jmp    stage_4         ; Move to the next stage

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db "3rd stage...", 0x0A, 0x0D, 0

.s1: db " Font Address="
.p1: db "ZZZZ:"
.p2: db "ZZZZ", 0x0A, 0x0D, 0
    db 0x0A, 0x0D, 0

.s2: db " ACPI data="
.p3: db "ZZZZ"
.p4: db "ZZZZ", 0x0A, 0x0D, 0

;***********************
; Fourth stage of boot process
;***********************
stage_4:
    ;-----------------------
    ; Print string
    ;-----------------------
    cdecl  puts, .s0

    ;-----------------------
    ; Activate A20 gate
    ;-----------------------
    cli                    ; Forbit interruption

    cdecl  KBC_Cmd_Write, 0xAD  ; Deactivate keyboard

    cdecl  KBC_Cmd_Write, 0xD0  ; Cmd of reading output port
    cdecl  KBC_Data_Read, .key  ; output port data

    mov    bl, [.key]      ; BL = key
    or     bl, 0x02        ; BL |= 0x02

    cdecl  KBC_Cmd_Write, 0xD1  ; Cmd of writing output port
    cdecl  KBC_Data_Read, bx   ; output port data

    cdecl  KBC_Cmd_Write, 0xAE  ; Activate keyboard

    sti                    ; Allow interruption

    ;-----------------------
    ; Print string
    ;-----------------------
    cdecl  puts, .s1

    ;-----------------------
    ; Test keyboard LED
    ;-----------------------
    cdecl  puts, .s2

    mov    bx, 0           ; BX = (initial value of LED)
.10L:
    mov    ah, 0x00        ; Wait keyboard interruption
    int    0x16,           ; AL = BIOS(0x16, 0x00)

    cmp    al, '1'         ; if (AL < '1')
    jb     .10E            ; break

    cmp    al, '3'         ; if ('3' < AL)
    ja     .10E            ; break

    mov    cl, al          ; CL = (keyboard input)
    dec    cl              ; CL--
    and    cl, 0x03        ; CL &= 0x03 (Consider only 0 ~ 2)
    mov    ax, 0x0001      ; AX = 0x0001
    shl    ax, cl          ; AX <<= CL
    xor    bx, ax          ; BX ^= AX

    ;-----------------------
    ; Send LED commands
    ;-----------------------
    cli                    ; Forbit interruption

    cdecl  KBC_Cmd_Write, 0xAD  ; Deactivate keyboard
    cdecl  KBC_Data_Write, 0xED  ; LED command
    cdecl  KBC_Data_Read, .key  ; Receive to command

    cmp    [.key], byte 0xFA  ; if (0xFA == key)
    jne    .11F

    cdecl  KBC_Data_Write, bx   ; Output LED data

    jmp    .11E            ; else
.11F:
    cdecl  itoa, word [.key], .e1, 2, 16, 0b0100
    cdecl  puts, .e0       ; Display recieved code
.11E:
    cdecl  KBC_Cmd_Write, 0xAE  ; Activate keyboard

    sti                    ; Allow interruption

    jmp    .10L            ; while (1)
.10E:

    ;-----------------------
    ; Print strings
    ;-----------------------
    cdecl  puts, .s3

    ;-----------------------
    ; Move to next stage
    ;-----------------------
    jmp    stage_5         ; Move to the next stage

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db "4th stage...", 0x0A, 0x0D, 0
.s1:  db "A20 Gate Enabled.", 0x0A, 0x0D, 0
.s2:  db " Keyboard LED Test...", 0
.s3:  db " (done)", 0x0A, 0x0D, 0
.e0:  db "["
.e1:  db "ZZ]", 0

.key:  dw 0


;***********************
; Fifth stage of boot process
;***********************
stage_5:
    ;-----------------------
    ; Print string
    ;-----------------------
    cdecl  puts, .s0

    ;-----------------------
    ; Read kernel
    ;-----------------------
    cdecl  read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END  ; AX = read_lba(.lba, ...)
    cmp    ax, KERNEL_SECT  ; if (AX != CX)
.10Q:  jz     .10E
.10T:  cdecl  puts, .e0
       call   reboot
.10E:

    ;-----------------------
    ; Move to next stage
    ;-----------------------
    jmp    stage_6         ; Move to the next stage

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db "5th stage...", 0x0A, 0x0D, 0
.e0:  db "Failure load kernel...", 0x0A, 0x0D, 0


;***********************
; Sixth stage of boot process
;***********************
stage_6:
    ;-----------------------
    ; Print string
    ;-----------------------
    cdecl  puts, .s0

    ;-----------------------
    ; Wait user input
    ;-----------------------
.10L:                      ; do
    mov    ah, 0x00        ; Wait keyboard input
    int    0x16            ; AL = BIOS(0x16, 0x00)
    cmp    al, ' '         ; ZF = AL == ' '
    jne    .10L            ; while (!ZF)

    ;-----------------------
    ; Set video mode
    ;-----------------------
    mov    ax, 0x0012      ; VGA 640x480
    int    0x10            ; BIOS(0x10, 0x12)  Set video mode

    ;-----------------------
    ; Move to next stage
    ;-----------------------
    jmp    stage_7         ; Move to the next stage

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db "6th stage...", 0x0A, 0x0D, 0x0A, 0x0D
      db "[Push SPACE key to move to protect mode...]", 0x0A, 0x0D, 0


;***********************
; GLOBAL DESCRIPTOR TABLE
;***********************
ALIGN 4, db 0
GDT:  dq 0x00_0_0_0_0_000000_0000  ; NULL
.cs:  dq 0x00_C_F_9_A_000000_FFFF  ; CODE 4G
.ds:  dq 0x00_C_F_9_2_000000_FFFF  ; DATA 4G
.gdt_end:

;=======================
; Selectors
;=======================
SEL_CODE  equ .cs - GDT  ; Selector for code
SEL_DATA  equ .ds - GDT  ; Selector for data

;=======================
; GDT
;=======================
GDTR:  dw GDT.gdt_end - GDT - 1  ; Limit of descriptor table
    dd     GDT         ; Address of descriptor table

;=======================
; IDT (pseudo table to forbid intreruption)
;=======================
IDTR:  dw 0            ; Limit of IDT
    dd     0           ; Address of IDT


;***********************
; Seventh stage of boot process
;***********************
stage_7:
    cli                    ; Forbid interruption

    ;-----------------------
    ; Load GDT
    ;-----------------------
    lgdt   [GDTR]          ; Load global descriptor table
    lidt   [IDTR]          ; Load interruption descriptor table

    ;-----------------------
    ; Move to protect mode
    ;-----------------------
    mov    eax, cr0        ; Set PE Booting
    or     ax, 1           ; CR0 |= 1
    mov    cr0, eax

    jmp    $ + 2           ; Clear prefetched instructions

    ;-----------------------
    ; Jump between segments
    ;-----------------------
[BITS 32]
    DB     0x66            ; Operand size override prefix
    jmp    SEL_CODE:CODE_32

;***********************
; Start 32 bit code
;***********************
CODE_32:

    ;-----------------------
    ; Initialize selectors
    ;-----------------------
    mov    ax, SEL_DATA
    mov    ds, ax
    mov    es, ax
    mov    fs, ax
    mov    gs, ax
    mov    ss, ax

    ;-----------------------
    ; Copy kernel part
    ;-----------------------
    mov    ecx, (KERNEL_SIZE) / 4  ; ECX = (copy in 4 bytes unit)
    mov    esi, BOOT_END   ; ESI = 0x0000_9C00 (kernel part)
    mov    edi, KERNEL_LOAD  ; EDI = 0x0010_1000 (upper part memory)
    cld                    ; Clear DF
    rep    movsd           ; while (--ECX) *EDI++ = *ESI++

    ;-----------------------
    ; Move to kernel processing
    ;-----------------------
    jmp    KERNEL_LOAD


;***********************
; Padding (set this file as 8K bytes)
;***********************
    times BOOT_SIZE - ($ - $$) db 0