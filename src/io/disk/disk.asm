BITS 32

global ata_lba_read
;
; ATA read sectors (LBA mode)
; 
; @param    eax     logical block address
; @param    cl      number of sectors to read
; @param    edi     the address to load into it
;
ata_lba_read:

    push ebp
    mov ebp, esp
    
    xor eax, eax
    xor ecx, ecx
    xor edi, edi

    mov eax, [ebp + 8]
    mov ecx, [ebp + 12]
    mov edi, [ebp + 16]

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

    pop ebp
    ret