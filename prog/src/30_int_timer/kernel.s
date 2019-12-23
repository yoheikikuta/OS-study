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
    ; Initialization
    ;-----------------------
    cdecl  init_int
    cdecl  init_pic

    set_vect 0x00, int_zero_div  ; Register interruption: 0 division
    set_vect 0x20, int_timer  ; Register interruption: timer
    set_vect 0x21, int_keyboard  ; Register interruption: KBC
    set_vect 0x28, int_rtc  ; Register interruption: RTC

    ;-----------------------
    ; Permit device interruption
    ;-----------------------
    cdecl  rtc_int_en, 0x10  ; rtc_int_en(UIE)

    ;-----------------------
    ; Set Interrupt Mask Register
    ;-----------------------
    outp   0x21, 0b_1111_1000  ; Activate interruption: slave PIC/KBC/timer
    outp   0xA1, 0b_1111_1110  ; Activate interruption: RTC

    ;-----------------------
    ; Permit CPU interruption
    ;-----------------------
    sti                    ; Permit interruption

    ;-----------------------
    ; Discplay all fonts
    ;-----------------------
    cdecl  draw_font, 63, 13  ; Display all fonts
    cdecl  draw_color_bar, 63, 4  ; Display color bars

    ;-----------------------
    ; Draw string
    ;-----------------------
    cdecl  draw_str, 25, 14, 0x010F, .s0  ; draw_str()

.10L:
    ;-----------------------
    ; Display time
    ;-----------------------
    mov    eax, [RTC_TIME]  ; Get time
    cdecl  draw_time, 72, 0, 0x0700, eax

    ;-----------------------
    ; Display rotating bar
    ;-----------------------
    cdecl  draw_rotation_bar

    ;-----------------------
    ; Display key code
    ;-----------------------
    cdecl  ring_rd, _KEY_BUFF, .int_key  ; EAX = ring_rd(buff, &int_key)
    cmp    eax, 0  ; if (EAX == 0)
    je     .10E

    cdecl  draw_key, 2, 29, _KEY_BUFF
.10E:
    jmp    .10L

.s0:  db " Hello, kernel! ", 0

.int_key:  dd 0

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
%include "../modules/protect/interrupt.s"
%include "../modules/protect/pic.s"
%include "../modules/protect/int_rtc.s"
%include "../modules/protect/int_keyboard.s"
%include "../modules/protect/ring_buff.s"
%include "modules/int_timer.s"
%include "../modules/protect/timer.s"
%include "../modules/protect/draw_rotation_bar.s"

;***********************
; Padding
;***********************
    times KERNEL_SIZE - ($ - $$) db 0x00  ; padding