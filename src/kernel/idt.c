#include "idt.h"
#include "config.h"
#include "../memory/memory.h"

#define KERNEL_CODE_SEG 0x08
// struct gate_descriptor idt[EPSILONOS_TOTAL_INTERRUPTS];

struct gate_descriptor idt[256];

struct idtr_descriptor idtr;


void set_interrupt(uint8_t interrupt_number, uint8_t gate_type, uint8_t dpl, void* interrupt_code_address)
{
    uint32_t address = (uint32_t)interrupt_code_address;
    idt[interrupt_number].offset1 = (uint16_t)(address & 0x0000ffff);

    idt[interrupt_number].segment_selector = (uint16_t) KERNEL_CODE_SEG;

    idt[interrupt_number].reserved = 0x00;


    uint8_t access = 0;

    access = access | (gate_type & 0x0f);

    access = access & 0b11101111;

    access = access | dpl << 5;

    access = access | 0b10000000;

    idt[interrupt_number].access = access;

    idt[interrupt_number].offset2 = (uint16_t)(address >> 16);
}

void set_idtr()
{
    idtr.size = EPSILONOS_TOTAL_INTERRUPTS - 1;
    idtr.offset = (uint32_t)idt;
}

void initialize_idt()
{
    set_idtr();

    load_idtr(&idtr);
    memset(idt, 0, EPSILONOS_TOTAL_INTERRUPTS);
}

