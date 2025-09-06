# Convert a raw little-endian binary to a $readmemh()-friendly hex (one 32-bit LE word per line)
# Usage: python3 elf2hex.py input.bin output.hex
import sys, struct

if len(sys.argv) != 3:
    print("Usage: python3 elf2hex.py <in.bin> <out.hex>")
    raise SystemExit(1)

inp, outp = sys.argv[1], sys.argv[2]
with open(inp, "rb") as f:
    data = f.read()

# pad to multiple of 4 bytes
if len(data) % 4 != 0:
    data += b"\x00" * (4 - (len(data) % 4))

with open(outp, "w") as w:
    for i in range(0, len(data), 4):
        word = struct.unpack("<I", data[i:i+4])[0]
        w.write(f"{word:08x}\n")
