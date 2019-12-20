;***********************
; Macro
;***********************
%include  "../include/define.s"
%include  "../include/macro.s"

    ORG  KERNEL_LOAD     ; load address of kernel


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
    ; Draw string
    ;-----------------------
    cdecl  draw_str, 25, 14, 0x010F, .s0  ; draw_str()

    ;-----------------------
    ; Draw lines
    ;-----------------------
    cdecl  draw_line, 100, 100, 0, 0, 0x0F
    cdecl  draw_line, 100, 100, 200, 0, 0x0F
    cdecl  draw_line, 100, 100, 200, 200, 0x0F
    cdecl  draw_line, 100, 100, 0, 200, 0x0F

    cdecl  draw_line, 100, 100, 50, 0, 0x02
    cdecl  draw_line, 100, 100, 150, 0, 0x03
    cdecl  draw_line, 100, 100, 150, 200, 0x04
    cdecl  draw_line, 100, 100, 50, 200, 0x05

    cdecl  draw_line, 100, 100, 0, 50, 0x02
    cdecl  draw_line, 100, 100, 200, 50, 0x03
    cdecl  draw_line, 100, 100, 200, 150, 0x04
    cdecl  draw_line, 100, 100, 0, 150, 0x05

    cdecl  draw_line, 100, 100, 100, 0, 0x0F
    cdecl  draw_line, 100, 100, 200, 100, 0x0F
    cdecl  draw_line, 100, 100, 100, 200, 0x0F
    cdecl  draw_line, 100, 100, 0, 100, 0x0F

    ;-----------------------
    ; Finish procedure
    ;-----------------------
    jmp    $               ; while (1)

.s0:  db " Hello, kernel! ", 0

ALIGN 4, db 0
FONT_ADR: dd 0


;***********************
; Modules
;***********************
%include "../modules/protect/vga.s"
%include "../modules/protect/draw_char.s"
%include "../modules/protect/draw_font.s"
%include "../modules/protect/draw_str.s"
%include "../modules/protect/draw_color_bar.s"
%include "../modules/protect/draw_pixel.s"
%include "../modules/protect/draw_line.s"


;***********************
; Padding
;***********************
    times KERNEL_SIZE - ($ - $$) db 0  ; padding