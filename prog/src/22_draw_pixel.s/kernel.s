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
    ; Draw color bar
    ;-----------------------
    cdecl  draw_color_bar, 63, 4  ; draw_color_bar

    ;-----------------------
    ; Draw pixels
    ;-----------------------
    cdecl  draw_pixel, 8, 4, 0x01
    cdecl  draw_pixel, 9, 5, 0x01
    cdecl  draw_pixel, 10, 6, 0x02
    cdecl  draw_pixel, 11, 7, 0x02
    cdecl  draw_pixel, 12, 8, 0x03
    cdecl  draw_pixel, 13, 9, 0x03
    cdecl  draw_pixel, 14, 10, 0x04
    cdecl  draw_pixel, 15, 11, 0x04

    cdecl  draw_pixel, 15, 4, 0x03
    cdecl  draw_pixel, 14, 5, 0x03
    cdecl  draw_pixel, 13, 6, 0x04
    cdecl  draw_pixel, 12, 7, 0x04
    cdecl  draw_pixel, 11, 8, 0x01
    cdecl  draw_pixel, 10, 9, 0x01
    cdecl  draw_pixel, 9, 10, 0x02
    cdecl  draw_pixel, 8, 11, 0x02

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


;***********************
; Padding
;***********************
    times KERNEL_SIZE - ($ - $$) db 0  ; padding