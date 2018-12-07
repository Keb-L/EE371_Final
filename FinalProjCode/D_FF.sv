 
// Synchronous reset D Flip-flop
// Parameterized width 
// Clocks in input d into output q as the posedge of a clk
//
module D_FF #(parameter WIDTH = 1) 
	(	input logic  [WIDTH-1:0] d, 
		output logic [WIDTH-1:0] q, 
		input logic 				 clk, 
		input logic 				 reset );

	always @( posedge clk )
	if ( reset ) begin
		q <= {WIDTH{1'b0}}; // Reset to all zeroes
	end else begin
		q <= d;
	end
		
endmodule


module D_FF_testbench();
	logic clk, reset;
	
	logic [7:0] d, q;
	
	parameter CLOCK_PERIOD = 20000;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	D_FF #(8) dut(.d, .q, .clk, .reset);
	
	// d should be clocked into q with a single posedge delay.
	// reset should override d clock into q for the previous clocked d.
	initial begin
		reset <= 0;	d <= 0;	q <= 0;	@ (posedge clk);
		reset <= 1;							@ (posedge clk);
		reset <= 0; d <= 1;				@ (posedge clk);
						d <= 2;				@ (posedge clk);
						d <= 3;				@ (posedge clk);
						d <= 4;				@ (posedge clk);
						d <= 5;				@ (posedge clk);
						d <= 31;				@ (posedge clk);
						d <= 63;				@ (posedge clk);
						d <= 127;			@ (posedge clk);
						d <= 255;			@ (posedge clk);
		reset <= 1; d <= 127;			@ (posedge clk);
		reset <= 0; 						@ (posedge clk);
												@ (posedge clk);
		$stop;
	end
	

endmodule