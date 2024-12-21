`timescale 1ns/1ps

module mips_processor_tb;

    // Testbench signals
    reg clk;
    reg reset;

    // Instantiate the MIPS processor
    mips_processor DUT (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation: 10 ns period => 100 MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // 1) Apply reset
        reset = 1;
        #20;               // Wait 20 ns
        reset = 0;         // Deassert reset

        // 2) Load instructions into the instruction memory
        //    DUT.imem.memory is a 1024-element array of 32-bit regs.
        //    We’ll load a small program that demonstrates:
        //      - addi, add, sub
        //      - lw, sw
        //      - beq, j (jump)
        //      - or, slt, nor, etc.

        // address 0: addi $1, $0, 10
        DUT.imem.memory[0] = 32'b001000_00000_00001_0000000000001010;
        // address 1: addi $2, $0, 20
        DUT.imem.memory[1] = 32'b001000_00000_00010_0000000000010100;
        // address 2: add $3, $1, $2  ($3 = 10 + 20 = 30)
        DUT.imem.memory[2] = 32'b000000_00001_00010_00011_00000_100000;
        // address 3: sw $3, 8($0)   (store 30 at data_mem[8 >> 2] = data_mem[2])
        DUT.imem.memory[3] = 32'b101011_00000_00011_0000000000001000;
        // address 4: lw $4, 8($0)   (load data_mem[2] => $4 should be 30)
        DUT.imem.memory[4] = 32'b100011_00000_00100_0000000000001000;
        // address 5: beq $4, $3, +2 (if $4 == $3, skip next instruction)
        DUT.imem.memory[5] = 32'b000100_00100_00011_0000000000000010;
        // address 6: sub $5, $1, $2 (this executes only if branch not taken; $5 = 10-20=-10)
        DUT.imem.memory[6] = 32'b000000_00001_00010_00101_00000_100010;
        // address 7: j 9           (jump to address 9)
        DUT.imem.memory[7] = 32'b000010_00000000000000000000001001;

        // address 8: or $4, $4, $1 (this will be skipped if branch was taken at instr 5)
        DUT.imem.memory[8] = 32'b000000_00100_00001_00100_00000_100101;

        // address 9: slt $6, $1, $4 ($6=1 if $1<$4, else 0)
        DUT.imem.memory[9] = 32'b000000_00001_00100_00110_00000_101010;

        // address 10: nor $7, $4, $6 ($7 = ~($4 | $6))
        DUT.imem.memory[10] = 32'b000000_00100_00110_00111_00000_100111;

        // Fill remaining instructions with NOP
        integer i;
        for (i = 11; i < 1024; i = i + 1) begin
            DUT.imem.memory[i] = 32'b000000_00000_00000_00000_00000_000000; // NOP
        end

        // 3) Optional: Display/Monitor
        $display("Starting simulation...");

        // You can monitor certain signals every cycle
        $monitor($time, 
                 " PC=%h | Instr=%h | R1=%d | R2=%d | R3=%d | R4=%d | R5=%d | R6=%d | R7=%d",
                  DUT.pc_reg,
                  DUT.instruction,
                  DUT.REG_FILE.registers[1],
                  DUT.REG_FILE.registers[2],
                  DUT.REG_FILE.registers[3],
                  DUT.REG_FILE.registers[4],
                  DUT.REG_FILE.registers[5],
                  DUT.REG_FILE.registers[6],
                  DUT.REG_FILE.registers[7]
                 );

        // 4) Let the simulation run for a while
        #300;  // 300 ns total
        $display("Simulation finished.");
        $finish;
    end

endmodule