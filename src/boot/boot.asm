;-----------------------------------------------
; Secondary Memory:
;
;
;   ---------------------  0x0
;   |   First Secotor   |
;   |                   |
;   |                   |
;   |    Bootloader     |
;   |                   |
;   |                   |
;   |             0x55AA|
;   |-------------------|
;   |   Second Sector   |
;   |                   |
;   |                   |
;   |   Kernel Entry    |
;   |                   |
;   |                   |
;   |                   |
;   |-------------------|
;   |                   |
;   |                   |
;   |                   |
;   |                   |
;             .
;             .
;             .
;
;--------------------------------------------------





;   --------------------------------  0x0
;   |    Interrupt Vector Table    |
;   |              1KB             |
;   |------------------------------|  0x400
;   |      BIOS Data Area 256B     |
;   |------------------------------|  0x500
;   |            Free              |
;   |                              |
;   |------------------------------|  0x7C00
;   |   Loaded Boot Sector 256B    |
;   |------------------------------|  0x7E00
;   |                              |
;   |            Free              |
;   |            638KB             |
;   |                              |
;   |------------------------------|  0x9FC00
;   |   Extended BIOS Data Area    |
;   |           128KB              |
;   |                              |
;   |------------------------------|  0xA0000
;   |        Video Memory          |
;   |           128KB              |
;   |------------------------------|  0xC0000
;   |            BIOS              |
;   |            256KB             |
;   |                              |
;   |------------------------------|
;   |            Free              |  0x100000  ---------
;   |                              |                    |
;   |                              |                    |
;   |                              |                    |
;   |                              |                    v
;   |                              |         kerenel will be loaded here
;   |                              |
;   |                              |
;   |                              |
;                  .
;                  .
;                  .






ORG 0X7C00
BITS 16

KERNEL_CODE_SEG equ 0x08           
KERNEL_DATA_SEG equ 0X10

_start:
    jmp short start
    nop

times 33 db 0

start:
    jmp 0:next_step

;extern _start
; Note: segments in protected mode are used as an offset of GDT for fidnig the segment discriptor
; kernel code segment is the second one in GDT, and
; kernele data segment is the third one

;--------------------------------------------------
; Setting Segment Registers In Real Mode
;   DS = 0x0000
;   CS = 0x0000
;   ES = 0x0000
;   SS = 0x0000
;
;   --------------------------------  0x0
;   |    Interrupt Vector Table    |
;   |              1KB             |
;   |------------------------------|  0x400
;   |      BIOS Data Area 256B     |
;   |------------------------------|  0x500
;   |                              |           
;   |        Stack Segment         |   <------------------ Stack: stack is growing upward ^
;   |                              |
;   |------------------------------|  0x7c00   <----------
;   |        Code Segment          |                      |
;   |                              |                      |
;   |                              |             ------------------------------------------------------
;   |                              |             | Stack Top Physical Address |                       |
;   |                              |             |-----------------------------                       |
;   |                              |             |   ss:sp                                            |
;   |                              |             |   0x0000:0x7c00 = 0x0000 * 0x10 + 0x7c00 = 0x07c00 |
;   |                              |             ------------------------------------------------------
;   |                              |
;
;                  .
;                  .
;                  .
;
;
;
;
;
; Note 1: Before setting segment registers, disable interrupts.
; This is a crucial operation!
;
; Note 2: It is not possible move immediate into segment registers,
; First move immediate into a global register and mov that register into the segment register
;
next_step:
; clear interrupt
cli

; Set DS, CS and ES to 0x7c00
mov ax, 0x0000
mov ds, ax
mov es, ax
mov ss, ax

; Set SP to 0x7c00
mov sp, 0x7c00

; set interrupt
sti






