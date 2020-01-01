task_2:
    ;-----------------------
    ; Display string
    ;-----------------------
    cdecl  draw_str, 63, 1, 0x07, .s0

    ;-----------------------
    ; Set initial value
    ;-----------------------
    fild   dword [.c1000]  ; 1000 |xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|
    fldpi                  ; pi | 1000 |xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|
    fidiv  dword [.c180]   ; d = pi/180 | 1000 |xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|
    fldpi                  ; pi | d | 1000 |xxxxxxxx|xxxxxxxx|xxxxxxxx|
    fadd   st0, st0        ; 2*pi | d | 1000 |xxxxxxxx|xxxxxxxx|xxxxxxxx|
    fldz                   ; \theta = 0 | 2*pi | d | 1000 |xxxxxxxx|xxxxxxxx|

.10L:

    ;-----------------------
    ; Sin (\theta)
    ;-----------------------
    fadd   st0, st2        ; \theta = \theta + d | 2*pi | d | 1000 |xxxxxxxx|xxxxxxxx|
    fprem                  ; MOD(\theta) | \theta | 2*pi | d | 1000 |xxxxxxxx|
    fld    st0             ; \theta | \theta | 2*pi | d | 1000 |xxxxxxxx|
    fsin                   ; sin(\theta) | \theta | 2*pi | d | 1000 |xxxxxxxx|
    fmul   st0, st4        ; ST4 * sin(\theta) | \theta | 2*pi | d | 1000 |xxxxxxxx|

    fbstp  [.bcd]          ; \theta | 2*pi | d | 1000 |xxxxxxxx|xxxxxxxx|

    ;-----------------------
    ; Display value
    ;-----------------------
    mov    eax, [.bcd]     ; EAX = 1000 * sin(\theta)
    mov    ebx, eax        ; EBX = EAX

    and    eax, 0x0F0F     ; Mask upper 4 bits
    or     eax, 0x3030     ; Set 0x3 in upper 4 bits (to change to character code)

    shr    ebx, 4          ; EBX >>= 4
    and    ebx, 0x0F0F     ; Mask upper 4 bits
    or     ebx, 0x3030     ; Set 0x3 in upper 4 bits (to change to character code)

    mov    [.s2 + 0], bh   ; Integer part
    mov    [.s3 + 0], ah   ; 1st decimal place
    mov    [.s3 + 1], bl   ; 2nd decimal place
    mov    [.s3 + 2], al   ; 3rd decimal place

    mov    eax, 7          ; Sign of the value
    bt     [.bcd + 9], eax  ; CF = bcd[9] & 0x80
    jc     .10F            ; if(CF)

    mov    [.s1 + 0], byte '+'  ; *s1 = '+'
    jmp    .10E
.10F:

    mov    [.s1 + 0], byte '-'  ; *s1 = '-'
.10E:

    cdecl  draw_str, 72, 1, 0x07, .s1  ; draw_str(.s1)

    ;-----------------------
    ; Weight
    ;-----------------------
    cdecl  wait_tick, 10   ; wait_tick() because display updating is too fast

    jmp    .10L

    ;-----------------------
    ; Data
    ;-----------------------
ALIGN 4, db 0
.c1000:  dd 1000
.c180:  dd 180

.bcd:  times 10 db 0x00

.s0:  db "Task-2", 0
.s1:  db "-"
.s2:  db "0."
.s3:  db "000", 0