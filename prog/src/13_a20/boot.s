;-----------------------
; Macro
;-----------------------
%include  "../include/define.s"
%include  "../include/macro.s"

    ORG  BOOT_LOAD     ; Tell load address to assembler


;-----------------------
; Entry point
;-----------------------
entry:
    ;-----------------------
    ; BIOS Parameter Block (BPB)
    ;-----------------------
    jmp    ipl
    times  90 - ($ - $$) db 0x90

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


;-----------------------
; Information of boot drive
;-----------------------
ALIGN 2, db 0
BOOT:                      ; Information about boot drive
  istruc drive
    at  drive.no,    dw 0  ; drive number
    at  drive.cyln,  dw 0  ; C - cylinder
    at  drive.head,  dw 0  ; H - head
    at  drive.sect,  dw 2  ; S - sector
  iend


;-----------------------
; Modules
;-----------------------
%include  "../modules/real/puts.s"
%include  "../modules/real/reboot.s"
%include  "../modules/real/read_chs.s"


;-----------------------
; Boot flag
;-----------------------
    times  510 - ($ - $$) db 0x00
    db 0x55, 0xAA


;-----------------------
; Information obtained in real mode
;-----------------------
FONT:                  ; font
.seg: dw 0
.off: dw 0
ACPI_DATA:             ; ACPI data
.adr: dd 0             ; ACPI data address
.len: dd 0             ; ACPI data length


;-----------------------
; Modules  (After head 512 bytes)
;-----------------------
%include  "../modules/real/itoa.s"
%include  "../modules/real/get_drive_param.s"
%include  "../modules/real/get_font_adr.s"
%include  "../modules/real/get_mem_info.s"
%include  "../modules/real/kbc.s"


;-----------------------
; Second stage of boot process
;-----------------------
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


;-----------------------
; Third stage of boot process
;-----------------------
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

;-----------------------
; Fourth stage of boot process
;-----------------------
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
    ; Finish procedure
    ;-----------------------
    jmp    $                ; while (1)

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db "4th stage...", 0x0A, 0x0D, 0
.s1:  db "A20 Gate Enabled.", 0x0A, 0x0D, 0

.key:  dw 0


;-----------------------
; Padding (set this file as 8K bytes)
;-----------------------
    times BOOT_SIZE - ($ - $$) db 0