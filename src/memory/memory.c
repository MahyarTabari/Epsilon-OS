#include "memory.h"

void* memset(void* s, int c, int n)
{   
    char* ptr = (char*)ptr;
    for (int i = 0 ; i < n ; i++)
    {
        ptr[i] = (char)c;
    }

    return s;
}