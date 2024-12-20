// in case the instruction memory is filled with instructions

`timescale 1ns / 1ps

module MIPS_tb;

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
        // Initially set reset high to reset the MIPS module
        reset = 1;
        #20; // Hold reset for some time (20ns)
        reset = 0;  // Deassert reset
    end

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;

        // Apply reset
        #10 reset = 0;

        // Test for Add
        #50; // Wait for the add operation to complete
        $display("Add Test: Register 2 = %d (Expected: 5)", dut.register_file_inst.regs[2]); // Assuming the result is 5

        // Test for Subtract
        #50;
        $display("Subtract Test: Register 3 = %d (Expected: 2)", dut.register_file_inst.regs[3]); // Assuming the result is 2

        // Test for Load
        #50;
        $display("Load Test: Register 4 = %d (Expected: 10)", dut.register_file_inst.regs[4]); // Assuming the value loaded is 10

        // Test for Store
        #50;
        $display("Store Test: Data Memory[10] = %d (Expected: 20)", dut.data_memory_inst.memory[10]); // Assuming the stored value is 20

        // Test for Branch
        #50;
        $display("Branch Test: PC = %d (Expected: 32)", dut.pc_inst.pc_out); // Assuming the PC after the branch is 32

        // End simulation
        #100;
        $finish;
    end

endmodule
