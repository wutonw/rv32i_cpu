.section .text.start
.globl _start

_start:
    /* Linker keeps ordinary data below this address; stack grows downward. */
    la sp, __stack_top

    # 清零 .bss
    la t0, __bss_start
    la t1, __bss_end

.Lclear_bss:
    bgeu t0, t1, .Lbss_done
    sw zero, 0(t0)
    addi t0, t0, 4
    j .Lclear_bss

.Lbss_done:
    la t0, trap_entry
    csrw mtvec, t0

    call main

1:
    j 1b
