module instruction_memory(
    input [31:0] address,       // Address input
    output [31:0] instruction   // Instruction output
);
    // TODO: instruction memory size is 4K
    // Memory array to hold instructions
    reg [31:0] memory [0:255];  // 256 words of 32-bit memory

    // Output the instruction at the given address
    assign instruction = memory[address[9:2]]; // Word-aligned (ignoring lower 2 bits)

    // Preload instructions based on the restricted single-cycle MIPS instruction set
    initial begin
        memory[0]  = 32'b000000_00001_00010_00011_00000_100000; // add $3, $1, $2
        memory[1]  = 32'b001000_00001_00100_0000000000001010;   // addi $4, $1, 10
        memory[2]  = 32'b000000_00100_00010_00101_00000_100100; // and $5, $4, $2
        memory[3]  = 32'b001100_00001_00110_0000000000001111;   // andi $6, $1, 15
        memory[4]  = 32'b000100_00100_00101_0000000000000100;   // beq $4, $5, 4
        memory[5]  = 32'b000101_00100_00101_0000000000000011;   // bne $4, $5, 3
        memory[6]  = 32'b000010_00000000000000000000001000;     // j 8
        memory[7]  = 32'b000011_00000000000000000000001010;     // jal 10
        memory[8]  = 32'b000000_11111_00000_00111_00000_001000; // jr $ra
        memory[9]  = 32'b100011_00100_01000_0000000000000100;   // lw $8, 4($4)
        memory[10] = 32'b101011_00101_01001_0000000000000100;   // sw $9, 4($5)
        memory[11] = 32'b000000_00110_00111_01010_00000_101010; // slt $10, $6, $7
        memory[12] = 32'b001010_00101_01011_0000000000000010;   // slti $11, $5, 2
        memory[13] = 32'b000000_00001_00100_01100_00000_000010; // srl $12, $1, $4
        memory[14] = 32'b000000_00100_00010_01101_00000_100010; // sub $13, $4, $2
        memory[15] = 32'b000000_00101_00111_01110_00000_100110; // xor $14, $5, $7
        memory[16] = 32'b001110_00011_01111_0000000000001111;   // xori $15, $3, 15
        memory[17] = 32'b000000_00011_00010_10000_00000_100101; // or $16, $3, $2
        memory[18] = 32'b001101_00010_10001_0000000000000101;   // ori $17, $2, 5
        memory[19] = 32'b100000_00101_10010_0000000000000100;   // lb $18, 4($5)
        memory[20] = 32'b100001_00110_10011_0000000000000100;   // lh $19, 4($6)
        memory[21] = 32'b101000_00111_10100_0000000000000100;   // sb $20, 4($7)
        memory[22] = 32'b101001_01000_10101_0000000000000100;   // sh $21, 4($8)
        memory[23] = 32'b001111_00000_01001_0000000000001111;   // lui $9, 15
        memory[24] = 32'b000000_01001_01010_10110_00000_100111; // nor $22, $9, $10
        memory[25] = 32'b000000_00110_01011_10111_00000_000011; // sra $23, $6, $11
        memory[26] = 32'b000000_01100_01001_11000_00000_101011; // sltu $24, $12, $9
        memory[27] = 32'b000000_01011_01100_11001_00000_101011; // sltu $25, $11, $12

        // Fill remaining memory with NOPs (32'b00000000000000000000000000000000)
        for (int i = 28; i < 256; i = i + 1) begin
            memory[i] = 32'b000000_00000_00000_00000_00000_000000; // NOP
        end
    end
endmodule
