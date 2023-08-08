#ifndef IDT_H
#define IDT_H
#include <stdint.h>

#define TASK_GATE               0x5
#define INTERRUPT_GATE_16       0x6
#define TRAP_GATE_16            0x7
#define INTERRUPT_GATE_32       0xE
#define TRAP_GATE_32            0xF

struct gate_descriptor
{
    uint16_t        offset1;
    uint16_t        segment_selector;
    uint8_t         reserved;
    uint8_t         access;
    uint16_t        offset2;

};

struct idtr_descriptor
{
    uint16_t        size;
    uint32_t        offset;
};

void set_interrupt(uint8_t interrupt_number, uint8_t gate_type, uint8_t dpl, void* interrupt_code_address);

void set_idtr();

extern void load_idtr(struct idtr_descriptor* idtr_addr);

void initialize_idt();
#endif