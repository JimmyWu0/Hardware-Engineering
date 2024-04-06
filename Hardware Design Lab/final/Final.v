`timescale 1ns / 1ps

module Final(
    input clk,				
    input rst,	
    input MISO1,
    input MISO2,
    input MISO3,
    input MISO4,					
    input [2:0] sw,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    output wire SS1,					
    output wire MOSI1,				
    output wire SCLK1,
    output wire SS2,					
    output wire MOSI2,				
    output wire SCLK2,
    output wire SS3,					
    output wire MOSI3,				
    output wire SCLK3,
    output wire SS4,					
    output wire MOSI4,				
    output wire SCLK4,			
    output reg [15:0] led,			
    output wire [3:0] anode,			
    output wire [6:0] sevenseg,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue,
    output hsync,
    output vsync						
    );
    
    wire [3:0] P1mode, P1dir;
    wire [3:0] P2mode, P2dir;
	wire P1pressed, P2pressed;
    
    Top P1move(
        .CLK(clk),				
        .RST(rst),					
        .MISO(MISO1),				
        .SW(sw),			
        .SS(SS1),					
        .MOSI(MOSI1),				
        .SCLK(SCLK1),				
        .mode(P1mode)		
    );
    
    Top P1shoot(
        .CLK(clk),				
        .RST(rst),					
        .MISO(MISO2),				
        .SW(sw),			
        .SS(SS2),					
        .MOSI(MOSI2),				
        .SCLK(SCLK2),				
        .mode(P1dir),
		.pressed(P1pressed)		
    );
    
    Top P2move(
        .CLK(clk),				
        .RST(rst),					
        .MISO(MISO3),				
        .SW(sw),			
        .SS(SS3),					
        .MOSI(MOSI3),				
        .SCLK(SCLK3),				
        .mode(P2mode)		
    );
    
    Top P2shoot(
        .CLK(clk),				
        .RST(rst),					
        .MISO(MISO4),				
        .SW(sw),			
        .SS(SS4),					
        .MOSI(MOSI4),				
        .SCLK(SCLK4),				
        .mode(P2dir),
		.pressed(P2pressed)		
    );
    
    SevenSegment seven_seg (
		.display(sevenseg),
		.digit(anode),
		.nums({P1mode, P1dir, P2mode, P2dir}),
		.rst(rst),
		.clk(clk)
	);
	
//	Display vga(
//    .clk(clk),
//    .rst(rst),
//    .PS2_DATA(PS2_DATA),
//    .PS2_CLK(PS2_CLK),
//    .hint(),
//    .vgaRed(vgaRed),
//    .vgaGreen(vgaGreen),
//    .vgaBlue(vgaBlue),
//    .hsync(hsync),
//    .vsync(vsync),
//    .pass
//    );
	always @(*) begin
		case({P1pressed, P2pressed})
		2'b00 : led[1:0] = 2'b00;
		2'b01 : led[1:0] = 2'b01;
		2'b10 : led[1:0] = 2'b10;
		2'b11 : led[1:0] = 2'b11;
		default : led[1:0] = 2'b00;
		endcase
	end
    
endmodule

module SevenSegment(
	output reg [6:0] display,
	output reg [3:0] digit,
	input wire [15:0] nums,
	input wire rst,
	input wire clk
    );
    
    reg [15:0] clk_divider;
    reg [3:0] display_num;
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		clk_divider <= 15'b0;
    	end else begin
    		clk_divider <= clk_divider + 15'b1;
    	end
    end
    
    always @ (posedge clk_divider[15], posedge rst) begin
    	if (rst) begin
    		display_num <= 4'b0000;
    		digit <= 4'b1111;
    	end else begin
    		case (digit)
    			4'b1110 : begin
    					display_num <= nums[7:4];
    					digit <= 4'b1101;
    				end
    			4'b1101 : begin
						display_num <= nums[11:8];
						digit <= 4'b1011;
					end
    			4'b1011 : begin
						display_num <= nums[15:12];
						digit <= 4'b0111;
					end
    			4'b0111 : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end
    			default : begin
						display_num <= nums[3:0];
						digit <= 4'b1110;
					end				
    		endcase
    	end
    end
    
    always @ (*) begin
    	case (display_num)
    		0 : display = 7'b1000000;	//0000
			1 : display = 7'b1111001;   //0001                                                
			2 : display = 7'b0100100;   //0010                                                
			3 : display = 7'b0110000;   //0011                                             
			4 : display = 7'b0011001;   //0100                                               
			5 : display = 7'b0010010;   //0101                                               
			6 : display = 7'b0000010;   //0110
			7 : display = 7'b1111000;   //0111
			8 : display = 7'b0000000;   //1000
			9 : display = 7'b0010000;	//1001
			default : display = 7'b1111111;
    	endcase
    end
    
endmodule
