module register_file(
    input clk,                      // Clock signal
    input reg_write,                // Write enable signal
    input [4:0] read_reg1,          // Address of the first register to read
    input [4:0] read_reg2,          // Address of the second register to read
    input [4:0] write_reg,          // Address of the register to write
    input [31:0] write_data,        // Data to write
    output [31:0] read_data1,       // Data read from the first register
    output [31:0] read_data2        // Data read from the second register
);

    // 32 registers, each 32 bits wide
    reg [31:0] registers [0:31];

    // Initialize registers (for simulation purposes)
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    // Read data (asynchronous)
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

    // Write data on the rising edge of the clock if reg_write is enabled
    always @(posedge clk) begin
        if (reg_write && write_reg != 5'b00000) begin
            registers[write_reg] <= write_data;
        end
    end

endmodule
