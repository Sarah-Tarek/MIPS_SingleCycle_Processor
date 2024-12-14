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
