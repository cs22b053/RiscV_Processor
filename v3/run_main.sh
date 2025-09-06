riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o crt0.o crt0.S
riscv64-unknown-elf-gcc -c main.c -o main.o \
  -march=rv32i -mabi=ilp32 -mcmodel=medany \
  -ffreestanding -fno-builtin -fno-exceptions -fno-asynchronous-unwind-tables \
  -O2

riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 \
  -o app.elf crt0.o main.o -T link.ld \
  -nostdlib -Wl,--no-relax

riscv64-unknown-elf-objcopy -O verilog app.elf app.hex

vlog -sv +acc VexRiscv.v tb_vexriscv.v
vsim -voptargs=+acc tb_vexriscv +HEX=app.hex
