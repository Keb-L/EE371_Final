module clearScreen
#(parameter WIDTH = 11,
				HACTIVE = 1280,
				VACTIVE = 640)
(
input logic clk, reset, en,
output logic [WIDTH-1:0] x, y
);

logic [WIDTH-1:0] x_reg, y_reg;

always_comb begin
	x = x_reg + 1; y = y_reg;

	// horizontal first
	if ( x + 1 > HACTIVE ) begin
		x = 0;
		y = y + 1;
	end
	
	if ( y + 1 > VACTIVE ) 
		y = 0;
end


always_ff @(posedge clk) begin
	if(reset) begin
		x_reg <= 0;
		y_reg <= 0;
	end 
	else begin
		x_reg <= x;
		y_reg <= y;
	end
end

endmodule

module clearScreen_testbench();

parameter WIDTH = 11;

logic clk, reset, en;
logic [WIDTH-1:0] x, y;
logic enClear, bufferClear;

clearScreen #(WIDTH, 4, 4) dut (.*);

parameter CLOCK_PERIOD = 20000;
initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk;
end
	

initial begin
reset <= 1; en <= 0; @(posedge clk);
							@(posedge clk);
reset <= 0;				@(posedge clk);
				en <= 1;	@(posedge clk);
				en <= 0;	@(posedge clk);
							@(posedge clk);
							#2000000;
$stop;
end

endmodule