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