;--------------------------------------------------------
; Enabling Protected Mode:
;   
;   follow these steps:
;       1. clear interrupts:
;           because it is a critical operation, so we are not going to answer any interrupts.
;
;       2. enable A20 line:
;           because we want to load the kernel into address 0x0100000(which needs the 21'th bit to be enabled).
;
;       3. load GDT:
;           because in protected mode the cpu must know where it is going to access and what is the permissions of it
;           ,but be aware that we set the gdt to defaults because we are not going to use segmented memory.
;           we only need to tell the cpu that we have access to memory,
;           later on we use paging for memory management
;
;--------------------------------------------------------


; we want to switch the processor state,
; so it is necessary to disable interrupts
cli

; load global discriptor register with the contents specified in the address load_gdtr label
lgdt [load_gdtr]

; the lsb of cr0(control register of CPU) is called protection enable,
; protection enable bit:
;       0: real mode
;       1: protected mode

mov eax, cr0

; make the lowest bit 1
or eax, 1
mov cr0, eax

 jmp 0x08:load32
; now we are in protected mode





;--------------------------------------------------------
; Setting GDT Entry For Kernel Code And Data Segments
;
;
;
;
; ----- GDTR points to the first byte in GDT
; |
; v
; GDTR + 0x00---------NULL - Reserved By Intel---------------------
; |                                                                |
; |                                                                |
; |                                                                |
; GDTR + 0x08---------------Code Selector--------------------------
; |                                                                |
; |                                                                |
; |                                                                |
; GDTR + 0x10---------------Data Selector--------------------------
; |                                                                |
; |                                                                |
; |                                                                |
; ------------------------------------------------------------------
;                                 .
;                                 .
;                                 .
;
;
;
;
;
; Access Byte:  bits 40 to 47
;
;  47                                                             40
;  *-------*-------*-------*-------*-------*-------*-------*-------*
;  |       |               |       |       |       |       |       |
;  |   P   |      DPL      |   S   |   E   |  DC   |   RW  |   A   |
;  |       |               |       |       |       |       |       |
;  *-------*-------*-------*-------*-------*-------*-------*-------*
;   for code segment:
;   10011010
;   
;   for data segment:
;   10010010
;
;   P(Present Bit)
;       0: invalid segment
;       1: valid segment
;   
;   DPL(Discriptor Privilege Level)
;       00: ring 0 (highest privilege)
;       01: ring 1
;       11: ring 3
;
;   S(Selector Type):
;       0: system segment
;       1: code or data segment
;   
;   E(Executable)
;       0: data segment(not executable)
;       1: code segment(executable)
;
;   DC(Direction Bit)
;       for data segment:
;           0: segment grows up
;           1: segment grows down
;
;       for code segment:
;           0: can be executed only by ring specified in DPL
;           1: can be executed from an equal or lower privilege level
;
;   RW(Read Write)
;       for data segment: Writable bit
;           0: can not write
;           1: can write
;
;           Note: read access is always allowed for data segments
;
;       for code segment: Readable bit
;           0: can not read
;           1: can read
;
;           Note: write access is never allowed in code segment(Readonly)
;
;
;   A(Accessed Bit)
;       best left 0(CPU itself handles it)
;
;
;
; GTR - Global Discriptor Table Register
; this register contains the address of the first entry of GDT,
; and the size of GDT
;
;     GDTR address(offset):
;        . 4 bytes in 32-bit mode - relative address not physical
;
;     GDTR size:
;        . 2 bytes
;
;
;
;
;
;
;   *-------*-------*-------*-------*
;   |       |       |       |       |
;   |   G   |   DB  |   L   |   0   |
;   |       |       |       |       |
;   *-------*-------*-------*-------*
;   +for code segment: 1100

;   G(Granularity flag)
;       0: Limit is scaled by 1
;       1: Limit is scaled by 4 KiB
;
;   DB(Size Bit)
;       0: 16-bit protected mode segment
;       1: 32-bit protected mode segment
;
;   L(Long Mode Code Flag)
;       1: 64-bit code segment
;       0: any other types of segment
;   
;   Reserved
;       always 0
;
;
;
;
;
;
;
;
;
;    GDTR in 32-bit mode:
;
;   47                               15                  0
;   ------------------------------------------------------
;   |                                |                   |
;   |          Offset : 4B           |     Size: 2B      |
;   |                                |                   |
;   ------------------------------------------------------
;
;

gdt_start:

segment_discriptor_null:
    ; First segment discriptor is NULL(8 bytes of 0)
    dd 0
    dd 0

; Note code and data segments are only different in access flags
code_segment_discriptor:
    ; Base address = 0
    ; Limit = 0xFFFFF = 2^20 addressable unit(GB)
    ; G bit in flags bits is set to 1 so blocks are 4 KiB(for paging)
    ; so we have access to 4GB
    dw 0xFFFF       ; Limit 0-15
    dw 0x0000       ; first and second lower bytes of Base 16-32: starting address of that segment
    db 0x00         ; third lower byte of Base

    db 0b10011010   ; Access bits

    ; |4-Bit Flag|4 Highest Bits of Limit|
    db      0b11001111
    db 0            ; fourth lower byte of Base


data_segment_discriptor:
    ; Base address = 0
    ; Limit = 0xFFFFF
    dw 0xFFFF       ; Limit 0-15
    dw 0x0000       ; first and second lower bytes of Base 16-32: starting address of that segment
    db 0x00         ; third lower byte of Base

    db 0x92         ; Access bits

;   |4-Bit Flag|4 Highest Bits of Limit|
    db      0b11001111
    db 0            ; fourth lower byte of Base

gdt_end:

load_gdtr:
    dw gdt_end - gdt_start - 1      ; 0-15:     size
    dd gdt_start                ; 16-47:    offset(relative address of the GDT)




[BITS 32]
load32:

    mov eax, 1
    mov ecx, 100
    mov edi, 0x100000

    call ata_lba_read


; jump to the kernel code.
; we use the KERNEL_CODE_SEG segment which is the offset to the GDT,
; the second entry because the first one is null and reserved,
; so it is 0x08(each entry contains 8 bytes)
;
; Note: in protected mode the segment part of the address is offset to GDT.

; _start is the entry point of kerenl 
    jmp KERNEL_CODE_SEG:0x0100000



;--------------------------------------------------------
; Loading Kernel into address 0x0100000(1M)
;       . to do this we need to:
;
;            + write our own driver for reading from the disk with ATA
;              becuase BIOS interrupts is not available in protected mode


;--------------------------------------------------------
;   Arguments: 
;       EBX: Cylinder: 2 bytes, Head: 1 byte, S: 1 byte
;       CH: number of sectors to read
;
;   Return: nothing
;
;    EBX
;    *----------*----------*----------*----------*
;    |  higher  |  lower   |     |    |          |
;    | cylinder | cylinder | --- |head|  sector  |
;    |          |          |     |    |          |
;    *----------*----------*----------*----------*
;                             ^
;                             |
;                              ----- this nibble is filled with 0b1010 for specifying
;                                    that we want to read from the disk
;





;
; ATA read sectors (LBA mode)
; 
; @param    eax     logical block address
; @param    cl      number of sectors to read
; @param    edi     the address to load into it
;
ata_lba_read:
    and eax, 0x0fffffff

    ; save eax in ebx
    mov ebx, eax

    ; send bits 24 to 27 in lower nibble
    ; and 0b1110 in upper nibble
    mov dx, 0x01f6
    shr eax, 24
    or al, 0b11100000
    out dx, al

    ; send number of sectors to read
    mov dx, 0x01f2
    mov al, cl
    out dx, al

    ; move bits 8 to 15
    mov dx, 0x1f4
    mov eax, ebx
    shr eax, 8
    out dx, al

    ; move bits 16 to 23
    mov dx, 0x1f5
    mov eax, ebx
    shr eax, 16
    out dx, al
    
    ; send read with retry command to command port
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.next_sector:
    push ecx

.wait:
    mov dx, 0x1f7
    ; wait until the bit 3 is set
    in al, dx
    test al, 8
    jz .wait

    ; ecx is counter for insw
    mov ecx, 256

    ; read form data port
    mov dx, 0x1f0

    ; read 'ecx' words pointed to by 'edi'
    rep insw
    pop ecx
    loop .next_sector

    ret
; Padding Remaining Bytes Of The Sector With Zero - except last 2 bytes for boot signature
times 510-($-$$) db 0

; Boot Signature
; Note: the intel CPU stores bytes in reverse order
; so it will be stored as 0x55 then 0xAA
dw 0xAA55
