module fir_filter_fifo
#(
	parameter N=3 // 3 bit address
)
(
	clock, reset, enable, read_ready, write_ready, d, q
);

input logic clock, enable, reset, read_ready, write_ready;
input logic signed [23:0] d;
output logic signed [23:0] q;

// FIFO variables
logic signed [23:0] fifo_in, fifo_out;
logic signed [23:0] fifo_inv;
logic empty, full;
logic rd, wr;

//logic [N-1:0] counter;

// Accumulator variables
logic signed [23:0] accm_d, accm_q;
// Filter Var
logic signed [23:0] filter_out;

fifo #(.DATA_WIDTH(24), .ADDR_WIDTH(N)) fir 
	(.clk(clock), .reset, .rd, .wr, .w_data(fifo_in), .empty, .full, .r_data(fifo_out));

D_FF #(24) flipflop (.d(accm_d), .q(accm_q), .clk(clock), .reset);

always_comb begin
	// Read when FIFO is full and filter is enabled
	rd = (enable & full & read_ready) ? 1'b1 : 1'b0;
	
	// Write when filter is enabled
	wr = (enable & read_ready) ? 1'b1 : 1'b0;
	
	// Compute next sample
	fifo_in = d >>> N;
	
	// Compute filter output
	fifo_inv = full ? fifo_out : '0; // Only read the fifo rd output when full
	accm_d = (enable & read_ready) ? (fifo_in - fifo_inv + accm_q) : accm_q;
end

assign q = enable ? accm_d : d;

endmodule 

module fir_filter_fifo_testbench();
	logic clock, enable, reset;
	logic read_ready, write_ready;
	logic signed [23:0] d;
	logic signed [23:0] q;
	
	parameter N = 3;
	
	fir_filter_fifo #(N) dut (.*);
	
	parameter CLOCK_PERIOD = 20000;
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock;
	end
	int i;
	initial begin
		enable = 0;
		reset = 1; @(posedge clock);
		reset = 0;
		for (i = 0; i < 300; i++) begin
			enable = 1; read_ready = 1; d = 200; @(posedge clock);
			
		end
		$stop;
	end
	
endmodule 

