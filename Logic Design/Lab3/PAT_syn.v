/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : R-2020.09
// Date      : Wed Jun  1 04:00:46 2022
/////////////////////////////////////////////////////////////


module PAT ( clk, reset, data, flag );
  input clk, reset, data;
  output flag;
  wire   N24, N25, N26, N27, N28, N55, N56, N57, N58, n1, n2, n3, n4, n5, n6,
         n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20,
         n21, n22, n23, n24, n25, n26, n27, n28, n29, n30;
  wire   [3:0] state;

  TLATX1 \next_state_reg[1]  ( .G(N24), .D(N26), .QN(n29) );
  TLATX1 \next_state_reg[2]  ( .G(N24), .D(N27), .QN(n28) );
  TLATX1 \next_state_reg[3]  ( .G(N24), .D(N28), .QN(n27) );
  TLATX1 \next_state_reg[0]  ( .G(N24), .D(N25), .QN(n30) );
  DFFQX1 \state_reg[3]  ( .D(N58), .CK(clk), .Q(state[3]) );
  DFFQX1 \state_reg[2]  ( .D(N57), .CK(clk), .Q(state[2]) );
  DFFQX1 \state_reg[1]  ( .D(N56), .CK(clk), .Q(state[1]) );
  DFFQX1 \state_reg[0]  ( .D(N55), .CK(clk), .Q(state[0]) );
  CLKINVX1 U39 ( .A(reset), .Y(n5) );
  NAND3X1 U40 ( .A(n5), .B(n4), .C(n24), .Y(n8) );
  NAND4X1 U41 ( .A(n22), .B(n20), .C(n13), .D(n5), .Y(N24) );
  OAI21XL U42 ( .A0(n8), .A1(n6), .B0(n9), .Y(N28) );
  NAND3X1 U43 ( .A(n5), .B(n4), .C(n25), .Y(n10) );
  AND4X1 U44 ( .A(n26), .B(n15), .C(n10), .D(n14), .Y(n22) );
  NAND3X1 U45 ( .A(n4), .B(n2), .C(n5), .Y(n26) );
  AND3X2 U46 ( .A(n9), .B(n23), .C(n11), .Y(n20) );
  NOR2X1 U47 ( .A(n2), .B(state[3]), .Y(n25) );
  NAND3X1 U48 ( .A(state[0]), .B(n5), .C(n24), .Y(n13) );
  NOR2X1 U49 ( .A(state[3]), .B(state[2]), .Y(n18) );
  NAND4X1 U50 ( .A(state[0]), .B(n25), .C(n5), .D(n3), .Y(n15) );
  NAND4X1 U51 ( .A(n25), .B(state[1]), .C(n5), .D(n4), .Y(n11) );
  NAND4X1 U52 ( .A(state[0]), .B(n25), .C(state[1]), .D(n5), .Y(n9) );
  NOR4X1 U53 ( .A(n7), .B(reset), .C(state[2]), .D(state[0]), .Y(flag) );
  NAND2X1 U54 ( .A(state[3]), .B(state[1]), .Y(n7) );
  NAND4X1 U55 ( .A(n18), .B(state[0]), .C(n5), .D(n3), .Y(n23) );
  NAND4X1 U56 ( .A(n18), .B(state[0]), .C(state[1]), .D(n5), .Y(n14) );
  CLKINVX1 U57 ( .A(state[0]), .Y(n4) );
  CLKINVX1 U58 ( .A(state[1]), .Y(n3) );
  NAND4X1 U59 ( .A(n11), .B(n8), .C(n13), .D(n21), .Y(N25) );
  OA22X1 U60 ( .A0(n22), .A1(data), .B0(data), .B1(n23), .Y(n21) );
  AND3X2 U61 ( .A(state[3]), .B(n3), .C(n2), .Y(n24) );
  CLKINVX1 U62 ( .A(state[2]), .Y(n2) );
  NOR2X1 U63 ( .A(n27), .B(reset), .Y(N58) );
  NOR2X1 U64 ( .A(n28), .B(reset), .Y(N57) );
  NOR2X1 U65 ( .A(n29), .B(reset), .Y(N56) );
  NOR2X1 U66 ( .A(n30), .B(reset), .Y(N55) );
  OAI211X1 U67 ( .A0(data), .A1(n10), .B0(n1), .C0(n11), .Y(N27) );
  CLKINVX1 U68 ( .A(n12), .Y(n1) );
  AOI31X1 U69 ( .A0(n13), .A1(n14), .A2(n15), .B0(n6), .Y(n12) );
  OAI211X1 U70 ( .A0(n16), .A1(n6), .B0(n13), .C0(n17), .Y(N26) );
  AND2X2 U71 ( .A(n15), .B(n20), .Y(n16) );
  NAND4X1 U72 ( .A(n18), .B(state[1]), .C(n19), .D(n6), .Y(n17) );
  NOR2X1 U73 ( .A(state[0]), .B(reset), .Y(n19) );
  CLKINVX1 U74 ( .A(data), .Y(n6) );
endmodule

