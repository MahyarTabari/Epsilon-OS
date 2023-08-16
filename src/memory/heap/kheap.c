#include "heap.h"
#include "kheap.h"
#include "../../kernel/config.h"
#include "../memory.h"

struct heap kheap;
struct heap_table kheap_table;

void initialize_kheap()
{
    heap_table_entry* kheap_table_entries_address = (heap_table_entry*)KERNEL_HEAP_TABLE_ADDRESS;
    void* kheap_saddr = (void*)KERNEL_HEAP_ADDRESS;
    create_heap(&kheap, kheap_saddr, &kheap_table,  kheap_table_entries_address, KERNEL_HEAP_SIZE);
}

void* kmalloc(size_t size)
{
    return heap_malloc(&kheap, size);
}

void* kzalloc(size_t size)
{
    void* ptr = kmalloc(size);
    memset(ptr, 0, size);
    
    return ptr;
}

void kfree(void* ptr)
{
    heap_free(&kheap, ptr);
}