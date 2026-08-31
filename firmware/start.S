.section .text.start
.globl _start

_start:
    li sp, 0x8000
    call main

1:
    j 1b