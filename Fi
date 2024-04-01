module Fib_G(in, out);

	input [4-1:0] in;  //from 0 to 3, total 4 bits
	output out;

	wire not_a, not_b, not_c, not_d;
	wire and0, and1, and2;

	not not_gate0(not_a, in[3]);  //in[3]==a
	not not_gate1(not_b, in[2]);  //in[2]==b
	not not_gate2(not_c, in[1]);  //in[1]==c
	not not_gate3(not_d, in[0]);  //in[0]==d

	and and_gate0(and0, not_a, not_b);
	and and_gate1(and1, in[2], not_c, in[0]);
	and and_gate2(and2, not_b, not_c, not_d);

	or or_gate0(out, and0, and1, and2);

endmodule

module Fib_D(in, out);

	input [4-1:0] in;
	output out;

	assign out = (~in[3] & ~in[2]) | (in[2] & ~in[1] & in[0]) | (~in[2] & ~in[1] & ~in[0]);
	//assign out = (!in[2] & !in[2]) | (in[2] & !in[1] & in[0]) | (!in[2] & !in[1] & !in[0]);

endmodule

module Fib_B(in, out);

	input [4-1:0] in;
	output out;

	reg out;  //must do

	always@(*)begin
		out = 1'b0;
		case(in)
			0, 1, 2, 3, 5, 8, 13:begin
				out = 1'b1;
				end
		endcase
	end

endmodule
