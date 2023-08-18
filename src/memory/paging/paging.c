#include "paging.h"
#include "../heap/kheap.h"

/*
 *  Discription:
 *  with paging we can take advantage of virtual addresses.
 *  virtual addresses can be resolved to physical addresses.
 *  this is the format of virtual address:
 *     |31             |21             |11                   0
 *     +---------------+---------------+---------------------+
 *     |   directory   |    table      |     offset in       |
 *     |     index     |    index      |     page frame      |
 *     +---------------+---------------+---------------------+
 * 
 *   this is how the processor resolves virtual addresses to physical address:
 *   it finds the page directory(its address is stored in cr3 register)
 *   then it goes to the entry of the directory which has the index specified by bits 22-31 of the virtual address
 *   directory entry has a pointer to the related page table
 *   (we need only 10 bits to address page table, so 12 lowest bits used for flags)
 *   
 *   then we get into that page table
 *   we are interested in the entry having the index specified by the bits  12-21 of the virtual address
 *   page table entry contains the physical address of the first byte of the related block
 *   
 *   in this os there are 4096 bytes in a block(4K)
 *   to find the actual byte we are interested in, we use the offset specifed by bits 0 to 11 of the virtual address
 * 
 *  
 */


// current virtual memory
static struct four_gb_virtual_memory* current_vm;

struct four_gb_virtual_memory*  new_four_gb_virtual_memory(uint8_t flags)
{
    struct four_gb_virtual_memory* vm = kmalloc(sizeof(struct four_gb_virtual_memory));
    

    // this is an offset to the physical 
    uint32_t offset = 0;
    // create a page directory with 1024 entries
    page_directory_entry* page_dir_entries = kmalloc(PAGING_ENTRIES_IN_PAGE_DIRECTORY * sizeof(page_directory_entry));

    // for each page directory entry,
    // create a page table,
    // and put the address of the first entry of that page table into page directory entry
    // then 
    for (int i = 0 ; i < PAGING_ENTRIES_IN_PAGE_DIRECTORY ; i++)
    {
        // creating a new page table(each table is an array of page table entries)
        // each page table has 1024 * 32 bytes = 32KB
        page_table_entry* new_page_table_entries = kmalloc(PAGING_ENTRIES_IN_PAGE_TABLE * sizeof(page_table_entry));
        page_dir_entries[i] = (uint32_t)new_page_table_entries | flags | PAGING_READ_WRITE;

        // now initialize each page table entry to point to to the corresponding physical address
        for (int j = 0 ; j < PAGING_ENTRIES_IN_PAGE_TABLE ; j++)
        {
            new_page_table_entries[j] = (page_table_entry)(offset + PAGING_PAGE_SIZE * j) | flags;
        }


        // now we've initialized 1024 page table entry such that each entry points to a frame of 4096 bytes
        // so we have to update the offset to go 1024 * 4096 bytes further
        offset += PAGING_ENTRIES_IN_PAGE_TABLE * PAGING_PAGE_SIZE;
    }

    vm->entries = page_dir_entries;

    return vm;

}

void switch_paging(struct four_gb_virtual_memory* vm)
{
    current_vm = vm;
    load_page_directory(vm->entries);
    return;
}

uint32_t get_directory_index(void* virtual_address)
{
    uint32_t res = ((uint32_t)virtual_address) >> 22;

    return res;
}

uint32_t get_table_index(void* virtual_address)
{
    uint32_t res = (((uint32_t)virtual_address) >> 12) & 0x03FF;

    return res;
}


int is_aligned(void* address)
{
    return ((uint32_t)address % PAGING_PAGE_SIZE) == 0;
}

int set_virtual_address(struct four_gb_virtual_memory* vm, void* virtual_address, void* physical_address, uint8_t flags)
{
    // we are going to change the physical address specified in the page table entry to the one specified by 'physical_address' parameter
    
    int status = 0;

    // the virtual address works for a block not for a single byte
    if (!is_aligned(virtual_address))
    {
        status = -EINVARG;
        goto out;
    }

    // first find the indices related to that given virtual address
    int directoy_index = get_directory_index(virtual_address);
    int table_index = get_table_index(virtual_address);

    page_directory_entry* directory = vm->entries;
    
    // the upper 20 bits of the entry of the page directory is a pointer to the related page table
    page_table_entry* table = (page_table_entry*)((directory[directoy_index]) & 0xfffff000);

    // set the related entry of the table to the given physical address and flags 
    table[table_index] = (uint32_t)(((uint32_t)physical_address) | (uint32_t)flags);

out:
    return status;
}