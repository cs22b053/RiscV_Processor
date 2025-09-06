.option norvc
    .section .text
    .globl _start
_start:
    # Byte/halfword store+load (sign/zero) checks
    la   t0, BASE
    li   t1, 0
    sw   t1, 0(t0)

    li   t1, 0xA5
    sb   t1, 0(t0)       # mem[0]=0xA5
    lbu  t2, 0(t0)       # t2=0xA5
    li   t3, 0xA5
    bne  t2, t3, fail

    li   t1, 0xBEEF
    sh   t1, 2(t0)       # mem[2]=0xEF, mem[3]=0xBE
    lhu  t2, 2(t0)       # t2=0xBEEF
    li   t3, 0xBEEF
    bne  t2, t3, fail

    # All good
    la   t4, UART_TX
    li   t5, 'O'
    sw   t5, 0(t4)
    li   t5, 'K'
    sw   t5, 0(t4)
    li   t5, '\n'
    sw   t5, 0(t4)

    la   t6, SIM_EXIT
    li   t7, 1
    sw   t7, 0(t6)
    j    .

fail:
    la   t6, SIM_EXIT
    li   t7, 0
    sw   t7, 0(t6)
    j    .

    .section .rodata
    .equ UART_TX,  0xF0010000
    .equ SIM_EXIT, 0xF0010004
    .equ BASE,     0x80010000
