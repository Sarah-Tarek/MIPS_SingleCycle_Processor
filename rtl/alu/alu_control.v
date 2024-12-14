module alu_control (
    input [1:0] alu_op,         // ALU operation from the control unit
    input [5:0] funct,          // Function code from the instruction
    output reg [3:0] alu_control // Control signal for the ALU
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_control = 4'b0010; // Load/Store (ADD)
            2'b01: alu_control = 4'b0110; // Branch (SUB)
            2'b10: begin                  // R-format
                case (funct)
                    6'b100000: alu_control = 4'b0010; // ADD
                    6'b100010: alu_control = 4'b0110; // SUB
                    6'b100100: alu_control = 4'b0000; // AND
                    6'b100101: alu_control = 4'b0001; // OR
                    6'b101010: alu_control = 4'b0111; // SLT
                    default:   alu_control = 4'b0000; // Default (NOP)
                endcase
            end
            default: alu_control = 4'b0000; // Default (NOP)
        endcase
    end
endmodule
