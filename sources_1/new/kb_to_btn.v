
module kb_to_btn(
    input clk, reset, ps2d, ps2c,
    output wire [3:0] dropper
    );
    
    wire rx_done_tick;
    wire [7:0] dout;
    reg [1:0] state_reg, state_next;
    reg [3:0] dropper_next, dropper_reg;
   
    localparam SP = 8'h29;
    localparam [1:0] idle = 2'b00;
    localparam [1:0] drop = 2'b01;
    localparam [1:0] check = 2'b10;

    
        
     ps2_rx unit(.clk(clk), .reset(reset), .ps2d(ps2d), .ps2c(ps2c), .rx_en(1'b1),.rx_done_tick(rx_done_tick), .dout(dout));
    
    always@(posedge clk, posedge reset)
    begin
    if(reset)
        begin
            state_reg <= idle;
            dropper_reg <= 3'b000;
        end
    else
        begin
            state_reg <= state_next;
            dropper_reg <= dropper_next;
        end
    end    

    always@(*)
    begin
    state_next = state_reg;
    dropper_next = dropper_reg;
    case(state_reg)
        idle:
            begin
            if(rx_done_tick)
                begin
                if (dout == SP)
                    state_next = drop;
                end
            end
        drop:
            begin
            if(rx_done_tick)
                begin
                if(dout == 8'hF0)
                    state_next = check;  
                end          
            end
        check:
                begin
                if(rx_done_tick)
                    begin
                    if(dout == SP)
                        dropper_next = dropper_reg + 1;
                        state_next = idle;  
                    end          
                end
        endcase
    end
    
assign dropper = dropper_reg;   
          
endmodule
