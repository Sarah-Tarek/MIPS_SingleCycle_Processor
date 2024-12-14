# **Control Signals in the MIPS Single-Cycle Processor**

Control signals are critical in orchestrating the behavior of the MIPS single-cycle processor. These signals determine the operation of the datapath components and ensure the correct execution of each instruction.

---

## **Table of Contents**

1. [Introduction](#introduction)
2. [Control Signals Overview](#control-signals-overview)
   - [RegDst](#regdst)
   - [ALUSrc](#alusrc)
   - [MemToReg](#memtoreg)
   - [RegWrite](#regwrite)
   - [MemRead](#memread)
   - [MemWrite](#memwrite)
   - [Branch](#branch)
   - [Jump](#jump)
   - [ALUOp](#aluop)
3. [Control Signal Values for Instructions](#control-signal-values-for-instructions)
4. [Example Usage](#example-usage)
5. [References](#references)

---

## **Introduction**

The control unit generates control signals based on the instruction's opcode. These signals drive the datapath to execute specific operations such as arithmetic computations, memory access, or branching.

The control unit processes:

- The **opcode** field (bits `[31:26]`) to determine the instruction type.
- The **funct** field (bits `[5:0]`) for R-format instructions.

---

## **Control Signals Overview**

### **RegDst**

- **Purpose**: Determines whether the destination register is specified in the `rd` field (R-format) or `rt` field (I-format).
- **Values**:
  - `0`: Use `rt` (I-format, e.g., `lw`).
  - `1`: Use `rd` (R-format, e.g., `add`).

---

### **ALUSrc**

- **Purpose**: Selects the second ALU operand.
- **Values**:
  - `0`: Use register value from the `rt` field (R-format).
  - `1`: Use the immediate value (I-format, e.g., `addi`, `lw`, `sw`).

---

### **MemToReg**

- **Purpose**: Selects the data source for writing to a register.
- **Values**:
  - `0`: Use the ALU result.
  - `1`: Use data read from memory (e.g., `lw`).

---

### **RegWrite**

- **Purpose**: Enables writing to a register.
- **Values**:
  - `0`: Disable register write.
  - `1`: Enable register write.

---

### **MemRead**

- **Purpose**: Enables reading from memory.
- **Values**:
  - `0`: Disable memory read.
  - `1`: Enable memory read (e.g., `lw`).

---

### **MemWrite**

- **Purpose**: Enables writing to memory.
- **Values**:
  - `0`: Disable memory write.
  - `1`: Enable memory write (e.g., `sw`).

---

### **Branch**

- **Purpose**: Indicates if the instruction is a branch (e.g., `beq`, `bne`).
- **Values**:
  - `0`: No branching.
  - `1`: Perform branching.

---

### **Jump**

- **Purpose**: Indicates if the instruction is a jump (e.g., `j`, `jal`).
- **Values**:
  - `0`: No jump.
  - `1`: Perform jump.

---

### **ALUOp**

- **Purpose**: Encodes the type of operation to be performed by the ALU.
- **Values**:
  - `00`: Perform addition (e.g., `lw`, `sw`).
  - `01`: Perform subtraction (e.g., `beq`, `bne`).
  - `10`: Use the `funct` field for R-format operations.

---

## **Control Signal Values for Instructions**

| **Instruction** | **RegDst** | **ALUSrc** | **MemToReg** | **RegWrite** | **MemRead** | **MemWrite** | **Branch** | **Jump** | **ALUOp** |
| --------------- | ---------- | ---------- | ------------ | ------------ | ----------- | ------------ | ---------- | -------- | --------- |
| `R-format`      | 1          | 0          | 0            | 1            | 0           | 0            | 0          | 0        | 10        |
| `lw`            | 0          | 1          | 1            | 1            | 1           | 0            | 0          | 0        | 00        |
| `sw`            | X          | 1          | X            | 0            | 0           | 1            | 0          | 0        | 00        |
| `beq`           | X          | 0          | X            | 0            | 0           | 0            | 1          | 0        | 01        |
| `bne`           | X          | 0          | X            | 0            | 0           | 0            | 1          | 0        | 01        |
| `j`             | X          | X          | X            | 0            | 0           | 0            | 0          | 1        | XX        |
| `jal`           | X          | X          | X            | 1            | 0           | 0            | 0          | 1        | XX        |
| `jr`            | 1          | 0          | 0            | 0            | 0           | 0            | 0          | 1        | 10        |

**Key**:

- `X`: Don't care
- `XX`: Not applicable

---

## **Example Usage**

### **R-Format Instruction (`add $3, $1, $2`)**

- **Opcode**: `000000` (R-format)
- **Control Signals**:
  - `RegDst = 1`, `ALUSrc = 0`, `MemToReg = 0`, `RegWrite = 1`
  - `MemRead = 0`, `MemWrite = 0`, `Branch = 0`, `Jump = 0`
  - `ALUOp = 10`

### **Memory Instruction (`lw $5, 4($6)`)**

- **Opcode**: `100011` (I-format)
- **Control Signals**:
  - `RegDst = 0`, `ALUSrc = 1`, `MemToReg = 1`, `RegWrite = 1`
  - `MemRead = 1`, `MemWrite = 0`, `Branch = 0`, `Jump = 0`
  - `ALUOp = 00`

### **Branch Instruction (`beq $4, $5, offset`)**

- **Opcode**: `000100` (I-format)
- **Control Signals**:
  - `RegDst = X`, `ALUSrc = 0`, `MemToReg = X`, `RegWrite = 0`
  - `MemRead = 0`, `MemWrite = 0`, `Branch = 1`, `Jump = 0`
  - `ALUOp = 01`

---

## **References**

- [MIPS Instruction Set Architecture](https://en.wikichip.org/wiki/mips)
- "Computer Organization and Design" by David A. Patterson and John L. Hennessy
