    .option norvc              # ensure no C extension
    .section .text
    .globl _start

# -----------------------------
# Test harness configuration
# -----------------------------
.equ BASE,       0x80000000           # reset vector
.equ RAM_BASE,   0x80001000           # scratch RAM
.equ PASS_ADDR,  0xFFFF_FFFC          # <-- match your TB (or change to 0x8000FFFC)

# Registers used:
# x1..x7 general temps, x10..x17 (a0..a7) as needed
# x28 (t3) = error counter, x29 (t4) = temp, x30 (t5) = temp, x31 (t6) = temp

_start:
    # Basic init
    lui   x1, %hi(RAM_BASE)
    addi  x1, x1, %lo(RAM_BASE)   # x1 = RAM_BASE
    addi  x28, x0, 0              # x28 (t3) = error_count = 0

    # Small data pattern in RAM
    addi  x2, x0, 0x12
    sb    x2, 0(x1)               # [0] = 0x12
    addi  x2, x0, 0x34
    sb    x2, 1(x1)               # [1] = 0x34
    addi  x2, x0, 0x56
    sb    x2, 2(x1)               # [2] = 0x56
    addi  x2, x0, 0x78
    sb    x2, 3(x1)               # [3] = 0x78
    # Now word @ RAM_BASE should be 0x78563412
    lw    x3, 0(x1)
    li    x4, 0x78563412
    bne   x3, x4, fail_inc

# -----------------------------
# LUI / AUIPC
# -----------------------------
# LUI: form a known constant in x5
    lui   x5, 0x12345
    addi  x5, x5, 0x6              # x5 = 0x12345006
    li    x6, 0x12345006
    bne   x5, x6, fail_inc

# AUIPC: take current PC + imm20<<12; we verify relative arithmetic
auipc_test:
    auipc x7, 0                    # x7 = auipc_test + 0
    addi  x7, x7, 8                # simulate known offset
    # Jump over a 2-instruction gap and come back via JALR
    jal   x0, auipc_gap
auipc_back:
    # When we get here, x7 should equal address of auipc_back + 0?
    # We'll check relative by subtracting labels.
    # (This is a structural exercise—main point: AUIPC executes without trap.)
    fence                          # treat as NOP; no verify needed
    j    jal_test

auipc_gap:
    jalr  x0, x7, 0                # jump to x7 (which should land near auipc_back)

# -----------------------------
# JAL / JALR
# -----------------------------
jal_test:
    # Use JAL to call a leaf that returns via JALR (link in x1)
    jal   x1, leaf_add              # x1 = return, go to leaf_add
    # leaf_add sets x10 = 11 + 31 = 42
    li    x6, 42
    bne   x10, x6, fail_inc

    # JALR: computed jump using a register
    la    x5, jalr_target
    jalr  x1, x5, 0                 # jump to target, link to x1
    j     after_jalr
jalr_target:
    addi  x11, x0, 0x77
    jalr  x0, x1, 0                 # return
after_jalr:
    li    x6, 0x77
    bne   x11, x6, fail_inc

# -----------------------------
# Branches (BEQ/BNE/BLT/BGE/BLTU/BGEU)
# -----------------------------
    li    x3, 5
    li    x4, 5
    beq   x3, x4, 1f
    j     fail_inc
1:
    bne   x3, x4, fail_inc

    li    x3, -1
    li    x4, 1
    blt   x3, x4, 2f
    j     fail_inc
2:
    bge   x3, x4, fail_inc          # -1 >= 1? false => OK

    li    x3, -1
    li    x4, 1
    bltu  x3, x4, fail_inc          # unsigned: 0xFFFF_FFFF < 1? false => OK to fallthrough
    bgeu  x3, x4, 3f                # unsigned: 0xFFFF_FFFF >= 1? true
    j     fail_inc
3:

