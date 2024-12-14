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
