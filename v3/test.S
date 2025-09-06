    .option norvc
    .section .text
    .globl _start
_start:
    # setup base address (0x80000100)
    lui   x31, 0x80000        # 0x80000FB7
    addi  x31, x31, 0x100     # 0x100F8F93

    # store 99 to [0x80000100]
    li    x5, 99              # 0x06300293
    sw    x5, 0(x31)          # 0x005FA023

    # === load-use hazard sequence ===
    lw    x6, 0(x31)          # 0x000FA303   (x6 = mem[0x80000100])
    addi  x7, x6, 1           # 0x00130393   (x7 = x6 + 1) <-- hazard!

    # tell testbench PASS
    li    x10, 1              # 0x00100513
    lui   x11, 0xF0010        # 0xF00105B7
    addi x11, x11, 0x004      # 0x00458593
    sw    x10, 0(x11)         # 0x00A5A023

done:
    j .                       # 0x0000006F

