module pc(
    input clk,                  // Clock signal
    input reset,                // Reset signal
    input [31:0] pc_in,         // Input address for the PC
    output reg [31:0] pc_out    // Output address from the PC
);
    // Update PC on rising edge of clock or reset
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'b0;    // Reset PC to 0
        else
            pc_out <= pc_in;    // Update PC with the input address
    end
endmodule
