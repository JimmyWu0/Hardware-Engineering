module lab6_2(
    input clk,
    input rst,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input hint,
    input [3:0] dir1,
    input [3:0] dir2,
    input [3:0] bu1,
    input [3:0] bu2,
    input wire gamePause,
    input wire [1:0] gameState,
    output reg [2:0] hp1,
    output reg [2:0] hp2,
    output reg[3:0] vgaRed,  //modified: reg
    output reg[3:0] vgaGreen,
    output reg[3:0] vgaBlue,
    output hsync,
    output vsync,
    output pass
);

wire [11:0] data;
//wire [16:0] pixel_addr;
//
//reg [16:0] pa, next_pa;
//reg [4:0] state[15:0], next_state[15:0];  //{up/down, position}  //state[0]=5'b1_0010 means the left-top fraction is now having 2nd(0010, start from 0 to 15) pic and upside down(1)
//wire [9:0] h_c, v_c;
//reg [9:0] hc, vc;
//reg [9:0] next_hc, next_vc;
//
wire [11:0] pixel;
reg [11:0] pi;  //new added!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
wire valid;
wire [9:0] h_cnt;  //640
wire [9:0] v_cnt;  //480
//  keyboard
wire [63:0] key_down;  //512 -> 64
wire [8:0] last_change;
reg [9:0] last_key;  //needed?
/*reg [8:0] last2_change=9'b0;
always@(*) begin
    last2_change=last_change;
end*/

wire been_ready;
wire [63:0] key_decode = 1 << last_change;  //!!  key_down-key_decode==0 <=> only one key can be press at the same time
reg [3:0] key_num;  //specify which picture (1 out of 16)

reg [16:0] pa, next_pa;

//assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? ((state[pixel_addr]==3) ? 12'hF00 : ((state[pixel_addr]==4) ? 12'h00F : ((state[pixel_addr]==5) ? 12'hFF0 : pixel))) : 12'h0;
always@(*) begin
    if(state[pa]==0) {vgaRed, vgaGreen, vgaBlue}=12'h000;
    else if(state[pa]==1) {vgaRed, vgaGreen, vgaBlue}=12'hFFF;
    else if(state[pa]==2) {vgaRed, vgaGreen, vgaBlue}=12'h888;
    else if(state[pa]==3) {vgaRed, vgaGreen, vgaBlue}=12'hF00;
    else if(state[pa]==4) {vgaRed, vgaGreen, vgaBlue}=12'h00F;
    else if(state[pa]==5) {vgaRed, vgaGreen, vgaBlue}=12'hFF0;  //yellow bullet
end

//assign pixel_addr = pa;  //can NOT use
//assign pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1)+ position*320 )% 76800;  //640*480 --> 320*240

wire clk_2, clk_22;
clock_divider #(2) div1(.clk(clk),.clk_div(clk_2));
clock_divider #(22) div2(.clk(clk),.clk_div(clk_22));  //not used?

vga_controller vga_inst(
    .pclk(clk_2),
    .reset(rst),
    .hsync(hsync),
    .vsync(vsync),
    .valid(valid),
    .h_cnt(h_cnt),
    .v_cnt(v_cnt)
);

// blk_mem_gen_0 blk_mem_gen_0_inst(
//     .clka(clk_2),
//     .wea(0),
//     .addra(pixel_addr),
//     .dina(data[11:0]),
//     .douta(pixel)  //pixel->pi
// );

// mem_addr_gen m(
//     .clk_2(clk_2),
//     .clk_22(clk_22),
//     .rst(rst),
//     .hint(hint),
//     .key_down(key_down),
//     .last_change(last_change),
//     .been_ready(been_ready),
//     .h_cnt(h_cnt),
//     .v_cnt(v_cnt),
//     .pa(pixel_addr),
//     .pass(pass)
// );

always@(posedge clk_2 or posedge rst) begin
    if(rst) begin
        pa<=0;
    end else begin
        pa<=next_pa;
    end
end

always@* begin
    next_pa = pa;
    next_pa = (h_cnt/32)+20*(v_cnt/32);  //if(state[pa]==2,3) ...  //+1?
end

