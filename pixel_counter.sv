module pixel_counter #(H = 640, W = 480)
 (
  input logic clock, reset,
  output logic [10:0] x, y
 );
 
 logic [10:0] x_ptr, y_ptr, x_ptrn, y_ptrn;
 logic hsync, vsync; 
 
 always_comb begin
 // Default
	hsync = 0;
	vsync = 0;
 
	x_ptrn = x_ptr + 1;
	y_ptrn = y_ptr;
	
	if (x_ptr + 1 == W) begin
		// HSYNC
		hsync = 1;
		
		x_ptrn = 0;
		if(y_ptr + 1 == H) begin
			//VSYNC
			vsync = 1;
			
			y_ptrn = 0;
		end
		else 
			y_ptrn = y_ptr + 1;
	end

 end
 
 assign x = x_ptr;
 assign y = y_ptr;
 
 always_ff @(posedge clock, posedge reset) begin
	if(reset) 
	  begin
		x_ptr <= 0; 
		y_ptr <= 0;
	  end 
	else 
	  begin
		x_ptr <= x_ptrn;
		y_ptr <= y_ptrn;
	  end
 end
 
 
 endmodule
 
 
module pixel_counter_testbench();
logic clock, reset;
logic [10:0] x, y;
logic hsync, vsync;

pixel_counter #(50, 50) dut (.*);

parameter CLOCK_PERIOD = 20000;
initial begin
	clock <= 0;
	forever #(CLOCK_PERIOD/2) clock <= ~clock;
end

initial begin
reset = 1; @(posedge clock);
reset = 0; @(posedge clock);
#(CLOCK_PERIOD * 2800);
$stop;
end

endmodule