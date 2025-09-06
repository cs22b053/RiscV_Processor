    .option norvc
    .section .text
    .globl _start
_start:
    li   x5, 1
    li   x6, 1
    beq  x5, x6, target     # should branch
    addi x7, x0, 0x55       # should be flushed if branch taken
target:
    addi x7, x0, 0xAA       # executed after branch

    # PASS exit
    li   x10, 1
    lui  x11, 0xF0010
    addi x11, x11, 0x004
    sw   x10, 0(x11)

done:
    j .

