// 2 to 1 MUX
module MUX2to1(in0, in1, sel, out);
    input [31:0] in0, in1;
    input sel;
    output [31:0] out;

    assign out = (sel == 0) ? in0 : in1;
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

// 