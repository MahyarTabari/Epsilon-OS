#ifndef HEAP_h
#define HEAP_h

#define HEAP_ENTRY_FREE         0b00000000
#define HEAP_ENTRY_TAKEN        0b00000001
#define HEAP_ENTRY_IS_FIRST     0b10000000
#define HEAP_ENTRY_CONTINUED    0b01000000

#include <stddef.h>
typedef unsigned char heap_table_entry;



struct heap_table
{
    heap_table_entry* entries;
    int total_entries;
};

struct heap
{   
    // starting address of data pool
    void* saddr;
    struct heap_table* table;

};

/*
 * check whether heap siza is fit into the block size of the OS defined in "config.h"
 * 
 * @param   size        heap size in bytes
 * @param   c           value to be set(byte)
 * @param   n           number of bytes to set    
 * @return  int         non zero if OK, otherwise 0
 */
int validate_heap_size(size_t size);

/*
 * set up the heap data pool and the heap table,
 * according to the specified arguments
 * 
 * @param   target_heap                     pointer to the heap struct
 * @param   heap_saddr                      pointer to the first byte of data pool
 * @param   target_heap_table               pointer to the heap table struct   
 * @param   heap_table_entries_address      pointer to the first entry in the table
 * @param   heap_size                       heap size in bytes
 * @return  int                             0 if OK, negative value when error   
 */
int create_heap(struct heap* target_heap, void* heap_saddr, struct heap_table* target_heap_table, heap_table_entry* heap_table_entires_adddress, int heap_size);

/*
 * set n bytes with c starting from byte pointed by 's'
 * 
 * @param   size        requested memory size in bytes
 * @return  int         alligned size according to block size in "config.h"   
 */
size_t allign_size(size_t size);

/*
 * finds the specified number of free contiguous blocks
 *
 * @param   target_heap         the heap we want to find free block(s) in it
 * @param   n_blocks            number of free contiguous blocks needed to find            
 * @return  int                 index of first entry or negative value when error
 */
int find_free_blocks_number(struct heap* target_heap, int n_blocks);

/*
 * calculates physical address of the specified block
 * 
 * @param   block_number            block number to be converted
 * @param   saddr                   starting address of the heap
 * @return  void*                   physical address of the given block number    
 */
void* block_number_to_address(int block_number, void* saddr);

/*
 * calculates the block number of the given address
 * 
 * @param   ptr         physical address of the chuck of memory in data pool
 * @param   saddr       starting address of the heap data pool 
 * @return  int         block number(index of the heap table entry)   
 */
int address_to_block_number(void* ptr, void* saddr);

/*
 * marks the entires as taken
 * 
 * @param   target_heap                    pointer to the heap struct
 * @param   starting_block_number          the starting block to mark
 * @param   n_blocks                       total number of blocks to mark
 * @return  void   
 */
void mark_blocks_taken(struct heap* target_heap, int starting_block_number, size_t n_blocks);

/*
 * allocates memory in the given heap
 * size will be alligned with allign_size() function
 * 
 * @param   target_heap     the heap to allocate memory in it
 * @param   size            the number of bytes to allocate
 * @return  void*           physical address of the first block of the allocated memory or 0 if there is no available memory
 */
void* heap_malloc(struct heap* target_heap, size_t size);

/*
 * unallocates the memory starting from the given physical address
 * 
 * @param   target_heap     the pointer to heap struct
 * @param   ptr             pointer to the first allocated byte
 * @return  void   
 */
void heap_free(struct heap* target_heap, void* ptr);

#endif