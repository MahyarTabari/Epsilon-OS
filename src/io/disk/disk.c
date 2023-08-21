#include "disk.h"


void ata_lba_read(uint32_t lba, uint8_t total_sectors_to_read, void* buf)
{
    unsigned short* ptr = (unsigned short*)buf;
    outb(READ_ATA_LBA_PORT_TO_SEND_BITS_24_TO_27_OF_LBA, ((unsigned short)(lba >> 24)) | READ_ATA_LBA_MASK_UPPER_NIBBLE_MASK_WHEN_SENDING_BITS_24_TO_27);
    outb(READ_ATA_LBA_PORT_TO_SNED_NUMBER_OF_SECTORS, total_sectors_to_read);
    outb(READ_ATA_LBA_PORT_TO_SEND_BITS_0_T0_7_OF_LBA, (unsigned short)(lba & 0xff));
    outb(READ_ATA_LBA_PORT_TO_SEND_BITS_8_TO_15_OF_LBA, (unsigned short)((lba >> 8) & 0xff));
    outb(READ_ATA_LBA_PORT_TO_SEND_BITS_16_TO_23_OF_LBA, (unsigned short)((lba >> 16) & 0xff));
    outb(READ_ATA_LBA_PORT_TO_SEND_COMMAND, READ_ATA_LBA_COMMAND_READ_WITH_RETRY);

    for (int read_sectors = 0 ; read_sectors < total_sectors_to_read ; read_sectors++)
    {
        uint8_t test = insb(READ_ATA_LBA_PORT_TO_SEND_COMMAND);
        // wait until the bit 3 is set
        while ((test & READ_ATA_LBA_MASK_READY_TO_READ) == 0b00000000)
        {
            test = insb(READ_ATA_LBA_PORT_TO_SEND_COMMAND);
        }


        // read 256 words(1 sector)
        for (int read_words = 0 ; read_words < WORDS_PER_SECTOR ; read_words++)
        {
            *ptr = insw(READ_ATA_LBA_PORT_TO_READ_DATA);
            ptr++;
        }
    }

    return;
}