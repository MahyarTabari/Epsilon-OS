#ifndef PAGING_H
#define PAGING_H

#include <stdint.h>
#include "../../kernel/status.h"

#define PAGING_IS_PRESENT                   0b00000001
#define PAGING_READ_WRITE                   0b00000010
#define PAGING_ACCESS_BY_ALL                0b00000100
#define PAGING_WRITE_THROUGH_CACHE          0b00001000
#define PAGING_DISABLE_CACHE                0b00010000
#define PAGING_IS_DIRTY                     0b00100000
#define PAGING_4MB_PAGE_SIZE                0b10000000

#define PAGING_ENTRIES_IN_PAGE_DIRECTORY    1024   
#define PAGING_ENTRIES_IN_PAGE_TABLE        1024
#define PAGING_PAGE_SIZE                    4096

typedef uint32_t page_directory_entry;
typedef uint32_t page_table_entry;

struct four_gb_virtual_memory
{
    // this is a pointer to the first entry of the page directory
    page_directory_entry* entries;

};

struct four_gb_virtual_memory*  new_four_gb_virtual_memory(uint8_t flags);

/*
 * set the paging (PG) and protection (PE) bits of cr0
 *
 * @return  void
 */
extern void enable_paging();

/*
 * set the cr3 to the pointer to the first byte of page directory entry
 *
 * @param   page_directory_address      pointer to the first byte of page directory entry
 * @return  void
 */
extern void load_page_directory(page_directory_entry* page_directory_address);

/*
 * switch current virtual memory to the given virtual memory
 *
 * @param   vm      new virtual memroy to switch on
 * @return  void
 */
void switch_paging(struct four_gb_virtual_memory* vm);

/*
 * get the directory index of the given virtual address
 * bits 22 to 31
 *
 * @param   virtual_address     virtual address
 * @return  void
 */
uint32_t get_directory_index(void* virtual_address);

/*
 * get the page index of the given virtual address
 * bits 12 to 21
 * 
 * @param   virtual_address     virtual address
 * @return  table index
 */
uint32_t get_table_index(void* virtual_address);

/*
 * check whether the given address can be the address of the first byte of a block
 * 
 * @param   address     address to be tested
 * @return  int         1 if ture, 0 if false  
 */
int is_aligned(void* address);

/*
 * switch current virtual memory to the given virtual memory
 *
 * @param   vm                  the virtual memory to be modified
 * @param   virtual_address     the virtual address of the first byte of the block(it must be aligned(divisable by block size))
 * @param   physical_address    the physical address of the first byte of the block(it must be aligned(divisable by block size))
 * @param   flags               flags can be set by macros defined in paging.h
 * @return  int                 0 if Ok, negative otherwise
 */
int set_virtual_address(struct four_gb_virtual_memory* vm, void* virtual_address, void* physical_address, uint8_t flags);
#endif