#ifndef DISK_H
#define DISK_H

#include <stdint.h>

/*
 * read sectors and write them into the specified buffer
 * 
 * @param   lba_sector              logical block address of the starting sector to read
 * @param   c                       number of sectors to read
 * @param   destination_address     buffer to write into it
 * @return  void   
 */
extern void ata_lba_read(uint32_t lba_sector, uint8_t c, void* buffer);

#endif