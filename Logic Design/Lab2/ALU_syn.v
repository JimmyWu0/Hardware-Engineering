/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09
// Date      : Thu Apr 28 05:35:58 2022
/////////////////////////////////////////////////////////////


module CLA_4bit_0 ( A, B, Cin, S, Cout );
  input [3:0] A;
  input [3:0] B;
  output [3:0] S;
  input Cin;
  output Cout;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;

  XOR2X1 U1 ( .A(n1), .B(n2), .Y(S[3]) );
  XOR2X1 U2 ( .A(n3), .B(n4), .Y(S[2]) );
  XOR2X1 U3 ( .A(n5), .B(n6), .Y(S[1]) );
  XOR2X1 U4 ( .A(Cin), .B(n7), .Y(S[0]) );
  OAI2BB2XL U5 ( .B0(n2), .B1(n1), .A0N(B[3]), .A1N(A[3]), .Y(Cout) );
  XNOR2X1 U6 ( .A(A[3]), .B(B[3]), .Y(n1) );
  OA21XL U7 ( .A0(n4), .A1(n3), .B0(n8), .Y(n2) );
  OAI21XL U8 ( .A0(B[2]), .A1(A[2]), .B0(n8), .Y(n3) );
  NAND2X1 U9 ( .A(B[2]), .B(A[2]), .Y(n8) );
  OA21XL U10 ( .A0(n6), .A1(n5), .B0(n9), .Y(n4) );
  OAI21XL U11 ( .A0(B[1]), .A1(A[1]), .B0(n9), .Y(n5) );
  NAND2X1 U12 ( .A(B[1]), .B(A[1]), .Y(n9) );
  AOI22X1 U13 ( .A0(n7), .A1(Cin), .B0(A[0]), .B1(B[0]), .Y(n6) );
  XOR2X1 U14 ( .A(A[0]), .B(B[0]), .Y(n7) );
endmodule


module CLA_4bit_7 ( A, B, Cin, S, Cout );
  input [3:0] A;
  input [3:0] B;
  output [3:0] S;
  input Cin;
  output Cout;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;

  XOR2X1 U1 ( .A(n1), .B(n2), .Y(S[3]) );
  XOR2X1 U2 ( .A(n3), .B(n4), .Y(S[2]) );
  XOR2X1 U3 ( .A(n5), .B(n6), .Y(S[1]) );
  XOR2X1 U4 ( .A(Cin), .B(n7), .Y(S[0]) );
  OAI2BB2XL U5 ( .B0(n2), .B1(n1), .A0N(B[3]), .A1N(A[3]), .Y(Cout) );
  XNOR2X1 U6 ( .A(A[3]), .B(B[3]), .Y(n1) );
  OA21XL U7 ( .A0(n4), .A1(n3), .B0(n8), .Y(n2) );
  OAI21XL U8 ( .A0(B[2]), .A1(A[2]), .B0(n8), .Y(n3) );
  NAND2X1 U9 ( .A(B[2]), .B(A[2]), .Y(n8) );
  OA21XL U10 ( .A0(n6), .A1(n5), .B0(n9), .Y(n4) );
  OAI21XL U11 ( .A0(B[1]), .A1(A[1]), .B0(n9), .Y(n5) );
  NAND2X1 U12 ( .A(B[1]), .B(A[1]), .Y(n9) );
  AOI22X1 U13 ( .A0(n7), .A1(Cin), .B0(A[0]), .B1(B[0]), .Y(n6) );
  XOR2X1 U14 ( .A(A[0]), .B(B[0]), .Y(n7) );
endmodule


module CLA_4bit_6 ( A, B, Cin, S, Cout );
  input [3:0] A;
  input [3:0] B;
  output [3:0] S;
  input Cin;
  output Cout;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;

  XOR2X1 U1 ( .A(n1), .B(n2), .Y(S[3]) );
  XOR2X1 U2 ( .A(n3), .B(n4), .Y(S[2]) );
  XOR2X1 U3 ( .A(n5), .B(n6), .Y(S[1]) );
  XOR2X1 U4 ( .A(Cin), .B(n7), .Y(S[0]) );
  OAI2BB2XL U5 ( .B0(n2), .B1(n1), .A0N(B[3]), .A1N(A[3]), .Y(Cout) );
  XNOR2X1 U6 ( .A(A[3]), .B(B[3]), .Y(n1) );
  OA21XL U7 ( .A0(n4), .A1(n3), .B0(n8), .Y(n2) );
  OAI21XL U8 ( .A0(B[2]), .A1(A[2]), .B0(n8), .Y(n3) );
  NAND2X1 U9 ( .A(B[2]), .B(A[2]), .Y(n8) );
  OA21XL U10 ( .A0(n6), .A1(n5), .B0(n9), .Y(n4) );
  OAI21XL U11 ( .A0(B[1]), .A1(A[1]), .B0(n9), .Y(n5) );
  NAND2X1 U12 ( .A(B[1]), .B(A[1]), .Y(n9) );
  AOI22X1 U13 ( .A0(n7), .A1(Cin), .B0(A[0]), .B1(B[0]), .Y(n6) );
  XOR2X1 U14 ( .A(A[0]), .B(B[0]), .Y(n7) );
endmodule


module CLA_4bit_5 ( A, B, Cin, S, Cout );
  input [3:0] A;
  input [3:0] B;
  output [3:0] S;
  input Cin;
  output Cout;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;

  XOR2X1 U1 ( .A(n1), .B(n2), .Y(S[3]) );
  XOR2X1 U2 ( .A(n3), .B(n4), .Y(S[2]) );
  XOR2X1 U3 ( .A(n5), .B(n6), .Y(S[1]) );
  XOR2X1 U4 ( .A(Cin), .B(n7), .Y(S[0]) );
  OAI2BB2XL U5 ( .B0(n2), .B1(n1), .A0N(B[3]), .A1N(A[3]), .Y(Cout) );
  XNOR2X1 U6 ( .A(A[3]), .B(B[3]), .Y(n1) );
  OA21XL U7 ( .A0(n4), .A1(n3), .B0(n8), .Y(n2) );
  OAI21XL U8 ( .A0(B[2]), .A1(A[2]), .B0(n8), .Y(n3) );
  NAND2X1 U9 ( .A(B[2]), .B(A[2]), .Y(n8) );
  OA21XL U10 ( .A0(n6), .A1(n5), .B0(n9), .Y(n4) );
  OAI21XL U11 ( .A0(B[1]), .A1(A[1]), .B0(n9), .Y(n5) );
  NAND2X1 U12 ( .A(B[1]), .B(A[1]), .Y(n9) );
  AOI22X1 U13 ( .A0(n7), .A1(Cin), .B0(A[0]), .B1(B[0]), .Y(n6) );
  XOR2X1 U14 ( .A(A[0]), .B(B[0]), .Y(n7) );
