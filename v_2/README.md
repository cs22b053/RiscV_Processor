# RISC-V Single Cycle Processor Implementation (V2)

This is an implementation of a RISC-V single-cycle processor in SystemVerilog. The processor supports basic RISC-V instructions and is designed with a modular architecture for better understanding and maintainability.

## Architecture Overview

The processor consists of several key modules that work together to execute RISC-V instructions:

### Core Components

1. **Processor (Processor.sv)**
   - Top-level module that integrates all components
   - Manages data and control flow between different modules
   - Implements the single-cycle architecture

2. **Program Counter (PC.sv)**
   - Holds the current instruction address
   - Updates on each clock cycle
   - Handles reset functionality

3. **Add4 (Add4.sv)**
   - Increments PC by 4 for sequential execution
   - Generates the next instruction address

4. **ALU (ALU.sv)**
   - Performs arithmetic and logical operations
   - Supports basic RISC-V ALU operations

### Memory and Storage

1. **Register File (RegisterFile.sv)**
   - 32 x 32-bit general-purpose registers
   - Supports simultaneous read of two registers
   - Write-back capability for instruction results

2. **Data Memory (DataMemory.sv)**
   - Stores data for load/store operations
   - Supports different memory access masks
   - Read/Write operations synchronized with clock

3. **Instruction Memory (InstructionMemory.sv)**
   - Stores program instructions
   - Read-only memory
   - Provides instructions based on PC value

### Control and Processing

1. **Controller (Controller.sv)**
   - Decodes instructions
   - Generates control signals for all modules
   - Determines operation types and data paths

2. **Branch Condition (BranchCondition.sv)**
   - Evaluates branch conditions
   - Determines if branch should be taken
   - Supports different branch types

3. **Immediate Generator (ImmediateGenerator.sv)**
   - Generates immediate values from instructions
   - Supports different immediate formats

4. **Write Back (WriteBack.sv)**
   - Manages data write-back to registers
   - Selects appropriate data source

5. **Mux2 (Mux2.sv)**
   - 2-to-1 multiplexer module
   - Used for selecting between different data paths

## Instruction Support

The processor supports basic RISC-V instructions including:
- Arithmetic operations (ADD, SUB, etc.)
- Logical operations (AND, OR, XOR)
- Load/Store operations
- Branch instructions
- Immediate operations

## Usage

1. The processor can be simulated using ModelSim or other SystemVerilog simulators
2. Use `Processor_TB.sv` as the testbench file
3. Instructions can be loaded through the instruction memory module(instruct.txt).

## Testing

- Use `Processor_TB.sv` for functional verification
- Test different instruction sequences
- Verify register and memory states
- Check branch and jump operations

## File Organization

```
v_2/
├── Add4.sv              # PC Increment module
├── ALU.sv               # Arithmetic Logic Unit
├── BranchCondition.sv   # Branch evaluation
├── Controller.sv        # Control unit
├── DataMemory.sv        # Data memory module
├── ImmediateGenerator.sv# Immediate value generator
├── InstructionMemory.sv # Instruction memory
├── Mux2.sv             # 2-to-1 Multiplexer
├── PC.sv               # Program Counter
├── Processor.sv        # Top-level processor module
├── Processor_TB.sv     # Testbench
├── RegisterFile.sv     # Register file
└── WriteBack.sv        # Write-back module
```

## Implementation Details

The processor implements a single-cycle architecture where each instruction is executed in one clock cycle. The datapath includes:
- Instruction fetch from instruction memory
- Instruction decode and control signal generation
- Register file read
- ALU operation
- Memory access (if required)
- Write-back to registers

