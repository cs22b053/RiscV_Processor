    .option norvc
    .section .text
    .globl _start
_start:
    fence                    # 0x0000000F

    # tell testbench PASS
    li   x10, 1              # 0x00100513
    lui  x11, 0xF0010        # 0xF00105B7
    addi x11, x11, 0x004     # 0x00458593
    sw   x10, 0(x11)         # 0x00A5A023
done:
    j .                      # 0x0000006F

