task_1:
    ;-----------------------
    ; Display string
    ;-----------------------
    cdecl  SS_GATE_0:0, 63, 0, 0x07, .s0  ; draw_str()

.10L:
    ;-----------------------
    ; Display time
    ;-----------------------
;;; comment out
;    mov    eax, [RTC_TIME]
;    cdecl  draw_time, 72, 0, 0x700, eax
;;;

    jmp    .10L

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db "Task-1", 0
