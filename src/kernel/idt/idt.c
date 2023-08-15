#include "idt.h"
#include "../config.h"
#include "../../memory/memory.h"

#define KERNEL_CODE_SEG 0x08


// interrupt discriptor table contains 256 entries,
// and each entry is related to one interrupt
struct gate_descriptor idt[EPSILONOS_TOTAL_INTERRUPTS];

// idtr_descriptor contains the total size and address of IDT
struct idtr_descriptor idtr_desc;


/*
 * creates an entry in IDT for the specified interrupt to run the specified code
 * 
 * @param   interrupt_numbeer           character to be printed
 * @param   gate_type                   defined in "idt.h"   
 * @param   dpl                         descriptor privilege level(defined in "config.h")
 * @return  void                        
 */
void set_interrupt(uint8_t interrupt_number, uint8_t gate_type, uint8_t dpl, void* interrupt_handler_address)
{

    // Important Note: address is stored in 2 part:
    // the 2 lower bytes are in offset1
    // the 2 higher bytes are in offset2

    uint32_t address = (uint32_t)interrupt_handler_address;

    // mask 2 lower bytes of address
    idt[interrupt_number].offset1 = (uint16_t)(address & 0x0000ffff);

    // the interrupts are related to kernel
    idt[interrupt_number].segment_selector = (uint16_t) KERNEL_CODE_SEG;

    // reserved
    idt[interrupt_number].reserved = 0x00;


    uint8_t access = 0;
    
    // fill the 4 lower bits to gate_type
    access = access | (gate_type & 0x0f);

    // make the 4'th bit 0
    access = access & 0b11101111;

    // dpl must be located in 5'th and 6'th bits
    access = access | (dpl << 5);

    // make present bit 1 to show that this entry is valid
    access = access | 0b10000000;

    idt[interrupt_number].access = access;

    // shift address 16 bits to right(2 byte) to access the 2 higher bytes of address
    idt[interrupt_number].offset2 = (uint16_t)(address >> 16);
}

/*
 * sets the value of idtr_desc(i.e. size of IDT and the address of it)
 * 
 * @param   None 
 * @return  void    
 */
void set_idtr()
{
    idtr_desc.size = EPSILONOS_TOTAL_INTERRUPTS - 1;
    idtr_desc.offset = (uint32_t)idt;
}

/*
 * sets the value of idt_desc,
 * and loads it into idtr register
 * then zero initializes all of entries in IDT
 * 
 * @param   str         character to be printed
 * @param   color       color is macro defined in "vga.h"       
 * @return  void    
 */

extern void no_interrupt_handler();
extern void division_by_zero_interrupt_handler();
extern void keyboard_irq_handler();
void initialize_idt()
{
    set_idtr();

    memset(idt, 0, sizeof(idt));
    //memset(idt, 0, EPSILONOS_TOTAL_INTERRUPTS * 8);
    // initalize each interrupt with a code that sends EOI(end of interrupt command) to IRQ's 
    for (int i = 0 ; i < EPSILONOS_TOTAL_INTERRUPTS ; i++)
    {
        set_interrupt(i, INTERRUPT_GATE_32, RING_3, no_interrupt_handler);
    }

    set_interrupt(0, INTERRUPT_GATE_32, RING_3, division_by_zero_interrupt_handler);

    // set interrupt for keyboard(IRQ 1)
    set_interrupt(0x21, INTERRUPT_GATE_32, RING_3, keyboard_irq_handler);

    load_idtr(&idtr_desc);
}

