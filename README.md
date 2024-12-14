# **MIPS Single-Cycle Processor**

This project implements a single-cycle MIPS processor in Verilog, designed to execute a subset of the MIPS instruction set. The processor supports basic arithmetic, logical, memory access, branching, and jump instructions.

---

## **Table of Contents**

1. [Introduction](#introduction)
2. [Features](#features)
3. [Project Structure](#project-structure)
4. [Supported Instructions](#supported-instructions)
5. [Design Details](#design-details)
   - [Datapath](#datapath)
   - [Control Unit](#control-unit)
6. [Usage](#usage)
   - [Simulation](#simulation)
   - [Synthesis](#synthesis)
7. [Examples and Testbenches](#examples-and-testbenches)
8. [Future Enhancements](#future-enhancements)
9. [Contributing](#contributing)
10. [License](#license)

---

## **Introduction**

This project provides a Verilog implementation of a single-cycle MIPS processor. It is designed to simulate and synthesize the execution of MIPS assembly instructions, emphasizing simplicity and clarity.

The processor is built using a modular approach, enabling easy debugging, testing, and extension. Each module corresponds to a specific component in the MIPS datapath or control unit.

---

## **Features**

- **Single-cycle implementation**:
  - Each instruction is completed in a single clock cycle.
- **Instruction support**:
  - Arithmetic: ADD, SUB, AND, OR, SLT, etc.
  - Logical operations: NOR, XOR, SLL, SRL, SRA.
  - Memory operations: LW, SW.
  - Branching: BEQ, BNE.
  - Jumping: J, JAL, JR.
- **Parameterizable design** for extensibility.
- **Preloaded instruction memory** for simulation and testing.
- **Readable and well-commented Verilog code** for easy understanding.

---

## **Project Structure**

```plaintext
MIPS_SingleCycle_Processor/
├── docs/                       # Documentation and design specifications
│   ├── mips_design.md          # High-level overview and module connections
│   ├── instruction_set.md      # Supported instruction set
│   └── control_signals.md      # Explanation of control signals
├── rtl/                        # Verilog source files
│   ├── alu/                    # Arithmetic Logic Unit
│   │   ├── alu.v               # ALU module
│   │   └── alu_control.v       # ALU control module
│   ├── control/                # Control unit
│   │   ├── control_unit.v      # Main control unit
│   │   └── branch_control.v    # Branching logic
│   ├── datapath/               # Datapath components
│   │   ├── pc.v                # Program Counter
│   │   ├── instruction_memory.v # Instruction memory
│   │   ├── register_file.v     # Register file
│   │   ├── mux_2to1.v          # 2-to-1 multiplexer
│   │   ├── mux_3to1.v          # 3-to-1 multiplexer
│   │   ├── adder.v             # Adders for PC and branches
│   │   ├── data_memory.v       # Data memory
│   │   └── sign_extend.v       # Sign extension unit
│   ├── top/                    # Top-level modules
│       ├── datapath.v          # Combined datapath
│       └── mips_top.v          # Top-level MIPS processor
├── sim/                        # Simulation files
│   ├── testbench/              # Testbenches for simulation
│   │   ├── tb_alu.v
│   │   ├── tb_control_unit.v
│   │   ├── tb_register_file.v
│   │   ├── tb_datapath.v
│   │   └── tb_mips_top.v       # Testbench for the full processor
│   └── waveforms/              # Generated waveforms for debugging
├── synthesis/                  # Synthesis files for hardware implementation
│   ├── constraints.sdc         # Synthesis constraints
│   ├── timing_analysis.rpt     # Timing analysis report
│   └── area_utilization.rpt    # Area utilization report
├── README.md                   # Overview and project documentation
└── tools/                      # Scripts for synthesis or simulation
    ├── run_simulation.sh       # Script to run simulations
    └── generate_bitstream.sh   # Script to generate bitstream
```

---

## **Supported Instructions**

### **Arithmetic and Logical**

- `ADD`, `SUB`, `AND`, `OR`, `SLT`
- `NOR`, `XOR`, `SLL`, `SRL`, `SRA`

### **Memory Access**

- `LW` (Load Word), `SW` (Store Word)

### **Branching**

- `BEQ` (Branch if Equal), `BNE` (Branch if Not Equal)

### **Jumping**

- `J` (Jump), `JAL` (Jump and Link), `JR` (Jump Register)

### **Immediate Operations**

- `ADDI`, `ANDI`, `ORI`, `SLTI`, `LUI`

---

## **Design Details**

### **Datapath**

The datapath contains components like:

- ALU
- Program Counter (PC)
- Instruction Memory
- Data Memory
- Register File
- Multiplexers and Adders

### **Control Unit**

The control unit generates signals for:

- Register Destination (`RegDst`)
- ALU Source (`ALUSrc`)
- Memory Read/Write (`MemRead`, `MemWrite`)
- Register Write (`RegWrite`)
- Branch (`Branch`) and Jump (`Jump`) instructions
- ALU Control (`ALUOp`)

---

## **Usage**

### **Simulation**

1. Ensure all files are in the appropriate structure (`rtl`, `sim`, etc.).
2. Compile the testbench using a Verilog simulator like ModelSim or Icarus Verilog:
   ```bash
   iverilog -o tb_mips_top sim/testbench/tb_mips_top.v
   vvp tb_mips_top
   ```
3. View waveforms (optional):
   ```bash
   gtkwave sim/waveforms/mips_top.vcd
   ```

### **Synthesis**

1. Use a synthesis tool like Synopsys Design Compiler or Vivado.
2. Apply constraints from `synthesis/constraints.sdc`.
3. Generate reports (`timing_analysis.rpt`, `area_utilization.rpt`) for verification.

---

## **Examples and Testbenches**

- Test arithmetic operations:
  ```assembly
  ADD $3, $1, $2  // $3 = $1 + $2
  SUB $4, $3, $2  // $4 = $3 - $2
  ```
- Test branching:
  ```assembly
  BEQ $1, $2, LABEL // Branch if $1 == $2
  ```
- Test memory operations:
  ```assembly
  LW $5, 0($6)     // Load word from address in $6
  SW $5, 4($7)     // Store word to address in $7
  ```

---

## **Future Enhancements**

- Support additional instructions (e.g., floating-point operations).
- Optimize for pipelined execution.
- Add error handling for invalid instructions.

---

## **Contributing**

Contributions are welcome! Please fork the repository, make your changes, and submit a pull request.

---

## **License**

This project is licensed under the MIT License. See `LICENSE` for details.
