;***********************
; Macro
;***********************
%include  "../include/define.s"
%include  "../include/macro.s"

    ORG  BOOT_LOAD     ; load address of kernel


[BITS 32]
;***********************
; Entry point
;***********************
kernel:
    ;-----------------------
    ; Get font address
    ;-----------------------
    mov    esi, BOOT_LOAD + SECT_SIZE  ; ESI = 0x7C00 + 512
    movzx  eax, word [esi + 0]  ; EAX = [ESI + 0] segment
    movzx  ebx, word [esi + 2]  ; EBX = [ESI + 2] offset
    shl    eax, 4          ; EAX <<= 4
    add    eax, ebx        ; EAX += EBX
    mov    [FONT_ADR], eax  ; FONT_ADR[0] = EAX

    ;-----------------------
    ; Discplay all fonts
    ;-----------------------
    cdecl  draw_font, 63, 13  ; Display all fonts

    ;-----------------------
    ; Finish procedure
    ;-----------------------
    jmp    $               ; while (1)

ALIGN 4, db 0
FONT_ADR: dd 0


;***********************
; Modules
;***********************
%include  "../modules/protect/vga.s"
%include  "../modules/protect/draw_char.s"
%include  "../modules/protect/draw_font.s"


;***********************
; Padding
;***********************
    times KERNEL_SIZE - ($ - $$) db 0  ; padding