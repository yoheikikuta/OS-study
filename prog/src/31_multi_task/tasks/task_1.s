task_1:
    ;-----------------------
    ; Display string
    ;-----------------------
    cdecl  draw_str, 63, 0, 0x07, .s0

    ;-----------------------
    ; Finish task
    ;-----------------------
    iret

    ;-----------------------
    ; Data
    ;-----------------------
.s0:  db "Task-1", 0