//budir1[last]
integer i;
//reg [3:0] last;
reg [2:0] next_hp1, next_hp2;
reg [9:0] pos1, next_pos1, pos2, next_pos2;
//reg [3:0] dir1, next_dir1, dir2, next_dir2;
reg [9:0] bupos1[0:0], next_bupos1[0:0], bupos2[0:0], next_bupos2[0:0];
//reg [9:0] past1, past2;
//reg [3:0] budir1, next_budir1, budir2, next_budir2;  //new added!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//reg [2:0] state[0:767], next_state[0:767];
// parameter [1:0] map [0:767]={
//     2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0,  //0:wall, 1:ground, 2:gray, 3:red, 4:blue, 5:bullet
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd0,
//     2'd0, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd0,
//     2'd0, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd0,
//     2'd0, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
//     2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0
// };

reg [2:0] state[0:299], next_state[0:299];

parameter [1:0] map [0:299]={
    2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0,   //0:wall, 1:ground, 2:gray, 3:red, 4:blue, 5:bullet
    2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
    2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 
    2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 
    2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
    2'd0, 2'd2, 2'd0, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd0, 2'd2, 2'd0,
    2'd0, 2'd2, 2'd0, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd0, 2'd2, 2'd0, 
    2'd0, 2'd2, 2'd0, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd0, 2'd2, 2'd0, 
    2'd0, 2'd2, 2'd0, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd0, 2'd2, 2'd0, 
    2'd0, 2'd2, 2'd0, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd2, 2'd0, 2'd2, 2'd0, 
    2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 
    2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 2'd0, 2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 
    2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0, 
    2'd0, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd1, 2'd0,
    2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0, 2'd0 
};

always@(posedge clk_22 or posedge rst) begin
    if(rst) begin
        // past1<=1;
        // past2<=1;
        pos1<=21;
        pos2<=278;
        for(i=0;i<300;i=i+1) state[i]<=map[i];
        for(i=0;i<1;i=i+1) begin
            bupos1[i]<=21;  //pos1+1-1;  //means NO bullet
            bupos2[i]<=278;  //pos2+1-1;
            // budir1[i]<=0;  //means NO bullet
            // budir2[i]<=0;
        end
        //pos1<=46;  //32*1+14  //red  //2
        //pos2<=721;  //32*22+17=721  //blue  //3  //787x
        //dir1<=0;
        //dir2<=0;
        hp1<=3;
        hp2<=3;

    end else begin
        // past1<=state[bupos1[0]];
        // past2<=state[bupos2[0]];
        for(i=0;i<300;i=i+1) state[i]<=next_state[i];
        for(i=0;i<1;i=i+1) begin
            bupos1[i]<=next_bupos1[i];
            bupos2[i]<=next_bupos2[i];
            // budir1[i]<=next_budir1[i];
            // budir2[i]<=next_budir2[i];
        end
        pos1<=next_pos1;
        pos2<=next_pos2;
        //dir1<=next_dir1;
        //dir2<=next_dir2;
        hp1<=next_hp1;
        hp2<=next_hp2;
    end
end

