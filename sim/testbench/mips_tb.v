// Testbench for MIPS Processor
module tb_mips_processor;

    // Inputs
    reg clk;
    reg reset;

    // Instantiate MIPS Processor
    mips_processor dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Test Procedure
    initial begin
        // Initialize signals
        reset = 1;
        #10;
        reset = 0;

        // Initialize registers
        dut.RF.registers[1] = 10;  // $1 = 10
        dut.RF.registers[2] = 20;  // $2 = 20
        dut.RF.registers[9] = 5;   // $9 = 5
        dut.RF.registers[10] = 15; // $10 = 15

        // Directly load instructions into instruction memory
        dut.IM.memory[0] = 32'b000000_00001_00010_00011_00000_100000; // add $3, $1, $2
        dut.IM.memory[1] = 32'b000000_00011_00010_01100_00000_100010; // sub $12, $3, $2
        dut.IM.memory[2] = 32'b100011_00001_01000_0000000000000000;   // lw $8, 0($1)
        dut.IM.memory[3] = 32'b101011_00001_01000_0000000000000100;   // sw $8, 4($1)
        dut.IM.memory[4] = 32'b000100_00001_00010_0000000000000010;   // beq $1, $2, skip
        dut.IM.memory[5] = 32'b000101_00001_00010_0000000000000001;   // bne $1, $2, skip
        dut.IM.memory[6] = 32'b000010_00000000000000000000000100;     // j 4 (Jump to instruction 4)

        // Store data in data memory for lw/sw testing
        dut.DM.memory[0] = 32'd42;  // Memory[0] = 42 (Simple test value)  // Memory[0] = 3735928559 (DEADBEEF in decimal)  // Memory[0] = DEADBEEF

        // Monitor signals
        //$monitor("Time: %0t | PC: %h | Instr: %h | ALU Result: %h | Zero: %b | Reg Write: %b", 
        //          $time, dut.pc_out, dut.instruction, dut.alu_result, dut.zero, dut.reg_write);

        // Display messages for each instruction in Assembly
        #10 $display("[ADD] add $3, $1, $2 | $3 = $1 (10) + $2 (20) | Expected: 30, Got: %d", dut.RF.registers[3]);
        #10 $display("[SUB] sub $12, $3, $2 | $12 = $3 (30) - $2 (20) | Expected: 10, Got: %d", dut.RF.registers[12]);
        #10 $display("[LW] lw $8, 0($1) | Load from mem[0] (42) into $8 | Expected: 42, Got: %h", dut.RF.registers[8]);
        #10 $display("[SW] sw $8, 4($1) | Store $8 (42) into mem[4] | Expected: 42, Got: %h", dut.DM.memory[1]);
        #10 $display("[BEQ] beq $1, $2, label | Branch if $1 (10) == $2 (20) | Expected: No branch, PC: %h", dut.pc_out);
        #10 $display("[BNE] bne $1, $2, label | Branch if $1 (10) != $2 (20) | Expected: Branch, PC: %h", dut.pc_out);
        #10 $display("[J] j 4 | Jump to address 4 | Expected PC: 10, Got: %h", dut.pc_out);

        // Run simulation for sufficient cycles to test all instructions
        #300;
        
        $stop;
    end

endmodule
