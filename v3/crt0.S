    .option  norvc
    .section .init
    .globl _start
_start:
    .option push
    .option norelax
    la   sp, _stack_top        # simple static stack
    .option pop

    # Call main()
    call main

1:  j 1b                       # if main returns, loop

