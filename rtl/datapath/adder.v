module adder(
    input [31:0] a,             // First operand
    input [31:0] b,             // Second operand
    output [31:0] result        // Sum output
);

    assign result = a + b;

endmodule
