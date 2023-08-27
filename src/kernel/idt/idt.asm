section .asm
global load_idtr

global no_interrupt_handler
extern no_interrupt_code

global enable_interrupts
global disable_interrupts

global division_by_zero_interrupt_handler
extern division_by_zero_interrupt_code

global keyboard_irq_handler
extern keyboard_irq_code
; loads idtr register with size and address of the IDT(pointed to by idtr_desc)
;
; @param   [ebp+8]         address of the idtr_desc      
; @return  void
load_idtr:
    push ebp
    mov ebp, esp

    mov ebx, [ebp+8]
    lidt [ebx]

    pop ebp
    ret


;; this is used for enabling interrupts after initializing LDT in C
enable_interrupts:  
    
    sti
    ret

disable_interrupts:
    cli
    ret

no_interrupt_handler:
    cli
    pushad

    call no_interrupt_code

    popad
    sti
    iret

division_by_zero_interrupt_handler:
    cli
    pushad

    call division_by_zero_interrupt_code

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

    popad
    sti
    iret