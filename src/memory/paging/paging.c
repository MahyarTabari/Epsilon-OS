#include "paging.h"
#include "../heap/kheap.h"

// current virtual memory
static struct four_gb_virtual_memory* current_vm;

struct four_gb_virtual_memory*  new_four_gb_virtual_memory(uint8_t flags)
{
    struct four_gb_virtual_memory* vm = kmalloc(sizeof(struct four_gb_virtual_memory));
    

    // this is an offset to the physical 
    uint32_t offset = 0;
    // create a page directory with 1024 entries
    page_directory_entry* page_dir_entries = kzalloc(PAGING_ENTRIES_IN_PAGE_DIRECTORY * sizeof(page_directory_entry));

    // for each page directory entry,
    // create a page table,
    // and put the address of the first entry of that page table into page directory entry
    // then 
    for (int i = 0 ; i < PAGING_ENTRIES_IN_PAGE_DIRECTORY ; i++)
    {
        // creating a new page table(each table is an array of page table entries)
        // each page table has 1024 * 32 bytes = 32KB
        page_table_entry* new_page_table_entries = kzalloc(PAGING_ENTRIES_IN_PAGE_TABLE * sizeof(page_table_entry));
        page_dir_entries[i] = (uint32_t)new_page_table_entries | flags;

        // now initialize each page table entry to point to to the corresponding physical address
        for (int j = 0 ; j < PAGING_ENTRIES_IN_PAGE_TABLE ; j++)
        {
            new_page_table_entries[j] = (page_table_entry)(offset + PAGING_PAGE_SIZE * j) | PAGING_READ_WRITE;
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