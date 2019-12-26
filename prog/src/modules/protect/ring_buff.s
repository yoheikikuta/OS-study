ring_rd:
    ; RETRUN 0 (no data) or 1 (some data)
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +12 | data save address
                           ; +8 | ring buffer
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   ebx
    push   esi
    push   edi

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    esi, [ebp + 8]  ; ESI = (ring buffer)
    mov    edi, [ebp + 12]  ; EDI = (data save address)

    ;-----------------------
    ; Check reading position
    ;-----------------------
    mov    eax, 0          ; EAX = 0 (no data)
    mov    ebx, [esi + ring_buff.rp]  ; EBX = rp (reading position)
    cmp    ebx, [esi + ring_buff.wp]  ; if (EBX != wp)  Check whether reading and writing positions are different
    je     .10E

    mov    al, [esi + ring_buff.item + ebx]  ; AL = BUFF[rp]  Save key code
    mov    [edi], al       ; [EDI] = AL  ; Save data
    inc    ebx             ; EBX++  Move to the next reading position
    and    ebx, RING_INDEX_MASK  ; EBX &= 0x0F  Size limit
    mov    [esi + ring_buff.rp], ebx  ; wp = EBX  Save the reading position
    mov    eax, 1          ; EAX = 1  Flat meaning there is data

.10E:
; This label is for just skipping the procedure

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    edi
    pop    esi
    pop    ebx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret


ring_wr:
    ; RETRUN 0 (failuer) or 1 (success)
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +12 | data (to be written)
                           ; +8 | ring buffer
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   ebx
    push   ecx
    push   esi

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    esi, [ebp + 8]  ; ESI = (ring buffer address)

    ;-----------------------
    ; Check writing position
    ;-----------------------
    mov    eax, 0          ; EAX = 0  returning value (0 is failure)
    mov    ebx, [esi + ring_buff.wp]  ; EBX = wp  Writing position
    mov    ecx, ebx        ; ECX = EBX
    inc    ecx             ; ECX++  Move to the next wiriting position
    and    ecx, RING_INDEX_MASK  ; ECX &= 0x0F  Size limit
    cmp    ecx, [esi + ring_buff.rp]  ; if (ECX != rp)  Check whether reading and writing positions are different
    je     .10E

    mov    al, [ebp + 12]  ; AL = (data)
    mov    [esi + ring_buff.item + ebx], al  ; BUFF[wp] = AL  Save key code
    mov    [esi + ring_buff.wp], ecx  ; wp = ECX  Save writing position
    mov    eax, 1          ; EAX =1  returning value (1 is success)

.10E:
; This label is for just skipping the procedure

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    esi
    pop    ecx
    pop    ebx

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret


draw_key:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +16 | rign buffer
                           ; +12 | row (Y)
                           ; +8 | column (X)
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    pusha

    ;-----------------------
    ; Get arguments
    ;-----------------------
    mov    edx, [ebp + 8]  ; EDX = (column)
    mov    edi, [ebp + 12]  ; EDI = (row)
    mov    esi, [ebp + 16]  ; ESI = (ring buffer)

    ;-----------------------
    ; Get information of ring buffer
    ;-----------------------
    mov    ebx, [esi + ring_buff.rp]  ; EBX = wp  Writing position
    lea    esi, [esi + ring_buff.item]  ; ESI - &KEY_BUFF[EBX]
    mov    ecx, RING_ITEM_SIZE  ; ECX = RING_ITEM_SIZE  Number of elements

    ;-----------------------
    ; Display
    ;-----------------------
.10L:
    dec    ebx             ; EBX--  Reading position
    and    ebx, RING_INDEX_MASK  ; EBX &= RING_INDEX_MASK
    mov    al, [esi + ebx]  ; EAX = KEY_BUFF[EBX]

    cdecl  itoa, eax, .tmp, 2, 16, 0b0100  ; Convert key code into string
    cdecl  draw_str, edx, edi, 0x02, .tmp  ; Display the converted string

    add    edx, 3          ; Update display position (for 3 characters)

    loop .10L
.10E:

    ;-----------------------
    ; Recover registers
    ;-----------------------
    popa

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret

.tmp:   db "-- ", 0
