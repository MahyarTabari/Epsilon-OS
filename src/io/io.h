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
extern void outb(uint32_t port, uint32_t out);

/*
 * ouputs a word to the specified port
 * 
 * @param   port        port to send the byte
 * @param   out         the word to be sent       
 * @return  void   
 */
extern void outw(uint32_t port, uint32_t );

/*
 * ouputs 4 bytes(double word) to the specified port
 * 
 * @param   port        port to send the byte
 * @param   out         the double word to be sent       
 * @return  void    
 */
extern void outdw(uint32_t port, uint32_t out);


/*
 * reads one byte from the specified port
 * 
 * @param   port        port to read the byte     
 * @return  byte read form the specified port   
 */
extern uint32_t insb(uint32_t port);

/*
 * reads one byte from the specified port
 * 
 * @param   port        port to read the word     
 * @return  word read form the specified port   
 */
extern uint32_t insw(uint32_t port);

/*
 * reads one byte from the specified port
 * 
 * @param   port        port to read the double word   
 * @return  double word read form the specified port   
 */
extern uint32_t insdw(uint32_t port);

#endif