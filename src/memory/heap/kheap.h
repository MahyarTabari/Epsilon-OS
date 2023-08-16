#ifndef KHEAP_H
#define KHEAP_H

#include <stddef.h>

#define KERNEL_HEAP_ADDRESS     0X1000000
#define KERNEL_HEAP_SIZE        100 * 1024 * 1024
#define KERNEL_HEAP_TABLE_ADDRESS  0x00007E00

/*
 * creates a heap for kernel with size specified by KERNEL_HEAP_ADDRESS, KERNEL_HEAP_SIZE and KERNEL_HEAP_TABLE_ADDRESS
 *
 * @return  void   
 */
void initialize_kheap();

/*
 * allocates memory in kernel heap
 * 
 * @param   size        number of bytes to allocate: this will be alligned with allign_size() function  
 * @return  void*       address of the first byte of allocated block(s)
 */
void* kmalloc(size_t size);

/*
 * allocates memory in kernel heap and zero-initializes it
 * 
 * @param   size        number of bytes to allocate: this will be alligned with align_size() funciton
 * @return  void*       address of the first byte of allocated block(s)
 */
void* kzalloc(size_t size);

/*
 * unallocates the block(s) specified by the physical address of the first block
 * 
 * @param   ptr         physical address of the first block   
 * @return  void  
 */
void kfree(void* ptr);
#endif