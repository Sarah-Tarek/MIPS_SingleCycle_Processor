// in case the instruction memory is NOT initially preloaded with instructions

`timescale 1ns / 1ps

module MIPS_TB1;

    // Inputs to the MIPS module
    reg clk;
    reg reset;

    // Instantiate the MIPS module
    MIPS dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Reset procedure
    initial begin
        reset = 1;
        #20;
        reset = 0;
    end

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;

        // Apply reset
        #10 reset = 0;

        // Test for Add operation (Add 2 and 3 -> result should be 5)
        // Load instruction into instruction memory to perform an ADD
        // Example: ADD $2, $3, $4 -> $2 = $3 + $4
        dut.instruction_memory_inst.memory[0] = 32'b000000_00011_00100_00010_00000_100000; // ADD instruction
        
        #50; // Wait for the add operation to complete
        $display("Add Test: {ADD $2, $3, $4} where $3 = 2, $4 = 3 --> Register 2 = %d (Expected: 5)", dut.register_file_inst.registers[2]); // Assuming $2 = 5 after ADD


        // Test for Subtract operation (Subtract 3 from 5 -> result should be 2)
        // Load instruction into instruction memory to perform SUB
        // Example: SUB $3, $4, $5 -> $3 = $4 - $5
        dut.instruction_memory_inst.memory[1] = 32'b000000_00011_00101_00011_00000_100010; // SUB instruction
        
        #50; // Wait for the subtract operation to complete
        $display("Subtract Test: {SUB $3, $4, $5} where $4 = 5, $5 = 3 --> Register 3 = %d (Expected: 2)", dut.register_file_inst.registers[3]); // Assuming $3 = 2 after SUB


        // Test for Load operation (Load value from data memory into a register)
        // Assume we load value 10 into Register 4 from memory location 4
        // First, store 10 at data memory address 4
        dut.data_memory_inst.memory[4] = 10;
        // Load instruction: lw $4, 4($0) -> Load data from memory address 4 into Register 4
        dut.instruction_memory_inst.memory[2] = 32'b100011_00000_00100_00000_00000_000100; // LW instruction
        
        #50; // Wait for the load operation to complete
        $display("Load Test: {lw $4, 4($0)} where Data Memory[4] = 10 --> Register 4 = %d (Expected: 10)", dut.register_file_inst.registers[4]); // Assuming $4 = 10 after LW


        // Test for Store operation (Store value 20 from Register 2 to data memory address 10)
        // First, set $2 to 20
        dut.register_file_inst.registers[2] = 20;
        // Store instruction: SW $2, 10($0) -> Store value in $2 into memory[10]
        dut.instruction_memory_inst.memory[3] = 32'b101011_00000_00010_00000_00000_01010; // SW instruction
        
        #50; // Wait for the store operation to complete
        $display("Store Test: {SW $2, 10($0)} where $2 = 20 --> Data Memory[10] = %d (Expected: 20)", dut.data_memory_inst.memory[10]); // Assuming memory[10] = 20 after SW


        // Test for Branch operation (Branch if zero flag is set, for example, BEQ)
        // Example: BEQ $1, $2, label -> Branch if $1 == $2
        // Set $1 = $2 to trigger the branch
        dut.register_file_inst.registers[1] = 5;
        dut.register_file_inst.registers[2] = 5;
        // Load BEQ instruction to branch
        dut.instruction_memory_inst.memory[4] = 32'b000100_00001_00010_00000_00000_00100; // BEQ instruction
        
        #50; // Wait for the branch operation to complete
        $display("Branch Test: {BEQ $1, $2, label} where $1 = $2 = 5 and offset = 4 --> PC = %d (Expected: 32)", dut.pc_inst.pc_out); // Assuming PC after branch = 32


        // End simulation
        #100;
        $stop;
    end
endmodule
