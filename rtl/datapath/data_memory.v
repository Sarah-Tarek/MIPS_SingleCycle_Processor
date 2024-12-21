module data_memory(
    input clk, mem_read, mem_write,
    input [31:0] address, write_data,
    output reg [31:0] read_data
);
    // 16K Data Memory
    // 16K = 16 x 1024 = 16,384 bytes
    // Each word in memory is 32 bits: 16,384 / 4 = 4096 words
    reg [31:0] memory [0:4095]; // 4096 words each 32-bit

    // Memory Initialization (Default value 0)
    integer i;
    initial begin
        // Initialize all memory locations to zero
        for (i = 0; i < 4096; i = i + 1) begin
            memory[i] = 32'h00000000;  // Initialize each word to zero
        end
    end

    // Write process
    always @(posedge clk) begin
        if (mem_write)
            memory[address[13:2]] <= write_data; // Addressing by word
    end
    
    // Read process
    always @(*) begin
        if (mem_read)
            read_data = memory[address[13:2]];
        else
            read_data = 32'b0;
    end
endmodule
