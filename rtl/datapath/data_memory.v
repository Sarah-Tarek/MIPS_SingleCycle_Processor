module data_memory(
    input clk, mem_read, mem_write,
    input [31:0] address, write_data,
    output [31:0] read_data
);
    // 16K Data Memory
    // 16K = 16 x 1024 = 16,384 bytes
    // Each word in memory is 32 bits: 16,384 / 4 = 4096 words
    reg [31:0] memory [0:4096]; // 4096 words each 32-bit

    always @(posedge clk) begin
        if (mem_write)
            memory[address[13:2]] <= write_data;
    end

    assign read_data = mem_read ? memory[address[13:2]] : 32'b0;
endmodule
