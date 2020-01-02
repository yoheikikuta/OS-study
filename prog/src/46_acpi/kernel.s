;***********************
; Macro
;***********************
%define  USE_SYSTEM_CALL
%define  USE_TEST_AND_SET
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
    ; Set TSS descriptor
    ;-----------------------
    set_desc  GDT.tss_0, TSS_0  ; TSS setting for taks 0
    set_desc  GDT.tss_1, TSS_1  ; TSS setting for taks 1
    set_desc  GDT.tss_2, TSS_2  ; TSS setting for taks 2
    set_desc  GDT.tss_3, TSS_3  ; TSS setting for taks 3
    set_desc  GDT.tss_4, TSS_4  ; TSS setting for taks 4
    set_desc  GDT.tss_5, TSS_5  ; TSS setting for taks 5
    set_desc  GDT.tss_6, TSS_6  ; TSS setting for taks 6

    ;-----------------------
    ; Set call gate
    ;-----------------------
    set_gate  GDT.call_gate, call_gate

    ;-----------------------
    ; Set LDT
    ;-----------------------
    set_desc  GDT.ldt, LDT, word LDT_LIMIT

    ;-----------------------
    ; Load GDT
    ;-----------------------
    lgdt  [GDTR]

    ;-----------------------
    ; Set stack
    ;-----------------------
    mov    esp, SP_TASK_0  ; Set stack for taks 0

    ;-----------------------
    ; Initialize task register
    ;-----------------------
    mov    ax, SS_TASK_0
    ltr    ax              ; Set task register

    ;-----------------------
    ; Initialization
    ;-----------------------
    cdecl  init_int
    cdecl  init_pic
    cdecl  init_page

    set_vect 0x00, int_zero_div  ; Register interruption: 0 division
    set_vect 0x07, int_nm  ; Register interruption: Unable to use device
    set_vect 0x0E, int_pf  ; Register interruption: page fault
    set_vect 0x20, int_timer  ; Register interruption: timer
    set_vect 0x21, int_keyboard  ; Register interruption: KBC
    set_vect 0x28, int_rtc  ; Register interruption: RTC
    set_vect 0x81, trap_gate_81, word 0xEF00  ; Register trap gate: draw one character
    set_vect 0x82, trap_gate_82, word 0xEF00  ; Register trap gate: draw pixels

    ;-----------------------
    ; Permit device interruption
    ;-----------------------
    cdecl  rtc_int_en, 0x10  ; rtc_int_en(UIE)
    cdecl  int_en_timer0     ; Permit timer iterruption

    ;-----------------------
    ; Set Interrupt Mask Register
    ;-----------------------
    outp   0x21, 0b_1111_1000  ; Activate interruption: slave PIC/KBC/timer
    outp   0xA1, 0b_1111_1110  ; Activate interruption: RTC

    ;-----------------------
    ; Enable paging
    ;-----------------------
    mov    eax, CR3_BASE
    mov    cr3, eax        ; Register page table

    mov    eax, cr0        ; Set PG bit
    or     eax, (1 << 31)  ; CR0 |= PG
    mov    cr0, eax
    jmp    $ + 2           ; FLUSH()

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

    ;-----------------------
    ; Procedure when key is pushed
    ;-----------------------
    mov    al, [.int_key]  ; AL = [.int_key]
    cmp    al, 0x02        ; if ('1' == AL)
    jne    .12E

    ;-----------------------
    ; Read file
    ;-----------------------
    call   [BOOT_LOAD + BOOT_SIZE - 16]

    ;-----------------------
    ; Display contents of file
    ;-----------------------
    mov    esi, 0x7800     ; ESI = (address)
    mov    [esi + 32], byte 0  ; [ESI + 32] = 0  Maximum 32 characters
    cdecl  draw_str, 0, 0, 0x0F04, esi  ; draw_str()

.12E:
    ;-----------------------
    ; F1 + F2 + F3 key
    ;-----------------------
    mov    al, [.int_key]  ; AL = [.int_key]  Key code
    cdecl  f1_f2_f3, eax  ; EAX = f1_f2_f3(key code)
    cmp    eax, 0          ; if (0 != EAX)
    je     .14E

    mov    eax, 0          ; Power off procedure is done only once
    bts    [.once], eax    ; if (0 == bts(.once))
    jc     .14E
    cdecl  power_off       ; power_off()

.14E:
.10E:
    jmp    .10L

.s0:  db " Hello, kernel! ", 0
.int_key:  dd 0
.once:  dd 0

ALIGN 4, db 0

FONT_ADR:  dd 0
RTC_TIME:  dd 0


;***********************
; Tasks
;***********************
%include  "descriptor.s"
%include  "modules/int_timer.s"
%include  "modules/int_pf.s"
%include  "modules/paging.s"
%include  "tasks/task_1.s"
%include  "tasks/task_2.s"
%include  "tasks/task_3.s"


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
%include "../modules/protect/timer.s"
%include "../modules/protect/draw_rotation_bar.s"
%include "../modules/protect/call_gate.s"
%include "../modules/protect/trap_gate.s"
%include "../modules/protect/test_and_set.s"
%include "../modules/protect/int_nm.s"
%include "../modules/protect/wait_tick.s"
%include "../modules/protect/memcpy.s"
%include "../modules/protect/f1_f2_f3.s"
%include "../modules/protect/power_off.s"
%include "../modules/protect/acpi_find.s"
%include "../modules/protect/find_rsdt_entry.s"
%include "../modules/protect/acpi_package_value.s"


;***********************
; Padding
;***********************
    times KERNEL_SIZE - ($ - $$) db 0x00  ; padding


;***********************
; FAT
;***********************
%include "fat.s"