;***********************
; Task State Segment (TSS)
;***********************
TSS_0:
.link:    dd 0  ; 0: Link to the previous task
.esp0:    dd SP_TASK_0 - 512  ; 4: ESP0
.ss0:     dd DS_KERNEL
.esp1:    dd 0
.ss1:     dd 0
.esp2:    dd 0
.ss2:     dd 0
.cr3:     dd 0
.eip:     dd 0
.eflags:  dd 0
.eax:     dd 0
.ecx:     dd 0
.edx:     dd 0
.ebx:     dd 0
.esp:     dd 0
.ebp:     dd 0
.esi:     dd 0
.edi:     dd 0
.es:      dd 0
.cs:      dd 0
.ss:      dd 0
.ds:      dd 0
.fs:      dd 0
.gs:      dd 0
.ldt:     dd 0  ; 96: LDT segment selector
.io:      dd 0  ; 100: I/O map based address

TSS_1:
.link:    dd 0  ; Link to the previous task
.esp0:    dd SP_TASK_1 - 512  ; 4: ESP0
.ss0:     dd DS_KERNEL
.esp1:    dd 0
.ss1:     dd 0
.esp2:    dd 0
.ss2:     dd 0
.cr3:     dd 0
.eip:     dd task_1
.eflags:  dd 0x0202
.eax:     dd 0
.ecx:     dd 0
.edx:     dd 0
.ebx:     dd 0
.esp:     dd SP_TASK_1
.ebp:     dd 0
.esi:     dd 0
.edi:     dd 0
.es:      dd DS_TASK_1
.cs:      dd CS_TASK_1
.ss:      dd DS_TASK_1
.ds:      dd DS_TASK_1
.fs:      dd DS_TASK_1
.gs:      dd DS_TASK_1
.ldt:     dd SS_LDT  ; 96: LDT segment selector
.io:      dd 0  ; 100: I/O map based address


;***********************
; Global Disk scriptor Table (GDT)
;***********************
; See http://www.ics.p.lodz.pl/~dpuchala/LowLevelProgr/Old/Lecture2.pdf, for example.
GDT:         dq 0x0000000000000000  ; NULL
.cs_kernel:  dq 0x00_CF9A_000000_FFFF  ; CODE 4G
.ds_kernel:  dq 0x00_CF92_000000_FFFF  ; DATA 4G
.ldt         dq 0x00_0082_000000_0000  ; LDT descriptor
.tss_0:      dq 0x00_0089_000000_0067  ; 0x67 = 103  Limit
.tss_1:      dq 0x00_0089_000000_0067
.end:

CS_KERNEL  equ .cs_kernel - GDT
DS_KERNEL  equ .ds_kernel - GDT
SS_LDT     equ .ldt - GDT
SS_TASK_0  equ .tss_0 - GDT
SS_TASK_1  equ .tss_1 - GDT

GDTR:  dw GDT.end - GDT - 1
       dd GDT

;***********************
; Local Descriptor Table (LDT)
;***********************
LDT:         dq 0x0000000000000000  ; NULL
.cs_task_0:  dq 0x00_CF9A_000000_FFFF  ; CODE 4G
.ds_task_0:  dq 0x00_CF92_000000_FFFF  ; DATA 4G
.cs_task_1:  dq 0x00_CFFA_000000_FFFF  ; CODE 4G  Lowest privilege level
.ds_task_1:  dq 0x00_CFF2_000000_FFFF  ; DATA 4G  Lowest privilege level
.end:

CS_TASK_0  equ (.cs_task_0 - LDT) | 4  ; CS selector for task 0  Need to set BIT2 to refer LDT
DS_TASK_0  equ (.ds_task_0 - LDT) | 4  ; DS selector for task 0
CS_TASK_1  equ (.cs_task_1 - LDT) | 4 | 3  ; CS selector for task 1  Lowest privilege level
DS_TASK_1  equ (.ds_task_1 - LDT) | 4 | 3  ; DS selector for task 1  Lowest privilege level

LDT_LIMIT  equ .end - LDT - 1
