module mouse_controller #(parameter H = 480, W = 640)
(clk, start, reset, PS2_CLK, PS2_DAT, MS_DIR,
									enable, clr, middle, x, y);
	input logic clk;
	input logic reset, start;
	output logic enable, clr, middle;
	inout  PS2_CLK;
	inout  PS2_DAT;
	output [8:0] MS_DIR;
		
	output logic [10:0] x, y;
	logic [10:0] prev_x, prev_y;
//	SEG7_LUT d0 (.iDIG(x),.oSEG(HEX0));
//	SEG7_LUT d1 (.iDIG(y),.oSEG(HEX1));
			
	ps2 #(
			.WIDTH(640),//640
			.HEIGHT(480),//480
			.BIN(20),
			.HYSTERESIS(30))
	U1(
			.start(start),  
			.reset(reset),  
			.CLOCK_50(clk),  
			.PS2_CLK(PS2_CLK), 
			.PS2_DAT(PS2_DAT), 
			.button_left(enable),  
			.button_right(clr),  
			.button_middle(middle), 
			.bin_x(x),
			.bin_y(y)
			);
	
	always_ff @(posedge PS2_CLK) begin
		if (reset) begin
			prev_x <= 0;
			prev_y <= 0;
		end
		else begin
			prev_x <= x;
			prev_y <= y;
		end
	end
	
	always_comb begin
	MS_DIR = '0;
	if ((prev_x == x) && (prev_y == y)) begin	//no motion detected
			MS_DIR[4] = 1'b1;
		end
		else begin											//motion
			if (prev_x > x) begin
				MS_DIR[3] = 1'b1;
				MS_DIR[5] = 1'b0;
			end
			else begin
				MS_DIR[5] = 1'b1;
				MS_DIR[3] = 1'b0;
			end
			if (prev_y > y) begin
				MS_DIR[1] = 1'b1;
				MS_DIR[7] = 1'b0;
			end
			else begin
				MS_DIR[7] = 1'b1;
				MS_DIR[1] = 1'b0;
			end
		end
	end
endmodule
