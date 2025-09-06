.option norvc
    .section .text
    .globl _start
_start:
    # Print "Hi\n" via MMIO
    la   t0, UART_TX
    li   t1, 'H'
    sw   t1, 0(t0)
    li   t1, 'i'
    sw   t1, 0(t0)
    li   t1, '\n'
    sw   t1, 0(t0)

    # Quick load/store/branch smoke test
    la   t2, TESTLOC
    li   t3, 0x12345678
    sw   t3, 0(t2)
    lw   t4, 0(t2)
    bne  t3, t4, fail

pass:
    la   t5, SIM_EXIT
    li   t6, 1
    sw   t6, 0(t5)
    j    .

fail:
    la   t5, SIM_EXIT
    li   t6, 0         # exit code 0 = non-pass; will print EXIT code
    sw   t6, 0(t5)
    j    .

    .section .rodata
    .equ UART_TX,  0xF0010000
    .equ SIM_EXIT, 0xF0010004
    .equ TESTLOC,  0x80010000
