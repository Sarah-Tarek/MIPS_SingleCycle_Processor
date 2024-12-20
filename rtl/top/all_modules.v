// alu_control
module alu_control (
    input [1:0] alu_op,         // ALU operation signal from the control unit
    input [5:0] funct,          // Function code from the R-format instruction
    output reg [3:0] alu_control // Control signal for the ALU
);

    always @(*) begin
        case (alu_op)
            2'b00: alu_control = 4'b0010; // Load/Store instructions (ADD)
            2'b01: alu_control = 4'b0110; // Branch instructions (SUB)
            2'b10: begin                  // R-format instructions
                case (funct)
                    6'b100000: alu_control = 4'b0010; // ADD
                    6'b100010: alu_control = 4'b0110; // SUB
                    6'b100100: alu_control = 4'b0000; // AND
                    6'b100101: alu_control = 4'b0001; // OR
                    6'b101010: alu_control = 4'b0111; // SLT (Set Less Than)
                    6'b100111: alu_control = 4'b1100; // NOR
                    6'b000000: alu_control = 4'b1110; // SLL (Shift Left Logical)
                    6'b000010: alu_control = 4'b1010; // SRL (Shift Right Logical)
                    6'b000011: alu_control = 4'b1011; // SRA (Shift Right Arithmetic)
                    default:   alu_control = 4'b0000; // Default (NOP)
                endcase
            end
            default: alu_control = 4'b0000; // Default (NOP)
        endcase
    end
endmodule

