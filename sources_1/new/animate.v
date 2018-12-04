// Listing 13.5
module graph_animate_level1
   (
    input wire clk, reset,
    input wire video_on,
    input wire [9:0] pix_x, pix_y,
    input wire [3:0] dropper,
    output reg [11:0] graph_rgb,
    output reg win
   );


   // constant and signal declaration
   // x, y coordinates (0,0) to (639,479)
   localparam MAX_X = 640;
   localparam MAX_Y = 480;
   wire refr_tick;
   
   //FLOOR
   localparam FLOOR_Y_T = 450;
   localparam FLOOR_Y_B = 480;
  
   
   //--------------------------------------------
   // BOXES
   //--------------------------------------------
   reg box1, box2, box3, box4, box5;
   reg clear, over1, over2, over3, over4;
   wire [2:0] box_count;
   wire game_over, game_clear;
   assign game_over = over1 | over2 | over3 | over4;
   assign game_clear = clear;
   assign box_count = box1 + box2 + box3 + box4 + box5;
   
      
   // box top, bottom, left, right boundary
   wire [9:0] box_y_t, box_y_b, box2_y_t, box2_y_b, box3_y_t, box3_y_b, box4_y_t, box4_y_b, box5_y_t, box5_y_b;
   wire [9:0] box_x_l, box_x_r, box2_x_l, box2_x_r, box3_x_l, box3_x_r, box4_x_l, box4_x_r, box5_x_l, box5_x_r;
   localparam BOX_SIZE = 72;
   localparam BOX2_SIZE = 60; 
   localparam BOX3_SIZE = 48;
   localparam BOX4_SIZE = 36;
   localparam BOX5_SIZE = 24;
   // register to track side boundary  (y position is fixed)
   reg [9:0] box_x_reg, box_y_reg, box2_x_reg, box2_y_reg, box3_x_reg, box3_y_reg, box4_x_reg, box4_y_reg, box5_x_reg, box5_y_reg;
   wire [9:0] box_x_next, box_y_next, box2_x_next, box2_y_next, box3_x_next, box3_y_next, box4_x_next, box4_y_next, box5_x_next, box5_y_next;

   // track box speed
   reg [9:0] x_delta_reg, x_delta_next, x2_delta_reg, x2_delta_next, x3_delta_reg, x3_delta_next, x4_delta_reg, x4_delta_next, x5_delta_reg, x5_delta_next;
   reg [9:0] y_delta_reg, y_delta_next, y2_delta_reg, y2_delta_next, y3_delta_reg, y3_delta_next, y4_delta_reg, y4_delta_next, y5_delta_reg, y5_delta_next;
   // ball velocity can be pos or neg)
   localparam BOX_V_R = 2;
   localparam BOX_V_L = -2;
   localparam BOX2_V_R = 3;
   localparam BOX2_V_L = -3;
   localparam BOX3_V_R = 4;
   localparam BOX3_V_L = -4;
   localparam BOX4_V_R = 5;
   localparam BOX4_V_L = -5;
   localparam BOX5_V_R = 6;
   localparam BOX5_V_L = -6;
   
   
   localparam BOX_DROP = 3;
   
   
   //--------------------------------------------
   // object output signals
   //--------------------------------------------
   wire box_on, sq_box_on, floor_on, box2_on, box3_on, box4_on, box5_on;
   wire [11:0] box_rgb, box2_rgb, box3_rgb, box4_rgb, box5_rgb, floor_rgb;
   
   
