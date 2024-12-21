module alu_control(
    input  [1:0] alu_op,    // from control unit
    input  [5:0] funct,     // from R-type
    input  [5:0] opcode,    // (optional) for I-type decode
    output reg [3:0] alu_control
);

always @(*) begin
    case (alu_op)
        2'b00: alu_control = 4'b0010; // add (lw, sw, addi)
        2'b01: alu_control = 4'b0110; // sub (beq, bne)
        2'b10: begin // R-type
            case (funct)
                6'b100000: alu_control = 4'b0010; // ADD
                6'b100010: alu_control = 4'b0110; // SUB
                6'b100100: alu_control = 4'b0000; // AND
                6'b100101: alu_control = 4'b0001; // OR
                6'b101010: alu_control = 4'b0111; // SLT
                6'b100111: alu_control = 4'b1100; // NOR
                6'b000000: alu_control = 4'b1110; // SLL
                6'b000010: alu_control = 4'b1010; // SRL
                6'b000011: alu_control = 4'b1011; // SRA
                default:   alu_control = 4'b0000; // NOP
            endcase
        end

        2'b11: begin
            // We can use opcode to differentiate I-types
            case (opcode)
                6'b001100: alu_control = 4'b0000; // andi => AND
                6'b001101: alu_control = 4'b0001; // ori  => OR
                6'b001010: alu_control = 4'b0111; // slti => SLT
                6'b001111: alu_control = 4'bXXXX; // lui => Typically shift imm by 16
                // ...
                default:   alu_control = 4'b0000; // fallback
            endcase
        end

        default: alu_control = 4'b0000;
    endcase
end

endmodule
