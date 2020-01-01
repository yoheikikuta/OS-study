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
.cr3:     dd CR3_BASE         ; 28: CR3(PDBR)
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
.fp_save: times 108 + 4 db 0  ; Save region for FPU context

TSS_1:
.link:    dd 0  ; Link to the previous task
.esp0:    dd SP_TASK_1 - 512  ; 4: ESP0
.ss0:     dd DS_KERNEL
.esp1:    dd 0
.ss1:     dd 0
.esp2:    dd 0
.ss2:     dd 0
.cr3:     dd CR3_BASE         ; 28: CR3(PDBR)
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
.fp_save: times 108 + 4 db 0  ; Save region for FPU context

TSS_2:
.link:    dd 0  ; Link to the previous task
.esp0:    dd SP_TASK_2 - 512  ; 4: ESP0
.ss0:     dd DS_KERNEL
.esp1:    dd 0
.ss1:     dd 0
.esp2:    dd 0
.ss2:     dd 0
.cr3:     dd CR3_BASE         ; 28: CR3(PDBR)
.eip:     dd task_2
.eflags:  dd 0x0202
.eax:     dd 0
.ecx:     dd 0
.edx:     dd 0
.ebx:     dd 0
.esp:     dd SP_TASK_2
.ebp:     dd 0
.esi:     dd 0
.edi:     dd 0
.es:      dd DS_TASK_2
.cs:      dd CS_TASK_2
.ss:      dd DS_TASK_2
.ds:      dd DS_TASK_2
.fs:      dd DS_TASK_2
.gs:      dd DS_TASK_2
.ldt:     dd SS_LDT  ; 96: LDT segment selector
.io:      dd 0  ; 100: I/O map based address
.fp_save: times 108 + 4 db 0  ; Save region for FPU context

TSS_3:
.link:    dd 0  ; Link to the previous task
.esp0:    dd SP_TASK_3 - 512  ; 4: ESP0
.ss0:     dd DS_KERNEL
.esp1:    dd 0
.ss1:     dd 0
.esp2:    dd 0
.ss2:     dd 0
.cr3:     dd CR3_BASE         ; 28: CR3(PDBR)
.eip:     dd task_3
.eflags:  dd 0x0202
.eax:     dd 0
.ecx:     dd 0
.edx:     dd 0
.ebx:     dd 0
.esp:     dd SP_TASK_3
.ebp:     dd 0
.esi:     dd 0
.edi:     dd 0
.es:      dd DS_TASK_3
.cs:      dd CS_TASK_3
.ss:      dd DS_TASK_3
.ds:      dd DS_TASK_3
.fs:      dd DS_TASK_3
.gs:      dd DS_TASK_3
.ldt:     dd SS_LDT  ; 96: LDT segment selector
.io:      dd 0  ; 100: I/O map based address
.fp_save: times 108 + 4 db 0  ; Save region for FPU context

TSS_4:
.link:    dd 0  ; Link to the previous task
.esp0:    dd SP_TASK_4 - 512  ; 4: ESP0
.ss0:     dd DS_KERNEL
.esp1:    dd 0
.ss1:     dd 0
.esp2:    dd 0
.ss2:     dd 0
.cr3:     dd CR3_TASK_4       ; 28: CR3(PDBR)
.eip:     dd task_3
.eflags:  dd 0x0202
.eax:     dd 0
.ecx:     dd 0
.edx:     dd 0
.ebx:     dd 0
.esp:     dd SP_TASK_4
.ebp:     dd 0
.esi:     dd 0
.edi:     dd 0
.es:      dd DS_TASK_4
.cs:      dd CS_TASK_3
.ss:      dd DS_TASK_4
.ds:      dd DS_TASK_4
.fs:      dd DS_TASK_4
.gs:      dd DS_TASK_4
.ldt:     dd SS_LDT  ; 96: LDT segment selector
.io:      dd 0  ; 100: I/O map based address
.fp_save: times 108 + 4 db 0  ; Save region for FPU context

TSS_5:
.link:    dd 0  ; Link to the previous task
.esp0:    dd SP_TASK_5 - 512  ; 4: ESP0
.ss0:     dd DS_KERNEL
.esp1:    dd 0
.ss1:     dd 0
.esp2:    dd 0
.ss2:     dd 0
.cr3:     dd CR3_TASK_5       ; 28: CR3(PDBR)
.eip:     dd task_3
.eflags:  dd 0x0202
.eax:     dd 0
.ecx:     dd 0
.edx:     dd 0
.ebx:     dd 0
.esp:     dd SP_TASK_5
.ebp:     dd 0
.esi:     dd 0
.edi:     dd 0
.es:      dd DS_TASK_5
.cs:      dd CS_TASK_3
.ss:      dd DS_TASK_5
.ds:      dd DS_TASK_5
.fs:      dd DS_TASK_5
.gs:      dd DS_TASK_5
.ldt:     dd SS_LDT  ; 96: LDT segment selector
.io:      dd 0  ; 100: I/O map based address
.fp_save: times 108 + 4 db 0  ; Save region for FPU context

