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








[org 0x7c00]

; Note: segments in protected mode are used as an offset of GDT for fidnig the segment discriptor
; kernel code segment is the second one in GDT, and
; kernele data segment is the third one
% define KERNEL_CODE_SEG 0x08           
% define KERNEL_DATA_SEG 0X10

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

; clear interrupt
cli

; Set DS, CS and ES to 0x7c00
mov ax, 0x0000
mov ds, ax
mov cs, ax
mov es, ax
mov ss, ax

; Set SP to 0x7c00
mov sp, 0x7c00

; set interrupt
sti










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
    dw gdt_end - gdt_start      ; 0-15:     size
    dd gdt_start                ; 16-47:    offset(relative address of the GDT)









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

; now we are in protected mode
[BITS 32]

mov ebx, 0x00000001
mov ch, 100

call ata_chs_read
; jump to the kernel code.
; we use the KERNEL_CODE_SEG segment which is the offset to the GDT,
; the second entry because the first one is null and reserved,
; so it is 0x08(each entry contains 8 bytes)
;
; Note: in protected mode the segment part of the address is offset to GDT.

; _start is the entry point of kerenl 
jmp KERNEL_CODE_SEG:_start



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

ata_chs_read:

    push eax
    push ebx
    push ecx
    push edx
    push rdi


    mov al, bl                  ; starting sector
    mov dx, 0x1f3
    out dx, al

    mov al, bh
    and al, 0b00001111          ; only keep the lower nibble(which is head)
    or al, 0b10100000           ; make the higher nibble 0b1010 for reading from the disk
    mov dx, 0x1f6
    out dx, al


    mov eax, ebx        ; cylinder low byte
    shr eax, 16
    mov dx, 0x1f4
    out dx, al

    mov dx, 0x1f5
    out dx, ah

    mov al, ch          ; number of sectors to read
    mov dx, 0x1f2
    out dx, al

    mov al, 0x20
    mov dx, 0x1f7
    out dx, al

.loop:
    in dx, al
    test al, 8
    jz .loop

    mov eax, 512/2      ; eax contains the number of words per sector

    xor ebx, ebx        ; make ebx 0
    mov bl, ch          ; bl contains the number of sectors to read     
    mul bl              ; al = al * bl : total_number_of_word = number_of_words_in_sector * numbr_of_sector

    mov rcx, rax        ; rep instruction repeats insw 'rcx' times
                        ; (i.e. it reads n words where n is the total number of words to read)

    rep insw            ; [es:rdi] <- word_read_from_disk , rdi <- rdi + 2(becuase we are reading word(2bytes))


    pop rdi
    pop edx
    pop ecx
    pop ebx
    pop eax

    popfq

    ret

; Padding Remaining Bytes Of The Sector With Zero - except last 2 bytes for boot signature
times 510-($-$$) db 0

; Boot Signature
; Note: the intel CPU stores bytes in reverse order
; so it will be stored as 0x55 then 0xAA
dw 0xAA55