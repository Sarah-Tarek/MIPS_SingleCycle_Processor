module mips_processor(
    input clk,              // Clock signal
    input reset             // Reset signal
);

    // Internal signals
    wire [31:0] pc_in, pc_out, instruction, read_data1, read_data2;
    wire [31:0] sign_ext_out, alu_result, mem_read_data, write_data;
    wire [4:0] write_reg;
    wire [3:0] alu_control;
    wire [1:0] alu_op;
    wire [31:0] pc_plus_4, branch_address, jump_address;
    wire zero, branch_taken, reg_write, alu_src, mem_to_reg;
    wire mem_read, mem_write, reg_dst, jump;

    // Program Counter
    pc pc_module(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // Instruction Memory
    instruction_memory instr_mem(
        .address(pc_out),
        .instruction(instruction)
    );

    // Control Unit
    control_unit control(
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

    // Register File
    register_file reg_file(
        .clk(clk),
        .reg_write(reg_write),
        .read_reg1(instruction[25:21]),
        .read_reg2(instruction[20:16]),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Sign Extend
    sign_extend sign_ext(
        .in(instruction[15:0]),
        .out(sign_ext_out)
    );

    // ALU Control
    alu_control alu_ctrl(
        .alu_op(alu_op),
        .funct(instruction[5:0]),
        .alu_control(alu_control)
    );

    // ALU
    alu alu_module(
        .a(read_data1),
        .b(alu_src_mux_out),  // Updated to use mux for ALU source
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    // Data Memory
    data_memory data_mem(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    // Mux for selecting ALU source
    wire [31:0] alu_src_mux_out;
    mux_2to1 alu_src_mux(
        .in0(read_data2),
        .in1(sign_ext_out),
        .sel(alu_src),
        .out(alu_src_mux_out)
    );

    // Mux to choose destination register (rd or rt)
    assign write_reg = reg_dst ? instruction[15:11] : instruction[20:16];

    // Mux to choose data to write back to registers (ALU result or memory data)
    assign write_data = mem_to_reg ? mem_read_data : alu_result;

    // PC update logic
    assign pc_plus_4 = pc_out + 4;
    assign branch_address = pc_plus_4 + (sign_ext_out << 2);
    assign jump_address = {pc_plus_4[31:28], instruction[25:0], 2'b00};
    assign pc_in = jump ? jump_address : (branch_taken && zero) ? branch_address : pc_plus_4;

endmodule
