`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2018 12:08:47 PM
// Design Name: 
// Module Name: slwerClkGen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module slowerClkGen(clk, clk_50MHz);
    input clk;
    output reg clk_50MHz;
    reg counter_50MHz; 
    
    always @ (posedge clk)
    begin
	  counter_50MHz = counter_50MHz +1;
	  if (counter_50MHz == 1)
		begin
	      clk_50MHz=~clk_50MHz;
		  counter_50MHz = 0;
		end
	  end
endmodule