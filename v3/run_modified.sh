riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o test.o test.S
riscv64-unknown-elf-ld -m elf32lriscv -Ttext=0x80000000 -o test.elf test.o
riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=4 test.elf mem.tmp
grep -v '^@' mem.tmp > mem.hex

vlog -sv +acc VexRiscv.v tb_vexriscv.v
vsim -voptargs=+acc tb_vexriscv
run -all

