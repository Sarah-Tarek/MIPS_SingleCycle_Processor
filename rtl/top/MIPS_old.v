module MIPS_old (
    input clk,                 // Clock signal
    input reset                // Reset signal
);

    // Wire declarations
    wire [31:0] instruction;   // Instruction from instruction memory
    wire [31:0] pc_in;         // Input to the program counter
    wire [31:0] pc_out;        // Current program counter value
    wire [31:0] read_data1, read_data2; // Data from register file
    wire [31:0] alu_result;    // Result from ALU
    wire [31:0] mem_read_data; // Data from memory (for load instruction)
    wire [31:0] write_data;    // Data to write to the register file
    wire zero;                 // Zero flag from ALU
    wire branch_taken;         // Branch decision signal
    wire reg_write;            // Register write signal
    wire mem_to_reg;           // Memory to register signal
    wire mem_read, mem_write;  // Memory read/write signals
    wire alu_src;              // ALU source signal
    wire reg_dst;              // Register destination signal
    wire [1:0] alu_op;         // ALU operation control signal
    wire jump;                 // Jump instruction signal
    
    // Program counter (PC)
    pc pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );
    
    // Instruction memory
    instruction_memory instruction_memory_inst (
        .address(pc_out),
        .instruction(instruction)
    );
    
    // Control unit
    control_unit control_unit_inst (
        .opcode(instruction[31:26]),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch_taken),
        .alu_op(alu_op),
        .jump(jump)
    );
    
    // Register file
    register_file register_file_inst (
        .clk(clk),
        .reg_write(reg_write),
        .read_reg1(instruction[25:21]),
        .read_reg2(instruction[20:16]),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    
    // ALU control
    alu_control alu_control_inst (
        .alu_op(alu_op),
        .funct(instruction[5:0]),
        .alu_control(alu_control)
    );
    
    // ALU
    alu alu_inst (
        .a(read_data1),
        .b(alu_src ? sign_extended_immediate : read_data2),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );
    
    // Data memory
    data_memory data_memory_inst (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );
    
    // Adder for branch calculation
    adder branch_adder (
        .a(pc_out),
        .b(sign_extended_immediate << 2),
        .result(branch_target)
    );
    
    // Branch control
    branch_control branch_control_inst (
        .opcode(instruction[31:26]),
        .zero(zero),
        .branch_taken(branch_taken)
    );
    
    // Sign extension
    sign_extend sign_extend_inst (
        .in(instruction[15:0]),
        .out(sign_extended_immediate)
    );
    
    // Multiplexers for write-back logic
    mux_2to1 mux_mem_to_reg (
        .in0(alu_result),
        .in1(mem_read_data),
        .sel(mem_to_reg),
        .out(write_data)
    );
    
    mux_2to1 mux_pc (
        .in0(branch_taken ? branch_target : pc_out + 4), // Next PC
        .in1({pc_out[31:28], instruction[25:0], 2'b00}),  // Jump address
        .sel(jump),
        .out(pc_in)
    );
    
    // Write register selection
    mux_2to1 mux_reg_dst (
        .in0(instruction[20:16]), // rt field
        .in1(instruction[15:11]), // rd field
        .sel(reg_dst),
        .out(write_reg)
    );
    
endmodule
