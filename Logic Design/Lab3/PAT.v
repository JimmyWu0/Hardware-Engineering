module PAT(clk, reset, data, flag);
	
	input clk, reset, data;
	output reg flag;  //reg

	reg [4-1:0] state;
	reg [4-1:0] next_state;

	always@(*)begin
		if(reset)
			next_state=4'b0000;
		else begin
			if(state==4'b0000)begin
				if(data==1'b0)
					next_state=4'b0001;
				else
					next_state=state;
			end
			else if(state==4'b0001)begin
				if(data==1'b0)
					next_state=state;
				else
					next_state=4'b0010;
			end
			else if(state==4'b0010)begin
                                if(data==1'b0)
                                        next_state=4'b0011;
                                else
                                        next_state=4'b0000;
                        end
			else if(state==4'b0011)begin
                                if(data==1'b0)
                                        next_state=4'b0001;
                                else
                                        next_state=4'b0100;
                        end
			else if(state==4'b0100)begin
                                if(data==1'b0)
                                        next_state=4'b0101;
                                else
                                        next_state=4'b0000;
                        end
			else if(state==4'b101)begin
                                if(data==1'b0)
                                        next_state=4'b0001;
                                else
                                        next_state=4'b0110;
                        end
                        else if(state==4'b0110)begin
                                if(data==1'b0)
                                        next_state=4'b0101;
                                else
                                        next_state=4'b0111;
                        end
			else if(state==4'b0111)begin
                                if(data==1'b0)
                                        next_state=4'b1000;
                                else
                                        next_state=4'b1010;  //4'b0000
                        end
			else if(state==4'b1000)begin
                                if(data==1'b0)
                                        next_state=4'b0001;
                                else
                                        next_state=4'b1001;
                        end
                        else if(state==4'b1001)begin
                                if(data==1'b0)
                                        next_state=4'b0011;
                                else
                                        next_state=4'b0111;
                        end
			else if(state==4'b1010)begin
                                if(data==1'b0)
                                        next_state=4'b0001;
                                else
                                        next_state=4'b0000;
                        end
		end
	end

	/*always@(posedge clk)begin
		if(reset)
			state<=3'b000;
		else
			state<=next_state;
	end*/

	//assign flag=(state==3'b111);

	//remember to set flag as reg

	always@(*)begin
		if(reset)
			flag=1'b0;
		else begin
			if(state==4'b1010)begin  //4'b0111
				if(data==1'b1)
					flag=1'b1;
				else
					flag=1'b1;  //0
			end
			else
				flag=1'b0;
		end
	end

	always@(posedge clk)begin  //posedge reset
                if(reset)
                        state<=4'b0000;
                else
                        state<=next_state;
        end

endmodule
