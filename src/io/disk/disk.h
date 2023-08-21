#ifndef DISK_H
#define DISK_H

#include <stdint.h>
#include "../io.h"

#define READ_ATA_LBA_PORT_TO_SEND_BITS_24_TO_27_OF_LBA                 0x1f6
#define READ_ATA_LBA_MASK_UPPER_NIBBLE_MASK_WHEN_SENDING_BITS_24_TO_27              0b11100000
#define READ_ATA_LBA_PORT_TO_SNED_NUMBER_OF_SECTORS                                 0x1f2
#define READ_ATA_LBA_PORT_TO_SEND_BITS_0_T0_7_OF_LBA                                0x1f3
#define READ_ATA_LBA_PORT_TO_SEND_BITS_8_TO_15_OF_LBA                               0x1f4
#define READ_ATA_LBA_PORT_TO_SEND_BITS_16_TO_23_OF_LBA                              0x1f5
#define READ_ATA_LBA_PORT_TO_SEND_COMMAND                                           0x1f7
#define READ_ATA_LBA_COMMAND_READ_WITH_RETRY                                        0x20
#define READ_ATA_LBA_MASK_READY_TO_READ                                             0b00001000
#define READ_ATA_LBA_PORT_TO_READ_DATA                                              0x1f0

#define WORDS_PER_SECTOR                                                            256

void ata_lba_read(int lba, int total, void* buf);

#endif