TSS_6:
.link:    dd 0  ; Link to the previous task
.esp0:    dd SP_TASK_6 - 512  ; 4: ESP0
.ss0:     dd DS_KERNEL
.esp1:    dd 0
.ss1:     dd 0
.esp2:    dd 0
.ss2:     dd 0
.cr3:     dd CR3_TASK_6       ; 28: CR3(PDBR)
.eip:     dd task_3
.eflags:  dd 0x0202
.eax:     dd 0
.ecx:     dd 0
.edx:     dd 0
.ebx:     dd 0
.esp:     dd SP_TASK_6
.ebp:     dd 0
.esi:     dd 0
.edi:     dd 0
.es:      dd DS_TASK_6
.cs:      dd CS_TASK_3
.ss:      dd DS_TASK_6
.ds:      dd DS_TASK_6
.fs:      dd DS_TASK_6
.gs:      dd DS_TASK_6
.ldt:     dd SS_LDT  ; 96: LDT segment selector
.io:      dd 0  ; 100: I/O map based address
.fp_save: times 108 + 4 db 0  ; Save region for FPU context


;***********************
; Global Disk scriptor Table (GDT)
;***********************
; See https://stackoverflow.com/questions/37554399/what-is-the-use-of-defining-a-global-descriptor-table?rq=1 in detail.
GDT:         dq 0x0000000000000000  ; NULL
.cs_kernel:  dq 0x00_CF9A_000000_FFFF  ; CODE 4G
.ds_kernel:  dq 0x00_CF92_000000_FFFF  ; DATA 4G
.ldt         dq 0x00_0082_000000_0000  ; LDT descriptor
.tss_0:      dq 0x00_0089_000000_0067  ; TSS descriptor 0x67 = 103  Limit
.tss_1:      dq 0x00_0089_000000_0067
.tss_2:      dq 0x00_0089_000000_0067
.tss_3:      dq 0x00_0089_000000_0067
.tss_4:      dq 0x00_0089_000000_0067
.tss_5:      dq 0x00_0089_000000_0067
.tss_6:      dq 0x00_0089_000000_0067
.call_gate:  dq 0x00_00EC_040008_0000  ; 386 call gate  DPL=3, count=4, SEL=8
.end:

CS_KERNEL  equ .cs_kernel - GDT
DS_KERNEL  equ .ds_kernel - GDT
SS_LDT     equ .ldt - GDT
SS_TASK_0  equ .tss_0 - GDT
SS_TASK_1  equ .tss_1 - GDT
SS_TASK_2  equ .tss_2 - GDT
SS_TASK_3  equ .tss_3 - GDT
SS_TASK_4  equ .tss_4 - GDT
SS_TASK_5  equ .tss_5 - GDT
SS_TASK_6  equ .tss_6 - GDT
SS_GATE_0  equ .call_gate - GDT

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
.cs_task_2:  dq 0x00_CFFA_000000_FFFF  ; CODE 4G  Lowest privilege level
.ds_task_2:  dq 0x00_CFF2_000000_FFFF  ; DATA 4G  Lowest privilege level
.cs_task_3:  dq 0x00_CFFA_000000_FFFF  ; CODE 4G  Lowest privilege level
.ds_task_3:  dq 0x00_CFF2_000000_FFFF  ; DATA 4G  Lowest privilege level
.ds_task_4:  dq 0x00_CFF2_000000_FFFF  ; DATA 4G  Lowest privilege level
.ds_task_5:  dq 0x00_CFF2_000000_FFFF  ; DATA 4G  Lowest privilege level
.ds_task_6:  dq 0x00_CFF2_000000_FFFF  ; DATA 4G  Lowest privilege level
.end:

CS_TASK_0  equ (.cs_task_0 - LDT) | 4  ; CS selector for task 0  Need to set BIT2 to refer LDT
DS_TASK_0  equ (.ds_task_0 - LDT) | 4  ; DS selector for task 0
CS_TASK_1  equ (.cs_task_1 - LDT) | 4 | 3  ; CS selector for task 1  Lowest privilege level
DS_TASK_1  equ (.ds_task_1 - LDT) | 4 | 3  ; DS selector for task 1  Lowest privilege level
CS_TASK_2  equ (.cs_task_2 - LDT) | 4 | 3  ; CS selector for task 2  Lowest privilege level
DS_TASK_2  equ (.ds_task_2 - LDT) | 4 | 3  ; DS selector for task 2  Lowest privilege level
CS_TASK_3  equ (.cs_task_3 - LDT) | 4 | 3  ; CS selector for task 3  Lowest privilege level
DS_TASK_3  equ (.ds_task_3 - LDT) | 4 | 3  ; DS selector for task 3  Lowest privilege level
DS_TASK_4  equ (.ds_task_4 - LDT) | 4 | 3  ; DS selector for task 4  Lowest privilege level
DS_TASK_5  equ (.ds_task_5 - LDT) | 4 | 3  ; DS selector for task 5  Lowest privilege level
DS_TASK_6  equ (.ds_task_6 - LDT) | 4 | 3  ; DS selector for task 6  Lowest privilege level

LDT_LIMIT  equ .end - LDT - 1