// alu
module alu(
    input [31:0] a,                // First input
    input [31:0] b,                // Second input
    input [3:0] alu_control,       // ALU control signal
    output reg [31:0] result,      // ALU result
    output zero                    // Zero flag
);
    // Compute the result based on alu_control
    always @(*) begin
        case (alu_control)
            4'b0000: result = a & b;           // AND
            4'b0001: result = a | b;           // OR
            4'b0010: result = a + b;           // ADD
            4'b0110: result = a - b;           // SUB
            4'b0111: result = (a < b) ? 1 : 0; // SLT (Set Less Than)
            4'b1100: result = ~(a | b);        // NOR
            default: result = 0;
        endcase
    end

    // Zero flag is high if result is 0
    assign zero = (result == 32'b0) ? 1'b1 : 1'b0;

endmodule

// branch_control
module branch_control (
    input [5:0] opcode,         // Opcode from the instruction
    input zero,                 // Zero signal from the ALU
    output reg branch_taken     // Indicates whether the branch is taken
);
    always @(*) begin
        case (opcode)
            6'b000100: branch_taken = zero;         // beq
            6'b000101: branch_taken = ~zero;        // bne
            default:   branch_taken = 1'b0;         // Default: No branch
        endcase
    end
endmodule

// control_unit
module control_unit (
    input [5:0] opcode,         // Opcode from the instruction
    output reg reg_dst,         // Selects destination register
    output reg alu_src,         // Selects ALU input source
    output reg mem_to_reg,      // Memory to register
    output reg reg_write,       // Write to register
    output reg mem_read,        // Read from memory
    output reg mem_write,       // Write to memory
    output reg branch,          // Branch instruction
    output reg [1:0] alu_op,    // ALU operation
    output reg jump             // Jump instruction
);
    always @(*) begin
        case (opcode)
            6'b000000: begin // R-format
                reg_dst = 1;
                alu_src = 0;
                mem_to_reg = 0;
                reg_write = 1;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                alu_op = 2'b10;
                jump = 0;
            end
            6'b100011: begin // lw
                reg_dst = 0;
                alu_src = 1;
                mem_to_reg = 1;
                reg_write = 1;
                mem_read = 1;
                mem_write = 0;
                branch = 0;
                alu_op = 2'b00;
                jump = 0;
            end
            6'b101011: begin // sw
                reg_dst = 0; // Don't care
                alu_src = 1;
                mem_to_reg = 0; // Don't care
                reg_write = 0;
                mem_read = 0;
                mem_write = 1;
                branch = 0;
                alu_op = 2'b00;
                jump = 0;
            end
            6'b000100: begin // beq
                reg_dst = 0; // Don't care
                alu_src = 0;
                mem_to_reg = 0; // Don't care
                reg_write = 0;
                mem_read = 0;
                mem_write = 0;
                branch = 1;
                alu_op = 2'b01;
                jump = 0;
            end
            6'b000101: begin // bne
                reg_dst = 0; // Don't care
                alu_src = 0;
                mem_to_reg = 0; // Don't care
                reg_write = 0;
                mem_read = 0;
                mem_write = 0;
                branch = 1;
                alu_op = 2'b01;
                jump = 0;
            end
            6'b000010: begin // j
                reg_dst = 0; // Don't care
                alu_src = 0; // Don't care
                mem_to_reg = 0; // Don't care
                reg_write = 0;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                alu_op = 2'b00; // Don't care
                jump = 1;
            end
            // Add other instructions here
            default: begin // Default case
                reg_dst = 0;
                alu_src = 0;
                mem_to_reg = 0;
                reg_write = 0;
                mem_read = 0;
                mem_write = 0;
                branch = 0;
                alu_op = 2'b00;
                jump = 0;
            end
        endcase
    end
endmodule

// adder
module adder(
    input [31:0] a,             // First operand
    input [31:0] b,             // Second operand
    output [31:0] result        // Sum output
);
    assign result = a + b;
endmodule

// data_memory
module data_memory(
    input clk, mem_read, mem_write,
    input [31:0] address, write_data,
    output [31:0] read_data
);
    // 16K Data Memory
    // 16K = 16 x 1024 = 16,384 bytes
    // Each word in memory is 32 bits: 16,384 / 4 = 4096 words
    reg [31:0] memory [0:4096]; // 4096 words each 32-bit

    always @(posedge clk) begin
        if (mem_write)
            memory[address[13:2]] <= write_data;
    end

    assign read_data = mem_read ? memory[address[13:2]] : 32'b0;
endmodule

// instruction_memory
module instruction_memory(
    input [31:0] address,       // Address input
    output [31:0] instruction   // Instruction output
);
    // 4K Instruction Memory
    // 4K = 4 x 1024 = 4096 bytes
    // Each word in memory is 32 bits: 4096 / 4 = 1024 words
    // Memory array to hold instructions
    reg [31:0] memory [0:1023];  // 1024 words each 32-bit

    // Output the instruction at the given address
    assign instruction = memory[address[11:2]]; // Word-aligned (ignoring lower 2 bits)

    // Preload instructions
    integer i;
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

        // Fill remaining memory with NOPs
        for (i = 28; i < 1024; i = i + 1) begin
            memory[i] = 32'b000000_00000_00000_00000_00000_000000; // NOP
        end
    end
endmodule

// mux_2to1
module mux_2to1 (
    input [31:0] in0,          // First input
    input [31:0] in1,          // Second input
    input sel,                 // Select signal
    output reg [31:0] out      // Output
);

always @(*) begin
    case (sel)
        1'b0: out = in0;       // Select input 0
        1'b1: out = in1;       // Select input 1
        default: out = 32'b0;  // Default case (if sel is undefined)
    endcase
end

endmodule

// mux_3to1
module mux_3to1 (
    input [31:0] in0,          // First input
    input [31:0] in1,          // Second input
    input [31:0] in2,          // Third input
    input [1:0] sel,           // 2-bit select signal
    output reg [31:0] out      // Output
);

always @(*) begin
    case (sel)
        2'b00: out = in0;      // Select input 0
        2'b01: out = in1;      // Select input 1
        2'b10: out = in2;      // Select input 2
        default: out = 32'b0;  // Default case (if sel is undefined)
    endcase
end

endmodule

// pc
module pc(
    input clk,                  // Clock signal
    input reset,                // Reset signal
    input [31:0] pc_in,         // Input address for the PC
    output reg [31:0] pc_out    // Output address from the PC
);
    // Update PC on rising edge of clock or reset
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'b0;    // Reset PC to 0
        else
            pc_out <= pc_in;    // Update PC with the input address
    end
endmodule

// register_file
module register_file(
    input clk,                      // Clock signal
    input reg_write,                // Write enable signal
    input [4:0] read_reg1,          // Address of the first register to read
    input [4:0] read_reg2,          // Address of the second register to read
    input [4:0] write_reg,          // Address of the register to write
    input [31:0] write_data,        // Data to write
    output [31:0] read_data1,       // Data read from the first register
    output [31:0] read_data2        // Data read from the second register
);

    // 32 registers each 32 bits
    reg [31:0] registers [0:31];

    // Initialize registers (for simulation purposes)
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    // Read data (asynchronous)
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

    // Write data on the rising edge of the clock if reg_write is enabled
    always @(posedge clk) begin
        if (reg_write && write_reg != 5'b00000) begin
            registers[write_reg] <= write_data;
        end
    end

endmodule

// sign_extend
module sign_extend(
    input [15:0] in,       // 16-bit input
    output [31:0] out      // 32-bit sign-extended output
);
    // Sign extension logic
    assign out = {{16{in[15]}}, in};
endmodule
