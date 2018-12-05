module mouse_controller (clk, start, reset, PS2_CLK, PS2_DAT,
								GPIO_0, enable, clr, middle, x, y);

	input logic clk;
	input logic reset, start;
	output logic enable, clr, middle;
	inout  PS2_CLK;
	inout  PS2_DAT;
	inout [35:0] GPIO_0;
		
	output logic [10:0] x, y;
	logic [10:0] prev_x, prev_y;
//	SEG7_LUT d0 (.iDIG(x),.oSEG(HEX0));
//	SEG7_LUT d1 (.iDIG(y),.oSEG(HEX1));
			
	ps2 #(
			.WIDTH(640),//640
			.HEIGHT(480),//480
			.BIN(100),
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
	if ((prev_x == x) && (prev_y == y)) begin	//no motion detected
			GPIO_0[1] = 1;
			GPIO_0[0] = 0;
		end
		else begin											//motion
			GPIO_0[0] = 1;
			GPIO_0[1] = 0;
		end
	end
	
endmodule
