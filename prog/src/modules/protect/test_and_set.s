test_and_set:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +8 | address of local variable
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx

    ;-----------------------
    ; Test and set
    ;-----------------------
    mov    eax, 0          ; local = 0
    mov    ebx, [ebp + 8]  ; global = (address)

.10L:
    lock bts [ebx], eax   ; CF = TEST_AND_SET(IN_USE, 1)  0: Caller sets variable as 1, 1: Another caller sets variable as 1
    jnc    .10E           ; if (0 == CF)

.12L:
    bt     [ebx], eax     ; CF = TEST(IN_USE, 1)
    jc     .12L           ; if (0 == CF)
    jmp    .10L           ; Try to enter the critical section while it succeeds

.10E:

    ;-----------------------
    ; Recover registers
    ;-----------------------
    push   ebx
    push   eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret
