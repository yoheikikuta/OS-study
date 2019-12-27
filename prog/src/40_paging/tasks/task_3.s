task_3:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
    mov    ebp, esp        ; EBP + 0 | EBP

    push   dword 0         ; -4 | x0 = 0  X coordinate origin
    push   dword 0         ; -8 | y0 = 0  Y coordinate origin
    push   dword 0         ; -12 | x = 0  Draw X coordinate
    push   dword 0         ; -16 | y = 0  Draw Y coordinate
    push   dword 0         ; -20 | r = 0  angle

    ;-----------------------
    ; Initialization
    ;-----------------------
    mov    esi, DRAW_PARAM  ; ESI = (draw parameter)

    ;-----------------------
    ; Display title
    ;-----------------------
    mov    eax, [esi + rose.x0]  ; X0 coordinate
    mov    ebx, [esi + rose.y0]  ; Y0 coordinate

    shr    eax, 3          ; EAX = EAX / 8  Translate X coordinate to character position
    shr    ebx, 4          ; EBX = EBX / 16  Translate X coordinate to character position
    dec    ebx             ; Move top by one character
    mov    ecx, [esi + rose.color_s]  ; character color
    lea    edx, [esi + rose.title]  ; title

    cdecl  draw_str, eax, ebx, ecx, edx  ; draw_str()

    ;-----------------------
    ; Mid-point of x axis
    ;-----------------------
    mov    eax, [esi + rose.x0]  ; EAX = X0
    mov    ebx, [esi + rose.x1]  ; EBX = X1
    sub    ebx, eax        ; EBX = X1 - X0
    shr    ebx, 1          ; EBX /= 2
    add    ebx, eax        ; EBX += X0
    mov    [ebp - 4], ebx  ; x0 = EBX

    ;-----------------------
    ; Mid-point of y axis
    ;-----------------------
    mov    eax, [esi + rose.y0]
    mov    ebx, [esi + rose.y1]
    sub    ebx, eax
    shr    ebx, 1
    add    ebx, eax
    mov    [ebp - 8], ebx

    ;-----------------------
    ; Draw x axis
    ;-----------------------
    mov    eax, [esi + rose.x0]  ; EAX = X0 coordinate
    mov    ebx, [ebp - 8]   ; EBX = (Mid-point of y axis)
    mov    ecx, [esi + rose.x1]  ; ECX = X1 coordinate

    cdecl  draw_line, eax, ebx, ecx, ebx, dword [esi + rose.color_x]

    ;-----------------------
    ; Draw y axis
    ;-----------------------
    mov    eax, [esi + rose.y0]
    mov    ebx, [ebp - 4]
    mov    ecx, [esi + rose.y1]

    cdecl  draw_line, ebx, eax, ebx, ecx, dword [esi + rose.color_y]

    ;-----------------------
    ; Draw frame
    ;-----------------------
    mov    eax, [esi + rose.x0]
    mov    ebx, [esi + rose.y0]
    mov    ecx, [esi + rose.x1]
    mov    edx, [esi + rose.y1]

    cdecl  draw_rect, eax, ebx, ecx, edx, dword [esi + rose.color_z]

    ;-----------------------
    ; Limit amplitude to 95 %
    ;-----------------------
    mov    eax, [esi + rose.x1]  ; EAX = X1 coordinate
    sub    eax, [esi + rose.x0]  ; EAX -= X0 coordinate
    shr    eax, 1          ; EAX /= 2
    mov    ebx, eax        ; EBX = EAX
    shr    ebx, 4          ; EBX /= 16
    sub    eax, ebx        ; EAX -= EBX

    ;-----------------------
    ; Initialize FPU (rose curve)
    ;-----------------------
    cdecl  fpu_rose_init, eax, dword [esi + rose.n], dword [esi + rose.d]

    ;-----------------------
    ; Main loop
    ;-----------------------
