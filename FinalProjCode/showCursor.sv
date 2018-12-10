module showCursor
#(parameter H = 480, W = 640)
(
	VGA_Cin_R, VGA_Cin_G, VGA_Cin_B,
	cursorX, cursorY,
	VGA_X, VGA_Y,
	VGA_Cout_R, VGA_Cout_G, VGA_Cout_B
);

input [7:0]	VGA_Cin_R, VGA_Cin_G, VGA_Cin_B;
input [10:0] cursorX, cursorY;
input [9:0] VGA_X, VGA_Y;
output [7:0] VGA_Cout_R, VGA_Cout_G, VGA_Cout_B;

parameter WHITE = 24'hFF_FF_FF,
			 BLACK = 24'h00_00_00,
			 RED   = 24'hFF_00_00,
			 BLUE  = 24'h00_00_FF,
			 GREEN = 24'h00_FF_00;	

//    x x x
//	 x o o 
//x o o 
//x o   o
//x        

logic [23:0] color;

always_comb begin
	color = {VGA_Cin_R, VGA_Cin_G, VGA_Cin_B};
	
	if(VGA_X == 0 | VGA_X == W-1)
		color = WHITE;
	if(VGA_Y == 0 | VGA_Y == H-1)
		color = WHITE;
	
//	if(VGA_X == 1 | VGA_X == W-3)
//		color = WHITE;
//	if(VGA_Y == 1 | VGA_Y == H-1)
//		color = WHITE;
//	
	if(VGA_X == cursorX & VGA_Y == cursorY)
		color = RED;
	if(VGA_X == cursorX & ( (VGA_Y - cursorY) < 4 | (cursorY - VGA_Y) < 4))
		color = RED;
	if(VGA_Y == cursorY & ( (VGA_X - cursorX) < 4 | (cursorX - VGA_X) < 4))
		color = RED;
end

assign {VGA_Cout_R, VGA_Cout_G, VGA_Cout_B} = color;
//assign VGA_Cout_G = color[15:8];
//assign VGA_Cout_B = color[7:0];

endmodule

module showCursor_testbench();
logic [7:0]	VGA_Cin_R, VGA_Cin_G, VGA_Cin_B;
logic [10:0] cursorX, cursorY;
logic [9:0] VGA_X, VGA_Y;
logic [7:0] VGA_Cout_R, VGA_Cout_G, VGA_Cout_B;

showCursor #(10, 10) dut (.*);

int i, j;
initial begin
VGA_Cin_R = 127; VGA_Cin_G = 127; VGA_Cin_B = 127;
for(i = 0; i < 10; i++) begin
	for(j = 0; j < 10; j++) begin
		cursorX = 5; cursorY = 5; VGA_X = i; VGA_Y = j; #1;
	end
end
$stop;
end
endmodule