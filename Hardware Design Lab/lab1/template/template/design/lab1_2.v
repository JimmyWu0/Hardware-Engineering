`timescale 1ns/100ps
module lab1_2 (
    input wire [3:0] source_0,
    input wire [3:0] source_1,
    input wire [3:0] source_2,
    input wire [3:0] source_3,
    input wire [1:0] op_0,
    input wire [1:0] op_1,
    input wire [1:0] request,
    output reg [3:0] result
); 
    /* Note that result can be either reg or wire. 
    * It depends on how you design your module. */
    // add your design here 
    wire [3:0] result_0,result_1;  //cannot use reg
    lab1_1 la0 (.op(op_0),.a(source_0),.b(source_1),.d(result_0));
    lab1_1 la1 (.op(op_1),.a(source_2),.b(source_3),.d(result_1));
    always @* begin
        result=4'b0000;  //default, i.e. when request==2'b00
        if(request==2'b01) begin
            result=result_0;
        end else if(request==2'b10) begin
            result=result_1;
        end else if(request==2'b11) begin
            if(op_0<=op_1) result=result_0;
            else result=result_1;
        end
    end
endmodule

wire [3:0] result_0,result_1;  //cannot use reg
    lab1_1 la0 (.op(op_0),.a(source_0),.b(source_1),.d(result_0));
    lab1_1 la1 (.op(op_1),.a(source_2),.b(source_3),.d(result_1));
    always @* begin
        result=4'b0;  //default
        if(request[0]==1'b1) begin  //op_0 has a higher priority
            lab1_1 la0 (.op(op_0),.a(source_0),.b(source_1),.d(result));
        end else if(request[1]==1'b1) begin
            lab1_1 la1 (.op(op_1),.a(source_2),.b(source_3),.d(result));
        end
    end