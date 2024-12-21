module instruction_memory(
    input [31:0] address,       // Address input
    output reg [31:0] instruction // Instruction output (changed to reg)
);
    // 4K Instruction Memory
    // 4K = 4 x 1024 = 4096 bytes
    // Each word in memory is 32 bits: 4096 / 4 = 1024 words
    // Memory array to hold instructions
    reg [31:0] memory [0:1023];  // 1024 words each 32-bit

    // Instruction fetch (combinational read)
    always @(*) begin
        instruction = memory[address[11:2]]; // Word-aligned (ignoring lower 2 bits)
    end

    // Initialize memory to zeros (NOP instructions)
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'b000000_00000_00000_00000_00000_000000; // NOP
        end
    end
endmodule