always@* begin
    next_pos1=pos1;
    next_pos2=pos2;
    next_hp1=hp1;
    next_hp2=hp2;
    for(i=0;i<300;i=i+1) next_state[i]=state[i];
    for(i=0;i<1;i=i+1) begin
        next_bupos1[i]=pos1;  //bupos1[i]
        next_bupos2[i]=pos2;  //bupos2[i]
        // if(bupos1[i]==pos1) next_budir1[i]=0;
        // else next_budir1[i]=budir1[i];
        // if(bupos2[i]==pos2) next_budir2[i]=0;
        // else next_budir2[i]=budir2[i];
    end
    if(gameState==0) begin
        next_hp1=3;
        next_hp2=3;
        next_pos1=21;
        next_pos2=278;
        for(i=0;i<300;i=i+1) next_state[i]=map[i];
        for(i=0;i<1;i=i+1) begin
            next_bupos1[i]=21;  //pos1+1-1;  //means NO bullet
            next_bupos2[i]=278;  //pos2+1-1;
            // budir1[i]<=0;  //means NO bullet
            // budir2[i]<=0;
        end
    end
    if(hp1!=0 && hp2!=0 && gamePause==0 && gameState==1) begin
    case(dir1)
        0: begin
            next_pos1=pos1;
        end
        1: begin
            if(state[pos1-1]==0 || state[pos1-1]==2) next_pos1=pos1;
            else next_pos1=pos1-1;
        end
        2: begin
            if(state[pos1-1-20]==0 || state[pos1-1-20]==2) next_pos1=pos1;
            else next_pos1=pos1-1-20;
        end
        3: begin
            if(state[pos1-20]==0 || state[pos1-20]==2) next_pos1=pos1;
            else next_pos1=pos1-20;
        end
        4: begin
            if(state[pos1-20+1]==0 || state[pos1-20+1]==2) next_pos1=pos1;
            else next_pos1=pos1-20+1;
        end
        5: begin
            if(state[pos1+1]==0 || state[pos1+1]==2) next_pos1=pos1;
            else next_pos1=pos1+1;
        end
        6: begin
            if(state[pos1+20+1]==0 || state[pos1+20+1]==2) next_pos1=pos1;
            else next_pos1=pos1+20+1;
        end
        7: begin
            if(state[pos1+20]==0 || state[pos1+20]==2) next_pos1=pos1;
            else next_pos1=pos1+20;
        end
        8: begin
            if(state[pos1+20-1]==0 || state[pos1+20-1]==2) next_pos1=pos1;
            else next_pos1=pos1+20-1;
        end
        default: begin
            next_pos1=pos1;
        end
    endcase
    case(dir2)
        0: begin
            next_pos2=pos2;
        end
        1: begin
            if(state[pos2-1]==0 || state[pos2-1]==2) next_pos2=pos2;
            else next_pos2=pos2-1;
        end
        2: begin
            if(state[pos2-1-20]==0 || state[pos2-1-20]==2) next_pos2=pos2;
            else next_pos2=pos2-1-20;
        end
        3: begin
            if(state[pos2-20]==0 || state[pos2-20]==2) next_pos2=pos2;
            else next_pos2=pos2-20;
        end
        4: begin
            if(state[pos2-20+1]==0 || state[pos2-20+1]==2) next_pos2=pos2;
            else next_pos2=pos2-20+1;
        end
        5: begin
            if(state[pos2+1]==0 || state[pos2+1]==2) next_pos2=pos2;
            else next_pos2=pos2+1;
        end
        6: begin
            if(state[pos2+20+1]==0 || state[pos2+20+1]==2) next_pos2=pos2;
            else next_pos2=pos2+20+1;
        end
        7: begin
            if(state[pos2+20]==0 || state[pos2+20]==2) next_pos2=pos2;
            else next_pos2=pos2+20;
        end
        8: begin
            if(state[pos2+20-1]==0 || state[pos2+20-1]==2) next_pos2=pos2;
            else next_pos2=pos2+20-1;
        end
        default: begin
            next_pos2=pos2;
        end
    endcase
    next_state[pos1]=1;  //ground
    next_state[pos2]=1;  //ground
    next_state[next_pos1]=3;  //red
    next_state[next_pos2]=4;  //blue
    for(i=0;i<1;i=i+1) begin
        if(bupos1[i]!=pos1+1-1) begin
            if(state[bupos1[i]+20]==0) next_bupos1[i]=pos1+1-1;
            else if(state[bupos1[i]+20]==2) begin
                next_bupos1[i]=pos1+1-1;
                next_state[bupos1[i]+20]=1;
            end
            else next_bupos1[i]=bupos1[i]+20;
            // case(budir1[i])
            //     0: begin
            //         next_bupos1[i]=bupos1[i];
            //     end
            //     1: begin
            //         if(state[bupos1[i]-1]==0) next_bupos1[i]=pos1+1-1;
            //         else next_bupos1[i]=bupos1[i]-1;
            //     end
            //     2: begin
            //         if(state[bupos1[i]-1-32]==0) next_bupos1[i]=pos1+1-1;
            //         else next_bupos1[i]=bupos1[i]-1-32;
            //     end
            //     3: begin
            //         if(state[bupos1[i]-32]==0) next_bupos1[i]=pos1+1-1;
            //         else next_bupos1[i]=bupos1[i]-32;
            //     end
            //     4: begin
            //         if(state[bupos1[i]-32+1]==0) next_bupos1[i]=pos1+1-1;
            //         else next_bupos1[i]=bupos1[i]-32+1;
            //     end
            //     5: begin
            //         if(state[bupos1[i]+1]==0) next_bupos1[i]=pos1+1-1;
            //         else next_bupos1[i]=bupos1[i]+1;
            //     end
            //     6: begin
            //         if(state[bupos1[i]+32+1]==0) next_bupos1[i]=pos1+1-1;
            //         else next_bupos1[i]=bupos1[i]+32+1;
            //     end
            //     7: begin
            //         if(state[bupos1[i]+32]==0) next_bupos1[i]=pos1+1-1;
            //         else next_bupos1[i]=bupos1[i]+32;
            //     end
            //     8: begin
            //         if(state[bupos1[i]+32-1]==0) next_bupos1[i]=pos1+1-1;
            //         else next_bupos1[i]=bupos1[i]+32-1;
            //     end
            //     default: begin
            //         next_bupos1[i]=bupos1[i];
            //     end
            // endcase
        end
        if(bupos2[i]!=pos2+1-1) begin
            if(state[bupos2[i]-20]==0) next_bupos2[i]=pos2+1-1;
            else if(state[bupos2[i]-20]==2) begin
                next_bupos2[i]=pos2+1-1;
                next_state[bupos2[i]-20]=1;
            end 
            else next_bupos2[i]=bupos2[i]-20;
            // case(budir2[i])
            //     0: begin
            //         next_bupos2[i]=bupos2[i];
            //     end
            //     1: begin
            //         if(state[bupos2[i]-1]==0) next_bupos2[i]=pos1+1-1;
            //         else next_bupos2[i]=bupos2[i]-1;
            //     end
            //     2: begin
            //         if(state[bupos2[i]-1-32]==0) next_bupos2[i]=pos1+1-1;
            //         else next_bupos2[i]=bupos2[i]-1-32;
            //     end
            //     3: begin
            //         if(state[bupos2[i]-32]==0) next_bupos2[i]=pos1+1-1;
            //         else next_bupos2[i]=bupos2[i]-32;
            //     end
            //     4: begin
            //         if(state[bupos2[i]-32+1]==0) next_bupos2[i]=pos1+1-1;
            //         else next_bupos2[i]=bupos2[i]-32+1;
            //     end
            //     5: begin
            //         if(state[bupos2[i]+1]==0) next_bupos2[i]=pos1+1-1;
            //         else next_bupos2[i]=bupos2[i]+1;
            //     end
            //     6: begin
            //         if(state[bupos2[i]+32+1]==0) next_bupos2[i]=pos1+1-1;
            //         else next_bupos2[i]=bupos2[i]+32+1;
            //     end
            //     7: begin
            //         if(state[bupos2[i]+32]==0) next_bupos2[i]=pos1+1-1;
            //         else next_bupos2[i]=bupos2[i]+32;
            //     end
            //     8: begin
            //         if(state[bupos2[i]+32-1]==0) next_bupos2[i]=pos1+1-1;
            //         else next_bupos2[i]=bupos2[i]+32-1;
            //     end
            //     default: begin
            //         next_bupos2[i]=bupos2[i];
            //     end
            // endcase
        end
    end
    if(bu1>=1 && bu1<=8) begin
        // last=11;
        // for(i=0;i<1;i=i+1) begin
        //     if(bupos1[i]==pos1+1-1) begin
        //         last=i;
        //     end
        // end
        // if(last!=11) begin
        //last=0;
        if(bupos1[0]==pos1) begin
        case(bu1)
            // 0: begin
            //     next_bupos1[0]=bupos1[0];
            //     //next_budir1[last]=budir1[last];
            // end
            1: begin
                if(state[pos1-1]!=0) begin
                    next_bupos1[0]=pos1-1;
                    //next_budir1[last]=1;
                end
            end
            // 2: begin
            //     if(state[pos1-1-32]!=0) begin
            //         next_bupos1[last]=pos1-1-32;
            //         next_budir1[last]=2;
            //     end
            // end
            // 3: begin
            //     if(state[pos1-32]!=0) begin
            //         next_bupos1[last]=pos1-32;
            //         //next_budir1[last]=3;
            //     end
            // end
            // 4: begin
            //     if(state[pos1-32+1]!=0) begin
            //         next_bupos1[last]=pos1-32+1;
            //         next_budir1[last]=4;
            //     end
            // end
            5: begin
                if(state[pos1+1]!=0) begin
                    next_bupos1[0]=pos1+1;
                    //next_budir1[last]=5;
                end
            end
            // 6: begin
            //     if(state[pos1+32+1]!=0) begin
            //         next_bupos1[last]=pos1+32+1;
            //         next_budir1[last]=6;
            //     end
            // end
            7: begin
                if(state[pos1+20]!=0) begin
                    next_bupos1[0]=pos1+20;
                    //next_budir1[last]=7;
                end
            end
            // 8: begin
            //     if(state[pos1+32-1]!=0) begin
            //         next_bupos1[last]=pos1+32-1;
            //         next_budir1[last]=8;
            //     end
            // end
            default: begin
                next_bupos1[0]=bupos1[0];
                //next_budir1[last]=budir1[last];
            end
        endcase
        end
    end
    if(bu2>=1 && bu2<=8) begin
        // last=11;
        // for(i=0;i<10;i=i+1) begin
        //     if(bupos2[i]==pos1+1-1) begin
        //         last=i;
        //     end
        // end
        // if(last!=11) begin
        //last=0;
        if(bupos2[0]==pos2) begin
        case(bu2)
            // 0: begin
            //     next_bupos2[0]=bupos2[0];
            //     //next_budir2[last]=budir2[last];
            // end
            1: begin
                if(state[pos2-1]!=0) begin
                    next_bupos2[0]=pos2-1;
                    //next_budir2[last]=1;
                end
            end
            // 2: begin
            //     if(state[pos2-1-32]!=0) begin
            //         next_bupos2[last]=pos2-1-32;
            //         next_budir2[last]=2;
            //     end
            // end
            3: begin
                if(state[pos2-20]!=0) begin
                    next_bupos2[0]=pos2-20;
                    //next_budir2[last]=3;
                end
            end
            // 4: begin
            //     if(state[pos2-32+1]!=0) begin
            //         next_bupos2[last]=pos2-32+1;
            //         next_budir2[last]=4;
            //     end
            // end
            5: begin
                if(state[pos2+1]!=0) begin
                    next_bupos2[0]=pos2+1;
                    //next_budir2[last]=5;
                end
            end
            // 6: begin
            //     if(state[pos2+32+1]!=0) begin
            //         next_bupos2[last]=pos2+32+1;
            //         next_budir2[last]=6;
            //     end
            // end
            // 7: begin
            //     if(state[pos2+32]!=0) begin
            //         next_bupos2[last]=pos2+32;
            //         next_budir2[last]=7;
            //     end
            // end
            // 8: begin
            //     if(state[pos2+32-1]!=0) begin
            //         next_bupos2[last]=pos2+32-1;
            //         next_budir2[last]=8;
            //     end
            // end
            default: begin
                next_bupos2[0]=bupos2[0];
                //next_budir2[last]=budir2[last];
            end
        endcase
        end
    end