endmodule


module Adder_16bit_0 ( A, B, Cin, S, Cout );
  input [15:0] A;
  input [15:0] B;
  output [15:0] S;
  input Cin;
  output Cout;
  wire   c4, c8, c12;

  CLA_4bit_0 cla1 ( .A(A[3:0]), .B(B[3:0]), .Cin(Cin), .S(S[3:0]), .Cout(c4)
         );
  CLA_4bit_7 cla2 ( .A(A[7:4]), .B(B[7:4]), .Cin(c4), .S(S[7:4]), .Cout(c8) );
  CLA_4bit_6 cla3 ( .A(A[11:8]), .B(B[11:8]), .Cin(c8), .S(S[11:8]), .Cout(c12) );
  CLA_4bit_5 cla4 ( .A(A[15:12]), .B(B[15:12]), .Cin(c12), .S(S[15:12]), 
        .Cout(Cout) );
endmodule


module CLA_4bit_4 ( A, B, Cin, S, Cout );
  input [3:0] A;
  input [3:0] B;
  output [3:0] S;
  input Cin;
  output Cout;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;

  XOR2X1 U1 ( .A(n1), .B(n2), .Y(S[3]) );
  XOR2X1 U2 ( .A(n3), .B(n4), .Y(S[2]) );
  XOR2X1 U3 ( .A(n5), .B(n6), .Y(S[1]) );
  XOR2X1 U4 ( .A(Cin), .B(n7), .Y(S[0]) );
  OAI2BB2XL U5 ( .B0(n2), .B1(n1), .A0N(B[3]), .A1N(A[3]), .Y(Cout) );
  XNOR2X1 U6 ( .A(A[3]), .B(B[3]), .Y(n1) );
  OA21XL U7 ( .A0(n4), .A1(n3), .B0(n8), .Y(n2) );
  OAI21XL U8 ( .A0(B[2]), .A1(A[2]), .B0(n8), .Y(n3) );
  NAND2X1 U9 ( .A(B[2]), .B(A[2]), .Y(n8) );
  OA21XL U10 ( .A0(n6), .A1(n5), .B0(n9), .Y(n4) );
  OAI21XL U11 ( .A0(B[1]), .A1(A[1]), .B0(n9), .Y(n5) );
  NAND2X1 U12 ( .A(B[1]), .B(A[1]), .Y(n9) );
  AOI22X1 U13 ( .A0(n7), .A1(Cin), .B0(A[0]), .B1(B[0]), .Y(n6) );
  XOR2X1 U14 ( .A(A[0]), .B(B[0]), .Y(n7) );
endmodule


module CLA_4bit_3 ( A, B, Cin, S, Cout );
  input [3:0] A;
  input [3:0] B;
  output [3:0] S;
  input Cin;
  output Cout;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;

  XOR2X1 U1 ( .A(n1), .B(n2), .Y(S[3]) );
  XOR2X1 U2 ( .A(n3), .B(n4), .Y(S[2]) );
  XOR2X1 U3 ( .A(n5), .B(n6), .Y(S[1]) );
  XOR2X1 U4 ( .A(Cin), .B(n7), .Y(S[0]) );
  OAI2BB2XL U5 ( .B0(n2), .B1(n1), .A0N(B[3]), .A1N(A[3]), .Y(Cout) );
  XNOR2X1 U6 ( .A(A[3]), .B(B[3]), .Y(n1) );
  OA21XL U7 ( .A0(n4), .A1(n3), .B0(n8), .Y(n2) );
  OAI21XL U8 ( .A0(B[2]), .A1(A[2]), .B0(n8), .Y(n3) );
  NAND2X1 U9 ( .A(B[2]), .B(A[2]), .Y(n8) );
  OA21XL U10 ( .A0(n6), .A1(n5), .B0(n9), .Y(n4) );
  OAI21XL U11 ( .A0(B[1]), .A1(A[1]), .B0(n9), .Y(n5) );
  NAND2X1 U12 ( .A(B[1]), .B(A[1]), .Y(n9) );
  AOI22X1 U13 ( .A0(n7), .A1(Cin), .B0(A[0]), .B1(B[0]), .Y(n6) );
  XOR2X1 U14 ( .A(A[0]), .B(B[0]), .Y(n7) );
endmodule


module CLA_4bit_2 ( A, B, Cin, S, Cout );
  input [3:0] A;
  input [3:0] B;
  output [3:0] S;
  input Cin;
  output Cout;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;

  XOR2X1 U1 ( .A(n1), .B(n2), .Y(S[3]) );
  XOR2X1 U2 ( .A(n3), .B(n4), .Y(S[2]) );
  XOR2X1 U3 ( .A(n5), .B(n6), .Y(S[1]) );
  XOR2X1 U4 ( .A(Cin), .B(n7), .Y(S[0]) );
  OAI2BB2XL U5 ( .B0(n2), .B1(n1), .A0N(B[3]), .A1N(A[3]), .Y(Cout) );
  XNOR2X1 U6 ( .A(A[3]), .B(B[3]), .Y(n1) );
  OA21XL U7 ( .A0(n4), .A1(n3), .B0(n8), .Y(n2) );
  OAI21XL U8 ( .A0(B[2]), .A1(A[2]), .B0(n8), .Y(n3) );
  NAND2X1 U9 ( .A(B[2]), .B(A[2]), .Y(n8) );
  OA21XL U10 ( .A0(n6), .A1(n5), .B0(n9), .Y(n4) );
  OAI21XL U11 ( .A0(B[1]), .A1(A[1]), .B0(n9), .Y(n5) );
  NAND2X1 U12 ( .A(B[1]), .B(A[1]), .Y(n9) );
  AOI22X1 U13 ( .A0(n7), .A1(Cin), .B0(A[0]), .B1(B[0]), .Y(n6) );
  XOR2X1 U14 ( .A(A[0]), .B(B[0]), .Y(n7) );
