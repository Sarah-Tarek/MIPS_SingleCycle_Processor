module control_unit (
    input  [5:0] opcode,
    output reg   reg_dst,
    output reg   alu_src,
    output reg   mem_to_reg,
    output reg   reg_write,
    output reg   mem_read,
    output reg   mem_write,
    output reg   branch,
    output reg  [1:0] alu_op,
    output reg   jump
);

    always @(*) begin
        // Default values (NOP-like)
        reg_dst    = 0;
        alu_src    = 0;
        mem_to_reg = 0;
        reg_write  = 0;
        mem_read   = 0;
        mem_write  = 0;
        branch     = 0;
        alu_op     = 2'b00;
        jump       = 0;

        case (opcode)

            // R-format (opcode = 0)
            6'b000000: begin
                reg_dst    = 1;     // write to rd
                alu_src    = 0;     // use register data
                mem_to_reg = 0;     // ALU result to reg
                reg_write  = 1;     // write enabled
                mem_read   = 0;
                mem_write  = 0;
                branch     = 0;
                alu_op     = 2'b10; // R-type (let alu_control figure out funct)
                jump       = 0;
            end

            // lw (100011)
            6'b100011: begin
                reg_dst    = 0;     // write to rt
                alu_src    = 1;     // immediate
                mem_to_reg = 1;     // from memory
                reg_write  = 1;
                mem_read   = 1;
                mem_write  = 0;
                branch     = 0;
                alu_op     = 2'b00; // add
                jump       = 0;
            end

            // sw (101011)
            6'b101011: begin
                reg_dst    = 0;  // don't care
                alu_src    = 1;  // immediate
                mem_to_reg = 0;  // don't care
                reg_write  = 0;
                mem_read   = 0;
                mem_write  = 1;
                branch     = 0;
                alu_op     = 2'b00; // add
                jump       = 0;
            end

            // beq (000100)
            6'b000100: begin
                reg_dst    = 0; // don't care
                alu_src    = 0; // register
                mem_to_reg = 0; // don't care
                reg_write  = 0;
                mem_read   = 0;
                mem_write  = 0;
                branch     = 1; // beq
                alu_op     = 2'b01; // subtract
                jump       = 0;
            end

            // bne (000101)
            6'b000101: begin
                reg_dst    = 0; // don't care
                alu_src    = 0;
                mem_to_reg = 0; // don't care
                reg_write  = 0;
                mem_read   = 0;
                mem_write  = 0;
                branch     = 1;
                alu_op     = 2'b01; // subtract
                jump       = 0;
            end

            // j (000010)
            6'b000010: begin
                jump = 1;
            end

            // --------------- NEW I-TYPES ------------------

            // addi (001000)
            6'b001000: begin
                reg_dst    = 0; // write to rt
                alu_src    = 1; // use immediate
                mem_to_reg = 0; // ALU result to register
                reg_write  = 1; // enable
                mem_read   = 0;
                mem_write  = 0;
                branch     = 0;
                alu_op     = 2'b00; // We'll do ADD in the ALU
                jump       = 0;
            end

            // andi (001100)
            6'b001100: begin
                reg_dst    = 0; // write to rt
                alu_src    = 1; // immediate
                mem_to_reg = 0;
                reg_write  = 1;
                mem_read   = 0;
                mem_write  = 0;
                branch     = 0;
                alu_op     = 2'b11; 
                jump       = 0;
                // We'll define "2'b11" as the code that indicates logical AND immediate 
                // in our ALU Control. Or you might just reuse 2'b10 if you decode funct carefully.
            end

            // ori (001101)
            6'b001101: begin
                reg_dst    = 0;
                alu_src    = 1;
                mem_to_reg = 0;
                reg_write  = 1;
                mem_read   = 0;
                mem_write  = 0;
                branch     = 0;
                alu_op     = 2'b11; // or immediate, same logic as above
                jump       = 0;
            end

            // lui (001111)
            6'b001111: begin
                // Typically means load upper 16 bits
                // Implementation detail: Usually the ALU just 
                // places imm << 16 in the register.
                reg_dst    = 0;
                alu_src    = 1;
                mem_to_reg = 0;
                reg_write  = 1;
                mem_read   = 0;
                mem_write  = 0;
                branch     = 0;
                alu_op     = 2'b11; // We'll handle this in alu_control or a separate path
                jump       = 0;
            end

            // slti (001010)
            6'b001010: begin
                reg_dst    = 0;
                alu_src    = 1;
                mem_to_reg = 0;
                reg_write  = 1;
                mem_read   = 0;
                mem_write  = 0;
                branch     = 0;
                alu_op     = 2'b11; // Another variant; your ALU control can decode slti
                jump       = 0;
            end

            // default / NOP
            default: begin
                // By default we keep everything 0 (no reg write, no mem, etc.)
            end
        endcase
    end
endmodule
