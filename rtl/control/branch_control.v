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
