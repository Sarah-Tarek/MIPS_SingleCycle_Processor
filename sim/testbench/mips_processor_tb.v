`timescale 1ns/1ps

module mips_processor_tb;

    // ----------------------------------
    // Testbench signals
    // ----------------------------------
    reg clk;
    reg reset;

    // ----------------------------------
    // Instantiate the MIPS processor (DUT)
    // ----------------------------------
    mips_processor DUT (
        .clk(clk),
        .reset(reset)
    );

    // ----------------------------------
    // 1) Clock generation
    //    10 ns period => toggling every 5 ns
    // ----------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  
    end

    // ----------------------------------
    // 2) Function: Convert register number to ASCII
    //    for $0..$31.
    // ----------------------------------
    function [63:0] reg2str;
        input [4:0] r;
        begin
            case (r)
                5'd0:   reg2str = "$0";
                5'd1:   reg2str = "$1";
                5'd2:   reg2str = "$2";
                5'd3:   reg2str = "$3";
                5'd4:   reg2str = "$4";
                5'd5:   reg2str = "$5";
                5'd6:   reg2str = "$6";
                5'd7:   reg2str = "$7";
                5'd8:   reg2str = "$8";
                5'd9:   reg2str = "$9";
                5'd10:  reg2str = "$10";
                5'd11:  reg2str = "$11";
                5'd12:  reg2str = "$12";
                5'd13:  reg2str = "$13";
                5'd14:  reg2str = "$14";
                5'd15:  reg2str = "$15";
                5'd16:  reg2str = "$16";
                5'd17:  reg2str = "$17";
                5'd18:  reg2str = "$18";
                5'd19:  reg2str = "$19";
                5'd20:  reg2str = "$20";
                5'd21:  reg2str = "$21";
                5'd22:  reg2str = "$22";
                5'd23:  reg2str = "$23";
                5'd24:  reg2str = "$24";
                5'd25:  reg2str = "$25";
                5'd26:  reg2str = "$26";
                5'd27:  reg2str = "$27";
                5'd28:  reg2str = "$28";
                5'd29:  reg2str = "$29";
                5'd30:  reg2str = "$30";
                5'd31:  reg2str = "$31";
                default: reg2str = "$??";
            endcase
        end
    endfunction

    // ----------------------------------
    // 3) Function: Decode a 32-bit instruction
    //    into a MIPS-like assembly string.
    // ----------------------------------
    // 3) Function: Decode a 32-bit instruction into a MIPS-like assembly string.
    function [127:0] decode_instr;
        input [31:0] instr;
        reg [5:0] opcode, funct;
        reg [4:0] rs, rt, rd, shamt;
        reg [15:0] imm;
        reg [25:0] jaddr;
    begin
        opcode = instr[31:26];
        rs     = instr[25:21];
        rt     = instr[20:16];
        rd     = instr[15:11];
        shamt  = instr[10:6];
        funct  = instr[5:0];
        imm    = instr[15:0];
        jaddr  = instr[25:0];

        decode_instr = "unknown";

        case (opcode)
            // --------------------------------------------------
            // R-type (opcode=0)
            // --------------------------------------------------
            6'b000000: begin
                case (funct)
                    6'b100000: decode_instr = {"add  ", reg2str(rd), ",", reg2str(rs), ",", reg2str(rt)};
                    6'b100010: decode_instr = {"sub  ", reg2str(rd), ",", reg2str(rs), ",", reg2str(rt)};
                    6'b100100: decode_instr = {"and  ", reg2str(rd), ",", reg2str(rs), ",", reg2str(rt)};
                    6'b100101: decode_instr = {"or   ", reg2str(rd), ",", reg2str(rs), ",", reg2str(rt)};
                    6'b101010: decode_instr = {"slt  ", reg2str(rd), ",", reg2str(rs), ",", reg2str(rt)};
                    6'b100111: decode_instr = {"nor  ", reg2str(rd), ",", reg2str(rs), ",", reg2str(rt)};
                    6'b000000: decode_instr = {"sll  ", reg2str(rd), ",", reg2str(rt), ",shamt"};
                    6'b000010: decode_instr = {"srl  ", reg2str(rd), ",", reg2str(rt), ",shamt"};
                    6'b000011: decode_instr = {"sra  ", reg2str(rd), ",", reg2str(rt), ",shamt"};
                    default:   decode_instr = "R-type?";
                endcase
            end

            // --------------------------------------------------
            // lw (100011)
            // --------------------------------------------------
            6'b100011: decode_instr = {"lw   ", reg2str(rt), ", offset(", reg2str(rs), ")"};

            // --------------------------------------------------
            // sw (101011)
            // --------------------------------------------------
            6'b101011: decode_instr = {"sw   ", reg2str(rt), ", offset(", reg2str(rs), ")"};

            // --------------------------------------------------
            // beq (000100)
            // --------------------------------------------------
            6'b000100: decode_instr = {"beq  ", reg2str(rs), ",", reg2str(rt), ", offset"};

            // --------------------------------------------------
            // bne (000101)
            // --------------------------------------------------
            6'b000101: decode_instr = {"bne  ", reg2str(rs), ",", reg2str(rt), ", offset"};

            // --------------------------------------------------
            // j (000010)
            // --------------------------------------------------
            6'b000010: decode_instr = {"j    addr"};

            // --------------------------------------------------
            // addi (001000)
            // --------------------------------------------------
            6'b001000: decode_instr = {"addi ", reg2str(rt), ",", reg2str(rs), ", imm"};

            // --------------------------------------------------
            // andi (001100)
            // --------------------------------------------------
            6'b001100: decode_instr = {"andi ", reg2str(rt), ",", reg2str(rs), ", imm"};

            // --------------------------------------------------
            // ori (001101)
            // --------------------------------------------------
            6'b001101: decode_instr = {"ori  ", reg2str(rt), ",", reg2str(rs), ", imm"};

            // --------------------------------------------------
            // lui (001111)
            // --------------------------------------------------
            6'b001111: decode_instr = {"lui  ", reg2str(rt), ", imm"};

            // --------------------------------------------------
            // slti (001010)
            // --------------------------------------------------
            6'b001010: decode_instr = {"slti ", reg2str(rt), ",", reg2str(rs), ", imm"};

            default: decode_instr = "???";
        endcase
    end
    endfunction


    // ----------------------------------
    // 4) Main test sequence
    // ----------------------------------
    initial begin
        // 4.1) Apply reset
        reset = 1;
        #20;
        reset = 0;

        // 4.2) Load instructions into the DUT's instruction memory
        //      (DUT.imem.memory is a 1024-element array of 32-bit regs)

        // addi $1, $0, 10
        DUT.imem.memory[0]  = 32'b001000_00000_00001_0000000000001010;

        // addi $2, $0, 20
        DUT.imem.memory[1]  = 32'b001000_00000_00010_0000000000010100;

        // add $3, $1, $2
        DUT.imem.memory[2]  = 32'b000000_00001_00010_00011_00000_100000;

        // sw $3, 8($0)
        DUT.imem.memory[3]  = 32'b101011_00000_00011_0000000000001000;

        // lw $4, 8($0)
        DUT.imem.memory[4]  = 32'b100011_00000_00100_0000000000001000;

        // sub $5, $1, $2
        DUT.imem.memory[5]  = 32'b000000_00001_00010_00101_00000_100010;

        // beq $4, $3, +2
        DUT.imem.memory[6]  = 32'b000100_00100_00011_0000000000000010;

        // j 9
        DUT.imem.memory[7]  = 32'b000010_00000000000000000000001001;

        // or $4, $4, $1
        DUT.imem.memory[8]  = 32'b000000_00100_00001_00100_00000_100101;

        // slt  $6, $1, $4
        DUT.imem.memory[9]  = 32'b000000_00001_00100_00110_00000_101010;

        // nor $7, $4, $6
        DUT.imem.memory[10] = 32'b000000_00100_00110_00111_00000_100111; 


        // 4.3) Display/Monitor 
        // AND the version that includes R1..R7
        $display("---------------------------------------------------");
        $display("Starting simulation...");
        $display("---------------------------------------------------");

        // We can print a header once
        $display("                Time |      PC       |   Instruction  |       Decoded      |");

        // We can combine all info in one $monitor
        $monitor($time, 
            " | PC=%d | Instr=%h | \"%s\" | R1=%d | R2=%d | R3=%d | R4=%d | R5=%d | R6=%d | R7=%d ",
             DUT.pc_reg,
             DUT.instruction,
             decode_instr(DUT.instruction),
             DUT.REG_FILE.registers[1],
             DUT.REG_FILE.registers[2],
             DUT.REG_FILE.registers[3],
             DUT.REG_FILE.registers[4],
             $signed(DUT.REG_FILE.registers[5]),
             DUT.REG_FILE.registers[6],
             $signed(DUT.REG_FILE.registers[7])
        );

        // 4.4) Let the simulation run
        #400;
        $display("---------------------------------------------------");
        $display("Simulation finished.");
        $display("---------------------------------------------------");
        $stop;
    end
endmodule
