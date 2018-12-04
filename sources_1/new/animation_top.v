// Listing 13.6
module animation_top
   (
    input wire clk, reset,
   input wire ps2c, ps2d,
   output wire hsync, vsync,
   output wire [11:0] rgb,
   output wire audioOut,
   output wire aud_sd
   );

   // signal declaration
   wire clk_50MHz;
   wire [9:0] pixel_x, pixel_y;
   wire video_on, pixel_tick;
   reg [11:0] rgb_reg;
   wire [11:0] rgb_next;
   wire [3:0] dropper;
   wire win;

    slowerClkGen clock(clk, clk_50MHz);
    kb_to_btn kbtobtnUnit(.clk(clk_50MHz), .reset(reset), .ps2d(ps2d), .ps2c(ps2c), .dropper(dropper));
    SongPlayer songUnit(.clock(clk), .reset(reset), .win(win), .audioOut(audioOut), .aud_sd(aud_sd));
   // instantiate vga sync circuit
   vga_sync vsync_unit
      (.clk(clk_50MHz), .reset(reset), .hsync(hsync), .vsync(vsync),
       .video_on(video_on), .p_tick(pixel_tick),
       .pixel_x(pixel_x), .pixel_y(pixel_y));

   // instantiate graphic generator
   graph_animate_level1 graph_an_unit
      (.clk(clk_50MHz), .reset(reset),
       .video_on(video_on), .pix_x(pixel_x),
       .pix_y(pixel_y), .dropper(dropper), .graph_rgb(rgb_next), .win(win));

   // rgb buffer
   always @(posedge clk)
      if (pixel_tick)
         rgb_reg <= rgb_next;
   // output
   assign rgb = rgb_reg;

endmodule
