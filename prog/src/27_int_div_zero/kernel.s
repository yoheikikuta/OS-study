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
    ; Initialize interruption vector
    ;-----------------------
    cdecl  init_int
    set_vect 0x00, int_zero_div  ; Register interruption: 0 division

    ;-----------------------
    ; Discplay all fonts
    ;-----------------------
    cdecl  draw_font, 63, 13  ; Display all fonts
    cdecl  draw_color_bar, 63, 4  ; Display color bars

    ;-----------------------
    ; Draw string
    ;-----------------------
    cdecl  draw_str, 25, 14, 0x010F, .s0  ; draw_str()

    ;-----------------------
    ; Zero division
    ;-----------------------
    mov    al, 0           ; AL = 0
    div    al              ; Zero division

    ;-----------------------
    ; Display time
    ;-----------------------
.10L:
    cdecl  rtc_get_time, RTC_TIME  ; EAX = get_time(&RTC_TIME)
    cdecl  draw_time, 72, 0, 0x0700, dword [RTC_TIME]
    jmp    .10L

    ;-----------------------
    ; Finish procedure
    ;-----------------------
    jmp    $               ; while (1)

.s0:  db " Hello, kernel! ", 0

ALIGN 4, db 0
FONT_ADR:  dd 0
RTC_TIME:  dd 0


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
%include "../modules/protect/draw_rect.s"
%include "../modules/protect/itoa.s"
%include "../modules/protect/rtc.s"
%include "../modules/protect/draw_time.s"
%include "modules/interrupt.s"


;***********************
; Padding
;***********************
    times KERNEL_SIZE - ($ - $$) db 0  ; padding