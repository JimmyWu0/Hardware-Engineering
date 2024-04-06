module clock_divider(clk,clk_div);
    input clk;
    output clk_div;
    parameter n = 500000;  //1000000 clk time period == 1 clk_div time period
    reg[29:0]num;
    reg tick=1'b1;
    always @(posedge clk) begin
        if (num == n-1) begin
            num <= 30'b0;
            tick <= ~tick;
        end else begin
            num <= num + 1'b1;
            tick <= tick;
        end
    end

    assign clk_div = tick;

endmodule

module Lab5(
	output wire [6:0] display,
	output wire [3:0] digit,
	output reg [15:0] LED,
	inout wire PS2_DATA,
	inout wire PS2_CLK,
	input wire rst,
	input wire clk,
	input wire btnL,
	input wire btnR
	);

reg [2:0] state, next_state;
reg [15:0] next_LED;
reg [19:0] cnt, next_cnt;
reg [3:0] noi, next_noi;  //# of items
reg [7:0] price, next_price;  //price of product
reg [7:0] pay, next_pay;  //the money that customer pays
reg [7:0] price10, pay10;  //price and pay in base 10
reg [3:0] bought;  //# of items bought
reg [7:0] paid, paid10, back10;  //# of money actually paid, # of money actually paid in base 10, # of change in base 10
reg [3:0] paid1, paid0, back1, back0;  //second 4-digit, first 4-digit  {----,----}

reg [15:0] nums, next_nums;  //value to display on 7-seg
reg [3:0] key_num;  //current input single key
reg [9:0] last_key;

wire [511:0] key_down;
wire [8:0] last_change;
wire key_valid;  //been_ready

parameter IDLE = 3'd0;
parameter SET = 3'd1;
parameter PAYMENT = 3'd2;
parameter BUY = 3'd3;
parameter CHANGE = 3'd4;

parameter [8:0] SPACE_CODES = 9'b0_0010_1001;  //29
parameter [8:0] ENTER_CODES = 9'b0_0101_1010;  //5A
parameter [8:0] KEY_CODES [0:19] = {
	9'b0_0100_0101,	// 0 => 45
	9'b0_0001_0110,	// 1 => 16
	9'b0_0001_1110,	// 2 => 1E
	9'b0_0010_0110,	// 3 => 26
	9'b0_0010_0101,	// 4 => 25
	9'b0_0010_1110,	// 5 => 2E
	9'b0_0011_0110,	// 6 => 36
	9'b0_0011_1101,	// 7 => 3D
	9'b0_0011_1110,	// 8 => 3E
	9'b0_0100_0110,	// 9 => 46
		
	9'b0_0111_0000, // right_0 => 70
	9'b0_0110_1001, // right_1 => 69
	9'b0_0111_0010, // right_2 => 72
	9'b0_0111_1010, // right_3 => 7A
	9'b0_0110_1011, // right_4 => 6B
	9'b0_0111_0011, // right_5 => 73
	9'b0_0111_0100, // right_6 => 74
	9'b0_0110_1100, // right_7 => 6C
	9'b0_0111_0101, // right_8 => 75
	9'b0_0111_1101  // right_9 => 7D
};

clock_divider div1(.clk(clk),.clk_div(clk_div1));  //0.01 sec
clock_divider #(20000) div2(.clk(clk),.clk_div(clk_div2));  //not used

wire rst_de, btnL_de, btnR_de;
debounce rst_db(.clk(clk),.pb(rst),.pb_debounced(rst_de));
debounce btnL_db(.clk(clk),.pb(btnL),.pb_debounced(btnL_de));
debounce btnR_db(.clk(clk),.pb(btnR),.pb_debounced(btnR_de));

wire rst_one, btnL_one, btnR_one;
one_pulse rst_1p(.clk(clk_div1),.pb_in(rst_de),.pb_out(rst_one));
one_pulse btnL_1p(.clk(clk_div1),.pb_in(btnL_de),.pb_out(btnL_one));
one_pulse btnR_1p(.clk(clk_div1),.pb_in(btnR_de),.pb_out(btnR_one));

SevenSegment seven_seg (
	.display(display),
	.digit(digit),
	.nums(nums),
	.rst(rst),
	.clk(clk)
);
		
KeyboardDecoder key_de (
	.key_down(key_down),
	.last_change(last_change),
	.key_valid(key_valid),
	.PS2_DATA(PS2_DATA),
	.PS2_CLK(PS2_CLK),
	.rst(rst),
	.clk(clk)
);

always@(posedge clk_div1 or posedge rst) begin
	if(rst) begin
		state<=IDLE;
		nums<=16'b1010101010101010;  //"----"
		LED<=16'b0;
		cnt<=20'd0;
		noi<=4'd9;
		price<=8'd10;
		pay<=8'd0;
	end else begin
		state<=next_state;
		nums<=next_nums;
		LED<=next_LED;
		cnt<=next_cnt;
		noi<=next_noi;
		price<=next_price;
		pay<=next_pay;
	end
end

