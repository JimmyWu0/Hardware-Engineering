`timescale 1ns / 1ps

`define c   32'd262 
`define d   32'd294
`define e   32'd330  
`define f   32'd349
`define g   32'd392   
`define a   32'd440
`define b   32'd494 

`define hc  32'd524   
`define hd  32'd588   
`define he  32'd660   
`define hf  32'd698   
`define hg  32'd784
`define ha  32'd880

`define sil 32'd50000000

module Music(
    input clk,
    input rst,        // BTNC: active high reset
    input _mute,      // SW14: Mute
    input _pause,      // SW15: Mode
    input _volUP,     // BTNU: Vol up
    input _volDOWN,   // BTND: Vol down
    output wire audio_mclk, // master clock
    output wire audio_lrck, // left-right clock
    output wire audio_sck,  // serial clock
    output wire audio_sdin // serial audio data input
    );

    reg [2:0] vol = 3'b011;

    wire opu, opd;
    wire dbu, dbd;
    debounce d2(.pb_debounced(dbu), .pb(_volUP), .clk(clk));
    debounce d3(.pb_debounced(dbd), .pb(_volDOWN), .clk(clk));
    one_pulse o2(.pb_in(dbu), .clk(clk), .pb_out(opu));
    one_pulse o3(.pb_in(dbd), .clk(clk), .pb_out(opd));

    // Internal Signal
    wire [15:0] audio_in_left, audio_in_right;

    wire [11:0] ibeatNum;    // Beat counter
    wire [31:0] freqL, freqR;           // Raw frequency, produced by music module
    wire [21:0] freq_outL, freq_outR;   // Processed frequency, adapted to the clock rate of Basys3

    // clkDiv22
    wire clkDiv22;
    clock_divider #(.n(22)) clock_22(.clk(clk), .clk_div(clkDiv22));    // for audio

    // Player Control
    // [in]  reset, clock, _play, _slow, _music, and _mode
    // [out] beat number
    player_control #(.LEN(512)) playerCtrl_00 ( 
        .clk(clkDiv22),
        .reset(rst),
        ._pause(_pause), 
        .ibeat(ibeatNum)
    );
    
    // Music module
    // [in]  beat number and en
    // [out] left & right raw frequency
    music_example music_00 (
        ._pause(_pause),
        .ibeatNum(ibeatNum),
        .toneL(freqL),
        .toneR(freqR)
    );

    // freq_outL, freq_outR
    // Note gen makes no sound, if freq_out = 50000000 / `silence = 1
    assign freq_outL = (!_mute) ? 50000000 / freqL : 50000000 / `sil;
    assign freq_outR = (!_mute) ? 50000000 / freqR : 50000000 / `sil;

    // Note generation
    // [in]  processed frequency
    // [out] audio wave signal (using square wave here)
    note_gen noteGen_00(
        .clk(clk), 
        .rst(rst), 
        .volume(vol),
        .note_div_left(freq_outL), 
        .note_div_right(freq_outR), 
        .audio_left(audio_in_left),     // left sound audio
        .audio_right(audio_in_right)    // right sound audio
    );

    // Speaker controller
    speaker_control sc(
        .clk(clk), 
        .rst(rst), 
        .audio_in_left(audio_in_left),      // left channel audio data input
        .audio_in_right(audio_in_right),    // right channel audio data input
        .audio_mclk(audio_mclk),            // master clock
        .audio_lrck(audio_lrck),            // left-right clock
        .audio_sck(audio_sck),              // serial clock
        .audio_sdin(audio_sdin)             // serial audio data input
    );

    always @(posedge clk or posedge rst) begin // VOLUME CONTROLLER
	   if(rst) vol <= 3'b011;
	   else begin
	       if(opu && vol < 5) vol <= vol + 1'b1;
	       else if(opd && vol > 1) vol <= vol - 1'b1;
	       else vol <= vol;
	   end
	end

endmodule

module player_control (
	input clk, 
	input reset, 
	input _pause, 
	output reg [11:0] ibeat
);
	parameter LEN = 4095;
    reg [11:0] next_ibeat;

	always @(posedge clk, posedge reset) begin
		if (reset) begin
			ibeat <= 0;
		end else begin
            ibeat <= next_ibeat;
		end
	end

    always @* begin
        if(_pause) 
            next_ibeat = (ibeat + 1 < LEN) ? (ibeat + 1) : 0;//LEN-1;        
        else 
            next_ibeat = ibeat;           
    end

endmodule

