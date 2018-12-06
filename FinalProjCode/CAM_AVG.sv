module CAM_AVG (
	input VGA_CLK,
	input RST, 
	input [7:0] pixel,
	output [7:0] color
);

logic [31:0] acc, counter;
logic [7:0] color_max;
logic [7:0] color_reg;

logic [7:0] abs_counter;

assign color = color_reg;
		
always_ff @(posedge VGA_CLK)
	if(~RST) begin
		acc <= 0;
		counter <= 0;
		color_max <= 0;
		
		// once every 30 frames
		if (abs_counter >= 8'h1E) begin
			color_reg <= acc / counter;
			abs_counter <= 0;
		end
		else
			abs_counter <= abs_counter + 1;
	end
	else begin
		if (pixel > color_max)
			color_max <= pixel;
		acc <= acc + pixel;
		counter <= counter + 1;
	end
endmodule

module CAM_AVG_testbench();
logic VGA_CLK;
logic RST;
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
	RST = 1; pixel = 0; 		@(posedge VGA_CLK);
	RST = 0; pixel = 200; 	@(posedge VGA_CLK);
	RST = 1;  					@(posedge VGA_CLK);
	#(CLOCK_PERIOD*100);		@(posedge VGA_CLK);
	RST = 0;					 	@(posedge VGA_CLK);
	RST = 1; 
	for(i = 0; i < 100; i++) begin
		pixel = i + 200; @(posedge VGA_CLK);
	end	
	
	RST = 0;					 	@(posedge VGA_CLK);
	RST = 1; 
	for(i = 0; i < 100; i++) begin
		pixel = i; @(posedge VGA_CLK);
	end	
	
	RST = 0;					 	@(posedge VGA_CLK);
	RST = 1;						@(posedge VGA_CLK);
	$stop;
end

endmodule