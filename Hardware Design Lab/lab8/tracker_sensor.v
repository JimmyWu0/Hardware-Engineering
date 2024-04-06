`define front   3'd0
`define left    3'd1
`define right   3'd2
`define stop    3'd3
`define sleft   3'd4
`define sright  3'd5

module tracker_sensor(clk, reset, left_track, right_track, mid_track, state);
    input clk;
    input reset;
    input left_track, right_track, mid_track;
    output reg [2:0] state;

    // TODO: Receive three tracks and make your own policy.
    // Hint: You can use output state to change your action.
    always@(posedge clk or posedge reset) begin
        if(reset) begin
            state<=`stop;
        end else begin
            case({left_track, mid_track, right_track})
                3'b000: state<=state;  //probably won't happen
                3'b001: state<=`sleft;
                3'b010: state<=state;  //won't happen
                3'b011: state<=`left;
                3'b100: state<=`sright;
                3'b101: state<=`front;
                3'b110: state<=`right;
                3'b111: state<=`stop;  //or state
            endcase
        end
    end

endmodule
