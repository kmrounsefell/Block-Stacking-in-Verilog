module Sound_sheet( input [9:0] number, 
	output reg [19:0] note,//max 32 different musical notes
	output reg [4:0] duration);
parameter   WHOLE = 5'b10000;
parameter   QUARTER = 5'b00010;//2 Hz
parameter	HALF = 5'b00100;
parameter   EIGHTH = 5'b00010;
parameter	ONE = 2* HALF;
parameter	TWO = 2* ONE;
parameter	FOUR = 2* TWO;
parameter B4 = 101238.5525, C4= 191112.5041, D4=170262.0333, E4 = 151686.1432, F4= 143176.2213, G4 = 127552.6474, C5 = 95556.434, A4 = 113636.3636, 
          E5 = 75843.1866, E5FLAT = 80353.0391, D5 = 85131.016, C5SHARP = 90193.284, A4SHARP = 107258.3898, A5 = 56818.18, F5 = 71586.47, SP = 1;  
 //key parameter : 50million / key freq

 //bounce
always@(number)
begin
    case(number) 
0: 	begin note = F4;  duration = HALF;	end	
1: 	begin note = SP;  duration = QUARTER;	end	
2: 	begin note = F4;  duration = HALF;	end	
3: 	begin note = SP; duration = QUARTER; 	end	
4: 	begin note = D4; duration = EIGHTH; 	end	
5: 	begin note = SP; duration = QUARTER; 	end
6: 	begin note = F4;  duration = HALF;	    end	
7: 	begin note = SP; duration = QUARTER; 	end	
8: 	begin note = C4; duration = EIGHTH; 	    end	
9: 	begin note = SP; duration = QUARTER; 	    end	
10: 	begin note = F4; duration = EIGHTH; 	end	
11: 	begin note = SP; duration = QUARTER; 	end	
12: 	begin note = D4; duration = QUARTER; 	end	
13: 	begin note = SP; duration = QUARTER; 	end	
14: 	begin note = C4; duration = QUARTER; 	end	
15: 	begin note = SP; duration = QUARTER; 	end	
16: 	begin note = F4; duration = HALF; 	end	
17: 	begin note = SP; duration = QUARTER; 	    end  
18: 	begin note = C5; duration = EIGHTH; 	    end  
19: 	begin note = SP; duration = QUARTER; 	    end  
20: 	begin note = D5; duration = EIGHTH; 	    end  
21: 	begin note = SP; duration = QUARTER; 	    end  
22: 	begin note = C5; duration = EIGHTH; 	    end  
23: 	begin note = SP; duration = QUARTER; 	    end  
24: 	begin note = D5; duration = EIGHTH; 	    end  
25: 	begin note = SP; duration = QUARTER; 	    end  
26: 	begin note = C5; duration = EIGHTH; 	    end  
27: 	begin note = SP; duration = QUARTER; 	    end  
28: 	begin note = C4; duration = EIGHTH; 	    end  
29: 	begin note = A4SHARP; duration = EIGHTH; 	    end  
30: 	begin note = A4; duration = EIGHTH; 	    end  
31: 	begin note = G4; duration = QUARTER; 	    end  
32: 	begin note = F4; duration = QUARTER; 	    end  
default: 	begin note = SP; duration = FOUR; 	end
    endcase
end


endmodule
