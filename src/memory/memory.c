#include "memory.h"

/*
 * set n bytes with c starting from byte pointed by 's'
 * 
 * @param   s           starting address
 * @param   c           value to be set(byte)
 * @param   n           number of bytes to set    
 * @return  void    
 */
void* memset(void* s, int c, int n)
{   
    char* ptr = (char*)s;
    for (int i = 0 ; i < n ; i++)
    {
        ptr[i] = (char)c;
    }

    return s;
}