//     // for(i=0;i<10;i=i+1) begin
//     //     if(bupos1[i]==pos1+1-1) ;  //next_state[bupos1[i]]=1;
//     //     else next_state[bupos1[i]]=1;
//     //     if(bupos2[i]==pos1+1-1) ;  //next_state[bupos2[i]]=1;
//     //     else next_state[bupos2[i]]=1;
//     //     if(next_bupos1[i]==pos1+1-1) ;  //next_state[next_bupos1[i]]=state[next_bupos1[i]];  //keep  //may be wrong
//     //     else next_state[next_bupos1[i]]=4;
//     //     if(next_bupos2[i]==pos1+1-1) ;  //next_state[next_bupos2[i]]=state[next_bupos2[i]];  //keep  //may be wrong
//     //     else next_state[next_bupos2[i]]=4;
//     // end
    // state[pos1]=1;  //ground
    // state[pos2]=1;  //ground

    for(i=0;i<1;i=i+1) begin
        if(bupos1[i]!=pos1+1-1) 
            next_state[bupos1[i]]=1;  //past1
        if(bupos2[i]!=pos2+1-1) 
            next_state[bupos2[i]]=1;
        if(next_bupos1[i]!=pos1+1-1) 
            next_state[next_bupos1[i]]=5;  //next_state[next_bupos1[i]]=4;
        if(next_bupos2[i]!=pos2+1-1) 
            next_state[next_bupos2[i]]=5;
    end

    // state[next_pos1]=2;  //red
    // state[next_pos2]=3;  //blue
    if(pos1==bupos2[0]) next_hp1=hp1-1;
    if(pos2==bupos1[0]) next_hp2=hp2-1;
