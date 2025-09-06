    .option norvc
    .section .text
    .globl _start
_start:
    # prepare operands
    addi x18, x0, 0x20        # 0x02000913
    addi x19, x0, 0x03        # 0x00300993

    # === instruction under test ===
    add  x20, x18, x19        # 0x01390A33

    # === tell testbench PASS ===
    li   x10, 1               # 0x00100513
    lui  x11, 0xF0010         # 0xF00105B7
    addi x11, x11, 0x004      # 0x00458593
    sw   x10, 0(x11)          # 0x00A5A023

done:
    j .                       # 0x0000006F

