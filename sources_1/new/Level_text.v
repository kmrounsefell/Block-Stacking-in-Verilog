// Listing 14.6
module Level_text
   (
    input wire clk, 
    input wire [3:0] leveldig,
    input wire game_over, game_clear,
    input wire [9:0] pix_x, pix_y,
    output wire [1:0] text_on,
    output reg [11:0] text_rgb
    );

   // signal declaration
   wire [10:0] rom_addr;
   reg [6:0] char_addr, char_addr_s, char_addr_o, char_addr_c;
   reg [3:0] row_addr;
   wire [3:0] row_addr_s, row_addr_o, row_addr_c;
   reg [2:0] bit_addr;
   wire [2:0] bit_addr_s, bit_addr_o, bit_addr_c;
   wire [7:0] font_word;
   wire font_bit, level_on, over_on, clear_on;
   wire [7:0] rule_rom_addr;
  

   // instantiate font ROM
   font_rom font_unit
      (.clk(clk), .addr(rom_addr), .data(font_word));

   //-------------------------------------------
   // score region
   //  - display two-digit score, ball on top left
   //  - scale to 16-by-32 font
   //  - line 1, 16 chars: "Score:DD Ball:D"
   //-------------------------------------------
   assign level_on = (pix_y[9:5]==0) && (pix_x[9:4]<16);
   assign row_addr_s = pix_y[4:1];
   assign bit_addr_s = pix_x[3:1];
   always @*
      case (pix_x[7:4])
         4'h0: char_addr_s = 7'h4c; // L
         4'h1: char_addr_s = 7'h45; // E
         4'h2: char_addr_s = 7'h56; // V
         4'h3: char_addr_s = 7'h45; // E
         4'h4: char_addr_s = 7'h4c; // L
         4'h5: char_addr_s = 7'h3a; // :
         4'h6: char_addr_s = {3'b011, leveldig}; // indicate what level
         default
         char_addr_s = 7'h00; 
      endcase
   
   //-------------------------------------------
   // game over region
   //  - display "Game Over" at center
   //  - scale to 32-by-64 fonts
   //-----------------------------------------
   
  
   assign over_on = (pix_y[9:6]==3) &&
                    (5<=pix_x[9:5]) && (pix_x[9:5]<=13);
   assign row_addr_o = pix_y[5:2];
   assign bit_addr_o = pix_x[4:2];
   always @*
      case(pix_x[8:5])
         4'h5: char_addr_o = 7'h47; // G
         4'h6: char_addr_o = 7'h41; // A
         4'h7: char_addr_o = 7'h4d; // M
         4'h8: char_addr_o = 7'h45; // E
         4'h9: char_addr_o = 7'h00; //
         4'ha: char_addr_o = 7'h4f; // O
         4'hb: char_addr_o = 7'h56; // V
         4'hc: char_addr_o = 7'h45; // E
         default: char_addr_o = 7'h52; //R
      endcase
      
      
   //-------------------------------------------
      // game clear region
      //  - display "GAME CLEAR" at center
      //  - scale to 32-by-64 fonts
      //-----------------------------------------
      
     
      assign clear_on = (pix_y[9:6]==3) &&
                       (5<=pix_x[9:5]) && (pix_x[9:5]<=13);
      assign row_addr_c = pix_y[5:2];
      assign bit_addr_c = pix_x[4:2];
      always @*
         case(pix_x[8:5])
            4'h5: char_addr_c = 7'h00; // 
            4'h6: char_addr_c = 7'h00; // 
            4'h7: char_addr_c = 7'h43; //  C
            4'h8: char_addr_c = 7'h4c; //  L
            4'h9: char_addr_c = 7'h45; //  E
            4'ha: char_addr_c = 7'h41; //  A
            4'hb: char_addr_c = 7'h52; //  R
            4'hc: char_addr_c = 7'h00; // 
            default: char_addr_c = 7'h00;
         endcase
 
   
   
   //-------------------------------------------
   // mux for font ROM addresses and rgb
   //-------------------------------------------
   always @*
   begin
      text_rgb = 12'b0000_0000_0000;  // background, yellow
      if (level_on)
         begin
            char_addr = char_addr_s;
            row_addr = row_addr_s;
            bit_addr = bit_addr_s;
            if (font_bit)
               text_rgb = 12'b0000_1110_0000;
         end
      
      else if(game_over)
            begin
                char_addr = char_addr_o;
                row_addr = row_addr_o;
                bit_addr = bit_addr_o;
                if (font_bit)
                   text_rgb = 12'b0000_1111_0000;
             end
         
      else if(game_clear)
          begin
                char_addr = char_addr_c;
                row_addr = row_addr_c;
                bit_addr = bit_addr_c;
                if(font_bit)
                    text_rgb = 12'b0000_1111_0000;
          end
          
       
   end

   assign text_on = {level_on, over_on, clear_on};
   //-------------------------------------------
   // font rom interface
   //-------------------------------------------
   assign rom_addr = {char_addr, row_addr};
   assign font_bit = font_word[~bit_addr];

endmodule