module note_gen(
    input clk, // clock from crystal
    input rst, // active high reset
    input [2:0] volume, 
    input [21:0] note_div_left, // div for note generation
    input [21:0] note_div_right,
    output [15:0] audio_left,
    output [15:0] audio_right
    );

    // Declare internal signals
    reg [21:0] clk_cnt_next, clk_cnt;
    reg [21:0] clk_cnt_next_2, clk_cnt_2;
    reg b_clk, b_clk_next;
    reg c_clk, c_clk_next;

    // Note frequency generation
    // clk_cnt, clk_cnt_2, b_clk, c_clk
    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            begin
                clk_cnt <= 22'd0;
                clk_cnt_2 <= 22'd0;
                b_clk <= 1'b0;
                c_clk <= 1'b0;
            end
        else
            begin
                clk_cnt <= clk_cnt_next;
                clk_cnt_2 <= clk_cnt_next_2;
                b_clk <= b_clk_next;
                c_clk <= c_clk_next;
            end
    
    // clk_cnt_next, b_clk_next
    always @*
        if (clk_cnt == note_div_left)
            begin
                clk_cnt_next = 22'd0;
                b_clk_next = ~b_clk;
            end
        else
            begin
                clk_cnt_next = clk_cnt + 1'b1;
                b_clk_next = b_clk;
            end

    // clk_cnt_next_2, c_clk_next
    always @*
        if (clk_cnt_2 == note_div_right)
            begin
                clk_cnt_next_2 = 22'd0;
                c_clk_next = ~c_clk;
            end
        else
            begin
                clk_cnt_next_2 = clk_cnt_2 + 1'b1;
                c_clk_next = c_clk;
            end

    // Assign the amplitude of the note
    // Volume is controlled here

    reg [15:0] vol_val_p, vol_val_n;    

    always @(*) begin
        case(volume)
            3'b001: begin
                vol_val_p = 16'h0400;
                vol_val_n = 16'hFC00;
            end
            3'b010: begin
                vol_val_p = 16'h0800;
                vol_val_n = 16'hF800;
            end
            3'b011: begin
                vol_val_p = 16'h1000;
                vol_val_n = 16'hF000;
            end
            3'b100: begin
                vol_val_p = 16'h2000;
                vol_val_n = 16'hE000;
            end
            3'b101: begin
                vol_val_p = 16'h4000;
                vol_val_n = 16'hC000;
            end
            default: begin
                vol_val_p = 16'h1000;
                vol_val_n = 16'hF000;
            end
        endcase
    end
 
    assign audio_left = (note_div_left == 22'd1) ? 16'h0000 : 
                                (b_clk == 1'b0) ? vol_val_n : vol_val_p;
    assign audio_right = (note_div_right == 22'd1) ? 16'h0000 : 
                                (c_clk == 1'b0) ? vol_val_n : vol_val_p;
endmodule

module speaker_control(
    input clk,  // clock from the crystal
    input rst,  // active high reset
    input [15:0] audio_in_left, // left channel audio data input
    input [15:0] audio_in_right, // right channel audio data input
    output audio_mclk, // master clock
    output audio_lrck, // left-right clock, Word Select clock, or sample rate clock
    output audio_sck, // serial clock
    output reg audio_sdin // serial audio data input
    ); 

    // Declare internal signal nodes 
    wire [8:0] clk_cnt_next;
    reg [8:0] clk_cnt;
    reg [15:0] audio_left, audio_right;

    // Counter for the clock divider
    assign clk_cnt_next = clk_cnt + 1'b1;

    always @(posedge clk or posedge rst)
        if (rst == 1'b1)
            clk_cnt <= 9'd0;
        else
            clk_cnt <= clk_cnt_next;

    // Assign divided clock output
    assign audio_mclk = clk_cnt[1];
    assign audio_lrck = clk_cnt[8];
    assign audio_sck = 1'b1; // use internal serial clock mode

    // audio input data buffer
    always @(posedge clk_cnt[8] or posedge rst)
        if (rst == 1'b1)
            begin
                audio_left <= 16'd0;
                audio_right <= 16'd0;
            end
        else
            begin
                audio_left <= audio_in_left;
                audio_right <= audio_in_right;
            end

    always @*
        case (clk_cnt[8:4])
            5'b00000: audio_sdin = audio_right[0];
            5'b00001: audio_sdin = audio_left[15];
            5'b00010: audio_sdin = audio_left[14];
            5'b00011: audio_sdin = audio_left[13];
            5'b00100: audio_sdin = audio_left[12];
            5'b00101: audio_sdin = audio_left[11];
            5'b00110: audio_sdin = audio_left[10];
            5'b00111: audio_sdin = audio_left[9];
            5'b01000: audio_sdin = audio_left[8];
            5'b01001: audio_sdin = audio_left[7];
            5'b01010: audio_sdin = audio_left[6];
            5'b01011: audio_sdin = audio_left[5];
            5'b01100: audio_sdin = audio_left[4];
            5'b01101: audio_sdin = audio_left[3];
            5'b01110: audio_sdin = audio_left[2];
            5'b01111: audio_sdin = audio_left[1];
            5'b10000: audio_sdin = audio_left[0];
            5'b10001: audio_sdin = audio_right[15];
            5'b10010: audio_sdin = audio_right[14];
            5'b10011: audio_sdin = audio_right[13];
            5'b10100: audio_sdin = audio_right[12];
            5'b10101: audio_sdin = audio_right[11];
            5'b10110: audio_sdin = audio_right[10];
            5'b10111: audio_sdin = audio_right[9];
            5'b11000: audio_sdin = audio_right[8];
            5'b11001: audio_sdin = audio_right[7];
            5'b11010: audio_sdin = audio_right[6];
            5'b11011: audio_sdin = audio_right[5];
            5'b11100: audio_sdin = audio_right[4];
            5'b11101: audio_sdin = audio_right[3];
            5'b11110: audio_sdin = audio_right[2];
            5'b11111: audio_sdin = audio_right[1];
            default: audio_sdin = 1'b0;
        endcase

endmodule

module music_example (
	input [11:0] ibeatNum,
	input _pause,
	output reg [31:0] toneL,
    output reg [31:0] toneR
);

    always @* begin
        if(_pause != 0) begin
            case(ibeatNum)
                // --- Measure 1 ---
                12'd0: toneR = `he;      12'd1: toneR = `he; 
                12'd2: toneR = `he;      12'd3: toneR = `he;
                12'd4: toneR = `he;      12'd5: toneR = `he;
                12'd6: toneR = `he;      12'd7: toneR = `he;
                12'd8: toneR = `he;      12'd9: toneR = `he; 
                12'd10: toneR = `he;     12'd11: toneR = `he;
                12'd12: toneR = `he;     12'd13: toneR = `he;
                12'd14: toneR = `he;     12'd15: toneR = `he; 

                12'd16: toneR = `b;     12'd17: toneR = `b; 
                12'd18: toneR = `b;     12'd19: toneR = `b;
                12'd20: toneR = `b;     12'd21: toneR = `b;
                12'd22: toneR = `b;     12'd23: toneR = `b;
                12'd24: toneR = `hc;     12'd25: toneR = `hc;
                12'd26: toneR = `hc;     12'd27: toneR = `hc;
                12'd28: toneR = `hc;     12'd29: toneR = `hc;
                12'd30: toneR = `hc;     12'd31: toneR = `hc;

                12'd32: toneR = `hd;     12'd33: toneR = `hd; 
                12'd34: toneR = `hd;     12'd35: toneR = `hd;
                12'd36: toneR = `hd;     12'd37: toneR = `hd;
                12'd38: toneR = `hd;     12'd39: toneR = `hd;
                12'd40: toneR = `hd;     12'd41: toneR = `hd; 
                12'd42: toneR = `hd;     12'd43: toneR = `hd;
                12'd44: toneR = `hd;     12'd45: toneR = `hd;
                12'd46: toneR = `hd;     12'd47: toneR = `hd;

                12'd48: toneR = `hc;     12'd49: toneR = `hc; 
                12'd50: toneR = `hc;     12'd51: toneR = `hc;
                12'd52: toneR = `hc;     12'd53: toneR = `hc;
                12'd54: toneR = `hc;     12'd55: toneR = `hc;
                12'd56: toneR = `b;     12'd57: toneR = `b;
                12'd58: toneR = `b;     12'd59: toneR = `b;
                12'd60: toneR = `b;     12'd61: toneR = `b;
                12'd62: toneR = `b;     12'd63: toneR = `b;

                // --- Measure 2 ---
                12'd64: toneR = `a;     12'd65: toneR = `a; 
                12'd66: toneR = `a;     12'd67: toneR = `a;
                12'd68: toneR = `a;     12'd69: toneR = `a;
                12'd70: toneR = `a;     12'd71: toneR = `a;
                12'd72: toneR = `a;     12'd73: toneR = `a;
                12'd74: toneR = `a;     12'd75: toneR = `a;
                12'd76: toneR = `a;     12'd77: toneR = `a;
                12'd78: toneR = `a;     12'd79: toneR = `sil;

                12'd80: toneR = `a;     12'd81: toneR = `a; 
                12'd82: toneR = `a;     12'd83: toneR = `a;
                12'd84: toneR = `a;     12'd85: toneR = `a;
                12'd86: toneR = `a;     12'd87: toneR = `a;
                12'd88: toneR = `hc;     12'd89: toneR = `hc; 
                12'd90: toneR = `hc;     12'd91: toneR = `hc;
                12'd92: toneR = `hc;     12'd93: toneR = `hc;
                12'd94: toneR = `hc;     12'd95: toneR = `hc;

                12'd96: toneR = `he;     12'd97: toneR = `he; 
                12'd98: toneR = `he;     12'd99: toneR = `he;
                12'd100: toneR = `he;    12'd101: toneR = `he;
                12'd102: toneR = `he;    12'd103: toneR = `he; 
                12'd104: toneR = `he;    12'd105: toneR = `he; 
                12'd106: toneR = `he;    12'd107: toneR = `he;
                12'd108: toneR = `he;    12'd109: toneR = `he;
                12'd110: toneR = `he;    12'd111: toneR = `he; 

                12'd112: toneR = `hd;    12'd113: toneR = `hd; 
                12'd114: toneR = `hd;    12'd115: toneR = `hd;
                12'd116: toneR = `hd;    12'd117: toneR = `hd;
                12'd118: toneR = `hd;    12'd119: toneR = `hd;
                12'd120: toneR = `hc;    12'd121: toneR = `hc;
                12'd122: toneR = `hc;    12'd123: toneR = `hc;
                12'd124: toneR = `hc;    12'd125: toneR = `hc;
                12'd126: toneR = `hc;    12'd127: toneR = `hc;

                //Measure 3
                12'd128: toneR = `b;    12'd129: toneR = `b;
                12'd130: toneR = `b;    12'd131: toneR = `b;
                12'd132: toneR = `b;    12'd133: toneR = `b;
                12'd134: toneR = `b;    12'd135: toneR = `b;
                12'd136: toneR = `b;    12'd137: toneR = `b;
                12'd138: toneR = `b;    12'd139: toneR = `b;
                12'd140: toneR = `b;    12'd141: toneR = `b;
                12'd142: toneR = `b;    12'd143: toneR = `b;

                12'd144: toneR = `b;    12'd145: toneR = `b;
                12'd146: toneR = `b;    12'd147: toneR = `b;
                12'd148: toneR = `b;    12'd149: toneR = `b;
                12'd150: toneR = `b;    12'd151: toneR = `b;
                12'd152: toneR = `hc;    12'd153: toneR = `hc;
                12'd154: toneR = `hc;    12'd155: toneR = `hc;
                12'd156: toneR = `hc;    12'd157: toneR = `hc;
                12'd158: toneR = `hc;    12'd159: toneR = `hc;

                12'd160: toneR = `hd;    12'd161: toneR = `hd;
                12'd162: toneR = `hd;    12'd163: toneR = `hd;
                12'd164: toneR = `hd;    12'd165: toneR = `hd;
                12'd166: toneR = `hd;    12'd167: toneR = `hd;
                12'd168: toneR = `hd;    12'd169: toneR = `hd;
                12'd170: toneR = `hd;    12'd171: toneR = `hd;
                12'd172: toneR = `hd;    12'd173: toneR = `hd;
                12'd174: toneR = `hd;    12'd175: toneR = `hd;

                12'd176: toneR = `he;    12'd177: toneR = `he;
                12'd178: toneR = `he;    12'd179: toneR = `he;
                12'd180: toneR = `he;    12'd181: toneR = `he;
                12'd182: toneR = `he;    12'd183: toneR = `he;
                12'd184: toneR = `he;    12'd185: toneR = `he;
                12'd186: toneR = `he;    12'd187: toneR = `he;
                12'd188: toneR = `he;    12'd189: toneR = `he;
                12'd190: toneR = `he;    12'd191: toneR = `he;

                //Measure 4
                12'd192: toneR = `hc;    12'd193: toneR = `hc;
                12'd194: toneR = `hc;    12'd195: toneR = `hc;
                12'd196: toneR = `hc;    12'd197: toneR = `hc;
                12'd198: toneR = `hc;    12'd199: toneR = `hc;
                12'd200: toneR = `hc;    12'd201: toneR = `hc;
                12'd202: toneR = `hc;    12'd203: toneR = `hc;
                12'd204: toneR = `hc;    12'd205: toneR = `hc;
                12'd206: toneR = `hc;    12'd207: toneR = `hc;
                
                12'd208: toneR = `a;    12'd209: toneR = `a;
                12'd210: toneR = `a;    12'd211: toneR = `a;
                12'd212: toneR = `a;    12'd213: toneR = `a;
                12'd214: toneR = `a;    12'd215: toneR = `a;
                12'd216: toneR = `a;    12'd217: toneR = `a;
                12'd218: toneR = `a;    12'd219: toneR = `a;
                12'd220: toneR = `a;    12'd221: toneR = `a;
                12'd222: toneR = `a;    12'd223: toneR = `sil;

                12'd224: toneR = `a;    12'd225: toneR = `a;
                12'd226: toneR = `a;    12'd227: toneR = `a;
                12'd228: toneR = `a;    12'd229: toneR = `a;
                12'd230: toneR = `a;    12'd231: toneR = `a;
                12'd232: toneR = `a;    12'd233: toneR = `a;
                12'd234: toneR = `a;    12'd235: toneR = `a;
                12'd236: toneR = `a;    12'd237: toneR = `a;
                12'd238: toneR = `a;    12'd239: toneR = `a;

                12'd240: toneR = `sil;    12'd241: toneR = `sil;
                12'd242: toneR = `sil;    12'd243: toneR = `sil;
                12'd244: toneR = `sil;    12'd245: toneR = `sil;
                12'd246: toneR = `sil;    12'd247: toneR = `sil;
                12'd248: toneR = `sil;    12'd249: toneR = `sil;
                12'd250: toneR = `sil;    12'd251: toneR = `sil;
                12'd252: toneR = `sil;    12'd253: toneR = `sil;
                12'd254: toneR = `sil;    12'd255: toneR = `sil;

                //measure 5
                12'd256: toneR = `sil;    12'd257: toneR = `sil;
                12'd258: toneR = `sil;    12'd259: toneR = `sil;
                12'd260: toneR = `sil;    12'd261: toneR = `sil;
                12'd262: toneR = `sil;    12'd263: toneR = `sil;
                12'd264: toneR = `hd;    12'd265: toneR = `hd;
                12'd266: toneR = `hd;    12'd267: toneR = `hd;
                12'd268: toneR = `hd;    12'd269: toneR = `hd;
                12'd270: toneR = `hd;    12'd271: toneR = `hd;

                12'd272: toneR = `hd;    12'd273: toneR = `hd;
                12'd274: toneR = `hd;    12'd275: toneR = `hd;
                12'd276: toneR = `hd;    12'd277: toneR = `hd;
                12'd278: toneR = `hd;    12'd279: toneR = `hd;
                12'd280: toneR = `hf;    12'd281: toneR = `hf;
                12'd282: toneR = `hf;    12'd283: toneR = `hf;
                12'd284: toneR = `hf;    12'd285: toneR = `hf;
                12'd286: toneR = `hf;    12'd287: toneR = `hf;

                12'd288: toneR = `ha;    12'd289: toneR = `ha;
                12'd290: toneR = `ha;    12'd291: toneR = `ha;
                12'd292: toneR = `ha;    12'd293: toneR = `ha;
                12'd294: toneR = `ha;    12'd295: toneR = `ha;
                12'd296: toneR = `ha;    12'd297: toneR = `ha;
                12'd298: toneR = `ha;    12'd299: toneR = `ha;
                12'd300: toneR = `ha;    12'd301: toneR = `ha;
                12'd302: toneR = `ha;    12'd303: toneR = `ha;
                
                12'd304: toneR = `hg;    12'd305: toneR = `hg;
                12'd306: toneR = `hg;    12'd307: toneR = `hg;
                12'd308: toneR = `hg;    12'd309: toneR = `hg;
                12'd310: toneR = `hg;    12'd311: toneR = `hg;
                12'd312: toneR = `hf;    12'd313: toneR = `hf;
                12'd314: toneR = `hf;    12'd315: toneR = `hf;
                12'd316: toneR = `hf;    12'd317: toneR = `hf;
                12'd318: toneR = `hf;    12'd319: toneR = `hf;

                //measure 6
                12'd320: toneR = `he;    12'd321: toneR = `he;
                12'd322: toneR = `he;    12'd323: toneR = `he;
                12'd324: toneR = `he;    12'd325: toneR = `he;
                12'd326: toneR = `he;    12'd327: toneR = `he;
                12'd328: toneR = `he;    12'd329: toneR = `he;
                12'd330: toneR = `he;    12'd331: toneR = `he;
                12'd332: toneR = `he;    12'd333: toneR = `he;
                12'd334: toneR = `he;    12'd335: toneR = `he;

                12'd336: toneR = `he;    12'd337: toneR = `he;
                12'd338: toneR = `he;    12'd339: toneR = `he;
                12'd340: toneR = `he;    12'd341: toneR = `he;
                12'd342: toneR = `he;    12'd343: toneR = `he;
                12'd344: toneR = `hc;    12'd345: toneR = `hc;
                12'd346: toneR = `hc;    12'd347: toneR = `hc;
                12'd348: toneR = `hc;    12'd349: toneR = `hc;
                12'd350: toneR = `hc;    12'd351: toneR = `hc;

                12'd352: toneR = `he;    12'd353: toneR = `he;
                12'd354: toneR = `he;    12'd355: toneR = `he;
                12'd356: toneR = `he;    12'd357: toneR = `he;
                12'd358: toneR = `he;    12'd359: toneR = `he;
                12'd360: toneR = `he;    12'd361: toneR = `he;
                12'd362: toneR = `he;    12'd363: toneR = `he;
                12'd364: toneR = `he;    12'd365: toneR = `he;
                12'd366: toneR = `he;    12'd367: toneR = `he;

                12'd368: toneR = `hd;    12'd369: toneR = `hd;
                12'd370: toneR = `hd;    12'd371: toneR = `hd;
                12'd372: toneR = `hd;    12'd373: toneR = `hd;
                12'd374: toneR = `hd;    12'd375: toneR = `hd;
                12'd376: toneR = `hc;    12'd377: toneR = `hc;
                12'd378: toneR = `hc;    12'd379: toneR = `hc;
                12'd380: toneR = `hc;    12'd381: toneR = `hc;
                12'd382: toneR = `hc;    12'd383: toneR = `hc;

                //measure 7
                12'd384: toneR = `b;    12'd385: toneR = `b;
                12'd386: toneR = `b;    12'd387: toneR = `b;
                12'd388: toneR = `b;    12'd389: toneR = `b;
                12'd390: toneR = `b;    12'd391: toneR = `b;
                12'd392: toneR = `b;    12'd393: toneR = `b;
                12'd394: toneR = `b;    12'd395: toneR = `b;
                12'd396: toneR = `b;    12'd397: toneR = `b;
                12'd398: toneR = `b;    12'd399: toneR = `b;

                12'd400: toneR = `b;    12'd401: toneR = `b;
                12'd402: toneR = `b;    12'd403: toneR = `b;
                12'd404: toneR = `b;    12'd405: toneR = `b;
                12'd406: toneR = `b;    12'd407: toneR = `b;
                12'd408: toneR = `hc;    12'd409: toneR = `hc;
                12'd410: toneR = `hc;    12'd411: toneR = `hc;
                12'd412: toneR = `hc;    12'd413: toneR = `hc;
                12'd414: toneR = `hc;    12'd415: toneR = `hc;

                12'd416: toneR = `hd;    12'd417: toneR = `hd;
                12'd418: toneR = `hd;    12'd419: toneR = `hd;
                12'd420: toneR = `hd;    12'd421: toneR = `hd;
                12'd422: toneR = `hd;    12'd423: toneR = `hd;
                12'd424: toneR = `hd;    12'd425: toneR = `hd;
                12'd426: toneR = `hd;    12'd427: toneR = `hd;
                12'd428: toneR = `hd;    12'd429: toneR = `hd;
                12'd430: toneR = `hd;    12'd431: toneR = `hd;

                12'd432: toneR = `he;    12'd433: toneR = `he;
                12'd434: toneR = `he;    12'd435: toneR = `he;
                12'd436: toneR = `he;    12'd437: toneR = `he;
                12'd438: toneR = `he;    12'd439: toneR = `he;
                12'd440: toneR = `he;    12'd441: toneR = `he;
                12'd442: toneR = `he;    12'd443: toneR = `he;
                12'd444: toneR = `he;    12'd445: toneR = `he;
                12'd446: toneR = `he;    12'd447: toneR = `he;

                //meausre 8
                12'd448: toneR = `hc;    12'd449: toneR = `hc;
                12'd450: toneR = `hc;    12'd451: toneR = `hc;
                12'd452: toneR = `hc;    12'd453: toneR = `hc;
                12'd454: toneR = `hc;    12'd455: toneR = `hc;
                12'd456: toneR = `hc;    12'd457: toneR = `hc;
                12'd458: toneR = `hc;    12'd459: toneR = `hc;
                12'd460: toneR = `hc;    12'd461: toneR = `hc;
                12'd462: toneR = `hc;    12'd463: toneR = `hc;

                12'd464: toneR = `a;    12'd465: toneR = `a;
                12'd466: toneR = `a;    12'd467: toneR = `a;
                12'd468: toneR = `a;    12'd469: toneR = `a;
                12'd470: toneR = `a;    12'd471: toneR = `a;
                12'd472: toneR = `a;    12'd473: toneR = `a;
                12'd474: toneR = `a;    12'd475: toneR = `a;
                12'd476: toneR = `a;    12'd477: toneR = `a;
                12'd478: toneR = `a;    12'd479: toneR = `sil;

                12'd480: toneR = `a;    12'd481: toneR = `a;
                12'd482: toneR = `a;    12'd483: toneR = `a;
                12'd484: toneR = `a;    12'd485: toneR = `a;
                12'd486: toneR = `a;    12'd487: toneR = `a;
                12'd488: toneR = `a;    12'd489: toneR = `a;
                12'd490: toneR = `a;    12'd491: toneR = `a;
                12'd492: toneR = `a;    12'd493: toneR = `a;
                12'd494: toneR = `a;    12'd495: toneR = `a;

                12'd496: toneR = `sil;    12'd497: toneR = `sil;
                12'd498: toneR = `sil;    12'd499: toneR = `sil;
                12'd500: toneR = `sil;    12'd501: toneR = `sil;
                12'd502: toneR = `sil;    12'd503: toneR = `sil;
                12'd504: toneR = `sil;    12'd505: toneR = `sil;
                12'd506: toneR = `sil;    12'd507: toneR = `sil;
                12'd508: toneR = `sil;    12'd509: toneR = `sil;
                12'd510: toneR = `sil;    12'd511: toneR = `sil;

                default: toneR = `sil;
            endcase
        end else begin
            toneR = `sil;
        end
    end

    always @(*) begin
        if(_pause != 0)begin
            case(ibeatNum)
                // --- Measure 1 ---
                12'd0: toneL = `he;      12'd1: toneL = `he; 
                12'd2: toneL = `he;      12'd3: toneL = `he;
                12'd4: toneL = `he;      12'd5: toneL = `he;
                12'd6: toneL = `he;      12'd7: toneL = `he;
                12'd8: toneL = `he;      12'd9: toneL = `he; 
                12'd10: toneL = `he;     12'd11: toneL = `he;
                12'd12: toneL = `he;     12'd13: toneL = `he;
                12'd14: toneL = `he;     12'd15: toneL = `he; 

                12'd16: toneL = `b;     12'd17: toneL = `b; 
                12'd18: toneL = `b;     12'd19: toneL = `b;
                12'd20: toneL = `b;     12'd21: toneL = `b;
                12'd22: toneL = `b;     12'd23: toneL = `b;
                12'd24: toneL = `hc;     12'd25: toneL = `hc;
                12'd26: toneL = `hc;     12'd27: toneL = `hc;
                12'd28: toneL = `hc;     12'd29: toneL = `hc;
                12'd30: toneL = `hc;     12'd31: toneL = `hc;

                12'd32: toneL = `hd;     12'd33: toneL = `hd; 
                12'd34: toneL = `hd;     12'd35: toneL = `hd;
                12'd36: toneL = `hd;     12'd37: toneL = `hd;
                12'd38: toneL = `hd;     12'd39: toneL = `hd;
                12'd40: toneL = `hd;     12'd41: toneL = `hd; 
                12'd42: toneL = `hd;     12'd43: toneL = `hd;
                12'd44: toneL = `hd;     12'd45: toneL = `hd;
                12'd46: toneL = `hd;     12'd47: toneL = `hd;

                12'd48: toneL = `hc;     12'd49: toneL = `hc; 
                12'd50: toneL = `hc;     12'd51: toneL = `hc;
                12'd52: toneL = `hc;     12'd53: toneL = `hc;
                12'd54: toneL = `hc;     12'd55: toneL = `hc;
                12'd56: toneL = `b;     12'd57: toneL = `b;
                12'd58: toneL = `b;     12'd59: toneL = `b;
                12'd60: toneL = `b;     12'd61: toneL = `b;
                12'd62: toneL = `b;     12'd63: toneL = `b;

                // --- Measure 2 ---
                12'd64: toneL = `a;     12'd65: toneL = `a; 
                12'd66: toneL = `a;     12'd67: toneL = `a;
                12'd68: toneL = `a;     12'd69: toneL = `a;
                12'd70: toneL = `a;     12'd71: toneL = `a;
                12'd72: toneL = `a;     12'd73: toneL = `a;
                12'd74: toneL = `a;     12'd75: toneL = `a;
                12'd76: toneL = `a;     12'd77: toneL = `a;
                12'd78: toneL = `a;     12'd79: toneL = `sil;

                12'd80: toneL = `a;     12'd81: toneL = `a; 
                12'd82: toneL = `a;     12'd83: toneL = `a;
                12'd84: toneL = `a;     12'd85: toneL = `a;
                12'd86: toneL = `a;     12'd87: toneL = `a;
                12'd88: toneL = `hc;     12'd89: toneL = `hc; 
                12'd90: toneL = `hc;     12'd91: toneL = `hc;
                12'd92: toneL = `hc;     12'd93: toneL = `hc;
                12'd94: toneL = `hc;     12'd95: toneL = `hc;

                12'd96: toneL = `he;     12'd97: toneL = `he; 
                12'd98: toneL = `he;     12'd99: toneL = `he;
                12'd100: toneL = `he;    12'd101: toneL = `he;
                12'd102: toneL = `he;    12'd103: toneL = `he; 
                12'd104: toneL = `he;    12'd105: toneL = `he; 
                12'd106: toneL = `he;    12'd107: toneL = `he;
                12'd108: toneL = `he;    12'd109: toneL = `he;
                12'd110: toneL = `he;    12'd111: toneL = `he; 

                12'd112: toneL = `hd;    12'd113: toneL = `hd; 
                12'd114: toneL = `hd;    12'd115: toneL = `hd;
                12'd116: toneL = `hd;    12'd117: toneL = `hd;
                12'd118: toneL = `hd;    12'd119: toneL = `hd;
                12'd120: toneL = `hc;    12'd121: toneL = `hc;
                12'd122: toneL = `hc;    12'd123: toneL = `hc;
                12'd124: toneL = `hc;    12'd125: toneL = `hc;
                12'd126: toneL = `hc;    12'd127: toneL = `hc;

                //Measure 3
                12'd128: toneL = `b;    12'd129: toneL = `b;
                12'd130: toneL = `b;    12'd131: toneL = `b;
                12'd132: toneL = `b;    12'd133: toneL = `b;
                12'd134: toneL = `b;    12'd135: toneL = `b;
                12'd136: toneL = `b;    12'd137: toneL = `b;
                12'd138: toneL = `b;    12'd139: toneL = `b;
                12'd140: toneL = `b;    12'd141: toneL = `b;
                12'd142: toneL = `b;    12'd143: toneL = `b;

                12'd144: toneL = `b;    12'd145: toneL = `b;
                12'd146: toneL = `b;    12'd147: toneL = `b;
                12'd148: toneL = `b;    12'd149: toneL = `b;
                12'd150: toneL = `b;    12'd151: toneL = `b;
                12'd152: toneL = `hc;    12'd153: toneL = `hc;
                12'd154: toneL = `hc;    12'd155: toneL = `hc;
                12'd156: toneL = `hc;    12'd157: toneL = `hc;
                12'd158: toneL = `hc;    12'd159: toneL = `hc;

                12'd160: toneL = `hd;    12'd161: toneL = `hd;
                12'd162: toneL = `hd;    12'd163: toneL = `hd;
                12'd164: toneL = `hd;    12'd165: toneL = `hd;
                12'd166: toneL = `hd;    12'd167: toneL = `hd;
                12'd168: toneL = `hd;    12'd169: toneL = `hd;
                12'd170: toneL = `hd;    12'd171: toneL = `hd;
                12'd172: toneL = `hd;    12'd173: toneL = `hd;
                12'd174: toneL = `hd;    12'd175: toneL = `hd;

                12'd176: toneL = `he;    12'd177: toneL = `he;
                12'd178: toneL = `he;    12'd179: toneL = `he;
                12'd180: toneL = `he;    12'd181: toneL = `he;
                12'd182: toneL = `he;    12'd183: toneL = `he;
                12'd184: toneL = `he;    12'd185: toneL = `he;
                12'd186: toneL = `he;    12'd187: toneL = `he;
                12'd188: toneL = `he;    12'd189: toneL = `he;
                12'd190: toneL = `he;    12'd191: toneL = `he;

                //Measure 4
                12'd192: toneL = `hc;    12'd193: toneL = `hc;
                12'd194: toneL = `hc;    12'd195: toneL = `hc;
                12'd196: toneL = `hc;    12'd197: toneL = `hc;
                12'd198: toneL = `hc;    12'd199: toneL = `hc;
                12'd200: toneL = `hc;    12'd201: toneL = `hc;
                12'd202: toneL = `hc;    12'd203: toneL = `hc;
                12'd204: toneL = `hc;    12'd205: toneL = `hc;
                12'd206: toneL = `hc;    12'd207: toneL = `hc;
                
                12'd208: toneL = `a;    12'd209: toneL = `a;
                12'd210: toneL = `a;    12'd211: toneL = `a;
                12'd212: toneL = `a;    12'd213: toneL = `a;
                12'd214: toneL = `a;    12'd215: toneL = `a;
                12'd216: toneL = `a;    12'd217: toneL = `a;
                12'd218: toneL = `a;    12'd219: toneL = `a;
                12'd220: toneL = `a;    12'd221: toneL = `a;
                12'd222: toneL = `a;    12'd223: toneL = `sil;

                12'd224: toneL = `a;    12'd225: toneL = `a;
                12'd226: toneL = `a;    12'd227: toneL = `a;
                12'd228: toneL = `a;    12'd229: toneL = `a;
                12'd230: toneL = `a;    12'd231: toneL = `a;
                12'd232: toneL = `a;    12'd233: toneL = `a;
                12'd234: toneL = `a;    12'd235: toneL = `a;
                12'd236: toneL = `a;    12'd237: toneL = `a;
                12'd238: toneL = `a;    12'd239: toneL = `a;

                12'd240: toneL = `sil;    12'd241: toneL = `sil;
                12'd242: toneL = `sil;    12'd243: toneL = `sil;
                12'd244: toneL = `sil;    12'd245: toneL = `sil;
                12'd246: toneL = `sil;    12'd247: toneL = `sil;
                12'd248: toneL = `sil;    12'd249: toneL = `sil;
                12'd250: toneL = `sil;    12'd251: toneL = `sil;
                12'd252: toneL = `sil;    12'd253: toneL = `sil;
                12'd254: toneL = `sil;    12'd255: toneL = `sil;

                //measure 5
                12'd256: toneL = `sil;    12'd257: toneL = `sil;
                12'd258: toneL = `sil;    12'd259: toneL = `sil;
                12'd260: toneL = `sil;    12'd261: toneL = `sil;
                12'd262: toneL = `sil;    12'd263: toneL = `sil;
                12'd264: toneL = `hd;    12'd265: toneL = `hd;
                12'd266: toneL = `hd;    12'd267: toneL = `hd;
                12'd268: toneL = `hd;    12'd269: toneL = `hd;
                12'd270: toneL = `hd;    12'd271: toneL = `hd;

                12'd272: toneL = `hd;    12'd273: toneL = `hd;
                12'd274: toneL = `hd;    12'd275: toneL = `hd;
                12'd276: toneL = `hd;    12'd277: toneL = `hd;
                12'd278: toneL = `hd;    12'd279: toneL = `hd;
                12'd280: toneL = `hf;    12'd281: toneL = `hf;
                12'd282: toneL = `hf;    12'd283: toneL = `hf;
                12'd284: toneL = `hf;    12'd285: toneL = `hf;
                12'd286: toneL = `hf;    12'd287: toneL = `hf;

                12'd288: toneL = `ha;    12'd289: toneL = `ha;
                12'd290: toneL = `ha;    12'd291: toneL = `ha;
                12'd292: toneL = `ha;    12'd293: toneL = `ha;
                12'd294: toneL = `ha;    12'd295: toneL = `ha;
                12'd296: toneL = `ha;    12'd297: toneL = `ha;
                12'd298: toneL = `ha;    12'd299: toneL = `ha;
                12'd300: toneL = `ha;    12'd301: toneL = `ha;
                12'd302: toneL = `ha;    12'd303: toneL = `ha;
                
                12'd304: toneL = `hg;    12'd305: toneL = `hg;
                12'd306: toneL = `hg;    12'd307: toneL = `hg;
                12'd308: toneL = `hg;    12'd309: toneL = `hg;
                12'd310: toneL = `hg;    12'd311: toneL = `hg;
                12'd312: toneL = `hf;    12'd313: toneL = `hf;
                12'd314: toneL = `hf;    12'd315: toneL = `hf;
                12'd316: toneL = `hf;    12'd317: toneL = `hf;
                12'd318: toneL = `hf;    12'd319: toneL = `hf;

                //measure 6
                12'd320: toneL = `he;    12'd321: toneL = `he;
                12'd322: toneL = `he;    12'd323: toneL = `he;
                12'd324: toneL = `he;    12'd325: toneL = `he;
                12'd326: toneL = `he;    12'd327: toneL = `he;
                12'd328: toneL = `he;    12'd329: toneL = `he;
                12'd330: toneL = `he;    12'd331: toneL = `he;
                12'd332: toneL = `he;    12'd333: toneL = `he;
                12'd334: toneL = `he;    12'd335: toneL = `he;

                12'd336: toneL = `he;    12'd337: toneL = `he;
                12'd338: toneL = `he;    12'd339: toneL = `he;
                12'd340: toneL = `he;    12'd341: toneL = `he;
                12'd342: toneL = `he;    12'd343: toneL = `he;
                12'd344: toneL = `hc;    12'd345: toneL = `hc;
                12'd346: toneL = `hc;    12'd347: toneL = `hc;
                12'd348: toneL = `hc;    12'd349: toneL = `hc;
                12'd350: toneL = `hc;    12'd351: toneL = `hc;

                12'd352: toneL = `he;    12'd353: toneL = `he;
                12'd354: toneL = `he;    12'd355: toneL = `he;
                12'd356: toneL = `he;    12'd357: toneL = `he;
                12'd358: toneL = `he;    12'd359: toneL = `he;
                12'd360: toneL = `he;    12'd361: toneL = `he;
                12'd362: toneL = `he;    12'd363: toneL = `he;
                12'd364: toneL = `he;    12'd365: toneL = `he;
                12'd366: toneL = `he;    12'd367: toneL = `he;

                12'd368: toneL = `hd;    12'd369: toneL = `hd;
                12'd370: toneL = `hd;    12'd371: toneL = `hd;
                12'd372: toneL = `hd;    12'd373: toneL = `hd;
                12'd374: toneL = `hd;    12'd375: toneL = `hd;
                12'd376: toneL = `hc;    12'd377: toneL = `hc;
                12'd378: toneL = `hc;    12'd379: toneL = `hc;
                12'd380: toneL = `hc;    12'd381: toneL = `hc;
                12'd382: toneL = `hc;    12'd383: toneL = `hc;

                //measure 7
                12'd384: toneL = `b;    12'd385: toneL = `b;
                12'd386: toneL = `b;    12'd387: toneL = `b;
                12'd388: toneL = `b;    12'd389: toneL = `b;
                12'd390: toneL = `b;    12'd391: toneL = `b;
                12'd392: toneL = `b;    12'd393: toneL = `b;
                12'd394: toneL = `b;    12'd395: toneL = `b;
                12'd396: toneL = `b;    12'd397: toneL = `b;
                12'd398: toneL = `b;    12'd399: toneL = `b;

                12'd400: toneL = `b;    12'd401: toneL = `b;
                12'd402: toneL = `b;    12'd403: toneL = `b;
                12'd404: toneL = `b;    12'd405: toneL = `b;
                12'd406: toneL = `b;    12'd407: toneL = `b;
                12'd408: toneL = `hc;    12'd409: toneL = `hc;
                12'd410: toneL = `hc;    12'd411: toneL = `hc;
                12'd412: toneL = `hc;    12'd413: toneL = `hc;
                12'd414: toneL = `hc;    12'd415: toneL = `hc;

                12'd416: toneL = `hd;    12'd417: toneL = `hd;
                12'd418: toneL = `hd;    12'd419: toneL = `hd;
                12'd420: toneL = `hd;    12'd421: toneL = `hd;
                12'd422: toneL = `hd;    12'd423: toneL = `hd;
                12'd424: toneL = `hd;    12'd425: toneL = `hd;
                12'd426: toneL = `hd;    12'd427: toneL = `hd;
                12'd428: toneL = `hd;    12'd429: toneL = `hd;
                12'd430: toneL = `hd;    12'd431: toneL = `hd;

                12'd432: toneL = `he;    12'd433: toneL = `he;
                12'd434: toneL = `he;    12'd435: toneL = `he;
                12'd436: toneL = `he;    12'd437: toneL = `he;
                12'd438: toneL = `he;    12'd439: toneL = `he;
                12'd440: toneL = `he;    12'd441: toneL = `he;
                12'd442: toneL = `he;    12'd443: toneL = `he;
                12'd444: toneL = `he;    12'd445: toneL = `he;
                12'd446: toneL = `he;    12'd447: toneL = `he;

                //meausre 8
                12'd448: toneL = `hc;    12'd449: toneL = `hc;
                12'd450: toneL = `hc;    12'd451: toneL = `hc;
                12'd452: toneL = `hc;    12'd453: toneL = `hc;
                12'd454: toneL = `hc;    12'd455: toneL = `hc;
                12'd456: toneL = `hc;    12'd457: toneL = `hc;
                12'd458: toneL = `hc;    12'd459: toneL = `hc;
                12'd460: toneL = `hc;    12'd461: toneL = `hc;
                12'd462: toneL = `hc;    12'd463: toneL = `hc;

                12'd464: toneL = `a;    12'd465: toneL = `a;
                12'd466: toneL = `a;    12'd467: toneL = `a;
                12'd468: toneL = `a;    12'd469: toneL = `a;
                12'd470: toneL = `a;    12'd471: toneL = `a;
                12'd472: toneL = `a;    12'd473: toneL = `a;
                12'd474: toneL = `a;    12'd475: toneL = `a;
                12'd476: toneL = `a;    12'd477: toneL = `a;
                12'd478: toneL = `a;    12'd479: toneL = `sil;

                12'd480: toneL = `a;    12'd481: toneL = `a;
                12'd482: toneL = `a;    12'd483: toneL = `a;
                12'd484: toneL = `a;    12'd485: toneL = `a;
                12'd486: toneL = `a;    12'd487: toneL = `a;
                12'd488: toneL = `a;    12'd489: toneL = `a;
                12'd490: toneL = `a;    12'd491: toneL = `a;
                12'd492: toneL = `a;    12'd493: toneL = `a;
                12'd494: toneL = `a;    12'd495: toneL = `a;

                12'd496: toneL = `sil;    12'd497: toneL = `sil;
                12'd498: toneL = `sil;    12'd499: toneL = `sil;
                12'd500: toneL = `sil;    12'd501: toneL = `sil;
                12'd502: toneL = `sil;    12'd503: toneL = `sil;
                12'd504: toneL = `sil;    12'd505: toneL = `sil;
                12'd506: toneL = `sil;    12'd507: toneL = `sil;
                12'd508: toneL = `sil;    12'd509: toneL = `sil;
                12'd510: toneL = `sil;    12'd511: toneL = `sil;

                default : toneL = `sil;
            endcase
        end
        else begin
            toneL = `sil;
        end
    end
endmodule