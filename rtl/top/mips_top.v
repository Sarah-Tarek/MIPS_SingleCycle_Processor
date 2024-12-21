// mips_processor
module mips_processor(
    input clk,                     // Clock signal
    input reset                    // Reset signal
);
    // Internal signals
    wire [31:0] pc_in, pc_out, instruction;
    wire [31:0] read_data1, read_data2, write_data, alu_result, mem_data;
    wire [31:0] sign_ext_imm, shifted_imm, branch_target, jump_target;
    wire [31:0] pc_plus4, next_pc;
    wire [4:0] write_reg;
    wire [1:0] alu_op;
    wire [3:0] alu_control;
    wire zero, branch_taken, jump;
    wire reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch;

    // Program Counter
    pc PC(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // Instruction Memory
    instruction_memory IM(
        .address(pc_out),
        .instruction(instruction)
    );

    // Control Unit
    control_unit CU(
        .opcode(instruction[31:26]),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .alu_op(alu_op),
        .jump(jump)
    );

    // Register File
    register_file RF(
        .clk(clk),
        .reg_write(reg_write),
        .read_reg1(instruction[25:21]),
        .read_reg2(instruction[20:16]),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ALU Control
    alu_control ALU_CTRL(
        .alu_op(alu_op),
        .funct(instruction[5:0]),
        .alu_control(alu_control)
    );

    // Sign Extend
    sign_extend SE(
        .in(instruction[15:0]),
        .out(sign_ext_imm)
    );

    // Shift Left 2 for Branch
    assign shifted_imm = sign_ext_imm << 2;

    // ALU (Main Data Path)
    alu ALU(
        .a(read_data1),
        .b(alu_result),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    // Data Memory
    data_memory DM(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(mem_data)
    );

    // MUX for Write Register Selection
    mux_2to1 WR_MUX(
        .in0(instruction[20:16]),
        .in1(instruction[15:11]),
        .sel(reg_dst),
        .out(write_reg)
    );

    // MUX for ALU Source
    mux_2to1 ALU_SRC_MUX(
        .in0(read_data2),
        .in1(sign_ext_imm),
        .sel(alu_src),
        .out(alu_result)
    );

    // MUX for Write Data to Register
    mux_2to1 WD_MUX(
        .in0(alu_result),
        .in1(mem_data),
        .sel(mem_to_reg),
        .out(write_data)
    );

    // Adder for PC + 4
    adder PC_ADDER(
        .a(pc_out),
        .b(32'd4),
        .result(pc_plus4)
    );

    // Adder for Branch Target Calculation
    adder BR_ADDER(
        .a(pc_plus4),
        .b(shifted_imm),
        .result(branch_target)
    );

    // MUX for PC Selection (Branch)
    mux_2to1 BR_MUX(
        .in0(pc_plus4),
        .in1(branch_target),
        .sel(branch && branch_taken),
        .out(next_pc)
    );

    // MUX for PC Selection (Jump)
    mux_2to1 JP_MUX(
        .in0(next_pc),
        .in1({pc_plus4[31:28], instruction[25:0], 2'b00}),
        .sel(jump),
        .out(pc_in)
    );

    // Branch Control
    branch_control BC(
        .opcode(instruction[31:26]),
        .zero(zero),
        .branch_taken(branch_taken)
    );

endmodule
