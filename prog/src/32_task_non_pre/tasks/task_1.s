task_1:
    ;-----------------------
    ; Display string
    ;-----------------------
    cdecl  draw_str, 63, 0, 0x07, .s0

    ;-----------------------
    ; Display time
    ;-----------------------
    mov    eax, [RTC_TIME]
    cdecl  draw_time, 72, 0, 0x700, eax

    ;-----------------------
    ; Call task
    ;-----------------------
    jmp    SS_TASK_0:0     ; inter-segment jump

    jmp    .10L

    ;-----------------------
    ; Finish task
    ;-----------------------
    iret

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db "Task-1", 0