endmodule


module CLA_4bit_1 ( A, B, Cin, S, Cout );
  input [3:0] A;
  input [3:0] B;
  output [3:0] S;
  input Cin;
  output Cout;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;

  XOR2X1 U1 ( .A(n1), .B(n2), .Y(S[3]) );
  XOR2X1 U2 ( .A(n3), .B(n4), .Y(S[2]) );
  XOR2X1 U3 ( .A(n5), .B(n6), .Y(S[1]) );
  XOR2X1 U4 ( .A(Cin), .B(n7), .Y(S[0]) );
  OAI2BB2XL U5 ( .B0(n2), .B1(n1), .A0N(B[3]), .A1N(A[3]), .Y(Cout) );
  XNOR2X1 U6 ( .A(A[3]), .B(B[3]), .Y(n1) );
  OA21XL U7 ( .A0(n4), .A1(n3), .B0(n8), .Y(n2) );
  OAI21XL U8 ( .A0(B[2]), .A1(A[2]), .B0(n8), .Y(n3) );
  NAND2X1 U9 ( .A(B[2]), .B(A[2]), .Y(n8) );
  OA21XL U10 ( .A0(n6), .A1(n5), .B0(n9), .Y(n4) );
  OAI21XL U11 ( .A0(B[1]), .A1(A[1]), .B0(n9), .Y(n5) );
  NAND2X1 U12 ( .A(B[1]), .B(A[1]), .Y(n9) );
  AOI22X1 U13 ( .A0(n7), .A1(Cin), .B0(A[0]), .B1(B[0]), .Y(n6) );
  XOR2X1 U14 ( .A(A[0]), .B(B[0]), .Y(n7) );
endmodule


module Adder_16bit_1 ( A, B, Cin, S, Cout );
  input [15:0] A;
  input [15:0] B;
  output [15:0] S;
  input Cin;
  output Cout;
  wire   c4, c8, c12;

  CLA_4bit_4 cla1 ( .A(A[3:0]), .B(B[3:0]), .Cin(Cin), .S(S[3:0]), .Cout(c4)
         );
  CLA_4bit_3 cla2 ( .A(A[7:4]), .B(B[7:4]), .Cin(c4), .S(S[7:4]), .Cout(c8) );
  CLA_4bit_2 cla3 ( .A(A[11:8]), .B(B[11:8]), .Cin(c8), .S(S[11:8]), .Cout(c12) );
  CLA_4bit_1 cla4 ( .A(A[15:12]), .B(B[15:12]), .Cin(c12), .S(S[15:12]), 
        .Cout(Cout) );
endmodule


module ALU_DW01_inc_0 ( A, SUM );
  input [15:0] A;
  output [15:0] SUM;

  wire   [15:2] carry;

  ADDHXL U1_1_14 ( .A(A[14]), .B(carry[14]), .CO(carry[15]), .S(SUM[14]) );
  ADDHXL U1_1_12 ( .A(A[12]), .B(carry[12]), .CO(carry[13]), .S(SUM[12]) );
  ADDHXL U1_1_10 ( .A(A[10]), .B(carry[10]), .CO(carry[11]), .S(SUM[10]) );
  ADDHXL U1_1_8 ( .A(A[8]), .B(carry[8]), .CO(carry[9]), .S(SUM[8]) );
  ADDHXL U1_1_6 ( .A(A[6]), .B(carry[6]), .CO(carry[7]), .S(SUM[6]) );
  ADDHXL U1_1_4 ( .A(A[4]), .B(carry[4]), .CO(carry[5]), .S(SUM[4]) );
  ADDHXL U1_1_13 ( .A(A[13]), .B(carry[13]), .CO(carry[14]), .S(SUM[13]) );
  ADDHXL U1_1_11 ( .A(A[11]), .B(carry[11]), .CO(carry[12]), .S(SUM[11]) );
  ADDHXL U1_1_9 ( .A(A[9]), .B(carry[9]), .CO(carry[10]), .S(SUM[9]) );
  ADDHXL U1_1_7 ( .A(A[7]), .B(carry[7]), .CO(carry[8]), .S(SUM[7]) );
  ADDHXL U1_1_5 ( .A(A[5]), .B(carry[5]), .CO(carry[6]), .S(SUM[5]) );
  ADDHXL U1_1_2 ( .A(A[2]), .B(carry[2]), .CO(carry[3]), .S(SUM[2]) );
  ADDHXL U1_1_3 ( .A(A[3]), .B(carry[3]), .CO(carry[4]), .S(SUM[3]) );
  ADDHXL U1_1_1 ( .A(A[1]), .B(A[0]), .CO(carry[2]), .S(SUM[1]) );
  CLKINVX1 U1 ( .A(A[0]), .Y(SUM[0]) );
  XOR2X1 U2 ( .A(carry[15]), .B(A[15]), .Y(SUM[15]) );
endmodule


