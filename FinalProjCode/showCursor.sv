/*
EE 371 Final Project - FPGA Drawing Application
Author(s): Kelvin Lin, Nate Park

showCursor.sv
Implementation as a multiplexer. Muxes the input RGB values with preset colors,
controlled based on the VGA X-Y pointer and/or the cursor position.

By default, draws the boundary of the drawing space in white, cursor in red.
This module goes in between the VGA driver and the VGA output
*/

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

// Pre-defined RGB colors
parameter WHITE = 24'hFF_FF_FF,
			 BLACK = 24'h00_00_00,
			 RED   = 24'hFF_00_00,
			 BLUE  = 24'h00_00_FF,
			 GREEN = 24'h00_FF_00;	

logic [23:0] color;

always_comb begin
	// Default to input color
	color = {VGA_Cin_R, VGA_Cin_G, VGA_Cin_B};
	
	// Override default color based on if specific conditions are met 
	
	
	// 1. Boundary of the drawing space
	//Testbench
	if(VGA_X == 0 | VGA_X == W-1)
		color = WHITE;
	if(VGA_Y == 0 | VGA_Y == H-1)
		color = WHITE;
	
//	// EE Lab Monitors
//	if(VGA_X == 1 | VGA_X == W-3)
//		color = WHITE;
//	if(VGA_Y == 1 | VGA_Y == H-1)
//		color = WHITE;
//	
	// 2. Overlay with the Cursor
	// Cursor is defined as a + sign with length 3, centered around cursor position
	if(VGA_X == cursorX & VGA_Y == cursorY)
		color = RED;
	if(VGA_X == cursorX & ( (VGA_Y - cursorY) < 4 | (cursorY - VGA_Y) < 4))
		color = RED;
	if(VGA_Y == cursorY & ( (VGA_X - cursorX) < 4 | (cursorX - VGA_X) < 4))
		color = RED;
end

// Assign color to output
assign {VGA_Cout_R, VGA_Cout_G, VGA_Cout_B} = color;

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