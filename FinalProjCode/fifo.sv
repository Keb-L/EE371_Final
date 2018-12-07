// Listing 7.8
module fifo
   #(
    parameter DATA_WIDTH=24, // number of bits in a word
	 parameter ADDR_WIDTH=3	  // number of bits in an address
   )
   (
    input  logic clk, reset,
    input  logic rd, wr,
    input  logic [DATA_WIDTH-1:0] w_data,
    output logic empty, full,
    output logic [DATA_WIDTH-1:0] r_data
   );

   //signal declaration
   logic [ADDR_WIDTH-1:0] w_addr, r_addr;
   logic wr_en, full_tmp;

   // body
   // write enabled only when FIFO is not full or rd asserted
   assign wr_en = wr & (~full_tmp | rd);
   assign full = full_tmp;
   
   // instantiate fifo control unit
   fifo_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) c_unit
      (.*, .full(full_tmp));

   // instantiate register file
   reg_file 
      #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) f_unit (.*);
endmodule

module fifo_testbench();
parameter DATA_WIDTH=24; // number of bits in a word
parameter ADDR_WIDTH=3;  // number of address bits

logic clk, reset;
logic rd, wr;
logic [DATA_WIDTH-1:0] w_data, r_data;
logic empty, full;

fifo #(DATA_WIDTH, ADDR_WIDTH) dut (.*);

parameter CLOCK_PERIOD = 20000;
initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk;
end

int i;
initial begin
reset = 1;	@(posedge clk);
wr = 1;		@(posedge clk);
reset = 0;  
for(i=1; i<300; i++) begin
	if(full) 
		rd = 1;
	else
		rd = 0;
	w_data = i; @(posedge clk);
end
					@(posedge clk);
$stop;
end


endmodule
