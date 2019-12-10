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
    cli                    ;Forbid interruption

    mov    ax, 0x0000
    mov    ds, ax
    mov    es, ax
    mov    ss, ax
    mov    sp, BOOT_LOAD

    sti                    ;Allow interruption

    mov    [BOOT.DRIVE], dl

    ;-----------------------
    ; Print characters
    ;-----------------------
    cdecl  putc, word 'X'
    cdecl  putc, word 'Y'
    cdecl  putc, word 'Z'

    ;-----------------------
    ; Finish procedure
    ;-----------------------
    jmp    $

ALIGN 2, db 0
BOOT:
.DRIVE:     dw 0

;-----------------------
; Modules
;-----------------------
%include  "../modules/real/putc.s"

;-----------------------
; Boot flag
;-----------------------
    times  510 - ($ - $$) db 0x00
    db 0x55, 0xAA