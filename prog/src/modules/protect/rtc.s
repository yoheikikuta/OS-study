rtc_get_time:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +8 | save destination address
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx

    ;-----------------------
    ; Get time
    ;-----------------------
    mov    al, 0x04        ; AL = 0x04
    out    0x70, al        ; outp(0x70, AL)
    in     al, 0x71        ; AL = inp(0x71)  hour
    shl    eax, 8          ; EAX <<= 8  escpae hour data to lefter bit

    mov    al, 0x02        ; AL = 0x02
    out    0x70, al        ; outp(0x70, AL)
    in     al, 0x71        ; AL = inp(0x71)  minute
    shl    eax, 8          ; EAX <<= 8  escpae minute data to lefter bit

    mov    al, 0x00        ; AL = 0x00
    out    0x70, al        ; outp(0x70, AL)
    in     al, 0x71        ; AL = inp(0x71)  second

    and    eax, 0x00_FF_FF_FF  ; Only valid lower 3 bytes

    mov    ebx, [ebp + 8]  ; dst = (save address)
    mov    [ebx], eax      ; [dst] = (time information)

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