module ALU ( A, B, Cin, Mode, Y, Cout, Overflow );
  input [15:0] A;
  input [15:0] B;
  input [3:0] Mode;
  output [15:0] Y;
  input Cin;
  output Cout, Overflow;
  wire   N21, N22, N23, N24, N25, N26, N27, N28, N29, N30, N31, N32, N33, N34,
         N35, N36, Cout1, Cout2, N243, N244, N245, N246, N247, N248, N249,
         N250, N251, N252, N253, N254, N255, N256, N257, N258, N259, N260,
         N261, n201, n202, n203, n204, n205, n206, n207, n208, n209, n210,
         n211, n212, n213, n214, n215, n216, n217, n218, n219, n220, n221,
         n222, n223, n224, n225, n226, n227, n228, n229, n230, n231, n232,
         n233, n234, n235, n236, n237, n238, n239, n240, n241, n242, n243,
         n244, n245, n246, n247, n248, n249, n250, n251, n252, n253, n254,
         n255, n256, n257, n258, n259, n260, n261, n262, n263, n264, n265,
         n266, n267, n268, n269, n270, n271, n272, n273, n274, n275, n276,
         n277, n278, n279, n280, n281, n282, n283, n284, n285, n286, n287,
         n288, n289, n290, n291, n292, n293, n294, n295, n296, n297, n298,
         n299, n300, n301, n302, n303, n304, n305, n306, n307, n308, n309,
         n310, n311, n312, n313, n314, n315, n316, n317, n318, n319, n320,
         n321, n322, n323, n324, n325, n326, n327, n328, n329, n330, n331,
         n332, n333, n334, n335, n336, n337, n338, n339, n340, n341, n342,
         n343, n344, n345, n346, n347, n348, n349, n350, n351, n352, n353,
         n354, n355, n356, n357, n358, n359, n360, n361, n362, n363, n364,
         n365, n366, n367, n368, n369, n370, n371, n372, n373, n374, n375,
         n376, n377, n378, n379, n380, n381, n382, n383, n384, n385, n386,
         n387, n388, n389, n390, n391, n392, n393, n394, n395, n396, n397,
         n398, n399, n400, n401, n402, n403, n404, n405, n406, n407, n408,
         n409, n410, n411, n412;
  wire   [15:0] b;
  wire   [15:0] y1;
  wire   [15:0] y2;

  Adder_16bit_0 add1 ( .A(A), .B(B), .Cin(Cin), .S(y1), .Cout(Cout1) );
  Adder_16bit_1 add2 ( .A(A), .B(b), .Cin(1'b0), .S(y2), .Cout(Cout2) );
  ALU_DW01_inc_0 add_0_root_add_87_ni ( .A({N21, N22, N23, N24, N25, N26, N27, 
        N28, N29, N30, N31, N32, N33, N34, N35, N36}), .SUM(b) );
  TLATX1 Cout_reg ( .G(N259), .D(N260), .Q(Cout) );
  TLATX1 \Y_reg[14]  ( .G(1'b1), .D(N257), .Q(Y[14]) );
  TLATX1 \Y_reg[13]  ( .G(1'b1), .D(N256), .Q(Y[13]) );
  TLATX1 \Y_reg[12]  ( .G(1'b1), .D(N255), .Q(Y[12]) );
  TLATX1 \Y_reg[11]  ( .G(1'b1), .D(N254), .Q(Y[11]) );
  TLATX1 \Y_reg[10]  ( .G(1'b1), .D(N253), .Q(Y[10]) );
  TLATX1 \Y_reg[9]  ( .G(1'b1), .D(N252), .Q(Y[9]) );
  TLATX1 \Y_reg[8]  ( .G(1'b1), .D(N251), .Q(Y[8]) );
  TLATX1 \Y_reg[7]  ( .G(1'b1), .D(N250), .Q(Y[7]) );
  TLATX1 \Y_reg[6]  ( .G(1'b1), .D(N249), .Q(Y[6]) );
  TLATX1 \Y_reg[5]  ( .G(1'b1), .D(N248), .Q(Y[5]) );
  TLATX1 \Y_reg[4]  ( .G(1'b1), .D(N247), .Q(Y[4]) );
  TLATX1 \Y_reg[2]  ( .G(1'b1), .D(N245), .Q(Y[2]) );
  TLATX1 \Y_reg[3]  ( .G(1'b1), .D(N246), .Q(Y[3]) );
  TLATX1 \Y_reg[1]  ( .G(1'b1), .D(N244), .Q(Y[1]) );
  TLATX1 \Y_reg[0]  ( .G(1'b1), .D(N243), .Q(Y[0]) );
  TLATX1 Overflow_reg ( .G(N259), .D(N261), .Q(Overflow) );
  TLATX1 \Y_reg[15]  ( .G(1'b1), .D(N258), .Q(Y[15]) );
  MXI2X1 U215 ( .A(n201), .B(n202), .S0(n203), .Y(N261) );
  AOI33X1 U216 ( .A0(n204), .A1(N21), .A2(y1[15]), .B0(n205), .B1(n206), .B2(
        y2[15]), .Y(n202) );
  CLKINVX1 U217 ( .A(n207), .Y(n201) );
  OAI33X1 U218 ( .A0(N21), .A1(y1[15]), .A2(n208), .B0(n209), .B1(y2[15]), 
        .B2(n206), .Y(n207) );
  CLKINVX1 U219 ( .A(b[15]), .Y(n206) );
  AO22X1 U220 ( .A0(Cout2), .A1(n205), .B0(Cout1), .B1(n204), .Y(N260) );
  NAND2X1 U221 ( .A(n209), .B(n208), .Y(N259) );
  CLKINVX1 U222 ( .A(n204), .Y(n208) );
  NAND4X1 U223 ( .A(n210), .B(n211), .C(n212), .D(n213), .Y(N258) );
  AOI221XL U224 ( .A0(n214), .A1(B[15]), .B0(y1[15]), .B1(n204), .C0(n215), 
        .Y(n213) );
  OAI32X1 U225 ( .A0(n216), .A1(n217), .A2(n218), .B0(n219), .B1(n220), .Y(
        n215) );
  MXI2X1 U226 ( .A(n221), .B(n222), .S0(n203), .Y(n212) );
  OAI21XL U227 ( .A0(B[15]), .A1(n223), .B0(n224), .Y(n222) );
  OAI221XL U228 ( .A0(N21), .A1(n225), .B0(n226), .B1(n227), .C0(n228), .Y(
        n221) );
  NAND2X1 U229 ( .A(y2[15]), .B(n205), .Y(n211) );
  MXI2X1 U230 ( .A(n229), .B(n230), .S0(n231), .Y(n210) );
  NAND2X1 U231 ( .A(n232), .B(n233), .Y(N257) );
  AOI221XL U232 ( .A0(n234), .A1(A[15]), .B0(y1[14]), .B1(n204), .C0(n235), 
        .Y(n233) );
  OAI22XL U233 ( .A0(n219), .A1(n236), .B0(n217), .B1(n237), .Y(n235) );
  AOI211X1 U234 ( .A0(y2[14]), .A1(n205), .B0(n238), .C0(n239), .Y(n232) );
  MXI2X1 U235 ( .A(n228), .B(n224), .S0(n220), .Y(n239) );
  MX3XL U236 ( .A(n229), .B(n240), .C(n241), .S0(n220), .S1(B[14]), .Y(n238)
         );
  NAND2X1 U237 ( .A(n242), .B(n243), .Y(n241) );
  MXI2X1 U238 ( .A(n244), .B(n229), .S0(n220), .Y(n242) );
  NAND2X1 U239 ( .A(n245), .B(n246), .Y(N256) );
  AOI221XL U240 ( .A0(n234), .A1(A[14]), .B0(y1[13]), .B1(n204), .C0(n247), 
        .Y(n246) );
  OAI32X1 U241 ( .A0(n218), .A1(A[1]), .A2(n217), .B0(n219), .B1(n248), .Y(
        n247) );
  AOI211X1 U242 ( .A0(y2[13]), .A1(n205), .B0(n249), .C0(n250), .Y(n245) );
  MXI2X1 U243 ( .A(n228), .B(n224), .S0(n236), .Y(n250) );
  MX3XL U244 ( .A(n229), .B(n240), .C(n251), .S0(n236), .S1(B[13]), .Y(n249)
         );
  NAND2X1 U245 ( .A(n252), .B(n243), .Y(n251) );
  MXI2X1 U246 ( .A(n244), .B(n229), .S0(n236), .Y(n252) );
  NAND2X1 U247 ( .A(n253), .B(n254), .Y(N255) );
  AOI221XL U248 ( .A0(A[13]), .A1(n234), .B0(y1[12]), .B1(n204), .C0(n255), 
        .Y(n254) );
  OAI32X1 U249 ( .A0(n217), .A1(A[1]), .A2(A[0]), .B0(n219), .B1(n256), .Y(
        n255) );
  NAND2BX1 U250 ( .AN(n257), .B(A[2]), .Y(n217) );
  AOI211X1 U251 ( .A0(y2[12]), .A1(n205), .B0(n258), .C0(n259), .Y(n253) );
  MXI2X1 U252 ( .A(n228), .B(n224), .S0(n248), .Y(n259) );
  MX3XL U253 ( .A(n229), .B(n240), .C(n260), .S0(n248), .S1(B[12]), .Y(n258)
         );
  NAND2X1 U254 ( .A(n261), .B(n243), .Y(n260) );
  MXI2X1 U255 ( .A(n244), .B(n229), .S0(n248), .Y(n261) );
  NAND2X1 U256 ( .A(n262), .B(n263), .Y(N254) );
  AOI221XL U257 ( .A0(A[12]), .A1(n234), .B0(y1[11]), .B1(n204), .C0(n264), 
        .Y(n263) );
  OAI32X1 U258 ( .A0(n265), .A1(n257), .A2(n218), .B0(n219), .B1(n266), .Y(
        n264) );
  AOI211X1 U259 ( .A0(y2[11]), .A1(n205), .B0(n267), .C0(n268), .Y(n262) );
  MXI2X1 U260 ( .A(n228), .B(n224), .S0(n256), .Y(n268) );
  MX3XL U261 ( .A(n229), .B(n240), .C(n269), .S0(n256), .S1(B[11]), .Y(n267)
         );
  NAND2X1 U262 ( .A(n270), .B(n243), .Y(n269) );
  MXI2X1 U263 ( .A(n244), .B(n229), .S0(n256), .Y(n270) );
  NAND2X1 U264 ( .A(n271), .B(n272), .Y(N253) );
  AOI221XL U265 ( .A0(A[11]), .A1(n234), .B0(y1[10]), .B1(n204), .C0(n273), 
        .Y(n272) );
  OAI32X1 U266 ( .A0(n265), .A1(A[0]), .A2(n257), .B0(n219), .B1(n274), .Y(
        n273) );
  AOI211X1 U267 ( .A0(y2[10]), .A1(n205), .B0(n275), .C0(n276), .Y(n271) );
  MXI2X1 U268 ( .A(n228), .B(n224), .S0(n266), .Y(n276) );
  MX3XL U269 ( .A(n229), .B(n240), .C(n277), .S0(n266), .S1(B[10]), .Y(n275)
         );
  NAND2X1 U270 ( .A(n278), .B(n243), .Y(n277) );
  MXI2X1 U271 ( .A(n244), .B(n229), .S0(n266), .Y(n278) );
  NAND2X1 U272 ( .A(n279), .B(n280), .Y(N252) );
  AOI221XL U273 ( .A0(A[10]), .A1(n234), .B0(y1[9]), .B1(n204), .C0(n281), .Y(
        n280) );
  OAI32X1 U274 ( .A0(n282), .A1(n257), .A2(n218), .B0(n219), .B1(n283), .Y(
        n281) );
  AOI211X1 U275 ( .A0(y2[9]), .A1(n205), .B0(n284), .C0(n285), .Y(n279) );
  MXI2X1 U276 ( .A(n228), .B(n224), .S0(n274), .Y(n285) );
  MX3XL U277 ( .A(n229), .B(n240), .C(n286), .S0(n274), .S1(B[9]), .Y(n284) );
  NAND2X1 U278 ( .A(n287), .B(n243), .Y(n286) );
  MXI2X1 U279 ( .A(n244), .B(n229), .S0(n274), .Y(n287) );
  NAND2X1 U280 ( .A(n288), .B(n289), .Y(N251) );
  AOI221XL U281 ( .A0(A[9]), .A1(n234), .B0(y1[8]), .B1(n204), .C0(n290), .Y(
        n289) );
  OAI32X1 U282 ( .A0(n282), .A1(A[0]), .A2(n257), .B0(n219), .B1(n291), .Y(
        n290) );
  NAND2X1 U283 ( .A(A[3]), .B(n292), .Y(n257) );
  AOI211X1 U284 ( .A0(y2[8]), .A1(n205), .B0(n293), .C0(n294), .Y(n288) );
  MXI2X1 U285 ( .A(n228), .B(n224), .S0(n283), .Y(n294) );
  MX3XL U286 ( .A(n229), .B(n240), .C(n295), .S0(n283), .S1(B[8]), .Y(n293) );
  NAND2X1 U287 ( .A(n296), .B(n243), .Y(n295) );
  MXI2X1 U288 ( .A(n244), .B(n229), .S0(n283), .Y(n296) );
  NAND2X1 U289 ( .A(n297), .B(n298), .Y(N250) );
  AOI221XL U290 ( .A0(A[8]), .A1(n234), .B0(y1[7]), .B1(n204), .C0(n299), .Y(
        n298) );
  OAI32X1 U291 ( .A0(n300), .A1(n218), .A2(n216), .B0(n219), .B1(n301), .Y(
        n299) );
  AOI211X1 U292 ( .A0(y2[7]), .A1(n205), .B0(n302), .C0(n303), .Y(n297) );
  MXI2X1 U293 ( .A(n228), .B(n224), .S0(n291), .Y(n303) );
  MX3XL U294 ( .A(n229), .B(n240), .C(n304), .S0(n291), .S1(B[7]), .Y(n302) );
  NAND2X1 U295 ( .A(n305), .B(n243), .Y(n304) );
  MXI2X1 U296 ( .A(n244), .B(n229), .S0(n291), .Y(n305) );
  NAND2X1 U297 ( .A(n306), .B(n307), .Y(N249) );
  AOI221XL U298 ( .A0(A[7]), .A1(n234), .B0(y1[6]), .B1(n204), .C0(n308), .Y(
        n307) );
  OAI22XL U299 ( .A0(n219), .A1(n309), .B0(n237), .B1(n300), .Y(n308) );
  AOI211X1 U300 ( .A0(y2[6]), .A1(n205), .B0(n310), .C0(n311), .Y(n306) );
  MXI2X1 U301 ( .A(n228), .B(n224), .S0(n301), .Y(n311) );
  MX3XL U302 ( .A(n229), .B(n240), .C(n312), .S0(n301), .S1(B[6]), .Y(n310) );
  NAND2X1 U303 ( .A(n313), .B(n243), .Y(n312) );
  MXI2X1 U304 ( .A(n244), .B(n229), .S0(n301), .Y(n313) );
  NAND2X1 U305 ( .A(n314), .B(n315), .Y(N248) );
  AOI221XL U306 ( .A0(A[6]), .A1(n234), .B0(y1[5]), .B1(n204), .C0(n316), .Y(
        n315) );
  OAI32X1 U307 ( .A0(n300), .A1(A[1]), .A2(n218), .B0(n219), .B1(n317), .Y(
        n316) );
  AOI211X1 U308 ( .A0(y2[5]), .A1(n205), .B0(n318), .C0(n319), .Y(n314) );
  MXI2X1 U309 ( .A(n228), .B(n224), .S0(n309), .Y(n319) );
  MX3XL U310 ( .A(n229), .B(n240), .C(n320), .S0(n309), .S1(B[5]), .Y(n318) );
  NAND2X1 U311 ( .A(n321), .B(n243), .Y(n320) );
  MXI2X1 U312 ( .A(n244), .B(n229), .S0(n309), .Y(n321) );
  NAND2X1 U313 ( .A(n322), .B(n323), .Y(N247) );
  AOI221XL U314 ( .A0(A[5]), .A1(n234), .B0(y1[4]), .B1(n204), .C0(n324), .Y(
        n323) );
  OAI32X1 U315 ( .A0(n300), .A1(A[1]), .A2(A[0]), .B0(n325), .B1(n219), .Y(
        n324) );
  CLKINVX1 U316 ( .A(n326), .Y(n219) );
  OR2X1 U317 ( .A(n327), .B(n328), .Y(n300) );
  AOI211X1 U318 ( .A0(y2[4]), .A1(n205), .B0(n329), .C0(n330), .Y(n322) );
  MXI2X1 U319 ( .A(n228), .B(n224), .S0(n317), .Y(n330) );
  MX3XL U320 ( .A(n229), .B(n240), .C(n331), .S0(n317), .S1(B[4]), .Y(n329) );
  NAND2X1 U321 ( .A(n332), .B(n243), .Y(n331) );
  MXI2X1 U322 ( .A(n244), .B(n229), .S0(n317), .Y(n332) );
  NAND3X1 U323 ( .A(n333), .B(n334), .C(n335), .Y(N246) );
  AOI221XL U324 ( .A0(n326), .A1(A[2]), .B0(A[4]), .B1(n234), .C0(n336), .Y(
        n335) );
  OAI22XL U325 ( .A0(N33), .A1(n243), .B0(n337), .B1(n338), .Y(n336) );
  MXI2X1 U326 ( .A(n339), .B(n340), .S0(n325), .Y(n334) );
  OAI211X1 U327 ( .A0(n265), .A1(n341), .B0(n224), .C0(n342), .Y(n340) );
  MXI2X1 U328 ( .A(n229), .B(n240), .S0(N33), .Y(n342) );
  NAND2X1 U329 ( .A(A[0]), .B(n292), .Y(n341) );
  NAND2X1 U330 ( .A(n343), .B(n228), .Y(n339) );
  MXI2X1 U331 ( .A(n244), .B(n229), .S0(N33), .Y(n343) );
  AOI22X1 U332 ( .A0(y1[3]), .A1(n204), .B0(y2[3]), .B1(n205), .Y(n333) );
  NAND3X1 U333 ( .A(n344), .B(n345), .C(n346), .Y(N245) );
  AOI211X1 U334 ( .A0(n326), .A1(A[1]), .B0(n347), .C0(n348), .Y(n346) );
  AOI31X1 U335 ( .A0(n349), .A1(n350), .A2(n351), .B0(n338), .Y(n348) );
  NAND3BX1 U336 ( .AN(n352), .B(A[4]), .C(n353), .Y(n350) );
  OAI31XL U337 ( .A0(A[5]), .A1(A[7]), .A2(A[6]), .B0(n337), .Y(n349) );
  OAI22XL U338 ( .A0(N34), .A1(n243), .B0(n325), .B1(n227), .Y(n347) );
  MXI2X1 U339 ( .A(n354), .B(n355), .S0(n328), .Y(n345) );
  OAI211X1 U340 ( .A0(n237), .A1(n327), .B0(n224), .C0(n356), .Y(n355) );
  MXI2X1 U341 ( .A(n229), .B(n240), .S0(N34), .Y(n356) );
  NAND2X1 U342 ( .A(A[1]), .B(n218), .Y(n237) );
  NAND2X1 U343 ( .A(n357), .B(n228), .Y(n354) );
  MXI2X1 U344 ( .A(n244), .B(n229), .S0(N34), .Y(n357) );
  AOI22X1 U345 ( .A0(y1[2]), .A1(n204), .B0(y2[2]), .B1(n205), .Y(n344) );
  NAND4X1 U346 ( .A(n358), .B(n359), .C(n360), .D(n361), .Y(N244) );
  AOI211X1 U347 ( .A0(y2[1]), .A1(n205), .B0(n362), .C0(n363), .Y(n361) );
  MXI2X1 U348 ( .A(n228), .B(n224), .S0(n216), .Y(n363) );
  MX3XL U349 ( .A(n229), .B(n240), .C(n364), .S0(n216), .S1(B[1]), .Y(n362) );
  NAND2X1 U350 ( .A(n365), .B(n243), .Y(n364) );
  CLKINVX1 U351 ( .A(n214), .Y(n243) );
  MXI2X1 U352 ( .A(n244), .B(n229), .S0(n216), .Y(n365) );
  AOI22X1 U353 ( .A0(y1[1]), .A1(n204), .B0(A[2]), .B1(n234), .Y(n360) );
  OAI21XL U354 ( .A0(n366), .A1(n326), .B0(A[0]), .Y(n359) );
  NOR3X1 U355 ( .A(Mode[2]), .B(Mode[3]), .C(Mode[1]), .Y(n326) );
  OAI31XL U356 ( .A0(n367), .A1(A[14]), .A2(n368), .B0(n369), .Y(n358) );
  CLKINVX1 U357 ( .A(n338), .Y(n369) );
  AOI211X1 U358 ( .A0(n266), .A1(n370), .B0(A[13]), .C0(A[12]), .Y(n368) );
  NAND3X1 U359 ( .A(A[2]), .B(n317), .C(n353), .Y(n370) );
  AO21X1 U360 ( .A0(A[6]), .A1(n337), .B0(n371), .Y(n367) );
  NAND4BX1 U361 ( .AN(n372), .B(n373), .C(n374), .D(n375), .Y(N243) );
  AOI221XL U362 ( .A0(y1[0]), .A1(n204), .B0(y2[0]), .B1(n205), .C0(n376), .Y(
        n375) );
  MXI2X1 U363 ( .A(n377), .B(n378), .S0(n218), .Y(n376) );
  CLKINVX1 U364 ( .A(A[0]), .Y(n218) );
  AOI211X1 U365 ( .A0(n240), .A1(N36), .B0(n366), .C0(n379), .Y(n378) );
  CLKINVX1 U366 ( .A(n224), .Y(n379) );
  NAND2X1 U367 ( .A(n380), .B(n226), .Y(n224) );
  NOR2X1 U368 ( .A(n327), .B(n282), .Y(n366) );
  NAND2X1 U369 ( .A(n216), .B(n328), .Y(n282) );
  NAND2X1 U370 ( .A(n292), .B(n325), .Y(n327) );
  NOR4X1 U371 ( .A(n381), .B(n382), .C(Mode[0]), .D(Mode[1]), .Y(n292) );
  OA21XL U372 ( .A0(B[0]), .A1(n383), .B0(n228), .Y(n377) );
  CLKINVX1 U373 ( .A(n209), .Y(n205) );
  NAND3X1 U374 ( .A(n384), .B(n381), .C(n385), .Y(n209) );
  NOR4X1 U375 ( .A(n382), .B(Mode[0]), .C(Mode[1]), .D(Mode[3]), .Y(n204) );
  OAI21XL U376 ( .A0(n214), .A1(n386), .B0(B[0]), .Y(n374) );
  CLKMX2X2 U377 ( .A(n229), .B(n244), .S0(A[0]), .Y(n386) );
  NAND2BX1 U378 ( .AN(n230), .B(n225), .Y(n244) );
  NOR2X1 U379 ( .A(n223), .B(Mode[0]), .Y(n230) );
  CLKINVX1 U380 ( .A(n240), .Y(n223) );
  NOR3X1 U381 ( .A(n381), .B(Mode[2]), .C(n384), .Y(n240) );
  CLKINVX1 U382 ( .A(n383), .Y(n229) );
  NAND2X1 U383 ( .A(n380), .B(Mode[0]), .Y(n383) );
  NOR3X1 U384 ( .A(Mode[1]), .B(Mode[2]), .C(n381), .Y(n380) );
  OAI21XL U385 ( .A0(n381), .A1(n225), .B0(n228), .Y(n214) );
  NAND3X1 U386 ( .A(n385), .B(n381), .C(Mode[1]), .Y(n228) );
  NAND3X1 U387 ( .A(Mode[2]), .B(n226), .C(Mode[1]), .Y(n225) );
  CLKINVX1 U388 ( .A(Mode[3]), .Y(n381) );
  NAND4X1 U389 ( .A(Mode[3]), .B(n385), .C(n387), .D(n384), .Y(n373) );
  AO22X1 U390 ( .A0(N21), .A1(A[15]), .B0(n231), .B1(n388), .Y(n387) );
  OAI21XL U391 ( .A0(A[14]), .A1(N22), .B0(n389), .Y(n388) );
  OAI221XL U392 ( .A0(B[13]), .A1(n236), .B0(B[14]), .B1(n220), .C0(n390), .Y(
        n389) );
  OAI221XL U393 ( .A0(A[12]), .A1(N24), .B0(A[13]), .B1(N23), .C0(n391), .Y(
        n390) );
  OAI221XL U394 ( .A0(B[11]), .A1(n256), .B0(B[12]), .B1(n248), .C0(n392), .Y(
        n391) );
  OAI221XL U395 ( .A0(A[10]), .A1(N26), .B0(A[11]), .B1(N25), .C0(n393), .Y(
        n392) );
  OAI221XL U396 ( .A0(B[10]), .A1(n266), .B0(B[9]), .B1(n274), .C0(n394), .Y(
        n393) );
  OAI221XL U397 ( .A0(A[8]), .A1(N28), .B0(A[9]), .B1(N27), .C0(n395), .Y(n394) );
  OAI221XL U398 ( .A0(B[7]), .A1(n291), .B0(B[8]), .B1(n283), .C0(n396), .Y(
        n395) );
  OAI221XL U399 ( .A0(A[6]), .A1(N30), .B0(A[7]), .B1(N29), .C0(n397), .Y(n396) );
  OAI221XL U400 ( .A0(B[5]), .A1(n309), .B0(B[6]), .B1(n301), .C0(n398), .Y(
        n397) );
  OAI221XL U401 ( .A0(A[4]), .A1(N32), .B0(A[5]), .B1(N31), .C0(n399), .Y(n398) );
  OAI221XL U402 ( .A0(B[3]), .A1(n325), .B0(B[4]), .B1(n317), .C0(n400), .Y(
        n399) );
  OAI221XL U403 ( .A0(A[2]), .A1(N34), .B0(A[3]), .B1(N33), .C0(n401), .Y(n400) );
  OAI221XL U404 ( .A0(n402), .A1(n216), .B0(B[2]), .B1(n328), .C0(n403), .Y(
        n401) );
  OAI2BB1X1 U405 ( .A0N(n216), .A1N(n402), .B0(N35), .Y(n403) );
  CLKINVX1 U406 ( .A(B[1]), .Y(N35) );
  NOR2X1 U407 ( .A(N36), .B(A[0]), .Y(n402) );
  CLKINVX1 U408 ( .A(B[0]), .Y(N36) );
  CLKINVX1 U409 ( .A(B[3]), .Y(N33) );
  CLKINVX1 U410 ( .A(B[2]), .Y(N34) );
  CLKINVX1 U411 ( .A(B[5]), .Y(N31) );
  CLKINVX1 U412 ( .A(B[4]), .Y(N32) );
  CLKINVX1 U413 ( .A(A[6]), .Y(n301) );
  CLKINVX1 U414 ( .A(B[7]), .Y(N29) );
  CLKINVX1 U415 ( .A(B[6]), .Y(N30) );
  CLKINVX1 U416 ( .A(A[8]), .Y(n283) );
  CLKINVX1 U417 ( .A(A[7]), .Y(n291) );
  CLKINVX1 U418 ( .A(B[9]), .Y(N27) );
  CLKINVX1 U419 ( .A(B[8]), .Y(N28) );
  CLKINVX1 U420 ( .A(B[11]), .Y(N25) );
  CLKINVX1 U421 ( .A(B[10]), .Y(N26) );
  XNOR2X1 U422 ( .A(n203), .B(N21), .Y(n231) );
  OAI22XL U423 ( .A0(n216), .A1(n227), .B0(n404), .B1(n338), .Y(n372) );
  NAND3X1 U424 ( .A(Mode[3]), .B(n385), .C(Mode[1]), .Y(n338) );
  NOR2X1 U425 ( .A(n226), .B(n382), .Y(n385) );
  CLKINVX1 U426 ( .A(Mode[2]), .Y(n382) );
  CLKINVX1 U427 ( .A(Mode[0]), .Y(n226) );
  AOI211X1 U428 ( .A0(n405), .A1(n220), .B0(n406), .C0(n371), .Y(n404) );
  OAI211X1 U429 ( .A0(n256), .A1(n407), .B0(n408), .C0(n203), .Y(n371) );
  CLKINVX1 U430 ( .A(A[15]), .Y(n203) );
  OAI21XL U431 ( .A0(n409), .A1(A[7]), .B0(n337), .Y(n408) );
  NOR4X1 U432 ( .A(A[6]), .B(A[5]), .C(A[4]), .D(n325), .Y(n409) );
  CLKINVX1 U433 ( .A(A[3]), .Y(n325) );
  OAI33X1 U434 ( .A0(n410), .A1(A[6]), .A2(n309), .B0(n407), .B1(n274), .B2(
        n352), .Y(n406) );
  CLKINVX1 U435 ( .A(A[9]), .Y(n274) );
  CLKINVX1 U436 ( .A(A[5]), .Y(n309) );
  CLKINVX1 U437 ( .A(n337), .Y(n410) );
  NOR4X1 U438 ( .A(n407), .B(n352), .C(A[8]), .D(A[9]), .Y(n337) );
  CLKINVX1 U439 ( .A(n351), .Y(n407) );
  NOR4X1 U440 ( .A(A[12]), .B(A[13]), .C(A[14]), .D(A[15]), .Y(n351) );
  CLKINVX1 U441 ( .A(A[14]), .Y(n220) );
  OAI31XL U442 ( .A0(n411), .A1(n352), .A2(n412), .B0(n236), .Y(n405) );
  CLKINVX1 U443 ( .A(A[13]), .Y(n236) );
  CLKINVX1 U444 ( .A(n353), .Y(n412) );
  NOR4X1 U445 ( .A(A[5]), .B(A[6]), .C(A[8]), .D(A[9]), .Y(n353) );
  NAND2X1 U446 ( .A(n266), .B(n256), .Y(n352) );
  CLKINVX1 U447 ( .A(A[11]), .Y(n256) );
  CLKINVX1 U448 ( .A(A[10]), .Y(n266) );
  NAND3BX1 U449 ( .AN(n265), .B(n248), .C(n317), .Y(n411) );
  CLKINVX1 U450 ( .A(A[4]), .Y(n317) );
  CLKINVX1 U451 ( .A(A[12]), .Y(n248) );
  NAND2X1 U452 ( .A(A[1]), .B(n328), .Y(n265) );
  CLKINVX1 U453 ( .A(A[2]), .Y(n328) );
  CLKINVX1 U454 ( .A(n234), .Y(n227) );
  NOR3X1 U455 ( .A(Mode[2]), .B(Mode[3]), .C(n384), .Y(n234) );
  CLKINVX1 U456 ( .A(Mode[1]), .Y(n384) );
  CLKINVX1 U457 ( .A(A[1]), .Y(n216) );
  CLKINVX1 U458 ( .A(B[12]), .Y(N24) );
  CLKINVX1 U459 ( .A(B[13]), .Y(N23) );
  CLKINVX1 U460 ( .A(B[14]), .Y(N22) );
  CLKINVX1 U461 ( .A(B[15]), .Y(N21) );
endmodule

