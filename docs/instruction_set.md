# **Instruction Set for MIPS Single-Cycle Processor**

This document details the supported instruction set for the MIPS single-cycle processor implementation. Each instruction is categorized by type (R-format, I-format, or J-format) and described with its functionality, binary representation, and usage.

---

## **Table of Contents**

1. [Instruction Formats](#instruction-formats)
   - [R-Format](#r-format)
   - [I-Format](#i-format)
   - [J-Format](#j-format)
2. [Supported Instructions](#supported-instructions)
   - [R-Format Instructions](#r-format-instructions)
   - [I-Format Instructions](#i-format-instructions)
   - [J-Format Instructions](#j-format-instructions)
3. [Instruction Encoding](#instruction-encoding)
4. [Examples](#examples)
5. [References](#references)

---

## **Instruction Formats**

### **R-Format**

- Used for arithmetic and logic operations.
- Fields:
  ```
  [opcode (6)] [rs (5)] [rt (5)] [rd (5)] [shamt (5)] [funct (6)]
  ```
  - **opcode**: Operation code (`000000` for R-format instructions).
  - **rs**: Source register.
  - **rt**: Source/destination register.
  - **rd**: Destination register.
  - **shamt**: Shift amount.
  - **funct**: Function code (specific operation).

---

### **I-Format**

- Used for immediate, load/store, and branch instructions.
- Fields:
  ```
  [opcode (6)] [rs (5)] [rt (5)] [immediate (16)]
  ```
  - **opcode**: Operation code.
  - **rs**: Source register.
  - **rt**: Destination register.
  - **immediate**: Constant or offset.

---

### **J-Format**

- Used for jump instructions.
- Fields:
  ```
  [opcode (6)] [address (26)]
  ```
  - **opcode**: Operation code.
  - **address**: Jump target address.

---

## **Supported Instructions**

### **R-Format Instructions**

| **Instruction** | **Mnemonic** | **Funct** | **Description**                                  |
| --------------- | ------------ | --------- | ------------------------------------------------ |
| `add`           | `add`        | `100000`  | Adds `rs` and `rt`, stores result in `rd`.       |
| `sub`           | `sub`        | `100010`  | Subtracts `rt` from `rs`, stores result in `rd`. |
| `and`           | `and`        | `100100`  | Bitwise AND between `rs` and `rt`.               |
| `or`            | `or`         | `100101`  | Bitwise OR between `rs` and `rt`.                |
| `nor`           | `nor`        | `100111`  | Bitwise NOR between `rs` and `rt`.               |
| `slt`           | `slt`        | `101010`  | Sets `rd` to 1 if `rs` < `rt`, else 0.           |
| `srl`           | `srl`        | `000010`  | Logical shift right of `rt` by `shamt`.          |
| `sll`           | `sll`        | `000000`  | Logical shift left of `rt` by `shamt`.           |
| `jr`            | `jr`         | `001000`  | Jump to address in `rs`.                         |

---

### **I-Format Instructions**

| **Instruction** | **Mnemonic** | **Opcode** | **Description**                                |
| --------------- | ------------ | ---------- | ---------------------------------------------- |
| `addi`          | `addi`       | `001000`   | Adds immediate to `rs`, stores result in `rt`. |
| `andi`          | `andi`       | `001100`   | Bitwise AND between `rs` and immediate.        |
| `ori`           | `ori`        | `001101`   | Bitwise OR between `rs` and immediate.         |
| `beq`           | `beq`        | `000100`   | Branch if `rs` == `rt`.                        |
| `bne`           | `bne`        | `000101`   | Branch if `rs` != `rt`.                        |
| `lw`            | `lw`         | `100011`   | Load word from memory to `rt`.                 |
| `sw`            | `sw`         | `101011`   | Store word from `rt` to memory.                |
| `lui`           | `lui`        | `001111`   | Load upper immediate to `rt`.                  |

---

### **J-Format Instructions**

| **Instruction** | **Mnemonic** | **Opcode** | **Description**                                           |
| --------------- | ------------ | ---------- | --------------------------------------------------------- |
| `j`             | `j`          | `000010`   | Jump to target address.                                   |
| `jal`           | `jal`        | `000011`   | Jump to address and link (store return address in `$ra`). |

---

## **Instruction Encoding**

### **Example Encodings**

1. **R-Format (e.g., `add $3, $1, $2`)**:

   ```
   Opcode: 000000
   rs:     00001
   rt:     00010
   rd:     00011
   shamt:  00000
   funct:  100000
   ```

   Binary: `000000 00001 00010 00011 00000 100000`

2. **I-Format (e.g., `addi $4, $1, 10`)**:

   ```
   Opcode: 001000
   rs:     00001
   rt:     00100
   Immediate: 0000000000001010
   ```

   Binary: `001000 00001 00100 0000000000001010`

3. **J-Format (e.g., `j 8`)**:
   ```
   Opcode: 000010
   Address: 00000000000000000000001000
   ```
   Binary: `000010 00000000000000000000001000`

---

## **Examples**

### **Example 1: Add Two Numbers**

Instruction: `add $3, $1, $2`

- Adds the values in registers `$1` and `$2`, stores result in `$3`.

### **Example 2: Load Word**

Instruction: `lw $5, 4($6)`

- Loads the word from memory at address `(4 + value_in_$6)` into `$5`.

### **Example 3: Branch on Equal**

Instruction: `beq $4, $5, offset`

- If the value in `$4` equals the value in `$5`, PC is updated to `PC + 4 + (offset << 2)`.

---

## **References**

- [MIPS Instruction Set Architecture](https://en.wikichip.org/wiki/mips)
- "Computer Organization and Design" by David A. Patterson and John L. Hennessy
