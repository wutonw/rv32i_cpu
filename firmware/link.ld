OUTPUT_ARCH(riscv)
ENTRY(_start)

/* 当前 CPU 是分离的指令/数据通路：指令 ROM 和数据 RAM 各自从 0 开始。 */
MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 2K
    /* 普通静态数据：0x0000..0x6fff。 */
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x7000
}

SECTIONS
{
    /* 指令 ROM 内容；objcopy 时只导出 .text/.rodata。 */
    .text ORIGIN(ROM) : ALIGN(4)
    {
        KEEP(*(.text.start))
        *(.text*)
    } > ROM

    .rodata : ALIGN(4)
    {
        *(.rodata*)
    } > ROM

    /* 当前硬件不能从指令 ROM 向数据 RAM 搬运 .data；先只使用 .bss。 */
    .data ORIGIN(RAM) : ALIGN(4)
    {
        __data_start = .;
        *(.data*)
        *(.sdata*)
        __data_end = .;
    } > RAM

    .bss (NOLOAD) : ALIGN(4)
    {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        *(.sbss*)
        __bss_end = .;
    } > RAM

    . = ALIGN(4);
    /* 0x7000..0x7faf 是栈区，栈从 0x7fb0 向低地址增长。 */
    PROVIDE(__stack_bottom = 0x00007000);
    PROVIDE(__stack_top = 0x00007fb0);
    PROVIDE(__signature_addr = 0x00007ff8);

    ASSERT(SIZEOF(.text) + SIZEOF(.rodata) <= LENGTH(ROM),
           "firmware code exceeds instruction ROM")
    ASSERT(__bss_end <= __stack_bottom,
           "firmware data overlaps reserved stack")
    ASSERT(SIZEOF(.data) == 0,
           "initialized .data is not supported yet; use zero-initialized globals")
}
