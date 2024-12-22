module mips_processor(
    input  wire clk,
    input  wire reset
);
    // =========================
    // 1) PROGRAM COUNTER (PC)
    // =========================
    wire [31:0] pc_reg;
    wire [31:0] pc_next;

    pc PC (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_next),
        .pc_out(pc_reg)
    );

    // =========================
    // 2) FETCH INSTRUCTION
    // =========================
    wire [31:0] instruction;

    // Instruction memory (instructions loaded externally, e.g., in testbench)
    instruction_memory imem (
        .address(pc_reg),
        .instruction(instruction)
    );

    // =========================
    // 3) DECODE / CONTROL
    // =========================
    wire [5:0] opcode       = instruction[31:26];
    wire [4:0] rs           = instruction[25:21];
    wire [4:0] rt           = instruction[20:16];
    wire [4:0] rd           = instruction[15:11];
    wire [5:0] funct        = instruction[5:0];
    wire [15:0] imm         = instruction[15:0];
    wire [25:0] jump_address= instruction[25:0]; // For j / jal

    // Control signals
    wire       reg_dst, alu_src, mem_to_reg, reg_write;
    wire       mem_read, mem_write, branch, jump;
    wire [1:0] alu_op;

    // Control Unit
    control_unit CU (
        .opcode(opcode),
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

    // =========================
    // 4) REGISTER FILE
    // =========================
    wire [31:0] write_data_rf;  // Data to write to register file
    wire [4:0]  write_reg_sel;  // Destination register index
    wire [31:0] read_data1, read_data2;

    // Mux for write register selection: rt vs rd
    wire [31:0] reg_dst_mux_out;  // Temporary wire to hold full 32-bit mux output

    mux_2to1 reg_dst_mux (
    .in0({27'b0, rt}),   // Zero-extend rt to 32 bits
    .in1({27'b0, rd}),   // Zero-extend rd to 32 bits
    .sel(reg_dst),
    .out(reg_dst_mux_out)  // Mux outputs full 32 bits
    );

    // Extract lower 5 bits from the mux output for register selection
    assign write_reg_sel = reg_dst_mux_out[4:0];




    // Instantiate the register file
    register_file REG_FILE (
        .clk(clk),
        .reg_write(reg_write),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(write_reg_sel),
        .write_data(write_data_rf),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // =========================
    // 5) SIGN EXTENSION
    // =========================
    wire [31:0] sign_ext_imm;
    sign_extend SE (
        .in(imm),
        .out(sign_ext_imm)
    );

    // =========================
    // 6) ALU CONTROL
    // =========================
    wire [3:0] alu_control;
    alu_control ALU_CTRL (
    .alu_op(alu_op),
    .funct(funct),
    .opcode(opcode),
    .alu_control(alu_control)
    );


    // =========================
    // 7) ALU INPUT MUX
    // =========================
    wire [31:0] alu_input_b;
    mux_2to1 alu_input_mux (
        .in0(read_data2),
        .in1(sign_ext_imm),
        .sel(alu_src),
        .out(alu_input_b)
    );

    // =========================
    // 8) ALU
    // =========================
    wire [31:0] alu_result;
    wire alu_zero;
    alu ALU (
        .a(read_data1),
        .b(alu_input_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );

    // =========================
    // 9) DATA MEMORY
    // =========================
    wire [31:0] mem_read_data;
    data_memory DMEM (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(read_data2), // typically store data from register 2
        .read_data(mem_read_data)
    );

    // =========================
    // 10) WRITE-BACK MUX
    // =========================
    mux_2to1 write_back_mux (
        .in0(alu_result),
        .in1(mem_read_data),
        .sel(mem_to_reg),
        .out(write_data_rf)
    );

    // =========================
    // 11) BRANCH CONTROL
    // =========================
    wire branch_taken;
    branch_control BR_CTRL (
        .opcode(opcode),
        .zero(alu_zero),
        .branch_taken(branch_taken)
    );

    // Combined branch condition
    wire pc_src = branch & branch_taken;

    // =========================
    // 12) NEXT PC LOGIC
    // =========================
    wire [31:0] pc_plus_4;
    wire [31:0] branch_offset;
    wire [31:0] branch_sum;
    wire [31:0] pc_branch_or_seq;
    wire [31:0] pc_jump;

    // PC + 4
    adder PC_ADDER (
        .a(pc_reg),
        .b(32'd4),
        .result(pc_plus_4)
    );

    // Shift-left-2 of the sign-extended immediate
    assign branch_offset = {sign_ext_imm[29:0], 2'b00};

    // Add to get branch target
    adder BRANCH_ADDER (
        .a(pc_plus_4),
        .b(branch_offset),
        .result(branch_sum)
    );

    // Mux for branch or sequential
    mux_2to1 pc_branch_mux (
        .in0(pc_plus_4),
        .in1(branch_sum),
        .sel(pc_src),
        .out(pc_branch_or_seq)
    );

    // Jump target: {PC+4[31:28], jump_address << 2}
    assign pc_jump = { pc_plus_4[31:28], jump_address, 2'b00 };

    /* // Next PC selection
    always @(*) begin
        if (jump)
            pc_next = pc_jump;
        else
            pc_next = pc_branch_or_seq;
    end */
    mux_2to1 pc_next_mux (
        .in0(pc_branch_or_seq),
        .in1(pc_jump),
        .sel(jump),
        .out(pc_next)
    );

endmodule
