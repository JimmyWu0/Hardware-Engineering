// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
`define front   3'd0
`define left    3'd1
`define right   3'd2
`define stop    3'd3
`define sleft   3'd4
`define sright  3'd5

module motor(
    input clk,
    input rst,
    input [2:0]mode,
    output [1:0]pwm,
    output reg [1:0]r_IN,  //wire -> reg
    output reg [1:0]l_IN  //wire -> reg
);

    reg [9:0] left_motor, right_motor;
    wire left_pwm, right_pwm;

    motor_pwm m0(clk, rst, left_motor, left_pwm);
    motor_pwm m1(clk, rst, right_motor, right_pwm);

    assign pwm = {left_pwm,right_pwm};

    // TODO: trace the rest of motor.v and control the speed and direction of the two motors
    reg [9:0] next_left_motor, next_right_motor;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            left_motor <= 10'd0;
            right_motor <= 10'd0;
        end else begin
            left_motor <= next_left_motor;
            right_motor <= next_right_motor;
        end
    end

    always @* begin
        case(mode)
            `front: begin
                next_left_motor = 730;
                next_right_motor = 730;
                l_IN = 2'b10;
                r_IN = 2'b10;
            end
            `left: begin
                next_left_motor = 600;
                next_right_motor = 730;
                l_IN = 2'b10;
                r_IN = 2'b10;
            end
            `right: begin
                next_left_motor = 730;
                next_right_motor = 600;
                l_IN = 2'b10;
                r_IN = 2'b10;
            end
            `stop: begin
                next_left_motor = 0;
                next_right_motor = 0;
                l_IN = 2'b00;
                r_IN = 2'b00;
            end
            `sleft: begin
                next_left_motor = 600;
                next_right_motor = 600;
                l_IN = 2'b01;
                r_IN = 2'b10;
            end
            `sright: begin
                next_left_motor = 600;
                next_right_motor = 600;
                l_IN = 2'b10;
                r_IN = 2'b01;
            end
        endcase
    end
    

    
endmodule

module motor_pwm (
    input clk,
    input reset,
    input [9:0]duty,
	output pmod_1 //PWM
);
        
    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1)
    );

endmodule

//generte PWM by input frequency & duty cycle
module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);
    wire [31:0] count_max = 100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            count <= count + 1;
            // TODO: set <PWM> accordingly
            if(count<count_duty) PWM<=1;
            else PWM<=0;
        end else begin
            count <= 0;
            PWM <= 0;
        end
    end
endmodule

