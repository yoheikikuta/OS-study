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
    jmp    ipl

    ;-----------------------
    ; BIOS Parameter Block (BPB)
    ;-----------------------
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
.s0  db "Booting...", 0x0A, 0x0D, 0
.e0  db "Error:sector read", 0

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
; Second stage of boot process
;-----------------------
stage_2:
    ;-----------------------
    ; Print string
    ;-----------------------
    cdecl  puts, .s0

    ;-----------------------
    ; Finish procedure
    ;-----------------------
    jmp    $               ; while (1)

    ;-----------------------
    ; Data
    ;-----------------------
.s0  db "2nd stage...", 0x0A, 0x0D, 0

;-----------------------
; Padding (set this file as 8K bytes)
;-----------------------
    times BOOT_SIZE - ($ - $$) db 0