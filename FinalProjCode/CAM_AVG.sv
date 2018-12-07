module CAM_AVG (
	input VGA_CLK,
	input V_SYNC, 
	input RST_N,
	input [7:0] pixel,
	output [7:0] color
);

logic [31:0] acc, counter;
logic [7:0] color_max;
logic [7:0] color_reg;

logic [7:0] frame_counter;

assign color = color_reg;

always_ff @(posedge VGA_CLK or negedge RST_N or negedge V_SYNC) begin
	if(~RST_N) begin
		acc <= 0;
		counter <= 0;
		color_max <= 0;
		frame_counter <= 0;
	end
	else if(~V_SYNC) begin
		acc <= 0;
		counter <= 0;
		color_max <= 0;	
		
		// once every 30 frames
		if (frame_counter >= 8'd30) begin
			color_reg <= acc / counter;
			frame_counter <= 0;
		end
		else
			frame_counter <= frame_counter + 1;
	end
	else begin
		if (pixel > color_max)
			color_max <= pixel;
		acc <= acc + pixel;
		counter <= counter + 1;
	end
end
endmodule

module CAM_AVG_testbench();
logic VGA_CLK;
logic RST_N, V_SYNC;
logic [7:0] pixel;
logic [7:0] color;

CAM_AVG dut (.*);

parameter CLOCK_PERIOD = 20000;
initial begin
	VGA_CLK <= 0;
	forever #(CLOCK_PERIOD/2) VGA_CLK <= ~VGA_CLK;
end

int i;
initial begin
	RST_N = 0; @(posedge VGA_CLK);
	RST_N = 1; @(posedge VGA_CLK);
	V_SYNC = 1; pixel = 0; 		@(posedge VGA_CLK);
	V_SYNC = 0; pixel = 200; 	@(posedge VGA_CLK);
	V_SYNC = 1;  					@(posedge VGA_CLK);
	#(CLOCK_PERIOD*100);		@(posedge VGA_CLK);
	V_SYNC = 0;					 	@(posedge VGA_CLK);
	V_SYNC = 1; 
	for(i = 0; i < 100; i++) begin
		pixel = i + 200; @(posedge VGA_CLK);
	end	
	
	V_SYNC = 0;					 	@(posedge VGA_CLK);
	V_SYNC = 1; 
	for(i = 0; i < 100; i++) begin
		pixel = i; @(posedge VGA_CLK);
	end	
	
	V_SYNC = 0;					 	@(posedge VGA_CLK);
	V_SYNC = 1;						@(posedge VGA_CLK);
	$stop;
end

endmodule