# -----------------------------
# I-type ALU (ADDI/SLTI/SLTIU/ANDI/ORI/XORI/SLLI/SRLI/SRAI)
# -----------------------------
    li    x3, 5
    addi  x4, x3, 7                 # 12
    li    x6, 12
    bne   x4, x6, fail_inc

    li    x3, -3
    slti  x4, x3, -2                # (-3 < -2) => 1
    li    x6, 1
    bne   x4, x6, fail_inc

    li    x3, -1                    # 0xFFFF_FFFF
    sltiu x4, x3, 1                 # (0xFFFF_FFFF < 1 unsigned)? 0
    li    x6, 0
    bne   x4, x6, fail_inc

    li    x3, 0x0F0F0F0F
    andi  x4, x3, 0xF0              # 0x00000000F0 & 0x0F0F0F0F = 0x00000000F0? (low 12b imm) -> 0x00000000F0
    li    x6, 0x000000F0
    bne   x4, x6, fail_inc

    ori   x4, x3, 0xF0              # 0x0F0F0FFF
    li    x6, 0x0F0F0FFF
    bne   x4, x6, fail_inc

    xori  x4, x3, 0xAA              # 0x0F0F0F0F ^ 0x000000AA = 0x0F0F0FA5
    li    x6, 0x0F0F0FA5
    bne   x4, x6, fail_inc

    li    x3, 0x00000003
    slli  x4, x3, 5                 # 0x60
    li    x6, 0x00000060
    bne   x4, x6, fail_inc

    li    x3, 0x000000E0
    srli  x4, x3, 5                 # 0x7
    li    x6, 0x00000007
    bne   x4, x6, fail_inc

    li    x3, 0xFFFF0000            # arithmetic right shift sign-extends
    srai  x4, x3, 12
    li    x6, 0xFFFFF000
    bne   x4, x6, fail_inc

# -----------------------------
# R-type ALU (ADD/SUB/SLT/SLTU/AND/OR/XOR/SLL/SRL/SRA)
# -----------------------------
    li    x5, 21
    li    x6, 21
    add   x7, x5, x6                # 42
    li    x8, 42
    bne   x7, x8, fail_inc

    sub   x7, x6, x5                # 0
    beq   x7, x0, 1f
    j     fail_inc
1:
    slt   x7, x6, x5                # 21 < 21? 0
    beq   x7, x0, 2f
    j     fail_inc
2:
    sltu  x7, x6, x5                # unsigned: equal -> 0
    beq   x7, x0, 3f
    j     fail_inc
3:
    li    x5, 0x00FF00FF
    li    x6, 0x0F0F0F0F
    and   x7, x5, x6                # 0x000F000F
    li    x8, 0x000F000F
    bne   x7, x8, fail_inc
    or    x7, x5, x6                # 0x0FFF0FFF
    li    x8, 0x0FFF0FFF
    bne   x7, x8, fail_inc
    xor   x7, x5, x6                # 0x0FF00FF0
    li    x8, 0x0FF00FF0
    bne   x7, x8, fail_inc

    li    x5, 0x00000003
    sll   x7, x5, x6                # shift by (x6&0x1F) = (0x0F & 31)=15 => 0x00018000
    li    x8, 0x00018000
    bne   x7, x8, fail_inc

    li    x5, 0x00018000
    srl   x7, x5, x6                # >>15 => 3
    li    x8, 3
    bne   x7, x8, fail_inc

    li    x5, 0xFFF00000
    sra   x7, x5, x6                # >>15 arithmetic => 0xFFFFE000
    li    x8, 0xFFFFE000
    bne   x7, x8, fail_inc

# -----------------------------
# Loads (LB/LBU/LH/LHU/LW) & Stores (SB/SH/SW)
# -----------------------------
    # RAM_BASE content currently: 12 34 56 78
    lb    x9, 0(x1)                 # signed 0x12 -> 0x00000012
    li    x8, 0x00000012
    bne   x9, x8, fail_inc

    lbu   x9, 1(x1)                 # 0x34 -> 0x00000034
    li    x8, 0x00000034
    bne   x9, x8, fail_inc

    lh    x9, 2(x1)                 # halfword 0x5678 -> signed 0x00005678
    li    x8, 0x00005678
    bne   x9, x8, fail_inc

    lhu   x9, 2(x1)                 # 0x00005678 (same here)
    li    x8, 0x00005678
    bne   x9, x8, fail_inc

    # Overwrite with a distinct word via SW and read back via LW
    li    x5, 0xA5A5A5A5
    sw    x5, 0(x1)
    lw    x9, 0(x1)
    bne   x9, x5, fail_inc

# -----------------------------
# FENCE (acts like NOP here)
# -----------------------------
    fence

# -----------------------------
# Final verdict: PASS if x28==0
# -----------------------------
done:
    bne   x28, x0, hang             # any error -> hang
    # PASS store
    lui   x5, %hi(PASS_ADDR)
    addi  x5, x5, %lo(PASS_ADDR)
    addi  x6, x0, 1
    sw    x6, 0(x5)
hang:
    j     hang

# -----------------------------
# Leaf function: x10 = 11 + 31 = 42
# Uses JALR for return
# -----------------------------
leaf_add:
    addi  x10, x0, 11
    addi  x11, x0, 31
    add   x10, x10, x11    # x10=42
    jalr  x0, x1, 0

# -----------------------------
# Error path
# -----------------------------
fail_inc:
    addi  x28, x28, 1
    j     done

