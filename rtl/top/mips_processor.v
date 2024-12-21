module mips_processor(
    input  wire clk,
    input  wire reset
);
    // =========================
    // 1) PROGRAM COUNTER (PC)
    // =========================
    reg [31:0] pc_reg, pc_next;

    // On each rising clock edge, update PC (or reset to 0)
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_reg <= 32'd0;
        else
            pc_reg <= pc_next;
    end

    // =========================
    // 2) FETCH INSTRUCTION
    // =========================
    wire [31:0] instruction;

    // Use your instruction_memory module (instructions loaded in TB)
    instruction_memory imem (
        .address(pc_reg),
        .instruction(instruction)
    );

    // =========================
    // 3) DECODE / CONTROL
    // =========================
    wire [5:0] opcode = instruction[31:26];
    wire [4:0] rs     = instruction[25:21];
    wire [4:0] rt     = instruction[20:16];
    wire [4:0] rd     = instruction[15:11];
    wire [5:0] funct  = instruction[5:0];
    wire [15:0] imm   = instruction[15:0];
    wire [25:0] jump_address = instruction[25:0]; // For j / jal

    // Control signals
    wire       reg_dst, alu_src, mem_to_reg, reg_write;
    wire       mem_read, mem_write, branch, jump;
    wire [1:0] alu_op;

    // Instantiate your control unit
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

    // Mux for write register selection: rt vs. rd
    assign write_reg_sel = (reg_dst) ? rd : rt;

    // Simple register file
    reg_file REG_FILE (
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
    assign sign_ext_imm = {{16{imm[15]}}, imm};

    // =========================
    // 6) ALU CONTROL
    // =========================
    wire [3:0] alu_control;
    alu_control ALU_CTRL (
        .alu_op(alu_op),
        .funct(funct),
        .alu_control(alu_control)
    );

    // =========================
    // 7) ALU INPUT MUX
    // =========================
    wire [31:0] alu_input_b;
    assign alu_input_b = (alu_src) ? sign_ext_imm : read_data2;

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
    assign write_data_rf = (mem_to_reg) ? mem_read_data : alu_result;

    // =========================
    // 11) BRANCH CONTROL
    // =========================
    wire branch_taken;
    branch_control BR_CTRL (
        .opcode(opcode),
        .zero(alu_zero),
        .branch_taken(branch_taken)
    );

    // Combined branch condition: must be a branch instruction AND branch is taken
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

    // Shift-left-2 of the sign-extended immediate (for branch offset)
    assign branch_offset = {sign_ext_imm[29:0], 2'b00};

    // Add to get branch target
    adder BRANCH_ADDER (
        .a(pc_plus_4),
        .b(branch_offset),
        .result(branch_sum)
    );

    // Mux for branch or sequential
    assign pc_branch_or_seq = (pc_src) ? branch_sum : pc_plus_4;

    // Jump target: {PC+4[31:28], jump_address << 2}
    assign pc_jump = { pc_plus_4[31:28], jump_address, 2'b00 };

    // Final next PC selection
    always @(*) begin
        if (jump)
            pc_next = pc_jump;
        else
            pc_next = pc_branch_or_seq;
    end

endmodule
