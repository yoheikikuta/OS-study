    BOOT_LOAD  equ  0x7C00
    ORG  BOOT_LOAD

;-----------------------
; Macro
;-----------------------
%include  "../include/macro.s"

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

    mov    [BOOT.DRIVE], dl  ; Save boot drive

    ;-----------------------
    ; Print characters
    ;-----------------------
    cdecl  puts, .s0

    ;-----------------------
    ; Read following 512 bytes
    ;-----------------------
    mov    ah, 0x02        ; AH = (reading instruction)
    mov    al, 1           ; AL = (reading sector number)
    mov    cx, 0x0002      ; CX = (cylinder | sector)
    mov    dh, 0x00        ; DH = (head position)
    mov    dl, [BOOT.DRIVE]  ; DL = (drive number)
    mov    bx, 0x7C00 + 512  ; BX = (offset)
    int    0x13            ; if (CF = BIOS(0x13, 0x02))
.10Q:  jnc    .10E
.10T:  cdecl  puts, .e0
    call   reboot
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

ALIGN 2, db 0
BOOT:                      ; Information about boot drive
.DRIVE:     dw 0           ; drive number

;-----------------------
; Modules
;-----------------------
%include  "../modules/real/puts.s"
%include  "../modules/real/itoa.s"
%include  "../modules/real/reboot.s"

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
    times (1024 * 8) - ($ - $$) db 0