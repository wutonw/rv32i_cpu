#include <stdint.h>

/*
 * Data RAM is 32 KiB (0x0000..0x7fff).  The linker reserves the very top
 * eight bytes for a simulator/ILA signature.  Ordinary C static data stays
 * below 0x7000 and the reserved stack grows down from 0x7fb0.
 */
#define SIGNATURE_ADDR  0x7ff8u
#define PASS_SIGNATURE  0x600dcafeu
#define FAIL_SIGNATURE  0xdead0001u

enum {
    CAUSE_INST_MISALIGNED  = 0,
    CAUSE_ILLEGAL_INST     = 2,
    CAUSE_BREAKPOINT       = 3,
    CAUSE_LOAD_MISALIGNED  = 4,
    CAUSE_STORE_MISALIGNED = 6,
    CAUSE_ECALL_M          = 11
};

typedef struct {
    uint32_t count;
    uint32_t last_cause;
    uint32_t last_epc;
} trap_info_t;

volatile trap_info_t trap_info;

static void fatal_trap(uint32_t cause, uint32_t epc)
{
    volatile uint32_t *signature =
        (volatile uint32_t *)SIGNATURE_ADDR;

    signature[0] = 0xdead0000u | cause;
    signature[1] = epc;

    while (1) {
    }
}

static void handle_ecall(void)
{
    /* 以后可以在这里实现自己的简易系统调用。 */
}

uint32_t trap_handler(uint32_t cause, uint32_t epc)
{
    trap_info.count++;
    trap_info.last_cause = cause;
    trap_info.last_epc = epc;

    switch (cause) {
    case CAUSE_ECALL_M:
        handle_ecall();
        return epc + 4;

    case CAUSE_BREAKPOINT:
        return epc + 4;

    case CAUSE_ILLEGAL_INST:
        fatal_trap(cause, epc);
        break;

    case CAUSE_LOAD_MISALIGNED:
        fatal_trap(cause, epc);
        break;

    case CAUSE_STORE_MISALIGNED:
        fatal_trap(cause, epc);
        break;

    case CAUSE_INST_MISALIGNED:
        fatal_trap(cause, epc);
        break;

    default:
        fatal_trap(cause, epc);
        break;
    }

    return epc;
}

/*
 * Small integer/branch/memory regression.  Keeping the array volatile makes
 * sure the compiler really emits RAM stores and loads instead of folding the
 * whole test away.
 */
static uint32_t run_loop_test(void)
{
    volatile uint32_t data[8];
    uint32_t i;
    uint32_t sum = 0u;

    /* Fill and read back an array: 3 + 4 + ... + 10 = 52. */
    for (i = 0u; i < 8u; i++) {
        data[i] = i + 3u;
        sum += data[i];
    }

    /* Reverse the array.  This adds more loads, stores and loop branches. */
    for (i = 0u; i < 4u; i++) {
        uint32_t tmp = data[i];
        data[i] = data[7u - i];
        data[7u - i] = tmp;
    }

    for (i = 0u; i < 4u; i++) {
        if (data[i] != (10u - i) ||
            data[7u - i] != (3u + i)) {
            return 0u;
        }
    }

    return (sum == 52u) ? 1u : 0u;
}

/* A small first real firmware program.  It deliberately executes ecall so
 * the complete C -> trap_entry.S -> trap_handler -> mret path is exercised.
 */
int main(void)
{
    volatile uint32_t *signature =
        (volatile uint32_t *)SIGNATURE_ADDR;
    uint32_t value = 21u;

    value = (value << 1) + 1u;       /* 43 */

    __asm__ volatile ("ecall");

    if (trap_info.count == 1u &&
        trap_info.last_cause == CAUSE_ECALL_M &&
        value == 43u &&
        run_loop_test() == 1u) {
        signature[0] = PASS_SIGNATURE;
        signature[1] = 52u;
    } else {
        signature[0] = FAIL_SIGNATURE;
        signature[1] = trap_info.last_cause;
    }

    while (1) {
        __asm__ volatile ("nop");
    }
}
