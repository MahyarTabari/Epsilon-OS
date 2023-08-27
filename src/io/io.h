#ifndef IO_H
#define IO_H
#include <stdint.h>

/*
 * ouputs one byte to the specified port
 * 
 * @param   port        port to send the byte
 * @param   out         the byte to be sent       
 * @return  void    
 */
extern void outb(unsigned short port, unsigned char out);

/*
 * ouputs a word to the specified port
 * 
 * @param   port        port to send the byte
 * @param   out         the word to be sent       
 * @return  void   
 */
extern void outw(unsigned short port, unsigned short out);

/*
 * ouputs 4 bytes(double word) to the specified port
 * 
 * @param   port        port to send the byte
 * @param   out         the double word to be sent       
 * @return  void    
 */
extern void outdw(unsigned short port, unsigned  out);


/*
 * reads one byte from the specified port
 * 
 * @param   port        port to read the byte     
 * @return  byte read form the specified port   
 */
extern unsigned char insb(unsigned short port);

/*
 * reads one byte from the specified port
 * 
 * @param   port        port to read the word     
 * @return  word read form the specified port   
 */
extern uint16_t insw(unsigned short port);

/*
 * reads one byte from the specified port
 * 
 * @param   port        port to read the double word   
 * @return  double word read form the specified port   
 */
extern uint32_t insdw(uint32_t port);

#endif