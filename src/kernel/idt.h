#ifndef IDT_H
#define IDT_H
#include <stdint.h>


// used for gate_type in set_interrupt function
#define TASK_GATE               0x5
#define INTERRUPT_GATE_16       0x6
#define TRAP_GATE_16            0x7
#define INTERRUPT_GATE_32       0xE
#define TRAP_GATE_32            0xF

// check the below link for more information
// https://wiki.osdev.org/Interrupt_Descriptor_Table
struct gate_descriptor
{
    uint16_t        offset1;
    uint16_t        segment_selector;
    uint8_t         reserved;
    uint8_t         access;
    uint16_t        offset2;

}__attribute__((packed));

struct idtr_descriptor
{
    uint16_t        size;
    uint32_t        offset;
}__attribute__((packed));

void set_interrupt(uint8_t interrupt_number, uint8_t gate_type, uint8_t dpl, void* interrupt_handler_address);

void set_idtr();

// defined in "idt.asm"
extern void load_idtr(struct idtr_descriptor* idtr_addr);

void initialize_idt();
#endif