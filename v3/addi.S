    .option norvc
    .section .text
    .globl _start
_start:
    # === instruction under test ===
    addi x18, x0, 0x20          # x18 = 0x20

    # === tell testbench PASS ===
    li   x10, 1
    lui  x11, 0xF0010
    addi x11, x11, 0x004        # x11 = 0xF0010004
    sw   x10, 0(x11)            # write 1 -> SIM_EXIT

done:
    j .

