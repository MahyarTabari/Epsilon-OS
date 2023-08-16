#ifndef PAGING_H
#define PAGING_H

#include <stdint.h>

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


#endif