#include "kernel.h"
#include <stdint.h>
#include "../include/vga.h"
#include "../include/type.h"
#include "./idt/idt.h"
#include "config.h"
#include "../io/io.h"
#include "../memory/heap/kheap.h"
#include "../memory/heap/heap.h"
#include "../memory/paging/paging.h"

int current_video_memory_row = 0;
int current_video_memory_col = 0;


static struct four_gb_virtual_memory* kernel_vm;
// test function for interrupt 0,
// defined in "kernel.asm"
extern void division_zero();

/*
 * calculates the length of the given string 
 * 
 * @param   str         - pointer to null terminated string
 * @return  int         - length of the string 
 */
int strlen(char* str)
{
    int count = 0;
    
    // go over the characters starting from 'str',
    // and count them,
    // until you reach to the null terminator
    while (1)
    {
        if (*str == '\0')
        {
            return count;
        }

        count++;
        str++;
    }
}




/*
 * prints one character with the specified color,
 * and shifts the cursor to the right
 * 
 * @param ch        character to be printed
 * @param color     color is a macro defined in "vga.h"       
 * @return          void    
 */
void print_char_terminal(char ch, char color)
{
    /*
     *  *------------------*------------------*
     *  |    ASCII CODE    |    COLOR CODE    |
     *  *------------------*------------------*
     * 
     * Note:
     *  as we use intel cpu, and intel CPU's are little endian,
     *  we first store color and then ASCII code
     * 
     * 
     * check below links for more information:
     *  https://en.wikipedia.org/wiki/VGA_text_mode
     *  http://www.brackeen.com/vga/basics.html
     */


    // go to the start of next line
    if (ch == '\n')
    {
        current_video_memory_col = 0;
        current_video_memory_row++;

        return;

    }

    int video_memory_index = to_video_memory_index(current_video_memory_row, current_video_memory_col);

    // shift color 1 byte to right and make ch the 
    uint16_t video_memory_element = (color << 8) | ch;

    TEXT_VIDEO_MEMORY[video_memory_index] = video_memory_element;


    current_video_memory_col++;

    // if you've passed the line,
    // go to the begining of the next line
    if (current_video_memory_col % VGA_COLUMNS == 0)
    {
        current_video_memory_col = 0;
        current_video_memory_row++;
    }


    return;

    
}


/*
 * initializes VGA memory with space
 * 
 * @param   None
 * @return  void
 */
void initialize_terminal()
{
    char space = ' ';
    char vga_white = VGA_WHITE;

    uint16_t initializer = (vga_white << 8) | space;
    const int VGA_NUMBER_OF_CHARS = VGA_COLUMNS * VGA_ROWS;
    for (int i = 0 ; i < VGA_NUMBER_OF_CHARS ; i++)
    {
        
        TEXT_VIDEO_MEMORY[i] = initializer;
    }

    return;
}

/*
 * prints the given null terminated string,
 * and moves the cursor
 * 
 * @param   str         character to be printed
 * @param   color       color is macro defined in "vga.h"       
 * @return  void    
 */
void print_str_terminal(char* str)
{
    int len = strlen(str);
    for (int i = 0 ; i < len ; i++)
    {
        print_char_terminal(str[i], VGA_WHITE);
    }

    return;
}


// test function for IDT
void division_by_zero_interrupt_code()
{
    print_str_terminal("division by zero interrupt\n");
}


void keyboard_irq_code()
{
    print_str_terminal("keybaord is pressed!\n");
}

extern void test_interrupt();

void kmain()
{

    initialize_terminal();
    print_str_terminal("we are in main\n");

    initialize_kheap();
    print_str_terminal("kheap is set up\n");

    initialize_idt();
    print_str_terminal("idt is initialized\n");

    kernel_vm = new_four_gb_virtual_memory((uint32_t)(PAGING_READ_WRITE | PAGING_IS_PRESENT | PAGING_ACCESS_BY_ALL));
    print_str_terminal("kernel virtual memroy is created\n");

    switch_paging(kernel_vm);
    print_str_terminal("switched to kernel virtual memroy\n");

    enable_paging();
    print_str_terminal("paging is enabled\n");

    char* ptr = kzalloc(100);

    // we've set virtual address 0x20000 to point to the physical address pointed to by ptr
    set_virtual_address(kernel_vm, (void*)0x20000, ptr, PAGING_READ_WRITE | PAGING_IS_PRESENT | PAGING_ACCESS_BY_ALL);
    
    char* virt_addr = (char*)0x20000;

    virt_addr[0] = 'A';

    print_str_terminal(ptr);

    // enabling interrupts using sti instruction is needed,
    // otherwise interrupts will be ignored
    //enable_interrupts();
    //print_str_terminal("interrupts are enabled\n");

    // int 0-31 are working,
    // but int 32-47 (IRQ's) are not working
    // it seems that the problem is due to mapping in kernel.asm 
    //test_interrupt();

}