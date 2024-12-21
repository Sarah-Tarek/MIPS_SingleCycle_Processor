module sign_extend(
    input [15:0] in,       // 16-bit input
    output [31:0] out      // 32-bit sign-extended output
);
    // Sign extension logic
    assign out = {{16{in[15]}}, in};  // Extend the sign of the 16th bit

endmodule