always@(*) begin
	next_state=state;
	next_nums=nums;
	next_LED=LED;
	next_cnt=cnt;
	next_noi=noi;
	next_price=price;
	next_pay=pay;

	case(state)
	IDLE: begin
		next_state=IDLE;
		next_nums=16'b1010101010101010;  //"----"
		next_LED=16'b0;
		next_cnt=20'd0;  //necessary?
		next_pay=8'd0;

		if(btnL_one) begin
			next_state=SET;
			next_nums={noi,4'b1010,price};
			next_LED=16'b1111111100000000;
		end
		if(btnR_one) begin
			next_state=PAYMENT;
			next_nums=16'b1010101000000000;  //"--00"
			next_LED=16'b0;
		end
	end
	SET: begin
		next_state=SET;
		next_nums={noi,4'b1010,price};
		next_LED=LED;

		if(key_valid && key_down[SPACE_CODES] == 1'b1) begin  //press space key
			next_LED=~LED;
		end
		if(key_valid && key_down[last_change] == 1'b1 && key_num!=4'b1111) begin  //press number key
			if(LED[15]==1'b1) begin  //set noi
				next_noi=key_num;
			end else begin  //set price
				next_price={price[3:0],key_num};
			end
		end
		if(key_valid && key_down[ENTER_CODES] == 1'b1) begin  //press enter key
			next_state=IDLE;
			next_nums=16'b1010101010101010;
			next_LED=16'b0;
		end
	end
	PAYMENT: begin
		next_state=PAYMENT;
		next_nums={8'b10101010,pay};

		if(key_valid && key_down[last_change] == 1'b1 && key_num!=4'b1111) begin  //press number key
			if(key_num==4'b0000) begin  //turn to 0
				next_pay=8'b0;
			end else if(key_num==4'b0001) begin  //+1
				if(pay[7:4]==4'd9 && pay[3:0]==4'd9) begin
					next_pay=pay;
				end else if(pay[3:0]==4'd9) begin
					next_pay={pay[7:4]+1,4'd0};
				end else begin
					next_pay={pay[7:4],pay[3:0]+1};
				end
			end else if(key_num==4'b0010) begin  //+5
				if(pay[7:4]==4'd9 && pay[3:0]>=4'd5) begin
					next_pay=8'b10011001;  //{4'd9,4'd9}
				end else if(pay[3:0]>=4'd5) begin
					next_pay={pay[7:4]+1,pay[3:0]-4'd5};
				end else begin
					next_pay={pay[7:4],pay[3:0]+4'd5};
				end
			end else if(key_num==4'b0011) begin  //+10
				if(pay[7:4]==4'd9) begin
					next_pay=8'b10011001;
				end else begin
					next_pay={pay[7:4]+1,pay[3:0]};
				end
			end else if(key_num==4'b0100) begin  //+50
				if(pay[7:4]>=4'd5) begin
					next_pay=8'b10011001;
				end else begin
					next_pay={pay[7:4]+4'd5,pay[3:0]};
				end
			end else begin  //pressing key other than 0,1,2,3,4 
				next_pay=pay;
			end
		end
		if(key_valid && key_down[ENTER_CODES] == 1'b1) begin  //press enter key
			pay10=10*pay[7:4]+pay[3:0];
			price10=10*price[7:4]+price[3:0];
			bought=pay10/price10;
			back10=pay10%price10;
			paid10=pay10-back10;
			paid1=paid10/10;
			paid0=paid10%10;
			back1=back10/10;
			back0=back0%10;
			if(pay10>=price10) begin
				next_state=BUY;
				next_nums={bought,4'b1010,paid1,paid0};
				next_noi=noi-bought;  //!! might have bug
				next_LED=16'b1111111111111111;
				next_cnt=20'd0;
			end else begin
				next_state=CHANGE;
				next_nums={4'b0,4'b1010,pay};
				next_LED=16'b1111111111111111;
				next_cnt=20'd0;
			end
		end
	end
	BUY: begin
		next_state=BUY;
		next_nums=nums;
		next_LED=LED;
		next_cnt=cnt+1'b1;

		if(cnt==20'd49 || cnt==20'd99 || cnt==20'd149 || cnt==20'd199 || cnt==20'd249) begin
			next_LED=~LED;
		end
		if(cnt==20'd299) begin
			next_state=CHANGE;
			next_nums={bought,4'b1010,back1,back0};
			next_LED=16'b1111111111111111;
			next_cnt=20'd0;
		end
	end
	CHANGE: begin
		next_state=CHANGE;
		next_nums=nums;
		next_LED=LED;
		next_cnt=cnt+1'b1;

		if(cnt==20'd299) begin
			next_state=IDLE;
			next_nums=16'b1010101010101010;
			next_LED=16'b0;
			next_cnt=20'd0;
		end
	end
	endcase
end

always@(*) begin
	case(last_change)
		KEY_CODES[00] : key_num = 4'b0000;
		KEY_CODES[01] : key_num = 4'b0001;
		KEY_CODES[02] : key_num = 4'b0010;
		KEY_CODES[03] : key_num = 4'b0011;
		KEY_CODES[04] : key_num = 4'b0100;
		KEY_CODES[05] : key_num = 4'b0101;
		KEY_CODES[06] : key_num = 4'b0110;
		KEY_CODES[07] : key_num = 4'b0111;
		KEY_CODES[08] : key_num = 4'b1000;
		KEY_CODES[09] : key_num = 4'b1001;
		KEY_CODES[10] : key_num = 4'b0000;
		KEY_CODES[11] : key_num = 4'b0001;
		KEY_CODES[12] : key_num = 4'b0010;
		KEY_CODES[13] : key_num = 4'b0011;
		KEY_CODES[14] : key_num = 4'b0100;
		KEY_CODES[15] : key_num = 4'b0101;
		KEY_CODES[16] : key_num = 4'b0110;
		KEY_CODES[17] : key_num = 4'b0111;
		KEY_CODES[18] : key_num = 4'b1000;
		KEY_CODES[19] : key_num = 4'b1001;
		default		  : key_num = 4'b1111;
	endcase
end

endmodule
