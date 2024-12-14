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
