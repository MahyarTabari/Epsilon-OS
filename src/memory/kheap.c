#include "heap.h"
#include "kheap.h"
#include "../kernel/config.h"
struct heap kheap;
struct heap_table kheap_table;

void initialize_kheap()
{
    heap_table_entry* kheap_table_entries_address = (heap_table_entry*)KERNEL_HEAP_TABLE_ADDRESS;
    void* kheap_saddr = (void*)KERNEL_HEAP_ADDRESS;
    create_heap(&kheap, kheap_saddr, &kheap_table,  kheap_table_entries_address, KERNEL_HEAP_SIZE);
}

void* kmalloc(int size)
{
    return heap_malloc(&kheap, size);
}

void kfree(void* ptr)
{
    heap_free(&kheap, ptr);
}