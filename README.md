# 32-bit Pipelined RISC-V Processor

This repository contains the SystemVerilog implementation of a 32-bit processor that executes the RISC-V (RV32I) base instruction set. The project is developed as part of the CSD course.

## Project Overview

The primary goal is to design, implement, and verify a functional RISC-V CPU. The project begins with a foundational single-cycle processor to verify the core datapath and control logic (Module 1). It then evolves into an advanced 5-stage pipelined processor to improve instruction throughput, complete with hazard detection and forwarding (Module 2).

---
## Architecture Specifications

This section defines the processor's behavior from a programmer's perspective, adhering to the RISC-V standard.

### Base ISA
The processor will implement the **RV32I Base Integer Instruction Set**, Version 2.1. This defines a 32-bit architecture with 32-bit general-purpose registers and a set of 47 base instructions.

### Instruction Formats
The processor decodes and executes all standard RV32I instruction formats: R, I, S, B, U, and J.


### Register File
* **General-Purpose Registers (GPRs):** 32 registers (`x0`-`x31`), each 32 bits wide.
* **Special GPR:** `x0` is a constant, hardwired to the value zero.
* **Special-Purpose Registers:** A single 32-bit **Program Counter (PC)** that holds the address of the instruction to be fetched.

### Memory and Address Space
* **Address Space:** The processor can access a flat, byte-addressable address space of **$2^{32}$ bytes (4 GiB)**.
* **Endianness:** The system is **Little-Endian**.
* **Cache:** No cache hierarchy is implemented in the base design.

### Input/Output (I/O)
I/O operations are handled via **Memory-Mapped I/O (MMIO)**. A portion of the address space is reserved for peripheral devices.

---
## Design Specifications (Microarchitecture)

This section describes the internal hardware implementation of the processor.

### Pipeline Structure
The advanced version of the processor implements a classic **5-stage RISC pipeline** to maximize instruction throughput.

1.  **IF:** Instruction Fetch
2.  **ID:** Instruction Decode & Register Read
3.  **EX:** Execute / Address Calculation
4.  **MEM:** Memory Access
5.  **WB:** Write Back

### Hazard Management
* **Data Hazards:** Resolved primarily through a **Forwarding Unit** (bypassing) to send results from the EX/MEM stages back to the EX stage. A **Hazard Detection Unit** stalls the pipeline for one cycle on a load-use hazard.
* **Control Hazards:** Resolved using a **predict-not-taken** scheme. The pipeline is flushed (instructions are invalidated) when a branch is taken.

### Clocking and HDL
* **Target Clock Frequency:** The design targets a synthesis frequency of **50 MHz**.
* **Clocking Scheme:** A **single, synchronous clock** drives the CPU core and all memory interfaces.
* **Hardware Description Language (HDL):** The entire design is coded in **SystemVerilog**.

---
## Project Plan & Weekly Split-up

This schedule outlines the planned tasks for the project.

* **Week 1 (Aug 18 - Aug 24): Core Component Design & Verification**
    * **Status:** ✅ **Completed**
    * **Goal:** Implement and individually verify all core datapath components (`ALU`, `RegFile`, memory modules, etc.).

* **Week 2 (Aug 25 - Aug 31): Single-Cycle Processor Integration (Module 1)**
    * **Status:** ⏳ **In Progress (Current Week)**
    * **Goal:** Assemble the complete single-cycle processor, create a test program, and fully debug the integrated design until the test passes.

* **Week 3 (Sep 1 - Sep 7): Pipelined IF & ID Stages**
    * **Status:** 📝 **Upcoming**
    * **Goal:** Begin the conversion to a 5-stage pipeline, focusing on the first two stages: Instruction Fetch and Instruction Decode.

* **Week 4 (Sep 8 - Sep 14): Pipelined EX & MEM Stages**
    * **Status:** 📝 **Upcoming**
    * **Goal:** Add the Execute and Memory stages to the pipeline by implementing the `ID/EX` and `EX/MEM` pipeline registers and connecting the relevant logic.

* **Week 5 (Sep 15 - Sep 21): Pipelined WB Stage & Data Hazards**
    * **Status:** 📝 **Upcoming**
    * **Goal:** Complete the 5-stage datapath and implement logic to handle data hazards using forwarding and stalling.

* **Week 6 (Sep 22 - Sep 28): Control Hazard Management**
    * **Status:** 📝 **Upcoming**
    * **Goal:** Implement logic to handle branch instructions correctly by implementing pipeline flushing.

* **Week 7 (Sep 29 - Oct 5): Full System Integration & Verification**
    * **Status:** 📝 **Upcoming**
    * **Goal:** Thoroughly test the complete pipelined processor with complex programs that combine data and control hazards.

* **Week 8 (Oct 6 - Oct 12): Extension 1: FPGA Synthesis & Implementation**
    * **Status:** 🚀 **Stretch Goal**
    * **Goal:** Take the processor design from simulation to a physical FPGA board by creating a top-level wrapper and running it through the Vivado toolchain.

* **Week 9 (Oct 13 - Oct 19): Extension 2: L1 Cache Implementation**
    * **Status:** 🚀 **Stretch Goal**
    * **Goal:** Add a simple direct-mapped L1 cache to improve memory access performance and analyze the impact.