//FLOOR
assign floor_on = (FLOOR_Y_T<=pix_y) && (pix_y<=FLOOR_Y_B);
assign floor_rgb = 12'b1100_0011_0000;
 
  
   // registers
   always @(posedge clk, posedge reset)
      if (reset)
         begin  
            box_x_reg <= 0;
            box2_x_reg <= 0;
            box3_x_reg <= 0;
            box4_x_reg <= 0;
            box5_x_reg <= 0;
            box_y_reg <=  0;
            box2_y_reg <= 0;
            box3_y_reg <= 0;
            box4_y_reg <= 0;
            box5_y_reg <= 0;
            x_delta_reg <= 10'h004;
            x2_delta_reg <= 10'h004;
            x3_delta_reg <= 10'h004;
            x4_delta_reg <= 10'h004;
            x5_delta_reg <= 10'h004;
            y_delta_reg <= 10'h004;
            y2_delta_reg <= 10'h004;
            y3_delta_reg <= 10'h004;
            y4_delta_reg <= 10'h004;
            y5_delta_reg <= 10'h004;
         end  
      else
         begin
            box_x_reg <= box_x_next;
            box2_x_reg <= box2_x_next;
            box3_x_reg <= box3_x_next;
            box4_x_reg <= box4_x_next;
            box5_x_reg <= box5_x_next;
            box_y_reg <= box_y_next;
            box2_y_reg <= box2_y_next;
            box3_y_reg <= box3_y_next;
            box4_y_reg <= box4_y_next;
            box5_y_reg <= box5_y_next;
            x_delta_reg <= x_delta_next;
            x2_delta_reg <= x2_delta_next;
            x3_delta_reg <= x3_delta_next;
            x4_delta_reg <= x4_delta_next;
            x5_delta_reg <= x5_delta_next;
            y_delta_reg <= y_delta_next;
            y2_delta_reg <= y2_delta_next;
            y3_delta_reg <= y3_delta_next;
            y4_delta_reg <= y4_delta_next;
            y5_delta_reg <= y5_delta_next;
         end


   // refr_tick: 1-clock tick asserted at start of v-sync
   //            i.e., when the screen is refreshed (60 Hz)
   assign refr_tick = (pix_y==481) && (pix_x==0);


//--------------------------------------------
// BOX1
//--------------------------------------------
   // boundary
   assign box_x_l = box_x_reg;
   assign box_y_t = box_y_reg;
   assign box_x_r = box_x_l + BOX_SIZE - 1;
   assign box_y_b = box_y_t + BOX_SIZE - 1;
   // pixel within box
   assign box_on =
            (box_x_l<=pix_x) && (pix_x<=box_x_r) &&
            (box_y_t<=pix_y) && (pix_y<=box_y_b);

   // box rgb output
   assign box_rgb = 12'b0000_0000_1111;   
   // box moving position
   assign box_x_next = (refr_tick & box_count == 0) ? box_x_reg+x_delta_reg : box_x_reg ;
   assign box_y_next = (refr_tick & box_count == 0) ? box_y_reg+y_delta_reg : box_y_reg ; 
  

   // original box velocity
   always @*
   begin  
      x_delta_next = x_delta_reg;  
      y_delta_next = y_delta_reg;   
      if(box_x_l < 1) //reach left side of screen
            begin
            x_delta_next = BOX_V_R; 
            y_delta_next = 0; 
            end
      else if (box_x_r > MAX_X-1) //reach right side of screen
            begin
            x_delta_next = BOX_V_L;
            y_delta_next = 0;
            end
      else if(dropper == 1)     //user presses SP, box will drop
            begin
            x_delta_next = 0;
            y_delta_next = BOX_DROP; 
            if((box_y_b >= FLOOR_Y_T))
                begin
                y_delta_next = 0;
                box1 = 1;
                end 
            end  

      end


//--------------------------------------------
// BOX2
//--------------------------------------------

assign box2_on =
              (box2_x_l<=pix_x) && (pix_x<=box2_x_r) &&
              (box2_y_t<=pix_y) && (pix_y<=box2_y_b);

assign box2_x_l = box2_x_reg;
assign box2_y_t = box2_y_reg;
assign box2_x_r = box2_x_l + BOX2_SIZE - 1;
assign box2_y_b = box2_y_t + BOX2_SIZE - 1;  
             
assign box2_rgb = 12'b0000_1111_1111;  
 
// box moving position
assign box2_x_next = (refr_tick & box_count == 1) ? box2_x_reg+x2_delta_reg : box2_x_reg ;
assign box2_y_next = (refr_tick & box_count == 1) ? box2_y_reg+y2_delta_reg : box2_y_reg ; 

