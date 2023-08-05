ENTRY(_start)
OUTPUT_FORMAT(binary)

SECTIONS {
    . = 0X100000;

    .text {
        *(.text)
    }

    .rodata {
        *(.rodata)
    }

    .data {
        *(.data)
    }

    .bss {
        *(COMMON)
        *(.bss)
    }
}