end
end

endmodule

module mem_addr_gen(
    input clk_2,
    input clk_22,
    input rst,
    input hint,
    input [63:0] key_down,
    input [8:0] last_change,
    input been_ready,
    input [9:0] h_cnt,  //640
    input [9:0] v_cnt,  //480
    output reg [16:0] pa,
    output wire pass
);

//parameter [8:0] SHIFT_CODES = 9'b0_0001_0010;  //left shift key => 12
// parameter [8:0] KEY_CODES [0:15] = {
// 	9'b0_0001_0110,	// 1 => 16
// 	9'b0_0001_1110,	// 2 => 1E
// 	9'b0_0010_0110,	// 3 => 26
// 	9'b0_0010_0101,	// 4 => 25
// 	9'b0_0001_0101,	// Q => 15
// 	9'b0_0001_1101,	// W => 1D
// 	9'b0_0010_0100,	// E => 24
// 	9'b0_0010_1101,	// R => 2D
// 	9'b0_0001_1100,	// A => 1C
//     9'b0_0001_1011,	// S => 1B
// 	9'b0_0010_0011, // D => 23
// 	9'b0_0010_1011, // F => 2B
// 	9'b0_0001_1010, // Z => 1A
// 	9'b0_0010_0010, // X => 22
// 	9'b0_0010_0001, // C => 21
// 	9'b0_0010_1010  // V => 2A
// };

