#include "heap.h"
#include "memory.h"
#include "../kernel/config.h"
#include "../kernel/status.h"

int validate_heap_size(size_t size)
{   
    // if the size of the heap is a multiple of block size,
    // that's ok
    return !(size % EPSILONOS_HEAP_BLOCK_SIZE);
}

int create_heap(struct heap* target_heap, void* heap_saddr, struct heap_table* target_heap_table, heap_table_entry* heap_table_entires_adddress, int heap_size)
{

    int status = 0;
    if (!validate_heap_size(heap_size))
    {
        status = -EINVARG;
        goto out;
    }
    //
    int total_blocks = heap_size / EPSILONOS_HEAP_BLOCK_SIZE;

    // initialize the heap struct
    memset(target_heap, 0, sizeof(struct heap));
    target_heap->saddr = heap_saddr;
    target_heap->table = target_heap_table;

    // initialize the heap table struct
    target_heap_table->entries = heap_table_entires_adddress;
    target_heap_table->total_entries = total_blocks;    
    
    // don't initialize heap data pool  
    /// memset(heap_saddr, 0, heap_size);

    // mark all of the blocks as FREE
    memset(heap_table_entires_adddress, HEAP_ENTRY_FREE, total_blocks);

out:
    return status;
}

size_t allign_size(size_t size)
{
    // if the give size is a multiple of bloc size,
    // return itself
    if ((size % EPSILONOS_HEAP_BLOCK_SIZE) == 0)
    {
        return size;
    }

    // otherwise round it up to th nearest multiple of block size
    return (size / EPSILONOS_HEAP_BLOCK_SIZE) * EPSILONOS_HEAP_BLOCK_SIZE + EPSILONOS_HEAP_BLOCK_SIZE;
}

int is_free_block(heap_table_entry entry)
{   
    // check the lower nibble of the entry
    if ((entry & (heap_table_entry)HEAP_ENTRY_TAKEN) == (heap_table_entry)HEAP_ENTRY_TAKEN)
    {
        return 0;
    }
    return 1;   
}

int find_free_blocks_number(struct heap* target_heap, int n_blocks)
{

    heap_table_entry* entries = target_heap->table->entries;


    int n_free_block_found = 0;
    int total_entries = target_heap->table->total_entries;

    
    for (int i = 0 ; i < total_entries ; i++)
    {
        // find the first free block
        if (is_free_block(entries[i]))
        {   
            // if we only need 1 of them
            // return it
            if (n_blocks == 1)
            {
                return i;
            }

            // otherwise count it
            // and go forward for more free blocks
            n_free_block_found = 1;

            // start from the next block
            int j;
            for (j = i + 1 ; j < total_entries ; j++)
            {
                // if it is free count it
                if (is_free_block(entries[j]))
                {
                    n_free_block_found++;

                    // if we find the total blocks need,
                    // return the index of the entry of the first block
                    if (n_free_block_found == n_blocks)
                    {
                        return i;
                    }
                }

                // otherwise, if the block is not free and we've not found as many free blocks as needed
                // go forward and look for it
                else
                {
                    i = j + 1;
                    break;
                }
            }
        }
    }

    // if we've reached to the end of the entries,
    // and there is no enough contiguous free blocks,
    // return no memory error staus
    return -ENOMEM;
}

void* block_number_to_address(int block_number, void* saddr)
{
    return (void*)(block_number * EPSILONOS_HEAP_BLOCK_SIZE + (int)saddr);
}

int address_to_block_number(void* ptr, void* saddr)
{
    return ((int)(ptr - saddr)) / EPSILONOS_HEAP_BLOCK_SIZE;
}

void mark_blocks_taken(struct heap* target_heap, int starting_block_number, size_t n_blocks)
{
    heap_table_entry* entries = target_heap->table->entries;

    // if there is only one block
    // it is the first and there is no other block
    if (n_blocks == 1)
    {
        entries[starting_block_number] = (heap_table_entry)(HEAP_ENTRY_IS_FIRST | HEAP_ENTRY_TAKEN);
    }
    else
    {
        // the first block
        entries[starting_block_number] =  (heap_table_entry)(HEAP_ENTRY_IS_FIRST | HEAP_ENTRY_CONTINUED | HEAP_ENTRY_TAKEN);

        // the middle blocks
        for (int i = 1 ; i < n_blocks - 1 ; i++)
        {
            entries[starting_block_number + i] = (heap_table_entry)(HEAP_ENTRY_CONTINUED | HEAP_ENTRY_TAKEN);
        }

        // the end block
        entries[starting_block_number + n_blocks - 1] = (heap_table_entry)(HEAP_ENTRY_TAKEN);

    }

    return;
}

void* heap_malloc(struct heap* target_heap, size_t size)
{

    ///int status = 0;
    // aliigne the requsted size to a multiple of bloc sie
    int alligned_size = allign_size(size);

    size_t n_blocks = alligned_size / EPSILONOS_HEAP_BLOCK_SIZE;

    int starting_block_number = find_free_blocks_number(target_heap, n_blocks);

    // check whether there is an error
    if (starting_block_number == -ENOMEM)
    {
        return 0;
    }

    // conert the index to physical address
    void* free_saddr = block_number_to_address(starting_block_number, target_heap->saddr);

    mark_blocks_taken(target_heap, starting_block_number, n_blocks);


    return free_saddr;
}

void heap_free(struct heap* target_heap, void* ptr)
{   
    // find the index of the given address
    int block_number = address_to_block_number(ptr, target_heap->saddr);

    heap_table_entry* entries = target_heap->table->entries;

    // i is offset from the block we want to deallocate
    for (int i = 0 ; ; i++)
    {
        // if there is another entiry left,
        // mark it as free
        if ((entries[block_number + i]) & (heap_table_entry)HEAP_ENTRY_CONTINUED)
        {
            entries[block_number + i] = (heap_table_entry)HEAP_ENTRY_FREE;
        }
        // otherwise mark it as free,
        // and get out of the loop
        else
        {   
            entries[block_number + i] = (heap_table_entry)HEAP_ENTRY_FREE;
            break;
        }
    }

    return;
}