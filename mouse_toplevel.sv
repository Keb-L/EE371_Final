module mouse_toplevel (CLOCK_50, KEY, PS2_CLK, PS2_DAT, GPIO_0, enable, clr, middle);

	input logic CLOCK_50;
	output logic enable, clr, middle;
	input logic [3:0] KEY;
	inout  PS2_CLK;
	inout  PS2_DAT;
	inout [35:0] GPIO_0;
		
	wire [3:0] x, y;
	logic [3:0] prev_x, prev_y;
	logic reset;
	assign reset = ~KEY[1];
//	SEG7_LUT d0 (.iDIG(x),.oSEG(HEX0));
//	SEG7_LUT d1 (.iDIG(y),.oSEG(HEX1));
			
	ps2 #(
			.WIDTH(10),//640
			.HEIGHT(10),//480
			.BIN(100),
			.HYSTERESIS(30))
	U1(
			.start(~KEY[0]),  
			.reset(reset),  
			.CLOCK_50(CLOCK_50),  
			.PS2_CLK(PS2_CLK), 
			.PS2_DAT(PS2_DAT), 
			.button_left(enable),  
			.button_right(clr),  
			.button_middle(middle), 
			.bin_x(x),
			.bin_y(y)
			);
	
	always_ff @(posedge CLOCK_50) begin
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
