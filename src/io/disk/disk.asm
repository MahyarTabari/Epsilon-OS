[BITS 32]

%define port_to_send_bits_24_27_of_lba 0x01f6
%define port_to_send_number_of_secotrs 0x01f2
%define port_to_send_bits_0_to_7_of_lba 0x1f3
%define port_to_send_bits_8_to_15_of_lba 0x1f4
%define port_to_send_bits_16_to_23_of_lba 0x1f5
%define port_to_send_commands 0x1f7
%define read_with_retry_command 0x20
%define bytes_per_word 256
%define port_to_read_and_wirte_data 0x1f0

global ata_lba_read

ata_lba_read:
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edx
    push edi

    ; save lba into ebx
    mov ebx, [ebp + 8]

    ; save # sectors to read into ecx
    mov ecx, [ebp + 12]

    ; save destination address into edi
    mov edi, [ebp + 16]

    mov eax, ebx
    shr eax, 24
    mov edx, port_to_send_bits_24_27_of_lba
    out dx, al

    mov edx, port_to_send_number_of_secotrs
    mov al, cl
    out dx, al

    mov eax, ebx
    mov edx, port_to_send_bits_0_to_7_of_lba
    out dx, al

    shr eax, 8
    mov edx, port_to_send_bits_8_to_15_of_lba
    out dx, al

    shr eax, 8
    mov edx, port_to_send_bits_16_to_23_of_lba
    out dx, al


    mov al, read_with_retry_command
    mov edx, port_to_send_commands
    out dx, al


.retry
    in al, dx
    ; if the bit 3 is set, we have to wait
    test al, 8
    jz .retry

    ; calculate the total words to read, and put it into eax
    ; eax = bytes_per_word * cl

    mov eax, bytes_per_word
    xor bx, bx
    mov bl, cl
    mul bl  ; eax = eax * bl

    ; ecx is counter for INSW
    mov ecx, eax
    mov edx, port_to_read_and_wirte_data

    ; write ecx words to address specified by edi
    rep insw

    
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax

    pop ebp
    ret