section .asm
global load_idtr

;
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
