module branch_control (
    input [5:0] opcode,         // Opcode from the instruction
    input zero,                 // Zero signal from the ALU
    output reg branch_taken     // Indicates whether the branch is taken
);

    always @(*) begin
        case (opcode)
            6'b000100: branch_taken = zero;         // beq (branch if equal)
            6'b000101: branch_taken = ~zero;        // bne (branch if not equal)
            default:   branch_taken = 1'b0;         // No branch by default
        endcase
    end

endmodule
