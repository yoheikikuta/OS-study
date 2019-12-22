;***********************
; Initialize interruption vector
;***********************
ALIGN 4
VECT_BASE  equ 0x0010_0000  ; 0010_0000:0010_07FF
IDTR:  dw 8 * 256 - 1
       dd VECT_BASE

;***********************
; Initialize interruption table
;***********************
init_int:
    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx
    push   ecx
    push   edi

    ;-----------------------
    ; Set default settings to all interruption
    ;-----------------------
    lea    eax, [int_default]
    mov    ebx, 0x0008_8E00
    xchg   ax, bx

    mov    ecx, 256        ; ECX = (interruption vector number)
    mov    edi, VECT_BASE  ; EDI = (interrpution vector table)
.10L:
    mov    [edi + 0], ebx  ; [EDI + 0] = (lower interruption disk discriptor)
    mov    [edi + 4], eax  ; [EDI + 4] = (upper interruption disk discriptor)
    add    edi, 8          ; EDI += 8
    loop   .10L            ; while (ECX--)

    ;-----------------------
    ; Load interruption discriptor table
    ;-----------------------
    lidt   [IDTR]

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    edi
    pop    ecx
    pop    ebx
    pop    eax

    ret

int_default:
        pushf
        push cs
        push int_stop

        mov eax, .s0
        iret

.s0:    db " <    STOP    > ", 0


int_stop:
    ;-----------------------
    ; Display characters of EAX
    ;-----------------------
    cdecl  draw_str, 25, 15, 0x060F, eax  ; draw_str(EAX)

    ;-----------------------
    ; Transform stack data to characters
    ;-----------------------
    mov    eax, [esp + 0]  ; EAX = ESP[0]
    cdecl  itoa, eax, .p1, 8, 16, 0b0100  ; itoa(EAX, 8, 16, 0b0100)

    mov    eax, [esp + 4]  ; EAX = ESP[4]
    cdecl  itoa, eax, .p2, 8, 16, 0b0100  ; itoa(EAX, 8, 16, 0b0100)

    mov    eax, [esp + 8]  ; EAX = ESP[8]
    cdecl  itoa, eax, .p3, 8, 16, 0b0100  ; itoa(EAX, 8, 16, 0b0100)

    mov    eax, [esp + 12]  ; EAX = ESP[12]
    cdecl  itoa, eax, .p4, 8, 16, 0b0100  ; itoa(EAX, 8, 16, 0b0100)

    ;-----------------------
    ; Display characters
    ;-----------------------
    cdecl  draw_str, 25, 16, 0x0F04, .s1  ; draw_str("ESP+ 0:--------")
    cdecl  draw_str, 25, 17, 0x0F04, .s2  ; draw_str("   + 4:--------")
    cdecl  draw_str, 25, 18, 0x0F04, .s3  ; draw_str("   + 8:--------")
    cdecl  draw_str, 25, 19, 0x0F04, .s4  ; draw_str("   +12:--------")

    ;-----------------------
    ; Infinite loop
    ;-----------------------
    jmp    $               ; while (1)

.s1:  db "ESP+ 0:"
.p1:  db "________ ", 0
.s2:  db "   + 4:"
.p2:  db "________ ", 0
.s3:  db "   + 8:"
.p3:  db "________ ", 0
.s4:  db "   +12:"
.p4:  db "________ ", 0

int_zero_div:
    pushf
    push   cs
    push   int_stop

    mov    eax, .s0
    iret

.s0:    db " <  ZERO DIV  > ", 0
