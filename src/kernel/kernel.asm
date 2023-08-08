[BITS 32]

KERNEL_CODE_SEG equ 0x08           
KERNEL_DATA_SEG equ 0X10

global _start
global division_zero
extern kmain

_start:
    ;set the segment registers(except code segment which is already set)
    mov ax, KERNEL_DATA_SEG
    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov es, ax
    mov ss, ax
    mov ebp, 0x200000
    mov esp, ebp

    ; enable A20 line
    in al, 0x92         ; read form port 0x92 into al
    or al, 2            ; set the second lowest bit of al
    out 0x92, al        ; write to that port

    ; go to kmain function in kernel.c
    call kmain

    jmp $

; Align to fill one sector
times 512-($-$$) db 0

division_zero:
    push ebp
    mov ebp, esp

    mov eax, 0
    div eax

    pop ebp
    ret
