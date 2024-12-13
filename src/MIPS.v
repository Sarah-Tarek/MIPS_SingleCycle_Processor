// 2 to 1 MUX
module MUX2to1(in0, in1, sel, out);
    input [31:0] in0, in1;
    input sel;
    output [31:0] out;

    assign out = sel ? in1 : in0;
endmodule


// ALU
module ALU(in1, in2, alu_op, zero, out);
    input [31:0] in1, in2;
    input [2:0] alu_op;
    output reg zero;
    output reg [31:0] out;

    always@(*) begin
      case(alu_op)
        3'b010: out = in1 + in2;  // add
        3'b110: out = in1 - in2;  // sub
        default: out = 0;
      endcase
      zero = (out == 0) ? 1 : 0;
    end
endmodule


// Register File
/*
clk (input): clock
reg_write (input): register write enable
read_reg1 (input): Specifies the address of the first source register to be read.
read_reg2 (input): Specifies the address of the second source register to be read.
write_reg (input): Specifies the address of the destination register to be written.
write_data (input): the data to write to the destination register write_reg when reg_write is enabled.
read_data1 & read_data2 (outputs): These are the values read from the registers specified by read_reg1 and read_reg2.
*/
module Register_File(clk, reg_write, read_reg1, read_reg2, write_reg, write_data, read_data1, read_data2);
  input clk, reg_write;
  input [4:0] read_reg1, read_reg2, write_reg;
  input [31:0] write_data;
  output [31:0] read_data1, read_data2;

  reg [31:0] registers [0:31];  // array of 32 registers each of 32 bits

  assign read_data1 = registers[read_reg1];
  assign read_data2 = registers[read_reg2];

  always @(posedge clk) begin
    if (reg_write) registers[write_reg] <= write_data;
    end
endmodule



