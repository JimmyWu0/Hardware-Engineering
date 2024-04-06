`timescale 1ns / 1ps

module Top(
    input CLK,					// 100Mhz onboard clock
    input RST,					// Button D
    input MISO,					// Master In Slave Out, Pin 3, Port JA
    input [2:0] SW,			// Switches 2, 1, and 0
    output wire SS,					// Slave Select, Pin 1, Port JA
    output wire MOSI,				// Master Out Slave In, Pin 2, Port JA
    output wire SCLK,				// Serial Clock, Pin 4, Port JA
    output reg [15:0] LED,			// LEDs 2, 1, and 0
    output wire [3:0] AN,			// Anodes for Seven Segment Display
    output wire [6:0] SEG,			// Cathodes for Seven Segment Display
    output reg [3:0] mode,
    output wire pressed
    );
    
    wire [9:0] xData, yData; 
    reg [1:0] xDir, yDir;
    reg [1:0] xDirPrev, yDirPrev;
    reg pulse;

    parameter idle = 4'b0000;
    parameter left = 4'b0001;
    parameter leftUp = 4'b0010;
    parameter up = 4'b0011;
    parameter rightUp = 4'b0100;
    parameter right = 4'b0101;
    parameter rightDown = 4'b0110;
    parameter down = 4'b0111;
    parameter leftDown = 4'b1000;
    

    // Holds data to be sent to PmodJSTK
    wire [7:0] sndData;

    // Signal to send/receive data to/from PmodJSTK
    wire sndRec;

    // Data read from PmodJSTK
    wire [39:0] jstkData;

    // Signal carrying output data that user selected
    wire [9:0] posData;

    PmodJSTK PmodJSTK_Int(
        .CLK(CLK),
        .RST(RST),
        .sndRec(sndRec),
        .DIN(sndData),
        .MISO(MISO),
        .SS(SS),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .DOUT(jstkData)
    );

    ssdCtrl DispCtrl(
        .CLK(CLK),
        .RST(RST),
        .DIN(posData),
        .AN(AN),
        .SEG(SEG)
    );

    ClkDiv_5Hz genSndRec(
        .CLK(CLK),
        .RST(RST),
        .CLKOUT(sndRec)
    );

    assign pressed = jstkData[0];

    // Use state of switch 0 to select output of X position or Y position data to SSD
    assign posData = (SW[0] == 1'b1) ? {jstkData[9:8], jstkData[23:16]} : {jstkData[25:24], jstkData[39:32]};

    // Data to be sent to PmodJSTK, lower two bits will turn on leds on PmodJSTK
    assign sndData = {8'b100000, {SW[1], SW[2]}};

    // Assign PmodJSTK button status to LED[2:0]
//    always @(sndRec or RST or jstkData) begin
//        if(RST == 1'b1) begin
//            LED[2:0] <= 3'b000;
//        end
//        else begin
//            LED[2:0] <= {jstkData[1], {jstkData[2], jstkData[0]}};
//        end
//    end  

    assign xData = {jstkData[9:8], jstkData[23:16]}; 
    assign yData = {jstkData[25:24], jstkData[39:32]};

    always @(xData, yData) begin
        if(rst) begin
            xDir <= 2'b00;
            yDir <= 2'b00;
            xDirPrev <= 2'b00;
            yDirPrev <= 2'b00;
            pulse <= 1'b0;
        end
        else begin
            // Update previous values
            xDirPrev <= xDir;
            yDirPrev <= yDir;

            if(xData <= 10'd350 && xData >= 10'd0) begin //left
                xDir = 2'b01;
            end else if (xData <= 10'd1023 && xData >= 10'd650) begin//right
                xDir = 2'b10;
            end else begin
                xDir = 2'b00;
            end

            if(yData <= 10'd350 && yData >= 10'd0) begin //up
                yDir = 2'b01;
            end else if (yData <= 10'd1023 && yData >= 10'd650) begin//down
                yDir = 2'b10;
            end else begin
                yDir = 2'b00;
            end

            if ((xDir != xDirPrev) || (yDir != yDirPrev)) begin
                pulse <= 1'b1;
            end else begin
                pulse <= 1'b0;
        end
        end
    end

    always @(*) begin
        if(pulse) begin
            case({xDir, yDir})
                4'b0000 : mode = idle;
                4'b0100 : mode = left;
                4'b0101 : mode = leftUp;
                4'b0001 : mode = up;
                4'b1001 : mode = rightUp;
                4'b1000 : mode = right;
                4'b1010 : mode = rightDown;
                4'b0010 : mode = down;
                4'b0110 : mode = leftDown;
                default : mode = idle;
            endcase
        end
        else
            mode <= mode;
    end

endmodule

//JOYSTICK CODE BELOW//

module PmodJSTK (
    input CLK,						// 100MHz onboard clock
    input RST,						// Reset
    input sndRec,					// Send receive, initializes data read/write
    input [7:0] DIN,				// Data that is to be sent to the slave
    input MISO,						// Master in slave out
    output SS,						// Slave select, active low
    output SCLK,					// Serial clock
    output MOSI,					// Master out slave in
    output [39:0] DOUT			// All data read from the slave
);
    
    // Output wires and registers
//    wire SS;
//    wire SCLK;
//    wire MOSI;
//    wire [39:0] DOUT;

    wire getByte;									// Initiates a data byte transfer in SPI_Int
    wire [7:0] sndData;							// Data to be sent to Slave
    wire [7:0] RxData;							// Output data from SPI_Int
    wire BUSY;										// Handshake from SPI_Int to SPI_Ctrl
    

    // 66.67kHz Clock Divider, period 15us
    wire iSCLK;										// Internal serial clock,
                                                        // not directly output to slave,
                                                        // controls state machine, etc.

    spiCtrl SPI_Ctrl(
        .CLK(iSCLK),
        .RST(RST),
        .sndRec(sndRec),
        .BUSY(BUSY),
        .DIN(DIN),
        .RxData(RxData),
        .SS(SS),
        .getByte(getByte),
        .sndData(sndData),
        .DOUT(DOUT)
    );

    spiMode0 SPI_Int(
        .CLK(iSCLK),
        .RST(RST),
        .sndRec(getByte),
        .DIN(sndData),
        .MISO(MISO),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .BUSY(BUSY),
        .DOUT(RxData)
    );

    ClkDiv_66_67kHz SerialClock(
        .CLK(CLK),
        .RST(RST),
        .CLKOUT(iSCLK)
    );

endmodule

module spiCtrl (
    input CLK,						// 66.67kHz onboard clock
    input RST,						// Reset
    input sndRec,					// Send receive, initializes data read/write
    input BUSY, 					// If active data transfer currently in progress
    input [7:0] DIN,				// Data that is to be sent to the slave
    input [7:0] RxData,			// Last data byte received
    output reg SS,						// Slave select, active low
    output reg getByte,				// Initiates a data transfer in SPI_Int
    output reg [7:0] sndData,		// Data that is to be sent to the slave
    output reg [39:0] DOUT  		// All data read from the slave
);

    // Output wires and registers
//    reg SS = 1'b1;
//    reg getByte = 1'b0;
//    reg [7:0] sndData = 8'h00;
//    reg [39:0] DOUT = 40'h0000000000;

    // FSM States
    parameter [2:0] Idle = 3'd0,
                            Init = 3'd1,
                            Wait = 3'd2,
                            Check = 3'd3,
                            Done = 3'd4;
    
    // Present State
    reg [2:0] pState = Idle;

    reg [2:0] byteCnt = 3'd0;					// Number bits read/written
    parameter byteEndVal = 3'd5;				// Number of bytes to send/receive
    reg [39:0] tmpSR = 40'h0000000000;		// Temporary shift register to
                                                        // accumulate all five data bytes

    always @(negedge CLK) begin
        if(RST == 1'b1) begin
            // Reest everything
            SS <= 1'b1;
            getByte <= 1'b0;
            sndData <= 8'h00;
            tmpSR <= 40'h0000000000;
            DOUT <= 40'h0000000000;
            byteCnt <= 3'd0;
            pState <= Idle;
        end
        else begin
                
            case(pState)

                // Idle
                Idle : begin

                    SS <= 1'b1;								// Disable slave
                    getByte <= 1'b0;						// Do not request data
                    sndData <= 8'h00;						// Clear data to be sent
                    tmpSR <= 40'h0000000000;			// Clear temporary data
                    DOUT <= DOUT;							// Retain output data
                    byteCnt <= 3'd0;						// Clear byte count

                    // When send receive signal received begin data transmission
                    if(sndRec == 1'b1) begin
                        pState <= Init;
                    end
                    else begin
                        pState <= Idle;
                    end
                        
                end

                // Init
                Init : begin
                
                    SS <= 1'b0;								// Enable slave
                    getByte <= 1'b1;						// Initialize data transfer
                    sndData <= DIN;						// Store input data to be sent
                    tmpSR <= tmpSR;						// Retain temporary data
                    DOUT <= DOUT;							// Retain output data
                    
                    if(BUSY == 1'b1) begin
                            pState <= Wait;
                            byteCnt <= byteCnt + 1'b1;	// Count
                    end
                    else begin
                            pState <= Init;
                    end
                        
                end

                // Wait
                Wait : begin

                    SS <= 1'b0;								// Enable slave
                    getByte <= 1'b0;						// Data request already in progress
                    sndData <= sndData;					// Retain input data to send
                    tmpSR <= tmpSR;						// Retain temporary data
                    DOUT <= DOUT;							// Retain output data
                    byteCnt <= byteCnt;					// Count
                    
                    // Finished reading byte so grab data
                    if(BUSY == 1'b0) begin
                            pState <= Check;
                    end
                    // Data transmission is not finished
                    else begin
                            pState <= Wait;
                    end

                end

                // Check
                Check : begin

                    SS <= 1'b0;								// Enable slave
                    getByte <= 1'b0;						// Do not request data
                    sndData <= sndData;					// Retain input data to send
                    tmpSR <= {tmpSR[31:0], RxData};	// Store byte just read
                    DOUT <= DOUT;							// Retain output data
                    byteCnt <= byteCnt;					// Do not count

                    // Finished reading bytes so done
                    if(byteCnt == 3'd5) begin
                            pState <= Done;
                    end
                    // Have not sent/received enough bytes
                    else begin
                            pState <= Init;
                    end
                end

                // Done
                Done : begin

                    SS <= 1'b1;							// Disable slave
                    getByte <= 1'b0;					// Do not request data
                    sndData <= 8'h00;					// Clear input
                    tmpSR <= tmpSR;					// Retain temporary data
                    DOUT[39:0] <= tmpSR[39:0];		// Update output data
                    byteCnt <= byteCnt;				// Do not count
                    
                    // Wait for external sndRec signal to be de-asserted
                    if(sndRec == 1'b0) begin
                            pState <= Idle;
                    end
                    else begin
                            pState <= Done;
                    end

                end

                // Default State
                default : pState <= Idle;
            endcase
        end
	end

endmodule

module spiMode0 (
    input CLK,						// 66.67kHz serial clock
    input RST,						// Reset
    input sndRec,					// Send receive, initializes data read/write
    input [7:0] DIN,				// Byte that is to be sent to the slave
    input MISO,						// Master input slave output
    output MOSI,					// Master out slave in
    output SCLK,					// Serial clock
    output reg BUSY,					// Busy if sending/receiving data
    output [7:0] DOUT			// Current data byte read from the slave
);
//    wire MOSI;
//    wire SCLK;
//    wire [7:0] DOUT;
//    reg BUSY;

    // FSM States
    parameter [1:0] Idle = 2'd0,
                            Init = 2'd1,
                            RxTx = 2'd2,
                            Done = 2'd3;

    reg [4:0] bitCount;							// Number bits read/written
    reg [7:0] rSR = 8'h00;						// Read shift register
    reg [7:0] wSR = 8'h00;						// Write shift register
    reg [1:0] pState = Idle;					// Present state

    reg CE = 0;										// Clock enable, controls serial
                                                        // clock signal sent to slave

    // Serial clock output, allow if clock enable asserted
    assign SCLK = (CE == 1'b1) ? CLK : 1'b0;
    // Master out slave in, value always stored in MSB of write shift register
    assign MOSI = wSR[7];
    // Connect data output bus to read shift register
    assign DOUT = rSR;

    //-------------------------------------
    //			 Write Shift Register
    // 	slave reads on rising edges,
    // change output data on falling edges
    //-------------------------------------
    always @(negedge CLK) begin
        if(RST == 1'b1) begin
            wSR <= 8'h00;
        end
        else begin
            // Enable shift during RxTx state only
            case(pState)
                Idle : begin
                    wSR <= DIN;
                end
                
                Init : begin
                    wSR <= wSR;
                end
                
                RxTx : begin
                    if(CE == 1'b1) begin
                        wSR <= {wSR[6:0], 1'b0};
                    end
                end
                
                Done : begin
                    wSR <= wSR;
                end
            endcase
    end
end




//-------------------------------------
//			 Read Shift Register
// 	master reads on rising edges,
// slave changes data on falling edges
//-------------------------------------
always @(posedge CLK) begin
        if(RST == 1'b1) begin
            rSR <= 8'h00;
        end
        else begin
            // Enable shift during RxTx state only
            case(pState)
                Idle : begin
                    rSR <= rSR;
                end
                
                Init : begin
                    rSR <= rSR;
                end
                
                RxTx : begin
                    if(CE == 1'b1) begin
                            rSR <= {rSR[6:0], MISO};
                    end
                end
                
                Done : begin
                    rSR <= rSR;
                end
            endcase
        end
end




//------------------------------
//		   SPI Mode 0 FSM
//------------------------------
always @(negedge CLK) begin

        // Reset button pressed
        if(RST == 1'b1) begin
            CE <= 1'b0;				// Disable serial clock
            BUSY <= 1'b0;			// Not busy in Idle state
            bitCount <= 4'h0;		// Clear #bits read/written
            pState <= Idle;		// Go back to Idle state
        end
        else begin
                
            case (pState)
            
                // Idle
                Idle : begin

                    CE <= 1'b0;				// Disable serial clock
                    BUSY <= 1'b0;			// Not busy in Idle state
                    bitCount <= 4'd0;		// Clear #bits read/written
                    

                    // When send receive signal received begin data transmission
                    if(sndRec == 1'b1) begin
                        pState <= Init;
                    end
                    else begin
                        pState <= Idle;
                    end
                        
                end

                // Init
                Init : begin
                
                    BUSY <= 1'b1;			// Output a busy signal
                    bitCount <= 4'h0;		// Have not read/written anything yet
                    CE <= 1'b0;				// Disable serial clock
                    
                    pState <= RxTx;		// Next state receive transmit
                        
                end

                // RxTx
                RxTx : begin

                    BUSY <= 1'b1;						// Output busy signal
                    bitCount <= bitCount + 1'b1;	// Begin counting bits received/written
                    
                    // Have written all bits to slave so prevent another falling edge
                    if(bitCount >= 4'd8) begin
                            CE <= 1'b0;
                    end
                    // Have not written all data, normal operation
                    else begin
                            CE <= 1'b1;
                    end
                    
                    // Read last bit so data transmission is finished
                    if(bitCount == 4'd8) begin
                            pState <= Done;
                    end
                    // Data transmission is not finished
                    else begin
                            pState <= RxTx;
                    end

                end

                // Done
                Done : begin

                    CE <= 1'b0;			// Disable serial clock
                    BUSY <= 1'b1;		// Still busy
                    bitCount <= 4'd0;	// Clear #bits read/written
                    
                    pState <= Idle;

                end

                // Default State
                default : pState <= Idle;
                
            endcase
        end
    end

endmodule

module ClkDiv_5Hz (
    input CLK,
	input RST,
	output reg CLKOUT
);
	
	// Value to toggle output clock at
	parameter cntEndVal = 24'h989680;
	// Current count
	reg [23:0] clkCount = 24'h000000;
	
    always @(posedge CLK) begin

        // Reset clock
        if(RST == 1'b1) begin
            CLKOUT <= 1'b0;
            clkCount <= 24'h000000;
        end
        else begin

            if(clkCount == cntEndVal) begin
                CLKOUT <= ~CLKOUT;
                clkCount <= 24'h000000;
            end
            else begin
                clkCount <= clkCount + 1'b1;
            end

        end

	end

endmodule

module ClkDiv_66_67kHz (
    input CLK,
	input RST,
	output reg CLKOUT
);
    
    // Value to toggle output clock at
	parameter cntEndVal = 10'b1011101110;
	// Current count
	reg [9:0] clkCount = 10'b0000000000;

    always @(posedge CLK) begin

        // Reset clock
        if(RST == 1'b1) begin
            CLKOUT <= 1'b0;
            clkCount <= 10'b0000000000;
        end
        // Count/toggle normally
        else begin

            if(clkCount == cntEndVal) begin
                CLKOUT <= ~CLKOUT;
                clkCount <= 10'b0000000000;
            end
            else begin
                clkCount <= clkCount + 1'b1;
            end

        end

	end

endmodule

module ssdCtrl (
    input CLK,						// 100Mhz clock
    input RST,						// Reset
    input [9:0] DIN,				// Input data to display
    output reg [3:0] AN,				// Anodes for seven segment display
    output reg [6:0] SEG				// Cathodes for seven segment display
);
    
    // Outputs to Seven Segment Display
//    reg [3:0] AN = 4'hF;
//    reg [6:0] SEG = 7'b0000000;

    // 1 kHz Clock Divider
    parameter cntEndVal = 16'hC350;
    reg [15:0] clkCount = 16'h0000;
    reg DCLK;

    // 2 Bit Counter
    reg [1:0] CNT = 2'b00;

    // Binary to BCD
    wire [15:0] bcdData;

    // Output Data Mux
    reg [3:0] muxData;

    Binary_To_BCD BtoBCD(
        .CLK(CLK),
        .RST(RST),
        .START(DCLK),
        .BIN(DIN),
        .BCDOUT(bcdData)
    );

    always @(CNT[1], CNT[0], bcdData, RST) begin
        if(RST == 1'b1) begin
            muxData <= 4'b0000;
        end
        else begin
            case (CNT)
                2'b00 : muxData <= bcdData[3:0];
                2'b01 : muxData <= bcdData[7:4];
                2'b10 : muxData <= bcdData[11:8];
                2'b11 : muxData <= bcdData[15:12];
            endcase
        end
    end    


    always @(posedge DCLK) begin
        if(RST == 1'b1) begin
            SEG <= 7'b1000000;
        end
        else begin
            case (muxData)

                4'h0 : SEG <= 7'b1000000;  // 0
                4'h1 : SEG <= 7'b1111001;  // 1
                4'h2 : SEG <= 7'b0100100;  // 2
                4'h3 : SEG <= 7'b0110000;  // 3
                4'h4 : SEG <= 7'b0011001;  // 4
                4'h5 : SEG <= 7'b0010010;  // 5
                4'h6 : SEG <= 7'b0000010;  // 6
                4'h7 : SEG <= 7'b1111000;  // 7
                4'h8 : SEG <= 7'b0000000;  // 8
                4'h9 : SEG <= 7'b0010000;  // 9
                default : SEG <= 7'b1000000;
                    
            endcase
        end
    end

    always @(posedge DCLK) begin
        if(RST == 1'b1) begin
            AN <= 4'b0000;
        end
        else begin
            case (CNT)

                4'h0 : AN <= 7'b1110;  // 0
                4'h1 : AN <= 7'b1101;  // 1
                4'h2 : AN <= 7'b1011;  // 2
                4'h3 : AN <= 7'b0111;  // 3
                default : AN <= 4'b1111;
                    
            endcase
        end
    end	

    always @(posedge DCLK) begin
        CNT <= CNT + 1'b1;
    end

    always @(posedge CLK) begin
        if(clkCount == cntEndVal) begin
            DCLK <= 1'b1;
            clkCount <= 16'h0000;
        end
        else begin
            DCLK <= 1'b0;
            clkCount <= clkCount + 1'b1;
        end
    end

endmodule

module Binary_To_BCD (
    input CLK,						// 100Mhz CLK
    input RST,						// Reset
    input START,					// Signal to initialize conversion
    input [9:0] BIN,				// Binary value to be converted
    output reg [15:0] BCDOUT		// 4 digit binary coded decimal output
);
    
     // FSM States
    parameter [2:0] Idle = 3'b000,
                    Init = 3'b001,
                    Shift = 3'b011,
                    Check = 3'b010,
                    Done = 3'b110;
                    
    //reg [15:0] BCDOUT = 16'h0000;		// Output BCD values, contains 4 digits
			
    reg [4:0] shiftCount = 5'b00000;	// Stores number of shifts executed
    reg [27:0] tmpSR;						// Temporary shift regsiter

    reg [2:0] STATE = Idle;				// Present state
    

    always @(posedge CLK) begin
        if(RST == 1'b1) begin
            // Reset/clear values
            BCDOUT <= 16'h0000;
            tmpSR <= 28'h0000000;
            STATE <= Idle;
        end
        else begin
        case (STATE)
        
                // Idle State
                Idle : begin
                    BCDOUT <= BCDOUT;								 	// Output does not change
                    tmpSR <= 28'h0000000;							// Temp shift reg empty
                    
                    if(START == 1'b1) begin
                        STATE <= Init;
                    end
                    else begin
                        STATE <= Idle;
                    end
                end

                // Init State
                Init : begin
                    BCDOUT <= BCDOUT;									// Output does not change
                    tmpSR <= {18'b000000000000000000, BIN};	// Copy input to lower 10 bits

                    STATE <= Shift;
                end

                // Shift State
                Shift : begin
                    BCDOUT <= BCDOUT;							// Output does not change
                    tmpSR <= {tmpSR[26:0], 1'b0};			// Shift left 1 bit

                    shiftCount <= shiftCount + 1'b1;		// Count the shift
                    
                    STATE <= Check;							// Check digits

                end

                // Check State
                Check : begin
                    BCDOUT <= BCDOUT;							// Output does not change

                    // Not done converting
                    if(shiftCount != 5'd12) begin

                        // Add 3 to thousands place
                        if(tmpSR[27:24] >= 3'd5) begin
                            tmpSR[27:24] <= tmpSR[27:24] + 2'd3;
                        end

                        // Add 3 to hundreds place
                        if(tmpSR[23:20] >= 3'd5) begin
                            tmpSR[23:20] <= tmpSR[23:20] + 2'd3;
                        end
                        
                        // Add 3 to tens place
                        if(tmpSR[19:16] >= 3'd5) begin
                            tmpSR[19:16] <= tmpSR[19:16] + 2'd3;
                        end
                        
                        // Add 3 to ones place
                        if(tmpSR[15:12] >= 3'd5) begin
                            tmpSR[15:12] <= tmpSR[15:12] + 2'd3;
                        end

                        STATE <= Shift;	// Shift again

                    end
                    // Done converting
                    else begin
                            STATE <= Done;
                    end
                        
                end
                            
                // Done State
                Done : begin

                    BCDOUT <= tmpSR[27:12];	// Assign output the new BCD values
                    tmpSR <= 28'h0000000;	// Clear temp shift register
                    shiftCount <= 5'b00000; // Clear shift count

                    STATE <= Idle;
                end
            endcase
        end
    end

endmodule