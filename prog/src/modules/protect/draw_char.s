draw_char:
    ;-----------------------
    ; Construct stack frame
    ;-----------------------
                           ; +20 | ch
                           ; +16 | color
                           ; +12 | row (Y: 0 ~ 29)  16 * 30 = 480
                           ; +8 | column (X: 0 ~ 79)  8 * 80 = 640
                           ; +4 | return address (32bits = 4bytes)
    push   ebp             ; BP + 0 | BP
    mov    ebp, esp

    ;-----------------------
    ; Save registers
    ;-----------------------
    push   eax
    push   ebx
    push   ecx
    push   edx
    push   esi
    push   edi

    ;-----------------------
    ; Test and set
    ;-----------------------
    %ifdef USE_TEST_AND_SET
        cdecl test_and_set, IN_USE
    %endif

    ;-----------------------
    ; Set copy font address
    ;-----------------------
    movzx  esi, byte [ebp + 20]  ; CL = (character code)
    shl    esi, 4          ; CL *= 16  16bytes per character
    add    esi, [FONT_ADR]  ; ESI = (font address)

    ;-----------------------
    ; Get copy destination address
    ; Adr = 0xA0000 + (640 / 8 * 16) * y + x
    ;-----------------------
    mov    edi, [ebp + 12]  ; Y (row)
    shl    edi, 8          ; EDI = Y * 256
    lea    edi, [edi * 4 + edi + 0xA0000]  ; EDI = Y * 4 + Y
    add    edi, [ebp + 8]  ; X (column)

    ;-----------------------
    ; Output one character font
    ;-----------------------
    movzx  ebx, word[ebp + 16]  ; Display color

    cdecl  vga_set_read_plane, 0x03  ; Write plane  Intensity
    cdecl  vga_set_write_plane, 0x08  ; Read plane  Intensity
    cdecl  vram_font_copy, esi, edi, 0x08, ebx
    
    cdecl  vga_set_read_plane, 0x02  ; Write plane  Red
    cdecl  vga_set_write_plane, 0x04  ; Read plane  Red
    cdecl  vram_font_copy, esi, edi, 0x04, ebx
    
    cdecl  vga_set_read_plane, 0x01  ; Write plane  Green
    cdecl  vga_set_write_plane, 0x02  ; Read plane  Green
    cdecl  vram_font_copy, esi, edi, 0x02, ebx
    
    cdecl  vga_set_read_plane, 0x00  ; Write plane  Blue
    cdecl  vga_set_write_plane, 0x01  ; Read plane  Blue
    cdecl  vram_font_copy, esi, edi, 0x01, ebx

    ;-----------------------
    ; Clear IN_USE variable
    ;-----------------------
    %ifdef USE_TEST_AND_SET
        mov [IN_USE], dword 0
    %endif

    ;-----------------------
    ; Recover registers
    ;-----------------------
    pop    edi
    pop    esi
    pop    edx
    pop    ecx
    pop    ebx
    pop    eax

    ;-----------------------
    ; Discard stack frame
    ;-----------------------
    mov    esp, ebp
    pop    ebp

    ret

ALIGN 4, db 0
IN_USE:  dd 0