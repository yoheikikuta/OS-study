draw_pixel:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +16 | color
                           ; +12 | Y
                           ; +8 | X
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx
    push   ecx
    push   edi

    ;-----------------------
    ; Multiply by 80 of Y coordinate (640 / 8)
    ;-----------------------
    mov    edi, [ebp + 12]  ; EDI = Y
    shl    edi, 4          ; EDI *= 16
    lea    edi, [edi * 4 + edi + 0xA_0000]  ; EDI = 0xA00000[EDI * 4 + EDI]

    ;-----------------------
    ; Multiply 1/8 of X coordinate and add
    ;-----------------------
    mov    ebx, [ebp + 8]  ; EBX = X
    mov    ecx, ebx        ; ECX = EBX
    shr    ebx, 3          ; EBX /= 8
    add    edi, ebx        ; EDI += EBX

    ;-----------------------
    ; Comput bit positon from X coordinate % 8
    ; (0=0x80, 1=0x40, ..., 7=0x01)
    ;-----------------------
    and    ecx, 0x07       ; ECX = X & 0x07
    mov    ebx, 0x80       ; EBX = 0x80
    shr    ebx, cl         ; EBX >>= ECX

    ;-----------------------
    ; Color specification
    ;-----------------------
    mov    ecx, [ebp + 16]  ; ECX = (color)

    ;-----------------------
    ; Output on each plane
    ;-----------------------
    cdecl  vga_set_read_plane, 0x03
    cdecl  vga_set_write_plane, 0x08
    cdecl  vram_bit_copy, ebx, edi, 0x08, ecx

    cdecl  vga_set_read_plane, 0x02
    cdecl  vga_set_write_plane, 0x04
    cdecl  vram_bit_copy, ebx, edi, 0x04, ecx

    cdecl  vga_set_read_plane, 0x01
    cdecl  vga_set_write_plane, 0x02
    cdecl  vram_bit_copy, ebx, edi, 0x02, ecx

    cdecl  vga_set_read_plane, 0x00
    cdecl  vga_set_write_plane, 0x01
    cdecl  vram_bit_copy, ebx, edi, 0x01, ecx

    ;-----------------------
    ; Recover regisiters
    ;-----------------------
    pop    edi
    pop    ecx
    pop    ebx
    pop    eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret

.s0:  db  '        ', 0
.t0:  dw  0x0000, 0x0800
      dw  0x0100, 0x0900
      dw  0x0200, 0x0A00
      dw  0x0300, 0x0B00
      dw  0x0400, 0x0C00
      dw  0x0500, 0x0D00
      dw  0x0600, 0x0E00
      dw  0x0700, 0x0F00
