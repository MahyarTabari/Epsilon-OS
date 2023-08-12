[BITS 32]

KERNEL_CODE_SEG equ 0x08           
KERNEL_DATA_SEG equ 0X10

global _start
global division_zero
extern kmain
global division_by_zero_interrupt_handler
extern division_by_zero_interrupt_code
global keyboard_irq_handler
extern keyboard_irq_code
_start:
    ;set the segment registers(except code segment which is already set)
    cli
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


    ;; Remapping IRQ
    ;; we need to remap IRQ's to interrupts 32 to 47
    ;; for more information check http://www.brokenthorn.com/Resources/OSDevPic.html

    mov al, 00010001b
    out 0x20, al
    
    ; set IRQ's to INT 32 and so on
    mov al, 0x20
    out 0x21, al
    
    ; tell the IRQ start handling interrupts
    mov al, 0b00000001
    out 0x21, al



    ;; go to kmain function in kernel.c
    call kmain
;
    jmp $

; Align to fill one sector
times 512-($-$$) db 0

division_zero:

    INT 33  
    ret


division_by_zero_interrupt_handler:
    cli
    pushad

    call division_by_zero_interrupt_code

    mov al, 0x20
    out 0x20, al
    popad
    sti
    iret


;; this is a wrapper for keyboard_irq_code function
;; because interrupts need iret to return
;; and we can't do that in C
keyboard_irq_handler:
    cli
    pushad

    call keyboard_irq_code

    mov al, 0x20
    out 0x20, al

    popad
    sti
    iret