# **MIPS Single-Cycle Processor Design Documentation**

This document provides an overview of the design, architecture, and components of the MIPS single-cycle processor. It explains the connections and interactions between modules and offers insights into how the processor executes instructions in a single clock cycle.

---

## **Table of Contents**

1. [Introduction](#introduction)
2. [High-Level Architecture](#high-level-architecture)
3. [Modules Overview](#modules-overview)
4. [Control Signals](#control-signals)
5. [Data Flow in the Datapath](#data-flow-in-the-datapath)
6. [Instruction Execution](#instruction-execution)
7. [Pipeline Limitations](#pipeline-limitations)
8. [References](#references)

---

## **Introduction**

The MIPS single-cycle processor implements a subset of the MIPS instruction set. Each instruction is executed within a single clock cycle, making the design simple but less efficient for complex pipelines.

---

## **High-Level Architecture**

The processor consists of:

- **Control Unit**: Decodes instructions and generates control signals.
- **Datapath**: Executes instructions by transferring and processing data.

Key components:

- Program Counter (PC)
- Instruction Memory
- Control Unit
- ALU and ALU Control
- Register File
- Data Memory
- Multiplexers (Muxes)
- Adders
- Branch and Jump logic

---

## **Modules Overview**

### **1. Program Counter (PC)**

- Holds the address of the next instruction to be executed.
- Increments by 4 or jumps to a branch/jump address.

### **2. Instruction Memory**

- Stores program instructions.
- Outputs the instruction at the PC address.

### **3. Control Unit**

- Decodes the opcode and generates control signals for the datapath components.
- Signals include `alu_op`, `reg_write`, `mem_read`, `mem_write`, `branch`, etc.

### **4. ALU (Arithmetic Logic Unit)**

- Performs arithmetic and logic operations.
- Controlled by the `alu_control` signal, which is derived from the instruction's `funct` field and the `alu_op`.

### **5. Register File**

- Contains 32 registers (`$0-$31`).
- Supports two simultaneous reads and one write per clock cycle.

### **6. Data Memory**

- Provides read and write access to memory for load/store instructions.
- Controlled by `mem_read` and `mem_write`.

### **7. Sign Extend**

- Extends 16-bit immediate values to 32 bits for operations like `addi`, `lw`, and `sw`.

### **8. Multiplexers**

- Direct data flow based on control signals.
- Examples:
  - `mux_2to1`: Selects between ALU result and memory data for register writes.
  - `mux_3to1`: Handles PC source selection (PC+4, branch, or jump address).

---

## **Control Signals**

The control signals are generated based on the instruction's opcode and function field. See [control_signals.md](control_signals.md) for detailed explanations.

---

## **Data Flow in the Datapath**

1. **Instruction Fetch**

   - PC provides the address to Instruction Memory.
   - Instruction Memory fetches the instruction.
   - PC is incremented by 4 using an adder.

2. **Instruction Decode**

   - The fetched instruction is decoded by the Control Unit.
   - Register addresses are extracted and sent to the Register File.

3. **Execute**

   - The ALU performs arithmetic/logic operations based on `alu_control`.
   - Branch decisions are made based on ALU results (`zero` flag).

4. **Memory Access**

   - For `lw` and `sw`, the Data Memory is accessed using the ALU result as the address.

5. **Write Back**
   - For R-type and `lw` instructions, the result is written back to the Register File.

---

## **Instruction Execution**

### **R-Type Instructions**

- **Example**: `add $3, $1, $2`
  - Read registers `$1` and `$2`.
  - Perform `add` operation in ALU.
  - Write result to `$3`.

### **I-Type Instructions**

- **Example**: `lw $2, 4($3)`
  - Read `$3` to compute the effective address.
  - Access Data Memory at the computed address.
  - Write data to `$2`.

### **J-Type Instructions**

- **Example**: `j 0x00400020`
  - Jump to the specified address.

---

## **Pipeline Limitations**

This design executes each instruction in a single clock cycle, which limits the clock speed due to the critical path through the datapath. Multi-cycle and pipelined designs improve efficiency but add complexity.

---

## **References**

- "Computer Organization and Design" by David A. Patterson and John L. Hennessy
- [MIPS Instruction Set Architecture](https://en.wikichip.org/wiki/mips)
