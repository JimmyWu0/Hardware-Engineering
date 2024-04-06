module Encoder (
    input clk, 
    input rst_n, 
    input [3:0] max, 
    input [3:0] min, 
    input in_valid, 
    input [1:0] mode, 
    input [7:0] in_data, 
    output reg [11:0] out_data, 
    output reg [2:0] state, 
    output wire [3:0] counter_out, /* use wire to connect two module*/
    output wire direction
);

reg [2:0] nxt_state;

parameter INIT = 3'd0;
parameter GET_DATA = 3'd1;
parameter ENCRYPT_DATA = 3'd2;
parameter OUTPUT_DATA = 3'd3;

/* using mode signal to process the flip and enable signal */
wire flip, enable;

/* fill in the following blanks (e.g.: a = (b == 2'b01) ? 1'b1 : 1'b0) */
assign flip = ? : ;
assign enable = ? : ;

/* instantiate the Parameterized_Ping_Pong_Counter module */
Parameterized_Ping_Pong_Counter pppc(.clk(clk), .rst_n(rst_n), .enable(enable), .max(max), .min(min), .flip(flip), .direction(direction), .out(counter_out));

/* state transition */

/* counter (this is the offset_cnt in the Practice_2) */

/* data processing  */

/* output data */

endmodule