//if first box drops, box 2 appears
always@*
begin 
    x2_delta_next = x2_delta_reg;  
    y2_delta_next = y2_delta_reg;

        if(box2_x_l < 1) //reach left side of screen
            begin
                x2_delta_next = BOX2_V_R; 
                y2_delta_next = 0; 
            end
        else if (box2_x_r > MAX_X-1) //reach right side of screen
            begin
                x2_delta_next = BOX2_V_L;
                y2_delta_next = 0;
            end
        else if(dropper == 2)     //user presses SP, box will drop
            begin
                x2_delta_next = 0;
                y2_delta_next = BOX_DROP;  
                if((box2_y_b >= FLOOR_Y_T))
                    begin   //SHOW GAME OVER TEXT
                    x2_delta_next = 0;
                    y2_delta_next = 0;
                    over1 = 1;
                    end 
                else if((box2_y_b >= 378) && (box2_x_r >= box_x_l) && (box2_x_l <= box_x_r))
                    begin //NEXT BOX APPEARS
                    x2_delta_next = 0;
                    y2_delta_next = 0;
                    box2 = 1;
                    end
            end
               
end

//--------------------------------------------
// BOX3
//--------------------------------------------

assign box3_on =
              (box3_x_l<=pix_x) && (pix_x<=box3_x_r) &&
              (box3_y_t<=pix_y) && (pix_y<=box3_y_b);


assign box3_x_l = box3_x_reg;
assign box3_y_t = box3_y_reg;
assign box3_x_r = box3_x_l + BOX3_SIZE - 1;
assign box3_y_b = box3_y_t + BOX3_SIZE - 1;  
             
assign box3_rgb = 12'b0000_1111_0000;   
// box moving position
assign box3_x_next = (refr_tick & box_count == 2) ? box3_x_reg+x3_delta_reg : box3_x_reg ;
assign box3_y_next = (refr_tick & box_count == 2) ? box3_y_reg+y3_delta_reg : box3_y_reg ; 


always@*
begin
    x3_delta_next = x3_delta_reg;  
    y3_delta_next = y3_delta_reg; 
        if(box3_x_l < 1) //reach left side of screen
            begin
                x3_delta_next = BOX3_V_R; 
                y3_delta_next = 0; 
            end
        else if (box3_x_r > MAX_X-1) //reach right side of screen
            begin
                x3_delta_next = BOX3_V_L;
                y3_delta_next = 0;
            end
        else if(dropper == 3)     //user presses SP, box will drop
            begin
                x3_delta_next = 0;
                y3_delta_next = BOX_DROP; 
                if((box3_y_b >= FLOOR_Y_T))
                    begin   //GAME OVER
                    x3_delta_next = 0;
                    y3_delta_next = 0;
                    over2 = 1;
                    end 
                else if((box3_y_b >= 318) && (box3_y_t >= 270) && (box3_x_r >= box2_x_l) && (box3_x_l <= box2_x_r))
                    begin //NEXT BOX APPEARS
                    x3_delta_next = 0;
                    y3_delta_next = 0;
                    box3 = 1;
                    end
            end
end

//--------------------------------------------
// BOX4
//--------------------------------------------
assign box4_on =
              (box4_x_l<=pix_x) && (pix_x<=box4_x_r) &&
              (box4_y_t<=pix_y) && (pix_y<=box4_y_b);


assign box4_x_l = box4_x_reg;
assign box4_y_t = box4_y_reg;
assign box4_x_r = box4_x_l + BOX4_SIZE - 1;
assign box4_y_b = box4_y_t + BOX4_SIZE - 1;  
             
assign box4_rgb = 12'b1111_1111_0000;   
// box moving position
assign box4_x_next = (refr_tick & box_count == 3) ? box4_x_reg+x4_delta_reg : box4_x_reg ;
assign box4_y_next = (refr_tick & box_count == 3) ? box4_y_reg+y4_delta_reg : box4_y_reg ; 


