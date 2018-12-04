module DE1_SoC (	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
	output logic [9:0] LEDR,
	input logic [3:0] KEY,
	input logic [9:0] SW,

	input CLOCK_50,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output VGA_HS,
	output VGA_SYNC_N,
	output VGA_VS
);
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR = SW;
	
	logic [10:0] x, y;
	logic [23:0] color;
	
	logic [7:0] pixel_GS, R, G, B;
	logic [9:0] color_acc;
	
	parameter	H = 50,
					W = 50;
	
	always_comb begin
		if(x == 0 | y == 0 | x == W-1 | y == H-1)
			pixel_GS = 8'hFF;
		else
			pixel_GS = SW[7:0];
//		R = {8{SW[2]}};
//		G = {8{SW[1]}};
//		B = {8{SW[0]}};
//		color_acc = R + G + B;
//		pixel_GS = color_acc / 3;
	end
	
	VGA_framebuffer fb(.clk50(CLOCK_50), .reset(~KEY[0]), .x, .y,
				.pixel_GS, .pixel_write(1'b1),
				.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
				.VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));
				
	pixel_counter #(H, W) pc (.clock(CLOCK_50), .reset(~VGA_VS), .x, .y);
	
//	SMPTE_Bars(.x, .y, .R, .G, .B);
endmodule



module DE1_SoC_testbench();
	// Outputs
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	
	logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	logic VGA_BLANK_N;
	logic VGA_CLK;
	logic VGA_HS;
	logic VGA_SYNC_N;
	logic VGA_VS;
	
	// Inputs 
	logic [3:0] KEY;
	logic [9:0] SW;
	logic CLOCK_50;

	
	DE1_SoC dut (.*);
	
	parameter CLOCK_PERIOD = 20000;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
	KEY = '1; SW = '0; 	@(posedge CLOCK_50);
	KEY[0] = 0; 			@(posedge CLOCK_50);
	KEY[0] = 1;				@(posedge CLOCK_50);
	SW[2] = 1;				@(posedge CLOCK_50);
	#(CLOCK_PERIOD * 1000000);
	$stop;
	end
endmodule
