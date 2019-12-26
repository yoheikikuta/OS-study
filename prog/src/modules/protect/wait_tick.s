wait_tick:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +8 | weight
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ecx

    ;-----------------------
    ; Weight
    ;-----------------------
    mov    ecx, [ebp + 8]  ; ECX = (weight number)
    mov    eax, [TIMER_COUNT]  ; EAX = TIMER

.10L:
    cmp    [TIMER_COUNT], eax  ; while (TIMER != EAX)  TIMER_COUNT re-written in an interruption process
    je     .10L
    inc    eax             ; EAX++
    loop   .10L

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    ecx
    pop    eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret
