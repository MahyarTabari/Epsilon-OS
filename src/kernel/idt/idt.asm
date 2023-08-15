section .asm
global load_idtr

global no_interrupt_handler
global enable_interrupts
global disable_interrupts

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

    ; send EOI
    mov al, 0x20
    out 0x20, al

    popad
    sti
    iret