always@*
begin
    x4_delta_next = x4_delta_reg;  
    y4_delta_next = y4_delta_reg; 
        if(box4_x_l < 1) //reach left side of screen
            begin
                x4_delta_next = BOX4_V_R; 
                y4_delta_next = 0; 
            end
        else if (box4_x_r > MAX_X-1) //reach right side of screen
            begin
                x4_delta_next = BOX4_V_L;
                y4_delta_next = 0;
            end
        else if(dropper == 4)     //user presses SP, box will drop
            begin
                x4_delta_next = 0;
                y4_delta_next = BOX_DROP; 
                if((box4_y_b >= FLOOR_Y_T))
                    begin   //GAME OVER
                    x4_delta_next = 0;
                    y4_delta_next = 0;
                    over3 = 1;
                    end 
                else if((box4_y_b >= 270) && (box4_y_t >= 234) && (box4_x_r >= box3_x_l) && (box4_x_l <= box3_x_r))
                    begin //NEXT BOX APPEARS
                    x4_delta_next = 0;
                    y4_delta_next = 0;
                    box4 = 1;
                    end
            end
end

//--------------------------------------------
// BOX5
//--------------------------------------------
assign box5_on =
              (box5_x_l<=pix_x) && (pix_x<=box5_x_r) &&
              (box5_y_t<=pix_y) && (pix_y<=box5_y_b);


assign box5_x_l = box5_x_reg;
assign box5_y_t = box5_y_reg;
assign box5_x_r = box5_x_l + BOX5_SIZE - 1;
assign box5_y_b = box5_y_t + BOX5_SIZE - 1;  
                                
assign box5_rgb = 12'b1111_0000_0000;   
// box moving position
assign box5_x_next = (refr_tick & box_count == 4) ? box5_x_reg+x5_delta_reg : box5_x_reg ;
assign box5_y_next = (refr_tick & box_count == 4) ? box5_y_reg+y5_delta_reg : box5_y_reg ; 


always@*
begin
    x5_delta_next = x5_delta_reg;  
    y5_delta_next = y5_delta_reg; 
        if(box5_x_l < 1) //reach left side of screen
            begin
                x5_delta_next = BOX5_V_R; 
                y5_delta_next = 0; 
            end
        else if (box5_x_r > MAX_X-1) //reach right side of screen
            begin
                x5_delta_next = BOX5_V_L;
                y5_delta_next = 0;
            end
        else if(dropper == 5)     //user presses SP, box will drop
            begin
                x5_delta_next = 0;
                y5_delta_next = BOX_DROP; 
                if((box5_y_b >= FLOOR_Y_T))
                    begin   //GAME OVER
                    x5_delta_next = 0;
                    y5_delta_next = 0;
                    over4 = 1;
                    end 
                else if((box5_y_b >= 234) && (box5_y_t >= 210) && (box5_x_r >= box4_x_l) && (box5_x_l <= box4_x_r))
                    begin //NEXT BOX APPEARS
                    x5_delta_next = 0;
                    y5_delta_next = 0;
                    box5 = 1;
                    win = 1;
                    clear = 1;
                    end
            end
end


        
//TEXT GENERATION
wire [1:0] text_on;
wire[11:0] text_rgb;
wire [3:0] leveldig;

Level_text levelunit(.clk(clk), .leveldig(leveldig), .game_over(game_over), .game_clear(game_clear), .pix_x(pix_x), .pix_y(pix_y), .text_on(text_on), .text_rgb(text_rgb));



//Calculate level
reg [3:0] dig_reg, dig_next;

always@(*)
begin
if(reset)
    dig_reg <= 1;
else    
    dig_reg <= dig_next;
end

always@(*)
begin
    dig_next = dig_reg;
    if(box_count < 6)
        dig_next = 1;
    else
        dig_next = dig_reg + 1;
end

assign leveldig = dig_reg;
          
       
   //--------------------------------------------
   // rgb multiplexing circuit
   //--------------------------------------------
   always @*
      if (~video_on)
         graph_rgb = 12'b0000_0000_0000; // blank
      else
         if (box_on)
            graph_rgb = box_rgb; 
         else if(box2_on)
            graph_rgb = box2_rgb;
         else if (box3_on)
            graph_rgb = box3_rgb;
         else if (box4_on)
               graph_rgb = box4_rgb; 
         else if (box5_on)
                  graph_rgb = box5_rgb;
         else if (floor_on)
            graph_rgb = floor_rgb; 
         else if (text_on)
            graph_rgb = text_rgb; 
         else
            graph_rgb = 12'b0000_0000_0000; // background
    


endmodule