//assign shift_down = (key_down[SHIFT_CODES] == 1'b1) ? 1'b1 : 1'b0;  //new added!!!!!!!!!!!!!!!!!!
reg [16:0] next_pa;
//reg [4:0] state[15:0], next_state[15:0];

integer i;
reg [9:0] vo=10'd0, ho=10'd0;  //offset
reg [3:0] pos=4'd0;
//assign pass = {state[0], state[1], state[2], state[3], state[4], state[5], state[6], state[7], state[8], state[9],
//         state[10], state[11], state[12], state[13], state[14], state[15]} 
//         == 80'b00000_00001_00010_00011_00100_00101_00110_00111_01000_01001_01010_01011_01100_01101_01110_01111;

/*reg [2:0] hp1, next_hp1, hp2, next_hp2;
reg [9:0] pos1, next_pos1, pos2, next_pos2;
//reg [3:0] dir1, next_dir1, dir2, next_dir2;
reg [9:0] bupos1[0:9], next_bupos1[0:9], bupos2[0:9], next_bupos2[0:9];
reg [3:0] budir1[0:9], next_budir1[0:9], budir2[0:9], next_budir2[0:9];
reg [2:0] state[0:767], next_state[0:767];
parameter [2:0] map [0:767]={
    3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,  //0:wall, 1:ground, 2:red, 3:blue, 4:bullet
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd2,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd3,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd0,
    3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0
};*/

always@(posedge clk_2 or posedge rst) begin
    if(rst) begin
        pa<=0;
    end else begin
        pa<=next_pa;
    end
end

