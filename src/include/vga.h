#ifndef VGA_H
#define VGA_H
#define VGA_COLUMNS         80
#define VGA_ROWS            25
#define VGA_BLACK           0
#define VGA_BLUE            1
#define VGA_GREEN           2
#define VGA_CYAN            3
#define VGA_RED             4
#define VGA_MAGENTA         5
#define VGA_BROWN           6
#define VGA_LIGHT_GRAY      7
#define VGA_DARK_GRAY       8
#define VGA_LIGHT_BLUE      9
#define VGA_LIGHT_GREEN     10
#define VGA_LIGHT_CYAN      11
#define VGA_LIGHT_RED       12
#define VGA_LIGHT_MAGENTA   13
#define VGA_YELLOW          14
#define VGA_WHITE           15

#define to_video_memory_index(row, col) (row * 80 + col)

#include <stdint.h>
extern uint16_t* TEXT_VIDEO_MEMORY;

#endif