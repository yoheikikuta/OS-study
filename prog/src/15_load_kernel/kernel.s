;-----------------------
; Macro
;-----------------------
%include  "../include/define.s"
%include  "../include/macro.s"

    ORG  KERNEL_LOAD     ; load address of kernel

[BITS 32]
;-----------------------
; Entry point
;-----------------------
kernel:
    ;-----------------------
    ; Finish procedure
    ;-----------------------
    jmp    $               ; while (1)


;-----------------------
; Padding
;-----------------------
    times KERNEL_SIZE - ($ - $$) db 0  ; padding