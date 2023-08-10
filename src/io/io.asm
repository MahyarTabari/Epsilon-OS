section .asm

global outb
global outw
global oudw
global insb
global insw
global insdw


outb:
    push ebp
    mov ebp, esp
    push eax

    ; send 1 byte of the second argument to the port specified by the first argument
    mov edx, [ebp + 8]
    mov eax, [ebp + 12]
    out dx, al

    pop eax
    pop ebp

outw:
    push ebp
    mov ebp, esp
    push eax

    ; send 2 bytes of the second argument to the port specified by the first argument
    mov edx, [ebp + 8]
    mov eax, [ebp + 12]
    out dx, ax

    pop eax
    pop ebp

outdw:
    push ebp
    mov ebp, esp
    push eax

    ; send 4 byte of the second argument to the port specified by the first argument
    mov edx, [ebp + 8]
    mov eax, [ebp + 12]
    out dx, eax

    pop eax
    pop ebp


insb:
    push ebp
    mov ebp, esp

    ; reset eax
    xor eax, eax
    ; read 1 byte form the given port 
    mov edx, [ebp + 8]
    in al, dx

    pop ebp

insw:
    push ebp
    mov ebp, esp

    ; reset eax
    xor eax, eax
    ; read 2 bytes form the given port 
    mov edx, [ebp + 8]
    in ax, dx

    pop ebp

insdw:
    push ebp
    mov ebp, esp

    ; reset eax
    xor eax, eax
    ; read 1 byte form the given port 
    xor eax, eax
    mov edx, [ebp + 8]
    in eax, dx

    pop ebp
