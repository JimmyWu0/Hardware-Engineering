module ALU(A, B, Cin, Mode, Y, Cout, Overflow);

	parameter n = 16;
	parameter m = 4;
	
	input [n - 1: 0] A, B;
	input Cin;
	input [m - 1: 0] Mode;	

	output reg [n - 1: 0] Y;
	output reg Cout;
	output reg Overflow;

	reg [m-1:0] a;

	wire [n-1:0] b;
	assign b=~B+16'b1;
	wire [n-1:0] y1,y2;
	wire Cout1,Cout2;

	Adder_16bit add1(A,B,Cin,y1,Cout1);
	Adder_16bit add2(A,b,1'b0,y2,Cout2);
	
	always@(*)begin
		case(Mode)
			//Logical shift A left by 1-bit.
			4'd0: begin
				Y=A<<1'b1;
			end
			//Arithmetic shift A left by 1-bit.
			4'd1: begin
				Y=A<<<1'b1;
			end
			//Logical shift A right by 1-bit.
			4'd2: begin
				Y=A>>1'b1;
			end
			//Arithmetic shift A right by 1-bit.
			4'd3: begin
				Y=A>>>1'b1;
				Y[15]=Y[14];
			end
			//Add two numbers with cla.
			4'd4: begin
				Y=y1;
				Cout=Cout1;
				Overflow=A[n-1]&B[n-1]&(~Y[n-1])|(~A[n-1])&(~B[n-1])&Y[n-1];
			end
			//Subtract B from A.
			4'd5: begin
				Y=y2;
				Cout=Cout2;
				Overflow=A[n-1]&b[n-1]&(~Y[n-1])|(~A[n-1])&(~b[n-1])&Y[n-1];
			end
			//and
			4'd6: begin
				Y=A&B;
			end
			//or
			4'd7: begin
				Y=A|B;
			end
			//not A
			4'd8: begin
				Y=~A;
			end
			//xor
			4'd9: begin
				Y=A^B;
			end
			//xnor
			4'd10: begin
				Y=~(A^B);
			end
			//nor
			4'd11: begin
				Y=~(A|B);
			end
			//binary to one-hot
			4'd12: begin
				a=A[3:0];
				Y=16'b1<<a;
			end
			//Comparator
			4'd13: begin
				if(A[15]==B[15])
					if(A<B)
						Y=1'b1;
					else
						Y=1'b0;
				else if(A[15]==1'b1 && B[15]==1'b0)
					Y=1'b1;
				else if(A[15]==1'b0 && B[15]==1'b1)
					Y=1'b0;
			end
			//B
			4'd14: begin
				Y=B;
			end
			//find first one from left
			4'd15: begin
				if(A[15]==1'b1)
					Y=4'd15;
				else if(A[14]==1'b1)
					Y=4'd14;
				else if(A[13]==1'b1)
                                        Y=4'd13;
				else if(A[12]==1'b1)
                                        Y=4'd12;
				else if(A[11]==1'b1)
                                        Y=4'd11;
				else if(A[10]==1'b1)
                                        Y=4'd10;
				else if(A[9]==1'b1)
                                        Y=4'd9;
				else if(A[8]==1'b1)
                                        Y=4'd8;
				else if(A[7]==1'b1)
                                        Y=4'd7;
				else if(A[6]==1'b1)
                                        Y=4'd6;
				else if(A[5]==1'b1)
                                        Y=4'd5;
				else if(A[4]==1'b1)
                                        Y=4'd4;
				else if(A[3]==1'b1)
                                        Y=4'd3;
				else if(A[2]==1'b1)
					Y=4'd2;
				else if(A[1]==1'b1)
					Y=4'd1;
				else
					Y=4'd0;
			end
			default: begin
			end
		endcase
	end
endmodule

module CLA_4bit(A, B, Cin, S, Cout);
        parameter n = 4;
        input [n - 1: 0] A, B;
        input Cin;

        output [n - 1: 0] S;
        output Cout;

        wire c1,c2,c3,p0,p1,p2,p3,g0,g1,g2,g3;

        assign p0=A[0]^B[0];
        assign p1=A[1]^B[1];
        assign p2=A[2]^B[2];
        assign p3=A[3]^B[3];
        assign g0=A[0]&B[0];
        assign g1=A[1]&B[1];
        assign g2=A[2]&B[2];
        assign g3=A[3]&B[3];
        assign c1=g0|(p0&Cin);
        assign c2=g1|(p1&g0)|(p1&p0&Cin);
        assign c3=g2|(p2&g1)|(p2&p1&g0)|(p2&p1&p0&Cin);
        assign Cout=g3|(p3&g2)|(p3&p2&g1)|(p3&p2&p1&g0)|(p3&p2&p1&p0&Cin);
        assign S[3]=p3^c3;
        assign S[2]=p2^c2;
        assign S[1]=p1^c1;
        assign S[0]=p0^Cin;

endmodule

module Adder_16bit(A, B, Cin, S, Cout);

        parameter n = 16;
        parameter m = 4;

        input [n - 1: 0] A, B;
        input Cin;

        output [n - 1: 0] S;
        output Cout;

        wire c4,c8,c12;

	CLA_4bit cla1(A[3:0],B[3:0],Cin,S[3:0],c4);
	CLA_4bit cla2(A[7:4],B[7:4],c4,S[7:4],c8);
	CLA_4bit cla3(A[11:8],B[11:8],c8,S[11:8],c12);
	CLA_4bit cla4(A[15:12],B[15:12],c12,S[15:12],Cout);

endmodule
