#include <stdint.h>
#define PASS_ADDR 0x8000FFFCu   // if that matches your testbench


volatile uint32_t * const PASS = (uint32_t *)PASS_ADDR;

int main(void) {
    // Do a little math to exercise ALU (all RV32I)
    volatile uint32_t a = 42, b = 43;
    volatile uint32_t c = a + b;      // ADD/ADDI path
    (void)c;

    // Optional tiny memory poke to exercise SW
    volatile uint32_t *p = (uint32_t*)0x80001000u;
    *p = 0xA5A5A5A5u;

    // Signal PASS to the testbench
    *PASS = 1u;                       // SW to PASS_ADDR
    for(;;) {}                        // stay alive
}

