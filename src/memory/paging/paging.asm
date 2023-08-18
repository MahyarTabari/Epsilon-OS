[BITS 32]

section .asm

global enable_paging
global load_page_directory


;;;;
;; set the paging and protection bits of cr0
;; @return  void
;;;;
enable_paging:
    push ebp
    mov ebp, esp

    mov eax, cr0
    ;; set the paging and protection bits of cr0
    or eax, 0x80000001
    mov cr0, eax

    pop ebp
    ret

;;;;
;; set the cr3 to the pointer to the first byte of page directory entry
;; @param   page_directory_address      pointer to the first byte of page directory entry
;; @return  void
;;;;
load_page_directory:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    mov cr3, eax

    pop ebp
    ret