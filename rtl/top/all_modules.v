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

    // Memory Initialization (Default value 0)
    integer i;
    initial begin
        // Initialize all memory locations to zero
        for (i = 0; i < 4096; i = i + 1) begin
            memory[i] = 32'h00000000;  // Initialize each word to zero
        end
    end

    // Write process
    always @(posedge clk) begin
        if (mem_write)
            memory[address[13:2]] <= write_data;
    end
    
    // Read process
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

    // Initialize memory to zeros
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
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