/*always@(posedge clk_22 or posedge rst) begin
    if(rst) begin
        for(i=0;i<768;i=i+1) state[i]<=map[i];
        for(i=0;i<10;i=i+1) begin
            bupos1[i]<=pos1+1-1;  //means NO bullet
            bupos2[i]<=pos1+1-1;
            budir1[i]<=0;  //means NO bullet
            budir2[i]<=0;
        end
        pos1<=46;  //32*1+14  //red  //2
        pos2<=721;  //32*22+17  //blue  //3
        //dir1<=0;
        //dir2<=0;
        hp1<=3;
        hp2<=3;

    end else begin
        for(i=0;i<768;i=i+1) state[i]<=next_state[i];
        for(i=0;i<10;i=i+1) begin
            bupos1[i]<=next_bupos1[i];
            bupos2[i]<=next_bupos2[i];
            budir1[i]<=next_budir1[i];
            budir2[i]<=next_budir2[i];
        end
        pos1<=next_pos1;
        pos2<=next_pos2;
        //dir1<=next_dir1;
        //dir2<=next_dir2;
        hp1<=next_hp1;
        hp2<=next_hp2;
    end
end*/

always@* begin
    next_pa = pa;
    next_pa = (h_cnt/20)+32*(v_cnt/20);  //if(state[pa]==2,3) ...  //+1?
end

/*always@* begin
    next_pos1=pos1;
    next_pos2=pos2;
    next_hp1=hp1;
    next_hp2=hp2;
    for(i=0;i<768;i=i+1) next_state[i]=state[i];
    for(i=0;i<10;i=i+1) begin
        next_bupos1[i]=bupos1[i];
        next_bupos2[i]=bupos2[i];
        next_budir1[i]=budir1[i];
        next_budir2[i]=budir2[i];
    end
    case(dir1)
        0: begin
            next_pos1=pos1;
        end
        1: begin
            if(state[pos1-1]==0) next_pos1=pos1;
            else next_pos1=pos1-1;
        end
        2: begin
            if(state[pos1-1-32]==0) next_pos1=pos1;
            else next_pos1=pos1-1-32;
        end
        3: begin
            if(state[pos1-32]==0) next_pos1=pos1;
            else next_pos1=pos1-32;
        end
        4: begin
            if(state[pos1-32+1]==0) next_pos1=pos1;
            else next_pos1=pos1-32+1;
        end
        5: begin
            if(state[pos1+1]==0) next_pos1=pos1;
            else next_pos1=pos1+1;
        end
        6: begin
            if(state[pos1+32+1]==0) next_pos1=pos1;
            else next_pos1=pos1+32+1;
        end
        7: begin
            if(state[pos1+32]==0) next_pos1=pos1;
            else next_pos1=pos1+32;
        end
        8: begin
            if(state[pos1+32-1]==0) next_pos1=pos1;
            else next_pos1=pos1+32-1;
        end
        default: begin
            next_pos1=pos1;
        end
    endcase
    case(dir2)
        0: begin
            next_pos2=pos2;
        end
        1: begin
            if(state[pos2-1]==0) next_pos2=pos2;
            else next_pos2=pos2-1;
        end
        2: begin
            if(state[pos2-1-32]==0) next_pos2=pos2;
            else next_pos2=pos2-1-32;
        end
        3: begin
            if(state[pos2-32]==0) next_pos2=pos2;
            else next_pos2=pos2-32;
        end
        4: begin
            if(state[pos2-32+1]==0) next_pos2=pos2;
            else next_pos2=pos2-32+1;
        end
        5: begin
            if(state[pos2+1]==0) next_pos2=pos2;
            else next_pos2=pos2+1;
        end
        6: begin
            if(state[pos2+32+1]==0) next_pos2=pos2;
            else next_pos2=pos2+32+1;
        end
        7: begin
            if(state[pos2+32]==0) next_pos2=pos2;
            else next_pos2=pos2+32;
        end
        8: begin
            if(state[pos2+32-1]==0) next_pos2=pos2;
            else next_pos2=pos2+32-1;
        end
        default: begin
            next_pos2=pos2;
        end
    endcase
    next_state[pos1]=1;  //ground
    next_state[pos2]=1;  //ground
    next_state[next_pos1]=2;  //red
    next_state[next_pos2]=3;  //blue
end*/

endmodule