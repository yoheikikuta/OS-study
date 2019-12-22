int_rtc:
    ;-----------------------
    ; Save registers
    ;-----------------------
    pusha
    push   ds
    push   es

    ;-----------------------
    ; Set segment selector for data
    ;-----------------------
    mov    ax, 0x0010      ; 0x0010 is 2nd element of Global Discriptor Table (in 8 bytes unit)
    mov    ds, ax
    mov    es, ax

    ;-----------------------
    ; Get time from RTC
    ;-----------------------
    cdecl  rtc_get_time, RTC_TIME  ; EAX = get_time(&RTC_TIME)

    ;-----------------------
    ; Get interruption type of RTC
    ;-----------------------
    outp   0x70, 0x0C      ; outp(0x70, 0x0C)  register C has the cause of RTC interruption
    in     al, 0x71        ; AL = port(0x71)

    ;-----------------------
    ; Clear interruption flag (EOI)
    ;-----------------------
    mov    al, 0x20        ; AL = (EOI command)
    out    0xA0, al        ; outp(0xA0, AL)  slave PIC
    out    0x20, al        ; outp(0x20, AL)  master PIC

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    es
    pop    ds
    popa

    iret                   ; Finish interruption procedure


rtc_int_en:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +8 | bit
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax

    ;-----------------------
    ; Set interruption permission
    ;-----------------------
    outp   0x70, 0x0B      ; outp(0x70, AL)  register B includes Update-ended Interrupt Enable bit
    in     al, 0x71        ; AL = port(0x71)
    or     al, [ebp + 8]   ; AL |= bit
    out    0x71, al        ; outp(0x71, AL)  write into register B

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret