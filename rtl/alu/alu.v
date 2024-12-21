module alu(
    input  [31:0] a,                // First input
    input  [31:0] b,                // Second input (could be shift amount)
    input  [3:0]  alu_control,      // ALU control signal
    output reg [31:0] result,       // ALU result
    output wire     zero            // Zero flag
);
    always @(*) begin
        case (alu_control)
            4'b0000: result = a & b;                           // AND
            4'b0001: result = a | b;                           // OR
            4'b0010: result = a + b;                           // ADD
            4'b0110: result = a - b;                           // SUB
            4'b0111: result = (a < b) ? 32'b1 : 32'b0;          // SLT
            4'b1100: result = ~(a | b);                        // NOR

            // ---- Newly added SHIFT OPERATIONS ----
            4'b1110: result = a << b[4:0];                     // SLL
            4'b1010: result = a >> b[4:0];                     // SRL
            4'b1011: result = $signed(a) >>> b[4:0];           // SRA

            default: result = 32'b0;                           // Default
        endcase
    end

    // Zero flag
    assign zero = (result == 32'b0);

endmodule
