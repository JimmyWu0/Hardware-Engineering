`timescale 1ns/1ps
module Parameterized_Ping_Pong_Counter (
    input clk, 
    input rst_n, 
    input enable, 
    input flip, 
    input [3:0] max, 
    input [3:0] min, 
    output reg direction, 
    output reg [3:0] out
);

// Output signals can be reg or wire
// add your design here

endmodule
