    .option norvc
    .section .text
    .globl _start
_start:
    # producer
    addi x5, x0, 42         # 0x02A00293   -> x5 = 42
    # consumer immediately uses x5
    addi x6, x0, 1          # 0x00128313   -> x6 = 43

    # PASS exit
    li   x10, 1
    lui  x11, 0xF0010
    addi x11, x11, 0x004
    sw   x10, 0(x11)

done:
    j .

