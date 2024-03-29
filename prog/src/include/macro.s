%macro cdecl 1-*.nolist
    %rep %0 - 1
      push   %{-1:-1}
      %rotate -1
    %endrep
    %rotate -1

      call   %1

    %if 1 < %0
      add    sp, (__BITS__ >> 3) * (%0 - 1)
    %endif
%endmacro

%macro set_vect 1-*
    push   eax
    push   edi

    mov    edi, VECT_BASE + (%1 * 8)  ; Vector address
    mov    eax, %2

    %if 3 == %0
      mov [edi + 4], %3
    %endif

    mov    [edi + 0], ax              ; Exception address [15:0]
    shr    eax, 16
    mov    [edi + 6], ax              ; Exception address [31:16]

    pop    edi
    pop    eax
%endmacro

%macro outp 2
    mov    al, %2
    out    %1, al
%endmacro

; Set base address and limit of LDT
; e.g.) set_desc  GDT.ldt, LDT, word LDT_LIMIT
%macro set_desc 2-*
    push   eax
    push   edi

    mov    edi, %1                    ; Descriptor address
    mov    eax, %2                    ; Base address

    %if 3 == %0
      mov [edi + 0], %3               ; Segment Limit [15:0] (%3 is word and it's 16bit)
    %endif

    mov    [edi + 2], ax              ; Segment base address [15:0] of total [31:0]
    shr    eax, 16
    mov    [edi + 4], al              ; Segment base address [23:16] of total [31:0]
    mov    [edi + 7], ah              ; Segment base address [31:24] of total [31:0]

    pop    edi
    pop    eax
%endmacro

; Register functions in the call gate
; e.g.) set_gate  GDT.call_gate, call_gate
%macro set_gate 2-*
    push   eax
    push   edi

    mov    edi, %1                    ; Descriptor adress
    mov    eax, %2                    ; Base address

    mov    [edi + 0], ax              ; offset [15:0] of total [31:0]
    shr    eax, 16
    mov    [edi + 6], ax              ; offset [31:16] of total [31:0]

    pop    edi
    pop    eax
%endmacro


struc drive
    .no     resw 1  ; drive number
    .cyln   resw 1  ; cylinder
    .head   resw 1  ; head
    .sect   resw 1  ; sector
endstruc

%define RING_ITEM_SIZE (1 << 4)
%define RING_INDEX_MASK (RING_ITEM_SIZE - 1)

struc ring_buff
    .rp resd 1                 ; Reading position
    .wp resd 1                 ; Writing position
    .item resb RING_ITEM_SIZE  ; buffer
endstruc

struc rose
    .x0       resd 1  ; left top x
    .y0       resd 1  ; left top y
    .x1       resd 1  ; right bottom x
    .y1       resd 1  ; right bottom y

    .n        resd 1  ; variable n
    .d        resd 1  ; variable d

    .color_x  resd 1  ; draw color x
    .color_y  resd 1  ; draw color y
    .color_z  resd 1  ; draw color frame
    .color_s  resd 1  ; draw color character
    .color_f  resd 1  ; draw color graph drawing
    .color_b  resd 1  ; draw color graph erasing
    
    .title    resb 16  ; title
endstruc