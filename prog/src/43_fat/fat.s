;***********************
; FAT: FAT-1
;***********************
    times  (FAT1_START) - ($ - $$) db 0x00
;-----------------------
FAT1:
    db     0xFF, 0xFF  ; cluster 0
    dw     0xFFFF      ; cluster 1
    dw     0xFFFF      ; cluster 2


;***********************
; FAT: FAT-2
;***********************
    times  (FAT2_START) - ($ - $$) db 0x00
;-----------------------
FAT2:
    db     0xFF, 0xFF  ; cluster 0
    dw     0xFFFF      ; cluster 1
    dw     0xFFFF      ; cluster 2


;***********************
; FAT: Region of root directory
;***********************
    times  (ROOT_START) - ($ - $$) db 0x00
;-----------------------
FAT_ROOT:
    db     'BOOTABLE', 'DSK'  ; + 0  Volume label
    db     ATTR_ARCHIVE | ATTR_VOLUME_ID  ; +11  Attribute
    db     0x00        ; +12  Reserved
    db     0x00        ; +13  TS
    dw     (0 << 11) | (0 << 5) | (0 / 2)  ; +14  Creation time
    dw     (0 << 9) | (0 << 5) | (1)  ; +16  Creation date
    dw     (0 << 9) | (0 << 5) | (1)  ; +18  Access date
    dw     0x0000      ; +20 Reserved
    dw     (0 << 11) | (0 << 5) | (0 / 2)  ; +22  Updated time
    dw     (0 << 9) | (0 << 5) | (1)  ; +24  Updated date
    dw     0           ; +26  Head cluster
    dd     0           ; +28  File size

    db     'SPECIAL ', 'TXT'  ; + 0  Volume label
    db     ATTR_ARCHIVE  ; +11  Attribute
    db     0x00        ; +12  Reserved
    db     0           ; +13  TS
    dw     (0 << 11) | (0 << 5) | (0 / 2)  ; +14  Creation time
    dw     (0 << 9) | (1 << 5) | (1)  ; +16  Creation date
    dw     (0 << 9) | (1 << 5) | (1)  ; +18  Access date
    dw     0x0000      ; +20  Reserved
    dw     (0 << 11) | (0 << 5) | (0 / 2)  ; +22  Updated time
    dw     (0 << 9) | (1 << 5) | (1)  ; +24  Updated date
    dw     2           ; +26  Head cluster
    dd     FILE.end - FILE  ; +28  File size


;***********************
; FAT: Region of data
;***********************
    times  FILE_START - ($ - $$) db 0x00
;-----------------------
FILE:  db 'hello, FAT!'
.end:  db 0

ALIGN 512, db 0x00
    times (512 * 63) db 0x00
