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
