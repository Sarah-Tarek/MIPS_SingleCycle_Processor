module data_memory(
    input clk, mem_read, mem_write,
    input [31:0] address, write_data,
    output [31:0] read_data
);
    reg [31:0] memory [0:255]; // 256 x 32-bit words

    always @(posedge clk) begin
        if (mem_write)
            memory[address[31:2]] <= write_data;
    end

    assign read_data = mem_read ? memory[address[31:2]] : 32'b0;
endmodule
