`timescale 1ns / 1ps

module Final(
    input clk,				
    input rst,	
    input MISO1,
    input MISO2,
    input MISO3,
    input MISO4,					
    input [2:0] sw,
    input _mute,            //switch 14
    input _pause,           //switch 15
    input _volUP,           //button up
    input _volDOWN,         //button down
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
    output [15:0] led,			
    output wire [3:0] anode,			
    output wire [6:0] sevenseg,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output audio_mclk, // master clock
    output audio_lrck, // left-right clock
    output audio_sck,  // serial clock
    output audio_sdin // serial audio data input						
    );
    
    //joystick states
    wire [3:0] P1mode, P1dir;
    wire [3:0] P2mode, P2dir;
	wire P1pressed, P2pressed;
    
    //countdown timer
    wire clkSec;
    clock_divider #(.n(27)) clock_22(.clk(clk), .clk_div(clkSec));
    reg [3:0] mins, secs;

    // Keyboard
    parameter SPACE_KEY = 9'b0_0010_1001; //29
    wire [511:0] key_down;
	wire [8:0] last_change;
	wire been_ready;

    //7seg
    reg [15:0] num_in;

    reg [1:0] gameState;
    reg gamePause;
    wire gameEnd;
    assign gameEnd = (mins == 4'd0 && secs == 4'd0) ? 1'b1 : 1'b0;
    wire [2:0] hp1, hp2;

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
		.nums(num_in),
		.rst(rst),
		.clk(clk)
	);
	
//	Display vga(
//        .clk(clk),
//        .rst(rst),
//        .PS2_DATA(PS2_DATA),
//        .PS2_CLK(PS2_CLK),
//        .dir1(P1mode),
//        .dir2(P2mode),
//        .bu1(P1dir),
//        .bu2(P2dir),
//        .hp1(p1hp),
//        .hp2(p2hp),
//        .vgaRed(vgaRed),
//        .vgaGreen(vgaGreen),
//        .vgaBlue(vgaBlue),
//        .hsync(hsync),
//        .vsync(vsync)
//    );

lab6_2 vga(
   .clk(clk),
   .rst(rst),
   .PS2_DATA(PS2_DATA),
   .PS2_CLK(PS2_CLK),
   .hint(hint),
   .dir1(P1mode),
   .dir2(P2mode),
   .bu1(P1dir),
   .bu2(P2dir),
   .gamePause(gamePause),
   .gameState(gameState),
   .hp1(hp1),
   .hp2(hp2),
   .vgaRed(vgaRed),
   .vgaGreen(vgaGreen),
   .vgaBlue(vgaBlue),
   .hsync(hsync),
   .vsync(vsync),
   .pass(pass)
   );

    assign led={3'b111,13'b0}<<(3-hp1) | 3'b111>>(3-hp2); 

    Music music(
        .clk(clk),
        .rst(rst),       
        ._mute(_mute),      
        ._pause(_pause),     
        ._volUP(_volUP),    
        ._volDOWN(_volDOWN),   
        .audio_mclk(audio_mclk), 
        .audio_lrck(audio_lrck), 
        .audio_sck(audio_sck),  
        .audio_sdin(audio_sdin) 
    );

    KeyboardDecoder key_de (
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);	 

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            gameState <= 2'b00;
            gamePause <= 1'b0;
        end        
        else begin
            case(gameState)
                2'b00 : begin
                    if(been_ready && key_down[last_change] == 1'b1 && last_change == SPACE_KEY)
                        gameState <= 2'b01;
                    else
                        gameState <= 2'b00;
                end
                2'b01 : begin
                    if(been_ready && key_down[last_change] == 1'b1 && last_change == SPACE_KEY)
                        gamePause <= ~gamePause;

                    if(gameEnd || hp1==0 || hp2==0) // havent add the hp condition
                        gameState <= 2'b10;
                    else
                        gameState <= 2'b01;
                end
                2'b10 : begin
                    if(been_ready && key_down[last_change] == 1'b1 && last_change == SPACE_KEY)
                        gameState <= 2'b00;
                    else
                        gameState <= 2'b10;
                end
                default : gameState <= gameState;
            endcase
            
        end
    end

    always @(posedge clkSec or posedge rst) begin
        if(rst) begin
            mins <= 4'd5;
            secs <= 4'd9;
        end else begin
            case(gameState)
            2'b00: begin
                mins <= 4'd5;
                secs <= 4'd9;
            end
            2'b01: begin
                if(gamePause) begin
                    mins <= mins;
                    secs <= secs;
                end else begin
                    if(secs > 0) begin
                        secs <= secs - 1'b1;
                    end
                    else begin
                        if(mins > 0) begin
                            mins <= mins - 1'b1;
                            secs <= 4'd9;
                        end
                        else begin
                            secs <= 1'b0;
                            mins <= 1'b0;
                        end
                    end 
                end
            end
            2'b10: begin
                mins <= 4'd5;
                secs <= 4'd9;
            end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            num_in <= {8'd0, 4'd6, 4'd0};
        end
        else begin
            case(gameState)
            2'b00: begin
                num_in <= {8'd0, 4'd6, 4'd0};
            end
            2'b01: begin
                if(gamePause) num_in <= {4'hD ,num_in[11:0]};
                else num_in <= {8'hEE, mins, secs};
            end
            2'b10: begin
                num_in <= {4'hF, 4'hA, 4'hB, 4'hC};
            end
            endcase
        end
    end

	//  always @(*) begin
	//  	case({p1hp, p2hp})
    //          2'b00 : led[1:0] = 2'b00;
    //          2'b01 : led[1:0] = 2'b01;
    //          2'b10 : led[1:0] = 2'b10;
    //          2'b11 : led[1:0] = 2'b11;
	//  	default : led[1:0] = 2'b00;
	//  	endcase
	//  end
    
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
            10 : display = 7'b0000110;   //E
            11 : display = 7'b0101011;   //n
            12 : display = 7'b0100001;   //d
            13 : display = 7'b0001100;   //P
            14 : display = 7'b0111111;   //-
			default : display = 7'b1111111;
    	endcase
    end
    
endmodule

module KeyboardDecoder(
	output reg [63:0] key_down,
	output wire [8:0] last_change,
	output reg key_valid,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk
    );
    
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
	parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
    reg [9:0] key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [511:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_0 inst (
		.key_in(key_in),
		.is_extend(is_extend),
		.is_break(is_break),
		.valid(valid),
		.err(err),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(rst),
		.clk(clk)
	);
	
	one_pulse op (
		.pb_out(pulse_been_ready),
		.pb_in(been_ready),
		.clk(clk)
	);
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		state <= INIT;
    		been_ready  <= 1'b0;
    		been_extend <= 1'b0;
    		been_break  <= 1'b0;
    		key <= 10'b0_0_0000_0000;
    	end else begin
    		state <= state;
			been_ready  <= been_ready;
			been_extend <= (is_extend) ? 1'b1 : been_extend;
			been_break  <= (is_break ) ? 1'b1 : been_break;
			key <= key;
    		case (state)
    			INIT : begin
    					if (key_in == IS_INIT) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready  <= 1'b0;
							been_extend <= 1'b0;
							been_break  <= 1'b0;
							key <= 10'b0_0_0000_0000;
    					end else begin
    						state <= INIT;
    					end
    				end
    			WAIT_FOR_SIGNAL : begin
    					if (valid == 0) begin
    						state <= WAIT_FOR_SIGNAL;
    						been_ready <= 1'b0;
    					end else begin
    						state <= GET_SIGNAL_DOWN;
    					end
    				end
    			GET_SIGNAL_DOWN : begin
						state <= WAIT_RELEASE;
						key <= {been_extend, been_break, key_in};
						been_ready  <= 1'b1;
    				end
    			WAIT_RELEASE : begin
    					if (valid == 1) begin
    						state <= WAIT_RELEASE;
    					end else begin
    						state <= WAIT_FOR_SIGNAL;
    						been_extend <= 1'b0;
    						been_break  <= 1'b0;
    					end
    				end
    			default : begin
    					state <= INIT;
						been_ready  <= 1'b0;
						been_extend <= 1'b0;
						been_break  <= 1'b0;
						key <= 10'b0_0_0000_0000;
    				end
    		endcase
    	end
    end
    
    always @ (posedge clk, posedge rst) begin
    	if (rst) begin
    		key_valid <= 1'b0;
    		key_down <= 511'b0;
    	end else if (key_decode[last_change] && pulse_been_ready) begin
    		key_valid <= 1'b1;
    		if (key[8] == 0) begin
    			key_down <= key_down | key_decode;
    		end else begin
    			key_down <= key_down & (~key_decode);
    		end
    	end else begin
    		key_valid <= 1'b0;
			key_down <= key_down;
    	end
    end

endmodule
