    .option norvc
    .section .text
    .globl _start
_start:
    ebreak                   # 0x00100073

    li   x10, 1
    lui  x11, 0xF0010
    addi x11, x11, 0x004
    sw   x10, 0(x11)
done:
    j .

