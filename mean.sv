module mean
		#(
			parameter N = 3,
			parameter datan = 8
		)
		(
		 clock,
		 reset,
		 data, 
		 q
		 );
	
	input clock;
	input reset;
	input [N-1:0] data [datan-1:0];
	output logic [datan-1:0] q;
	
	int sum = 0;
	
	always_ff @(posedge clock) begin
		if (reset)
			sum <= 0;
		sum <= data.sum;
		q <= sum / N;
	end

endmodule 

module mean_testbench();
	parameter N = 3;
	parameter datan = 8;
	logic clock;
	logic reset;
	logic [N-1:0] data [datan-1:0];
	logic q;
	
	mean #(N, datan) dut (clock, reset, data, q);
	
	parameter CLOCK_PERIOD = 20000;
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock;
	end
	
	int i;
	initial begin
		data[0] = 8'b00101010;
		data[1] = 8'b00111011;
		data[2] = 8'b00000111;
		
		for (i = 0; i < 15; i++)
			@(posedge clock);

	end
	

endmodule 