.10L:

    ;-----------------------
    ; Compute coordinate
    ;-----------------------
    lea    ebx, [ebp - 12]  ; EBX = &x
    lea    ecx, [ebp - 16]  ; ECX = &y
    mov    eax, [ebp - 20]  ; EAX = r

    cdecl  fpu_rose_update, ebx, ecx, eax

    ;-----------------------
    ; Update angle (r = r % 36000)
    ;-----------------------
    mov    edx, 0          ; EDX = 0
    inc    eax             ; EAX++
    mov    ebx, 360 * 100  ; DBX = 36000
    div    ebx             ; EDX = EDX:EAX % EBX
    mov    [ebp - 20], edx

    ;-----------------------
    ; Draw dots
    ;-----------------------
    mov    ecx, [ebp - 12]  ; ECX = X coordinate
    mov    edx, [ebp - 16]  ; EDX = Y coordinate

    add    ecx, [ebp - 4]  ; ECX += X coordinate origin
    add    edx, [ebp - 8]  ; EDX += Y coordinate origin

    mov    ebx, [esi + rose.color_f]  ; EBX = display color
    int    0x82            ; sys_call_82(color, X, Y)

    ;-----------------------
    ; Weight
    ;-----------------------
    cdecl  wait_tick, 2

    ;-----------------------
    ; Draw dots (erasing)
    ;-----------------------
    mov    ebx, [esi + rose.color_b]  ; EBX = back ground color
    int    0x82            ; sys_call_82(color, X, Y)

    jmp    .10L

    ;-----------------------
    ; Data
    ;-----------------------
ALIGN 4, db 0
DRAW_PARAM:
    istruc rose
        at rose.x0, dd 16  ; left top X0
        at rose.y0, dd 32  ; left top Y0
        at rose.x1, dd 416  ; right bottom X1
        at rose.y1, dd 432  ; right bottom Y1

        at rose.n, dd 2  ; variable n
        at rose.d, dd 1  ; variable d

        at rose.color_x, dd 0x0007  ; color X axis
        at rose.color_y, dd 0x0007  ; color Y axis
        at rose.color_z, dd 0x000F  ; color frame
        at rose.color_s, dd 0x030F  ; color character
        at rose.color_f, dd 0x000F  ; color graph drawing
        at rose.color_b, dd 0x0003  ; color graph erasing

        at rose.title, db "Task-3", 0  ; "Task-3", 0  ; title
    iend


fpu_rose_init:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +16 | d
                           ; +12 | n
                           ; +8 | A
    push   ebp             ; EBP + 4 | EIP (return address)
    mov    ebp, esp        ; EBP + 0 | EBP

    push   dword 180       ; - 4 | dword i = 180 

    ;-----------------------
    ; Set FPU stack
    ;-----------------------
    fldpi                   ; pi |xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|
    fidiv  dword [ebp - 4]  ; pi/180 |xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|
    fild   dword [ebp + 12]  ; n | pi/180 |xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|
    fidiv  dword [ebp + 16]  ; n/d |  |xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|
    fild   dword [ebp + 8]  ; A | k=n/d | r=pi/180 |xxxxxxxx|xxxxxxxx|xxxxxxxx|

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret


fpu_rose_update:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +16 | t (angle)
                           ; +12 | Y (float)
                           ; +8 | X (float)
    push   ebp             ; EBP + 4 | EIP (return address)
    mov    ebp, esp        ; EBP + 0 | EBP

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx

    ;-----------------------
    ; Set save address of X/Y coordinate
    ;-----------------------
    mov    eax, [ebp + 8]  ; EAX = ptrX  Pointer to x coordinate
    mov    ebx, [ebp + 12]  ; EBX = ptrY  Pointer to y coordinate

    ;-----------------------
    ; Tranform angle to radian
    ;-----------------------
    fild   dword [ebp + 16]  ; t | A | k | r |xxxxxxxx|xxxxxxxx|
    fmul   st0, st3          ; rt |  |  |  |xxxxxxxx|xxxxxxxx|
    fld    st0               ; \theta=rt | \theta=rt | A | k | r |xxxxxxxx|

    fsincos                  ; cos(\theta) | sin(\theta) | \theta | A | k | r |
    fxch   st2               ; \theta | sin(\theta) | cos(\theta) | A | k | r |
    fmul   st0, st4          ; k \theta |  |  |  |  |  |
    fsin                     ; sin(k \theta) |  |  |  |  |  |
    fmul   st0, st3          ; A sin(k \theta) |  |  |  |  |  |

    ;-----------------------
    ; x = A * sin(k \theta) * cos(k \theta)
    ;-----------------------
    fxch   st2             ; cos(k \theta) |  | A sin(k \theta) |  |  |  |
    fmul   st0, st2        ; x |  |  |  |  |  |
    fistp  dword [eax]     ; sin(k \theta) | A sin(k \theta) | A | k | r |xxxxxxxx|

    ;-----------------------
    ; y = - A * sin(k \theta) * cos(k \theta)
    ;-----------------------
    fmulp  st1, st0        ; y | A | k | r |xxxxxxxx|xxxxxxxx|
    fchs                   ; -y |  |  |  |xxxxxxxx|xxxxxxxx|
    fistp  dword [ebx]     ; A | k | r |xxxxxxxx|xxxxxxxx|xxxxxxxx|

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
