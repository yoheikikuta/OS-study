draw_time:
    ;-----------------------
    ; Construct stack frame
                           ; +20  | time
                           ; +16  | color
                           ; +12  | column
                           ; +8  | row
                           ; +4  | EIP (return address)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx

    ;-----------------------
    ; Display time
    ;-----------------------
    mov    eax, [ebp + 20]  ; EAX = (time data)

    movzx  ebx, al          ; EBX = (second)
    cdecl  itoa, ebx, .sec, 2, 16, 0b0100  ; Change to characters

    mov    bl, ah           ; EBX = (minute)
    cdecl  itoa, ebx, .min, 2, 16, 0b0100  ; Change to characters

    shr    eax, 16          ; EBX = (hour)
    cdecl itoa, eax, .hour, 2, 16, 0b0100  ; Change to characters

    cdecl draw_str, dword[ebp + 8], dword[ebp + 12], dword[ebp + 16], .hour  ; draw_str()

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    ebx
    pop    eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret

.hour:  db "ZZ:"
.min:  db "ZZ:"
.sec:  db "ZZ", 0
